## Effect of Layoff News on Price Change of Stocks ##

library(dplyr)

layoff_data <- data.frame()
stock_names <- c("aapl","tsla","goog","cost","f","pg")
path <- "./../final_datasets/news_data/final/"

for(stock in stock_names){
  news <- read.csv(paste0(path,stock,".csv"), check.names = F)
  layoff_data <- rbind(layoff_data, news)  
}

## extracting layoff keywords from data ##
layoff_keywords <- c("Layoff", "layoffs","laid off","recession","downsizing","downsize")

layoff_data$LayoffNews <- apply(layoff_data, 1, function(row) {
  matches <- grepl(paste(layoff_keywords, collapse = "|"), row["News"], ignore.case = TRUE)
  if (any(matches)) {
    return(grep(paste(layoff_keywords[matches], collapse = "|"), row["News"], ignore.case = TRUE, value = TRUE)[1])
  } else {
    return(NA)
  }
})

layoff_data$LayoffSentiment <- ifelse(is.na(layoff_data$LayoffNews), NA, layoff_data$sentiment_score)
layoff_data <- select(layoff_data,"Date","LayoffSentiment")
layoff_data <- na.omit(layoff_data)
layoff_data <- layoff_data %>% distinct(Date, .keep_all = TRUE)

