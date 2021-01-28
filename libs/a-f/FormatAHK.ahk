FormatAHK(ByRef fnText,fnAllowFormatAlterationsAhk := 0) {

	; function description
	; MsgBox fnText: %fnText%`nfnAllowFormatAlterationsAhk: %fnAllowFormatAlterationsAhk%


	; declare local, global, static variables


	Try
	{
		; set default return value
		ReturnValue := 0 ; success


		; validate parameters
		If !fnText
			Return ReturnValue


		; initialise variables
		BareKeywords =
		( LTrim Join, Comments
			.__Handle,.AtEOF,.Encoding,.Name,.Pos,.Position
			Add,Alt
			ByRef
			Check,Click,Comment,Comments,Ctrl
			Default,DeleteAll
			Edit,Else,EnvUpdate
			Files,Finally,For
			GetKeyState,Global
			If
			Join
			KeyHistory
			ListHotkeys,ListVars,Local,Loop,LWin
			NoStandard
			Off,On,OnExit
			Parse
			Read,Reg,Reload,Return,RWin
			Send,SendEvent,SendInput,SendMode,SendPlay,SendRaw,Shift,SplashTextOff,Standard,Static
			Tip,Tray,Try
			Uncheck,Until
			While,Win,WinMinimizeAll,WinMinimizeAllUndo
		)

		KeyNames =
		( LTrim Join, Comments
			{ASC,{Alt,{AppsKey
			{Backspace,{Blind,{Browser_Back,{Browser_Favorites,{Browser_Forward,{Browser_Home,{Browser_Refresh,{Browser_Search,{Browser_Stop
			{CapsLock,{Click,{Control,{CtrlBreak
			{Delete,{Down
			{End,{Enter,{Escape
			{Home
			{Insert
			{LAlt,{Launch_App1,{Launch_App2,{Launch_Mail,{Launch_Media,{LControl,{Left,{LShift,{LWin
			{Media_Next,{Media_Play_Pause,{Media_Prev,{Media_Stop
			{NumLock,{Numpad0,{NumpadAdd,{NumpadClear,{NumpadDel,{NumpadDiv,{NumpadDot,{NumpadDown,{NumpadEnd,{NumpadEnter,{NumpadHome,{NumpadIns,{NumpadLeft,{NumpadMult,{NumpadPgDn,{NumpadPgUp,{NumpadRight,{NumpadSub,{NumpadUp
			{Pause,{PgDn,{PgUp,{PrintScreen
			{RAlt,{Raw,{RControl,{Right,{RShift,{RWin
			{ScrollLock,{Shift,{Sleep,{Space
			{Tab
			{Up
			{Volume_Down,{Volume_Mute,{Volume_Up
			{WheelDown
		)

		CommaAllowedKeywords =
		( LTrim Join, Comments
			Break
			Catch,ClipWait,Continue,ControlClick,ControlFocus,ControlGetPos,ControlSend,ControlSendRaw,ControlSetText,Critical
			Exit,ExitApp
			FileEncoding,FileRecycleEmpty,FileSetTime
			IfWinActive,IfWinExist,IfWinNotActive,IfWinNotExist,Input
			ListLines
			MouseClick,MsgBox
			Pause
			RunAs
			SetCapsLockState,SetKeyDelay,SetNumLockState,SetScrollLockState,SetTimer,SoundBeep,SplashImage,SplashTextOn,StatusBarWait,Suspend
			Throw,ToolTip,TrayTip
			WinActivate,WinActivateBottom,WinClose,WinGetPos,WinHide,WinKill,WinMaximize,WinMinimize,WinRestore,WinShow,WinWait,WinWaitActive,WinWaitClose,WinWaitNotActive
		)

		CommaNeededKeywords =
		( LTrim Join, Comments
			AutoTrim
			BlockInput
			Control,ControlGet,ControlGetFocus,ControlGetText,ControlMove,CoordMode
			DetectHiddenText,DetectHiddenWindows,Drive,DriveGet,DriveSpaceFree
			EnvAdd,EnvDiv,EnvGet,EnvMult,EnvSet,EnvSub
			FileAppend,FileCopy,FileCopyDir,FileCreateDir,FileCreateShortcut,FileDelete,FileGetAttrib,FileGetShortcut,FileGetSize,FileGetTime,FileGetVersion,FileInstall,FileMove,FileMoveDir,FileRead,FileReadLine,FileRecycle,FileRemoveDir,FileSelectFile,FileSelectFolder,FileSetAttrib,FormatTime
			Gosub,Goto,GroupActivate,GroupAdd,GroupClose,GroupDeactivate,Gui,GuiControl,GuiControlGet
			Hotkey
			IfEqual,IfExist,IfGreater,IfGreaterOrEqual,IfInString,IfLess,IfLessOrEqual,IfMsgBox,IfNotEqual,IfNotExist,IfNotInString,ImageSearch,IniDelete,IniRead,IniWrite,InputBox
			KeyWait
			Menu,MouseClickDrag,MouseGetPos,MouseMove
			OutputDebug
			PixelGetColor,PixelSearch,PostMessage,Process,Progress
			Random,RegDelete,RegRead,RegWrite,Run,RunWait
			SendLevel,SendMessage,SetBatchLines,SetControlDelay,SetDefaultMouseSpeed,SetEnv,SetFormat,SetMouseDelay,SetRegView,SetStoreCapslockMode,SetTitleMatchMode,SetWinDelay,SetWorkingDir,Shutdown,Sleep,Sort,SoundGet,SoundGetWaveVolume,SoundPlay,SoundSet,SoundSetWaveVolume,SplitPath,StatusBarGetText,StringCaseSense,StringGetPos,StringLeft,StringLen,StringLower,StringMid,StringReplace,StringRight,StringSplit,StringTrimLeft,StringTrimRight,StringUpper,SysGet
			Thread,Transform
			UrlDownloadToFile
			WinGet,WinGetActiveStats,WinGetActiveTitle,WinGetClass,WinGetText,WinGetTitle,WinMenuSelectItem,WinMove,WinSet,WinSetTitle
		)

		ParenNeededKeywords =
		( LTrim Join, Comments
			._NewEnum
			.Bind
			.Call,.Clone,.Close
			.Delete
			.GetAddress,.GetCapacity
			.HasKey
			.Insert,.InsertAt,.IsBuiltIn,.IsByRef,.IsOptional,.IsVariadic
			.Length
			.MaxIndex,.MaxParams,.MinIndex
			.MinParams
			.Next
			.Pop,.Push
			.RawRead,.RawWrite,.Read,.ReadChar,.ReadDouble,.ReadFloat,.ReadInt,.ReadInt64,.ReadLine,.ReadShort,.ReadUChar,.ReadUInt,.ReadUShort,.Remove,.RemoveAt
			.Seek,.SetCapacity
			.Tell,.Write,.WriteChar,.WriteDouble,.WriteFloat,.WriteInt,.WriteInt64,.WriteLine,.WriteLine,.WriteShort,.WriteUChar,.WriteUInt,.WriteUShort
			Abs,ACos,Asc,ASin,ATan
			Ceil
			Chr,ComObjActive,ComObjArray,ComObjConnect,ComObjCreate,ComObjEnwrap,ComObjError,ComObjFlags,ComObjGet,ComObjMissing,ComObjParameter,ComObjQuery,ComObjType,ComObjValue,Cos
			DllCall
			Exception,Exp
			FileExist,FileOpen,Floor,Format,Func
			GetKeyName,GetKeySC,GetKeyVK,GuiClose,GuiContextMenu
			IL_Add,IL_Create,IL_Destroy,InStr,IsByRef,IsFunc,IsLabel,IsObject
			Ln,LoadPicture,Log,LTrim,LV_Add,LV_Delete,LV_DeleteCol,LV_GetCount,LV_GetNext,LV_GetText,LV_Insert,LV_InsertCol,LV_Modify,LV_ModifyCol,LV_SetImageList
			MenuGetHandle,MenuGetName,Mod
			NumGet,NumPut
			ObjAddRef,ObjBindMethod,ObjRawSet,ObjRelease,OnMessage,Ord
			RegExMatch,RegExReplace,RegisterCallback,Round,RTrim
			SB_SetIcon,SB_SetParts,SB_SetProgress,SB_SetText,Sin,Sqrt,StrGet,StrLen,StrPut,StrReplace,StrSplit,SubStr
			Tan,Trim,TV_Add,TV_Delete,TV_Get,TV_GetChild,TV_GetCount,TV_GetNext,TV_GetParent,TV_GetPrev,TV_GetSelection,TV_GetText,TV_Modify,TV_SetImageList
			VarSetCapacity
			WinActive,WinExist
		)

		BuiltInVariablesList =
		( LTrim Join, Comments
			A_AhkPath,A_AhkVersion,A_AppData,A_AppDataCommon,A_AutoTrim
			A_BatchLines
			A_CaretX,A_CaretY,A_ComputerName,A_ControlDelay,A_CoordModeCaret,A_CoordModeMenu,A_CoordModeMouse,A_CoordModePixel,A_CoordModeToolTip,A_Cursor
			; A_ComSpec
			A_DD,A_DDD,A_DDDD,A_DefaultGui,A_DefaultListView,A_DefaultMouseSpeed,A_DefaultTreeView,A_Desktop,A_DesktopCommon,A_DetectHiddenText,A_DetectHiddenWindows
			A_EndChar,A_EventInfo,A_ExitReason
			A_FileEncoding,A_FormatFloat,A_FormatInteger
			A_Gui,A_GuiControl,A_GuiEvent,A_GuiHeight,A_GuiWidth,A_GuiX,A_GuiY
			A_Hour
			A_IconFile,A_IconHidden,A_IconNumber,A_IconTip,A_Index,A_IPAddress1,A_Is64bitOS,A_IsAdmin,A_IsCompiled,A_IsCritical,A_IsPaused,A_IsSuspended,A_IsUnicode
			A_KeyDelay,A_KeyDelayPlay,A_KeyDuration,A_KeyDurationPlay
			A_Language,A_LastError,A_LineFile,A_LineNumber,A_LoopField,A_LoopFileExt,A_LoopFileName,A_LoopReadLine,A_LoopRegName
			A_Min,A_MM,A_MMM,A_MMMM,A_MouseDelay,A_MouseDelayPlay,A_MSec,A_MyDocuments
			A_Now,A_NowUTC
			A_OSType,A_OSVersion
			A_PriorHotkey,A_PriorKey,A_ProgramFiles,A_Programs,A_ProgramsCommon,A_PtrSize
			A_RegView
			A_ScreenDPI,A_ScreenHeight,A_ScreenWidth,A_ScriptDir,A_ScriptFullPath,A_ScriptHwnd,A_ScriptName,A_Sec,A_SendLevel,A_SendMode,A_Space,A_StartMenu,A_StartMenuCommon,A_Startup,A_StartupCommon,A_StoreCapslockMode,A_StringCaseSense
			A_Tab,A_Temp,A_ThisFunc,A_ThisHotkey,A_ThisLabel,A_ThisMenu,A_ThisMenuItem,A_ThisMenuItemPos,A_TickCount,A_TimeIdle,A_TimeIdlePhysical,A_TimeSincePriorHotkey,A_TimeSinceThisHotkey,A_TitleMatchMode,A_TitleMatchModeSpeed
			A_UserName
			A_WDay,A_WinDelay,A_WinDir,A_WorkingDir
			A_YDay,A_YWeek,A_YYYY
			ComSpec,Clipboard,ClipboardAll
			ErrorLevel
			false
			ProgramFiles
			true
		)

		DirectivesList =
		( LTrim Join, Comments
			; #AllowSameLineComments
			#ClipboardTimeout,#CommentFlag
			#Delimiter,#DerefChar
			#ErrorStdOut,#EscapeChar
			#HotkeyInterval,#HotkeyModifierTimeout,#Hotstring
			#If,#IfTimeout,#IfWinActive,#IfWinExist,#IfWinNotActive,#IfWinNotExist,#Include,#IncludeAgain,#InputLevel,#InstallKeybdHook,#InstallMouseHook
			#KeyHistory
			#LTrim
			#MaxHotkeysPerInterval,#MaxMem,#MaxThreads,#MaxThreadsBuffer,#MaxThreadsPerHotkey,#MenuMaskKey
			#NoEnv,#NoTrayIcon
			#Persistent
			#SingleInstance
			#UseHook
			#Warn,#WinActivateForce
		)

		WinTitleParams =
		( LTrim Join, Comments
			ahk_class
			ahk_exe
			ahk_group
			ahk_id
			ahk_pid
		)


		MessagesList =
		( LTrim Join, Comments
			WM_ACTIVATE,WM_ACTIVATEAPP,WM_APP,WM_ASKCBFORMATNAME
			WM_CANCELJOURNAL,WM_CANCELMODE,WM_CAPTURECHANGED,WM_CHANGECBCHAIN,WM_CHAR,WM_CHARTOITEM,WM_CHILDACTIVATE,WM_CLEAR,WM_CLOSE,WM_COALESCE_FIRST,WM_COALESCE_LAST,WM_COMMAND,WM_COMPACTING,WM_COMPAREITEM,WM_CONTEXTMENU,WM_COPY,WM_COPYDATA,WM_CREATE,WM_CTLCOLOR,WM_CTLCOLORBTN,WM_CTLCOLORDLG,WM_CTLCOLOREDIT,WM_CTLCOLORLISTBOX,WM_CTLCOLORMSGBOX,WM_CTLCOLORSCROLLBAR,WM_CTLCOLORSTATIC,WM_CUT
			WM_DDE_ACK,WM_DDE_ADVISE,WM_DDE_DATA,WM_DDE_EXECUTE,WM_DDE_FIRST,WM_DDE_INITIATE,WM_DDE_LAST,WM_DDE_POKE,WM_DDE_REQUEST,WM_DDE_TERMINATE,WM_DDE_UNADVISE,WM_DEADCHAR,WM_DELETEITEM,WM_DESTROY,WM_DESTROYCLIPBOARD,WM_DEVICECHANGE,WM_DEVMODECHANGE,WM_DISPLAYCHANGE,WM_DRAWCLIPBOARD,WM_DRAWITEM,WM_DROPFILES
			WM_ENABLE,WM_ENDSESSION,WM_ENTERIDLE,WM_ENTERMENULOOP,WM_ENTERSIZEMOVE,WM_ERASEBKGND,WM_EXITMENULOOP,WM_EXITSIZEMOVE
			WM_FONTCHANGE
			WM_GETDLGCODE,WM_GETFONT,WM_GETHOTKEY,WM_GETICON,WM_GETMINMAXINFO,WM_GETTEXT,WM_GETTEXTLENGTH
			WM_HANDHELDFIRST,WM_HANDHELDLAST,WM_HELP,WM_HOTKEY,WM_HSCROLL,WM_HSCROLLCLIPBOARD
			WM_ICONERASEBKGND,WM_IME_CHAR,WM_IME_COMPOSITION,WM_IME_COMPOSITIONFULL,WM_IME_CONTROL,WM_IME_ENDCOMPOSITION,WM_IME_KEYDOWN,WM_IME_KEYLAST,WM_IME_KEYUP,WM_IME_NOTIFY,WM_IME_SELECT,WM_IME_SETCONTEXT,WM_IME_STARTCOMPOSITION,WM_INITDIALOG,WM_INITMENU,WM_INITMENUPOPUP,WM_INPUTLANGCHANGE,WM_INPUTLANGCHANGEREQUEST
			WM_KEYDOWN,WM_KEYFIRST,WM_KEYLAST,WM_KEYUP,WM_KILLFOCUS
			WM_LBUTTONDBLCLK,WM_LBUTTONDOWN,WM_LBUTTONUP
			WM_MBUTTONDBLCLK,WM_MBUTTONDOWN,WM_MBUTTONUP,WM_MDIACTIVATE,WM_MDICASCADE,WM_MDICREATE,WM_MDIDESTROY,WM_MDIGETACTIVE,WM_MDIICONARRANGE,WM_MDIMAXIMIZE,WM_MDINEXT,WM_MDIREFRESHMENU,WM_MDIRESTORE,WM_MDISETMENU,WM_MDITILE,WM_MEASUREITEM,WM_MENUCHAR,WM_MENUSELECT,WM_MOUSEACTIVATE,WM_MOUSEFIRST,WM_MOUSEHOVER,WM_MOUSEHWHEEL,WM_MOUSELEAVE,WM_MOUSEMOVE,WM_MOUSEWHEEL,WM_MOVE,WM_MOVING
			WM_NCACTIVATE,WM_NCCALCSIZE,WM_NCCREATE,WM_NCDESTROY,WM_NCHITTEST,WM_NCLBUTTONDBLCLK,WM_NCLBUTTONDOWN,WM_NCLBUTTONUP,WM_NCMBUTTONDBLCLK,WM_NCMBUTTONDOWN,WM_NCMBUTTONUP,WM_NCMOUSELEAVE,WM_NCMOUSEMOVE,WM_NCPAINT,WM_NCRBUTTONDBLCLK,WM_NCRBUTTONDOWN,WM_NCRBUTTONUP,WM_NEXTDLGCTL,WM_NEXTMENU,WM_NOTIFY,WM_NOTIFYFORMAT,WM_NULL
			WM_PAINT,WM_PAINTCLIPBOARD,WM_PAINTICON,WM_PALETTECHANGED,WM_PALETTEISCHANGING,WM_PARENTNOTIFY,WM_PASTE,WM_PENWINFIRST,WM_PENWINLAST,WM_POWER,WM_POWERBROADCAST,WM_PRINT,WM_PRINTCLIENT
			WM_QUERYDRAGICON,WM_QUERYENDSESSION,WM_QUERYNEWPALETTE,WM_QUERYOPEN,WM_QUEUESYNC,WM_QUIT
			WM_RBUTTONDBLCLK,WM_RBUTTONDOWN,WM_RBUTTONUP,WM_RENDERALLFORMATS,WM_RENDERFORMAT
			WM_SETCURSOR,WM_SETFOCUS,WM_SETFONT,WM_SETHOTKEY,WM_SETICON,WM_SETREDRAW,WM_SETTEXT,WM_SETTINGCHANGE,WM_SHOWWINDOW,WM_SIZE,WM_SIZECLIPBOARD,WM_SIZING,WM_SPOOLERSTATUS,WM_STYLECHANGED,WM_STYLECHANGING,WM_SYSCHAR,WM_SYSCOLORCHANGE,WM_SYSCOMMAND,WM_SYSDEADCHAR,WM_SYSKEYDOWN,WM_SYSKEYUP,WM_SYSTEMERROR
			WM_TCARD,WM_TIMECHANGE,WM_TIMER
			WM_UNDO,WM_USER,WM_USERCHANGED
			WM_VKEYTOITEM,WM_VSCROLL,WM_VSCROLLCLIPBOARD
			WM_WINDOWPOSCHANGED,WM_WINDOWPOSCHANGING,WM_WININICHANGE
		)

		CustomList =
		( LTrim Join, Comments
			; {U+nnnn
			; {vk[0-9a-fA-F][0-9a-fA-F]
			; {scYYY
			; {vk[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]sc[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]
			Shell_TrayWnd
		)

		; complete list
		WordList =
		( LTrim Join, Comments
			%BareKeywords%
			%KeyNames%
			%CommaAllowedKeywords%
			%CommaNeededKeywords%
			%ParenNeededKeywords%
			%BuiltInVariablesList%
			%DirectivesList%
			%WinTitleParams%
			%MessagesList%
			%CustomList%
		)


		; prepare the text
		NormaliseLineEndings(fnText)
		NewText := fnText
		; FormatStoreStrings(NewText,"/*nf>*/","/*<nf*/","NoFormat")
		FormatStoreComments(NewText,";")
		FormatStoreStrings(NewText,"/*","*/","StreamComments")
		FormatStoreStrings(NewText,"""","DoubleQuotes")


		; loop through each word, replacing each instance with its correctly formatted version
		Loop, Parse, WordList, CSV
		{
			Word   := A_LoopField
			Word1  := SubStr(Word,1,1)
			If Word1 is not alnum
				PCRE := "[" Word1 "]\b" SubStr(Word,2)
			Else
				PCRE := "\b" Word
			PCRE   := "imS)" PCRE "\b"
			NewText := RegExReplace(NewText,PCRE,Word)
		}


		; additional formatting
		If fnAllowFormatAlterationsAhk
		{
			; GetKeyState
			PCRE   := "iS)\b(GetKeyState)\b(\s+)([(])"
			NewText := RegExReplace(NewText,PCRE,"$1$3")
			PCRE   := "iS)\b(GetKeyState)\b(\s*)(,)?(\s*)([^;(]+)"
			NewText := RegExReplace(NewText,PCRE,"$1, $5")

			; Loop
			PCRE   := "iS)\b(Loop)\b(?![\r\n])(\s*)(,)?(\s*+)([^{;\r\n])"
			NewText := RegExReplace(NewText,PCRE,"$1, $5")
			PCRE   := "iS)\b(Loop,)\b(\s*)(Reg|Files|Parse|Read)(\s*)(,)(\s*)"
			NewText := RegExReplace(NewText,PCRE,"$1 $T3, ")

			; OnClipboardChange:
			PCRE   := "iS)\b(OnClipboardChange)\b(\s+)([(:])"
			NewText := RegExReplace(NewText,PCRE,"$1$3")

			; OnExit
			PCRE   := "iS)\b(OnExit)\b(\s+)([(])"
			NewText := RegExReplace(NewText,PCRE,"$1$3")
			PCRE   := "iS)\b(OnExit)\b(?![\r\n])(\s*)(,)?(\s*+)([^;(])"
			NewText := RegExReplace(NewText,PCRE,"$1, $5")

			; CommaAllowedKeywords
			Loop, Parse, CommaAllowedKeywords, CSV
			{
				Word   := A_LoopField
				PCRE   := "iS)(?<!\*)(\b" Word "\b)(?![\r\n:])(\s*)(,)?(\s*+)([^;(,])"
				NewText := RegExReplace(NewText,PCRE,"$1, $5")
			}

			; CommaNeededKeywords
			Loop, Parse, CommaNeededKeywords, CSV
			{
				Word   := A_LoopField
				PCRE   := "iS)(\b" Word "\b)(?![\r\n:])(\s*)(,)?(\s*)([^\s,])"
				NewText := RegExReplace(NewText,PCRE,"$1, $5")
			}

			; ParenNeededKeywords
			Loop, Parse, ParenNeededKeywords, CSV
			{
				Word   := A_LoopField
				PCRE   := "iS)(\b" Word "\b)(?![\r\n:])(\s+)([(])"
				NewText := RegExReplace(NewText,PCRE,"$1$3")
			}

			PCRE   := "S)([^:\s])(:=)([^=\s])"
			NewText := RegExReplace(NewText,PCRE,"$1 $2 $3") ; space around :=

			TotalCountOfReplacements := 1 ; just to force entry into while loop
			While TotalCountOfReplacements > 0
			{
				PCRE   := "xiS) ([(].*?) ([,][ ]) (.*[)])" ; comma-space between brackets
				NewText := RegExReplace(NewText,PCRE,"$1,$3",CountOfReplacements)
				TotalCountOfReplacements := CountOfReplacements

				PCRE   := "xiS) ([(].*?) ([ ][,]) (.*[)])" ; space-comma between brackets
				NewText := RegExReplace(NewText,PCRE,"$1,$3",CountOfReplacements)
				TotalCountOfReplacements += CountOfReplacements
			}

			TotalCountOfReplacements := 1 ; force entry into while loop
			While TotalCountOfReplacements > 0
			{
				PCRE   := "xiS) [(][ ] (.*?) [)]" ; space after an opening bracket
				NewText := RegExReplace(NewText,PCRE,"($1)",CountOfReplacements)
				TotalCountOfReplacements := CountOfReplacements

				PCRE   := "xiS) [(] (.*?) [ ][)]" ; space before a closing bracket
				NewText := RegExReplace(NewText,PCRE,"($1)",CountOfReplacements)
				TotalCountOfReplacements += CountOfReplacements
			}

			; PCRE   := "imS)([ \t]*)([\+\-\*\/])([ \t]*)" ; whitespace around maths symbols
			; NewText := RegExReplace(NewText,PCRE,"$2")
		}


		; restore comments and strings
		FormatRestoreStrings(NewText,"DoubleQuotes")
		FormatRestoreStrings(NewText,"StreamComments")
		FormatRestoreComments(NewText)
		; FormatRestoreStrings(NewText,"NoFormat")


		PCRE   := "imS)([^ `t])([ `t]+)$" ; trim whitespace from end of line
		NewText := RegExReplace(NewText,PCRE,"$1")

		; PCRE   := "imS)^[ `t]+$" ; trim blank lines (whitespace only lines)
		; NewText := RegExReplace(NewText,PCRE,"")

		PCRE   := "S)(\s;)([^; ])" ; unspaced comments
		NewText := RegExReplace(NewText,PCRE,"$1 $2")

		PCRE   := "mS)^(;)([^; ])" ; whole line comments
		NewText := RegExReplace(NewText,PCRE,"$1 $2")


		; assign back to ByRef parameter
		fnText := NewText

	}
	Catch, ThrownValue
	{
		ReturnValue := !ReturnValue
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,1,0,0)
	}
	Finally
	{
	}

	; return
	Return ReturnValue
}


/* ; testing
params := xxx
ReturnValue := FormatAHK(params)
MsgBox, FormatAHK`n`nReturnValue: %ReturnValue%
*/