# Auto compounding script 

### Lending all available Coin balances in FTX a sub-account 

Running ```python autocompound_client.py``` will max out the lending of all of your coins. To only lend out USD you need to create a separate FTX sub-account and only fund it with USD

### Configuration 

To configure the script change the `SECRET`,  `KEY` and `SUBACCOUNT` variables to match yours  
```
if __name__ == "__main__":
    KEY = ""
    SECRET = ""
    ENDPOINT = "https://ftx.com/api"
    SUBACCOUNT = ""
```

### Running the script 

After you've configured the script, you can run it by typing `python autocompound_client.py` 

