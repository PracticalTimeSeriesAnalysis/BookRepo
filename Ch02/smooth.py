import pandas as pd

air = pd.read_csv('data/AirPassengers.csv', parse_dates = True, header = None)
air.columns = ['Date', 'Passengers']

air['Smooth.5'] = pd.ewma(air, alpha = .5).Passengers
air['Smooth.1'] = pd.ewma(air, alpha = .1).Passengers
air['Smooth.9'] = pd.ewma(air, alpha = .9).Passengers
