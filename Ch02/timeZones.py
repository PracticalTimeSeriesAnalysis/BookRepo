import datetime
import pytz

datetime.datetime.utcnow()
# datetime.datetime.utcnow()
# datetime.datetime(2018, 5, 31, 14, 49, 43, 187680)

datetime.datetime.now()
# >>> >>> datetime.datetime.now()
# datetime.datetime(2018, 5, 31, 10, 49, 59, 984947)
# as we can see, my computer does not return UTC even though there is no time zone attached

datetime.datetime.now(datetime.timezone.utc)
# >>> datetime.datetime.now(datetime.timezone.utc)
# datetime.datetime(2018, 5, 31, 14, 51, 35, 601355, tzinfo=datetime.timezone.utc)


western = pytz.timezone('US/Pacific')
western.zone
# >>> eastern.zone
# 'US/Pacific'

## the API supports two ways of building a time zone aware time, either via 'localize' or to convert a timezone from one locale to another
# here we localize
loc_dt = western.localize(datetime.datetime(2018, 5, 15, 12, 34, 0))
# datetime.datetime(2018, 5, 15, 12, 34, tzinfo=<DstTzInfo 'US/Pacific' PDT-1 day, 17:00:00 DST>)
# >>>

london_tz = pytz.timezone('Europe/London')
london_dt = loc_dt.astimezone(london_tz)
# >>> london_dt
# datetime.datetime(2018, 5, 15, 20, 34, tzinfo=<DstTzInfo 'Europe/London' BST+1:00:00 DST>)
f = '%Y-%m-%d %H:%M:%S %Z%z'
datetime.datetime(2018, 5, 12, 12, 15, 0, tzinfo = london_tz).strftime(f)
## '2018-05-12 12:15:00 LMT-0001'
## as highlighted in the pytz documentation using the tzinfo of the datetime.datetime initializer does not always lead to the desired outcome
## such as with the London
## according to the pytz documentation, this method does lead to the desired results in time zones without daylight savings

# generally you want to store data in UTC and convert only when generating human readable output
# you can also do date arithmetic with time zones
event1 = datetime.datetime(2018, 5, 12, 12, 15, 0, tzinfo = london_tz)
event2 = datetime.datetime(2018, 5, 13, 9, 15, 0, tzinfo = western)
event2 - event1
## this will yield the wrong time delta because the time zones haven't been labelled properly


event1 = london_tz.localize( datetime.datetime(2018, 5, 12, 12, 15, 0))
event2 = western.localize(datetime.datetime(2018, 5, 13, 9, 15, 0))
event2 - event1



event1 = london_tz.localize((datetime.datetime(2018, 5, 12, 12, 15, 0))).astimezone(datetime.timezone.utc)
event2 = western.localize(datetime.datetime(2018, 5, 13, 9, 15, 0)).astimezone(datetime.timezone.utc)
event2 - event1

## note that in the event you are working on dates for arithmetic that could corss daylight savings time boundaries
## you also need to apply the normalize function for your time zone
event1 = london_tz.localize( datetime.datetime(2018, 5, 12, 12, 15, 0))
event2 = western.localize(datetime.datetime(2018, 5, 13, 9, 15, 0))

## have a look at pytz.common_timezones
pytz.common_timezones
## or country specific
pytz.country_timezones('RU')
# >>> pytz.country_timezones('RU')
# ['Europe/Kaliningrad', 'Europe/Moscow', 'Europe/Simferopol', 'Europe/Volgograd', 'Europe/Kirov', 'Europe/Astrakhan', 'Europe/Saratov', 'Europe/Ulyanovsk', 'Europe/Samara', 'Asia/Yekaterinburg', 'Asia/Omsk', 'Asia/Novosibirsk', 'Asia/Barnaul', 'Asia/Tomsk', 'Asia/Novokuznetsk', 'Asia/Krasnoyarsk', 'Asia/Irkutsk', 'Asia/Chita', 'Asia/Yakutsk', 'Asia/Khandyga', 'Asia/Vladivostok', 'Asia/Ust-Nera', 'Asia/Magadan', 'Asia/Sakhalin', 'Asia/Srednekolymsk', 'Asia/Kamchatka', 'Asia/Anadyr']
# >>>
# >>> pytz.country_timezones('fr')
# ['Europe/Paris']
# >>>


## time zones
ambig_time = western.localize(datetime.datetime(2002, 10, 27, 1, 30, 00)).astimezone(datetime.timezone.utc)
ambig_time_earlier = ambig_time - datetime.timedelta(hours=1)
ambig_time_later = ambig_time + datetime.timedelta(hours=1)
ambig_time_earlier.astimezone(western)
ambig_time.astimezone(western)
ambig_time_later.astimezone(western)
# >>> >>> >>> datetime.datetime(2002, 10, 27, 1, 30, tzinfo=<DstTzInfo 'US/Pacific' PDT-1 day, 17:00:00 DST>)
# >>> datetime.datetime(2002, 10, 27, 1, 30, tzinfo=<DstTzInfo 'US/Pacific' PST-1 day, 16:00:00 STD>)
# >>> datetime.datetime(2002, 10, 27, 2, 30, tzinfo=<DstTzInfo 'US/Pacific' PST-1 day, 16:00:00 STD>)
# >>> >>>
# notice that the last two timestamps are identical, no good!

## in this case you need to use is_dst to indicate whether daylight savings is in effect
ambig_time = western.localize(datetime.datetime(2002, 10, 27, 1, 30, 00), is_dst = True).astimezone(datetime.timezone.utc)
ambig_time_earlier = ambig_time - datetime.timedelta(hours=1)
ambig_time_later = ambig_time + datetime.timedelta(hours=1)
ambig_time_earlier.astimezone(western)
ambig_time.astimezone(western)
ambig_time_later.astimezone(western)
# >> >>> datetime.datetime(2002, 10, 27, 0, 30, tzinfo=<DstTzInfo 'US/Pacific' PDT-1 day, 17:00:00 DST>)
# >>> datetime.datetime(2002, 10, 27, 1, 30, tzinfo=<DstTzInfo 'US/Pacific' PDT-1 day, 17:00:00 DST>)
# >>> datetime.datetime(2002, 10, 27, 1, 30, tzinfo=<DstTzInfo 'US/Pacific' PST-1 day, 16:00:00 STD>)


## notice that now we don't have the same time happening twice.
## it may appear that way until you check the offset from UTC
loc_dt.strftime(f)
