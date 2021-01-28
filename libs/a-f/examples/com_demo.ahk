; #Include com.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

COM_Init()
pwb := COM_CreateObject("InternetExplorer.Application")
COM_Invoke(pwb , "Visible=", "True") ;"False" ;"True" ;
url:="http://www.google.com"
COM_Invoke(pwb, "Navigate", url)
loop
      If (rdy:=COM_Invoke(pwb,"readyState") = 4)
         break
url:="http://www.Yahoo.com"
COM_Invoke(pwb, "Navigate", url)
loop
      If (rdy:=COM_Invoke(pwb,"readyState") = 4)
         break
MsgBox, 262208, Done, Goodbye,5
COM_Invoke(pwb, "Quit")
COM_Term()