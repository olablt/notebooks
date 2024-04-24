library(httr)
library(jsonlite)

# Function to get Bybit tickers
get_bybit_tickers <- function(category, ticker = NULL, baseCoin = NULL, expDate = NULL) {
  # Base URL for the Bybit API
  base_url <- "https://api.bybit.com/v5/market/tickers"

  # Create a list of parameters
  params <- list(category = category)
  if (!is.null(ticker)) params$symbol <- ticker
  if (!is.null(baseCoin)) params$baseCoin <- baseCoin
  if (!is.null(expDate)) params$expDate <- expDate

  # Make the GET request
  response <- GET(url = base_url, query = params)

  # Check if the request was successful
  if (response$status_code == 200) {
    # Parse the JSON response
    data <- fromJSON(content(response, "text"), simplifyDataFrame = TRUE)
        # Assuming the data of interest is in a list within 'result.list'
    if ("result" %in% names(data) && "list" %in% names(data$result)) {
      ticker_data <- as_tibble(data$result$list) %>%
        select(
          symbol, lastPrice, price24hPcnt, volume24h, turnover24h
        ) %>%
        rename(
          ticker = symbol,
          last_price = lastPrice,
          price_24h_pct = price24hPcnt,
          volume_24h = volume24h,
          turnover_24h = turnover24h
        ) %>%
        mutate (
          across(c(last_price, price_24h_pct, volume_24h, turnover_24h), as.numeric)
        ) %>%
        arrange(desc(turnover_24h))
      return(ticker_data)
    } else {
      stop("Unexpected data structure in the response.")
    }
    return(data)
  } else {
    stop("Failed to retrieve data: ", response$status_code)
  }
}


# Function to get Bybit klines
single_bybit_prices <- function(category, symbol, interval, start, end) {
  # Base URL for the Bybit API
  base_url <- "https://api.bybit.com/v5/market/kline"

  start_unix = as.numeric(as.POSIXct(start, tz = "UTC", format = "%Y-%m-%d")) * 1000
  end_unix = as.numeric(as.POSIXct(glue("{end} 23:59:59"), tz = "UTC", format = "%Y-%m-%d %H:%M:%S")) * 1000
  # end_unix = as.numeric(as.POSIXct(end, tz = "UTC", format = "%Y-%m-%d")+ (23 * 3600 + 59 * 60 + 59))  * 1000

  # Create a list of parameters
  params <- list(category = category, symbol = symbol, interval = interval, limit = 1000)
  params$start <- start_unix
  params$end <- end_unix

  all_data <- data.frame()
  print(glue("[single_bybit_prices] loading prices for {symbol}"))

  # Loop to fetch data in chunks
  repeat {
    # Make the GET request
    response <- GET(url = base_url, query = params)
    # Check if the request was successful
    if (response$status_code == 200) {
      # Parse the JSON response and convert to a data frame
      data <- fromJSON(content(response, "text"), flatten = TRUE)
      # print(data$result$list)
      # break
      # Assuming the data of interest is in a list within 'result.list'
      if ("result" %in% names(data) && "list" %in% names(data$result)) {
        kline_data <- data$result$list
        if (length(kline_data) > 0) {
          # Set column names
          colnames(kline_data) <- c("OpenTime", "Open", "High", "Low", "Close", "Volume", "Turnover")
          # Convert to tibble
          kline_data <- as_tibble(kline_data)
          kline_data <- kline_data %>%
            mutate(
              OpenTime =  as.POSIXct(as.numeric(OpenTime) / 1000, origin = "1970-01-01", tz = "UTC"),
              across(c(Open, High, Low, Close, Volume, Turnover), as.numeric)
            ) %>%
            arrange(OpenTime)
          # Add data to all_data
          all_data <- rbind(all_data, kline_data)
          # Update start time for next request
          first_time <- min(kline_data$OpenTime)
          last_time <- max(kline_data$OpenTime)
          # start_unix <- as.numeric(last_time) * 1000 + 1
          # params$start <- start_unix
          end_unix <- as.numeric(first_time) * 1000 - 1
          params$end <- end_unix
          # Break the loop if we've fetched all data
          # print(length(kline_data$OpenTime))
          # print(as.POSIXct(as.numeric(start_unix) / 1000, origin = "1970-01-01", tz = "UTC"))
          # print(as.POSIXct(as.numeric(end_unix) / 1000, origin = "1970-01-01", tz = "UTC"))
          if (length(kline_data$OpenTime) < params$limit || start_unix > end_unix) {
            # print(start_unix > end_unix)
            # print("breaking")
            break
          }
        } else {
          # no data received
          break
        }
        # return(kline_data)
      } else {
        warning("Unexpected data structure in the response.")
        return(all_data)
      }
    } else {
      # stop("Failed to retrieve data: ", response$status_code)
      warning("Request failed. Status: ", http_status(response)$status_code, " - ", http_status(response)$reason)
      return(all_data)
    }
  }
  if (length(all_data) > 0) {
    all_data <- all_data %>%
    arrange(OpenTime)
  }
   return(all_data)
}

bybit_prices <- function(category = "spot", symbols, interval = "60", start, end) {
  # Helper function for adding a Ticker column and arranging columns
  fun <- function(category, symbol, interval, start, end) {
    prices <- single_bybit_prices(
      category, symbol, interval, start, end
    )
    if (length(prices) > 0) {
     prices <- prices %>%
      mutate(Symbol = symbol) %>%
      relocate(Symbol, .after = OpenTime)
    } else {
      print(glue("[bybit_prices] no prices for {symbol}"))
    }
    return (prices)
  }

  symbols %>%
    map_dfr(~fun(category, symbol = .x, interval, start, end)) %>%
    arrange(OpenTime)
}


# Function to get Bybit funding rates
single_bybit_funding_rates <- function(category, symbol, start, end) {
  # Base URL for the Bybit API (funding history)
  base_url <- "https://api.bybit.com/v5/market/funding/history"

  start_unix = as.numeric(as.POSIXct(start, tz = "UTC", format = "%Y-%m-%d")) * 1000
  end_unix = as.numeric(as.POSIXct(glue("{end} 23:59:59"), tz = "UTC", format = "%Y-%m-%d %H:%M:%S")) * 1000

  # Create a list of parameters
  params <- list(category = category, symbol = symbol, limit = 200)
  params$startTime <- start_unix
  params$endTime <- end_unix

  all_data <- data.frame()

  repeat {
    response <- GET(url = base_url, query = params)

    if (response$status_code == 200) {
      data <- fromJSON(content(response, "text"), flatten = TRUE)

      if ("result" %in% names(data) && "list" %in% names(data$result)) {
        funding_data <- data$result$list

        if (length(funding_data) > 0) {
          funding_data <- as_tibble(funding_data) %>%
            mutate(
              Time = as.POSIXct(as.numeric(fundingRateTimestamp) / 1000, origin = "1970-01-01", tz = "UTC"),
              Symbol = symbol,
              Rate = as.numeric(fundingRate)
            ) %>%
            arrange(Time) %>%
            select(Time, Symbol, Rate)

          all_data <- rbind(all_data, funding_data)

          first_time <- min(funding_data$Time)
          end_unix <- as.numeric(first_time) * 1000 - 1
          params$endTime <- end_unix

          if (length(funding_data$Time) < params$limit || start_unix > end_unix) {
            break
          }
        } else {
          break
        }
      } else {
        warning("Unexpected data structure in the response.")
        return(all_data)
      }
    } else {
      warning("Request failed. Status: ", http_status(response)$status_code, " - ", http_status(response)$reason)
      return(all_data)
    }
  }

  if (length(all_data) > 0) {
    all_data <- all_data %>%
    arrange(Time)
  }

  return(all_data)
}

bybit_funding_rates <- function(category = "linear", symbols, start, end) {
  fun <- function(category, symbol, start, end) {
    print(glue("Loading Symbol {symbol}"))
    rates <- single_bybit_funding_rates(category, symbol, start, end)
    if (length(rates) == 0) {
      print(glue("[bybit_funding_rates] no rates for {symbol}"))
    }
    return(rates)
  }

  symbols %>%
    map_dfr(~fun(category, symbol = .x, start, end)) %>%
    arrange(Time)
}


