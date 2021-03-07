; Title:   	getDateYYMMDD_fromString()
; Link:   	autohotkey.com/boards/viewtopic.php?f=6&t=69320&hilit=Date+regex
; Author:	Rocks
; Date:   	28.10.2019
; for:     	AHK_L

; This is a function I made to help me find the YYMMDD formatted date from any date resembling input.
; I need that for my work because we receive many client's files where they communicate dates to us that are never in the correct format. Hence this is why I came up with something to help me discover my desired format from their input value.
;
; It's surely not perfect and I'd appreciate if you have ideas to make it more evrsatile and reliable at the same time.
; Please note, that I do a bit of logical guessing to create the missing parts in the input string.
; For example, when the string input is something like january 31 the regexmatch pattern will not find a year, but I will assume that the date relates to A_YEAR (the current year).

/*

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, Force ; Prevent double execution of this script

; Type anything ressembling a date string like mar 15 (should return 190315)
; it will try to match a specific case to output the YYMMDD date from it:
MsgBox % getDateYYMMDD_fromString("mar 15") "`ninput was: mar 15"
MsgBox % getDateYYMMDD_fromString("31 ja") "`ninput was: 31 ja"
MsgBox % getDateYYMMDD_fromString("30 jan") "`ninput was: 30 jan"
MsgBox % getDateYYMMDD_fromString("30") "`ninput was: 30"
MsgBox % getDateYYMMDD_fromString("jul 4") "`ninput was: jul 4"
MsgBox % getDateYYMMDD_fromString("20200131") "`ninput was: 20200131"
MsgBox % getDateYYMMDD_fromString("201231") "`ninput was: 201231"
return

*/



;--------------------------------------------------------------------------------
getDateYYMMDD_fromString(string) {
;--------------------------------------------------------------------------------
	static regex, initialized

	if (!initialized) {
		regex:=[] ; create object to store the following reg expressions
		initialized := true

		; General use regex patterns
		YYYY:= "(?<YEAR>201[6-9]|202[0-5])" 			; Ex: 2016...2019 | 2020...2025
		YY:=   "(?<YEAR>1[6-9]|2[0,5])" 				; Ex: 16...19 | 20...25
		MONTH:="(?<MONTH>[a-z]{2,9})" 	    			; Ex: Decembre
		MM:=   "(?<MONTH>0[1-9]|1[0-2])"				; Ex: 01 02 03 04 05 06 07 08 09 | 10 11 12
		DD:=   "(?<DAY>0[1-9]|1[0-9]|2[0-9]|3[0,1])"	; Ex: 01 à 31
		D:=	   "(?<DAY>[1-9]{1})"						; Ex: 1 à 9 sans le 0 du début

		regex["date","YYYYMMDD"]:=		YYYY MM DD		; 20191201
		regex["date","YYYYMMD"]:=		YYYY MM D		; 2019121
		regex["date","YYMMDD"]:=		YY MM DD		; 191201
		regex["date","YYMMD"]:=			YY MM D			; 19121
		regex["date","MMDD"]:=			MM DD			; 1201
		regex["date","MMD"]:=			MM D			; 121
		regex["date","DD"]:=			DD				; 01
		regex["date","D"]:=				D				; 1

		regex["date","YYYYMONTHDD"]:=	YYYY MONTH DD	; 2019 Decembre 01
		regex["date","YYYYMONTHD"]:=	YYYY MONTH D	; 2019 Decembre 1
		regex["date","YYMONTHDD"]:=		YY MONTH DD		; 19 Decembre 01
		regex["date","YYMONTHD"]:=		YY MONTH D		; 19 Decembre 1
		regex["date","MONTHDD"]:=		MONTH DD		; Decembre 01
		regex["date","MONTHD"]:=		MONTH D			; Decembre 1
		regex["date","WORD_MONTH"]:=	MONTH			; Decembre

		regex["date","DDMONTHYYYY"]:=	DD MONTH YYYY	; 01 Decembre 2019
		regex["date","DMONTHYYYY"]:=	D MONTH YYYY	; 1 Decembre 2019
		regex["date","DDMONTHYY"]:=		DD MONTH YY		; 01 Decembre 19
		regex["date","DDMONTHYY"]:=		D MONTH YY		; 1 Decembre 19
		regex["date","DDMONTH"]:=		DD MONTH 		; 01 Decembre
		regex["date","DMONTH"]:=		D MONTH 		; 1 Decembre

		regex["date","DDMMYYYY"]:=		DD MM YYYY		; 01122019
		regex["date","DMMYYYY"]:=		D MM YYYY		; 1122019
		regex["date","DDMMYY"]:=		DD MM YY		; 011219
		regex["date","DMMYY"]:=			D MM YY			; 11219
	}

	; fail-safe reformat input string
	string := RegExReplace(string, "[^a-zA-Z0-9]") ; remove anything that's not a letter or digit
	string := StrUnmark(string) ; remove word accents (décembre -> decembre)

	; loop date patterns in the regex object
	For pattern, needle in regex.date {
		if (RegExMatch(string, "i)^" needle "$", matched)) {
			year := matchedYEAR
		  , month := matchedMONTH
		  , day := matchedDAY
		  , matchedPattern := pattern
			break
		}
	}

	; validate found values and reformat if needed
	YY := year ? ((StrLen(year) = 2) ? year : SubStr(year,3,2)) : SubStr(A_YEAR,3,2)
	MM := month ? (RegExMatch(month, "i)"regex.date.WORD_MONTH) ? dateMonthStringToMM(month) : month) : "NULL"
	DD := day ? ((StrLen(day) = 2) ? day : "0"day) : "NULL"

	return YY . MM . DD
}

;--------------------------------------------------------------------------------
dateMonthStringToMM(monthString) {
;--------------------------------------------------------------------------------
	if (RegExMatch(monthString, "i)^ja"))
		MM := 01
	else if (RegExMatch(monthString, "i)^fe"))
		MM := 02
	else if (RegExMatch(monthString, "i)^mar"))
		MM := 03
	else if (RegExMatch(monthString, "i)^av|ap"))
		MM := 04
	else if (RegExMatch(monthString, "i)^mai|may"))
		MM := 05
	else if (RegExMatch(monthString, "i)^juin|jun"))
		MM := 06
	else if (RegExMatch(monthString, "i)^juil|jul"))
		MM := 07
	else if (RegExMatch(monthString, "i)^ao|au"))
		MM := 08
	else if (RegExMatch(monthString, "i)^se"))
		MM := 09
	else if (RegExMatch(monthString, "i)^oc"))
		MM := 10
	else if (RegExMatch(monthString, "i)^no"))
		MM := 11
	else if (RegExMatch(monthString, "i)^de"))
		MM := 12
	return MM
}

;--------------------------------------------------------------------------------
dateMMtoMonthString(MM) {
;--------------------------------------------------------------------------------
	Switch MM {
		case 01:month:="Janvier"
		case 02:month:="Février"
		case 03:month:="Mars"
		case 04:month:="Avril"
		case 05:month:="Mai"
		case 06:month:="Juin"
		case 07:month:="Juillet"
		case 08:month:="Août"
		case 09:month:="Septembre"
		case 10:month:="Octobre"
		case 11:month:="Novembre"
		case 12:month:="Décembre"
	}
	return month
}

;--------------------------------------------------------------------------------
StrUnmark(string) {
;--------------------------------------------------------------------------------
; Function written by - Lexikos
; Removes marks (accents) from letters.  Requires Windows Vista or later.
	len :=	DllCall("Normaliz.dll\NormalizeString", "int", 2
				  , "wstr", string, "int", StrLen(string)
				  , "ptr", 0, "int", 0)	; Get *estimated* required buffer size.
	Loop {
		VarSetCapacity(buf, len * 2)
		len :=	DllCall("Normaliz.dll\NormalizeString", "int", 2
					  , "wstr", string, "int", StrLen(string)
					  , "ptr", &buf, "int", len)
		if	len >= 0
			break
		if	(A_LastError != 122)	; ERROR_INSUFFICIENT_BUFFER
			return
		len *= -1	; This is the new estimate.
	}
	; Remove combining marks and return result.
	return	RegExReplace(StrGet(&buf, len, "UTF-16"), "\pM")
}