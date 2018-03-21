;~ This library is the Product of tank
;~ based on COM.ahk from Sean http://www.autohotkey.com/forum/topic22923.html
;~ standard library is the work of tank and updates may be downloaded from
;~ http://www.autohotkey.net/~tank/iWeb.zip
;~ http://www.autohotkey.com/forum/viewtopic.php?t=51270

;~ complete API
/*
iWeb_Init()
iWeb_Term()
iWeb_newIe()
iWeb_Model(h=550,w=900)
iWeb_getwin(Name="")
iWeb_Release(pdisp)
iWeb_nav(pwb,url)
iWeb_complete(pwb)
iWeb_DomWin(pDisp,frm="")
iWeb_inpt(i)
iWeb_getDomObj(pwb,obj,frm="")
iWeb_setDomObj(pwb,obj,t,frm="")
iWeb_Checked(pwb,obj,checked=1,sIndex=0,frm="")
iWeb_SelectOption(pDisp,sName,selected,method="selectedIndex",frm="")
iWeb_TableParse(pDisp,table,row,cell,frm="")
iWeb_FireEvents(ele)
iWeb_TableLength(pDisp,TableRows="",TableRowsCells="",frm="")
iWeb_clickDomObj(pwb,obj,frm="")
iWeb_clickText(pwb,t,frm="")
iWeb_clickHref(pwb,t,frm="")
iWeb_clickValue(pwb,t,frm="")
iWeb_execScript(pwb,js,frm="")
iWeb_getVar(pwb,var,frm="")
iWeb_escape_text(txt)
iWeb_striphtml(HTML)
iWeb_Txt2Doc(t)
iWeb_Activate(sTitle)
*/
;~ Library initialisers
{
	;inititalize the library
	iWeb_Init()
	{
		Return COM_CoInitialize()
	}
	;~ close the library
	iWeb_Term()
	{
		Return COM_CoUninitialize()
	}
}
;~ getting/destroying browser handles*
{
	;~ A new internet explorer window
	iWeb_newIe()
	{
		Return	pweb := (pweb := COM_CreateObject("InternetExplorer.Application") ) ? (pweb,COM_Invoke(pweb , "Visible=", "True")) : 0
	}
	;~ New internet explorer window always on top with titlebar only
	iWeb_Model(h=550,w=900)
	{
		;"False" ;"True" ;uncomment to show
	;~ 	COM_Invoke(pwb,"ToolBar",1)
		If	pwb := (pwb := iWeb_newIe()) ? (pwb,	COM_Invoke(pwb,"MenuBar",0),	COM_Invoke(pwb,"AddressBar",0),	COM_Invoke(pwb,"StatusBar",0),	COM_Invoke(pwb,"Height",h),	COM_Invoke(pwb,"Width",w)) : 
		WinSet,AlwaysOnTop,On,% "ahk_class " COM_Invoke(pwb,"hwnd")
		Return	pwb
	}
	;~ reuse an existing tab or window
	iWeb_getwin(Name="")
	{
	;~ 	COM_GetActiveObject("InternetExplorer.Application")
		IfEqual, Name,, WinGetTitle, Name, ahk_class IEFrame ; Get active window if no parameter 
			Name := RegExReplace(Name," - (Windows|Microsoft) Internet Explorer")
		if name
			If	psh	:=	COM_CreateObject("Shell.Application") {
				If	psw	:=	COM_Invoke(psh,	"Windows") {
					COM_Error(0)
					Loop, %	COM_Invoke(psw,	"Count")
						If	pwb	:=	(InStr(COM_Invoke(psw,"Item[" A_Index-1 "].LocationName"),Name) && InStr(COM_Invoke(psw,"Item[" A_Index-1 "].FullName"), "iexplore.exe")) ? COM_Invoke(psw,"Item",A_Index-1) :
							Break
					COM_Release(psw)
					COM_Error(1)
				}
				COM_Release(psh)
			}
		Return	pwb	
	}
	;~ this is just a wrapper for COM_Release()
	iWeb_Release(pdsp)
	{
		COM_Release(pdsp)
	}
}


;~ Navigate to a url
iWeb_nav(pwb,url)						; returns bool 
{
	If  !pwb		;	test to see if we have a valid interface pointer
	{
		MsgBox, 262160, Browser Navigation, The Browser you tried to Navigate to `n%url%`nwith is not valid
		Return						;	ExitApp if we dont
	}
;~ 	
;~ 	http://msdn.microsoft.com/en-us/library/aa752133(VS.85).aspx
	navTrustedForActiveX	=	0x0400
	COM_Invoke(pwb,	"Navigate",	url,	navTrustedForActiveX,	"_self")
	iWeb_complete(pwb)
	Return							;	return the result(bool) of the complete function 
}									;	nav function end
;~ wait for a page to finish loading
iWeb_complete(pwb)						;	returns bool for success or failure
{	
	If  !pwb							;	test to see if we have a valid interface pointer
		sleep, 5000						;	ExitApp if we dont
	Else
	{
		loop 20							;	sets limit if itenerations to 40 seconds 80*500=40000=40 secs
			If not (rdy:=COM_Invoke(pwb,"readyState") = 4)
				Break				;	return success
			Else	Sleep,100					;	sleep .1 second between cycles
		loop 80							;	sets limit if itenerations to 40 seconds 80*500=40000=40 secs
			If (rdy:=COM_Invoke(pwb,"readyState") = 4)
				Break
			Else	Sleep,500					;	sleep half second between cycles
		Loop	80				
			If	((rdy:=COM_Invoke(pwb,"document.readystate"))="complete")
				Return 	1				;	return success
			Else	Sleep,100
	}
	Return 0						;	lets face it if it got this far it failed
}								;	end complete
;~ get the window onject from an object
iWeb_DomWin(pdsp,frm="")
{
	If	pWin	:=	COM_QueryService(pdsp,	"{332C4427-26CB-11D0-B483-00C04FD90119}",	"{332C4427-26CB-11D0-B483-00C04FD90119}") 
	{
		Loop, Parse, frm, `, 
		{
			frame:=COM_Invoke(pWin,"document.all.item[" A_LoopField "].contentwindow")
			COM_Release(pWin)
			pWin:=COM_QueryService(frame,	"{332C4427-26CB-11D0-B483-00C04FD90119}",	"{332C4427-26CB-11D0-B483-00C04FD90119}")
			COM_Release(frame)
			If	!pWin
				Return	False
		}
		Return	pWin
	}	
	Return False
}
;~ Determin if an element is a form input 
iWeb_inpt(i)
{
;~ 			http://msdn.microsoft.com/en-us/library/ms534657(VS.85).aspx tagname property
	typ		:=	COM_Invoke(i,	"tagName")
	inpt	:=	"BUTTON,INPUT,OPTION,SELECT,TEXTAREA" ; these things all have value attribute and is likely what i need instead of innerHTML
	Loop,Parse,inpt,`,
		if (typ	=	A_LoopField	?	1	:	"")
			Return 1
	Return
}
;~ Functions that manipulate DOM
{
	iWeb_getDomObj(pwb,obj,frm="")
	{
	/*********************************************************************
	pwb	-	browser object
	obj	-	object reference; optionally, a comma delimited list of references (name, id or index) of all value can be used
	frm -	frame reference; optionally, a comma delimited list of frames (name, id or index ) of all value can be used
	example of usage
	The below will try to get an object called 'username'
	iWeb_getDomObj(pwb,"username")
	This will cycle thru and attempt to get 3 separate objects (username, pass and 3) 
	iWeb_getDomObj(pwb,"username,pass,3")
	This will recurse into the 'left' frame and try to get an object called 'results'
	iWeb_getDomObj(pwb,"results","left")
	*/
		If	pWin	:=	iWeb_DomWin(pwb,frm) 
		{
			If  col	:=	COM_Invoke(pWin,"document.all")	
			{
				Loop,Parse,obj,`,
				{
					If	itm		:=	COM_Invoke(col,"item", A_LoopField)	;if this fails there really isnt any need to do below
					{
						tx		:=	COM_Invoke(itm,	T	:=	iWeb_inpt(itm)	?	"value"	:	"innerHTML")
						StringReplace,tx,tx,`,,&#44;,all	;	escape all commas in text extracted always
						rslt	.=	tx ","
						iWeb_FireEvents(itm)
						COM_Release(itm)
					}
				}
				StringTrimRight, rslt, rslt, 1	;strip trailing coma
				COM_Release(col)
			}
			COM_Release(pWin)
		}
		Return	rslt
	}

	iWeb_setDomObj(pwb,obj,t,frm="")
	{
	/*********************************************************************
	pwb	-	browser object
	obj	-	object reference; optionally ,a comma delimited list of references a name, id, or index of all value can be used
	t	-	text to place in object; optionally a comma delimited list of references a name, id, or index of all value can be used
	frm -	frame reference; optionally, a comma delimited list of frames (name, id or index ) of all value can be used
	Example Usage
	The below will take a browser object, try to get an object called 'username' and set its value/innerHTML to 'john'
	iWeb_setDomObj(pwb,"username","john")
	This will cycle thru 3 separate objects (username, pass and 3) and attempt to set them each to separate text (john, sam and paul respectively).
	iWeb_setDomObj(pwb,"username,pass,3","john,sam,paul")
	This will recurse into the 'left' frame and try to set an object 'searchText' with the text '007'
	iWeb_setDomObj(pwb,"searchText","007","left")
	*/
		If	pWin	:=	iWeb_DomWin(pwb,frm) 
		{
			If  col		:=	COM_Invoke(pWin,	"document.all") 
			{
				StringSplit,tt,t,`,
				Loop,Parse,obj,`,
				{
					If	itm		:=	COM_Invoke(col,"item", A_LoopField)	;if this fails there really isnt any need to do below
					{
						StringReplace,tt%A_Index%,tt%A_Index%,&#44;,`,,all	;	unescape all commas in text extracted always
			;~ 			making invoke take integers as Strings  ",	VT_BSTR:=8"
			;~ 			http://www.autohotkey.com/forum/viewtopic.php?p=221631#221631
						COM_Invoke_(itm,	v	:=	iWeb_inpt(itm)	?	"Value="	:	"innerHTML=",	VT_BSTR:=8,	tt%A_Index%)
						iWeb_FireEvents(itm)
						COM_Release(itm)
						d=1
					}
				}
				COM_Release(col)
			}
			
			COM_Release(pWin)
		}
			
		Return d
	}

	iWeb_Checked(pwb,obj,checked=1,sIndex=0,frm="")
	{
		If	pWin	:=	iWeb_DomWin(pwb,frm) 
		{
			COM_Invoke(pWin,(string:=sIndex ? "document.all[" obj "].item[" sIndex "]" : "document.all[" obj "]") ".checked",checked)
			Checkmark	:= COM_Invoke(pWin,string ".checked") ? True	: False
			iWeb_FireEvents(ele:=COM_Invoke(pWin,string))
			COM_Release(ele)
			COM_Release(pWin)
		}
		Return	Checkmark
	}

	iWeb_SelectOption(pdsp,sName,selected,method="selectedIndex",frm="")
	{
		If	pWin	:=	iWeb_DomWin(pwb,frm) 
		{
			COM_Invoke(pWin,"document.all[" sName "].selectedIndex" ,selected)
			iWeb_FireEvents(ele:=COM_Invoke(pWin,"document.all[" sName "]."))
			COM_Release(ele)
			COM_Release(pWin)
		}
		Return	
	}

	iWeb_TableParse(pdsp,table,row,cell,frm="")
	{
	;~ 	http://www.w3schools.com/jsref/dom_obj_table.asp
		ErrorLevel:=
		If	ErrorLevel:=!(pWin	:=	iWeb_DomWin(pdsp,frm)) ? "failed to get a window handle" : false
			Return ErrorLevel
		COM_Error(0)
		cell:=pWin ? COM_Invoke(pWin,"document.all.tags[table].item[" table "].rows[" row "].cells[" cell "]") : false
		COM_Error(1)
		COM_Release(pWin)
		If	!cell
			Return ErrorLevel:="**** failed to get the cell reference ****"
		result:=cell ? COM_Invoke(cell,"innerHTML")  : 
		iWeb_FireEvents(cell)
		COM_Release(cell)
		Return result
	}

}

iWeb_FireEvents(ele)
{
	COM_Error(0)
	COM_Invoke(ele,"onfocus")
	COM_Invoke(ele,"onblur")
	COM_Invoke(ele,"onchange")
	COM_Invoke(ele,"onclick")
	COM_Error(1)
	
}

iWeb_TableLength(pdsp,TableRows="",TableRowsCells="",frm="") 
{
	/*
	TableRows - table index id or name for the table whos rows you wish to count
	TableRowsCells - row index id or name for the table whos rows you wish to count TableRows is required for this
	*/
	ErrorLevel:=
	If	ErrorLevel:=!(pWin	:=	iWeb_DomWin(pdsp,frm)) ? "failed to get a window handle" : false
		Return ErrorLevel
	string:="document.all.tags[table]" (t:=(StrLen(TableRows) ? (".item[" TableRows "].rows" (r:=StrLen(TableRowsCells) ? ("[" TableRowsCells "].cells") : "")) : ""))
	COM_Error(0)
	ref:=pWin ? COM_Invoke(pWin,string) : false
	COM_Error(1)
	COM_Release(pWin)
	If	!ref
		Return ErrorLevel:="**** failed to get the iWeb_TableLength reference ****"
	result:=ref ? COM_Invoke(ref,"length")  : 
	COM_Release(ref)
	Return result
}



;~ functions that click 
{
	iWeb_clickDomObj(pwb,obj,frm="")
	{
	/*********************************************************************
	pwb	-	browser object
	obj	-	object reference; optionally, a comma delimited list of references (name, id or index) of all value can be used
	frm -	frame reference; optionally, a comma delimited list of frames (name, id or index ) of all value can be used
	Example of Usage
	The below will take a browser object and try to click an object called username
	iWeb_getDomObj(pwb,"username")
	This will cycle thru and attempt to click 3 separate objects (username, pass and 3) 
	iWeb_clickDomObj(pwb,"username,pass,3")
	This will recurse into the 'left' frame and try to click an object called 'results'
	iWeb_clickDomObj(pwb,"results","left")
	*/ 
		If	pWin	:=	iWeb_DomWin(pwb,frm) 
		{
			COM_Invoke(pWin,"Document.all.item[" obj "].click")
			iWeb_FireEvents(ele:=COM_Invoke(pWin,"Document.all.item[" obj "]."))
			d=1
			COM_Release(ele)
			COM_Release(pWin)
		}
		Return	d
	}
	iWeb_clickText(pwb,t,frm="")
	{
	/*********************************************************************
	pwb	-	browser object
	t 	-	text with in the link to check against
	frm -	frame reference; optionally, a comma delimited list of frames (name, id or index ) of all value can be used
	Example Usage
	The below will take a browser object and try to click an object with the text 'Click Here'
	iWeb_clickText(pwb,"Click Here")
	This will recurse into the 'left' frame and try to click an object with the text 'Contact Us'
	iWeb_clickText(pwb,"Contact Us","left")
	*/
		If	pWin	:=	iWeb_DomWin(pwb,frm) 
		{
			Loop,%	COM_Invoke(pWin,"document.links.length")
				If	InStr(COM_Invoke(pWin,"document.links.item[" A_Index-1 "].innertext"),t)
				{
					COM_Invoke(pWin,"document.links.item[" A_Index-1 "].click")
					iWeb_FireEvents(ele:=COM_Invoke(pWin,"Document.links.item[" A_Index-1 "]."))
					COM_Release(ele)
					d=1
					Break
				}	
			COM_Release(pWin)
		} ;;If	pWin
		Return	d
	}
	iWeb_clickHref(pwb,t,frm="")
	{
	/*********************************************************************
	pwb	-	browser object
	t 	-	text with in the href to check against
	frm -	frame reference; optionally, a comma delimited list of frames (name, id or index ) of all value can be used
	Example Usage
	This will click a link with the text below in the href attribute even if there were more following that entry in the href
	iWeb_clickHref(pwb,"javascript:alert('this was in a link')")
	This will recurse into the 'left' frame and try to click an object with the url for AutoHotkey's forum in an href
	iWeb_clickHref(pwb,"http://www.autohotkey.com/forum/","left")
	*/
		If	pWin	:=	iWeb_DomWin(pwb,frm) 
		{
			Loop,%	COM_Invoke(pWin,"document.links.length")
				If	InStr(COM_Invoke(pWin,"document.links.item[" A_Index-1 "].href"),t)
				{
					COM_Invoke(pWin,"document.links.item[" A_Index-1 "].click")
					iWeb_FireEvents(ele:=COM_Invoke(pWin,"Document.links.item[" A_Index-1 "]."))
					COM_Release(ele)
					d=1
					Break
				}	
			COM_Release(pWin)
		} ;;If	pWin
		Return	d
	}
	iWeb_clickValue(pwb,t,frm="")
	{
	/*********************************************************************
	pwb	-	browser object
	t	-	text to match from visible button or other inputs
	frm -	frame reference; optionally, a comma delimited list of frames (name, id or index ) of all value can be used
	Example Usage
	The below will click an element that has a value attribute equal to 'Submit'
	iWeb_clickValue(pwb,"Submit")
	This will recurse into the 'left' frame and try to click an object with the value 'Enter'
	iWeb_clickValue(pwb,"Enter","left")
	*/
		If	pWin	:=	iWeb_DomWin(pwb,frm) 
		{
			Loop,%	COM_Invoke(pWin,"document.all.length")
				If	iWeb_inpt(itm:=COM_Invoke(pWin,"document.all.item", A_Index-1)) ? InStr(COM_Invoke(pWin,"document.all.item[" A_Index-1 "].value"),t) : 0
				{
					COM_Invoke(itm,	"click")
					iWeb_FireEvents(itm)
					COM_Release(itm)
					d=1
					Break
				}	
				Else	COM_Release(itm)
			COM_Release(pWin)
		} ;;If	pWin
		Return	d
	}

}

;~ Functions used to interact with scripts embeded in a web page
{
;~ 	insert and execute a javascript statement into an exisiting document window
	iWeb_execScript(pwb,js,frm="")
	{
		If	(js && (pWin:=	iWeb_DomWin(pwb,frm)))
		{
			COM_Invoke(pWin,	"execScript",	js)
			COM_Release(pWin)
		}
		Return
	}
;~ 	retreive a global variable value from a page
	iWeb_getVar(pwb,var,frm="")
	{
		If	(var && (pWin:=	iWeb_DomWin(pwb,frm)))
		{
			rslt:=	COM_Invoke(pWin,	var)
			COM_Release(pWin)
		}
		Return rslt
	}
	
	;~ 	this helper function is really designed to return only 
	;~ 	useable un formated text that can be used within javascript
	iWeb_escape_text(txt)
	{
		
		StringReplace,txt,txt,',\',ALL
		StringReplace,txt,txt,"",\"",ALL
		;~ StringReplace,txt,txt,`.`.,`.,ALL
		StringReplace,txt,txt,`r,%a_space%,ALL
		StringReplace,txt,txt,`n,%a_space%,ALL
		StringReplace,txt,txt,`n`r,%a_space%,ALL
		StringReplace,txt,txt,%a_space%%a_space%,%a_space%,ALL
		return txt	
	}
;~ 	simply stripts html tags from a string
	iWeb_striphtml(HTML)
	{
;~ 		thanks lazlo http://www.autohotkey.com/forum/viewtopic.php?p=71935#71935
		Loop Parse, HTML, <>
			If (A_Index & 1) 
				noHTML .= A_LoopField
		Return noHTML
	}

}
;~ takes an html fragment and creates a DOM document from a string
iWeb_Txt2Doc(t)
{
	If	doc := COM_CreateObject("{25336920-03F9-11CF-8FD0-00AA00686F13}") 
		COM_Invoke(doc, "write", t),COM_Invoke(doc, "close") 
	Return doc
}
;~ Sets a window and tab as active by the page title
iWeb_Activate(sTitle) 
{ 
; thanks Sean 
; http://www.autohotkey.com/forum/viewtopic.php?p=231093#231093 
	DllCall("LoadLibrary", "str", "oleacc.dll") 
	DetectHiddenWindows, On 
	WinActivate,% "ahk_id " HWND
	WinWaitActive,% "ahk_id " HWND,,5
	ControlGet, hTabBand, hWnd,, TabBandClass1, ahk_class IEFrame
	ControlGet, hTabUI  , hWnd,, DirectUIHWND1, ahk_id %hTabBand% 
	If   hTabUI && DllCall("oleacc\AccessibleObjectFromWindow", "Uint", hTabUI, "Uint",-4, "Uint", COM_GUID4String(IID_IAccessible,"{618736E0-3C3D-11CF-810C-00AA00389B71}"), "UintP", pacc)=0 
	{ 
		Loop, %   COM_Invoke(pacc, "accChildCount") 
			If   paccChild:=COM_Invoke(pacc, "accChild", A_Index) 
				If   COM_Invoke(paccChild, "accRole", 0) = 0x3C 
				{ 
					paccTab:=paccChild 
					Break 
				} 
				Else   COM_Release(paccChild) 
		COM_Release(pacc) 
	} 
	If   pacc:=paccTab 
	{ 
		Loop, %   COM_Invoke(pacc, "accChildCount") 
			If   paccChild:=COM_Invoke(pacc, "accChild", A_Index) 
				If   COM_Invoke(paccChild, "accName", 0) = sTitle   
				{ 
					COM_Release(pwb),VarSetCapacity(pwb,0),VarSetCapacity(HWND,0)
					COM_Invoke(paccChild, "accDoDefaultAction", 0)
					COM_Release(paccChild) 
					Break 
				} 
				Else   COM_Release(paccChild) 
		COM_Release(pacc) 
	}  
	WinActivate,% sTitle
} 
