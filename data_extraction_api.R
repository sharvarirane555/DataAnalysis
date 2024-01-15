## Data Extraction from IEXCloud and AlphaVantage API ##

## importing libraries ##
library(httr)
library(readxl)
library(lubridate)
library(jsonlite)

## output path ##
path <- "./../final_datasets/news_data"

## list of dates, per month - starting 2022-11-10 for iex##
start_date <- as.Date("2022-11-01")
end_date <- Sys.Date()
date_sequence <- seq(start_date, end_date, by = "month")

## last date is today's date ##
date_sequence <- append(date_sequence, Sys.Date())

## list of dates, per month - starting 2022-07-01 for alphavantage##
start_date_av <- as.Date("2022-07-01")
end_date_av <- as.Date("2022-08-01")
date_sequence_av <- seq(start_date_av, end_date_av, by = "month")
## formatting date ##
date_sequence_av <- strptime(date_sequence_av, format = "%Y-%m-%d")
date_sequence_av <- strftime(date_sequence_av, format = "%Y%m%dT%H%M")
## list of stocks ##
stock_names <- c("aapl","tsla","goog","cost","f","pg")

## looping for stocks ##
for(stock in stock_names){
  
  print(paste0("Extracting data for ",stock))
  output_df_iex <- data.frame()  
  response_iex <- list()
  output_df_av <- data.frame()  
  response_av <- list()
  
  ## iex ##
  for(i in 1:length(date_sequence)){
    
    ## calling api##
    url <- paste0("https://cloud.iexapis.com/stable/time-series/news/",stock,"?from=",date_sequence[i],"&to=",date_sequence[i+1],"&format=csv&token=pk_3ef08b2d49bc474794cf440301b1cfe0")
    headers <- c('Authorization' = "Basic cGtfM2VmMDhiMmQ0OWJjNDc0Nzk0Y2Y0NDAzMDFiMWNmZTA6c2tfODRiMmUyMDEzZWE0NDhjODgzZDllNWJhYjI4MzNmZjE=",
                 'Cookie' = "ctoken=5b1b076d823e41f48b4cd784218428bb")
    
    response_iex[[i+1]] <- GET(url, add_headers(headers))
    output_df_iex <- rbind(output_df_iex, read.csv(text = content(response_iex[[i+1]], "text")))
  }
  
  ## alphavantage ##
  for(j in 1:length(date_sequence_av)){
    
    ## calling api##
    url_alphavantage <- paste0("https://www.alphavantage.co/query?function=NEWS_SENTIMENT&tickers=",stock,"&time_from=",date_sequence_av[j],"&sort=EARLIEST&limit=1000&apikey=47TLHUR3S9YRL6QY")
    
    response_av[[j+1]] <- GET(url_alphavantage)
    response_av[[j+1]] <- fromJSON(content(response_av[[j+1]], "text"), flatten = TRUE)
    response_av[[j+1]] <- as.data.frame(response_av[[j+1]])
    output_df_av <- rbind(output_df_av, response_av[[j+1]])
    
  }
  
  ## changing datetime format iex ##
  output_df_iex$datetime <- as.POSIXct(output_df_iex$datetime /1000,origin = "1970-01-01", tz = "UTC")
  output_df_iex$date <- as.POSIXct(output_df_iex$date /1000,origin = "1970-01-01", tz = "UTC")
  output_df_iex$updated <- as.POSIXct(output_df_iex$updated /1000,origin = "1970-01-01", tz = "UTC")
  write.csv(output_df_iex, paste0(path,"/raw_news_output_",stock,".csv"), row.names = FALSE, )
  
  ## store alphavantage data ##
  output_df_av <- output_df_av[,c("feed.time_published","feed.title","feed.summary")]
  write.csv(output_df_av, paste0(path,"/av_raw_news_output_",stock,".csv"), row.names = FALSE)
  
  ## sleep to avoid multiple "No encoding supplied" error ##
  Sys.sleep(10)
}
