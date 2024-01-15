## Combining all files with sentiment scores ##

library(caTools) ## split train test
library(zoo)  ## for forward filling
library(glmnet) ## for regularization
library(stargazer) ## format model output
library(dplyr)
library(lubridate)

## input path ##

path <- "./../final_datasets/news_data/final/"
path_stock <- "./../final_datasets/market_data/"

result <- list()
output_df <- data.frame()
stock_names <- c("aapl","tsla","goog","cost","f","pg")
for(stock in stock_names){
  result[[stock]] <- read.csv(paste0(path, stock, ".csv"), check.names = F)
  result[[stock]]$Stock <- toupper(stock)
  result[[stock]] <- select(result[[stock]], Date, sentiment_score, Stock)
  colnames(result[[stock]]) <- c("Date", "SentimentScore", "Stock")
  result[[stock]] <- result[[stock]] %>% distinct(Date, .keep_all = TRUE)
  result[[stock]] <- na.omit(result[[stock]])
  output_df <- rbind(output_df, result[[stock]])
}

all_dates <- unique(output_df$Date)
all_dates <- subset(all_dates, all_dates >= as.Date("2021-10-07"))
all_dates_df <- data.frame(Date = all_dates)


output_df <- data.frame()
for(stock in stock_names){
  
  result[[stock]] <- merge(all_dates_df, result[[stock]], by = "Date", all.x = TRUE)
  result[[stock]] <- result[[stock]][order(result[[stock]]$Date), ]
  result[[stock]]$Stock <- toupper(stock)
  result[[stock]] <- na.locf(result[[stock]])
  output_df <- rbind(output_df, result[[stock]])
}

output_df <- output_df[output_df$Date >= "2021-10-11", ]

## trading holidays ##

holiday_func <- function(holidate) {
  while(as.character(holidate) %in% holidays){
    #print("it's a holiday")
    #print(holidate)
    holidate <- as.Date(holidate) + days(1)
  }
  return(as.character(holidate))
}

## reading stock price data ##
result_stock <- list()
output_stock_df <- data.frame()
for(stock in stock_names){
  result_stock[[stock]] <- read.csv(paste0(path_stock, stock, ".csv"), check.names = F)
  result_stock[[stock]]$Stock <- toupper(stock)
  result_stock[[stock]] <- select(result_stock[[stock]], Date, `Change %`, Stock)
  colnames(result_stock[[stock]]) <- c("Date", "PriceChange", "Stock")
  result_stock[[stock]]$PriceChange <- gsub("%", "", result_stock[[stock]]$PriceChange)
  result_stock[[stock]]$PriceChange <- as.numeric(result_stock[[stock]]$PriceChange)
  result_stock[[stock]] <- result_stock[[stock]] %>% arrange(Date)
  result_stock[[stock]] <- result_stock[[stock]][,c("Date", "PriceChange","Stock")]
  result_stock[[stock]] <- na.omit(result_stock[[stock]])
  colnames(result_stock[[stock]]) <- c("Date", "PriceChange", "Stock")
  output_stock_df <- rbind(output_stock_df, result_stock[[stock]])
}

stock_price_data_date <- unique(output_stock_df[,c("Date")])
sentiment_dataset_date <- unique(output_df[,c("Date")])

holidays <- setdiff(sentiment_dataset_date, stock_price_data_date)
holidays <- sort(holidays)

## holiday adjustment ##
output_df$AdjustedDate <- NA
for(i in 1:length(output_df$Date)){
  output_df[i,c("AdjustedDate")] <- holiday_func(output_df[i,c("Date")])
}

## average of adjusted_date ##
sentiment_dataset_new <- output_df %>%
  group_by(AdjustedDate, Stock) %>%
  summarise(Avg_Value = mean(SentimentScore, na.rm = TRUE))
colnames(sentiment_dataset_new) <- c("Date","Stock","SentimentScore")


## regression ##

## merge datasets ##
merged_stock_sentiment <- merge(output_stock_df, sentiment_dataset_new, by = c("Date","Stock"), all = TRUE)

train_set <- merged_stock_sentiment[merged_stock_sentiment$Date <= "2023-09-01", ]
test_set <- merged_stock_sentiment[merged_stock_sentiment$Date > "2023-09-01", ]

merged_stock_sentiment <- train_set
merged_stock_sentiment_test <- test_set

## model 1 - Independent variable - PriceChange, Dependendent variables - SentimentScore and Stock ##
model <- lm(PriceChange ~ SentimentScore + I(Stock) , data = merged_stock_sentiment)
summary(model)

## Effect of SPY Index News on Price Change of Stocks ##

spy <- read.csv("./../final_datasets/news_data/final/spy_calculated.csv", check.names =F)
spy <-  spy[,c("Date","sentiment_score")]
colnames(spy) <- c("Date","SPYSentiment")
spy <- spy %>% distinct(Date, .keep_all = TRUE)

merged_stock_sentiment_2 <- merge(merged_stock_sentiment, spy, by = "Date", all.x = TRUE)
merged_stock_sentiment_2 <- na.locf(merged_stock_sentiment_2, fromLast = TRUE)

merged_stock_sentiment_test_2 <- merge(merged_stock_sentiment_test, spy, by = "Date", all.x = TRUE)
merged_stock_sentiment_test_2 <- na.locf(merged_stock_sentiment_test_2, fromLast = TRUE)

## model 2 - Independent variable - PriceChange, Dependendent variables - SentimentScore and Stock and SPYSentiment ##
model_2 <- lm(PriceChange ~ SentimentScore + I(Stock) + SPYSentiment, data = merged_stock_sentiment_2)
summary(model_2)

## Effect of Layoff News on Price Change of Stocks ##
source("./layoff.R")
merged_stock_sentiment_3 <- merge(merged_stock_sentiment_2, layoff_data, by = "Date", all.x = TRUE)
merged_stock_sentiment_3$LayoffSentiment <- ifelse(is.na(merged_stock_sentiment_3$LayoffSentiment), 0, merged_stock_sentiment_3$LayoffSentiment)

merged_stock_sentiment_test_3 <- merge(merged_stock_sentiment_test_2, layoff_data, by = "Date", all.x = TRUE)
merged_stock_sentiment_test_3$LayoffSentiment <- ifelse(is.na(merged_stock_sentiment_test_3$LayoffSentiment), 0, merged_stock_sentiment_test_3$LayoffSentiment)


## model 3 - Independent variable - PriceChange, Dependendent variables - SentimentScore and Stock and SPYSentiment and LayoffSentiment##
model_3 <- lm(PriceChange ~ SentimentScore + I(Stock) + SPYSentiment + LayoffSentiment, data = merged_stock_sentiment_3)
summary(model_3)

## stargazer view ##
formatted_model <- stargazer(list(model, model_2, model_3), type = "text")

## Regularization ##

## data preparation ##
merged_train_data <- model.matrix(PriceChange ~ SentimentScore + Stock + SPYSentiment + LayoffSentiment, data = merged_stock_sentiment_3)
merged_train_data_outcome <- merged_stock_sentiment_3$PriceChange

merged_test_data <- model.matrix(PriceChange ~ SentimentScore + Stock + SPYSentiment + LayoffSentiment, data = merged_stock_sentiment_test_3)
merged_test_data_outcome <- merged_stock_sentiment_test_3$PriceChange

## no pooling ##
model_no_pooling <- glmnet(x = merged_train_data, y = merged_train_data_outcome, alpha = 0, lambda = 0)
coef(model_no_pooling)

## complete pooling ##
model_complete_pooling <- glmnet(x = merged_train_data, y = merged_train_data_outcome, alpha = 0, lambda = 10^5)
coef(model_complete_pooling)

## ridge ##
cv_model_ridge <- cv.glmnet(x = merged_train_data, y = merged_train_data_outcome, alpha = 0)
best_lambda_ridge <- cv_model_ridge$lambda.min
best_lambda_ridge
## [1] 0.4412163 ## 
model_ridge <- glmnet(x = merged_train_data, y = merged_train_data_outcome, alpha = 0, lambda = best_lambda_ridge)
coef(model_ridge)

## predictions with test dataset ##
predicted_ridge <- predict(model_ridge, s = best_lambda_ridge, newx = merged_test_data)
merged_stock_sentiment_test_3$PredictedPrice <- predicted_ridge[,"s1"]

## calculating difference in values ##
actual <- merged_stock_sentiment_test_3$PriceChange
pred <- merged_stock_sentiment_test_3$PredictedPrice

## calculating residuals ##
residuals <- actual - pred

# Calculate standard deviation of residuals
std_dev_residuals <- sqrt(sum(residuals^2) / (length(residuals) - 2))
## [1] 1.927223 ##
