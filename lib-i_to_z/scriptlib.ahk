/*
-----------------------------
UI Test Automation Library
version 1.4

Updated: Mar. 21, 2017
Created by: Feng Wu (477875@qq.com)
--------------------------------
*/

;SetWorkingDir, %A_ScriptDir%
;AHK Standard Library
#Include  ../../Lib/Gdip_All.ahk
#Include  ../../Lib/HTTPRequest.ahk
#Include  ../../Lib/StrX.ahk
#Include  ../../Lib/UnHTM.ahk
#Include  ../../Lib/json.ahk
/*
-------------------------------------Update History------------------------------
03/21/2017
Replace Gdip.ahk with Gdip_All.ahk to support AHK: 32, 64, unicode, ansi
Solve printScreen does not work with Gdip on Win10 64bit
PrtScreen / PrtFromScreen
https://autohotkey.com/boards/viewtopic.php?f=6&t=6517
02/12/2014
update WaitForImageVanish
12/08/2013
v1.4
 - separate module lib from scriptlib
 - add WX11Lib, Email libraries
 - remove ini.ahk library to improve the performance of case execution
 - add GetAllKVFromFile and GetSectionKVFromFile
 - rewrite WaitForImage, WaitForImageVanish, WaitForPixelColor, WaitForPixelColorVanish
 -

11/12/2013
change HT&LT login only via CI
LoginSPICall -> LoginSPICallV13
SendSpiCall -> SendSpiCallV13

09/23/13
1.2.3- add an API - ClearCookies
05/03/13

Update if statement

1.2.2 - 11/14/12
	Modify it to correct logic  __GetEmailIDByEmailCode
	Add 9  APIs for email testing in Outlook2007/2010
	GetFirstEmailFromOL, SearchEmailByTopicFromOL, InstantSearchEmailFromOL
	SearchEmailByTopicFromOL_AD, DeleteEmailFromOL, DeleteAllEmailsFromOL, ReceiveEmailFromOL
	GetHTMLEmailBodyFromOL, GetPlainTextEmailBodyFromOL
	Fixed: GetEmailIDByTopic - GET method in HTTPRequest is not available, so change the url
1.2.1 - 10/10/12
	Add 5 APIs
	 ParseJsonStrToArr,		GetEmailIDByTopic,	 OpenPageWithBrowser
	 EmailPageURL,	        GoToPageLinkedInEmail
1.2
	1. Add some APIs to get email templates information from free email server and verify results
ToDo:
1. Verify and Wait
2. Report
3. Configuration case dependency
4. relative path issue
1.1
	1. Rname GetHTMLSourceCode to GetHTMLCodeFromServ
	2. Add GetHTMLCodeFromClient(), GetTextFromHtml()
1.0.1
	1. modify PrtScreen() - change default directory to "capture_screen" in each module
	2. Import AHK standard library
	3. Fix GetTextFromPage() bug: if offset="", the behavior is wrong
	4. Fix GetIniFile() bug: filePattern should be file_path
	5. Add "`r`n" to error_msg
1.0
 -Fix ActiveBrowserWin timeout issue
 Add new APIs:
 - SendEmailFromOL
 - Highlight
 - CreateEmailAccount
 - GetHTMLSourceCode
0.9
 getKVObjFromIni(ini)- change the parameter
 MoveMouseToImage-remove time parameter
 WaitForImage-Add "image_dir" parameter
 Remove local
 ErrorLevel, error_message, isError
0.8
 - fix GetTextFromPage bug
 Add new APIs:
 - PrtImgFromScreen
 - EvalString(inputstr)
v0.7
 Add new APIs:
	- LoginWAPI(wapiBaseURL, username, pwd)
	- SendWAPICall(cmd, task, wapiCall)
   - ClickImage(image)
 v0.6
 Add new APIs:
  - UriEncode/UriDecode/StrPutVar
  - Spicall
 -  improve waitForImage : *n Share the same images with various browsers
 v0.5 GetTextFromPage(strReg)2.modify  parameter default value expression
 v0.4 remove offsetx,offsety from clickElement and MoveMouseToCoor
 v0.3
 GetKVObjFromIni(iniFileWithPath)
 v0.2
 add - MoveMouseToCoor
----------------------------------------------------------------------------------
 */

/*
------------------------------------Utils-----------------------------------------
	GetAllKVFromFile, 	GetSectionKVFromFile, 	GetSplittedObj,
	ShowTooltip,	CopyURLFromAddressBar, 		GoToURLByPaste, 	GetTextFromPage,
	UriEncode, 		UriDecode,					EvalString,			Highlight
    GetHTMLCodeFromServ, GetHTMLCodeFromClient, GetTextFromHtml,	GetValFromStr
	ParseJsonStrToArr
----------------------------------------------------------------------------------
*/
;-------------------------------------------------------------------------------
;
; Function: GetAllKVFromFile
; Description:
;		Generate an object which stores all keys and values of the INI file
; Syntax: GetAllKVFromFile(file_path)
; Parameters:
;       file_path - the path of the ini file
; Return Value:
;       return an object which stores all keys and values of the INI file
; Related:
;		GetSectionKVFromFile
; Example:
;	    cfgobj := GetAllKVFromFile("c:\config.ini")
;
;-------------------------------------------------------------------------------
GetAllKVFromFile(file_path) {
  obj := object()
  IniRead, secs, %file_path%
 Loop, parse, secs, `n
{
	 section_name := A_LoopField
	 IniRead, content, %file_path%, %section_name%
	Loop, parse, content, `r`n
	{
		field := A_LoopField
		StringGetPos, pos, field, `#
		if !ErrorLevel
			continue
		StringSplit, kv,  field, `=
		obj[kv1] := kv2
    }
}
	return obj
}

;-------------------------------------------------------------------------------
;
; Function: GetSectionKVFromFile
; Description:
;		Generate an object which stores keys and values belongs to specified section in the INI file
; Syntax: GetSectionKVFromFile(file_path, section_name)
; Parameters:
;       file_path - the path of the ini file
;		section_name - section name
; Return Value:
;       return an object which stores keys and values belongs to specified section in the INI file
; Related:
;		GetAllKVFromFile
; Example:
;	    secobj := GetSectionKVFromFile("c:\config.ini", "section1")
;
;-------------------------------------------------------------------------------
GetSectionKVFromFile(file_path, section_name) {
  obj := object()
  IniRead, content, %file_path%, %section_name%
  if (!content){
	msg := "[" . A_ThisFunc . "] Warring - [" . section_name . "] does not exist in [" . file_path . "]"
	Debug(msg)
	return
  }
  Loop, parse, content, `r`n
  {
	field := A_LoopField
	StringGetPos, pos, field, `#
	if !ErrorLevel
		continue
	StringSplit, kv,  field, `=
	obj[kv1] := kv2
  }
	return obj
}
;-------------------------------------------------------------------------------
;
; Function: GetSplittedObj
; Description:
;		Split string to array object
; Syntax: GetSplittedObj(str)
; Parameters:
;		str - string includes "," for example  "w,x,y, y,    z"
; Return Value:
;		array object - for example: object( 1, w, 2, x, 3, y, 4, z )
; Remarks:
; 		Real arrays don't exist in AutoHotkey. You can use global or object instead.
;		http://www.autohotkey.com/forum/topic45148.html&highlight=return+array
; 		http://www.autohotkey.com/forum/topic54446.html&postdays=0&postorder=asc&highlight=return+array&start=0
; Related: [bbcode]None.
; Example:
;		xy := GetSplittedObj(strcoors)
;		x := xy[1] y:= xy[2]
;
;-------------------------------------------------------------------------------
GetSplittedObj(str) {
	global @error_msg
	try
	{
		obj := object()
		StringSplit, arr, str, `,			; real arrays don't exist in AutoHotkey. You can use global or object instead.
		loop, %arr0%
		{
			obj[A_Index] := Trim(arr%A_Index%)
		}

		return obj
	}
	catch
	{
		@error_msg := "[" . A_ThisFunc . "] Err - Format of string is wrong [ " . str . "]`r`n"
		Gosub, ErrorLabel
	}
}

;-------------------------------------------------------------------------------
;
; Function: ShowTooltip
; Description:
;		Show tooltip for a while
; Syntax: ShowTooltip(msg[, t])
; Parameters:
;		msg - content
;		t - show t milliseconds
; Related: [bbcode]None.
; Example:
;		ShowTooltip("The script is running `n[ESC]-Stop`n[Pause]-Pause/Resume`n[PrintScreen]-Print Screen", 1000)
;
;-------------------------------------------------------------------------------
ShowTooltip(msg, t = 1000) {
	ToolTip, %msg%
	Sleep, %t%
	ToolTip

}

;-------------------------------------------------------------------------------
;
; Function: CopyURLFromAddressBar
; Description:
;		Copy URL from address bar of browser to clipboard
; Syntax: CopyURLFromAddressBar()
; Return Value:
;		URL String
; Related:
;		GoToURLByPaste
; Example:
;		url := CopyURLFromAddressBar()
;
;-------------------------------------------------------------------------------
CopyURLFromAddressBar() {
	clipboard=
	Send !d
	Sleep, 200
	Send ^c
	ClipWait, 2
	return clipboard
}

;-------------------------------------------------------------------------------
;
; Function: GoToURLByPaste
; Description:
;		Go to URL site via pasting clipboard (URL) to address bar of browser
; Syntax: GoToURLByPaste()
; Related:
;		[bbcode]CopyURLFromAddressBar
; Remarks:
;		Make sure clipboard is URL
;
;-------------------------------------------------------------------------------
GoToURLByPaste() {
	Send !d
	Sleep, 500
	Send ^v
	Sleep, 500
	Send, {Enter}
}

;-------------------------------------------------------------------------------
;
; Function: GetTextFromPage
; Description:
;		Get text in a region
; Syntax: GetTextFromPage(strcoors [, speed = "", offset = ""])
; Parameters:
;		strcoors - "x1, y1, x2, y2"
;			x1,y1: The x1/y1 coordinates of the drag's starting position
;			x2,y2: The x2/y2 coordinates to drag the mouse to
;		speed - (Optional) Mouse movement speed
;		offset - (Optional)
;			R (Default): The x1/y1 coordinates will be treated as offsets from the current mouse position
;				x2 and y2 coordinates will be treated as offsets from the x1 and y1 coordinates
;			W: Coordinates are relative to the active window (Mouse Position In active window)
; Return Value:
;		Text in the region (strcoors)
; Remarks:
;		The function is for text assertion
; Related: [bbcode]None.
; Example:
;		text := GetTextFromPage("40, 205, 100, 2")
;		text := GetTextFromPage("285,268,390,288",,"W")
;
;-------------------------------------------------------------------------------
GetTextFromPage(strcoors, speed = 15, offset = "R") {
	global @error_msg
	xys := GetSplittedObj(strcoors)

	if (offset == "R")
	{
		yy := Abs(xys[4]//2)

	}
	else
	{
		y := Abs((xys[4] - xys[2]) // 2)
		yy := xys[2] > xys[4] ? xys[2] - y : xys[2] + y
	}

	if (!!xys)
	{
		if (offset == "R")
		{
			MouseClickDrag, Left, % xys[1], xys[2], xys[3], yy, speed, R

		}
		else if (offset == "W")
		{
			MouseClickDrag, Left, % xys[1], yy, xys[3], yy, speed

		}
		else
		{
			@error_msg := "[" . A_ThisFunc . "]  Err - The parameter offset [" . offset . "] is wrong. `r`n"
			Gosub, ErrorLabel
		}

		Sleep, 200
		Send ^c
		ClipWait, 2
		return Trim(clipboard)
	}
	else
	{
		@error_msg := "[" . A_ThisFunc . "] Err - strcoors [" . strcoors . "] is wrong `r`n"
		Gosub, ErrorLabel
	}
}


;-------------------------------------------------------------------------------
;
; Function: UriEncode
; Description:
;		Encode Uri
; Syntax: UriEncode(Uri [, Enc = "UTF-8"])
; Parameters:
;		Uri - value of parameter in Uri
;		Enc - (Optional) default encoding is UTF-8
; Return Value:
;		Encode Ur
; Related:
;		UriDecode, SendSpiCall
; Example:
;		encode_wbx11Ticket := UriEncode(wbx11Ticket)
;
;-------------------------------------------------------------------------------
UriEncode(Uri, Enc = "UTF-8") {
   StrPutVar(Uri, Var, Enc)
   f := A_FormatInteger
   SetFormat, IntegerFast, H
   Loop
   {
      Code := NumGet(Var, A_Index - 1, "UChar")
      If (!Code)
         Break
      If (Code >= 0x30 && Code <= 0x39 ; 0-9
         || Code >= 0x41 && Code <= 0x5A ; A-Z
         || Code >= 0x61 && Code <= 0x7A) ; a-z
         Res .= Chr(Code)
      Else
         Res .= "%" . SubStr(Code + 0x100, -1)
   }
   SetFormat, IntegerFast, %f%
   Return, Res
}

;-------------------------------------------------------------------------------
;
; Function: UriDecode
; Description:
;		Decode Uri
; Syntax: UriDecode(Uri [, Enc = "UTF-8"])
; Parameters:
;		Uri - value of parameter in Uri
;		Enc - (Optional) default encoding is UTF-8
; Return Value:
;		Decode Uri
; Related:
;		UriEncode, SendSpiCall
; Example:
;		encode_wbx11Ticket := UriEncode(wbx11Ticket)
;		wbx11Ticket := UriDecode(encode_wbx11Ticket)
;
;-------------------------------------------------------------------------------
UriDecode(Uri, Enc = "UTF-8") {
   Pos := 1
   Loop
   {
      Pos := RegExMatch(Uri, "i)(?:%[\da-f]{2})+", Code, Pos++)
      If (Pos = 0)
         Break
      VarSetCapacity(Var, StrLen(Code) // 3, 0)
      StringTrimLeft, Code, Code, 1
      Loop, Parse, Code, `%
         NumPut("0x" . A_LoopField, Var, A_Index - 1, "UChar")
      StringReplace, Uri, Uri, `%%Code%, % StrGet(&Var, Enc), All
   }
   Return, Uri
}

;-------------------------------------------------------------------------------
;
; Function: EvalString
; Description:
;		Get the real string without variables
; Syntax: EvalString(inputstr)
; Parameters:
;		inputstr - String with variable(s)eg: "this string has ${var}"
; Return Value:
;		 Real string without variable(s) - "this string has real variable"
; Related:
;		SendSpiCall, SendWapiCall
; Example:
;		1. replace existing variables.
;		   global var := "real variable" str := "this string has ${var}" retstr := EvalString(str)  - "this string has real variable"
;		2. non-existing variable will be blank
;		   str := "this string has ${nonexistingvar}" retstr := EvalString(str) - "this string has "
;		3. getUsrinfoSPI(e)
;		  {
;			global email := e
;			__spiCall := "[{'service':'account','spi':'checkEmails','parameters':{'emails':'${email}'}}]"
;			spiCall := EvalString(__spiCall)
;			return SendSpiCall(spiCall)
;		 }
;
;-------------------------------------------------------------------------------
EvalString(inputstr) {
	pos :=1
	retstr := inputstr
	While pos:=RegExMatch(inputstr,"\${([\w]+)}", m, Pos+StrLen(m))
	{
		;retStr := RegExReplace(retStr, m, %m1%)
		StringReplace, retstr, retstr, %m%, % %m1% ;m: #var# m1: var
	}

	Debug("[" . A_ThisFunc . "] " . retstr)
	return retstr
}

;-------------------------------------------------------------------------------
;
; Function: Highlight
; Description:
;		Show a red rectangle outline to highlight specified region, it's useful to debug
; Syntax: Highlight(region [, delay = 1500])
; Parameters:
;		reg - The region for highlight
;		delay - Show time (milliseconds)
; Return Value:
;		 Real string without variable(s) - "this string has real variable"
; Related:
;		SendSpiCall, SendWapiCall
; Remarks:
;		#Include, Gdip.ahk
; Example:
;		Highlight("100,200,300,400")
;		Highlight("100,200,300,400", 1000)
;
;-------------------------------------------------------------------------------
Highlight(reg, delay=1500 {

	global @reg_global
; Start gdi+
	If !pToken := Gdip_Startup()
	{
		MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
		ExitApp
	}

	StringSplit, g_coors, @reg_global, `,
	; Set the width and height we want as our drawing area, to draw everything in. This will be the dimensions of our bitmap
	Width := g_coors3
	Height := g_coors4
    ; Create a layered window (+E0x80000 : must be used for UpdateLayeredWindow to work!) that is always on top (+AlwaysOnTop), has no taskbar entry or caption
	Gui, 1: -Caption +E0x80000 +LastFound +OwnDialogs +Owner +AlwaysOnTop

	; Show the window
	Gui, 1: Show, NA

	; Get a handle to this window we have created in order to update it later
	hwnd1 := WinExist()

	; Create a gdi bitmap with width and height of what we are going to draw into it. This is the entire drawing area for everything
	hbm := CreateDIBSection(Width, Height)

	; Get a device context compatible with the screen
	hdc := CreateCompatibleDC()

	; Select the bitmap into the device context
	obm := SelectObject(hdc, hbm)

	; Get a pointer to the graphics of the bitmap, for use with drawing functions
	G := Gdip_GraphicsFromHDC(hdc)

	; Set the smoothing mode to antialias = 4 to make shapes appear smother (only used for vector drawing and filling)
	Gdip_SetSmoothingMode(G, 4)


	; Create a slightly transparent (66) blue pen (ARGB = Transparency, red, green, blue) to draw a rectangle
	; This pen is wider than the last one, with a thickness of 10
	pPen := Gdip_CreatePen(0xffff0000, 2)

	; Draw a rectangle onto the graphics of the bitmap using the pen just created
	; Draws the rectangle from coordinates (250,80) a rectangle of 300x200 and outline width of 10 (specified when creating the pen)

	StringSplit, reg_coors, reg, `,
	x := reg_coors1
	y := reg_coors2
	w := reg_coors3 - reg_coors1
	h := reg_coors4 - reg_coors2

	Gdip_DrawRectangle(G, pPen, x, y, w, h)

	; Delete the brush as it is no longer needed and wastes memory
	Gdip_DeletePen(pPen)

	; Update the specified window we have created (hwnd1) with a handle to our bitmap (hdc), specifying the x,y,w,h we want it positioned on our screen
	; So this will position our gui at (0,0) with the Width and Height specified earlier
	UpdateLayeredWindow(hwnd1, hdc, 0, 0, Width, Height)

	; Select the object back into the hdc
	SelectObject(hdc, obm)

	; Now the bitmap may be deleted
	DeleteObject(hbm)

	; Also the device context related to the bitmap may be deleted
	DeleteDC(hdc)

	; The graphics may now be deleted
	Gdip_DeleteGraphics(G)
	Sleep, %delay%
	Gui, 1: Show, Hide
	Gdip_Shutdown(pToken)
}

;-------------------------------------------------------------------------------
;
; Function: GetHTMLCodeFromServ
; Description:
;		Get html source code before page renderred by Javascript
; Syntax: GetHTMLCodeFromServ()
; Parameters:
;		None
; Return Value:
;		clipboard - html source code as string
; Remarks:
;		The html source is from server without executing javascript, so does not include DOM source
; 		Use GetHTMLCodeFromClient to get the whole html including DOM source
; Related:
;		GetHTMLCodeFromClient
; Example:
;		brexe := "iexplore.exe"
;		html_source_code := GetHTMLCodeFromServ()
;
;-------------------------------------------------------------------------------
GetHTMLCodeFromServ() {
   global @brexe, @error_msg
   clipboard=
   if (@brexe == "iexplore.exe")
   {
      Send, {alt down}vc{alt up}
      WinWaitActive, ahk_class SOURCE_VIEWER
      Send, ^a
      Sleep, 200
      Send, ^c
      ClipWait, 2
      WinClose, ahk_class SOURCE_VIEWER
      return clipboard
   }
   else if (@brexe == "firefox.exe")
   {
      Send, ^u
      WinWaitActive, Source of:,,1
      Send, ^a
      Sleep, 200
      Send, ^c
      ClipWait, 2
      WinClose
      return clipboard
   }
   else if (@brexe == "chrome.exe")
   {
      Send, ^u
      WinWaitActive, view-source:,,1
      Send, ^a
      Sleep, 200
      Send ^c
      ClipWait, 2
      Send, ^w
      Sleep, 200
      return clipboard
   }
   else
   {
     @error_msg := "[" . A_ThisFunc . "] Err - Make sure brexe [" . @brexe . "] value in sysconfig.ini is correct. `r`n"
	 Gosub, ErrorLabel
   }
}

;-----------------------------
;
; Function: GetHTMLCodeFromClient
; Description:
;		Get HTML code after page renderred completely
; Syntax: GetHTMLCodeFromClient(is_saved)
; Parameters:
;		is_saved - true: get html code from existing temporary file  false: write html code to a temporary file
; Remarks:
; 		Some time we need do verification, so need get critical information from page such as text on page, parameter value
;		from html code. the method will return html code for further handling.
; Related:
;		GetHTMLCodeFromServ, GetTextFromHtml
; Example:
;		brexe := "firefox.exe"
;		x := GetHTMLCodeFromClient(false)
;		MsgBox, %x%
;
;-------------------------------------------------------------------------------
GetHTMLCodeFromClient(is_saved) {
	if (is_saved)
	{
		FileRead, htmlcode, tmp/__htmlsource__.txt
		return htmlcode
	}
	else
	{
		IfExist, tmp/__htmlsource__.txt
			FileDelete, tmp/__htmlsource__.txt
		return __GetHTMLCodeFromBrowsers()
	}
}


__GetHTMLCodeFromBrowsers() {
	global @brexe, @error_msg
	Clipboard := ""
	if (@brexe == "chrome.exe")
	{
		Send, {F12}
		Sleep, 1500
		Send, ^c
		ClipWait, 1
		Send, {F12}

	}
	else if (@brexe == "firefox.exe")
	{
		Send, ^a
		Sleep, 500
		MouseClick, right
		Sleep, 500
		Send, {e}
		Sleep, 1000
		WinGet, active_id, ID, A
		Send, ^c
		ClipWait, 1
		WinClose, ahk_id %active_id%		; close source code window
		Sleep, 500
		MouseClick, left, 1,250
		Sleep, 500
	}
	else if (@brexe == "iexplore.exe")
	{
		Send, {F12}
		Sleep, 1500
		WinWaitActive, ahk_class IEDEVTOOLS,,2
		Send, ^g
		WinWaitActive, ahk_class HTMLSOURCEVIEW,,5
		Send, ^a
		Sleep, 500
		Send, ^c
		ClipWait, 1
		WinClose
		WinClose, ahk_class IEDEVTOOLS
	}
	else
	{
	 ; Debug("[" . A_ThisFunc . "] Err - Make sure brexe [" . @brexe . "] value in sysconfig.ini is correct. `r`n" )
	 ;return
	 @error_msg := "[" . A_ThisFunc . "] Err - Make sure brexe [" . @brexe . "] value in sysconfig.ini is correct. `r`n"
	 Gosub, ErrorLabel

	}

FileAppend, %Clipboard%, tmp/__htmlsource__.txt
return Clipboard

}

;-----------------------------
;
; Function: GetTextFromHtml
; Description:
;		Get text (innerText) from html code, html tag will be removed
; Syntax: GetTextFromHtml(html, begin_html_str, end_html_str)
; Parameters:
;		html - html code
;		begin_html_str - any html before matched text
; 		end_html_str  - any html after matched text
; Remarks:
;		1. The method is usually to get innertext in html
;		2. Both beginHtmlStr and endHtmlStr are included in the string returned by StrX
; Related:
;		GetHTMLCodeFromServ, GetHTMLCodeFromClient, GetValFromStr
; Example:
;		Example 1:
;		 html := "<li class=""nav_home"" module=""home""><a href=""/collabs/#/home"" class=""btn"" data-monitor-id=""headerHome""><span>Home</span></a></li>"
;		 home := GetTextFromHtml(html, "<li", "</li>") ; return Home
;		 home := GetTextFromHtml(html, "<li class=""nav_home"" module=""home"">", "</li>") ;return Home
;
;-------------------------------------------------------------------------------
GetTextFromHtml(html, begin_html_str, end_html_str) {
	return UnHTM(StrX(html, begin_html_str, N, 0, end_html_str, 1, 0, N))	; Both beginHtmlStr and endHtmlStr are included in the string returned by StrX
}

;-----------------------------
;
; Function: GetValFromStr
; Description:
;		Get paramter value from string or html text, html tag will be removed
; Syntax: GetValFromStr(str, beginStr, endStr)
; Parameters:
;		str - string or html text
;		beginStr - any string before matched text
; 		endStr	- any string after matched text
; Remarks:
;		1. The method is usually to get parameter's value in html or sub-String between beginStr and endStr
;		2. Both beginStr and endStr are excluded from the string returned by StrX
; Related:
;		GetHTMLCodeFromServ, GetHTMLCodeFromClient, GetTextFromHtml
; Example:
;		Example 1:
;		html =
;			(`
;				<li class="nav_home" module="home"><a href="/collabs/#/home" class="btn" data-monitor-id="headerHome"><span>Home</span></a></li>
;			)
;		 home := GetValFromStr(html, "<li class=""nav_home"" module=""home"">", "</li>") 	;return Home
;		Example 2:
;		 a =
;		 (`
;	      <script type="text/javascript">
;		  var WBX_HEADER = {
;		  'baseUrl': 'https://wlc.webex.com' + '/',
;		  'cover':'https://bt3.ciscowebex.com/collabs/resource/images/support/shedule_video_4.png',
;		  'playUrl':'/players/video/hqvideo.swf',
;		  'loginUserID': "UF34GWCXFLNHV65WBQ347YIUZE-1BZ"
;		 }
;		 ...
;		 </script>
;		)
;		 playUrlValue := GetValFromStr(a, "'playUrl':'", "',") ; return /players/video/hqvideo.swf
;
;-------------------------------------------------------------------------------
GetValFromStr(str, beginStr, endStr) {
	return UnHTM(StrX(str, beginStr, N, StrLen(beginStr), endStr, 1, strLen(endStr), N))   ; both beginStr and endStr are excluded from the string returned by StrX
}


;-----------------------------
;
; Function: ParseJsonStrToArr(v1.2.1)
; Description:
;		Parse Json string to an array
; Syntax: ParseJsonStrToArr(json_data)
; Parameters:
;       json_data - json string
; Return Value:
;		return an array
; Remarks:
;		Each item in the array still is string type
; Related:
;		N/A
; Example:
;		j := "[{'id':'a1','subject':'s1'},{'id':'a2','subject':'s2},{'id':'a3','subject':'s3'}]"
;		arr = ParseJsonStrToArr(j)
;
;-------------------------------------------------------------------------------

ParseJsonStrToArr(json_data) {
   arr := []
   pos :=1
   While pos:=RegExMatch(json_data,"((?:{)[\s\S][^{}]+(?:}))", j, pos+StrLen(j))
   {
	arr.Insert(j1)                      ; insert json string to array  arr=[{"id":"a1","subject":"s1"},{"id":"a2","subject":"s2"},{"id":"a3","subject":"s3"}]
   }
   return arr
}

/*
------------------------------------Core----------------------------------------
	WaitForImage, 				WaitForImageVanish, 	WaitForPixelColor,
	WaitForPixelColorVanish, 	OpenSiteWithBrowser, 	ClearCookies
	ActiveBrowserWin, 			PrtScreen, 				PrtFromScreen,
	Debug

-------------------------------------------------------------------------------
*/
;-------------------------------------------------------------------------------
;
; Function: WaitForImage
; Description:
;       Search the image in some region
; Syntax: WaitForImage(i_keyimage [, i_reg, i_timeout, n])
; Parameters:
;		i_keyimage - the key image for searching
;		i_reg - the search region, the default is fullscreen(0, 0, 1440, 900)
;		i_timeout - searching the key image should be in the specified time
;		n - Specify for n a number between 0 (accurately represent an image)and 255 (does not accurately)
;           to indicate the allowed number of shades of variation in either direction for the intensity of the red, green,
;           and blue components of each pixel's color. For example, *2 would allow two shades of variation
; Return Value:
;		[FoundX,FoundY] if found keyimage otherwise return none
; Remarks:
;		1. The same image on the IE/FF/Chrome/.. are different, so need prepare to key image on different browsers
; Related: [bbcode] WaitForImageVanish, WaitForPixelColor, WaitForPixelColorVanish
; Example:
;		logoXY := WaitForImage("wbxlogo.png", "0, 0, 1440, 900", 10000, 50)
;
;-------------------------------------------------------------------------------
WaitForImage(ByRef i_keyimage, i_reg = "", i_timeout = "", n = 50) {
   global @reg_global, @timeout, @image_dir, @isDebug, @error_msg
   i_reg := i_reg ? i_reg : @reg_global
   i_timeout := i_timeout ? i_timeout : @timeout
   i_img_fullpath := @image_dir . "/" . i_keyimage
   i_start := A_TickCount
   i_coords := []
   n := n == "" ? 50 : n
   StringSplit, coords, i_reg, `,
   Debug(coords1)
   Loop
   {
      ImageSearch, foundX, foundY, %coords1%, %coords2%, %coords3%, %coords4%, *%n% %i_img_fullpath%
      if (ErrorLevel = 0)
	  {
		 if(@isDebug and !!i_reg)
		 {
			Highlight(i_reg)
		 }
         i_coords.Insert(foundX)
		 i_coords.Insert(foundY)
         return i_coords
      }
	  if (ErrorLevel = 2)
	  {
		 @error_msg := "[" . A_ThisFunc . "] Err - [" . i_img_fullpath . "] Could not conduct the search. (such as failure to open the image file or a badly formatted option)."
		 gosub, ErrorLabel
		 i_keyimage := ""
		 return
	  }
      If (A_TickCount - i_start >= i_timeout)
	  {
		 @error_msg := "[" . A_ThisFunc . "] Err - [" . i_img_fullpath . "] was not found in " . i_timeout . " ms `r`n"
		 gosub, ErrorLabel
         i_keyimage := ""
	     return
      }
   }
}

;-------------------------------------------------------------------------------
;
; Function: WaitForImageVanish
; Description:
;		Wait for the image vanish in some region
; Syntax: WaitForImageVanish(i_keyimage [, i_reg, i_timeout, n])
; Parameters:
;       i_keyimage - the key image for searching, default image directory is set by "@image_dir" in sysconfig.ini
;		i_reg - the search region, the default is fullscreen(0, 0, 1440, 900)
;		i_timeout - searching the key image should be in the specified time
;		n - Specify for n a number between 0 (accurately represent an image)and 255 (does not accurately)
;       	to indicate the allowed number of shades of variation in either direction for the intensity of the red, green,
;           and blue components of each pixel's color. For example, *2 would allow two shades of variation
; Return Value:
; 		None
; Remarks:
; 		1. The same image on the IE/FF/Chrome/.. are different, so need prepare to key image on different browsers[br]
; Related:
;		[bbcode] WaitForImage, WaitForPixelColor, WaitForPixelColorVanish
; Example:
;       WaitForImageVanish("wbxlogo.png", "0, 0, 1440, 900", 10000, 50)
;
;-------------------------------------------------------------------------------
WaitForImageVanish(ByRef i_keyimage, i_reg = "", i_timeout = "", n = 50) {
   global @reg_global, @timeout, @image_dir, @isDebug, @error_msg
   i_reg := i_reg ? i_reg : @reg_global
   i_timeout := i_timeout ? i_timeout : @timeout
   i_img_fullpath := @image_dir . "/" . i_keyimage
   i_start := A_TickCount
   i_coords := []
   n := n == "" ? 50 : n
   StringSplit, coords, i_reg, `,
   if(@isDebug and !!i_reg)
	{
		Highlight(i_reg)
	}
   While A_TickCount - i_start <= i_timeout
   {
      ImageSearch, foundX, foundY, %coords1%, %coords2%, %coords3%, %coords4%, *%n% %i_img_fullpath%
      if (ErrorLevel = 0)
	  {
		Sleep, 1000
		continue
      }
	  if (ErrorLevel = 2)
	  {
		@error_msg := "[" . A_ThisFunc . "] Err - [" . i_img_fullpath . "] Could not conduct the search. (such as failure to open the image file or a badly formatted option)."
		gosub, ErrorLabel
		i_keyimage := ""
		return
	  }
	  if (ErrorLevel = 1)
	  {
		return
	  }

   }
   @error_msg := "[" . A_ThisFunc . "] Err - [" . i_img_fullpath . "] was still found in " . i_timeout . " ms `r`n"
   gosub, ErrorLabel
   return
}

;-------------------------------------------------------------------------------
;
; Function: WaitForPixelColor
; Description:
;		Search special color in some region
; Syntax: WaitForPixelColor(p_colorid [, p_reg, p_timeout])
; Parameters:
;		p_colorid - The decimal or hexadecimal color ID to search for, in [b]Blue-Green-Red (BGR)[/b] format,
;			which can be an expression. Color IDs can be determined using Window Spy (accessible from the tray menu)
;			or via PixelGetColor. For example: 0x9d6346
;		p_reg - Search region
;		p_timeout - searching the colorid should be in the specified time
; Return Value:
;		[FoundX,FoundY] if found colorid otherwise return none
; Remarks:
; 		1. The colorid on the IE/FF/Chrome/.. are different, so need prepare to each colorid on different browsers
; Related:
;		[bbcode] WaitForImage,WaitForImageVanish, WaitForPixelColorVanish
; Example:
;       pixelXY := WaitForPixelColor("0x24B577", "100, 200, 200, 400", 10000)
;
;-------------------------------------------------------------------------------
WaitForPixelColor(ByRef p_colorid, p_reg, p_timeout = "") {
   global @timeout, @isDebug, @error_msg
   p_timeout := p_timeout ? p_timeout : @timeout
   p_start := A_TickCount
   p_coords := []

   StringSplit, coords, p_reg, `,
   Loop
   {
	  PixelSearch, foundX, foundY, %coords1%, %coords2%, %coords3%, %coords4%, %p_colorid%,,Fast RGB
      if (!ErrorLevel)
	  {
		if(@isDebug)
		{
			Highlight(p_reg)
		}
         p_coords.Insert(foundX)
		 p_coords.Insert(foundY)
         return p_coords
      }
      If (A_TickCount - p_start >= p_timeout)
	  {
	     p_colorid := 0
		 @error_msg := "[" . A_ThisFunc . "] Err - [" . p_colorid . "] was not found in " . p_timeout . " ms `r`n"
		 gosub, ErrorLabel
		 return
      }
   }
}

;-------------------------------------------------------------------------------
;
; Function: WaitForPixelColorVanish
; Description:
;		searching the colorid is NOT in some region in the specified time
; Syntax: WaitForPixelColorVanish(p_colorid [, p_reg, p_timeout])
; Parameters:
;		p_colorid - The decimal or hexadecimal color ID to search for, in [b]Blue-Green-Red (BGR)[/b] format,
;			which can be an expression. Color IDs can be determined using Window Spy (accessible from the tray menu)
;			or via PixelGetColor. For example: 0x9d6346
;		p_reg - the search region, the default is fullscreen(0, 0, 1440, 900)
;		p_timeout - the time for searching the colorid
; Return Value:
;		None
; Remarks:
; 		1. The colorid on the IE/FF/Chrome/.. are different, so need prepare to each colorid on different browsers
; Related:
;		[bbcode] WaitForImage, WaitForImageVanish, WaitForPixelColor
; Example:
;		pixelXY := WaitForPixelColor("0x24B577", "0, 0, 1440, 900", 10000)
;
;-------------------------------------------------------------------------------
WaitForPixelColorVanish(ByRef p_colorid, p_reg, p_timeout = "") {
   global @timeout, @isDebug, @error_msg
   p_timeout := p_timeout ? p_timeout : @timeout
   p_start := A_TickCount
   p_coords := []
   if(@isDebug)
	{
		Highlight(p_reg)
	}
   StringSplit, coords, p_reg, `,
   While A_TickCount - p_start <= p_timeout
   {
	 PixelSearch, foundX, foundY, %coords1%, %coords2%, %coords3%, %coords4%, %p_colorid%,,Fast RGB
     if (!ErrorLevel)
	 {
		@error_msg := "[" . A_ThisFunc . "] Err - [" . p_colorid . "] was still found in " . p_timeout . " ms `r`n"
		gosub, ErrorLabel
		return
      }
	  else
	  {
		sleep, 1000
	  }

   }
}
;-------------------------------------------------------------------------------
;
; Function: OpenSiteWithBrowser
; Description:
;		 Open the special browser to load site URL
; Syntax: OpenSiteWithBrowser()
; Remarks:
; 		brexe - iexplore.exe/firefox.exe/chrome.exe
; Related:
;		[bbcode] OpenPageWithBrowser, ActiveBrowserWin
; Example:
;		brexe := "iexplore.exe"
;		site_url := "www.webex.com"
;		OpenSiteWithBrowser()
;
;-------------------------------------------------------------------------------
OpenSiteWithBrowser() {
	global @brexe, @site_url, @error_msg

 	try
	{
		run, %@brexe% %@site_url% ,,Max								; avoid special browser has not been installed
	}catch e{

		@error_msg := "[" . A_ThisFunc . "] Err - Make sure the  [" . @brexe . "] has been installed on your computer. `r`n"
		Gosub, ErrorLabel

	}

	ActiveBrowserWin()
	;SendMessage, 0x112, 0xF030,,, A
}

;-------------------------------------------------------------------------------
;
; Function: OpenPageWithBrowser (1.2.1)
; Description:
;		Open the special browser to load a page
; Syntax: OpenPageWithBrowser(page_url)
; Remarks:
; 		brexe - iexplore.exe/firefox.exe/chrome.exe
;		page_url - page url
; Related:
;		[bbcode] OpenSiteWithBrowser, ActiveBrowserWin
; Example:
;		brexe := "iexplore.exe"
;		page_url := "http://bk.qa.webex.com/freemail/?cmd=view&messid=sp102%40sprt66.com4829946841861472"
;		OpenPageWithBrowser(page_url)
;
;-------------------------------------------------------------------------------
OpenPageWithBrowser(page_url) {
	global @brexe, @error_msg

 	try
	{
		run, %@brexe% %page_url% ,,Max								; avoid special browser has not been installed
	}catch e{

		@error_msg := "[" . A_ThisFunc . "] Err - Make sure the  [" . @brexe . "] has been installed on your computer. `r`n"
		Gosub, ErrorLabel

	}

	ActiveBrowserWin()
	;SendMessage, 0x112, 0xF030,,, A
}


__ClearIECookes() {
 /*
  InteCpl.cpl - control panel file
  clear IE temporary internate files
  RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 8
  clear cookies
  RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 2
  clear history record
  RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 1
  clear form data
  RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 16
  clear password
  RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 32
  clear all items above
  RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 255
  clear all including data loaded by others
  RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 4351
  */
    RunWait, rundll32.exe InetCpl.cpl`,ClearMyTracksByProcess 2
}


__GetCachePath(brow) {
   if(brow == "ff"){
      ff_cache_path := A_OSVersion = "WIN_7" ? "C:\Users\" .  A_UserName . "\AppData\Roaming\Mozilla\Firefox\Profiles"
                     : A_OSVersion = "WIN_XP" ? "C:\Documents and Settings\" .  A_UserName . "\Application Data\Mozilla\Firefox\Profiles"
                     : "Undefined"

      Loop, %ff_cache_path%\*.default,  2
      {
          return  ff_cache_path . "\" . A_LoopFileName
      }


   } else if (brow == "ch"){
      return ch_cache_path :=  A_OSVersion = "WIN_7" ? "C:\Users\" . A_UserName . "\AppData\Local\Google\Chrome\User Data\Default"
                     : A_OSVersion = "WIN_XP" ? "C:\Documents and Settings\" . A_UserName . "\Local Settings\Application Data\Google\Chrome\User Data\Default"
                     : "Undefined"
   }else{
      return "ie"
   }
}

__ClearFireFoxCookes() {
	global @error_msg
   ff_cache_path := __GetCachePath("ff")
   if (ff_cache_path != "Undefined"){
      ; Two files will be generated automatically via restart Firefox
      ; FileDelete, %ff%\signons.sqlite
      FileDelete, %ff_cache_path%\cookies.sqlite
      if A_LastError
      {
		@error_msg := "[" . A_ThisFunc . "] Err - Clear Firefox cookies failed! Please close Firefox and try again. `r`n"
		Gosub, ErrorLabel
      }
   }else{
		@error_msg := "[" . A_ThisFunc . "] Err - Clear Firefox cookies failed! Only support on Win7 and WinXP.`r`n"
		Gosub, ErrorLabel
   }
}

__ClearChromeCookes() {
	global @error_msg
   ch_cache_path := __GetCachePath("ch")
   if (ch_cache_path != "Undefined"){
      FileDelete, %ch_cache_path%\Cookies
      FileDelete, %ch_cache_path%\Current Session
      FileDelete, %ch_cache_path%\Cookies-journal
      if A_LastError
      {
        @error_msg := "[" . A_ThisFunc . "] Err - Clear Chrome cookies failed! `n`nPlease close Chrome and try again.`r`n"
		Gosub, ErrorLabel

      }
   }else{
		@error_msg := "[" . A_ThisFunc . "] Err - Clear Chrome cookies failed! - only support on Win7 and WinXP.`r`n"
		Gosub, ErrorLabel

   }
}

;-------------------------------------------------------------------------------
;
; Function: ClearCookies (v1.2.3)
; Description:
;		Clear browser's cookies
; Syntax: ClearCookies()
; Remarks:
;		Tested by WinXP and Win7
; Related:
;		[bbcode]OpenSiteWithBrowser [bbcode]OpenPageWithBrowser
;
;-------------------------------------------------------------------------------
ClearCookies() {
	global @brexe
   if (@brexe == "iexplore.exe"){
      __ClearIECookes()
   }
   if (@brexe == "firefox.exe"){
      __ClearFireFoxCookes()
   }
   if (@brexe == "chrome.exe"){
      __ClearChromeCookes()
   }

}

;-------------------------------------------------------------------------------
;
; Function: ActiveBrowserWin
; Description:
;		Active browser
; Syntax: ActiveBrowserWin()
; Remarks:
; 		The function is invoked by OpenSiteWithBrowser
; Related:
;		[bbcode] OpenSiteWithBrowser
;
;-------------------------------------------------------------------------------
ActiveBrowserWin() {
	global @brexe, @timeout, @error_msg

	if (@brexe == "iexplore.exe")
	{
		WinWaitActive, ahk_class IEFrame,,%@timeout%/1000

	}
	else if (@brexe == "firefox.exe")
	{
		WinWaitActive, ahk_class MozillaWindowClass,,%@timeout%/1000

	}
	else if (@brexe == "chrome.exe")
	{
		WinWaitActive, ahk_class Chrome_WidgetWin_1,,%@timeout%/1000

	}
	else
	{
		@error_msg := "[" . A_ThisFunc . "] Err - Make sure brexe [" . brexe . "] value in sysconfig.ini is correct. `r`n"
		Gosub, ErrorLabel
	}

}

;-------------------------------------------------------------------------------
;
; Function: PrtScreen
; Description:
;		Capture active window screen to a file
; Syntax: PrtScreen([file_name_path = ""])
; Parameters:
;		file_name_path - (Optional) sepcified image file with path to save it
;	    	if the parameter is blank,then the screenshot will be in "capture_screen" directory
; Return Value:
;		None
; Remarks:
; 		Need Gdip_All.ahk library
; Related:
;		[bbcode] PrtFromScreen
; Example:
;		1. PrtScreen()
;		2. PrtScreen("screen.png")
;
;-------------------------------------------------------------------------------
PrtScreen(file_name_path = "") {
	global @capture_screen_path
	fpath := file_name_path ? file_name_path : (A_ScriptDir . "\" . A_Now . ".png")
	/*
	fdir := A_ScriptDir . "\" . @capture_screen_path . "\"
	fname := file_name ? file_name :  A_Now . ".png"
	fpath := fdir . fname
	*/
	pToken := Gdip_Startup()
	hwnd := WinExist("A")
	pBitmap := Gdip_BitmapFromHWND(hwnd)
	Gdip_SaveBitmapToFile(pBitmap, fpath)
	Gdip_DisposeImage(pBitmap)
	Gdip_Shutdown(pToken)
	ShowTooltip("Capture Screenshot Successfully `n" . fpath)
	return
}
;-------------------------------------------------------------------------------
;
; Function: PrtFromScreen
; Description:
;		Capture specified region screenshot to a file
; Syntax: PrtFromScreen(strcoors [, file_name_path = ""])
; Parameters:
;		strcoor - "x1,y1,x2,y2"
;			(x1, y1) is the coordinate of the upper-left corner of the rectangle
;			(x2, y2) is the coordinate of the lower right corner of the rectangle
;		file_name_path - (Optional) file_name_path - (Optional) sepcified image file with path to save it
;	    	if the parameter is blank,then the screenshot will be in "capture_screen" directory
; Return Value:
;		None
; Remarks:
; 		Need Gdip_All.ahk library
; Related:
;		[bbcode] PrtScreen
; Example:
;		PrtFromScreen("250,250,350,350", "region.png")
;
;-------------------------------------------------------------------------------
PrtFromScreen(strcoors, file_name_path = "") {
	global @error_msg
	xys := GetSplittedObj(strcoors)
	; x|y|w|h = Take specific coordinates with a width and height
	xywh := xys[1] . "|" . xys[2] . "|" . Abs(xys[3] - xys[1]) . "|" . Abs(xys[4] - xys[2])
	fpath := file_name_path ? file_name_path : (A_ScriptDir . "\" . A_Now . ".png")
	if(!!xys)
	{
		pToken := Gdip_Startup()
		pBitmap := Gdip_BitmapFromScreen(xywh) ;"100|200|300|400"
		Gdip_SaveBitmapToFile(pBitmap, fpath)   ; save Full sized image
		Gdip_Shutdown(pToken)
		ShowTooltip("Capture Screenshot Successfully `n" . fpath)
	}
	else
	{
		@error_msg := "[" . A_ThisFunc . "] Err - The parameter strcoors [" . strcoors . "] is wrong. `r`n"
		Gosub, ErrorLabel

	}
}

/*
 Description: write the debug info to DOS window and log.txt file
Logger(strmsg, level = "DEBUG")
{
	if(level == "DISABLED")
	{
		return

	}
	else if ( level == "DEBUG")
	{

		IfWinNotExist ahk_class ConsoleWindowClass
		{
			Run, cmd.exe
			Sleep, 500
		}

		WinActivate ahk_class ConsoleWindowClass
		SetTitleMatchMode, 2
		FormatTime, t, %A_Now%, yyyy-MM-dd hh:mm:ss
		ControlSend, ,prompt $S{Enter}, cmd.exe
		ControlSend, ,echo %t% - %str%>>log.txt{Enter}, cmd.exe
	}
	else
	{
		@error_msg := "The " . level . " has not been defined"
		Gosub, ErrorLabel
	}

}
*/
;-------------------------------------------------------------------------------
;
; Function: Debug
; Description:
;		if isDebug=1, then turn on debug, show tooltip and highlight
; Syntax: Debug(msg [, t = 1500])
; Parameters:
;		msg - debug info
;		t - (Optional) Time to show tooltip
; Return Value:
;		None
; Remarks:
; 		None
; Related:
;		None
; Example:
;		Debug("debug information")
;
;-------------------------------------------------------------------------------
Debug(msg, t = 1500) {
	global @isDebug

	if (@isDebug)
	{
	;	ShowTooltip(msg, t)
	;	OutputDebug % "->>" .  "[Label]: " . A_ThisLabel .  "[LineFile]: " . A_LineFile . "[Linenumber]: " . A_LineNumber . "[Func]: " .  A_ThisFunc
		OutputDebug % msg
	}

}

;-------------------------------------------------------------------------------
;
; Function: VerifyString
; Description:
;		Verify whether expected string equals original string
; Syntax: VerifyString(ostr, rstr)
; Parameters:
;		ostr - original string variable
;		rstr - string to be matched
; Return Value:
;		None
; Remarks:
; 		None
; Related:
;		None
; Example:
;		ostr := "this is a test"
;		VerifyString(ostr, "this is a test")
;
;-------------------------------------------------------------------------------
VerifyString(ostr, rstr) {
	global @error_msg
	if (ostr == rstr){
		Debug("[" . A_ThisFunc . "] Pass - " . "[" . ostr . "]")
	}else{
		@error_msg := "[" . A_ThisFunc . "] Err - " . "[" . ostr . " != " . rstr . "]"
		Gosub, WarringLabel
	}
}

;-------------------------------------------------------------------------------
;
; Function: VerifySubString
; Description:
;		Verify whether expected string exists in original string
; Syntax: VerifyString(ostr, rstr)
; Parameters:
;		ostr - original string variable
;		rstr - string to be matched
; Return Value:
;		None
; Remarks:
; 		None
; Related:
;		None
; Example:
;		ostr := "this is a test"
;		VerifyString(ostr, "test")
;
;-------------------------------------------------------------------------------
VerifySubString(ostr, rstr) {
	global @error_msg
	StringCaseSense, On
	IfInString, ostr, %rstr%
	{
		Debug("[" . A_ThisFunc . "] Pass - [" . rstr . "] was found. ")
	}else{
		@error_msg := "[" . A_ThisFunc . "] Err - [" . rstr . "] was NOT found in [" . ostr . "]"
		Gosub, WarringLabel
	}
}

/*
--------------------------------------------Mouse Operation -------------------------------------
	ClickElement,		 ClickImage, 		ClickDragMouse
	MoveMouseToCoor,     MoveMouseToImage
-------------------------------------------------------------------------------------------------
*/

;-------------------------------------------------------------------------------
;
; Function: ClickElement
; Description:
;		Click a position
; Syntax: ClickElement(strCoor [, clickcount="", offset=""])
; Parameters:
;		strcoor - Position coordinate
;		clickcount - (Optional) click times. double-click is 2
;		offset - R (Default): relative current mouse location coordinate
;			W: relative current window.
; Return Value:
;		None
; Remarks:
; 		None
; Related:
;		ClickImage,
; Example:
;		ClickElement("100, 200")
;		ClickElement("100, 200", 2)
;		ClickElement("153, 217",,"W")
;
;-------------------------------------------------------------------------------
ClickElement(strcoor, clickcount = 1, offset = "R")
{
	global @error_msg
	xy := GetSplittedObj(strcoor)

	if(!!xy)
	{
		if (offset == "R")
		{
			MouseClick, Left, % xy[1], xy[2], clickcount,15,,R		 ; relative current mouse location coordinate
		}
		else if(offset == "W")
		{
			MouseClick, Left, % xy[1], xy[2], clickcount,15		; relative current window  - for meeting client
		}
		else
		{
			@error_msg := "[" . A_ThisFunc . "] Err - The parameter offset [" . offset . "] is wrong. `r`n"
			Gosub, ErrorLabel
		}
	}
	else
	{
		@error_msg := "[" . A_ThisFunc . "] Err - [" . strCoor . "] is error, please check it again. `r`n"
		Gosub, ErrorLabel
	}

}

;-------------------------------------------------------------------------------
;
; Function: ClickImage
; Description:
;		Click an image
; Syntax: ClickImage(img [, reg = "", timeoutset = "", n = ""])
; Parameters:
;		img - the key image for searching
;		reg - the search region, the default is fullscreen(0, 0, 1440, 900)
;		timeoutset - searching the key image should be in the specified time
;		n - Specify for n a number between 0 (accurately represent an image)and 255 (does not accurately)
;       	to indicate the allowed number of shades of variation in either direction for the intensity of the red, green,
;           and blue components of each pixel's color. For example, *2 would allow two shades of variation
; Return Value:
;		None
; Remarks:
; 		None
; Related:
;		 WaitForImage
; Example:
;		ClickImage(%A_ScriptDir%\images\pic.png)
;
;-------------------------------------------------------------------------------
ClickImage(img, reg = "", timeoutset = "", n = "")
{
	imageXY := WaitForImage(img, reg, timeoutset, n)
	MouseClick, Left, % imageXY[1]+5, imageXY[2]+5, 1, 15

}

;-------------------------------------------------------------------------------
;
; Function: ClickDragMouse
; Description:
;		Click and drag mouse
; Syntax: ClickDragMouse(strcoor)
; Parameters:
;		strcoors - coordinates of the drag's starting position and drag the mouse to
; Return Value:
;		None
; Remarks:
; 		None
; Related:
;		 GetSplittedObj
; Example:
;		ClickDragMouse("10, 20, 100, 200")
;
;-------------------------------------------------------------------------------
ClickDragMouse(strcoors)
{
	global @error_msg
	stedxy := GetSplittedObj(strcoors)
	if(!!stedxy)
	{
		MouseClickDrag, Left, % stedxy[1], stedxy[2], stedxy[3], stedxy[4],15
	}
	else
	{
		@error_msg := "[" . A_ThisFunc . "] Err - The parameter" . strcoors . " is wrong. `r`n"
		Gosub, ErrorLabel
	}
}

;-------------------------------------------------------------------------------
;
; Function: MoveMouseToCoor
; Description:
;		Move mouse to specified position
; Syntax: MoveMouseToCoor(strCoor [, speed = "", offset = ""])
; Parameters:
;		strCoor - Position coordinate
;		speed - Mouse movement speed
;		offset - R (Default): relative current mouse location coordinate
;			W: relative current window
; Return Value:
;		None
; Remarks:
; 		None
; Related:
;		 GetSplittedObj
; Example:
;		MoveMouseToCoor("10, 100")
;
;-------------------------------------------------------------------------------
MoveMouseToCoor(strcoor, speed = 15, offset = "R")
{
	global @error_msg
	xy := GetSplittedObj(strcoor)

	if (offset == "R")
		{
			MouseMove, % xy[1], xy[2], speed, R		; If this parameter is the letter R, the X and Y coordinates will be treated as offsets from the current mouse position

		}
		else if(offset == "W")
		{
			MouseMove, % xy[1], xy[2], speed		; relative browser window coordinate . eg: reset the mouse position to base key image

		}
		else
		{
			@error_msg := "[" . A_ThisFunc . "] Err - The parameter offset is wrong. `r`n"
			Gosub, ErrorLabel
		}

}

;-------------------------------------------------------------------------------
;
; Function: MoveMouseToImage
; Description:
;		Move mouse to the image
; Syntax: MoveMouseToImage(img [, reg = "", timeoutset = "", n = ""])
; Parameters:
;		img - the key image for searching
;		reg - the search region, the default is fullscreen(0, 0, 1440, 900)
;		timeoutset - searching the key image should be in the specified time
;		n - Specify for n a number between 0 (accurately represent an image)and 255 (does not accurately)
;       	to indicate the allowed number of shades of variation in either direction for the intensity of the red, green,
;           and blue components of each pixel's color. For example, *2 would allow two shades of variation
; Return Value:
;		An array object includes the image coordinate of the upper-left
; Remarks:
; 		None
; Related:
;		 WaitForImage
; Example:
;		xy := MoveMouseToImage("pic.png")
;		x := xy[1] y:=xy[2]
;
;-------------------------------------------------------------------------------
MoveMouseToImage(img, reg = "", timeoutset = "", n = "")
{
	xy:= WaitForImage(img, reg, timeoutset, n)
	MouseMove % xy[1], xy[2]
	return xy
}

;-------------------------------------------------------------------------------
;
; Function: StrPutVar
; Description:
;		Convert the data to some Enc, like UTF-8, UTF-16, CP1200 and so on
; Syntax: StrPutVar(Str, ByRef Var [, Enc = ""])
; Parameters:
;		Str - String
;		Var - The name of the variable
;		Enc - Encoding
; Return Value:
;		String in a particular encoding
; Example:
;		None
;
;-------------------------------------------------------------------------------
StrPutVar(Str, ByRef Var, Enc = "")
{
   Len := StrPut(Str, Enc) * (Enc = "UTF-16" || Enc = "CP1200" ? 2 : 1)
   VarSetCapacity(Var, Len, 0)
   Return, StrPut(Str, &Var, Enc)
}

/*

 DynaRun: DynaRun
 Description:
		Run Dynamic Script Through a Pipe!
 Syntax: DynaRun(TempScript [, pipename=""])
 Parameters:
		TempScript - script text
		pipename - allow to specified pipename to connect remote machine
 Remarks:
 		Because "#include <filename>" The file name must not contain variable references
		so can not load script dynamically
 Related:
		http://www.autohotkey.com/community/viewtopic.php?f=2&t=60627
 Example:
		; suite.ahk
		gosub Test2
		return

		Test2:
		MsgBox, haha2
		return

		; b.ahk
		; Read text file into OutputVar
		FileRead, OutputVar, suite.ahk
		; execute the script
		DynaRun(OutputVar)

DynaRun(TempScript, pipename="")
{
	global isFinished := false

   static _:="uint",@:="Ptr"
   If pipename =
      name := "AHK" A_TickCount
   Else
      name := pipename
   __PIPE_GA_ := DllCall("CreateNamedPipe","str","\\.\pipe\" name,_,2,_,0,_,255,_,0,_,0,@,0,@,0)
   __PIPE_    := DllCall("CreateNamedPipe","str","\\.\pipe\" name,_,2,_,0,_,255,_,0,_,0,@,0,@,0)
   if (__PIPE_=-1 or __PIPE_GA_=-1)
      Return 0
   Run, %A_AhkPath% "\\.\pipe\%name%",,UseErrorLevel HIDE, PID
   If ErrorLevel
      MsgBox, 262144, ERROR,% "Could not open file:`n" __AHK_EXE_ """\\.\pipe\" name """"
   DllCall("ConnectNamedPipe",@,__PIPE_GA_,@,0)
   DllCall("CloseHandle",@,__PIPE_GA_)
   DllCall("ConnectNamedPipe",@,__PIPE_,@,0)
   script := (A_IsUnicode ? chr(0xfeff) : (chr(239) . chr(187) . chr(191))) TempScript
   if !DllCall("WriteFile",@,__PIPE_,"str",script,_,(StrLen(script)+1)*(A_IsUnicode ? 2 : 1),_ "*",0,@,0)
      Return A_LastError
   DllCall("CloseHandle",@,__PIPE_)
   isFinished := true
   Return PID
}
*/
