#ifndef TIME_HEADER
#define TIME_HEADER

#include "mclib.h"
#include "stdlib.h"

typedef uint64_t time_t;

MCLIB_IMPORT(time_t, msvcrt, time, (time_t*));

struct tm {
   int tm_sec;         /* seconds,  range 0 to 59          */
   int tm_min;         /* minutes, range 0 to 59           */
   int tm_hour;        /* hours, range 0 to 23             */
   int tm_mday;        /* day of the month, range 1 to 31  */
   int tm_mon;         /* month, range 0 to 11             */
   int tm_year;        /* The number of years since 1900   */
   int tm_wday;        /* day of the week, range 0 to 6    */
   int tm_yday;        /* day in the year, range 0 to 365  */
   int tm_isdst;       /* daylight saving time             */	
};

MCLIB_IMPORT(int, msvcrt, _localtime32_s, (struct tm*, const time_t*));

struct tm* localtime_r(const time_t* Time, struct tm* Output) {
	_localtime32_s(Output, Time);

	return Output;
}

struct tm* localtime(const time_t* Time) {
	struct tm* Result = malloc(sizeof(struct tm));

	return localtime_r(Time, Result);
}

MCLIB_IMPORT(size_t, msvcrt, strftime, (char*, size_t, const char*, const struct tm*));

#endif // TIME_HEADER