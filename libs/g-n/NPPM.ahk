NPPM_GETCURRENTSCINTILLA() ; 2028
{
	;sciView indicates the current Scintilla view :
  ; 0 is the main Scintilla view
	; 1 is the second Scintilla view.
	hNpp := Nppm_Hwnd()

	openProcSuccess := NPPM_OpenBuffer(hProcess, nppBufAddress, 4)

	if (WinExist("ahk_id " . hNpp) == 0) OR (openProcSuccess == 0)
		return

	DllCall("SendMessage", "Ptr", hNpp, "UInt", 4034, "Int", 0, "Ptr", nppBufAddress)

	sciView := NPPM_ReadBuffer(hProcess, nppBufAddress, 4, "Number")

	NPPM_CloseBuffer(hProcess, nppBufAddress)

	return sciView
}

NPPM_GETCURRENTLANGTYPE() ; 2029
{
  ; langType indicates the language type of current Scintilla view document
  ; please see the enum LangType in "PluginInterface.h" for all possible value.
  ; or NPPM_Langs(lang)

	MAX_PATH := 260 * (A_IsUnicode ? 2 : 1)

	hNpp := Nppm_Hwnd()

	openProcSuccess := NPPM_OpenBuffer(hProcess, nppBufAddress, MAX_PATH)

	if (WinExist("ahk_id " . hNpp) == 0) OR (openProcSuccess == 0)
		return

	DllCall("SendMessage", "Ptr", hNpp, "UInt", 2029, "Int", MAX_PATH, "Ptr", nppBufAddress)

	langType := NPPM_ReadBuffer(hProcess, nppBufAddress, MAX_PATH, "Number")

	NPPM_CloseBuffer(hProcess, nppBufAddress)

	return langType
}

NPPM_SETCURRENTLANGTYPE(langType) ; 2030
{
  ; langType is used to set the language type of current Scintilla view document
  ; please see the enum LangType in "PluginInterface.h" for all possible value.
  ; or NPPM_Langs(lang)
	DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2030 , "Int", 0, "Int", langType)
}

NPPM_GETNBOPENFILES(nbType := 0) ; 2031
{
  ; The return value depends on nbType :
  ; nbType         | Meaning
  ; -------------------------------------
  ; ALL_OPEN_FILES | the total number of files opened in Notepad++
  ; PRIMARY_VIEW   | the number of files opened in the primary view
  ; SECOND_VIEW    | the number of files opened in the second view

	; exclude 'nbType' for ALL files
	; set 'nbType' as 1, P, or PRIMARY for files in primary view
	; set 'nbType' as 2, S, or SECONDARY for files in secondary view

	nbType := (nbType ~= "i)^(PRIMARY|P|1)$") ? 1 : (nbType ~= "i)^(SECONDARY|S|2)$") ? 2 : (nbType == 0) ? 0 : return

	singleView := Nppm_IsSingleView()

	if (singleView = true AND nbType = 2)
		return 0

	num := DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2031, "Int", 0, "Int", nbType)

	return (singleView = true AND nbType = 0) ? (num - 1) : (num)
}

; NPPM_GETOPENFILENAMES ; 2032
; {
/* nbFile is the size of your fileNames array. You should get this value by using NPPM_NBOPENFILES message with constant ALL_OPEN_FILES, then allocate fileNames array with this value.
fileNames receives the full path names of all the opened files in Notepad++. User is responsible to allocate fileNames array with an enough size.

The return value is the number of file full path names copied in fileNames array.
 */
	; return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2032, "Int", , "Int", )
; }

NPPM_MODELESSDIALOG(operationMode, hDialog) ; 2036
{	; operationMode:
	; MODELESSDIALOGADD		0
	; MODELESSDIALOGREMOVE	1

  ; For each created dialog in your plugin, you should register it (and unregister while destroy it) to Notepad++ by using this message. If this message is ignored, then your dialog won't react with the key stroke messages such as TAB key. For the good functioning of your plugin dialog, you're recommended to not ignore this message.
  ; hDlg is the handle of the dialog to be registed.
  ; op : the operation mode. MODELESSDIALOGADD is to register; MODELESSDIALOGREMOVE is to unregister.

	return (operationMode == 1) OR (operationMode == 2)
			? DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2036, "Int", operationMode, "Int", hDialog)
			: 0
}

NPPM_GETNBSESSIONFILES(file) ; 2037
{
  ; This message return the number of files to load in the session sessionFileName. sessionFileName should be a full path name of an xml file. 0 is returned if sessionFileName is NULL or an empty string

  MAX_PATH := 260 * (A_IsUnicode ? 2 : 1)

	hNpp := Nppm_Hwnd()

	openProcSuccess := NPPM_OpenBuffer(hProcess, nppBufAddress, MAX_PATH)

	if (WinExist("ahk_id " . hNpp) == 0) OR (openProcSuccess == 0)
		return

	stringWritten := DllCall("WriteProcessMemory", "Ptr", hProcess, "Ptr", nppBufAddress
						 , "Ptr", &file, "UInt", MAX_PATH, "UInt", 0)

	if (stringWritten <> true)
		return
	else DllCall("SendMessage", "Ptr", hNpp, "UInt", 2037, "Int", 0, "Ptr", nppBufAddress)

	NPPM_CloseBuffer(hProcess, nppBufAddress)
	return
}

; NPPM_GETSESSIONFILES ; 2038
; {
/* Send this message to get files' full path name from a session file.
sessionFileName is the session file from which you retrieve the files.

sessionFileArray : the array in which the files' full path of the same group are written. You should send message NPPM_GETNBSESSIONFILES before to allocate this array with the proper size.
 */
	; return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2038, "Int", , "Int", )
; }

; NPPM_SAVESESSION ; 2039
; {
; This message let plugins save a session file (xml format) by providing an array of full files path name. sessionInfomation is a structure defined as follows:   TCHAR* sessionFilePathName; the full path name of session file to save   int nbFile; the number of files in the session   TCHAR** files; files' full path

	; return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2039, "Int", , "Int", )
; }

NPPM_SAVECURRENTSESSION(sessionFileName) ; 2040
{
  ; You can save the current opened files in Notepad++ as a group of files (session) by using this message. Notepad++ saves the current opened files' full pathe names and their current stats in a xml file. The xml full path name is provided by sessionFileName.

	MAX_PATH := 260 * (A_IsUnicode ? 2 : 1)

	hNpp := Nppm_Hwnd()

	openProcSuccess := NPPM_OpenBuffer(hProcess, nppBufAddress, MAX_PATH)

	if (WinExist("ahk_id " . hNpp) == 0) OR (openProcSuccess == 0)
		return

	stringWritten := DllCall("WriteProcessMemory", "Ptr", hProcess, "Ptr", nppBufAddress
						 , "Ptr", &sessionFileName, "UInt", MAX_PATH, "UInt", 0)

	if (stringWritten <> true)
		return
	else DllCall("SendMessage", "Ptr", hNpp, "UInt", 2040, "Int", 0, "Ptr", nppBufAddress)

	NPPM_CloseBuffer(hProcess, nppBufAddress)
	return
}

; NPPM_GETOPENFILENAMESPRIMARY ; 2041
; {
/* nbFile is the size of your fileNames array. You should get this value by using NPPM_NBOPENFILES message with constant PRIMARY_VIEW, then allocate fileNames array with this value.
fileNames receives the full path names of the opened files in the primary view. User is responsible to allocate fileNames array with an enough size. The return value is the number of file full path names copied in fileNames array.
 */
 ; return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2041, "Int", , "Int", )
; }

; NPPM_GETOPENFILENAMESSECOND ; 2042
; {
/* nbFile is the size of your fileNames array. You should get this value by using NPPM_NBOPENFILES message with constant SECOND_VIEW, then allocate fileNames array with this value.
fileNames receives the full path names of the opened files in the second view. User is responsible to allocate fileNames array with an enough size.

The return value is the number of file full path names copied in fileNames array.
 */
	; return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2042, "Int", , "Int", )
; }

NPPM_CREATESCINTILLAHANDLE(hParent := false) ; 2044
{
  ; A plugin can create a Scintilla for its usage by sending this message to Notepad++. The return value is created Scintilla handle. The handle should be destroyed by NPPM_DESTROYSCINTILLAHANDLE message while exit the plugin. If pluginWindowHandle is set (non NULL), it will be set as parent window of this created Scintilla handle, otherwise the parent window is Notepad++.

	hParent := (hParent == false) ? (A_ScriptHwnd) : (hParent)
	hScin := DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2044 , "Int", 0, "Ptr", hParent)

	DestroyOnExit := Func("NPPM_DESTROYSCINTILLAHANDLE").Bind(hScin)

	OnExit(DestroyOnExit)

	return hScin
}

NPPM_DESTROYSCINTILLAHANDLE(hSci) ; 2045
{
  ; If plugin called NPPM_DESTROYSCINTILLAHANDLE to create a Scintilla handle, it should call this message to destroy this handle while it exit. #

	DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2045 , "Int", 0, "Ptr", hSci)
}

NPPM_GETNBUSERLANG() ; 2046
{
	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2046, "Int", 0, "Int", 0)
}

NPPM_GETCURRENTDOCINDEX(iView := "") ; 2047
{
  ; Sending this message to get the current index in the view that you indicates in iView : MAIN_VIEW or SUB_VIEW. Returned value is -1 if the view is invisible (hidden), otherwise is the current index.

	view := (iView == 0) ? 0 : (iView == 1) ? 1 : NPPM_GETCURRENTSCINTILLA()

	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2047 , "Int", 0, "Int", view)
}

; NPPM_SETSTATUSBAR ; 2048
; {
	; return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2048, "Int", , "Int", )
; }

NPPM_GETMENUHANDLE(mainMenu = true) ; 2049
{
; This message help plugins to get the plugins menu handle of Notepad++, whichMenu must be NPPPLUGINMENU (0), or NPPMAINMENU (1) to return handle to the menu br in the main window. 0 is return on any other inut.
; set mainMenu as 'false/0' to retrieve handle of plugin menu
	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2049 , "Int", mainMenu, "Int", 0)
}

; NPPM_ENCODESCI ; 2050
; {
	; return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2050, "Int", , "Int", )
; }

; NPPM_DECODESCI ; 2051
; {
	; return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2051, "Int", , "Int", )
; }

NPPM_ACTIVATEDOC(view, tabNumber) ; 2052
{
; When Notepad++ receives this message, it switches to iView (MAIN_VIEW or SUB_VIEW) as current view, then it switches to index2Activate from the current document.
; tabNumber is 0-based. the first tab is 0, second is 1, etc
	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2049 , "Int", view, "Int", tabNumber)
}

; NPPM_LAUNCHFINDINFILESDLG ; 2053
; {
  ; This message triggers the Find in files dialog. The fields Directory and filters are filled by respectively dir2Search and filtre if those parameters are not NULL or empty.

	; return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2053, "Int", , "Int", )
; }

NPPM_DMMSHOW(hDialog) ; 2054
{
  ; This message is used for your plugin's dockable dialog. Send this message to show the dialog. hDlg is the handle of your dialog to be shown.

	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2054, "Int", 0, "Int", hDialog)
}

NPPM_DMMHIDE(hDialog) ; 2055
{
  ; This message is used for your plugin's dockable dialog. Send this message to hide the dialog. hDlg is the handle of your dialog to be hidden.

	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2055, "Int", 0, "Int", hDialog)
}

NPPM_DMMUPDATEDISPINFO(hDialog) ; 2056
{
  ; This message is used for your plugin's dockable dialog. Send this message to update (redraw) the dialog. hDlg is the handle of your dialog to be updated.

	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2056, "Int", 0, "Int", hDialog)
}

; NPPM_DMMREGASDCKDLG ; 2057
; {
/* From v4.0, Notepad++ supports the dockable dialog feature for the plugins. This message passes the necessary data dockingData to Notepad++ in order to make your dialog dockable. Here is tTbData looks like this:   HWND hClient; your dockable dialog handle.   TCHAR *pszName; the name of your plugin dialog.   int dlgID; index of menu entry where the dialog in question will be triggered.   UINT uMask; contains the behaviour informations of your dialog. It can be one of the following value : DWS_DF_CONT_LEFT, DWS_DF_CONT_RIGHT, DWS_DF_CONT_TOP, DWS_DF_CONT_BOTTOM and DWS_DF_FLOATING combined (optional) with DWS_ICONTAB, DWS_ICONBAR and DWS_ADDINFO.   HICON hIconTab; handle to the icon to display on the dialog's tab   TCHAR *pszAddInfo; pointer to a string joined to the caption using " - ", if not NULL   RECT rcFloat; Used internally, do not set   int iPrevCont; Used internally, do not set   const TCHAR *pszModuleName; the name of your plugin module (with extension .dll).
Minimum informations you need to fill out before sending it by NPPM_DMMREGASDCKDLG message is hClient, pszName, dlgID, uMask and pszModuleName. Notice that rcFloat and iPrevCont shouldn't be filled. They are used internally.
 */
	; return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2057, "Int", , "Int", )
; }

NPPM_LOADSESSION(sessionFileName) ; 2058
{
  ; Open all files of same session in Notepad++ via a xml format session file sessionFileName.

	MAX_PATH := 260 * (A_IsUnicode ? 2 : 1)

	hNpp := Nppm_Hwnd()

	openProcSuccess := NPPM_OpenBuffer(hProcess, nppBufAddress, MAX_PATH)

	if (WinExist("ahk_id " . hNpp) == 0) OR (openProcSuccess == 0)
		return

	stringWritten := DllCall("WriteProcessMemory", "Ptr", hProcess, "Ptr", nppBufAddress
						 , "Ptr", &sessionFileName, "UInt", MAX_PATH, "UInt", 0)

	if (stringWritten <> true)
		return
	else DllCall("SendMessage", "Ptr", hNpp, "UInt", 2058, "Int", 0, "Ptr", nppBufAddress)

	NPPM_CloseBuffer(hProcess, nppBufAddress)
	return
}

; NPPM_DMMVIEWOTHERTAB ; 2059
; {
	; return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2059, "Int", , "Int", )
; }

NPPM_RELOADFILE(file, confirm := false) ; 2060
{
  ; This Message reloads the file indicated in filePathName2Reload. If withAlert is TRUE, then an alert message box will be launched.

	if (confirm <> true) AND (confirm <> false)
		return

	MAX_PATH := 260 * (A_IsUnicode ? 2 : 1)

	hNpp := Nppm_Hwnd()

	openProcSuccess := NPPM_OpenBuffer(hProcess, nppBufAddress, MAX_PATH)

	if (WinExist("ahk_id " . hNpp) == 0) OR (openProcSuccess == 0)
		return

	stringWritten := DllCall("WriteProcessMemory", "Ptr", hProcess, "Ptr", nppBufAddress
						 , "Ptr", &file, "UInt", MAX_PATH, "UInt", 0)

	if (stringWritten <> true)
		return
	else DllCall("SendMessage", "Ptr", hNpp, "UInt", 2060, "Int", confirm, "Ptr", nppBufAddress)

	NPPM_CloseBuffer(hProcess, nppBufAddress)
	return
}

NPPM_SWITCHTOFILE(file) ; 2061
{
  ; When this message is received, Notepad++ switches to the document which matches with the given filePathName2switch.

	MAX_PATH := 260 * (A_IsUnicode ? 2 : 1)

	hNpp := Nppm_Hwnd()

	openProcSuccess := NPPM_OpenBuffer(hProcess, nppBufAddress, MAX_PATH)

	if (WinExist("ahk_id " . hNpp) == 0) OR (openProcSuccess == 0)
		return

	stringWritten := DllCall("WriteProcessMemory", "Ptr", hProcess, "Ptr", nppBufAddress
						 , "Ptr", &file, "UInt", MAX_PATH, "UInt", 0)

	if (stringWritten <> true)
		return
	else DllCall("SendMessage", "Ptr", hNpp, "UInt", 2061, "Int", 0, "Ptr", nppBufAddress)

	NPPM_CloseBuffer(hProcess, nppBufAddress)
	return
}

NPPM_SAVECURRENTFILE() ; 2062
{
  ; Send this message to Notepad++ to save the current document.
	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2062, "Int", 0, "Int", 0)
}

NPPM_SAVECURRENTFILEAS(file, saveAsCopy := false) ; 2062
{
  ; Performs a Save As (wParam == 0) or Save a Copy As (wParam == 1) on the current buffer, outputting to filename.

; set saveAsCopy to 'true' to 'Save a Copy As', otherwise 'Save As' is default

	if (saveAsCopy <> true) AND (saveAsCopy <> false)
		return

	MAX_PATH := 260 * (A_IsUnicode ? 2 : 1)

	hNpp := Nppm_Hwnd()

	openProcSuccess := NPPM_OpenBuffer(hProcess, nppBufAddress, MAX_PATH)

	if (WinExist("ahk_id " . hNpp) == 0) OR (openProcSuccess == 0)
		return

	stringWritten := DllCall("WriteProcessMemory", "Ptr", hProcess, "Ptr", nppBufAddress
						 , "Ptr", &file, "UInt", MAX_PATH, "UInt", 0)

	if (stringWritten <> true)
		return
	else DllCall("SendMessage", "Ptr", hNpp, "UInt", 2102, "Int", saveAsCopy, "Ptr", nppBufAddress)

	NPPM_CloseBuffer(hProcess, nppBufAddress)
	return
}

NPPM_SAVEALLFILES() ; 2063
{
  ; Send this message to Notepad++ to save all opened document.
	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2063, "Int", 0, "Int", 0)
}

NPPM_SETMENUITEMCHECK(cmdID, bool) ; 2064
{
	; Use this message to set/remove the check on menu item. cmdID is the command ID which corresponds to the menu item.

  return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2064, "UInt", cmdID, "Int", bool)
}

; NPPM_ADDTOOLBARICON ; 2065
; {
	; return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2065, "Int", , "Int", )
; }

NPPM_GETWINDOWSVERSION() ; 2066
{
  ; The return value is windows version of enum winVer. The possible value is WV_UNKNOWN, WV_WIN32S, WV_95, WV_98, WV_ME, WV_NT, WV_W2K, WV_XP, WV_S2003, WV_XPX64 and WV_VISTA

	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2066, "Int", 0, "Int", 0)
}

; NPPM_DMMGETPLUGINHWNDBYNAME ; 2067
; {
  ; This message returns the dialog handle corresponds to the windowName and moduleName. You may need this message if you want to communicate with another plugin "dockable" dialog, by knowing its name and its plugin module name. If moduleName is NULL, then return value is NULL. If windowName is NULL, then the first found window handle which matches with the moduleName will be returned.
  ;return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2067, "Int", , "Int", )
; }

NPPM_MAKECURRENTBUFFERDIRTY() ; 2068
{
	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2068, "Int", 0, "Int", 0)
}

NPPM_GETENABLETHEMETEXTUREFUNC() ; 2069
{
	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2069, "Int", 0, "Int", 0)
}

NPPM_GETPLUGINSCONFIGDIR() ; 2070
{
  ; string receives the directory path of plugin config files.
  ; User is responsible to allocate (or use automatic variable) a buffer with an enough size.
  ; MAX_PATH is suggested to use.

	MAX_PATH := 260 * (A_IsUnicode ? 2 : 1)

	hNpp := Nppm_Hwnd()

	openProcSuccess := NPPM_OpenBuffer(hProcess, nppBufAddress, MAX_PATH)

	if (WinExist("ahk_id " . hNpp) == 0) OR (openProcSuccess == 0)
		return

	DllCall("SendMessage", "Ptr", hNpp, "UInt", 2070, "Int", MAX_PATH, "Ptr", nppBufAddress)

	string := NPPM_ReadBuffer(hProcess, nppBufAddress, MAX_PATH)

	NPPM_CloseBuffer(hProcess, nppBufAddress)

	return string
}

; NPPM_MSGTOPLUGIN ; 2071
; {
/* This message allows the communication between 2 plugins.
For example, plugin X can execute a command of plugin Y if plugin X knows the command ID and the file name of plugin Y. destModuleName is the complete module name (with the extesion .dll) of plugin with which you want to communicate (plugin Y). communicationInfo is a poniter of structure type :
  long internalMsg; an integer defined by plugin Y, known by plugin X, identifying the message being sent.   TCHAR * srcModuleName; the complete module name (with the extesion .dll) of caller(plugin X).   void * info; defined by plugin, the informations to be exchanged between X and Y. It's a void pointer so it should be defined by plugin Y and known by plugin X.
The returned value is TRUE if Notepad++ found the plugin by its module name (destModuleName), and pass the info (communicationInfo) to the module. The returned value is FALSE if no plugin with such name is found.
 */
	; return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2071, "Int", , "Int", )
; }

NPPM_MENUCOMMAND(cmdID) ; 2072
{
  ; This message allows plugins to call all the Notepad++ menu commands.
  ; commandID are the command ID used in Notepad++. All the command ID are defined in menuCmdID.h.`

	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2072, "Int", 0, "Int", cmdID)
}

NPPM_TRIGGERTABBARCONTEXTMENU(view, tabNumber) ; 2073
{
  ; This message switches to iView (MAIN_VIEW or SUB_VIEW) as current view, and it switchs to index2Activate from the current document. Finally it triggers the tabbar context menu for the current document.
  ; Tabs are 0-based
	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2073, "Int", view, "Int", tabNumber)
}

NPPM_GETNPPVERSION() ; 2074
{
/* You can get Notepad++ version via this message. The return value is made up of 2 parts : the major version (the high word) and minor version (the low word).
For example, the 4.7.5 version will be :
  HIWORD(version) == 4   LOWORD(version) == 75 Note that this message is supported by the v4.7 or higher version. Earlier versions return 0.
 */
	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2074, "Int", 0, "Int", 0)
}

NPPM_HIDETABBAR() ; 2075
{
  ; If hideOrNot == TRUE, then this message will hide the tabbar, otherwise it makes tabbar shown. The returned value is the previous status before this operation.

  return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2075, "Int", 0, "Int", bool)
}

NPPM_ISTABBARHIDDEN() ; 2076
{
  ; By sending this message, a plugin is able to tell the current status of tabbar from the returned value: TRUE if the tabbar is hidden, FALSE otherwise.

	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2076, "Int", 0, "Int", 0)
}

NPPM_GETPOSFROMBUFFERID(hBuf, view) ; 2081
{
  ; Get 0-based document position from given buffer ID, which is held in the 30 lowest bits of the return value on success.
  ; If bufferID doesn't exist, -1 is returned. Otherwise, the index part is valid, and bit 30 indicates which view has the buffer (clear for main view, set for sub view).

	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2081, "Ptr", hBuf, "Int", view)
}

NPPM_GETFULLPATHFROMBUFFERID(hBuf) ; 2082
{
  ; Get full path file name from a given buffer ID.
  ; Return -1 if the bufferID non existing, otherwise the number of TCHAR copied/to copy. User should call it with fullFilePath be NULL to get the number of TCHAR (not including the nul character), allocate fullFilePath with the return values + 1, then call it again to get full path file name

	MAX_PATH := 260 * (A_IsUnicode ? 2 : 1)

	hNpp := Nppm_Hwnd()

	openProcSuccess := NPPM_OpenBuffer(hProcess, nppBufAddress, MAX_PATH)

	if (WinExist("ahk_id " . hNpp) == 0) OR (openProcSuccess == 0)
		return

	DllCall("SendMessage", "Ptr", hNpp, "UInt", 2082, "Ptr", hBuf, "Ptr", nppBufAddress)

	string := NPPM_ReadBuffer(hProcess, nppBufAddress, MAX_PATH)

	NPPM_CloseBuffer(hProcess, nppBufAddress)

	return string

}

NPPM_GETBUFFERIDFROMPOS(tabIndex, view) ; 2083
{
  ; Get document buffer ID from given position.
  ; position is 0 based index, view should be MAIN_VIEW or SUB_VIEW. Return value : 0 if given position is invalid, otherwise the document buffer ID.

	; tabIndex is 0-based
	; view = 0 for main, 1 for secondary
	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2083, "Int", tabIndex, "Int", view)
}

NPPM_GETCURRENTBUFFERID() ; 2084
{
	; Returns active document buffer ID
  return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2084, "Int", 0, "Int", 0)
}

NPPM_RELOADBUFFERID(hBuf, confirm := false) ; 2085
{
  ;Reload the document by given buffer ID.
  ; if doAlertOrNot is TRUE, then a message box will display to ask user to reload the document, otherwise document will be loaded without asking user.

  ; set confirm to 'true' to enable the confirmation dialog
	return (confirm <> true) AND (confirm <> false)
		 ? 0
		 : DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2113, "Ptr", hBuf, "Int", confirm)
}

NPPM_GETBUFFERLANGTYPE(hBuf) ; 2088
{
  ; Get document's language type from given buffer ID.
  ; Returns value : if error -1, otherwise language type (see LangType). [in] int bufferID

	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2088, "Ptr", hBuf, "Int", 0)
}

NPPM_SETBUFFERLANGTYPE(hBuf, langType) ; 2089
{
  ; Set language type of given buffer ID's document.
  ; Returns TRUE on success, FALSE otherwise. L_USER and L_EXTERNAL are not supported.

	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2089, "Ptr", hBuf, "Int", langType)
}

NPPM_GETBUFFERENCODING(hBuf) ; 2090
{
  ; Get document's encoding from given buffer ID.
  ; Returns value : if error -1, otherwise encoding number. enum UniMode - uni8Bit 0, uniUTF8 1, uni16BE 2, uni16LE 3, uniCookie 4, uni7Bit 5, uni16BE_NoBOM 6, uni16LE_NoBOM 7

	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2090, "Ptr", hBuf, "Int", 0)
}

NPPM_SETBUFFERENCODING(hBuf, encoding) ; 2091
{
  ; Set given buffer ID's document encoding.
  ; Can only be done on new, unedited files

	; Encoding choices: uni8Bit=0, uniUTF8=1, uni16BE=2, uni16LE=3, uniCookie=4
	; 					uni7Bit=5, uni16BE_NoBOM=6, uni16LE_NoBOM=7
	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2091, "Ptr", hBuf, "Int", encoding)
}

NPPM_GETBUFFERFORMAT(hBuf) ; 2092
{
  ; Get document's format from given buffer ID.
  ; Returns value : if error -1, otherwise document's format (see formatType).

	; 0 = windows, 1 = macos, 2 = unix
	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2092, "Ptr", hBuf, "Int", 0)
}

NPPM_SETBUFFERFORMAT(hBuf, format) ; 2093
{
  ; Set format of given buffer ID's document.
  ; Returns TRUE on success, FALSE otherwise

	; 0 = windows, 1 = macos, 2 = unix
	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2093, "Ptr", hBuf, "Int", format)
}

NPPM_HIDETOOLBAR(bool) ; 2094
{
  ; If hideOrNot == TRUE, then this message will hide the toolbar, otherwises it makes tabbar shown. The returned value is the previous staus before this operation.

	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2094, "Int", 0, "Int", bool)
}

NPPM_ISTOOLBARHIDDEN() ; 2095
{
  ; Via this message plugin is able to know the current status of toolbar.
  ; TRUE if the toolbar is hidden, FALSE otherwise.

	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2095, "Int", 0, "Int", 0)
}

NPPM_HIDEMENU(bool) ; 2096
{
	; If hideOrNot == TRUE, then this message will hide the menu bar, otherwises it makes tabbar shown. The returned value is the previous staus before this operation.

  return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2096, "Int", 0, "Int", bool)
}

NPPM_ISMENUHIDDEN() ; 2097
{
	; Via this message plugin is able to know the current status of menu bar.
  ; TRUE if the menbar is hidden, FALSE otherwise.

  return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2097, "Int", 0, "Int", 0)
}

NPPM_HIDESTATUSBAR(bool) ; 2098
{
	; If hideOrNot == TRUE, then this message will hide the status bar, otherwises it makes tabbar shown. The returned value is the previous staus before this operation.

  return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2098, "Int", 0, "Int", bool)
}

NPPM_ISSTATUSBARHIDDEN() ; 2099
{
	; Via this message plugin is able to know the current status of status bar.
  ; TRUE if the status bar is hidden, FALSE otherwise.

  return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2099, "Int", 0, "Int", 0)
}

; NPPM_GETSHORTCUTBYCMDID ; 2100
; {
  ; Get your plugin command current mapped shortcut into sk via cmdID. You may need it after getting NPPN_READY notification.
  ; Returned value : TRUE if this function call is successful and shorcut is enable, otherwise FALSE
	; return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2100, "Int", , "Int", )
; }

NPPM_DOOPEN(file) ; 2101
{
  ; file indicates the full file path name to be opened. In case it is already open the tab gets selected.
  ; The return value is TRUE (1) if the operation is successful, otherwise FALSE (0). ??? use return value

	MAX_PATH := 260 * (A_IsUnicode ? 2 : 1)

	hNpp := Nppm_Hwnd()

	openProcSuccess := NPPM_OpenBuffer(hProcess, nppBufAddress, MAX_PATH)

	if (WinExist("ahk_id " . hNpp) == 0) OR (openProcSuccess == 0)
		return

	stringWritten := DllCall("WriteProcessMemory", "Ptr", hProcess, "Ptr", nppBufAddress
						 , "Ptr", &file, "UInt", MAX_PATH, "UInt", 0)

	if (stringWritten <> true)
		return
	else DllCall("SendMessage", "Ptr", hNpp, "UInt", 2101, "Int", 0, "Ptr", nppBufAddress)

	NPPM_CloseBuffer(hProcess, nppBufAddress)
	return
}

NPPM_GETCURRENTNATIVELANGENCODING() ; 2103
{
  ; Returns the code page associated with the current localisation of Notepad++. As of v6.6.6, returned values are 1252 (ISO 8859-1), 437 (OEM US) or 950 (Big5).

	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2103, "Int", 0, "Int", 0)
}

NPPM_ALLOCATESUPPORTED() ; 2104
{
  ; Returns TRUE if NPPM_ALLOCATECMDID is supported. Use it to identify if subclassing is necessary.

	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2104, "Int", 0, "Int", 0)
}

; NPPM_ALLOCATECMDID ; 2105
; {
  ; Allows a plugin to obtain a number of consecutive meni item IDs for creating menus dynamically, with the guarantee of these IDs not clashing with any other plugin's. Returns 0 on failure, nonzero on success.
	; return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2105, "Int", , "Int", )
; }

; NPPM_ALLOCATEMARKER ; 2106
; {
  ; Allows a plugin to obtain a number of consecutive arker IDs dynamically, with the guarantee of these IDs not clashing with any other plugin's. Returns 0 on failure, nonzero on success.
	; return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2106, "Int", , "Int", )
; }

NPPM_GETLANGUAGENAME(langType) ; 2107
{
  ; Returns the number of characters needed or copied. If lParam is null, size of the language name is copied. Use this to allocate a buffer to pass as lParam and get the language name copied therein. The terminating \0 isn't counted in the returned length.

	hNpp := Nppm_Hwnd()

	size := DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2107, "Int", langType, "Int", 0)

	openProcSuccess := NPPM_OpenBuffer(hProcess, nppBufAddress, size)

	if (WinExist("ahk_id " . hNpp) == 0) OR (openProcSuccess == 0)
		return

	DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2107, "Int", langType, "Ptr", nppBufAddress)

	string := NPPM_ReadBuffer(hProcess, nppBufAddress, size)

	NPPM_CloseBuffer(hProcess, nppBufAddress)

	return string
}

NPPM_GETLANGUAGEDESC(langType) ; 2108
{
	; Returns the number of characters needed or copied. If lParam is null, size of the language name is copied. Use this to allocate a buffer to pass as lParam and get the language description copied therein. The terminating \0 isn't counted in the returned length.

  hNpp := Nppm_Hwnd()

	size := DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2108, "Int", langType, "Int", 0)

	openProcSuccess := NPPM_OpenBuffer(hProcess, nppBufAddress, size)

	if (WinExist("ahk_id " . hNpp) == 0) OR (openProcSuccess == 0)
		return

	DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2108, "Int", langType, "Ptr", nppBufAddress)

	string := NPPM_ReadBuffer(hProcess, nppBufAddress, size)

	NPPM_CloseBuffer(hProcess, nppBufAddress)

	return string
}

NPPM_SHOWDOCSWITCHER(bool) ; 2109
{
  ; Shows document switcher if lparam is true, hide it if false.

	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2109, "Int", 0, "Int", bool)
}

NPPM_ISDOCSWITCHERSHOWN() ; 2110
{
  ; Returns 0 if the document switcher is not currently shown, else non zero.
	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2110, "Int", 0, "Int", 0)
}

NPPM_GETAPPDATAPLUGINSALLOWED() ; 2111
{
  ; Returns true if loading plugins from %APPDATA is allowed, else returns false.
	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2111, "Int", 0, "Int", 0)
}

NPPM_GETCURRENTVIEW() ; 2112
{
	; Returns 0 when primary view is active, and 1 instead if secondary view is.
  return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2112, "Int", 0, "Int", 0)
}

NPPM_DOCSWITCHERDISABLECOLUMN(bool) ; 2113
{
	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2113, "Int", 0, "Int", bool)
}

NPPM_GETEDITORDEFAULTFOREGROUNDCOLOR() ; 2114
{
	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2114, "Int", 0, "Int", 0)
}

NPPM_GETEDITORDEFAULTBACKGROUNDCOLOR() ; 2115
{
	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2115, "Int", 0, "Int", 0)
}

NPPM_SETSMOOTHFONT(bool) ; 2116
{
	; set bool to true or false
	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2116, "Int", 0, "Int", bool)
}

NPPM_SETEDITORBORDEREDGE(bool) ; 2117
{
	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2116, "Int", 0, "Int", bool)
}

NPPM_SAVEFILE(file) ; 2118
{
	MAX_PATH := 260 * (A_IsUnicode ? 2 : 1)

	hNpp := Nppm_Hwnd()

	openProcSuccess := NPPM_OpenBuffer(hProcess, nppBufAddress, MAX_PATH)

	if (WinExist("ahk_id " . hNpp) == 0) OR (openProcSuccess == 0)
		return

	stringWritten := DllCall("WriteProcessMemory", "Ptr", hProcess, "Ptr", nppBufAddress
						 , "Ptr", &file, "UInt", MAX_PATH, "UInt", 0)

	if (stringWritten <> true)
		return
	else DllCall("SendMessage", "Ptr", hNpp, "UInt", 2118, "Int", 0, "Ptr", nppBufAddress)

	NPPM_CloseBuffer(hProcess, nppBufAddress)

	return
}

NPPM_DISABLEAUTOUPDATE() ; 2119
{
	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 2119, "Int", 0, "Int", 0)
}

NPPM_GETFULLCURRENTPATH() ; 4025
{
  ; string receives the full path of current Scintilla view document.
  ; User is responsible to allocate (or use automatic variable) a buffer with an enough size.
  ; MAX_PATH is suggested to use.

	MAX_PATH := 260 * (A_IsUnicode ? 2 : 1)

	hNpp := Nppm_Hwnd()

	openProcSuccess := NPPM_OpenBuffer(hProcess, nppBufAddress, MAX_PATH)

	if (WinExist("ahk_id " . hNpp) == 0) OR (openProcSuccess == 0)
		return

	DllCall("SendMessage", "Ptr", hNpp, "UInt", 4025, "Int", MAX_PATH, "Ptr", nppBufAddress)

	string := NPPM_ReadBuffer(hProcess, nppBufAddress, MAX_PATH)

	NPPM_CloseBuffer(hProcess, nppBufAddress)

	return string
}

NPPM_GETCURRENTDIRECTORY() ; 4026
{
  ; string receives the directory path of current Scintilla view document.
  ; User is responsible to allocate (or use automatic variable) a buffer with an enough size.
  ; MAX_PATH is suggested to use.

	MAX_PATH := 260 * (A_IsUnicode ? 2 : 1)

	hNpp := Nppm_Hwnd()

	openProcSuccess := NPPM_OpenBuffer(hProcess, nppBufAddress, MAX_PATH)

	if (WinExist("ahk_id " . hNpp) == 0) OR (openProcSuccess == 0)
		return

	DllCall("SendMessage", "Ptr", hNpp, "UInt", 4026, "Int", MAX_PATH, "Ptr", nppBufAddress)

	string := NPPM_ReadBuffer(hProcess, nppBufAddress, MAX_PATH)

	NPPM_CloseBuffer(hProcess, nppBufAddress)

	return string
}

NPPM_GETFILENAME() ; 4027
{
  ; string receives the file name of current Scintilla view document.
  ; User is responsible to allocate (or use automatic variable) a buffer with an enough size.
  ; MAX_PATH is suggested to use.

	MAX_PATH := 260 * (A_IsUnicode ? 2 : 1)

	hNpp := Nppm_Hwnd()

	openProcSuccess := NPPM_OpenBuffer(hProcess, nppBufAddress, MAX_PATH)

	if (WinExist("ahk_id " . hNpp) == 0) OR (openProcSuccess == 0)
		return

	DllCall("SendMessage", "Ptr", hNpp, "UInt", 4027, "Int", MAX_PATH, "Ptr", nppBufAddress)

	string := NPPM_ReadBuffer(hProcess, nppBufAddress, MAX_PATH)

	NPPM_CloseBuffer(hProcess, nppBufAddress)

	return string
}

NPPM_GETFILENAMEATCURSOR() ; 4035
{
	MAX_PATH := 260 * (A_IsUnicode ? 2 : 1)

	hNpp := Nppm_Hwnd()

	openProcSuccess := NPPM_OpenBuffer(hProcess, nppBufAddress, MAX_PATH)

	if (WinExist("ahk_id " . hNpp) == 0) OR (openProcSuccess == 0)
		return

	DllCall("SendMessage", "Ptr", hNpp, "UInt", 4035, "Int", MAX_PATH, "Ptr", nppBufAddress)

	string := NPPM_ReadBuffer(hProcess, nppBufAddress, MAX_PATH)

	NPPM_CloseBuffer(hProcess, nppBufAddress)

	return string
}

NPPM_GETNAMEPART() ; 4028
{
  ; string receives the part of name (without extension) of current Scintilla view document.
  ; User is responsible to allocate (or use automatic variable) a buffer with an enough size.
  ; MAX_PATH is suggested to use.

	MAX_PATH := 260 * (A_IsUnicode ? 2 : 1)

	hNpp := Nppm_Hwnd()

	openProcSuccess := NPPM_OpenBuffer(hProcess, nppBufAddress, MAX_PATH)

	if (WinExist("ahk_id " . hNpp) == 0) OR (openProcSuccess == 0)
		return

	DllCall("SendMessage", "Ptr", hNpp, "UInt", 4028, "Int", MAX_PATH, "Ptr", nppBufAddress)

	string := NPPM_ReadBuffer(hProcess, nppBufAddress, MAX_PATH)

	NPPM_CloseBuffer(hProcess, nppBufAddress)

	return string
}

NPPM_GETEXTPART() ; 4029
{
	; string receives the part of extension of current Scintilla view document.
  ; User is responsible to allocate (or use automatic variable) a buffer with an enough size.
  ; MAX_PATH is suggested to use.

  MAX_PATH := 260 * (A_IsUnicode ? 2 : 1)

	hNpp := Nppm_Hwnd()

	openProcSuccess := NPPM_OpenBuffer(hProcess, nppBufAddress, MAX_PATH)

	if (WinExist("ahk_id " . hNpp) == 0) OR (openProcSuccess == 0)
		return

	DllCall("SendMessage", "Ptr", hNpp, "UInt", 4029, "Int", MAX_PATH, "Ptr", nppBufAddress)

	string := NPPM_ReadBuffer(hProcess, nppBufAddress, MAX_PATH)

	NPPM_CloseBuffer(hProcess, nppBufAddress)

	return string
}

NPPM_GETCURRENTWORD() ; 4030
{
  ; string receives the word on which cursor is currently of current Scintilla view document.
  ; User is responsible to allocate (or use automatic variable) a buffer with an enough size.
  ; MAX_PATH is suggested to use.

	MAX_PATH := 260 * (A_IsUnicode ? 2 : 1)

	hNpp := Nppm_Hwnd()

	openProcSuccess := NPPM_OpenBuffer(hProcess, nppBufAddress, MAX_PATH)

	if (WinExist("ahk_id " . hNpp) == 0) OR (openProcSuccess == 0)
		return

	DllCall("SendMessage", "Ptr", hNpp, "UInt", 4030, "Int", MAX_PATH, "Ptr", nppBufAddress)

	string := NPPM_ReadBuffer(hProcess, nppBufAddress, MAX_PATH)

	NPPM_CloseBuffer(hProcess, nppBufAddress)

	return string
}

NPPM_GETNPPDIRECTORY() ; 4031
{
  ; string receives the full path of directory where located Notepad++ binary.
  ; User is responsible to allocate (or use automatic variable) a buffer with an enough size.
  ; MAX_PATH is suggested to use.

	MAX_PATH := 260 * (A_IsUnicode ? 2 : 1)

	hNpp := Nppm_Hwnd()

	openProcSuccess := NPPM_OpenBuffer(hProcess, nppBufAddress, MAX_PATH)

	if (WinExist("ahk_id " . hNpp) == 0) OR (openProcSuccess == 0)
		return

	DllCall("SendMessage", "Ptr", hNpp, "UInt", 4031, "Int", MAX_PATH, "Ptr", nppBufAddress)

	string := NPPM_ReadBuffer(hProcess, nppBufAddress, MAX_PATH)

	NPPM_CloseBuffer(hProcess, nppBufAddress)

	return string
}

NPPM_GETCURRENTLINE() ; 4032
{
	; Returns the caret current position 0-based line

  ; Line numbers are zero-based
	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 4032 , "Int", 0, "Int", 0)
}

NPPM_GETCURRENTCOLUMN() ; 4033
{
	; Returns the caret current position 0-based column

  ; Column numbers are zero-based
	return DllCall("SendMessage", "Ptr", Nppm_Hwnd(), "UInt", 4033 , "Int", 0, "Int", 0)
}

NPPM_GETNPPFULLFILEPATH() ; 4034
{
	MAX_PATH := 260 * (A_IsUnicode ? 2 : 1)

	hNpp := Nppm_Hwnd()

	openProcSuccess := NPPM_OpenBuffer(hProcess, nppBufAddress, MAX_PATH)

	if (WinExist("ahk_id " . hNpp) == 0) OR (openProcSuccess == 0)
		return

	DllCall("SendMessage", "Ptr", hNpp, "UInt", 4034, "Int", MAX_PATH, "Ptr", nppBufAddress)

	string := NPPM_ReadBuffer(hProcess, nppBufAddress, MAX_PATH)

	NPPM_CloseBuffer(hProcess, nppBufAddress)

	return string
}

Nppm_HWND(Title := "Notepad++"){
	return DllCall("FindWindow", "Str", Title, "Int", 0, "Ptr")
}

;functions:
; https://www.scintilla.org/ScintillaDoc.html
;code of functions:
; https://sourceforge.net/p/scintilla/feature-requests/1165/attachment/Scintilla.h

SCI_HWND(){
  ControlGet hSci, Hwnd,, Scintilla1, % "ahk_id" Nppm_HWND()
  Return hSci
}
SCI_SETFIRSTVISIBLELINE(line){
  Return DllCall("SendMessage", "Ptr", SCI_HWND(), "UInt", 2613 , "Int", Line - 1, "Int", 0)
}
SCI_GETFIRSTVISIBLELINE(){
  Return DllCall("SendMessage", "Ptr", SCI_HWND(), "UInt", 2152 , "Int", 0, "Int", 0) + 1
}
SCI_GETCURRENTPOS(){
  Return DllCall("SendMessage", "Ptr", SCI_HWND(), "UInt", 2008 , "Int", 0, "Int", 0)
}
SCI_LINESONSCREEN(){
  Return DllCall("SendMessage", "Ptr", SCI_HWND(), "UInt", 2370 , "Int", 0, "Int", 0)
}
SCI_GotoLine(Line){
  DllCall("SendMessage", "Ptr", SCI_HWND(), "UInt", 2024 , "Int", Line - 1, "Int", 0)
}
SCI_GOTOPOS(Pos){
  DllCall("SendMessage", "Ptr", SCI_HWND(), "UInt", 2025 , "Int", Pos, "Int", 0)
}
SCI_SCROLLCARET(){
  DllCall("SendMessage", "Ptr", SCI_HWND(), "UInt", 2169 , "Int", , "Int", 0)
}
SCI_LINELENGTH(Line){
  Return DllCall("SendMessage", "Ptr", SCI_HWND(), "UInt", 2350 , "Int", Line - 1, "Int", 0)
}
SCI_GETSELTEXT(){  ;2161
; SCI_GETSELTEXT(<unused>, char *text NUL-terminated) ? int
; This copies the currently selected text and a terminating 0 byte to the text buffer. The buffer size should be determined by calling with a NULL pointer for the text argument SCI_GETSELTEXT(0,0). This allows for rectangular and discontiguous selections as well as simple selections. See Multiple Selection for information on how multiple and rectangular selections and virtual space are copied.

  BufferSize := DllCall("SendMessage", "Ptr", SCI_HWND(), "UInt", 2161 , "UInt", 0 , "UInt", 0)
  BufferSize := BufferSize * (A_IsUnicode ? 2 : 1)

	hNpp := Nppm_Hwnd()

	openProcSuccess := NPPM_OpenBuffer(hProcess, nppBufAddress, BufferSize)

	if (WinExist("ahk_id " . hNpp) == 0) OR (openProcSuccess == 0)
		return

	DllCall("SendMessage", "Ptr", SCI_HWND(), "UInt", 2161, "Int", 0, "Ptr", nppBufAddress)

	string := NPPM_ReadBuffer(hProcess, nppBufAddress, BufferSize, "Text")

	NPPM_CloseBuffer(hProcess, nppBufAddress)

	return string
}
SCI_REPLACESEL(text){ ;2170
; SCI_REPLACESEL(<unused>, const char *text)
; The currently selected text between the anchor and the current position is replaced by the 0 terminated text string. If the anchor and current position are the same, the text is inserted at the caret position. The caret is positioned after the inserted text and the caret is scrolled into view.

  Output := NPPM_ConvertToUTF8(Text, BufferSize)

	hNpp := Nppm_Hwnd()

	openProcSuccess := NPPM_OpenBuffer(hProcess, nppBufAddress, BufferSize)

	if (WinExist("ahk_id " . hNpp) == 0) OR (openProcSuccess == 0)
		return

  NPPM_WriteProcessMemory(hProcess, nppBufAddress, Output, BufferSize)

	DllCall("SendMessage", "Ptr", SCI_HWND(), "UInt", 2170, "Int", 0, "Ptr", nppBufAddress)

	NPPM_CloseBuffer(hProcess, nppBufAddress)

}

; SCI_GETLINE(Line){
  ; VarSetCapacity(LineText, (A_IsUnicode?2:1) * SCI_LINELENGTH(Line))
  ; Int := DllCall("SendMessage", "Ptr", SCI_HWND(), "UInt", 2153 , "Int", Line - 1, "Ptr", *LineText)
  ; LineText := NumGet(&LineText)
  ; Return LineText "`n" Int
  ; Return DllCall("SendMessage", "Ptr", SCI_HWND(), "UInt", 2153 , "Int", Line - 1, "Int", 0)
; }

NPPM_Langs(lang)
{  ;??? make langs static
	langs := { "TEXT"     : 0,   "PYTHON"    : 22,  "MATLAB"       : 44,  "AVS"          : 66
			,  "PHP"      : 1,   "LUA"       : 23,  "HASKELL"      : 45,  "BLITZBASIC"   : 67
			,  "C"        : 2,   "TEX"       : 24,  "INNO"         : 46,  "PUREBASIC"    : 68
			,  "CPP"      : 3,   "FORTRAN"   : 25,  "SEARCHRESULT" : 47,  "FREEBASIC"    : 69
			,  "CS"       : 4,   "BASH"      : 26,  "CMAKE"        : 48,  "CSOUND"       : 70
			,  "OBJC"     : 5,   "FLASH"     : 27,  "YAML"         : 49,  "ERLANG"       : 71
			,  "JAVA"     : 6,   "NSIS"      : 28,  "COBOL"        : 50,  "ESCRIPT"      : 72
			,  "RC"       : 7,   "TCL"       : 29,  "GUI4CLI"      : 51,  "FORTH"        : 73
			,  "HTML"     : 8,   "LISP"      : 30,  "D"            : 52,  "LATEX"        : 74
			,  "XML"      : 9,   "SCHEME"    : 31,  "POWERSHELL"   : 53,  "MMIXAL"       : 75
			,  "MAKEFILE" : 10,  "ASM"       : 32,  "R"            : 54,  "NIMROD"       : 76
			,  "PASCAL"   : 11,  "DIFF"      : 33,  "JSP"          : 55,  "NNCRONTAB"    : 77
			,  "BATCH"    : 12,  "PROPS"     : 34,  "COFFEESCRIPT" : 56,  "OSCRIPT"      : 78
			,  "INI"      : 13,  "PS"        : 35,  "JSON"         : 57,  "REBOL"        : 79
			,  "ASCII"    : 14,  "RUBY"      : 36,  "JAVASCRIPT"   : 58,  "REGISTRY"     : 80
			,  "USER"     : 15,  "SMALLTALK" : 37,  "FORTRAN_77"   : 59,  "RUST"         : 81
			,  "ASP"      : 16,  "VHDL"      : 38,  "BAANC"        : 60,  "SPICE"        : 82
			,  "SQL"      : 17,  "KIX"       : 39,  "SREC"         : 61,  "TXT2TAGS"     : 83
			,  "VB"       : 18,  "AU3"       : 40,  "IHEX"         : 62,  "VISUALPROLOG" : 84
			,  "JS"       : 19,  "CAML"      : 41,  "TEHEX"        : 63,  "EXTERNAL"     : 85
			,  "CSS"      : 20,  "ADA"       : 42,  "SWIFT"        : 64,  "PERL"         : 21
			,  "VERILOG"  : 43,  "ASN1"      : 65 }
	return langs[lang]
}

Nppm_OpenBuffer(ByRef hProcess, ByRef nppBufAddress, nppBufBytes)
{
	NppPID := NPPM_PID()
  If WinExist("ahk_pid " . NppPID)
	{
		; Retrieve a handle to the N++ process so we can operate within its memory space
		hProcess := DllCall("OpenProcess"
							, "UInt", ( PROCESS_VM_OPERATION := 0x8 | PROCESS_VM_READ := 0x10 | PROCESS_VM_WRITE := 0x20)
							, "Int" , false
							, "UInt", NppPID
							, "Ptr")

		; Allocate a remote buffer in N++'s memory space
		nppBufAddress := DllCall("VirtualAllocEx"
								, "UInt", hProcess
								, "Int" , 0
								, "Int" , nppBufBytes
								, "Int" , MEM_COMMIT := 0x1000
								, "Int" , PAGE_READWRITE := 0x4
								, "Ptr" )
	}
	return  hProcess AND nppBufAddress ? true : false
}

NPPM_ConvertToUTF8(Text, ByRef BufferSize){
  BufferSize := StrPut(Text, "UTF-8")
	vOutput := ""
	VarSetCapacity(vOutput, BufferSize+1, 0)
	StrPut(Text, &vOutput, "UTF-8")
  Return vOutput
}

NPPM_WriteProcessMemory(hProcess, nppBufAddress, Output, BufferSize){
  DllCall("kernel32\WriteProcessMemory"
                 , "Ptr" , hProcess
                 , "Ptr" , nppBufAddress
                 , "Ptr" , &Output
                 , "UPtr", BufferSize
                 , "Ptr" , 0)
}


Nppm_ReadBuffer(ByRef hProcess, ByRef nppBufAddress, bytesToRead, isType := "")
{
	; Ensure there's enough space allocated in a local buffer
	VarSetCapacity(stringFromNpp, bytesToRead, 0)

	; Fill local buffer 'stringFromNpp' with 'bytesToRead' number of bytes from remote buffer 'nppBufAddress'
	DllCall("ReadProcessMemory", "Ptr", hProcess, "Ptr", nppBufAddress, "Ptr", &stringFromNpp, "UInt", bytesToRead, "UInt", 0)

	If (isType = "Number")
		stringFromNpp := NumGet(stringFromNpp)
  Else If (isType = "Text")
    stringFromNpp := StrGet(&stringFromNpp, "UTF-8")

	; Resize var to fit the size of its contents because the value will likely be less than bytesToRead
	VarSetCapacity(stringFromNpp, -1)

	return stringFromNpp
}

; F7::
  ; MsgBox % NPPM_GETNPPFULLFILEPATH() "`n"
         ; . NPPM_GETNPPDIRECTORY() "`n"
         ; . NPPM_GETCURRENTWORD() "`n"
         ; . NPPM_GETEXTPART() "`n"
         ; . NPPM_GETFILENAMEATCURSOR() "`n"
; Return

Nppm_CloseBuffer(ByRef hProcess, ByRef nppBufAddress)
{
	; Release remote buffer because we're done accessing it
	DllCall("VirtualFreeEx", "Ptr", hProcess, "Ptr", nppBufAddress, "UInt", 0, "UInt", MEM_RELEASE := 0x8000)

	; Close the handle opened by OpenProcess
	DllCall("CloseHandle", "Ptr", hProcess)
	return
}

PIDfromHwnd(Hwnd){
  WinGet PID, PID, ahk_id %Hwnd%
  Return PID
}

Nppm_PID(TimeOutInSec := 1){
	Process, Wait, Notepad++.exe, %TimeOutInSec%
	return ErrorLevel  ;PID or 0 when timed out
}

Nppm_IsSingleView()
{
	hNpp := DllCall("FindWindow", "Str", "Notepad++", "Int", 0, "Ptr")
	hSplitter := DllCall("FindWindowEx", "Ptr", hNpp, "Int", 0, "Str", "splitterContainer", "Int", 0, "Ptr")
	return DllCall("IsWindowVisible", "Ptr", hSplitter) ? false : true
}
