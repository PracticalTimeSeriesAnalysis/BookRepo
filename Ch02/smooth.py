import pandas as pd

air = pd.read_csv('data/AirPassengers.csv', parse_dates = True, header = None)
air.columns = ['Date', 'Passengers']

air['Smooth.5'] = air['Passengers'].ewm(alpha=.5).mean()
air['Smooth.1'] = air['Passengers'].ewm(alpha=.1).mean()
air['Smooth.9'] = air['Passengers'].ewm(alpha=.9).mean()
