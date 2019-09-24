require(lubridate)

## Creating a timestamp with a time zone
eventTime <- as.POSIXct("2018-02-06 15:41:23.102")

## > eventTime
## [1] "2018-02-06 15:41:23 EST"

eventTime1 <- as.POSIXct("2018-02-06 15:41:23.102", tz="EST")
## but
eventTime2 <- as.POSIXct("2018-02-06 15:41:23.102", tz="EE")
eventTime3 <- as.POSIXct("2018-02-06 15:41:23.102")

attr(eventTime1,"tzone")
attr(eventTime2,"tzone")
attr(eventTime3,"tzone")


format(eventTime, tz="GMT",usetz=TRUE)
format(eventTime, tz="America/Los_Angeles",usetz=TRUE)

## > attr(eventTime,"tzone")
## [1] "EST"
## > attr(eventTime2,"tzone")
## [1] "EE"
## >

## Converting time from one time zone to another
## Need to remove time zone via passing back to a string
## Note it's ugly but you can easily wrap it in a function and drop it in your .Rprofile
eventTime1Converted <- as.POSIXct(format(eventTime1, tz = "GMT", usetz = TRUE), tz = "GMT")

## or
eventTime1Copy <- eventTime1
attributes(eventTime1Copy)$tzone <- "GMT"
## eventTime1Copy == eventTime1
## [1] TRUE


## ## What is going on here?
## > eventTime1Converted <= eventTime1
## [1] TRUE
## > eventTime1Converted >= eventTime1
## [1] FALSE
## > 

## > eventTime1 == eventTime1Converted
## [1] FALSE
## depends on == implementation

## > as.numeric(eventTime1)
## [1] 1517949683
## > as.numeric(eventTime1Copy)
## [1] 1517949683
## > as.numeric(eventTime1Copy) == as.numeric(eventTime1)
## [1] TRUE
## > 

## Calculating time difference between time zones
eventTime1 - eventTime
## > eventTime1 - eventTime
## Time difference of 0 secs

eventTime1 - with_tz(eventTime1, "GMT")
## > eventTime1 - with_tz(eventTime1, "GMT")
## Time difference of 0 secs

t1 <- as.POSIXct("2018-02-06 15:41:23.102", tz="EST") 
t2 <- as.POSIXct("2018-02-06 15:41:23.102", tz="GMT")

difftime(t1, t2, units = "hours")
difftime(t1, t2, units = "days")


## Setting up your system, consider this for your R profile
Sys.setenv(TZ="GMT")

## A little lubridate


## Converting time from one time zone to another while keeping the underlying moment in time the same
with_tz(eventTime1, "GMT")
##  with_tz(eventTime1, "GMT") == eventTime1
## [1] TRUE
## >

## You can also keep the 'label' on the time and simply swap the time zone
force_tz(eventTime1, "GMT")
## > force_tz(eventTime1, "GMT") == eventTime1
## [1] FALSE (of course no)


## R:

## Base R is fairly savvy in its handling of time related data, and for this reason you will generally get time with a timestamp when you are generating time from the system information. For example, Sys.time() will return a POSIXlt with a timezone.

## “There are two POSIXt types, POSIXct and POSIXlt. "ct" can stand for calendar time, it stores the number of seconds since the origin. "lt", or local time, keeps the date as a list of time attributes (such as "hour" and "mon").” If you are working with data that relates to human behavior, you likely want to use the “lt” variant because you will care about human related time labels, such as day of the week, but if you are working with scientific data where such labels are unlikely to be important, the POSIXct variant is more lightweight.

## Note that operating systems are not built into R but rather rely on the underlying time zones stored and used by the operating system. For that reason, the exact abbreviations for time zones, how far back in time they go, and their underlying representation will depend on your operating system. You can see your system’s timezone with Sys.timezone(), or you can see and set this variable with the TZ environmental variable. You can hence always have the preferred timezone by running a command to set Sys.setenv() or the Renviron.site variable. For this reason, the rules implementing time zones and daylight savings are done by your operating system, which means a change or upgrade to your operating system can result in display changes to your time related variables in some cases. 
