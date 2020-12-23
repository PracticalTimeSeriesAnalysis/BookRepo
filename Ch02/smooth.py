import pandas as pd

air = pd.read_csv('data/AirPassengers.csv', parse_dates = True, header = None)
air.columns = ['Date', 'Passengers']

## thanks to Mark Wilson for this code correction
air['Smooth.5'] = air.ewm(alpha=0.5).mean().Passengers
air['Smooth.1'] = air.ewm(alpha=0.1,).mean().Passengers
air['Smooth.9'] = air.ewm(alpha=0.9,).mean().Passengers
