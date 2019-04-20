;https://autohotkey.com/boards/viewtopic.php?t=1035

#include %A_ScriptDir%\..\lib-i_to_z\RegEx.ahk

haystack =
(
;autohotkey,''
;'autohotkey,'
;,autohotkey,,,;
)

MsgBox % "Haystack = `n" haystack
. "`n`nRegEx_Trim right:`n" 		RegEx_Trim(haystack, n:= "[,;']+", "r")
. "`n`nRegEx_Trim left:`n" 		RegEx_Trim(haystack, n, "L")
. "`n`nRegEx_Trim:`n"				RegEx_Trim(haystack, n)

;----------------------------------------------------------------------
haystack = auto,hot;key
out := "Haystack = `n" haystack "`n`n" 
out .= "RegEx_Split:`n`n"
out .= "String:`n" RegEx_Split(haystack, "[,;]", " || ") "`n`nArray Object:`n"
for k, v in RegEx_Split(haystack, "[,;]")
	out .= "obj "A_Index " = " v "`n"
MsgBox,262144,, % Out
;----------------------------------------------------------------------
t1 =
(
23_9_64_28
12_9_56_6
8_78_73_85
4_76_56_45
)
t2 = DMX74_BAT23_ANT23_XL8
MsgBox % "Haystack = `n" t1 
. "`n`nRegular Sort no param:`n"					                	Regex_Sort(t1)
. "`n`nSort by 1st number:`n"					                       		Regex_Sort(t1, "\d+")
. "`n`nSort by subpat# 2 - 2nd No.:`n"			               		Regex_Sort(t1, "(\d+)_(\d+)_(\d+)_(\d+)", 2)
. "`n`nSort by subpat# 3 - 3rd No. descending order:`n"	Regex_Sort(t1, "(\d+)_(\d+)_(\d+)_(\d+)", 3, 1)
. "`n`ncustom delim by 1st digit:`n"			                		Regex_Sort(t2, "\d",,, "_")
. "`n`ncustom delim by 2nd letter:`n"			                		Regex_Sort(t2, "\w\K\w",,, "_")
. "`n`ncustom delim by 1st No. descending:`n"	           		Regex_Sort(t2, "\d+",, "r", "_")
;----------------------------------------------------------------------
haystack = auto,hot;key
out := "Haystack = `n" haystack
out .= "`n`nRegEx_Grep:`n"
out .= "String:`n" RegEx_Grep(haystack, "\w(\w)\w+", 1," / ") "`n`nArray Object:`n"
for k, v in RegEx_Grep(haystack, "\w(\w)\w+", 1)
	out .= "obj "A_Index " = " v "`n"
MsgBox,262144,, % Out
;----------------------------------------------------------------------
HayStack = one [ two ] three [ four ] five [ six ]
out := haystack "`n`n"
out .= "RegEx_Between:`n`n"
out .= "String:`n" RegEx_Between(HayStack, "\[", "\]", ",") "`n`nArray Object:`n"
for k, v in RegEx_Between(HayStack, "\[", "\]")
	out .= "obj "A_Index " = " v "`n"
MsgBox,262144,, % Out

haystack =
(join`n
new hot key
brand new auto key
brand new hot auto key
frog1dog2cat
)

MsgBox % RegEx_Grep(haystack,".*hot.*",," / ")




return