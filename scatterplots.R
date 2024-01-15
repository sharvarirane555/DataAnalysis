## visualization ##
library(ggplot2)
library(gridExtra)

## create a scatterplot matrix ##
stock_names <- c("AAPL","TSLA","GOOG","COST","F","PG")
colours_list <- c("red","blue","green","orange","purple","yellow")

i = 0
list_plots <- c()
for(stock in stock_names){
  i = i+1
  merged_stock_sentiment_viz <- merged_stock_sentiment[merged_stock_sentiment$Stock == stock,]
  list_plots[[i]] <- ggplot(merged_stock_sentiment_viz, aes(x = SentimentScore, y = PriceChange, color = Stock)) +
    geom_point() +
    geom_smooth(method = "lm", se = FALSE, aes(group = Stock, color = "black")) +
    scale_color_manual(values = setNames(colours_list[i], stock)) +
    labs(title = paste0(stock),
         x = "SentimentScore",
         y = "PriceChange")
}

grid.arrange(grobs = list_plots, ncol = 3)


