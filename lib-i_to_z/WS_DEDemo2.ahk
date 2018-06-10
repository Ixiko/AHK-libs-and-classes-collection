
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;#include WS_DEControl.ahk

If (!WS_Initialize("VBScript"))
{
   Msgbox % "Error initializing EasyScript"
   ExitApp
}
InitComControls()


Gui, +Resize +LastFound +theme
Gui, Add, Button, x0 y0 gSetBold, Bold
Gui, Add, Button, xp+40 gSetItalic,italic
Gui, Add, Button, xp+50 gSetUnderLine, underline
gui, Add, Button, xp+75 gSetBlue, Blue
Gui, Add, Button, xp+40 gSetImageLink, Image
Gui, Add, Button, xp+50 gSetHyperLink, Link
Gui, Add, Button, xp+50 gLoadUrl, LoadURL
Gui, Add, Button, xp+70 gGetDocument, GetHtml
gui, add, button, xp+70 gSetDocument, SetHtml
Gui, Add, button, xp+70 gSaveDocument, SaveHtml
Gui, Add, button, xp+80 gBrowseMode, BrowseMode Toggle
Gui, add, button, xp+140 gNewDocument, New
Gui, add, button, xp+40 gFindText, FindText
Gui, add, button, xp+70 gSetBackColor, SetBackColor
Gui, add, button, x0 yp+25 gSetFontName, SetFontName
Gui, add, button, xp+90 gSetFontSize, SetFontSize
Gui, add, button, xp+90 gSetFont, SetFont
Gui, add, button, xp+50 gList1, List1
Gui, add, button, xp+50 gList2, List2
gui, Add, Button, xp+50 gInsertTable, InsertTable


Gui, Show, w800 h600 Center, DhtmlEdit_Test
hWnd := WinExist()

DEdit := "DEdit"

; Method #1
ppvDEdit := DE_Add(hWnd, 0, 50, 800, 550)
WS_AddObject(ppvDEdit, DEdit)

; Method #2
; If (!WS_Exec("Set %v = CreateObject(%s)", DEdit, "DhtmlEdit.DhtmlEdit"))
;       Msgbox % ErrorLevel
; If (!WS_Eval(ppvDEdit, DEdit))
;       Msgbox % ErrorLevel
; 
; hContainerCtrl := CreateComControlContainer(hWnd, 0, 25, 800, 575) 
; AttachComControlToHWND(ppvDEdit, hContainerCtrl)


Gosub, SetDocument

Return ; end of auto-run




1::

;msgbox, % GetSelection(Dedit)

return

SetBold:
;iret := Invoke(DEdit, "ExecCommand()", DECMD_BOLD)
DE_SetBold(DEdit)  

Return

SetItalic:

;iret := Invoke(DEdit, "ExecCommand()", DECMD_ITALIC)
DE_SetItalic(DEdit) 

Return

SetBlue:


;iret := Invoke(DEdit, "ExecCommand()", DECMD_SETFORECOLOR, OLECMDEXECOPT_DODEFAULT, "Blue")

;DE_SetForeColor(DEdit, "0000FF") 
DE_SetForeColor(DEdit, "Blue") ; possible way
;DE_SetForeColor(pDHtmlEdit, "#0000FF") ; also possible


Return


SetUnderline:

;iret := Invoke(DEdit, "ExecCommand()", DECMD_UNDERLINE)
DE_SetUnderline(DEdit) 

Return

SetImageLink:

;iret := Invoke(DEdit, "ExecCommand()", DECMD_IMAGE, OLECMDEXECOPT_DODEFAULT, "")
DE_SetImage(DEdit) 

Return

SetHyperLink:

;iret := Invoke(DEdit, "ExecCommand()", DECMD_HYPERLINK, OLECMDEXECOPT_DODEFAULT, "")
DE_SetHyperLink(DEdit)  

Return

LoadUrl:
url := "http://www.autohotkey.com"
DE_LoadUrl(DEdit, url) 
Return

NewDocument:
DE_NewDocument(DEdit) 
Return

SaveDocument:

Filedir = %A_ScriptDir%\DhtmlEdit_%A_Now%.htm 
DE_SaveDocument(DEdit, FileDir)

Return

GetDocument:

msgbox, % DE_GetDocumentHtml(DEdit)

Return

SetDocument:

htmlcode =
(
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content="text/html; charset=ISO-8859-1"
 http-equiv="content-type">
  <title></title>
</head>
<body
 style="COLOR: rgb(0,0,0); BACKGROUND-COLOR: rgb(255,204,51)" alink   
 ="#ee0000" link="#0000ee" vlink="#551a8b">
<P>
<big style="FONT-FAMILY: Verdana"><big><EM><STRONG>Forgive</STRONG></EM> my <span
 style="FONT-WEIGHT: bold; COLOR: rgb(51,51,255)"  >poor</span> coding style! Yes?
</big></big></P>
<P><BIG style="FONT-FAMILY: Verdana"><BIG>This File is Edited with 
<STRONG>DhtmlEdit_Demo</STRONG>
  .<br>
<br></P></BIG></BIG>
<ul style="FONT-FAMILY: Verdana">
  <li><STRONG><U>First List</U></STRONG> 
  <li><FONT color=blue>second List</FONT> 
  <li><A href="http://www.autohotkey.com">what 
  now?(</A>click then go to AutohotKey)</li>
</ul>
<br style="FONT-FAMILY: Verdana">
<table
 style="WIDTH: 440px; FONT-FAMILY: Verdana; HEIGHT: 52px; TEXT-ALIGN: left"
 border="1" cellpadding="2" cellspacing="2">
  <tbody>
    <tr>
      <td>This is a table<br>
and &nbsp;the right image is directly from AutoHotKey Forum.</td>
      <td><A href="http://www.autohotkey.com"><img style="WIDTH: 228px; HEIGHT: 133px"
 alt="image cannot be loaed for some reason"
 src="http://www.autohotkey.com/docs/images/AutoHotkey_logo.gif"></A></td>
    </tr>
  </tbody>
</table>
</body>
</html>
)


DE_SetDocumentHtml(DEdit, htmlcode)
htmlcode =


Return


BrowseMode:

DE_BrowseMode(DEdit)

Return


FindText:

DE_FindText(DEdit)

Return

SetBackColor:

DE_SetBackColor(DEdit, "Yellow")

Return


SetFontName:

DE_SetFontName(DEdit, "Arial Black")

Return

SetFontSize:

DE_SetFontSize(DEdit, "4")

Return

SetFont:

DE_Font(DEdit)

Return

List1:

DE_OrderList(DEdit)

Return

List2:

DE_UnOrderList(DEdit)
Return

InsertTable:

DE_InsertTable(2,2)

return




GuiSize:

DE_Move(ppvDEdit, 0, 50, A_GuiWidth, A_GuiHeight-50)


Return



GuiClose:
Gui, %A_Gui%:Destroy
ReleaseObject(ppvDEdit)
UninitComControls()
WS_Uninitialize()
ExitApp
