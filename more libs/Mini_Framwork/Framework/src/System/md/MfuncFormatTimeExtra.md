		### Remarks
		Letters and numbers that you want to be transcribed literally from Format as return value should be enclosed in single
		quotes as in this example: `'Date:' MM/dd/yy 'Time:' hh:mm:ss tt`.
		
		By contrast, non-alphanumeric characters such as spaces, tabs, linefeeds (\`n), slashes, colons, commas, and other
		punctuation do not need to be enclosed in single quotes. The exception to this is the single quote character itself:
		to produce it literally, use four consecutive single quotes (''''), or just two if the quote is already inside
		an outer pair of quotes.
		
		If *Format* contains date and time elements together, they must not be intermixed. In other words, the string should
		be dividable into two halves: a time half and a date half. For example, a format string consisting of "hh yyyy mm"
		would not produce the expected result because it has a date element in between two time elements.
		
		When *Format* contains a numeric day of the month (either d or dd) followed by the full month name (MMMM), the
		genitive form of the month name is used (if the language has a genitive form).
		
		If Format contains more than 2000 characters, return will be null.
		
		Wrapper for [AutoHotkey Docs - FormatTime](http://ahkscript.org/docs/commands/FormatTime.htm){_blank}.  
		Static method.  
		
		### Returns
		Returns date formated to the specified time
		
		### Date Formats (case sensitive)  
		* **d** - Day of the month without leading zero (1 - 31)
		* **dd** - Day of the month with leading zero (01 – 31)
		* **ddd** - Abbreviated name for the day of the week (e.g. Mon) in the current user's language
		* **dddd** - Full name for the day of the week (e.g. Monday) in the current user's language
		* **M**	- Month without leading zero (1 – 12)
		* **MM** - Month with leading zero (01 – 12)
		* **MMM**	- Abbreviated month name (e.g. Jan) in the current user's language
		* **MMMM**	- Full month name (e.g. January) in the current user's language
		* **y**	- Year without century, without leading zero (0 – 99)
		* **yy** - Year without century, with leading zero (00 - 99)
		* **yyyy** - Year with century. For example: 2005
		* **gg** - Period/era string for the current user's locale (blank if none)  
		
		### Time Formats (case sensitive)  
		* **h** - Hours without leading zero; 12-hour format (1 - 12)
		* **hh** - Hours with leading zero; 12-hour format (01 – 12)
		* **H** - Hours without leading zero; 24-hour format (0 - 23)
		* **HH** - Hours with leading zero; 24-hour format (00– 23)
		* **m** - Minutes without leading zero (0 – 59)
		* **mm** - Minutes with leading zero (00 – 59)
		* **s** - Seconds without leading zero (0 – 59)
		* **ss** - Seconds with leading zero (00 – 59)
		* **t** - Single character time marker, such as A or P (depends on locale)
		* **tt** - Multi-character time marker, such as AM or PM (depends on locale)  
		
		### The following formats must be used alone; that is, with no other formats or text present in the Format parameter. These formats are not case sensitive.
		* **(Blank)** - Leave Format blank to produce the time followed by the long date. For example, in some locales it might appear as 4:55 PM Saturday, November 27, 2004
		* **Time** - Time representation for the current user's locale, such as 5:26 PM
		* **ShortDate** - Short date representation for the current user's locale, such as 02/29/04
		* **LongDate** - Long date representation for the current user's locale, such as Friday, April 23, 2004
		* **YearMonth** - Year and month format for the current user's locale, such as February, 2004
		* **YDay** - Day of the year without leading zeros (1 – 366)
		* **YDay0** - Day of the year with leading zeros (001 – 366)
		* **WDay** - Day of the week (1 – 7). Sunday is 1.
		* **YWeek** - The ISO 8601 full year and week number. For example: 200453. If the week containing January 1st has four or more days in the new year, it is considered week 1. Otherwise, it is the last week of the previous year, and the next week is week 1. Consequently, both January 4th and the first Thursday of January are always in week 1.
		
		### Additional Options  
		The following options can appear inside the YYYYMMDDHH24MISS parameter immediately after the timestamp
		(if there is no timestamp, they may be used alone). In the following example, note the lack of commas between
		the last four items:
		> OutputVar := Mfunc.FormatTime("20040228 LSys D1 D4")
		**R**: Reverse. Have the date come before the time (meaningful only when Format is blank).
		
		**Ln**: If this option is not present, the current user's locale is used to format the string. To use the system's
		locale instead, specify LSys. To use a specific locale, specify the letter L followed by a hexadecimal or decimal
		locale identifier (LCID). For information on how to construct an LCID, search
		[www.microsoft.com](http://www.microsoft.com/){_blank} for the followingphrase: Locale Identifiers
		
		**Dn**: Date options. Specify for n one of the following numbers:  
		0: Force the default options to be used. This also causes the short date to be in effect.  
		1: Use short date (meaningful only when Format is blank; not compatible with 2 and 8).  
		2: Use long date (meaningful only when Format is blank; not compatible with 1 and 8).  
		4: Use alternate calendar (if any).  
		8: Use Year-Month format (meaningful only when Format is blank; not compatible with 1 and 2).  
		0x10: Add marks for left-to-right reading order layout.  
		0x20: Add marks for right-to-left reading order layout.  
		0x80000000: Do not obey any overrides the user may have in effect for the system's default date format.  
		0x40000000: Use the system ANSI code page for string translation instead of the locale's code page.  
		
		**Tn**: Time options. Specify for n one of the following numbers:  
		0: Force the default options to be used. This also causes minutes and seconds to be shown.  
		1: Omit minutes and seconds.  
		2: Omit seconds.  
		4: Omit time marker (e.g. AM/PM).  
		8: Always use 24-hour time rather than 12-hour time.  
		12: Combination of the above two.  
		0x80000000: Do not obey any overrides the user may have in effect for the system's default time format.   
		0x40000000: Use the system ANSI code page for string translation instead of the locale's code page.  
		
		**Note**: Dn and Tn may be repeated to put more than one option into effect, such as this example:
		> OutputVar := Mfunc.FormatTime("20040228 D2 D4 T1 T8")
		
		See Also:[AutoHotkey Docs - FormatTime](http://ahkscript.org/docs/commands/FormatTime.htm){_blank}.