Crypto Research Pod
==========

The Lab's Crypto Pod contains research, code, data, and edges relating to crypto. 

[The Crytpo Pod's GitHub repo is here.](https://github.com/RWLab/crypto-pod)

Organisation
------------

- The `research` directory contains research notebooks
- The `techniques` directory contains notebooks on data analysis techniques
- The `trading` directory contains notebooks, scripts, and tools to help with trading. Note that other trading tools are provided outside the Crypto pod - details below.

Edge Database
-------------

Edges belonging to the Crypto pod can be found in the Edge Database's [Crypto Status View.](https://github.com/orgs/RWLab/projects/1/views/6)

Trading
-------

### YOLO Momentum and Trend Strategy

YOLO information provided is based on Binance data.

#### Trade helper spreadsheet

ThomasF has contributed a trade helper spreadsheet to pull arrival price, factor values, and target weight data from the RW API.

To use it, follow these steps: - Make your own copy of the publicly available spreadsheet [here](https://docs.google.com/spreadsheets/d/1IrNISXezOhTmM6tgvyl356eLDmz0X3EpJbgXA4N1UVA).  
- Enter your API key in cell N3 on the "Trades" tab
- Set your personal parameters in cells B2:B6 (nominal allocation, leverage, etc)
- Each day, enter your current positions in column G
- Place the trades that are calculated for you in column J - As usual, make sure the checks in the grey cells reconcile correctly - Each day, record your fills and funding payments in the relevant tabs
- Occasionally, as the universe of coins changes, you may need to update the tickers in column A.

#### Strategy dashboard

A strategy dashboard is available
[here](https://datastudio.google.com/u/0/reporting/b737c6c4-b142-42d5-91cb-080e19cc69fd).

It shows the weights for the momentum and trend factors (both current and time series), as well as arrival price for the traded coins.

Click "analytical dashboard" to see historical plots of the individual factors that make up the strategy.

#### API endpoint

The RW API exposes an endpoint that provides access to factor values, and trend, momentum, and 50/50 combined weights for each ticker in the current universe. 

The endpoint is https://api.robotwealth.com/v1/yolo/weights?api_key=YOUR-API-KEY and the documentation for the RW API is [here](https://robot-wealth.github.io/rw-api/#/Y.O.L.O/).

If you don't have any API key, get in touch with @robotkris on Slack and he'll generate a new one for you. 

Datasets
--------

What datasets are available in the Crypto Pod?

### coincondex_marketcap.feather

Daily resolution price and market capitalisation data from coincodex.com. Updates daily. 

Columns:

-   Ticker - Ticker name  
-   Date - Date in yyyy-mm-dd format  
-   Price - Price of the asset in USD\$ (unclear where price comes from, although it looks like an average price across several exchanges)  
-   Volume - 24 hour volume traded in USD\$ (probably consolidated volume from several exchanges, although this is undocumented)  -   
-   MarketCapUSD - Market capitalisation in USD\$

`rwRtools::crypto_get_coincodex()`

### binance_spot_1d.csv

Daily resolution spot price and volume data from the Binance spot kline (OHLCV) API endpoint. Includes USDT pairs only. Daily data snapshotted at midnight UTC.

The Binance kline spot data specification can be found [here](https://binance-docs.github.io/apidocs/spot/en/#kline-candlestick-data).

```R
rwRtools::rwlab_data_auth()
prices <- rwRtools::crypto_get_binance_spot_1d()
head(prices)
```

|ticker  |date       |    open|    high|     low|   close|    volume|
|:-------|:----------|-------:|-------:|-------:|-------:|---------:|
|BTCUSDT |2017-08-17 | 4261.48| 4485.39| 4200.74| 4285.08|  795.1504|
|ETHUSDT |2017-08-17 |  301.13|  312.18|  298.00|  302.00| 7030.7103|
|BTCUSDT |2017-08-18 | 4285.08| 4371.52| 3938.77| 4108.37| 1199.8883|
|ETHUSDT |2017-08-18 |  302.00|  311.79|  283.94|  293.96| 9537.8465|
|BTCUSDT |2017-08-19 | 4108.37| 4184.69| 3850.00| 4139.98|  381.3098|
|ETHUSDT |2017-08-19 |  293.31|  299.90|  278.00|  290.91| 2146.1977|


### binance_spot_1h.feather

Hourly resolution spot price and volume data from the Binance spot kline (OHLCV) API endpoint. Includes USDT pairs only. 

The Binance kline spot data specification can be found [here](https://binance-docs.github.io/apidocs/spot/en/#kline-candlestick-data).

`rwRtools::crypto_get_binance_spot_1h()`

### binance_perps_1h.feather

Hourly resolution perpetual futures price and volume data from the Binance futures kline (OHLCV) API endpoint.  

The Binance kline futures data specification can be found [here](https://binance-docs.github.io/apidocs/futures/en/#kline-candlestick-data).

`rwRtools::crypto_get_binance_perps_1h()`

### binance_perps_funding.feather

Perpetual futures funding data from the Binance futures funding API endpoint.  

The Binance futures funding data specification can be found [here](https://binance-docs.github.io/apidocs/futures/en/#get-funding-rate-history).

`rwRtools::crypto_get_binance_perps_funding()`

### Usage examples

[This notebook](https://github.com/RWLab/crypto-pod/blob/main/research/trend-momentum-spot-analysis/update_2023/using_binance_and_coincodex_data.ipynb) shows how to retrieve and use the Coincodex market capitalisation, Binance spot, and Binance futures datasets described above.

### coinmetrics.csv

***IMPORTANT:** coinmetrics.csv is now a static dataset as the source no longer exists for updating. It was used in the trend/momentum analysis to create a universe based on market cap. To roll this analysis forward, one approach is to freeze the universe at the time the dataset was last updated (end of June 2022).* 

Daily resolution price data loaded from the https://coinmetrics.io/ community
dataset.

Columns:

-   ticker - Ticker name

-   date - Date in yyyy-mm-dd format

-   price_usd - Price of the asset in USD\$

-   market_cap - Market Cap in USD\$

`rwRtools::crypto_get_coinmetrics()`

### ftx_coin_lending_rates.feather

Hourly resolution data showing the lending rate for a coin (or a tokenized
stock) during that hour.

Columns:

-   ticker - Coin name

-   date - Date time in yyyy-mm-dd H:M:S format

-   size - Amount of coin borrowed during the current hour

-   rate - Hourly lending rate: 1% = 0.01

`rwRtools::crypto_get_lending_rates()`

### ftx_expired_futures_1h_ohlc.feather

Hourly resolution OHLCV data for FTX expired futures.

Columns:

-   ticker - Ticker name of expired future

-   date - Date time in yyyy-mm-ddTH:M:S

-   open - Open price of the bar (first trade within time period)

-   high - Highest traded price of the bar

-   low - Lowest traded price of the bar

-   close - Last traded price of the bar

-   volume - Dollar volume traded

`rwRtools::crypto_get_expired_futures()`

### ftx_futures_ohlc_1h.feather

Hourly resolution OHLCV data for FTX current futures and perpetuals.

Columns:

-   ticker - Ticker name

-   date - Date time in yyyy-mm-ddTH:M:S

-   open - Open price of the bar (first trade within time period)

-   high - Highest traded price of the bar

-   low - Lowest traded price of the bar

-   close - Last traded price of the bar

-   volume - Dollar volume traded

`rwRtools::crypto_get_futures()`

### ftx_perps_1m_ohlc.feather

1 Minute resolution OHLCV data for FTX perpetuals. Only contains perpetuals that
are used as an underlying for leveraged tokens

Columns:

-   ticker - Ticker name

-   date - Date time in yyyy-mm-ddTH:M:S

-   open - Open price of the bar (first trade within time period)

-   high - Highest traded price of the bar

-   low - Lowest traded price of the bar

-   close - Last traded price of the bar

-   volume - Dollar volume traded

`rwRtools::crypto_get_minute_perpetuals()`

### ftx_index_ohlc_1h.feather

Hourly resolution OHLCV data for FTX Indexes. These are aggregated across
multiple venues. FTX Futures expire to them.

Columns:

-   ticker - Ticker name

-   date - Date time in yyyy-mm-ddTH:M:S

-   open - Open price of the bar (first trade within time period)

-   high - Highest traded price of the bar

-   low - Lowest traded price of the bar

-   close - Last traded price of the bar

`rwRtools::crypto_get_index()`

### ftx_perpetual_funding_rates.feather

Hourly resolution data for FTX perpetual premiums

Columns:

-   ticker - Ticker name

-   date - Date time in yyyy-mm-dd H:M:S

-   rate - Hourly funding rate 1% = 0.01

`rwRtools::crypto_get_perp_rates()`

### ftx_spot_ohlc_1h.feather

Hourly resolution spot data. (Includes tokenized stocks and leveraged tokens)

Columns:

-   ticker - Ticker name

-   date - Date time in yyyy-mm-ddTH:M:S

-   open - Open price of the bar (first trade within time period)

-   high - Highest traded price of the bar

-   low - Lowest traded price of the bar

-   close - Last traded price of the bar

-   volume - Dollar volume traded

`rwRtools::crypto_get_spot()`

### ftx_clean_spot_ohlc_1h.feather

Hourly resolution spot data (excluding tokenized stocks and leveraged tokens)

Columns:

-   ticker - Ticker name

-   date - Date time in yyyy-mm-ddTH:M:S

-   open - Open price of the bar (first trade within time period)

-   high - Highest traded price of the bar

-   low - Lowest traded price of the bar

-   close - Last traded price of the bar

-   volume - Dollar volume traded

`rwRtools::crypto_get_clean_spot()`

### ftx_token_rebalance_trades.feather

This dataset contains token rebalance data

Columns:

-   date - Date time in yyyy-mm-dd H:M:S.sss

-   side - Which side did the rebalance trade (sell or buy)

-   avg_fill_price - Average price the order was filled at

-   filled_size - The token amount of the order filled

-   sent_size - Token size of the order

-   ticker - Name of the leveraged token

-   underlying - Name of the underlying perpetual

`rwRtools::crypto_get_rebalance_trades()`

### ftx_btc_perp_bbo_sample.feather

This dataset contains a sample of top-of-book data for BTC-PERP traded on FTX between 2022-03-01 and 2022-03-05.

This is a sample dataset only and is not auto-updated. 

Columns:

-   symbol - Name of the symbol (BTC-PERP)

-   timestamp - Timestamp in yyyy-mm-dd H:M:S.ssssss UTC

-   ask_amount - Quantity on the best ask

-   ask_price - Best ask price

-   bid_price - Best bid price

-   bid_amount - Quantity on the best bid

`rwRtools::crypto_get_top_of_book_sample()`

### ftx_btc_perp_trades_sample.feather

This dataset contains a sample of trade data for BTC-PERP traded on FTX between 2022-03-01 and 2022-03-05.

This is a sample dataset only and is not auto-updated. 

Columns:

-   symbol - Name of the symbol (BTC-PERP)

-   timestamp - Timestamp in yyyy-mm-dd H:M:S.ssssss UTC

-   id - Unique exchange-provided trade ID

-   side - The aggressing side in the trade (buy = aggressive buy, sell = aggressive sell)

-   price - Traded price

-   amount - Quantity traded

`rwRtools::crypto_get_trades_sample()`
