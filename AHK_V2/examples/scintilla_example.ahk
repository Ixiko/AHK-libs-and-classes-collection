; AHK v2
; ====================================================================
; Example
; ====================================================================

#Include scintilla.ahk

(Scintilla) ; Init class, or simply #INCLUDE the extension-lib at the top.

g := Gui("+Resize +E0x2000000 0x2000000","Scintilla Test")
g.OnEvent("Close",gui_close)
g.OnEvent("Escape",gui_close)
g.OnEvent("Size",gui_size)

a := 1, b := 2
if (1=0)
    WinActive("ahk_id " b)


ctl := g.AddScintilla("vMyScintilla w1000 h500 DefaultOpt DefaultTheme")

ctl.CaseSense := false ; turn off case sense (for AHK), do this before setting keywords

kw1 := "Else If Continue Critical Break Goto Return Loop Read Reg Parse Files Switch Try Catch Finally Throw Until While For Exit ExitApp OnError OnExit Reload Suspend Thread"

kw2 := "Abs ASin ACos ATan BlockInput Buffer CallbackCreate CallbackFree CaretGetPos Ceil Chr Click ClipboardAll ClipWait ComCall ComObjActive ComObjArray ComObjConnect ComObject ComObjFlags ComObjFromPtr ComObjGet ComObjQuery ComObjType ComObjValue ComValue ControlAddItem ControlChooseIndex ControlChooseString ControlClick ControlDeleteItem ControlFindItem ControlFocus ControlGetChecked ControlGetChoice ControlGetClassNN ControlGetEnabled ControlGetFocus ControlGetHwnd ControlGetIndex ControlGetItems ControlGetPos ControlGetStyle ControlGetExStyle ControlGetText ControlGetVisible ControlHide ControlHideDropDown ControlMove ControlSend ControlSendText ControlSetChecked ControlSetEnabled ControlSetStyle ControlSetExStyle ControlSetText ControlShow ControlShowDropDown CoordMode Cos DateAdd DateDiff DetectHiddenText DetectHiddenWindows DirCopy DirCreate DirDelete DirExist DirMove DirSelect DllCall Download DriveEject DriveGetCapacity DriveGetFileSystem DriveGetLabel DriveGetList DriveGetSerial DriveGetSpaceFree DriveGetStatus DriveGetStatusCD DriveGetType DriveLock DriveRetract DriveSetLabel DriveUnlock Edit EditGetCurrentCol EditGetCurrentLine EditGetLine EditGetLineCount EditGetSelectedText EditPaste EnvGet EnvSet Exp FileAppend FileCopy FileCreateShortcut FileDelete FileEncoding FileExist FileInstall FileGetAttrib FileGetShortcut FileGetSize FileGetTime FileGetVersion FileMove FileOpen FileRead FileRecycle FileRecycleEmpty FileSelect FileSetAttrib FileSetTime Float Floor Format FormatTime GetKeyName GetKeyVK GetKeySC GetKeyState GetMethod GroupAdd GroupClose GroupDeactivate Gui GuiCtrlFromHwnd GuiFromHwnd HasBase HasMethod HasProp HotIf HotIfWinActive HotIfWinExist HotIfWinNotActive HotIfWinNotExist Hotkey Hotstring IL_Create IL_Add IL_Destroy ImageSearch IniDelete IniRead IniWrite InputBox InputHook InstallKeybdHook InstallMouseHook InStr Integer IsLabel IsObject IsSet IsSetRef KeyHistory KeyWait ListHotkeys ListLines ListVars ListViewGetContent LoadPicture Log Ln Map Max MenuBar Menu MenuFromHandle MenuSelect Min Mod MonitorGet MonitorGetCount MonitorGetName MonitorGetPrimary MonitorGetWorkArea MouseClick MouseClickDrag MouseGetPos MouseMove MsgBox Number NumGet NumPut ObjAddRef ObjRelease ObjBindMethod ObjHasOwnProp ObjOwnProps ObjGetBase ObjGetCapacity ObjOwnPropCount ObjSetBase ObjSetCapacity OnClipboardChange OnMessage Ord OutputDebug Pause Persistent PixelGetColor PixelSearch PostMessage ProcessClose ProcessExist ProcessSetPriority ProcessWait ProcessWaitClose Random RegExMatch RegExReplace RegDelete RegDeleteKey RegRead RegWrite Round Run RunAs RunWait Send SendText SendInput SendPlay SendEvent SendLevel SendMessage SendMode SetCapsLockState SetControlDelay SetDefaultMouseSpeed SetKeyDelay SetMouseDelay SetNumLockState SetScrollLockState SetRegView SetStoreCapsLockMode SetTimer SetTitleMatchMode SetWinDelay SetWorkingDir Shutdown Sin Sleep Sort SoundBeep SoundGetInterface SoundGetMute SoundGetName SoundGetVolume SoundPlay SoundSetMute SoundSetVolume SplitPath Sqrt StatusBarGetText StatusBarWait StrCompare StrGet String StrLen StrLower StrPut StrReplace StrSplit StrUpper SubStr SysGet SysGetIPAddresses Tan ToolTip TraySetIcon TrayTip Trim LTrim RTrim Type VarSetStrCapacity VerCompare WinActivate WinActivateBottom WinActive WinClose WinExist WinGetClass WinGetClientPos WinGetControls WinGetControlsHwnd WinGetCount WinGetID WinGetIDLast WinGetList WinGetMinMax WinGetPID WinGetPos WinGetProcessName WinGetProcessPath WinGetStyle WinGetExStyle WinGetText WinGetTitle WinGetTransColor WinGetTransparent WinHide WinKill WinMaximize WinMinimize WinMinimizeAll WinMinimizeAllUndo WinMove WinMoveBottom WinMoveTop WinRedraw WinRestore WinSetAlwaysOnTop WinSetEnabled WinSetRegion WinSetStyle WinSetExStyle WinSetTitle WinSetTransColor WinSetTransparent WinShow WinWait WinWaitActive WinWaitNotActive WinWaitClose"

kw3 := "Add AddActiveX AddButton AddCheckbox AddComboBox AddCustom AddDateTime AddDropDownList AddEdit AddGroupBox AddHotkey AddLink AddListBox AddListView AddMonthCal AddPicture AddProgress AddRadio AddSlider AddStandard AddStatusBar AddTab AddText AddTreeView AddUpDown Bind Check Choose Clear Clone Close Count DefineMethod DefineProp Delete DeleteCol DeleteMethod DeleteProp Destroy Disable Enable Flash Focus Get GetAddress GetCapacity GetChild GetClientPos GetCount GetNext GetOwnPropDesc GetParent GetPos GetPrev GetSelection GetText Has HasKey HasOwnMethod HasOwnProp Hide Insert InsertAt InsertCol Len Mark Maximize MaxIndex Minimize MinIndex Modify ModifyCol Move Name OnCommand OnEvent OnNotify Opt OwnMethods OwnProps Pop Pos Push RawRead RawWrite Read ReadLine ReadUInt ReadInt ReadInt64 ReadShort ReadUShort ReadChar ReadUChar ReadDouble ReadFloat Redraw RemoveAt Rename Restore Seek Set SetCapacity SetColor SetFont SetIcon SetImageList SetParts SetText Show Submit Tell ToggleCheck ToggleEnable Uncheck UseTab Write WriteLine WriteUInt WriteInt WriteInt64 WriteShort WriteUShort WriteChar WriteUChar WriteDouble WriteFloat"

kw4 := "AtEOF BackColor Base Capacity CaseSense ClassNN ClickCount Count Default Enabled Encoding Focused FocusedCtrl Gui Handle Hwnd Length MarginX MarginY MenuBar Name Pos Position Ptr Size Text Title Value Visible __Handle"

kw5 := "A_Space A_Tab A_Args A_WorkingDir A_InitialWorkingDir A_ScriptDir A_ScriptName A_ScriptFullPath A_ScriptHwnd A_LineNumber A_LineFile A_ThisFunc A_AhkVersion A_AhkPath A_IsCompiled A_YYYY A_MM A_DD A_MMMM A_MMM A_DDDD A_DDD A_WDay A_YDay A_YWeek A_Hour A_Min A_Sec A_MSec A_Now A_NowUTC A_TickCount A_IsSuspended A_IsPaused A_IsCritical A_ListLines A_TitleMatchMode A_TitleMatchModeSpeed A_DetectHiddenWindows A_DetectHiddenText A_FileEncoding A_SendMode A_SendLevel A_StoreCapsLockMode A_KeyDelay A_KeyDuration A_KeyDelayPlay A_KeyDurationPlay A_WinDelay A_ControlDelay A_MouseDelay A_MouseDelayPlay A_DefaultMouseSpeed A_CoordModeToolTip A_CoordModePixel A_CoordModeMouse A_CoordModeCaret A_CoordModeMenu A_RegView A_TrayMenu A_AllowMainWindow A_AllowMainWindow A_IconHidden A_IconTip A_IconFile A_IconNumber A_TimeIdle A_TimeIdlePhysical A_TimeIdleKeyboard A_TimeIdleMouse A_ThisHotkey A_PriorHotkey A_PriorKey A_TimeSinceThisHotkey A_TimeSincePriorHotkey A_EndChar A_EndChar A_MaxHotkeysPerInterval A_HotkeyInterval A_HotkeyModifierTimeout A_ComSpec A_Temp A_OSVersion A_Is64bitOS A_PtrSize A_Language A_ComputerName A_UserName A_WinDir A_ProgramFiles A_AppData A_AppDataCommon A_Desktop A_DesktopCommon A_StartMenu A_StartMenuCommon A_Programs A_ProgramsCommon A_Startup A_StartupCommon A_MyDocuments A_IsAdmin A_ScreenWidth A_ScreenHeight A_ScreenDPI A_Clipboard A_Cursor A_EventInfo A_LastError True False A_Index A_LoopFileName A_LoopRegName A_LoopReadLine A_LoopField this"

kw6 := "#ClipboardTimeout #DllLoad #ErrorStdOut #Hotstring #HotIf #HotIfTimeout #Include #IncludeAgain #InputLevel #MaxThreads #MaxThreadsBuffer #MaxThreadsPerHotkey #NoTrayIcon #Requires #SingleInstance #SuspendExempt #UseHook #Warn #WinActivateForce #If"

kw7 := "Global Local Static"


ctl.setKeywords(kw1, kw2, kw3, kw4, kw5, kw6, kw7)


; ======================================================================

; ctl.UseDirect := true ; the DLL uses the Direct Ptr for now
; ctl.Wrap.LayoutCache := 3 ; speeds up window resize on large docs, but sometimes causes slower load times on large documents
; ======================================================================
; items that should be set by the user
; ======================================================================
ctl.Brace.Chars := "[]{}()" ; modify braces list that will be tracked
ctl.SyntaxEscapeChar := "``" ; set this to "\" to load up CustomLexer.c, or to "``" to load an AHK script.
ctl.SyntaxCommentLine := ";" ; set this to "//" to load up CustomLexer.c, or to ";" to load an AHK script.

; ======================================================================
; Setting DLL punct and word chars:
;
; Below are the defaults for punct and word chars for the DLL.  Setting
; punct and word chars for Scintilla has a different purpose and a 
; slightly different effect.  It's also kinda of squirrely.  Since it is
; possible to use a direct pointer to parse Scintilla text I leave the
; Scintilla defaults for punct and word chars alone.
;
; You'll notice that the punct defaults also contain braces, escape
; chars, and of course " and '.  The search for punct chars happens 
; after searching for those other elements, and thus doesn't affect
; how braces, strings, and escape chars function.
;
; For WordChars, since a variable or function must normally start with
; a letter or underscore, only specify letters and underscore/pound sign
; if desired.  Matching for digits in a "word" is done separately assuming
; the first character of the "word" is not a digit.
; ======================================================================
; ctl.SyntaxPunctChars := "!`"$%&'()*+,-./:;<=>?@[\]^``{|}~"                      ; this is the default
; ctl.SyntaxWordChars := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_#" ; this is the default

; ======================================================================
; Simple to apply vertical colored lines at specified column - uncomment to test
; ======================================================================
; ctl.Edge.Mode := 3 ; vertical lines - handy!
; ctl.Edge.Multi.Add(5,0xFF0000)
; ctl.Edge.Multi.Add(10,0x00FF00)
; ctl.Edge.Multi.Add(15,0x0000FF)
; ctl.Edge.View := 1

; ======================================================================
; To see white space/CRLF/other special non-printing chars
; ======================================================================
; ctl.WhiteSpace.View := 1
; ctl.LineEnding.View := 1
; ======================================================================

ctl.callback := ctl_callback ; this doesn't do anything for now
ctl.CustomSyntaxHighlighting := true ; turns syntax highlighting on
ctl.AutoSizeNumberMargin := true
; ctl.Target.Flags := Scintilla.sc_search.RegXP | Scintilla.sc_search.CXX11RegEx ; CXX11RegEx | POSIX

; ======================================================================

; ctl.Styling.Idle := 3 ; do NOT set this when using my syntax highlighting.  My syntax highlighting works differently.

; ======================================================================
; Set this to prevent unnecessary parsing and improve load time.  While
; editing the document additional parsing must happen in order to
; properly color the various elements of the document correctly when
; adding/deleting/uncommenting text.  This value will automatically be
; set to 0 after loading a document.
; ======================================================================
ctl.loading := 1



; sFile := A_ScriptDir "\CustomLexer.c" ; C source for CustomLexer.dll
sFile := A_ScriptDir "\" A_ScriptName ; this script
; sFile := "test-script.ahk" ; 2.16 MB

size := FileGetSize(sFile)
ptr := ctl.Doc.Create(size+100)
ctl.Doc.ptr := ptr
ctl.Text := FileRead(sFile)

; ======================================================================
; These must usually be set after changing document ptr.
; ======================================================================
ctl.Tab.Use := false ; use spaces instad of tabs
ctl.Tab.Width := 4 ; number of spaces for a tab

; ======================================================================
; show GUI
; ======================================================================
g.Show()

ctl.CurPos := 0 ; move to the beginning of the document

ctl_callback(ctl, scn) { ; callback for wm_notify messages
    ; do user stuff
}

gui_size(g, minMax, w, h) {
    ctl := g["MyScintilla"] ; test
    ctl.Move(,,w-(g.MarginX * 2), h-(g.MarginY * 2))
}

gui_close(*) {
    ExitApp
}

F2::{
    global ctl
    
    msgbox ctl.CurPos " / style: " ctl.GetStyle(ctl.curPos) " / lines on screen: " ctl.LinesOnScreen
}

F3::{
    global ctl
    
    ; msgbox ctl.GetChar(ctl.CurPos)
    msgbox ctl.LineLength() "`n`n" ctl.LineText()
    
    ; msgbox "curPos: " ctl.curPos " / match: " ctl.Brace.Match(ctl.curPos) " / last style: " ctl.Styling.Last
}

F4::{
    ExitApp
}

g := Gui("+Resize +E0x2000000 0x2000000","Scintilla Test")