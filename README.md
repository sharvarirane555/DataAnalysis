---
title: "ReadMe"
output: html_document
date: "2023-11-27"
---

## Quantitative Data Analysis Project Readme

## Group Members:
Sharvari Rane
Aishwarya Bhure
Karishma Savant
Lida Ghasemi
Aksheya Unnikrishnan

## Topic: Effect of Financial News on Sentiment of Stocks

### Overview
This project explores the impact of financial news on the sentiment of stocks. The analysis involves several steps, including data extraction from an API, data formatting, sentiment analysis in Python, and regression modeling in R.

## Sentiment Analysis

Sentiment analysis was conducted in Python and sentiment scores were assigned to the news articles related to stocks on a daily basis.

__Overview__
The sentiment analysis involved the following steps:

1. **Data Loading**
   - Data files for Apple, Google, Tesla, Procter & Gamble (PG), Costco, and Ford were loaded using the Pandas library from CSV files. Each dataset contained information such as datetime, headlines, and summaries of news articles.

2. **Sentiment Analysis using VADER**
   - The VADER (Valence Aware Dictionary and sEntiment Reasoner) sentiment analysis tool from NLTK (Natural Language Toolkit) was used for sentiment analysis.
   - The sentiment analysis function was applied to each row of the datasets to calculate sentiment scores, including overall sentiment, negative sentiment, neutral sentiment, and positive sentiment.

3. **Sentiment Classification**
   - Sentiment thresholds were defined to classify sentiment as positive, negative, or neutral based on the overall sentiment score.

4. **Adding Sentiment Scores to Datasets**
   - Sentiment scores and sentiment labels (Positive, Negative, Neutral) were added to the respective datasets for Apple, Google, Tesla, PG, Costco, and Ford.

5. **Objective**
   - The sentiment analysis aimed to provide insights into the sentiment conveyed by news articles related to each company and specific topics, such as layoffs and the "S&P 500" Index.

6. **Utilization in Subsequent Analyses**
   - The obtained sentiment scores can be further utilized in subsequent analyses to explore the impact of sentiment on stock price changes.



## Folder: final_codes 
### File: qda_project.R
Ensures that the working directory is set to the appropriate location

The project is organized into separate R scripts for modularity and clarity. The following files are sourced in a specific order:

1. Data Extraction from API
2. Data Formatting
3. Sentimental Analysis in Python
4. Regression Modeling
5. Visualization

### File: data_extraction_api.R
__Note:__ This file cannot be rerun because the free API keys used were valid for 7 days

__Data Extraction from IEXCloud and AlphaVantage API__

This script extracts news data for specified stock names from IEXCloud and AlphaVantage APIs. The data includes headlines, summaries, and publication dates.

__Date Sequences__
The script defines date sequences for IEX and AlphaVantage APIs:

__Stock Names__
The script is designed to extract data for the following stock names:

1. AAPL (Apple)
2. TSLA (Tesla)
3. GOOG (Google)
4. COST (Costco)
5. F (Ford)
6. PG (Procter & Gamble)

__API Calls__
The script iterates over each stock, making API calls to IEX and AlphaVantage to fetch news data. The extracted data is then formatted and saved as CSV files.


### File: data_formatting.R

__Combining and Formatting Raw News Data__

This script combines and formats raw news data from multiple sources for the specified stock names. The process involves reading data from CSV files, formatting the content, and combining it into a final dataset.

__Stock Names__
The script is designed to process news data for the following stock names:
1. AAPL (Apple)
2. TSLA (Tesla)
3. GOOG (Google)
4. COST (Costco)
5. F (Ford)
6. PG (Procter & Gamble)


### File: layoff.R

__Effect of Layoff News on Price Change of Stocks__

This script analyzes the effect of layoff-related news on the sentiment and price change of stocks. It combines news data for specified stock names and extracts layoff-related keywords to identify relevant news articles.


__Data Aggregation__
Combines news data for specified stock names into a single data frame (layoff_data).

__Layoff Keywords Extraction__
Identifies layoff-related news articles by applying layoff keywords to the "News" column.

__Sentiment Assignment__
Assigns sentiment scores to layoff-related news articles.

__Data Transformation__
Selects relevant columns ("Date" and "LayoffSentiment").
Removes rows with missing values.
Retains unique dates to avoid duplication

__Output__
The resulting layoff_data data frame contains information about the sentiment of layoff-related news articles for the specified stocks.


### File: regression.R

__Combining all Files with Sentiment Scores__

This script combines sentiment scores from news data with stock price change information for the specified stocks (AAPL, TSLA, GOOG, COST, F, PG). It performs a regression analysis and applies regularization techniques to predict stock price changes based on sentiment scores and additional variables.

__Libraries Used__
1. `caTools`: For splitting the dataset into training and testing sets.
2. `zoo`: For forward filling missing values.
3. `glmnet`: For regularization techniques.
4. `stargazer`: For formatting model output.
5. `dplyr`: A data manipulation library in R.

__Input Paths__
Sets input paths

__Data Processing__


1. **Sentiment Scores Aggregation**
   - Reads sentiment scores from news data files for each stock.
   - Combines and formats sentiment scores into a unified data frame (`output_df`).
   - Handles missing values and duplicates.

2. **Stock Price Change Data Reading**
   - Reads stock price change data for each stock.
   - Formats and cleans the data.

3. **Date Alignment and Imputation**
   - Aligns all dates across different stocks.
   - Imputes missing values using the last observation carried forward (LOCF) method.

4. **Holiday Adjustment**
   - Adjusts dates to account for trading holidays.

5. **Regression Analysis**
   - Performs multiple linear regression to predict stock price changes based on sentiment scores and stock-specific variables.

6. **Regularization**
   - Applies regularization techniques (no pooling, complete pooling, ridge) using the glmnet library.
   - Evaluates the performance of the models and calculates the R^2 value.

7. **Outlier Removal**
   - Identifies and removes outliers to improve model performance.

8. **Prediction and Evaluation**
   - Predicts stock price changes using the trained model.
   - Calculates the difference between predicted and actual price changes.

__Outputs__
- Model summaries.
- Regularization results (coefficients, lambda values).
- Predicted values and evaluation metrics (R^2 values, difference between predicted and actual price changes).


## Folder: final_datasets 
### Folder: market_data

This folder contains files of market data of below stock downloaded from Investing.com to use in the project for comparison and analysis

1. AAPL (Apple)
2. TSLA (Tesla)
3. GOOG (Google)
4. COST (Costco)
5. F (Ford)
6. PG (Procter & Gamble)

### Folder: news_data/final

This folder contains files extracted news of the below stock and final files after sentiment analysis

1. AAPL (Apple)
2. TSLA (Tesla)
3. GOOG (Google)
4. COST (Costco)
5. F (Ford)
6. PG (Procter & Gamble)

### File: scatterplots.R

Visualization of SentimentScore vs. PriceChange for all stocks
