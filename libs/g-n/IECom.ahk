; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; ieCOM.ahk 
; by ameyrick
; https://autohotkey.com/boards/viewtopic.php?f=6&t=19300
; Last updated: 2016 June 29 21:33 UTC
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*

functions:

		nav(), ie() 
			Same as wb()
			
		wb()
			Connect to an existing IE window by title
			Opens a new IE window if title not found
			Navigates to URL
			~options: invisible, silent
				visible and silent by default.
			
			Creates 'wb' pointer to IE window
				wb.document.getElementByID("ID") 
				
			Automatically calls DocWait() on completion
		
		Example:
			wb("about:blank")
			wb("http://www.google.co.uk","title",true,true)
		
		+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		
		wait(), DocWait()
			Pause script until web page has finished loading
			Automatically invoked after wb()
			Automatically calls setvars() on completion
		
		+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		
		setvars()
			Creates shortcut references to IE
			Call this function, to update the script variables after 
			new browser content. Automatically invoked after DocWait()
			
			document := wb.document
			d:= wb.document
			w:= wb.document.parentwindow
			
		+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		
		rs()
		resizeIE()
			Resize &/or move IE window
			
		Example:
			resizeIE(x,y,width,height,PointerToIE)

		+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		
		jsapp()
		jsappend()
			Append your own Javascript functions to the current page
		
		Example:
			https://autohotkey.com/boards/viewtopic.php?f=6&t=19300
		
		+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		
		js()
			Execute Javascript, call a function on the current page.
		
		Example:
			https://autohotkey.com/boards/viewtopic.php?f=6&t=19300
		
		+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		
		IEGet2()
			Modified version of original IEGet() by Jethrow
			Retrieves pointer to existing IE window/tab
			with or without a window/tab title specified
			
		Example:
			wb := IEGet2("page title")
			
		+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		
		frames(0)
		frames("name")
		        Create an obj reference to a specific frame or iframe
		frames()
			Create an array of obj references for each frame in the document
			
		Example:
			MyFrame := frames(1)
			MyFrame := frames("name")
			Frame := frames()
			Frame[0].document
			Frame[1].document
			
		+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		
		createTable()
			Creates a table element on the current page
			'parent_elem' is the element you wish to append to
			'idValue' is your Table id string
			'r' the amount of rows you would like in your table
			'c' the amount of Columns you would like in your table
			
		Example:
			createTable(wb.document.body,"MyTableID",10,10)
		
		+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		
		table2array()
			stores each <td></td> element in a multi-dimensional array/obj
			
		Example:
			myarray := table2array("MyTableID")
			
			myarray[0,0].InnerHTML := "#"
			Loop,
			{
				myarray[0,(A_Index-1)].bgcolor := "#D3D3D3"
				myarray[(A_Index-1),0].bgcolor := "#D3D3D3"
			}	
						
			myarray[0,1].InnerHTML := "A"
			myarray[0,2].InnerHTML := "B"
			myarray[0,3].InnerHTML := "C"
			myarray[0,4].InnerHTML := "D"
			myarray[0,5].InnerHTML := "E"
			myarray[0,6].InnerHTML := "F"
			myarray[0,7].InnerHTML := "G"
			
			myarray[1,0].InnerHTML := "1"
			myarray[2,0].InnerHTML := "2"
			myarray[3,0].InnerHTML := "3"
			myarray[4,0].InnerHTML := "4"
			myarray[5,0].InnerHTML := "5"
			myarray[6,0].InnerHTML := "6"
			myarray[7,0].InnerHTML := "7"
			
			
		
		+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


*/ 
nav(url:="",window_title:="",v:="",s:=""){
		wb(url,window_title,v,s)
	return
}
 
ie(url:="",window_title:="",v:="",s:=""){
	wb(url,window_title,v,s)
	return
}
 
wb(url:="",window_title:="",v:="",s:=""){
	global	
	if !wb
		wb := IEGet2(window_title)
	if !wb 
		wb := ComObjCreate("InternetExplorer.Application")
	if !v
		wb.Visible := true
	if v = true
		wb.Visible := true
	if v = false
		wb.Visible := false
 
	if !s
		wb.Silent := true
	if s = true
		wb.Silent := true
	if s = false
		wb.Silent := false
 
	if url
		wb.Navigate(url)
 
	DocWait(wb)
	return
}
 
wait(x=""){
	global
	if x
		wb := x
	DocWait(wb)
	return
}
 
DocWait(x:=""){
	global
	if x 
		wb := x
	try while wb.readyState != 4 or wb.busy
           Sleep, 10
	Sleep, 100
	setvars(wb)
	return
}
 
setvars(x=""){
	global
	if x
		wb := x
	document := wb.document
	d:= wb.document
	w:= wb.document.parentwindow
	return
}
 
rs(x:=0,y:=0,width:="",height:="",browser:=""){
	global
	if !browser
		browser := wb
	resizeIE(x,y,width,height,browser)
	return
}
 
resizeIE(x:=0,y:=0,width:="",height:="",browser:=""){
	global
	if !browser
		browser := wb
	if !width
		width:= A_ScreenWidth
	if !height
		height:= A_ScreenHeight
	try browser.document.parentWindow.moveTo(x,y)
	try browser.document.parentWindow.resizeTo(width,height)
	return
}
 
jsapp(code=""){
	jsappend(code)
}
 
jsappend(code=""){
	global
	if !code
		return
	s := d.createElement("script")
	s.type := "text/javascript"
	try {
	  s.appendChild(d.createTextNode(code))
	  d.body.appendChild(s)
	} catch e {
	  s.text := code
	  d.body.appendChild(s)
	}
}
 
js(js:=""){
	global
	if !js
		return
	try w.execScript(js)
	catch {
		DocWait()
		try w.execScript(js)
	}
	return
}

IEGet2(Name="")  ;Retrieve pointer to existing IE window/tab
{
IfEqual, Name,, WinGetTitle, Name, ahk_class IEFrame
	Name := ( Name="New Tab - Windows Internet Explorer" ) ? "about:Tabs"
	: RegExReplace( Name, " - (Windows|Microsoft) Internet Explorer" )
For wb in ComObjCreate( "Shell.Application" ).Windows
	If ( wb.LocationName = Name ) && InStr( wb.FullName, "iexplore.exe" )
		Return wb
	; Below added for when no tab name/page title provided ~ ameyrick
	If InStr( wb.FullName, "iexplore.exe" ) 
		Return wb
} ;Original IEGet() written by Jethrow
 
table2array(id="") {
	Global
	if !id
		return
	tObj:= Object()
	loop % d.getElementById(id).rows.length
	{
		row:= (A_Index-1) 
		loop % d.getElementById(id).rows[row].cells.length
		{
			col := (A_Index-1)
			tObj[row, col] := d.getElementById(id).rows[row].cells[col]
		}
	}
	return tObj
}

createTable(parent_elem="",idValue="",r=1,c=1){
	Global
	if !parent_elem
		return
	if !idValue
		return
	t := document.createElement("TABLE")
	t.setAttribute("id", idValue)
	parent_elem.appendChild(t)
	loop % r
	{
		row := (A_Index-1)
		tr := d.createElement("TR")
		tr.setAttribute("id", idValue "_tr" row )
		t.appendChild(tr)
		loop % c
		{
			td := document.createElement("TD")
			td.setAttribute("id", idValue "_tr" row "_td" (A_Index-1) )
			td.setAttribute("class", idValue )
			
			cell := document.createTextNode(" ")
			td.appendChild(cell)
			tr.appendChild(td)
		}
	}
	DocWait(wb)
	setvars(wb)
}

frames(name=""){
	global wb
	frames := wb.document.parentwindow.frames
	fObj := Object()
	loop, % frames.length
	{
		If !IsObject(fObj[A_Index-1] := frames[A_Index-1])
			try fObj[A_Index-1] := ComObj(9, ComObjQuery(frames[A_Index-1], "{332C4427-26CB-11D0-B483-00C04FD90119}", "{332C4427-26CB-11D0-B483-00C04FD90119}"), 1)
	}
	if !name
		return fObj
	if name is Integer
		return fObj[name]
	else
		loop, % frames.length
		{
			if ( fObj[A_Index-1].name == name ){
				return fObj[A_Index-1]
			}
		}
}

/*  Fix keyboard shortcuts in WebBrowser control.
 *  References:
 *    http://www.autohotkey.com/community/viewtopic.php?p=186254#p186254
 *    http://msdn.microsoft.com/en-us/library/ms693360
 */

gui_KeyDown(wParam, lParam, nMsg, hWnd) {
    global wb
    if (Chr(wParam) ~= "[A-Z]" || wParam = 0x74) ; Disable Ctrl+O/L/F/N and F5.
        return
    pipa := ComObjQuery(wb, "{00000117-0000-0000-C000-000000000046}")
    VarSetCapacity(kMsg, 48), NumPut(A_GuiY, NumPut(A_GuiX
    , NumPut(A_EventInfo, NumPut(lParam, NumPut(wParam
    , NumPut(nMsg, NumPut(hWnd, kMsg)))), "uint"), "int"), "int")
    Loop 2
    r := DllCall(NumGet(NumGet(1*pipa)+5*A_PtrSize), "ptr", pipa, "ptr", &kMsg)
    ; Loop to work around an odd tabbing issue (it's as if there
    ; is a non-existent element at the end of the tab order).
    until wParam != 9 || wb.Document.activeElement != ""
    ObjRelease(pipa)
    if r = 0 ; S_OK: the message was translated to an accelerator.
        return 0
}

/* 	Fix keyboard shortcuts in WebBrowser control.
*	by coco 
*	https://autohotkey.com/boards/viewtopic.php?f=5&t=5487&p=31581#p31581
*/
WB_OnKeyPress(wParam, lParam, nMsg, hWnd)
{
   WinGetClass WinClass, ahk_id %hWnd%
   if (WinClass == "Internet Explorer_Server")
   {
      static riid_IDispatch
      if !VarSetCapacity(riid_IDispatch)
      {
         VarSetCapacity(riid_IDispatch, 16)
         DllCall("ole32\CLSIDFromString", "WStr", "{00020400-0000-0000-C000-000000000046}", "Ptr", &riid_IDispatch)
      }
      DllCall("oleacc\AccessibleObjectFromWindow", "Ptr", hWnd, "UInt", 0xFFFFFFFC, "Ptr", &riid_IDispatch, "Ptr*", pacc) ; OBJID_CLIENT:=0xFFFFFFFC
 
      static IID_IHTMLWindow2 := "{332C4427-26CB-11D0-B483-00C04FD90119}"
      pwin := ComObjQuery(pacc, IID_IHTMLWindow2, IID_IHTMLWindow2)
         ObjRelease(pacc)
 
      static IID_IWebBrowserApp := "{0002DF05-0000-0000-C000-000000000046}"
           , SID_SWebBrowserApp := IID_IWebBrowserApp
      pweb := ComObjQuery(pwin, SID_SWebBrowserApp, IID_IWebBrowserApp)
         ObjRelease(pwin)
      wb := ComObject(9, pweb, 1)
 
      static IID_IOleInPlaceActiveObject := "{00000117-0000-0000-C000-000000000046}"
      pIOIPAO := ComObjQuery(wb, IID_IOleInPlaceActiveObject)
 
      VarSetCapacity(MSG, 48, 0)                      ; http://goo.gl/GX6GNm
      , NumPut(A_GuiY                                 ; POINT.y
      , NumPut(A_GuiX                                 ; POINT.x
      , NumPut(A_EventInfo                            ; time
      , NumPut(lParam                                 ; lParam
      , NumPut(wParam                                 ; wParam
      , NumPut(nMsg                                   ; message
      , NumPut(hWnd, MSG)))), "UInt"), "Int"), "Int") ; hwnd
 
      TranslateAccelerator := NumGet(NumGet(pIOIPAO + 0) + 5*A_PtrSize)
      Loop 2
         r := DllCall(TranslateAccelerator, "Ptr", pIOIPAO, "Ptr", &MSG)
      until (wParam != 9 || wb.Document.activeElement != "")
      ObjRelease(pIOIPAO)
      if (r == 0)
         return 0
   }
}

/*  javascript:AHK('Func') --> Func()
 */

JS_AHK(func, prms*) {
    global wb
    ; Stop navigation prior to calling the function, in case it uses Exit.
    wb.Stop(),  %func%(prms*)
}


