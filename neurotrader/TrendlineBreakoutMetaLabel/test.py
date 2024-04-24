
import pandas as pd

high = pd.Series([2, 4, 7, 11, 16, 22, 29])
result  = high - high.shift(1)
print(result)
