/*  Highlite - BBCode syntax highlighting
 *  By kon
 *  Last Updated June 13, 2014
 *
 *  Instructions
 *      - Copy text to the clipboard
 *      - Run this script
 *      - To paste into autohotkey.com:
 *          - Ensure "BBCode Mode" is toggled off. (The light switch icon, top left)
 *          - Click the "Paste as Plain Text" button and paste.
 *            (or set "Paste as Plain Text" as the default in the forum options)
 *          - Click the "BBCode Mode" button twice to toggle it on and then off again.
 *            This step will preserve indenting and newlines.
 */

;==================================================================
; Configuration section
ShowGUI := true

; Options
MO := { "B"  :  true        ; bold tag
    ,   "HR" :  true        ; horizontal rule tag
    ,   "PCU":  true        ; prevent automatic collapsing of URL's
    ,   "QB" :  false       ; quote box tag
    ,   "SP" :  true }      ; spoiler tag
   
; Colors
C  := { "BIV":  "cc00cc"    ; built in variables
    ,   "CMD":  "0000cc"    ; commands
    ,   "DRT":  "ff0000"    ; directives
    ,   "FUN":  "008080"    ; functions
    ,   "KEY":  "ff6600"    ; keys
    ,   "KWD":  "663300"    ; keywords
    ,   "LBG":  "ffff99"    ; label backgrounds
    ,   "LBL":  "000000"    ; labels
    ,   "MLC":  "916f6f"    ; multi line comments
    ,   "NHT":  "000000"    ; non-highlighted text color
    ,   "SLC":  "008000"    ; single line comments
    ,   "STR":  "8D5FD3" }  ; strings
; End of configuration section
;==================================================================

SetBatchLines, -1
#NoEnv

; GUI
if (ShowGUI)
    Options(MO)

 TempClip := Clipboard, Clipboard := ""

; Literal URLs
if (MO["PCU"])
    TempClip := RegExReplace(TempClip, "Ui)\b(https?://)"
    , "[c]$1[/c]")

; Backreferences
StringReplace, TempClip, TempClip, $, <<<_BRPlaceholder_>>>, All

; Multi line comments
MultiLine := [], m := "", p := 1
while p := RegExMatch(TempClip, "s)(^|\R)\s*/\*.*?(\R\s*\*/|$)", m, p+StrLen(m))
    MultiLine[A_Index] := m
TempClip := RegExReplace(TempClip, "s)(^|\R)\s*/\*.*?(\R\s*\*/|$)"
, "`r`n<<<_MultiLinePlaceholder_>>>`r`n")

; Single line comments
Comments := [], m := "", p := 1
while p := RegExMatch(TempClip, "m)(^|\s)(;.*)$", m, p+StrLen(m))
    Comments[A_Index] := m2
TempClip := RegExReplace(TempClip, "m)(^|\s)\K(;.*)$"
, "`r`n<<<_CommentPlaceholder_>>>`r`n")

; Quoted strings
Quoted := [], m := "", p := 1
while p := RegExMatch(TempClip, "(?<!``)("".*?)(?<!``)("")", m, p+StrLen(m))
    Quoted[A_Index] := m
TempClip := RegExReplace(TempClip, "(?<!``)("".*?)(?<!``)("")"
, "`r`n<<<_QuotedPlaceholder_>>>`r`n")

; Gui color
TempClip := RegExReplace(TempClip, "i)(?<!])(?<!#)\b(color)\b"
, "[url=http://ahkscript.org/docs/commands/Gui.htm#Color][color=#" C["CMD"] "]$1[/color][/url]")

; Labels
TempClip := RegExReplace(TempClip, "im)^\s*\K(\w+:)(\s|$)"
, "[background=#" C["LBG"] "][color=#" C["LBL"] "]$1[/color][/background]$2")

Group1 := ["and","in","is","not","or"]
for key, val in Group1
    TempClip := RegExReplace(TempClip, "i)\b(" val ")\b"
    , "[color=#" C["KWD"] "]$1[/color]")

Group2 := ["Else","For","Loop","Return","While"]
for key, val in Group2
    TempClip := RegExReplace(TempClip, "i)\b(?<!commands/)(" val ")\b"
    , "[url=http://ahkscript.org/docs/commands/" val ".htm][color=#" C["KWD"] "]$1[/color][/url]")

Group3 := ["Break","Catch","Exit","ExitApp","Finally","Gosub","Goto","IfExist"
    , "IfInString","IfMsgBox","IfNotExist","IfNotInString","OnExit","SetTimer","Sleep","Suspend"
    , "Throw","Try","Until"]
for key, val in Group3
    TempClip := RegExReplace(TempClip, "i)(?<!/)\b(?<![_#])(" val ")(?!])\b"
    , "[url=http://ahkscript.org/docs/commands/" val ".htm][color=#" C["KWD"] "]$1[/color][/url]")

Bool := ["false","true"]
for key, val in Bool
    TempClip := RegExReplace(TempClip, "i)\b(?<!commands/)(" val ")\b"
    , "[url=http://ahkscript.org/docs/Variables.htm#Boolean][color=#" C["KWD"] "]$1[/color][/url]")

IfEq := ["If","IfEqual","IfNotEqual","IfLess","IfLessOrEqual","IfGreater","IfGreaterOrEqual"]
for key, val in IfEq
    TempClip := RegExReplace(TempClip, "i)(?<!#)\b(?<!commands/)(" val ")(?!\s*\()\b"
    , "[url=http://ahkscript.org/docs/commands/IfEqual.htm][color=#" C["KWD"] "]$1[/color][/url]")

; Built in variables
BIV := ["AhkPath","AhkVersion","AppData","AppDataCommon","AutoTrim","BatchLines","CaretX","CaretY","ComputerName"
    , "ControlDelay","Cursor","DD","DDD","DDDD","DefaultMouseSpeed","Desktop","DesktopCommon","DetectHiddenText"
    , "DetectHiddenWindows","EndChar","EventInfo","ExitReason","FormatFloat","FormatInteger","Gui","GuiControl"
    , "GuiControlEvent","GuiEvent","GuiHeight","GuiWidth","GuiX","GuiY","Hour","IconFile","IconHidden","IconNumber"
    , "IconTip","Index","IPAddress1","IPAddress2","IPAddress3","IPAddress4","Is64bitOS","ISAdmin","IsCompiled"
    , "IsCritical","IsPaused","IsSuspended","IsUnicode","KeyDelay","Language","LastError","LineFile","LineNumber"
    , "LoopField","LoopFileAttrib","LoopFileDir","LoopFileExt","LoopFileFullPath","LoopFileLongPath","LoopFileName"
    , "LoopFileShortName","LoopFileShortPath","LoopFileSize","LoopFileSizeKB","LoopFileSizeMB","LoopFileTimeAccessed"
    , "LoopFileTimeCreated","LoopFileTimeModified","LoopReadLine","LoopRegKey","LoopRegName","LoopRegSubkey"
    , "LoopRegTimeModified","LoopRegType","MDAY","Min","MM","MMM","MMMM","Mon","MouseDelay","MSec","MyDocuments","Now"
    , "NowUTC","NumBatchLines","OSType","OSVersion","PriorHotkey","ProgramFiles","Programs","ProgramsCommon","PtrSize"
    , "RegView","ScreenDPI","ScreenHeight","ScreenWidth","ScriptDir","ScriptFullPath","ScriptHwnd","ScriptName","Sec"
    , "Space","StartMenu","StartMenuCommon","Startup","StartupCommon","StringCaseSense","Tab","Temp","ThisFunc"
    , "ThisHotkey","ThisLabel","ThisMenu","ThisMenuItem","ThisMenuItemPos","TickCount","TimeIdle","TimeIdlePhysical"
    , "TimeSincePriorHotkey","TimeSinceThisHotkey","TitleMatchMode","TitleMatchModeSpeed","UserName","WDay","WinDelay"
    , "WinDir","WorkingDir","YDay","YEAR","YWeek","YYYY"]
for key, val in BIV
    TempClip := RegExReplace(TempClip, "i)\b(A_)(" val ")\b"
    , "[url=http://ahkscript.org/docs/Variables.htm#" val "][color=#" C["BIV"] "]$1$2[/color][/url]")

; Built in variables 2
BIV2 := ["ComSpec","ErrorLevel","ProgramFiles"]
for key, val in BIV2
    TempClip := RegExReplace(TempClip, "i)\b(?<!Variables.htm#)(" val ")\b"
    , "[url=http://ahkscript.org/docs/Variables.htm#" val "][color=#" C["BIV"] "]$1[/color][/url]")

; if (expression)
TempClip := RegExReplace(TempClip, "i)\b(?<!#)(if)(\s*\()"
, "[url=http://ahkscript.org/docs/commands/IfExpression.htm][color=#" C["KWD"] "]$1[/color][/url]$2")

Commands := ["AutoTrim","BlockInput","Click","ClipWait","Continue","Control","ControlClick","ControlFocus","ControlGet"
    , "ControlGetFocus","ControlGetPos","ControlGetText","ControlMove","ControlSend","ControlSendRaw","ControlSetText"
    , "CoordMode","Critical","DetectHiddenText","DetectHiddenWindows","Drive","DriveGet","DriveSpaceFree","EnvAdd"
    , "EnvDiv","EnvGet","EnvMult","EnvSet","EnvSub","EnvUpdate","FileAppend","FileCopy","FileCopyDir","FileCreateDir"
    , "FileCreateShortcut","FileDelete","FileEncoding","FileGetAttrib","FileGetShortcut","FileGetSize","FileGetTime"
    , "FileGetVersion","FileInstall","FileMove","FileMoveDir","FileRead","FileReadLine","FileRecycle","FileRecycleEmpty"
    , "FileRemoveDir","FileSelectFile","FileSelectFolder","FileSetAttrib","FileSetTime","FormatTime","GetKeyState"
    , "GroupActivate","GroupAdd","GroupClose","GroupDeactivate","Gui","GuiControl","GuiControlGet","Hotkey","ImageSearch"
    , "IniDelete","IniRead","IniWrite","Input","InputBox","KeyHistory","KeyWait","ListHotkeys","ListLines","ListVars"
    , "Menu","MouseClick","MouseClickDrag","MouseGetPos","MouseMove","MsgBox","OutputDebug","PixelGetColor","PixelSearch"
    , "PostMessage","Process","Progress","Random","RegDelete","RegRead","RegWrite","Reload","Run","RunAs","RunWait"
    , "SendLevel","SendMessage","SendMode","SetBatchLines","SetCapslockState","SetControlDelay","SetDefaultMouseSpeed"
    , "SetEnv","SetFormat","SetKeyDelay","SetMouseDelay","SetNumlockState","SetRegView","SetScrollLockState"
    , "SetStoreCapslockMode","SetTitleMatchMode","SetWinDelay","SetWorkingDir","Shutdown","Sort","SoundBeep","SoundGet"
    , "SoundGetWaveVolume","SoundPlay","SoundSet","SoundSetWaveVolume","SplashImage","SplashTextOff","SplashTextOn"
    , "SplitPath","StatusBarGetText","StatusBarWait","StringCaseSense","StringGetPos","StringLeft","StringLen"
    , "StringLower","StringMid","StringReplace","StringRight","StringSplit","StringTrimLeft","StringTrimRight"
    , "StringUpper","SysGet","Thread","ToolTip","Transform","TrayTip","URLDownloadToFile","WinActivate"
    , "WinActivateBottom","WinClose","WinGet","WinGetActiveStats","WinGetActiveTitle","WinGetClass","WinGetPos"
    , "WinGetText","WinGetTitle","WinHide","WinKill","WinMaximize","WinMenuSelectItem","WinMinimize","WinMinimizeAll"
    , "WinMinimizeAllUndo","WinMove","WinRestore","WinSet","WinSetTitle","WinShow","WinWait","WinWaitActive"
    , "WinWaitClose","WinWaitNotActive"]
for key, val in Commands
    TempClip := RegExReplace(TempClip, "i)(?<!/)\b(?<![_#])(" val ")(?!])\b"
    , "[url=http://ahkscript.org/docs/commands/" val ".htm][color=#" C["CMD"] "]" val "[/color][/url]")

; Gui controls
GuiCont := ["ActiveX","Button","Checkbox","ComboBox","Custom","DateTime","DDL","DropDownList","Edit","GroupBox","Link"
    , "ListBox","ListView","MonthCal","Picture","Radio","Slider","StatusBar","Text","TreeView","UpDown"]  ;,"Tab","Hotkey","Progress"
for key, val in GuiCont
    TempClip := RegExReplace(TempClip, "i)\b(" val ")\b"
    , "[url=http://ahkscript.org/docs/commands/GuiControls.htm#" val "][color=#" C["CMD"] "]$1[/color][/url]")

; Built in functions
BIF := ["Abs","ACos","Asc","ASin","ATan","Ceil","Chr","Cos","Exp","FileExist","Floor","Func","GetKeyName","InStr","IsByRef"
    , "IsFunc","IsLabel","IsObject","Ln","Log","Mod","NumGet","NumPut","Round","SB_SetIcon","SB_SetParts","SB_SetText"
    , "Sin","Sqrt","StrLen","StrSplit","SubStr","Tan","WinActive","WinExist"]
for key, val in BIF
    TempClip := RegExReplace(TempClip, "i)\b(" val ")(?=\()\b"
    , "[url=http://ahkscript.org/docs/Functions.htm#" val "][color=#" C["FUN"] "]$1[/color][/url]")

; Built in functions 2
BIF2 := ["ComObjActive","ComObjArray","ComObjConnect","ComObjCreate","ComObjError","ComObjFlags","ComObjGet","ComObjQuery"
    , "ComObjType","ComObjValue","DllCall","FileOpen","OnMessage","RegExMatch","RegExReplace","RegisterCallback","Trim"
    , "VarSetCapacity"]
for key, val in BIF2
    TempClip := RegExReplace(TempClip, "i)(?<!/)\b(?<![_#])(" val ")(?=\()\b(?!])"
    , "[url=http://ahkscript.org/docs/commands/" val ".htm][color=#" C["FUN"] "]" val "[/color][/url]")

; Built in list view functions
BILVF := ["IL_Add","IL_Create","IL_Destroy","LV_Add","LV_Delete","LV_DeleteCol","LV_GetCount","LV_GetNext","LV_GetText"
    , "LV_Insert","LV_InsertCol","LV_Modify","LV_ModifyCol","LV_SetImageList"]
for key, val in BILVF
    TempClip := RegExReplace(TempClip, "i)\b(" val ")(?=\()\b"
    , "[url=http://ahkscript.org/docs/commands/ListView.htm#" val "][color=#" C["FUN"] "]$1[/color][/url]")

; Built in tree view functions
BITVF := ["TV_Add","TV_Delete","TV_Get","TV_GetChild","TV_GetCount","TV_GetNext","TV_GetParent","TV_GetPrev"
    , "TV_GetSelection","TV_GetText","TV_Modify","TV_SetImageList"]
for key, val in BITVF
    TempClip := RegExReplace(TempClip, "i)\b(" val ")(?=\()\b"
    , "[url=http://ahkscript.org/docs/commands/TreeView.htm#" val "][color=#" C["FUN"] "]$1[/color][/url]")

; Directives
Drct := ["AllowSameLineComments","ClipboardTimeout","CommentFlag","ErrorStdOut","EscapeChar","HotkeyInterval"
    , "HotkeyModifierTimeout","Hotstring","If","IfTimeout","InputLevel","InstallKeybdHook","InstallMouseHook","KeyHistory"
    , "LTrim","MaxHotkeysPerInterval","MaxMem","MaxThreads","MaxThreadsBuffer","MaxThreadsPerHotkey","MenuMaskKey","NoEnv"
    , "NoTrayIcon","Persistent","SingleInstance","UseHook","Warn","WinActivateForce"]
for key, val in Drct
    TempClip := RegExReplace(TempClip, "i)(#)\b(" val ")\b"
    , "[url=http://ahkscript.org/docs/commands/_" val ".htm][color=#" C["DRT"] "]#$2[/color][/url]")

Keys := ["Alt","AltDown","AltUp","AppsKey","BackSpace","Browser_Back","Browser_Favorites","Browser_Forward","Browser_Home"
    , "Browser_Refresh","Browser_Search","Browser_Stop","BS","CapsLock","Ctrl","CtrlBreak","CtrlDown","CtrlUp","Del"
    , "Delete","Down","End","Enter","Esc","Escape","F1","F10","F11","F12","F13","F14","F15","F16","F17","F18","F19","F2"
    , "F20","F21","F22","F23","F24","F3","F4","F5","F6","F7","F8","F9","Home","Ins","Insert","Joy1","Joy10","Joy11"
    , "Joy12","Joy13","Joy14","Joy15","Joy16","Joy17","Joy18","Joy19","Joy2","Joy20","Joy21","Joy22","Joy23","Joy24"
    , "Joy25","Joy26","Joy27","Joy28","Joy29","Joy3","Joy30","Joy31","Joy32","Joy4","Joy5","Joy6","Joy7","Joy8","Joy9"
    , "JoyAxes","JoyButtons","JoyInfo","JoyName","JoyPOV","JoyR","JoyU","JoyV","JoyX","JoyY","JoyZ","LAlt","Launch_App1"
    , "Launch_App2","Launch_Mail","Launch_Media","LButton","LControl","LCtrl","Left","LShift","LWin","LWinDown","LWinUp"
    , "MButton","Media_Next","Media_Play_Pause","Media_Prev","Media_Stop","NumLock","Numpad0","Numpad1","Numpad2"
    , "Numpad3","Numpad4","Numpad5","Numpad6","Numpad7","Numpad8","Numpad9","NumpadAdd","NumpadClear","NumpadDel"
    , "NumpadDiv","NumpadDot","NumpadDown","NumpadEnd","NumpadEnter","NumpadHome","NumpadIns","NumpadLeft","NumpadMult"
    , "NumpadPgdn","NumpadPgup","NumpadRight","NumpadSub","NumpadUp","Pause","PGDN","PGUP","PrintScreen","RAlt","RButton"
    , "RControl","RCtrl","Right","RShift","RWin","RWinDown","RWinUp","ScrollLock","Shift","ShiftDown","ShiftUp","Space"
    , "Tab","Up","Volume_Down","Volume_Mute","Volume_Up","WheelDown","WheelLeft","WheelRight","WheelUp","XButton1"
    , "XButton2"]
for key, val in Keys
    TempClip := RegExReplace(TempClip, "i)(?<!#)(?<!A_)(?<!\.)\b(" val ")\b"
    , "[url=http://ahkscript.org/docs/KeyList.htm][color=#" C["KEY"] "]$1[/color][/url]")

; Gui commands
GuiCmd := ["Add","Cancel","Default","Destroy","Flash","Font","GuiClose","GuiContextMenu","GuiDropFiles","GuiEscape","GuiSize"
    , "Margin","New","Show","Submit"]   ;"Menu","Color"
for key, val in GuiCmd
    TempClip := RegExReplace(TempClip, "i)(?<!/)\b(" val ")(?!=)\b"
    , "[url=http://ahkscript.org/docs/commands/Gui.htm#" val "][color=#" C["CMD"] "]$1[/color][/url]")

Str := ["StrPut","StrGet"]
for key, val in Str
    TempClip := RegExReplace(TempClip, "i)\b(" val ")(?=\()\b"
    , "[url=http://ahkscript.org/docs/commands/StrPutGet.htm][color=#" C["FUN"] "]$1[/color][/url]")

; IfWinActive (directive)
WinA := ["IfWinActive","IfWinExist","IfWinNotActive","IfWinNotExist"]
for key, val in WinA
    TempClip := RegExReplace(TempClip, "i)(#)\b(" val ")\b"
    , "[url=http://ahkscript.org/docs/commands/_IfWinActive.htm][color=#" C["DRT"] "]$1$2[/color][/url]")

; Include (directive)
Incl := ["Include","IncludeAgain"]
for key, val in Incl
    TempClip := RegExReplace(TempClip, "i)(#)\b(" val ")\b"
    , "[url=http://ahkscript.org/docs/commands/_Include.htm][color=#" C["DRT"] "]$1$2[/color][/url]")

; Object methods
ObjMethods := ["Clone","GetAddress","GetCapacity","HasKey","Insert","Remove","SetCapacity"]
for key, val in ObjMethods
    TempClip := RegExReplace(TempClip, "i)\.\K(" val ")(?=\()"
    , "[url=http://ahkscript.org/docs/objects/Object.htm#" val "][color=#" C["FUN"] "]$1[/color][/url]")

ObjMethods := ["MinIndex","MaxIndex"]
for key, val in ObjMethods
    TempClip := RegExReplace(TempClip, "i)\.\K(" val ")(?=\()"
    , "[url=http://ahkscript.org/docs/objects/Object.htm#MinMaxIndex][color=#" C["FUN"] "]$1[/color][/url]")

; _NewEnum
TempClip := RegExReplace(TempClip, "i)\.\K(_NewEnum)(?=\()"
, "[url=http://ahkscript.org/docs/objects/Object.htm#NewEnum][color=#" C["FUN"] "]$1[/color][/url]")

WinA2 := ["IfWinActive","IfWinNotActive"]
for key, val in WinA2
    TempClip := RegExReplace(TempClip, "i)(?<!#)\b(" val ")\b"
    , "[url=http://ahkscript.org/docs/commands/IfWinActive.htm][color=#" C["KWD"] "]$1[/color][/url]")

WinEx := ["IfWinExist","IfWinNotExist"]
for key, val in WinEx
    TempClip := RegExReplace(TempClip, "i)(?<!#)\b(" val ")\b"
    , "[url=http://ahkscript.org/docs/commands/IfWinExist.htm][color=#" C["KWD"] "]$1[/color][/url]")

Send := ["Send","SendEvent","SendInput","SendPlay","SendRaw"]
for key, val in Send
    TempClip := RegExReplace(TempClip, "i)\b(" val ")\b"
    , "[url=http://ahkscript.org/docs/commands/Send.htm][color=#" C["CMD"] "]$1[/color][/url]")

LRTrim := ["LTrim", "RTrim"]
for key, val in LRTrim
    TempClip := RegExReplace(TempClip, "i)(?<!/)\b(?<![_#])(" val ")(?=\()\b(?!])"
    , "[url=http://ahkscript.org/docs/commands/Trim.htm][color=#" C["FUN"] "]" val "[/color][/url]")

; Parse
TempClip := RegExReplace(TempClip, "i)\b(Parse)\b"
, "[url=http://ahkscript.org/docs/commands/LoopParse.htm][color=#" C["CMD"] "]$1[/color][/url]")

; Read
TempClip := RegExReplace(TempClip, "i)\b(Read)\b"
, "[url=http://ahkscript.org/docs/commands/LoopReadFile.htm][color=#" C["CMD"] "]$1[/color][/url]")

; Clipboard
TempClip := RegExReplace(TempClip, "i)\b(Clipboard)\b"
, "[url=http://ahkscript.org/docs/misc/Clipboard.htm][color=#" C["BIV"] "]$1[/color][/url]")

; ClipboardAll
TempClip := RegExReplace(TempClip, "i)\b(ClipboardAll)\b"
, "[url=http://ahkscript.org/docs/misc/Clipboard.htm#ClipboardAll][color=#" C["BIV"] "]$1[/color][/url]")

; Reinsert multi line comments
for key, val in MultiLine
    TempClip := RegExReplace(TempClip, "`r`n<<<_MultiLinePlaceholder_>>>`r`n"
    , "[color=#" C["MLC"] "]" val "[/color]", , 1)

; Reinsert strings
for key, val in Quoted
    TempClip := RegExReplace(TempClip, "`r`n<<<_QuotedPlaceholder_>>>`r`n"
    , "[color=#" C["STR"] "]" val "[/color]", , 1)

; Reinsert single line comments
for key, val in Comments
    TempClip := RegExReplace(TempClip, "`r`n<<<_CommentPlaceholder_>>>`r`n"
    , "[color=#" C["SLC"] "]" val "[/color]", , 1)

; Maintian existing tabs(tabs must be replaced with spaces or they will be lost when pasted into the website)
TempClip := RegExReplace(TempClip, "(\t)"
, "    ")

; Maintain double newlines
TempClip := RegExReplace(TempClip, "[^\R]\K\r?\n\r?\n"
, "`r`n`r`n`r`n")

; Backreferences
StringReplace, TempClip, TempClip, <<<_BRPlaceholder_>>>, $, All

; Meta options. Additional font and styling tags
TempClip := (MO.SP ? "[spoiler]"  : "")
          . (MO.QB ? "[quote]"    : "")
          . "[color=#" C.NHT "]"
          . (MO.HR ? "[hr]"       : "")
          . (MO.B  ? "[b]"        : "")
          . "[font=courier new,courier,monospace]"
          . TempClip
          . "[/font]"
          . (MO.B  ? "[/b]"       : "")
          . (MO.HR ? "[hr]"       : "")
          . "[/color]"
          . (MO.QB ? "[/quote]"   : "")
          . (MO.SP ? "[/spoiler]" : "")

Clipboard := TempClip
ClipWait, 10
ExitApp

Esc::ExitApp

Options(MO) {
    static B, HR, PCU, QB, SP
    Gui, +LastFound
    Gui, Margin, 10, 10
    Gui, Font, s10 bold
    Gui, Add, Checkbox, % "x10 vB " (MO.B ? "Checked" : ""), Bold Text
    Gui, Add, Checkbox, % "vHR " (MO.HR ? "Checked" : ""), Horizontal Rule
    Gui, Add, Checkbox, % "vPCU " (MO.PCU ? "Checked" : ""), Enclose "http://" In [c][/c]
    Gui, Add, Checkbox, % "vQB " (MO.QB ? "Checked" : ""), Quote Box
    Gui, Add, Checkbox, % "vSP " (MO.SP ? "Checked" : ""), Spoiler
    GuiControlGet, PCU, Pos
    Gui, Add, Button,  w%PCUW% Default, OK
    Gui, -Caption
    Gui, +Owner
    Gui, Show
    WinSet AlwaysOnTop
    Pause
    Gui, Submit
    for key, val in MO
        MO[key] := %key%
    return
   
    ButtonOK:
  Pause, Off
    return
}