; Title:   	Invers FormatTime: TimeStamp(Date,Format)
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=87146
; Author:	Rohwedder
; Date:   	20 Feb 2021, 06:38
; for:     	AHK_L

/*
    ; EnvAdd and EnvSub require YYYYMMDDHH24MISS stamps.
    ; I found it inconvenient and wrote this function TimeStamp(Date, Format).
    ; It calculates the necessary stamp from given Date and Format and completes missing values with today's noon.
    ; It works with numeric formats, complete (with leading zeros) or separated e.g. with dots
    ; It is not as powerful as InvFormattime from philz, but easier to use.


    MsgBox,% TimeStamp("01022021","ddMMyyyy")
    ; 20210201120000 (complete formats with leading zeros)
    MsgBox,% TimeStamp("1.2.21","d.M.yy")
    ; 20210201120000 (dot separated formats)

    Minutes := TimeStamp("12:17","H:mm")
    Minutes -= TimeStamp("3:06"), Minutes ;EnvSub
    MsgBox,% Minutes ;551 (minutes between 3:06 and 12:17)

    Date := TimeStamp("11.9.01","d.M.yy")
    Date += 1234, days ;EnvAdd
    FormatTime, Date,% Date, d.M.yy
    MsgBox,% Date ;27.1.05 (= 11.9.01 + 1234 days)
    Return

*/


TimeStamp(Date, Format:=""){
    Static Noon := A_Year A_MM A_DD 120000, Down := 7060504030201, FOld
    FormatTime, D,% 8 Down,% Format?FOld:=Trim(Format):FOld
    For all, V in ["Date","D"], Date := Trim(Date) ; add missing leading zeros
		%V% := RegExReplace(%V%, "(?<=^|\D)(\d)(?=\D|$)", "0$1")
    Loop, Parse,% (0 Down, N := Noon) ; today's noon
        IF A_LoopField And Pos := InStr(D, A_LoopField)
            N := SubStr(N,1,A_Index-2) SubStr(Date,Pos-1,2) SubStr(N,A_Index+1)
    Return, N ; digits >0 from Down in D stand for Date's values
}