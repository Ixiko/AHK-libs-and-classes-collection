/* Title:	IconEx
 			*Advanced icon dialog*
 :
			This is advanced version of system dialog <CmnDlg_Icon>.
 			With Icon, you can only open icon from file resource while this dialog
 			allows you to move trough file system folders and use anything as an icon. 
 			Furthermore, icon resource can be entered like it is a folder. 
 			If file is the icon resource, its name will have ">" at the end and you can open it.
 :
 			Dialog is modal, meaning that your script will stop until dialog is closed.
 			Additionally, you can pass configuration file (ini) when opening dialog to let it store
 			state information in IconEx section, like dialog position and size, last folder/file
 			that was open, etc.
 :
 			Dialog is resizable, and have support for filters and icon size.
			(see IconEx.png)
 */

/*
  Function: IconEx
 			Open the dialog.
 
  Parameters: 
 			StartFile	- File or folder to start with. By default empty it means that shell32.dll will be used
 						  unless you set Settings and IconEx was previously used (so it saved previous session).
 						  If you specify file that is not an icon resource, its parent folder will be open and file will
 						  be selected. If file is icon-resource (like shell32.dll) it will be open. You can specify file index
 						  to be selected after the file name separated by ":" (shell32.dll:125)
 			Pos			- Position of gui in AHK syntax. By default empty, dialog will start at screen center, unless
 						  there is saved position of previous session (if Settings is set)
 			Settings	- Path of the ini file that will be used to store session information. Data is saved in IconEx section.
 						  If this file already exists with valid session information, those will be used to set Pos and StartFile if they are left empty.
 			GuiNum		- GUI number to be used by the dialog, by default 69.
 
  Returns:
 			Path of the selected icon. If icon is in icon resource, its 0 based index is specified after the file name with ":" as separator, for instance
 			shell32.dll:12. 
 
  Remarks:	
 			Default window will be set as the parent of the dialog. Use Gui N:Default to set the correct parent before calling this function.
 			Parent will be disabled while the dialog is active. Dialog will not change the Default Gui.
 
 			User can set relative paths in the file name field of the IconEx GUI, for instance ".." to open a parent folder.
 			If StartFile is empty, shell32.dll will be open, the same as in standard Icon dialog.

  Hotkeys:
 			Backspace	- Go to the parent folder.
 			Enter		- Enter folder or icon resource.
  */
IconEx(StartFile="", Pos="", Settings="", GuiNum=69) {
	static WM_ACTIVATE = 6
	static sFilter = "*||ico icl|exe dll| |show folders|hide folders| |icon size 24|icon size 32|icon size 48|icon size 64|icon size 92|icon size 128"

  ;initialize
    oldbl := A_BatchLines
	SetBatchLines, -1

	IconEx_("Settings",  Settings)
	IconEx_("GuiNum",	 GuiNum)
	IconEx_("Shell32dll",shell32dll := A_WinDir "\system32\shell32.dll")

	guiPos		:= Pos!="" ? IconEx_CfgGet( "GuiPos" ) : Pos
	guiW		:= IconEx_CfgGet( "GuiW", 400)
	guiH		:= IconEx_CfgGet( "GuiH", 500)
	StartFile	.= StartFile="" ? IconEx_CfgGet("File", shell32dll) : ""

	IconEx_("Filter",  filter := IconEx_CfgGet("Filter", "*") )
	IconEx_("Flags",   IconEx_CfgGet("Flags", "0") )
	iconSize := IconEx_CfgGet("IconSize", "32") 
	IfLess,iconSize, 24, SetEnv, iconSize, 24
	IconEx_("IconSize", iconSize)

  ;create GUi
	Gui, +LastFoundExist
	IconEx_("hParent", hParent := WinExist()),  defGui := IconEx_DefaultGui()

	Gui, %GuiNum%:Default
	Gui, +ToolWindow +Resize +LabelIconEx_ +LastFound MinSize320x300
	IconEx_("hIconEx", hIconEx := WinExist())

  ;add combo
	w := guiW - 105
	Gui, Add, ComboBox, x0 w%w% gIconEx_onPath, %StartFile%||
	Gui, Add, ComboBox, w100 x+5 gIconEx_onFilter, %sFilter%

  ;add listview
	h := GuiH - 30
	Gui, Add, ListView, x0 w%GuiW% h%h% -Multi AltSubmit Icons gIconEx_onIconClick, Icon|File name

  ;set hotkeys
	Hotkey, IfWinActive, ahk_id %hIconEx%
	Hotkey, ~Backspace, IconEx_hkBackspace, on
	Hotkey, ~Enter,		IconEx_hkEnter, on
	Hotkey, IfWinActive

  ;show it
	DllCall("EnableWindow", "uint", hParent, "uint", 0)
	Gui, Show, %guiPos% w%guiW% h%guiH%, Choose Icon
	ControlFocus, SysListView321
	IconEx_scan(StartFile)

  ;do modal loop
    IconEx_onActivate(hIconEx, hParent,"","") 
	old := OnMessage(6, "IconEx_onActivate")
	ifEqual, old, IconEx_onActivate, SetEnv, old,
	WinWaitClose, ahk_id %hIconEx% 
	OnMessage(WM_ACTIVATE, old)

  ;return 
	DllCall("EnableWindow", "uint", hParent, "uint", 1)
	Winactivate, ahk_id %hParent%
	ifNotEqual defGui,0,Gui, %defGui%:Default
	SetBatchLines, %oldbl%
	return IconEx_("result")
}

IconEx_onFilter(filter=""){
	static NOFOLDERS=1

	ControlGet,t,Choice,, ComboBox2
	oldTrim := A_AutoTrim
	AutoTrim, on
	t = %t%
	filter = %filter%
	AutoTrim, %oldTrim%
	if ( filter t = "" )
		return

	flags := IconEx_("Flags")
	
	if (t="show folders")
		IconEx_("Flags", flags &= !NOFOLDERS)
	else if (t="hide folders")
		IconEx_("Flags", flags |= NOFOLDERS)
	else if InStr(t, "icon size ") {
		iconSize := SubStr(t, 11) 
		ifLess, iconSize, 24, SetEnv, iconSize, 24
		IconEx_("IconSize", iconSize)
	}
	else IconEx_("Filter", t)

	IconEx_scan("!")		;rescan
}

IconEx_onFilter:
	IconEx_onFilter()
return

IconEx_onPath()  {
	ControlGet,c,Choice, , ComboBox1
	ifEqual, c,,return
	IconEx_scan("!")
}

IconEx_onPath:
	IconEx_onPath()
return

;Convert relative file name to the full file name
IconEx_getFullName( Fn ) {
	static buf, init
	ifEqual, init, , SetEnv, init, % VarSetCapacity(buf, 512)
	ifEqual, Fn, >drives, return fn

	DllCall("GetFullPathNameA", "str", Fn, "uint", 512, "str", buf, "str*", 0)
	return buf
}

;When user activates the parent, don't allow it.
IconEx_onActivate(Wparam, Lparam, Msg, Hwnd){
    static hIconEx, hParent
    
    if Msg= 
        return hIconEx := Wparam, hParent := Lparam 
        
    if (wparam & 0xFF) and (hwnd = hParent) 
        WinActivate ahk_id %hIconEx% 
}

;Returns true if file has icon resources or if file is the folder.
IconEx_hasIcons( File ){
	return InStr(FileExist(File), "D") ? 1 : DllCall("shell32\ExtractIconA", "UInt", 0, "Str", File, "UInt", -1) > 1
}

;Add item to combo and select it, but only if it is not already there.
IconEx_add2Combo( Item ) {
	ControlGet,s, FindString, %Item%, ComboBox1, A		; add to the combobox if not already in it
	if !s
		GuiControl, ,  ComboBox1, %Item%||
}

; Populates listview with icons from ther given file. If file name is empty, it will be taken from the ComboBox
; Check parameters, prepare GUI and see if pFile is folder or icon resource and call adequate function.
IconEx_scan( FileName = "" ){
	if SubStr(FileName,1,1) = "!" {
		IconEx_scanFolder(), IconEx_scanFile()	;stop them if working...
		IconEx_("File", SubStr(FileName,2) )
		SetTimer, IconEx_scanTimer, -20
		return
	}
	IconEx_("", "GuiNum shell32dll hIconEx", guiNum, shell32dll, hIconEx)
	Gui, %guiNum%:Default
	IconEx_stopScan := 0
	pFile := FileName

	if (pFile = "") {
		GuiControlGet, pFile, ,ComboBox1
		IfEqual, pFile,,SetEnv, pFile, %shell32dll%
	}
	pFile := IconEx_getFullName( pFile )

 ;clear list of files
	selected := LV_GetNext()
	LV_Delete()

 ;create new list of large images and replace and delete old one
	IconEx_("hIL", hIL := IconEx_ILCreate(100, 100))
	IL_Destroy(LV_SetImageList(hIL))

 ;check for drives 
 	ifEqual, pFile, >drives, return IconEx_addDrives()

 ;check for file:idx 
	idx := 0
	if (j := InStr(pFile,":",0,0)) > 2
		idx := SubStr(pFile, j+1), pFile := SubStr(pFile, 1, j-1)
	
 ;check for wrong path
	if not attrib := FileExist(pFile)
		return LV_Add("","> Invalid path")

 ;everything is OK, add to combo and start scanning
	IconEx_Add2Combo(pFile)
	IconEx_("File", pFile)

	If attrib contains D
	{
		IconEx_scanFolder( pFile )
		prevSel := IconEx_("prevSel")
		if (prevSel != "") {
			SplitPath, prevSel, idx , dir
			ifEqual, dir, %pFile%, SetEnv, sel, %idx%
			IconEx_("prevIcon", "")
		} else sel := 1
		ifEqual, sel, 0, SetEnv, sel, 1
		LV_Modify(sel, "vis select focus") 
	}
	else  
	    if IconEx_hasIcons( pFile ) {
			SplitPath, pFile, fn , dir			
			IconEx_("prevSel", dir "\" selected)
			IconEx_scanFile( pFile )
			LV_Modify(idx+2, "vis select focus")
		}
		else {								;if no icon resource is given, browse parent folder and select given icon			
			SplitPath, pFile, fn, dir	
			IconEx_scanFolder( dir )
			ControlSendRaw, SysListView321, %fn%, ahk_id %hIconEx%		;select the file
		}

	IconEx_stopScan := 1
}

IconEx_scanTimer:
	IconEx_scan( IconEx_("File") )
return

IconEx_scanFile( FileName="" ) {
	static stop
	ifEqual, FileName,, return stop := 1

	IconEx_("", "hIL shell32", hIL, shell32dll)
	folderIcon  := IconEx_ILAdd(hIL, shell32dll, 5)
	LV_Add("Icon" . folderIcon, ". .", FileName)
	;Search for 9999 icons in the selected file
	stop := 0
	Loop, 9999
    {
		ifEqual, stop, 1, return stop := 0
     
		if idx := IconEx_ILAdd(hIL, FileName , A_Index)
			LV_Add("Icon" . idx, idx-1, FileName ":" idx-1)
		else break  
    }

	IconEx_setStatus()
}

IconEx_scanFolder( FolderName="" ){
	static NOFOLDERS=1, stop
	ifEqual, FolderName,, return stop := 1

	IconEx_("", "Flags Filter shell32dll hIL", flags, filter, shell32dll, hIL)
	folderIcon := IconEx_ILAdd(hIL, shell32dll, 4)
	goUpIcon   := IconEx_ILAdd(hIL, shell32dll, 5)
	LV_Add("Icon" . goUpIcon, ". .", FolderName)

 ;add folders
	IconEx_setStatus( "scaning folder ..." )
	stop := 0
    If !(flags & NOFOLDERS)
	{
		Loop, %FolderName%\*, 2 
		{
			ifEqual, stop, 1, return stop := 0

		 ;don't add hiden and system
			FileGetAttrib, attrib , %A_LoopFileFullPath%
			If attrib contains H,S
				continue
			LV_Add("Icon" . folderIcon, A_LoopFileName, A_LoopFileFullPath)		
		}

		folderCount := LV_GetCount()-1
		s :=  foldercount " folder" (folderCount=1  ? "" : "s") ", "
	}

 ;files	  
	Loop, %FolderName%\*
	{
		ifEqual, stop, 1, return stop := 0
		if (filter != "*") && !InStr(filter, A_LoopFileExt)
		   continue
		 
		idx := IconEx_ILAdd(hIL, A_LoopFileFullPath,1)
		ifEqual, idx, 0, continue

		if IconEx_hasIcons( A_LoopFileFullPath )
			 LV_Add("Icon" . idx, A_LoopFileName ">", A_LoopFileFullPath)		
		else LV_Add("Icon" . idx, A_LoopFileName, A_LoopFileFullPath)
	}

	icnCount := LV_GetCount()-foldercount-1
	IconEx_setStatus( (folderCount ? s : "") icnCount " file" (icnCount=1  ? "" : "s"))
}

; Add drive icons in the list
IconEx_addDrives() {
	IconEx_("", "shell32dll hIL", shell32dll, hIL)

	driveIcon	:= IconEx_ILAdd(hIL, shell32dll, 8)
	floppyIcon	:= IconEx_ILAdd(hIL, shell32dll, 7)
	cdIcon		:= IconEx_ILAdd(hIL, shell32dll, 12)
	remoteIcon	:= IconEx_ILAdd(hIL, shell32dll, 11)

	DriveGet drives, List

	Loop, parse, drives
	{
		r := DllCall("GetDriveType", "str", A_LoopField ":")
		if r = 3	;cdrom
			icn := driveIcon
		else if r = 5
			icn := cdIcon
		else if r = 4
			icn := remoteIcon
		else if r = 2
			icn := floppyIcon

		LV_Add("Icon" . icn, A_LoopField ":", A_LoopField ":")
	}
	IconEx_setStatus("drives")
}
	
IconEx_setStatus( s="" ){
	hIconEx := IconEx_("hIconEx")
	WinSetTitle, ahk_id %hIconEx%, ,% "Choose Icon  -  " (s="" ? LV_GetCount()-1 " icons" : s)
}

; Handles icon click in ListView
IconEx_onIconClick(e){
	IfEqual, e, 0, return

	guiNum := IconEx_("GuiNum")
	Gui, %guiNum%:Default
	LV_GetText(file, e, 2), LV_GetText(txt, e, 1)
	IfEqual, file,, return	 ;happens if user clicks on "Invalid path" text.

	if (txt = ". ."){
		if StrLen(file) = 3
			file := ">drives"
		else {
			file := (j:=InStr(file, "\", 0, 0)) ? SubStr( file, 1,  j-1) : ">drives"
			if (StrLen(file)=2)		;drive
				file .= "\"
		}
	}

	if (FileExist( file ) && IconEx_hasIcons( file )) OR (file = ">drives")
	{
		IconEx_("File", file)
		SetTimer, IconEx_scanTimer, -10
		return
	}

	;its not the resource, not the folder, this is the icon to return
	IconEx_("Result", file)
	IconEx_exit()
}

IconEx_onIconClick:
	critical 50
	If A_GuiEvent = A
		IconEx_onIconClick(A_EventInfo)
return

IconEx_anchor(c, a, r = false) { ; v3.5 - Titan
	static d
	GuiControlGet,  p, Pos, %c%
	If !A_Gui or ErrorLevel
		Return
	i = x.w.y.h./.7.%A_GuiWidth%.%A_GuiHeight%.`n%A_Gui%:%c%=
	StringSplit, i, i, .
	d .= (n := !InStr(d, i9)) ? i9 : ""
	Loop, 4
		x := A_Index, j := i%x%, i6 += x = 3, k` := !RegExMatch(a, j . "([\d.]+)", v)
		+ (v1 ? v1 : 0), e := p%j% - i%i6% * k, d .= n ? e . i5 : "", RegExMatch(d
		, i9 . "(?:([\d.\-]+)/){" . x . "}", v), l .= InStr(a, j) ? j . v1 + i%i6% * k : ""
	r := r ? "Draw" : ""
	GuiControl, Move%r%, %c%, %l%
}

IconEx_setLV() {
	ControlGet, hLV, HWND, ,SysListView321, A
	SendMessage, 4118,,,, ahk_id %hLV%		;LVM_ARRANGE
}
IconEx_size:
	IconEx_Anchor("ComboBox1"       , "w")
	IconEx_Anchor("ComboBox2"		 , "x")
	IconEx_Anchor("SysListView321"  , "wh")
	IconEx_setLV()
Return

; Save settings if present and exit
IconEx_exit(){

	if IconEx_("Settings") != ""
	{
		IconEx_("", "hIconEx IconSize Filter Flags File", hIconEx, iconSize, filter, flags, file)

		VarSetCapacity(RECT, 16)
		DllCall("GetClientRect", "uint", hIconEx, "uint", &RECT)
		WinGetPos, x, y,,,ahk_id %hIconEx%

		IconEx_CfgSet( "GuiW",		NumGet(RECT, 8) )
		IconEx_CfgSet( "GuiH",		NumGet(RECT, 12) )
		IconEx_CfgSet( "GuiPos",	"x" x " y" y )
		IconEx_CfgSet( "File",		file )
		IconEx_CfgSet( "IconSize",	iconSize )
		IconEx_CfgSet( "Filter",	filter )
		IconEx_CfgSet( "Flags",		flags )
	}

	Gui, Destroy
}

IconEx_close:
IconEx_escape:
	IconEx_exit()
Return

; Get configuration entery from ini file (or registry, eventualy)
IconEx_cfgGet( var, def="" ){
	static settings
	ifEqual, settings,, SetEnv, settings, % IconEx_("Settings")

	IniRead, var, %settings%, IconEx, %var%, %A_SPACE%
    ifEqual, var,,return def
	return var
}

; Set configuration entery in ini file (or registry eventualy)
IconEx_cfgSet( var, value ) {
	static settings
	ifEqual, settings,, SetEnv, settings, % IconEx_("Settings")

    IniWrite, %value%, %settings%, IconEx, %var%
}


; Hotkey handlers
IconEx_hkEnter() {
	IconEx_("", "hIconEx File GuiNum", hIconEx, file, guiNum)
	ControlGetFocus, c, ahk_id %hIconEx%

	if (c="Edit1")
		return IconEx_scan("!")
	else if (c="Edit2")
	{
		ControlGetText, t,ComboBox2
		return IconEx_onFilter(t)
	}
	else if (c="SysListView321") 
	{
		Gui, %guiNum%:Default
		return IconEx_onIconClick( LV_GetNext() )		
	}
}

IconEx_hkBackspace(){
	IconEx_("", "hIconEx File", hIconEx, file)
	ControlGetFocus, c, ahk_id %hIconEx%
	if (c = "SysListView321") && (file != ">drives")
		IconEx_onIconClick( 1 )
}

IconEx_hkEnter:
	IconEx_hkEnter()
return 

IconEx_hkBackspace:
	IconEx_hkBackspace()
return

; ImageList replacement
IconEx_ILAdd(hIL, FileName, IconNumber) {

	iconSize := IconEx_("IconSize")
	DllCall("PrivateExtractIcons", "str",Filename,"int",IconNumber-1,"int",iconSize,"int", iconSize,"uint*",hIcon,"uint*",0,"uint",1,"uint",0,"int")
	res := DllCall("comctl32.dll\ImageList_ReplaceIcon", "uint", hIL, "int", -1, "uint", hIcon) 
	DllCall("DestroyIcon","uint",hIcon)

	return res + 1
}

IconEx_ILCreate(InitialCount, GrowCount){
	static  ILC_COLOR := 0, ILC_COLOR4 := 0x4, ILC_COLOR8 := 0x8, ILC_COLOR16 := 0x10, ILC_COLOR24 := 0x18, ILC_COLOR32 := 0x20 

	iconSize := IconEx_("IconSize")
	return DllCall("comctl32.dll\ImageList_Create","int", iconSize, "int", iconSize, "uint", ILC_COLOR24, "int", InitialCount, "int", GrowCount)  ;Change ILC constant for differenct color depths.
}

;Find default Gui
IconEx_defaultGui() { 
   if A_Gui != 
      return A_GUI 
   m := DllCall( "RegisterWindowMessage", Str, "GETDEFGUI")
   OnMessage(m, "A_DefaultGui")
   Gui, +LastFound
   k := WinExist()
   res := DllCall("SendMessageA", "uint", k, "uint", m, "uint", 0, "uint", 0) 
   OnMessage(m, "")   
   return res   
}

;Storage function
IconEx_(var="", value="~`a", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="") {
	static
	if (var = "" ){
		if ( _ := InStr(value, ")") )
			__ := SubStr(value, 1, _-1), value := SubStr(value, _+1)
		loop, parse, value, %A_Space%
			_ := %__%%A_LoopField%,  o%A_Index% := _ != "" ? _ : %A_LoopField%
		return
	} else _ := %var%
	ifNotEqual, value, ~`a, SetEnv, %var%, %value%
	return _
}

/*
 Group: About 
      o Ver 2.0 by majkinetor. See <http://www.autohotkey.com/forum/topic17299.html>
      o Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/>
 */