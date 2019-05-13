OnExit, CleanUp
#Persistent

global JCWSettings

FileCreateDir, %A_AppData%\JCW\
JCWSettings:=new ApplicationSettingsClass(A_AppData "\JCW\JControlWriter.ini", "JControlWriter")

fileinstall, JCWGUIStrings.ini, %A_AppData%\JCW\JCWGUIStrings.ini
LoadResourceStrings(A_AppData "\JCW\JCWGUIStrings.ini", JCWSettings, "English")

if !InitJavaAccessBridge()
{
msgbox, JAB not loaded!
}
return

#Include JavaAccessBridge.ahk

; shows the list of all visible controls
^!F10::
OpenJControlDlg("A")
return

; shows the list of all visible and invisible controls
^!F11::
OpenJControlDlg("A", 0)
return

; test function
^!F12::
JavaControlDoAction(0, "File", "menu", "", "1", "click")
sleep, 1000
msgbox, done
return

CleanUp:
ExitJavaAccessBridge()
ExitApp

OpenJControlDlg(hwnd, visible:=1)
{
global 13JCtrlLVVar, 13Searchfield, 13GuiHwnd
if (hwnd="A")
{
currwin:=WinExist("A")
JCWSettings.13hwnd:=currwin
if (!IsJavaWindow(currwin))
{
ControlGetFocus, currctrl, ahk_id %currwin%
ControlGet, currwin, Hwnd, , %currctrl%, ahk_id %currwin%
}
}
if (IsJavaWindow(currwin))
{
JCWSettings.13JWinVmId:=1
ac:=0
Info:=
getAccessibleContextFromHWND(currwin, vmid, ac)
JCWSettings.13JWinVmId:=vmid
rac:=GetAccessibleChildFromContext(VmId, ac, 0)
if (visible)
JCWSettings.13JWinVisibleChildren:=GetVisibleChildrenFromTree(VmId, rac)
else
JCWSettings.13JWinVisibleChildren:=GetAllChildrenFromTree(VmId, rac)
Gui, 13: Destroy
Gui, 13: +Resize +MaximizeBox +MinimizeBox +Hwnd13GuiHwnd
Gui, 13: Add, ListView, r10 w500 AltSubmit -Multi v13JCtrlLVVar g13JVisItLVLAb, % JCWSettings.ResourceString.13JControlListHeader
GuiControlGet, CSize, 13:Pos, 13JCtrlLVVar
JCWSettings["13cMargin"]:=cSizeX
Gui, 13: Add, Button, xm g13WriteCommandsFile, % JCWSettings.ResourceString.13JControlWriteCommandsFileButton
Gui, 13: Add, Button, x+10 section g13CopyCommand, % JCWSettings.ResourceString.13JControlCopyCommandButton
Gui, 13: Add, Text, x+30 yp+5, % JCWSettings.ResourceString.13JControlSearchLabel
Gui, 13: Add, Edit, x+10 ys v13Searchfield g13SearchFieldLabel,
Gui, 13: Add, Button, x+10 g13FindNextLabel, % JCWSettings.ResourceString.13JControlFindNextButton
Gui, 13: Add, Button, x+30 g13Cancel, % JCWSettings.ResourceString.ButtonClose
GuiControlGet, CSize, 13:Pos, % JCWSettings.ResourceString.ButtonClose
JCWSettings["13cMinSizeH"]:=CSizeY+CSizeH+JCWSettings["13cMargin"]
JCWSettings["13cSizeButH"]:=CSizeH+2*JCWSettings["13cMargin"]
JCWSettings["13cSizeCButW"]:=CSizeW+JCWSettings["13cMargin"]
GuiControlGet, CSize, 13:Pos, % JCWSettings.ResourceString.ButtonClose
JCWSettings["13cMinSizeW"]:=CSizeX+CSizeW+JCWSettings["13cMargin"]
Gui, 13: Default
Gui, 13: ListView, 13JCtrlLVVar
OBJCounter:=
OBJCounter:=Object()
For index, value in JCWSettings.13JWinVisibleChildren
{
Info:=
Info:=getAccessibleContextInfo(VmId, value)
act:=""
if (Instr(Info["States"],"focusable"))
act:="focus, "
if (Info["Accessible action"]<>0)
{
Actions:=getAccessibleActions(VmId, value)
act:=""
for ind2, val2 in Actions
{
act.= val2 ", "
}
}
oident:="R:" Info["Role"] "N:" Info["Name"] "D:" Info["Description"]
if (OBJCounter[oident]<1)
{
OBJCounter.Insert(oident,"0")
}
OBJCounter[oident]:=1+OBJCounter[oident]
LV_Add("",index,OBJCounter[oident],Info["Role"],Info["Name"],Info["Description"],act,value)
}
LV_ModifyCol()
str:="+MinSize" JCWSettings["13cMinSizeW"] "x" JCWSettings["13cMinSizeH"]
Gui, 13: %str%
x:=JCWSettings.SetIni("13GuiX","empty")
y:=JCWSettings.SetIni("13GuiY","empty")
w:=JCWSettings.SetIni("13GuiW","empty")
h:=JCWSettings.SetIni("13GuiH","empty")
JCWSettings.SetIni("13FileSavePath","")
WinGetTitle, title
if x is integer
if y is integer
if h is integer
if w is integer
{
Gui, 13: Show, % "X" x " Y" y " W" w " H" h, % JCWSettings.ResourceString.13JControlTitle " " title
}
else
Gui, 13: Show, Center, % JCWSettings.ResourceString.13JControlTitle " " title
else
Gui, 13: Show, Center, % JCWSettings.ResourceString.13JControlTitle " " title
else
Gui, 13: Show, Center, % JCWSettings.ResourceString.13JControlTitle " " title
else
Gui, 13: Show, Center, % JCWSettings.ResourceString.13JControlTitle " " title
LV_Modify(1,"Select Focus Vis")
}
else
{
WinGetTitle, title
msgbox, %hwnd%, %currctrl%, %currwin%, %title%
}
}

13GuiSize:
13GuiResize(A_GuiWidth, A_GuiHeight)
return

13GuiResize(GuiWidth, GuiHeight)
{
GuiControl, 13:MoveDraw, 13JCtrlLVVar, % "w" GuiWidth-2*JCWSettings["13cMargin"] "h" GuiHeight-JCWSettings["13cSizeButH"]
GuiControlGet, CSize, 13:Pos, 13JCtrlLVVar
GuiControl, 13:MoveDraw, % JCWSettings.ResourceString.13JControlWriteSpeechFileButton, % "y" CSizeY+CSizeH+JCWSettings["13cMargin"]
GuiControl, 13:MoveDraw, % JCWSettings.ResourceString.13JControlWriteCommandsFileButton, % "y" CSizeY+CSizeH+JCWSettings["13cMargin"]
GuiControl, 13:MoveDraw, % JCWSettings.ResourceString.13JControlCopyCommandButton, % "y" CSizeY+CSizeH+JCWSettings["13cMargin"]
GuiControl, 13:MoveDraw, % JCWSettings.ResourceString.13JControlSearchLabel, % "y" CSizeY+CSizeH+JCWSettings["13cMargin"]+5
GuiControl, 13:MoveDraw, 13Searchfield, % "y" CSizeY+CSizeH+JCWSettings["13cMargin"]
GuiControl, 13:MoveDraw, % JCWSettings.ResourceString.13JControlFindNextButton, % "y" CSizeY+CSizeH+JCWSettings["13cMargin"]
GuiControl, 13:MoveDraw, % JCWSettings.ResourceString.ButtonClose, % "x" GuiWidth-JCWSettings["13cSizeCButW"] "y" CSizeY+CSizeH+JCWSettings["13cMargin"]
if GuiWidth is integer
JCWSettings["13GuiW"]:=GuiWidth
if GuiHeight is integer
JCWSettings["13GuiH"]:=GuiHeight
}

13JVisItLVLAb:
if (A_GuiEvent="I")
{
DisplayBorder()
}
return

13FindNextLabel:
13FindText(1)
return

13SearchFieldLabel:
13FindText(0)
return

13FindText(addline:=1)
{
global 13Searchfield
Gui, 13: Default
Gui, 13: ListView, 13JCtrlLVVar
Gui, 13: Submit, NoHide
fr:=LV_GetNext(0, "Focused")
frs:=fr+addline
cn:=LV_GetCount()
found:=0
while (frs<=cn)
{
LV_GetText(Output, frs , 3)
if (InStr(Output, 13Searchfield))
{
found:=1
break
}
LV_GetText(Output, frs , 4)
if (InStr(Output, 13Searchfield))
{
found:=1
break
}
LV_GetText(Output, frs , 5)
if (InStr(Output, 13Searchfield))
{
found:=1
break
}
frs++
}
if (!found)
{
frs:=1
while (frs<=fr)
{
LV_GetText(Output, frs , 3)
if (InStr(Output, 13Searchfield))
{
found:=1
break
}
LV_GetText(Output, frs , 4)
if (InStr(Output, 13Searchfield))
{
found:=1
break
}
LV_GetText(Output, frs , 5)
if (InStr(Output, 13Searchfield))
{
found:=1
break
}
frs++
}
}
if (found)
{
LV_Modify(frs,"Select Focus Vis")
}
}

DisplayBorder()
{
Gui, 13: Default
Gui, 13: ListView, 13JCtrlLVVar
fr:=LV_GetNext(0, "Focused")
LV_GetText(Output, fr , 1)
Info:=getAccessibleContextInfo(JCWSettings.13JWinVmId, JCWSettings["13JWinVisibleChildren"][Output])
x:=Info["X"]
y:=Info["Y"]
w:=Info["Width"]
h:=Info["Height"]
Gui, 14: Destroy
border_thickness:= 10
Gui, 14: +Lastfound +AlwaysOnTop +Toolwindow
iw:= w+border_thickness
ih:= h+border_thickness
w:=w+border_thickness*2
h:=h+border_thickness*2
x:= x -border_thickness
y:= y -border_thickness
Gui, 14: Color, 00FF00
Gui, 14: -Caption
WinSet, Region, 0-0 %w%-0 %w%-%h% 0-%h% 0-0 %border_thickness%-%border_thickness% %iw%-%border_thickness% %iw%-%ih% %border_thickness%-%ih% %border_thickness%-%border_thickness%
Gui, 14: Show, w%w% h%h% x%x% y%y% NoActivate,
}

13WriteCommandsFile:
WriteCommandsFile()
return

WriteCommandsFile()
{
WinGetTitle, WinTitle, % "ahk_id " JCWSettings.13hwnd
FileSelectFile, filename, S 18, % JCWSettings["13FileSavePath"] WinTitle ".ahk"
If (filename<>"")
{
SplitPath, filename, , OutDir
JCWSettings["13FileSavePath"]:=OutDir "\"
file:=FileOpen(filename,"w `n")
OBJCounter:=
OBJCounter:=Object()
For index, value in JCWSettings.13JWinVisibleChildren
{
Info:=
Info:=getAccessibleContextInfo(JCWSettings.13JWinVmId, value)
If (Info["Role"]<>"panel" and Info["Role"]<>"filler" and Info["Role"]<>"root pane" and Info["Role"]<>"layered pane" and Info["Role"]<>"menu bar" and Info["Role"]<>"tool bar" and Info["Role"]<>"separator" and Info["Role"]<>"split pane" and Info["Role"]<>"viewport" and Info["Role"]<>"scroll bar" and Info["Role"]<>"scroll pane")
{
Action:=""
if (Info["Accessible action"]<>0)
{
Actions:=getAccessibleActions(JCWSettings.13JWinVmId, value)
Action:=""
for ind2, val2 in Actions
{
Action.= val2 ", "
}
}
Action:=Trim(Trim(Action),",")
if (Instr(Info["States"],"focusable") and act="")
act:="focus"
oident:="R:" Info["Role"] "N:" Info["Name"] "D:" Info["Description"]
if (OBJCounter[oident]<1)
{
OBJCounter.Insert(oident,"0")
}
OBJCounter[oident]:=1+OBJCounter[oident]
if (Action<>"")
{
c:="JavaControlDoAction(0, """ . Info["name"] . """, """ Info["Role"] . """, """ . Info["Description"] . """, """ . OBJCounter[oident] . """, """ . Action . """)"
file.WriteLine(c)
}
}
}
file.Close()
}
}

13CopyCommand:
CopyJCommand()
return

CopyJCommand()
{
global 13JCtrlLVVar
Gui, 13: Default
Gui, 13: ListView, 13JCtrlLVVar
fr:=LV_GetNext(0, "Focused")
LV_GetText(Output, fr , 1)
Info:=getAccessibleContextInfo(JCWSettings.13JWinVmId, JCWSettings["13JWinVisibleChildren"][Output])
LV_GetText(Output, fr , 6)
Action:=Trim(Trim(Output),",")
LV_GetText(Output, fr , 2)
s:="JavaControlDoAction(0, """ . Info["Name"] . """, """ Info["Role"] . """, """ . Info["Description"] . """, """ . Output . """, """ . Action . """)" . Chr(13) Chr(10)
ClipBoard:=s
}

13SaveGuiPos()
{
global 13GuiHwnd
WinGetPos, x, y, , , ahk_id %13GuiHwnd%
JCWSettings["13GuiX"]:=x
JCWSettings["13GuiY"]:=y
}

13GuiEscape:
13GuiClose:
14GuiEscape:
14GuiClose:
13Cancel:
13SaveGuiPos()
Gui, 13: Destroy
Gui, 14: Destroy
JCWSettings.13JWinVisibleChildren:=
return

LoadResourceStrings(ResourceFile, byref BaseObject, Language:="English")
{
If (IsObject(BaseObject))
{
If (BaseObject.HasKey("ResourceString"))
ObjRelease(BaseObject.ResourceString)
BaseObject.ResourceString:=Object()
IniRead, ResStrings, %ResourceFile%, %Language%
Loop, Parse, ResStrings, `n, `r
{
cnt:=Instr(A_LoopField,"=")-1
StringLeft, Left, A_LoopField, %cnt%
BaseObject["ResourceString"][Left]:=UnEscapeLiteralStr(SubStr(A_LoopField,cnt+2))
}
}
}

UnEscapeLiteralStr(Line)
{
tline:=Line
StringReplace, tline, tline, ```,, `,, All
StringReplace, tline, tline, ```%, `%, All
StringReplace, tline, tline, ```;, `;, All
StringReplace, tline, tline, ``n, `n, All
StringReplace, tline, tline, ``r, `r, All
StringReplace, tline, tline, ``b, `b, All
StringReplace, tline, tline, ``t, `t, All
StringReplace, tline, tline, ``v, `v, All
StringReplace, tline, tline, ``a, `a, All
StringReplace, tline, tline, ``f, `f, All
Return, tline
}

class ApplicationSettingsClass
{

__New(IniFile:="", Section:="Main")
{
ApplicationSettingsClass.hidden[this]:= { ASVars: [], ASConsts: [], ASInis: []}
ApplicationSettingsClass.hidden[this].IniFilePath:=IniFile
ApplicationSettingsClass.hidden[this].IniSection:=Section
}

__Get(VarName)
{
If (ApplicationSettingsClass.hidden[this].ASConsts.HasKey(VarName))
return, ApplicationSettingsClass.hidden[this].ASConsts[VarName]
else If (ApplicationSettingsClass.hidden[this].ASInis.HasKey(VarName))
return, ApplicationSettingsClass.hidden[this].ASInis[VarName]
else If (ApplicationSettingsClass.hidden[this].ASVars.HasKey(VarName))
return, ApplicationSettingsClass.hidden[this].ASVars[VarName]
else MsgBox, Read from undefined variable: %VarName%
}

__Set(VarName, byref Value)
{
If (ApplicationSettingsClass.hidden[this].ASConsts.HasKey(VarName))
{
MsgBox, Attempt to write to constant: %VarName%
return
}
else If (ApplicationSettingsClass.hidden[this].ASInis.HasKey(VarName))
{
ApplicationSettingsClass.hidden[this].ASInis[VarName]:=Value
If ApplicationSettingsClass.hidden[this].IniFilePath<>""
{
IniWrite, %Value%, % ApplicationSettingsClass.hidden[this].IniFilePath, % ApplicationSettingsClass.hidden[this].IniSection, %VarName%
}
return
}
else
return ApplicationSettingsClass.hidden[this].ASVars[VarName]:=Value
}

SetConstant(VarName, byref Value)
{
If (ApplicationSettingsClass.hidden[this].ASConsts.HasKey(VarName))
{
MsgBox, Attempt to write to constant: %VarName%
return
}
else
{
ApplicationSettingsClass.hidden[this].ASConsts[VarName]:=Value
return, value
}
}

SetIni(VarName, DefaultValue:="")
{
If (ApplicationSettingsClass.hidden[this].ASConsts.HasKey(VarName))
{
MsgBox, Attempt to overload constant: %VarName%
return
}
else
{
If ApplicationSettingsClass.hidden[this].IniFilePath<>""
{
IniRead, Value, % ApplicationSettingsClass.hidden[this].IniFilePath, % ApplicationSettingsClass.hidden[this].IniSection, %VarName%, EMPTYVALUE
If (Value="EMPTYVALUE")
{
Value:=DefaultValue
IniWrite, %Value%, % ApplicationSettingsClass.hidden[this].IniFilePath, % ApplicationSettingsClass.hidden[this].IniSection, %VarName%
}
ApplicationSettingsClass.hidden[this].ASInis[VarName]:=Value
}
return, value
}
}

GetIniFilePath()
{
return, ApplicationSettingsClass.hidden[this].IniFilePath
}

__Delete()
{
this.Remove("ASVars")
this.Remove("ASConsts")
this.Remove("ASInis")
}
}