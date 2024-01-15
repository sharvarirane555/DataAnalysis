## Combining and Formatting Raw News Data ##

library(dplyr)
stock_names <- c("aapl","tsla","goog","cost","f","pg")
path <- "./../final_datasets/news_data/"

data_iex <- list()
data_iex_headline <- list()
data_iex_summary <- list()
data_iex_final <- list()
data_av <- list()
data_av_headline <- list()
data_av_summary <- list()
data_av_final <- list()
data_final <- list()
i=0

for(stock in stock_names){
  i = i + 1
  ## read iex and av datasets ##
  print(paste0("Reading data for ",stock))
  data_iex[[i]] <- read.csv(paste0(path,"raw_news_output_",stock,".csv"), check.names = F)
  data_av[[i]] <- read.csv(paste0(path,"av_raw_news_output_",stock,".csv"), check.names = F)
  
  ## formatting iex ##
  data_iex[[i]] <- select(data_iex[[i]], datetime, headline, summary)
  data_iex_headline[[i]] <- select(data_iex[[i]], datetime, headline)
  data_iex_summary[[i]] <- select(data_iex[[i]], datetime, summary)
  colnames(data_iex_headline[[i]]) <- c("Date","News")
  colnames(data_iex_summary[[i]]) <- c("Date","News")
  data_iex_final[[i]] <- rbind(data_iex_headline[[i]],data_iex_summary[[i]])
  
  ## formatting av ##
  data_av_headline[[i]] <- select(data_av[[i]], feed.time_published, feed.title)
  data_av_summary[[i]] <- select(data_av[[i]], feed.time_published, feed.summary)
  colnames(data_av_headline[[i]]) <- c("Date","News")
  colnames(data_av_summary[[i]]) <- c("Date","News")
  data_av_final[[i]] <- rbind(data_av_headline[[i]],data_av_summary[[i]])
  
  data_av_final[[i]]$Date <- strptime(data_av_final[[i]]$Date, format = "%Y%m%dT%H%M%S")
  data_av_final[[i]]$Date <- strftime(data_av_final[[i]]$Date, format = "%Y-%m-%d %H:%M:%S")
  
  data_final[[i]] <- rbind(data_iex_final[[i]], data_av_final[[i]])
  write.csv(data_final[[i]],paste0(path,"temp_",stock,".csv"), row.names = F)
}

## read kaggle dataset ##
kaggle_tweets <- read.csv(paste0(path,"stock_tweets.csv"), check.names = F)
kaggle_tweets <- kaggle_tweets[,c("Date","Tweet","Stock Name")]
kaggle_tweets$Date <- strptime(kaggle_tweets$Date, format = "%Y-%m-%d %H:%M:%S+00:00")
kaggle_tweets$Date <- strftime(kaggle_tweets$Date, format = "%Y-%m-%d %H:%M:%S")
colnames(kaggle_tweets) <- c("Date","Tweet","Stock")
stock_names_upper <- sapply(stock_names, function(x) toupper(as.character(x)))
stock_datasets <- lapply(stock_names_upper, function(stock_name) {
  kaggle_tweets_new <- kaggle_tweets %>% filter(Stock == stock_name)
  return(kaggle_tweets_new)
})

for(j in 1:length(stock_names)){
  ## for kaggle ##
  stock_datasets[[j]] <- select(stock_datasets[[j]], Date, Tweet)
  colnames(stock_datasets[[j]]) <- c("Date","News")
  data_final[[j]] <- rbind(data_final[[j]], stock_datasets[[j]])
  write.csv(data_final[[j]], paste0(path,"final_",stock_names[j],".csv"), row.names = F)
}
  



