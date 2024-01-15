## QDA Project ##
## Topic: Effect of Financial News on Sentiment of Stocks ##

##  Setting home directory ##
setwd("/Users/sharvarirane/Documents/sharvari/QDA/final_codes")

## sourcing files ##

## data extraction from api ##
source("./data_extraction_api.R")

## data formatting ##
source("./data_formatting.R")

## after sentimental analysis in python, we get datasets stored in ./../final_datasets/final ##

## regression ##
source("./regression.R")

## visualization ##
source("./scatterplots.R")

