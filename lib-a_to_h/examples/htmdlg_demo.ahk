; #Include HtmDlg.ahk
#NoEnv
SendMode Input
#SingleInstance, Force
SetWorkingDir %A_ScriptDir% 

bgcolor := GetSysColor(15)  ; Window Background color for the current desktop theme

FileDelete, demo.htm
FileAppend,
( Join
<html><body bgcolor="#%bgcolor%" leftmargin="10" topmargin="10"><div align="left"><p><font
 face="Arial" size="2">This area of this Dialogbox uses HTM which means you can format you
r message using <i>Italics, </i><b>Bold</b>, <font color="#3366CC"><b><font color="#FF0033
">Colors</font></b></font> and all other formatting HTML permits.<br><br>Please note that
 this webcontrol mimics a static control using these workarounds:<br><b>1)</b> Your comput
er system's window color is <b>%bgcolor%</b>, and is being used as the bgcolor of HTM so a
s to simulate transparency. <b><br>2)</b> This control has been disabled and so you cannot
 select/copy text.<b><br>3)</b> The vertical scrollbar is just outside the client-area of
 this dialog.<br><br>Do you like this MessageBox?</font><font face="Arial" size="2"></font
><font color="#3333CC" face="Arial" size="2"> </font></p></div></body></html>
)
, demo.htm


URL=file:///%A_ScriptDir%\demo.htm
Options := "Buttons=Yes/No/50-50, HtmW=360, HtmH=260, BEsc=3"

Sel := HtmDlg( URL, "", Options )

Return                                                 ; // end of auto-execute section //


GetSysColor( DisplayElement=1 ) {
 VarSetCapacity( HexClr,7,0 ), SClr := DllCall( "GetSysColor", UInt,DisplayElement )
 RGB := ( ( ( SClr & 0xFF) << 16 ) | ( SClr & 0xFF00 ) | ( ( SClr & 0xFF0000 ) >> 16 ) )
 DllCall( "msvcrt\sprintf", Str,HexClr, Str,"%06X", UInt,RGB )
Return HexClr
}