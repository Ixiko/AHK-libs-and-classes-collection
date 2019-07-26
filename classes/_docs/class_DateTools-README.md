### DateTools
Builds a date object, complete with methods for manipulating dates and times, via a programmer-friendly interface. Dates are automatically parsed from a variety of formats. When parsing dates, any missing date information will derived from the information provided or will be gathered from A_Now.

Note, this set of functions may not behave properly for dates before the 1600's.

See also: [the better write up](https://github.com/RoyOMiller/DateTools/wiki/DateTools-v0.1)

### Features

* Date Math 
	* Provides full control over adding or subtracting all units of time from seconds to centuries.
		* With months or larger units of time, DateTools automatically deals with leapyear and last day of month paradoxes by selecting the actual last day of the month rather than moving into the next month. 
			* For example: 
			* January 31 plus 1 month will equal Feburary 28 or Feburary 29 if it's a leap year
			* January 31 plus 2 months will equal March 31
			* January 31 plus 3 months will equal April 30
	* Calculate the amount of time between two dates
* Compairson functions that automatically evaluate a dates in a given format.
* Reads most date formats and standardizes them into the autohotkey standard yyyyMMddHHmmss format.
 

### Required

	Authotkey v1.1.22 +

### Install and Use: 

	#Include DateTools.ahk
	
	Today := New date
	Today.Format := "ddd, yyyy MM dd"
	MsgBox, % "Today is '" . Today.Format . "'"
	
	MsgBox, % "Four Score and Seven Years ago was '" . Today.Add({Score:-4, Years:-7}) . "'"
	
	DateTools.SyntaxExamples()


### Syntax

Full description of the syntax is in the comments of the Class Date. And more complex examples are availble in Class Datetools.SyntaxExamples
