; Title:		StrSplitDlm() - Separator Indicator
; Link:   		https://www.autohotkey.com/boards/viewtopic.php?f=10&t=104590
; Author: 	Bobo
; Date:		May 22, 2022
; for:     	AHK_L

; In the AHK help for Loop, Parse ... CSV there is an :arrow: example,
; which should determine the separator type (comma, semi-colon,...) of a CSV dataset.
; I can't think of a compelling reason why you would want to know this afterwards for separators used in StrSplit(),
; but never mind...

/*
colors := "red,green|blue;yellow|cyan,magenta"
array := StrSplit(colors,[",","|",";"])
MsgBox % StrSplitDlm(array,colors)
*/

StrSplitDlm(array,str) {
   Loop % array.Count()
      str := StrReplace(str,array[A_Index],"")
   Sort, str, U D|
   Return str
   }