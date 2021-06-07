import matplotlib.pyplot as plt
import pandas as pd

unemp = pd.read_csv('data/UNRATE.csv', parse_dates=['DATE'], index_col='DATE')

# generate a data set where data is randomly missing
rand_unemp = unemp.sample(frac=0.9).sort_index() 

# generate a dataset where data is more likely to be missing when unemployment
# is high
high_unemp = unemp.query('UNRATE > 8').sample(frac=0.2)
bias_unemp = unemp.drop(high_unemp.index, axis='index')

# 
rand_unemp = rand_unemp.resample('M').mean()
bias_unemp = bias_unemp.resample('M').mean()

# Seems unnecessary.
rand_unemp['rpt'] = rand_unemp['UNRATE'].isnull()

data = {
    'amt': [99, 100, 5, 15, 11, 1200],
    'dt': ['2019-02-27', '2019-03-02', '2019-06-13', '2019-08-01', '2019-08-31', '2019-09-15',]
}

donations = pd.DataFrame(data, index=list(range(1,7)))
donations['dt'] = pd.to_datetime(donations['dt'])

identifier = ['q4q42', '4299hj', 'bbg2']
dt = [pd.Timestamp(x) for x in ['2019-1-1', '2019-4-1', '2019-7-1']]
publicity = pd.DataFrame({'identifier': identifier, 'dt': dt}, index=list(range(1,4)))

donations.set_index('dt', inplace=True)
publicity.set_index('dt', inplace=True)

# we wish to label each donation according to 
# what publicity campaign most recently preceded it.
new_index = pd.date_range('2019-01-01', periods=270)
df = donations.join(publicity.reindex(new_index, method='ffill'))
print(df)

# identify the missing data
# Hey, it's already done by resample.

idx = slice(350, 400)
unemp_idx = unemp.iloc[idx]
rand_unemp_ff = rand_unemp.iloc[idx].fillna(method='ffill')

# plot a sample graph showing the flat portions.
fig, ax = plt.subplots()
unemp_idx.plot(ax=ax, linestyle='-', marker='o', markerfacecolor='none')
rand_unemp_ff.plot(ax=ax)
rand_unemp_ff.loc[rand_unemp_ff.rpt, 'UNRATE'].plot(linestyle='none', marker='o', color='r')
ax.legend(['UNRATE', 'Missing', 'FFILL'])
