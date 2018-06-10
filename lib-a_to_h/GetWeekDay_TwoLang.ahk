; ===================================================================================
; AHK Version ...: AHK_L 1.1.14.03 x64 Unicode
; Win Version ...: Windows 7 Professional x64 SP1
; Description ...: Get the weekday on any given date
; Modified ......: 2014.04.15-0925
; Author ........: jNizM
; Licence .......: WTFPL (http://www.wtfpl.net/txt/copying/)
; Source ........: https://github.com/jNizM/AutoHotkey_Scripts/blob/master/Functions/Others/GetWeekday.ahk
;Modified .......: 2018.04.01. by Ixiko - two languages two formats, you have to only use your date English format 01-03-1990
;					or german format 03.01.1990 - you can use default Delimiter or choose your own
; ===================================================================================


; GLOBAL SETTINGS ===================================================================

#NoEnv
#SingleInstance Force

; SCRIPT ============================================================================

MsgBox, % GetWeekday("1-1-1990", "en", "", "en") ;  --> Monday
MsgBox, % GetWeekday("15.4.2014", "ge", "","de") ;  --> Dienstag
MsgBox, % GetWeekday("15.4.2014", "ge", "","en") ;  --> ThuesDay

ExitApp

; FUNCTIONS =========================================================================

GetWeekday(date, format, DelimitChar:="", outlang:="en" ) {

	WeekDay:= Object()
	WeekDay.En:= Object(Weekday)
	WeekDay.Ge= Object(Weekday)

	WeekDay.En:= ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
	WeekDay.Ge:= ["Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Sonnabend"]

	;append or change the following for your language
	If (format="en") {

			If (DelimitChar="") {
					DelimitChar:= "-"
			}

			StringSplit, split, date, %DelimitChar%
			d:= split2, m:= split1, y:= split3

    } else if (format="ge") {

			If (DelimitChar="") {
					DelimitChar:= "`."
			}

			StringSplit, split, date, %DelimitChar%
			d:= split1, m:= split2, y:= split3

	}

    if (m < 3) {
        m += 12
        y -= 1
    }

    wd:= mod(d + (2 * m) + floor(6 * (m + 1) / 10) + y + floor(y / 4) - floor(y / 100) + floor(y / 400) + 1, 7) + 1
	ListVars
	MsgBox, %wd%
	return WeekDay%outlang%[wd]
}

