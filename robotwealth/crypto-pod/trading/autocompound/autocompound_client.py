import time
import datetime
import hmac
from requests import Request, Session
import csv
from math import ceil

class FTXClient():
    def __init__(self, endpoint="https://ftx.com/api", key=None, secret=None, subaccount=None):
        self.session = Session()
        self.endpoint = endpoint
        self.key = key
        self.secret = secret
        self.subaccount = subaccount   
        self.req = 0
        self.t1 = time.time()
        self.t2 = time.time()

    def _get(self, path, params = None):
        
        return self._request('GET', path, params=params)

    def _post(self, path, params = None):
        
        return self._request('POST', path, json=params)

    def _delete(self, path, params = None):
        
        return self._request('DELETE', path, json=params)

    def _request(self, method, path, **kwargs):
        request = Request(method, f'{self.endpoint}{path}', **kwargs)
        self._sign_request(request)
        response = self.session.send(request.prepare())

        return self._process_response(response)

    def _process_response(self, response):
        try:
            data = response.json()
        except ValueError:
            response.raise_for_status()
            raise
        else:
            if not data['success']:
                raise Exception(data['error'])
            
        return data['result']
        
    def _sign_request(self, request):
        ts = int(time.time() * 1000)
        prepared = request.prepare()
        signature_payload = f'{ts}{prepared.method}{prepared.path_url}'.encode()
        
        # if we have additional json passed with the request, add it to the signature payload
        if prepared.body:
            signature_payload += prepared.body
            
        signature = hmac.new(self.secret.encode(), signature_payload, 'sha256').hexdigest()

        request.headers['FTX-KEY'] = self.key
        request.headers['FTX-SIGN'] = signature
        request.headers['FTX-TS'] = str(ts)
        if self.subaccount:
            request.headers['FTX-SUBACCOUNT'] = self.subaccount
        
        return request
    
    def get_current_lending(self):
        current_lending = self._get('/spot_margin/lending_info')
        
        return current_lending

    def max_out_lending(self):
        lending_info = self.get_current_lending()
        
        # if any capital free, max out lending
        responses = []
        for coin in lending_info:
            print(coin)
            print("Lendable: ", coin['lendable'] - coin['offered'], coin['coin'])
            #if(coin['lendable'] - coin['offered'] > 0.00000001):
            offer = {
                "coin": coin['coin'],
                "size": float(int(coin['lendable'] * 1e8))/1e8,  # truncate to 8 decimals otherwise can get rejected on too big size
                "rate": 1e-6
            }
            response = self._post('/spot_margin/offers', params = offer)
            responses.append(response)
        
        return responses        

if __name__ == "__main__":
    KEY = ""
    SECRET = ""
    ENDPOINT = "https://ftx.com/api"
    SUBACCOUNT = ""

    ftx = FTXClient(key = KEY, secret = SECRET, subaccount = SUBACCOUNT)
    ftx.max_out_lending()