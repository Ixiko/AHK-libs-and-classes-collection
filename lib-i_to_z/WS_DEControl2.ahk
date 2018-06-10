

#Include ws4ahk.ahk ; designed for ws4ahk.ahk v0.01 or v0.02

;        Command IDs

DECMD_BOLD =                      5000
DECMD_COPY =                      5002
DECMD_CUT =                       5003
DECMD_DELETE =                    5004
DECMD_DELETECELLS =               5005
DECMD_DELETECOLS =                5006
DECMD_DELETEROWS =                5007
DECMD_FINDTEXT =                  5008
DECMD_FONT =                      5009
DECMD_GETBACKCOLOR =              5010
DECMD_GETBLOCKFMT =               5011
DECMD_GETBLOCKFMTNAMES =          5012
DECMD_GETFONTNAME =               5013
DECMD_GETFONTSIZE =               5014
DECMD_GETFORECOLOR =              5015
DECMD_HYPERLINK =                 5016
DECMD_IMAGE =                     5017
DECMD_INDENT =                    5018
DECMD_INSERTCELL =                5019
DECMD_INSERTCOL =                 5020
DECMD_INSERTROW =                 5021
DECMD_INSERTTABLE =               5022
DECMD_ITALIC =                    5023
DECMD_JUSTIFYCENTER =             5024
DECMD_JUSTIFYLEFT =               5025
DECMD_JUSTIFYRIGHT =              5026
DECMD_LOCK_ELEMENT =              5027
DECMD_MAKE_ABSOLUTE =             5028
DECMD_MERGECELLS =                5029
DECMD_ORDERLIST =                 5030
DECMD_OUTDENT =                   5031
DECMD_PASTE =                     5032
DECMD_REDO =                      5033
DECMD_REMOVEFORMAT =              5034
DECMD_SELECTALL =                 5035
DECMD_SEND_BACKWARD =             5036
DECMD_BRING_FORWARD =             5037
DECMD_SEND_BELOW_TEXT =           5038
DECMD_BRING_ABOVE_TEXT =          5039
DECMD_SEND_TO_BACK =              5040
DECMD_BRING_TO_FRONT =            5041
DECMD_SETBACKCOLOR =              5042
DECMD_SETBLOCKFMT =               5043
DECMD_SETFONTNAME =               5044
DECMD_SETFONTSIZE =               5045
DECMD_SETFORECOLOR =              5046
DECMD_SPLITCELL =                 5047
DECMD_UNDERLINE =                 5048
DECMD_UNDO =                      5049
DECMD_UNLINK =                    5050
DECMD_UNORDERLIST =               5051
DECMD_PROPERTIES =                5052


;   Enums


;OLECMDEXECOPT  

OLECMDEXECOPT_DODEFAULT =         0 
OLECMDEXECOPT_PROMPTUSER =        1
OLECMDEXECOPT_DONTPROMPTUSER =    2

; DHTMLEDITCMDF

DECMDF_NOTSUPPORTED =             0 
DECMDF_DISABLED =                 1 
DECMDF_ENABLED =                  3
DECMDF_LATCHED =                  7
DECMDF_NINCHED =                  11

; DHTMLEDITAPPEARANCE

DEAPPEARANCE_FLAT =               0
DEAPPEARANCE_3D =                 1 

; OLE_TRISTATE
OLE_TRISTATE_UNCHECKED =          0
OLE_TRISTATE_CHECKED =            1
OLE_TRISTATE_GRAY =               2


; Error Return Values
;

DE_E_INVALIDARG =                 0x5
DE_E_ACCESS_DENIED =              0x46
DE_E_PATH_NOT_FOUND =             0x80070003
DE_E_FILE_NOT_FOUND =             0x80070002
DE_E_UNEXPECTED =                 0x8000ffff
DE_E_DISK_FULL =                  0x80070027
DE_E_NOTSUPPORTED =               0x80040100
DE_E_FILTER_FRAMESET =            0x80100001
DE_E_FILTER_SERVERSCRIPT =        0x80100002
DE_E_FILTER_MULTIPLETAGS =        0x80100004
DE_E_FILTER_SCRIPTLISTING =       0x80100008
DE_E_FILTER_SCRIPTLABEL =         0x80100010
DE_E_FILTER_SCRIPTTEXTAREA =      0x80100020
DE_E_FILTER_SCRIPTSELECT =        0x80100040
DE_E_URL_SYNTAX =                 0x800401E4
DE_E_INVALID_URL =                0x800C0002
DE_E_NO_SESSION =                 0x800C0003
DE_E_CANNOT_CONNECT =             0x800C0004
DE_E_RESOURCE_NOT_FOUND =         0x800C0005
DE_E_OBJECT_NOT_FOUND =           0x800C0006
DE_E_DATA_NOT_AVAILABLE =         0x800C0007
DE_E_DOWNLOAD_FAILURE =           0x800C0008
DE_E_AUTHENTICATION_REQUIRED =    0x800C0009
DE_E_NO_VALID_MEDIA =             0x800C000A
DE_E_CONNECTION_TIMEOUT =         0x800C000B
DE_E_INVALID_REQUEST =            0x800C000C
DE_E_UNKNOWN_PROTOCOL =           0x800C000D
DE_E_SECURITY_PROBLEM =           0x800C000E
DE_E_CANNOT_LOAD_DATA =           0x800C000F
DE_E_CANNOT_INSTANTIATE_OBJECT =  0x800C0010
DE_E_REDIRECT_FAILED =            0x800C0014
DE_E_REDIRECT_TO_DIR =            0x800C0015
DE_E_CANNOT_LOCK_REQUEST =        0x800C0016


; ------------------------- General functions ---------------------------------------------------------------

DE_Add(hWnd, x, y, w, h) 
{ 
	ppvDEdit := GetComControlInHWND( CreateComControlContainer(hWnd, x, y, w, h, "DhtmlEdit.DhtmlEdit") ) 
	; Add the COM control to the scripting environment 
	; with the name "DHtmlControl"
	; Note that this means only one DHtmlEdit control can exist at a time
	WS_AddObject(ppvDEdit, "DHtmlControl")
	Return  ppvDEdit
} 

DE_Move(pwb, x, y, w, h) 
{ 
	WinMove, % "ahk_id " . GetHWNDofComControl(pwb), , x, y, w, h 
} 

DE_BrowseMode()     ; toggle between Edit mode and View mode.
{
	sCode = 
	(
	If DHtmlControl.Browsemode = 0 Then
		DHtmlControl.Browsemode = 1
	Else
		DHtmlControl.Browsemode = 0
	End If
	)
         
	If (!WS_Exec(sCode))
		Msgbox % A_LineFile ":" ErrorLevel
}


DE_LoadUrl(url)  ;Load url(e.g. "http://www.autohotkey.com") and ready to edit in a WYSIWIG way
{
	If (!WS_Exec("DHtmlControl.LoadUrl %s", url))
		Msgbox % A_LineFile ":" ErrorLevel
}

DE_NewDocument()  ;clear current document and open blank html document
{
	If (!WS_Exec("DHtmlControl.NewDocument"))
		Msgbox % A_LineFile ":" ErrorLevel
}


DE_LoadDocument(FileDir)   ;open file dialog and last parameter is prompt string.
{
	If (!WS_Exec("DHtmlControl.LoadDocument", FileDir, prompt))
		Msgbox % A_LineFile ":" ErrorLevel
}

DE_SaveDocument(Filedir)        ;save contents in html.
{
	If (!WS_Exec("DHtmlControl.SaveDocument %s", FileDir))
		Msgbox % A_LineFile ":" ErrorLevel
}


DE_GetDocumentHtml()      ;get and return DOCUMENT'S htmlcode
{
	If (!WS_Eval(sRet, "DHtmlControl.DocumentHtml"))
		Msgbox % A_LineFile ":" ErrorLevel
	Return sRet
}

DE_SetDocumentHtml(sHtml)   ;set document's htmlcode
{
	If (!WS_Exec("DHtmlControl.DocumentHtml = %s", sHtml))
		Msgbox % A_LineFile ":" ErrorLevel
}

DE_Refresh()   ;open file dialog and last parameter is prompt string.
{
	If (!WS_Exec("DHtmlControl.Refresh"))   
		Msgbox % A_LineFile ":" ErrorLevel
}

; --- WYSIWYG Edit functions ----------------------------------------------------------------------------------------------


; Set property --> use ExecCommand(), Command ID
; Get Propery --> use QueryStatus(), command ID

DE_SetBOLD()         ; toggle selections bold/normal
{
	global
	If (!WS_Exec("DHtmlControl.ExecCommand " DECMD_BOLD))
		Msgbox % A_LineFile ":" ErrorLevel
}

DE_SetUnderline()  ; toggle selections underline
{
	global
	If (!WS_Exec("DHtmlControl.ExecCommand " DECMD_UNDERLINE))
		Msgbox % A_LineFile ":" ErrorLevel
}

DE_SetItalic()  ; toggle selections italic
{
   global
   If (!WS_Exec("DHtmlControl.ExecCommand " DECMD_ITALIC))
      Msgbox % A_LineFile ":" ErrorLevel
}

DE_SetForeColor(sColor)    ; set font color string, e.g. "#55A0FF", "55A0FF", "Blue", "Red"
{
   global
   If (!WS_Exec("DHtmlControl.ExecCommand %v, %v, %s"
				, DECMD_SETFORECOLOR
				, OLECMDEXECOPT_DODEFAULT
				, sColor))
	   Msgbox % A_LineFile ":" ErrorLevel
}


DE_SetBackColor(sColor)    ; 
{
	global
	If (!WS_Exec("DHtmlControl.ExecCommand %v, %v, %s"
				, DECMD_SETBACKCOLOR
				, OLECMDEXECOPT_DODEFAULT
				, sColor))
		Msgbox % A_LineFile ":" ErrorLevel
}

DE_Font()    ;  
{
	global
	If (!WS_Exec("DHtmlControl.ExecCommand " DECMD_FONT))
		Msgbox % A_LineFile ":" ErrorLevel
}

DE_SetFontName(sFont)    ; 
{
	global
	If (!WS_Exec("DHtmlControl.ExecCommand %v, %v, %s"
				, DECMD_SETFONTNAME
				, OLECMDEXECOPT_DODEFAULT
				, sFont))
		Msgbox % A_LineFile ":" ErrorLevel
}

DE_SetFontSize(iFontSize)    ; 
{
	global
	If (!WS_Exec("DHtmlControl.ExecCommand %v, %v, %s"
				, DECMD_SETFONTSIZE
				, OLECMDEXECOPT_DODEFAULT
				, iFontSize))
		Msgbox % A_LineFile ":" ErrorLevel
}

DE_JustifyLeft()    ;  
{
	global
	If (!WS_Exec("DHtmlControl.ExecCommand " DECMD_JUSTIFYLEFT))
		Msgbox % A_LineFile ":" ErrorLevel
}

DE_JustifyCenter()    ;  
{
	global
	If (!WS_Exec("DHtmlControl.ExecCommand " DECMD_JUSTIFYCENTER))
		Msgbox % A_LineFile ":" ErrorLevel
}

DE_JustifyRight()    ;  
{
	global
	If (!WS_Exec("DHtmlControl.ExecCommand " DECMD_JUSTIFYRIGHT))
		Msgbox % A_LineFile ":" ErrorLevel
}

DE_SetHyperLink()    ; insert hyperlink property in selection 
{
   global
   If (!WS_Exec("DHtmlControl.ExecCommand %v, %v, %s"
               , DECMD_HYPERLINK
               , OLECMDEXECOPT_DODEFAULT
               , ""))
      Msgbox % A_LineFile ":" ErrorLevel
}

DE_SetImage()    ; insert image in selection 
{
   global
   If (!WS_Exec("DHtmlControl.ExecCommand %v, %v, %s"
            , DECMD_IMAGE
            , OLECMDEXECOPT_DODEFAULT
            , ""))
      Msgbox % A_LineFile ":" ErrorLevel
}

DE_UnLink()    ; insert image in selection 
{
   global
   If (!WS_Exec("DHtmlControl.ExecCommand %v, %v, %s"
            , DECMD_UNLINK
            , OLECMDEXECOPT_DODEFAULT
            , ""))
      Msgbox % A_LineFile ":" ErrorLevel
}

DE_SelectAll()    ;  
{
   global
  If (!WS_Exec("DHtmlControl.ExecCommand " DECMD_SELECTALL))
      Msgbox % A_LineFile ":" ErrorLevel
   
}


DE_Paste(pDHtmlEdit)    ;  
{
   global
  If (!WS_Exec("DHtmlControl.ExecCommand %v, %v"
               , DECMD_HYPERLINK
               , OLECMDEXECOPT_DODEFAULT))
      Msgbox % A_LineFile ":" ErrorLevel
   
}

DE_Properties()    ;  
{
	global
	If (!WS_Exec("DHtmlControl.ExecCommand " DECMD_PROPERTIES))
		Msgbox % A_LineFile ":" ErrorLevel
}

DE_UnDo()    ;  
{
	global
	If (!WS_Exec("DHtmlControl.ExecCommand " DECMD_UNDO))
		Msgbox % A_LineFile ":" ErrorLevel
}

DE_ReDo()    ;  
{
	global
	If (!WS_Exec("DHtmlControl.ExecCommand " DECMD_REDO))
		Msgbox % A_LineFile ":" ErrorLevel
}

DE_FindText()    ;  
{
	global
	If (!WS_Exec("DHtmlControl.ExecCommand " DECMD_FINDTEXT))
		Msgbox % A_LineFile ":" ErrorLevel
}

DE_Delete()    ;  
{
	global
	If (!WS_Exec("DHtmlControl.ExecCommand " DECMD_DELETE))
		Msgbox % A_LineFile ":" ErrorLevel
}

DE_Cut()    ;  
{
	global
	If (!WS_Exec("DHtmlControl.ExecCommand " DECMD_CUT))
		Msgbox % A_LineFile ":" ErrorLevel
}

DE_COPY()    ;  
{
	global
	If (!WS_Exec("DHtmlControl.ExecCommand " DECMD_COPY))
		Msgbox % A_LineFile ":" ErrorLevel
}

; ------- LIST AND TABLE FUNCTIONS

DE_OrderList()    ;   NUMBERED LIST
{
	global
	If (!WS_Exec("DHtmlControl.ExecCommand " DECMD_ORDERLIST))
		Msgbox % A_LineFile ":" ErrorLevel
}

DE_UnorderList()    ;   BULLET LIST
{
	global
	If (!WS_Exec("DHtmlControl.ExecCommand " DECMD_UNORDERLIST))
		Msgbox % A_LineFile ":" ErrorLevel
}


DE_InsertTable(numrows, numcols)
{
	If (!WS_Exec("Set tParam = CreateObject(%s)", "DEInsertTableParam.DEInsertTableParam"))
		Msgbox % A_LineFile ":" ErrorLevel
	; create a table object
	If (!WS_Exec("tParam.NumRows = " numrows)) ; -> set the table property.
		Msgbox % A_LineFile ":" ErrorLevel
	If (!WS_Exec("tParam.NumCols = " numcols))
		Msgbox % A_LineFile ":" ErrorLevel
	
	global DECMD_INSERTTABLE, OLECMDEXECOPT_DODEFAULT
	If (!WS_Exec("DHtmlControl.ExecCommand %v, %v, tParam"
				, DECMD_INSERTTABLE
				, OLECMDEXECOPT_DODEFAULT))
	Msgbox % A_LineFile ":" ErrorLevel
}


; --------- USING DOM ----------------------------------------------------------

GetSelection()
{
	sVBCode =
	(
		SelType = DHtmlControl.DOM.Selection.Type
		If SelType = "Text" Then
			SelectedText = DHtmlControl.DOM.Selection.CreateRange().HtmlText
		Else
			SelectedText = ""
		End If
	)

	; Execute the VB code
	If (!WS_Exec(sVBCode))
		Msgbox % A_LineFile ":" ErrorLevel

	; The variable "SelectedText" in the scripting environment holds the
	; selected text. This gets the value out of the scripting environment.
	If (!WS_Eval(SelectedText, "SelectedText"))
		Msgbox % A_LineFile ":" ErrorLevel
	
	Return SelectedText
}
