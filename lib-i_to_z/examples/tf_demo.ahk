; #Include tf.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

TestFile= ; create variable
(join`r`n
1 Hi this
2 a test variable
3 to demonstrate
4 how to 
5 use this
6 new version
7 of TF.AHK
)
FileDelete, TestFile.txt
FileAppend, %TestFile%, TestFile.txt ; create file
F=TestFile.txt ; just a shorthand code for TextFile.txt, so below when
; using F we are still passing on a TextFile, not a variable

;pass on file, read lines 5 to end of file:
MsgBox % "From File 1:`n" TF_ReadLines("TestFile.txt",5) ; same as before
MsgBox % "From File 2:`n" TF_ReadLines(F,5)              ; same as before

;pass on variable, read lines 1 to 5
MsgBox % "From Variable 1:`n" TF_ReadLines(TestFile,"1-5")     
MsgBox % "From Variable 2:`n" TF_ReadLines("Hi`nthis`nis`na`ntest`nvariable`nfor`ntesting",1,3) ; pass on string

;Examples using TF(): (it will save you a FileRead if you want to work with Variables

TF("TestFile.txt") ; read file, create globar var t
t:=TF_ReadLines(t,5) ; pass on global var t created by TF(), read lines 5 to end of file, asign result to t 
MsgBox % "TF(), example 1:`n" t

TF("TestFile.txt", "MyVar") ; read file, create globar var MyVar
MyVar:=TF_ReadLines(MyVar,5) ; pass on global var MyVar created by TF(), read lines 5 to end of file, asign result to MyVar
MsgBox % "TF(), example 2:`n" MyVar

; Note how we can use TF() here
t:=TF_ReadLines(TF("TestFile.txt"),5) ; pass on global var t created by TF(), read lines 5 to end of file, asign result to t 
MsgBox % "TF(), example 3:`n" t

MyVar:=TF_ReadLines(TF("TestFile.txt","MyVar"),5) ; pass on global var t created by TF(), read lines 5 to end of file, asign result to t 
MsgBox % "TF(), example 4:`n" MyVar

t:=TF_ReadLines(TF(F),5) ; pass on global var t created by TF(), read lines 5 to end of file, asign result to t
t:=TF_ReverseLines(t,5) ; pass on global var t created by TF(), read lines 5 to end of file, asign result to t
MsgBox % "TF(), example 5:`n" t

; Work directly with the clipboard or another other variable
Clipboard=Line 1`nLine 2`nLine 3`nLine 4`nLine 5`nLine 6`nLine 7`nLine 8
Clipboard:=TF_RemoveLines(Clipboard, 3, 6) ; remove lines 3 to 6
MsgBox % "Clipboard, example 6:`n" Clipboard
