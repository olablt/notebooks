I have table of multiple symbol hourly crypto prices.

```r
returns <- universe %>%
  group_by(ticker) %>%
  filter(is_universe) %>%
  arrange(datetime) %>%
  mutate(
    hour = lubridate::hour(datetime),
    # trail_volatility = roll::roll_sd(returns, 7*24) * sqrt(365),
    # vol_adjusted_returns = returns * (0.5 / lag(trail_volatility)), # 7 day trailing vol to size things by
    # returns
    log_return = log(close/lag(close)),
    future_return = (lead(close, 1)-close)/close,
    future_log_return = log(1 + future_return),
  ) %>%
  mutate(
    future_log_return_2 = lead(future_log_return, 2),
    future_log_return_3 = lead(future_log_return, 3),
    future_log_return_4 = lead(future_log_return, 4),
    future_log_return_5 = lead(future_log_return, 5),
  )
  na.omit()

rolling_hours_since_high_72 <- purrr::possibly(
  tibbletime::rollify(
    function(x) {
      idx_of_high <- which.max(x)
      days_since_high <- length(x) - idx_of_high
      days_since_high
    },
    window = 72, na_value = NA),
  otherwise = NA
)

features <- returns %>%
  group_by(ticker) %>%
  arrange(datetime) %>%
  mutate(
    # we won't lag features here because we're using forward returns
    breakout = 71.5 - rolling_hours_since_high_72(close),  # puts this feature on a scale -9.5 to +9.5 (9.5 = high was today)
    momo = close - lag(close, 3)/close,
    # carry = funding_rate,
    # delta = -taker_buy_volume + (num_trades - taker_buy_volume)
  ) %>%
  ungroup() %>%
  na.omit()

head(features)
```

features table looks like this: 
```
ticker	datetime	open	high	low	close	volume	quote_volume	num_trades	ask	⋯	hour	log_return	future_return	future_log_return	future_log_return_2	future_log_return_3	future_log_return_4	future_log_return_5	breakout	momo
<chr>	<dttm>	<dbl>	<dbl>	<dbl>	<dbl>	<dbl>	<dbl>	<int>	<dbl>	⋯	<int>	<dbl>	<dbl>	<dbl>	<dbl>	<dbl>	<dbl>	<dbl>	<dbl>	<dbl>
BTC	2017-09-19 09:00:00	3932.02	3982.23	3921.01	3940.20	27.52615	108812.451	236	11.00212	⋯	9	0.0020781947	1.517689e-02	1.506288e-02	1.183443e-02	-0.021711695	0.004156743	0.0047122081	51.5	3939.1759
ETH	2017-09-19 09:00:00	283.00	289.87	282.13	289.87	32.53512	9275.422	47	20.54452	⋯	9	0.0205991634	1.000448e-03	9.999484e-04	6.920176e-05	-0.003570133	-0.002921030	0.0098072278	51.5	288.8538
BTC	2017-09-19 10:00:00	3940.20	4000.00	3923.15	4000.00	39.79384	157479.971	247	12.83464	⋯	10	0.0150628777	-7.747500e-03	-7.777668e-03	-2.171170e-02	0.004156743	0.004712208	-0.0007846690	50.5	3999.0037
ETH	2017-09-19 10:00:00	286.07	290.99	283.52	290.16	73.56736	21212.844	45	51.81581	⋯	10	0.0009999484	-3.997794e-03	-4.005807e-03	-3.570133e-03	-0.002921030	0.009807228	-0.0033852670	50.5	289.1536
BTC	2017-09-19 11:00:00	3990.13	4032.02	3969.00	3969.01	39.53009	158335.834	287	14.43713	⋯	11	-0.0077776678	1.190473e-02	1.183443e-02	4.156743e-03	0.004712208	-0.000784669	-0.0004771577	49.5	3968.0100
ETH	2017-09-19 11:00:00	289.01	294.99	289.00	289.00	123.77576	36010.108	48	14.73985	⋯	11	-0.0040058069	6.920415e-05	6.920176e-05	-2.921030e-03	0.009807228	-0.003385267	-0.0034662080	49.5	287.9965
```


I want to analyze the data to find the best time to buy each symbol (time to sell is not relevand at the moment).
For that I want to calculate and analyze the following features:
- breakout: the number of hours since the last high price in the last 72 hours
- momo: momentum of the price change in the last 3 hours
- delta: the difference between the ask and bid volumes

For each feature I want to calculate the following statistics:
- how the feature is related to the future price change - future_return and future_log_return
- darw scatterplots and timeseries plots of cumulative next day returns to the feature.

Please provide R code for each feature analysis  where we can see the best time to buy each symbol based on the analysis.
