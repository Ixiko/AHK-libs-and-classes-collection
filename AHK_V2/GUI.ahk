; ===========================================================================
; created by TheArkive
; Usage: Specify X/Y coords to get info on which monitor that point is on,
;        and the bounds of that monitor.  If no X/Y is specified then the
;        current mouse X/Y coords are used.
; ===========================================================================
GetMonitorData(x:="", y:="") {
	CoordMode "Mouse", "Screen" ; CoordMode Mouse, Screen ; AHK v1
	If (x = "" Or y = "")
		MouseGetPos x, y
	actMon := 0
	
	monCount := MonitorGetCount() ; SysGet, monCount, MonitorCount ; AHK v1
	Loop monCount { ; Loop % monCount { ; AHK v1
		MonitorGet(A_Index,mLeft,mTop,mRight,mBottom) ; SysGet, m, Monitor, A_Index ; AHK v1
		
		If (mLeft = "" And mTop = "" And mRight = "" And mBottom = "")
			Continue
		
		If (x >= (mLeft) And x <= (mRight-1) And y >= mTop And y <= (mBottom-1)) {
			monList := {}, monList.left := mLeft, monList.right := mRight
			monList.top := mTop, monList.bottom := mBottom, monList.active := A_Index
			monList.x := x, monList.y := y
			monList.Cx := ((mRight - mLeft) / 2) + mLeft
			monList.Cy := ((mBottom - mTop) / 2) + mTop
			monList.w := mRight - mLeft, monList.h := mBottom - mTop
			Break
		}
	}
	
	return monList
}

; example for GetMonitorData()
; Loop {
	; sleep 100
	
	; m := GetMonitorData()
	; txtBlock := "act mon: " m.active "`r`n`r`n" m.x " / " m.y "`r`n"
	          ; . "Left: " m.left "`r`nRight: " m.right "`r`nTop: " m.top "`r`nBottom: " m.bottom "`r`n"
			  ; . "Center X/Y: " m.Cx " / " m.Cy
	
	; Tooltip % txtBlock
; }
; F12::ExitApp

; ======================================================================
; modified from Fnt_Library v3 posted by jballi
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=4379
; original function(s) = Fnt_CalculateSize() / Fnt_GetAverageCharWidth()
; ======================================================================
GetTextDims(r_Text, sFaceName, nHeight,maxWidth:=0) {
	Static Dummy57788508, DEFAULT_GUI_FONT:=17, HWND_DESKTOP:=0, MAXINT:=0x7FFFFFFF, OBJ_FONT:=6, SIZE
	
	hDC := DllCall("GetDC", "Ptr", HWND_DESKTOP) ; "UInt" or "Ptr" ?
	devCaps := DllCall("GetDeviceCaps", "Uint", hDC, "int", 90)
	nHeight := -DllCall("MulDiv", "int", nHeight, "int", devCaps, "int", 72)
	
	bBold := False, bItalic := False, bUnderline := False, bStrikeOut := False, nCharSet := 0
	
	hFont := DllCall("CreateFont", "int", nHeight, "int", 0 ; get specified font handle
	               , "int", 0, "int", 0, "int", 400 + 300 * bBold
				   , "Uint", bItalic, "Uint", bUnderline, "Uint"
				   , bStrikeOut, "Uint", nCharSet, "Uint", 0, "Uint"
				   , 0, "Uint", 0, "Uint", 0, "str", sFaceName)
	
	hFont := !hFont ? DllCall("GetStockObject","Int",DEFAULT_GUI_FONT) : hFont ; load default font if invalid
	
    l_LeftMargin:=0, l_RightMargin:=0, l_TabLength:=0, r_Width:=0, r_Height:=0
	l_Width := (!maxWidth) ? MAXINT : maxWidth
	l_DTFormat := 0x400|0x10 ; DT_CALCRECT (0x400) / DT_WORDBREAK (0x10)
	
    DRAWTEXTPARAMS := BufferAlloc(20,0) ;-- Create and populate DRAWTEXTPARAMS structure
	NumPut "UInt", 20, "Int", l_TabLength, "Int", l_LeftMargin, "Int", l_RightMargin, DRAWTEXTPARAMS
	
	RECT := BufferAlloc(16,0)
	NumPut "Int", l_Width, RECT, 8 ;-- right
	
    old_hFont := DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)
	
	SIZE := BufferAlloc(8,0) ;-- Initialize
	testW := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz" ; taken from Fnt_GetAverageCharWidth()
	RC := DllCall("GetTextExtentPoint32","Ptr",hDC,"Str",testW,"Int",StrLen(testW),"Ptr",SIZE.Ptr)
	RC := RC ? NumGet(SIZE,0,"Int") : 0
	avgCharWidth := Floor((RC/26+1)/2)
	avgCharHeight := NumGet(SIZE,4,"Int")
	
	strBufSize := StrPut(r_Text)
	l_Text := BufferAlloc(strBufSize+16,0)
	StrPut r_Text, l_Text ; , (l_Text.Size+1) ; not specifying size
	
    DllCall("DrawTextEx"
        ,"Ptr",hDC                                      ;-- hdc [in]
        ,"Ptr",l_Text.Ptr ; orig type = "Str"           ;-- lpchText [in, out]
        ,"Int",-1                                       ;-- cchText [in]
        ,"Ptr",RECT.Ptr                                 ;-- lprc [in, out]
        ,"UInt",l_DTFormat                              ;-- dwDTFormat [in]
        ,"Ptr",DRAWTEXTPARAMS.Ptr)                      ;-- lpDTParams [in]
	
    DllCall("SelectObject","Ptr",hDC,"Ptr",old_hFont)
	DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC) ; avoid memory leak
	
	r_Width := NumGet(RECT,8,"Int")
	r_Height := NumGet(RECT,12,"Int")
	NumPut "Int", r_Width, "Int", r_Height, SIZE ; write H/W to SIZE rect structure
	
	retVal := {}, retVal.h := r_Height, retVal.w := r_Width
	retVal.avgW := avgCharWidth, retVal.avgH := avgCharHeight, retVal.addr := SIZE.Ptr
	
	return retVal
}


; ===========================
; GetTextSize by Laszlo
; https://autohotkey.com/board/topic/16414-hexview-31-for-stdlib/page-2#entry108223
; ===========================
; GetTextSize(pStr, pSize=8, pFont="", pHeight=false) {
   ; Gui 9:Font, %pSize%, %pFont%
   ; Gui 9:Add, Text, R1, %pStr%
   ; GuiControlGet T, 9:Pos, Static1
   ; Gui 9:Destroy
   ; Return pHeight ? TW "," TH : TW
; }

; ===========================
; GetTextPixels()
;	orignally: GetTextExtentPoint()
;	by Sean: https://autohotkey.com/board/topic/16414-hexview-31-for-stdlib/#entry107363
; ===========================
GetTextPixels(sString, sFaceName, nHeight, ByRef WidthVar, ByRef HeightVar, bBold := False, bItalic := False, bUnderline := False, bStrikeOut := False, nCharSet := 0) { ; GetTextExtentPoint
	hDC := DllCall("GetDC", "Uint", 0)
	nHeight := -DllCall("MulDiv", "int", nHeight, "int", DllCall("GetDeviceCaps", "Uint", hDC, "int", 90), "int", 72)

	hFont := DllCall("CreateFont", "int", nHeight, "int", 0, "int", 0, "int", 0, "int", 400 + 300 * bBold, "Uint", bItalic, "Uint", bUnderline, "Uint", bStrikeOut, "Uint", nCharSet, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0, "str", sFaceName)
	hFold := DllCall("SelectObject", "Uint", hDC, "Uint", hFont)

	DllCall("GetTextExtentPoint32", "Uint", hDC, "str", sString, "int", StrLen(sString), "int64P", nSize:=0)
	DllCall("SelectObject", "Uint", hDC, "Uint", hFold), DllCall("DeleteObject", "Uint", hFont)
	DllCall("ReleaseDC", "Uint", 0, "Uint", hDC)

	nWidth  := nSize & 0xFFFFFFFF, nHeight := nSize >> 32 & 0xFFFFFFFF ; Return "w" nWidth " h" nHeight
	WidthVar := nWidth, HeightVar := nHeight
}


; ===========================
; isWindowFullScreen(winTitle) ;checks if the specified window is full screen
; thanks to Derrick
; URL: https://autohotkey.com/board/topic/38882-detect-fullscreen-application/#entry252922

isWindowFullScreen(winTitle) {
	winID := WinExist(winTitle)
	If (!winID)
		Return false
    style := WinGetStyle("ahk_id " WinID) ; 0x800000 is WS_BORDER.
	WinGetPos x,y,winW,winH, winTitle  ; 0x20000000 is WS_MINIMIZE. ; no border and not minimized
	Return ((style & 0x20800000) or winH < A_ScreenHeight or winW < A_ScreenWidth) ? false : true
}

; ====================================================================
; by TheArkive
; SaveTree(hCtl=0)
; ====================================================================

SaveTree(oCtl:=0) { ; specify hCtl if also saving icons (TreeView control handle)
	If (!IsObject(oCtl))
		oCtl := GuiCtrlFromHwnd(oCtl)
    CurID := oCtl.GetNext() ; get top most node ID
    CurText := oCtl.GetText(CurID) ; get top most node text
    
    While (CurID > 0) {
        CurLine := CurText
        
        attrib := oCtl.Get(CurID,"E") ; check if expanded
        If (attrib > 0)
            attribList := "E"
        attrib := oCtl.Get(CurID,"C") ; check if checked
        If (attrib > 0)
            attribList .= "C"
        attrib := oCtl.Get(CurID,"B") ; check if bold
        If (attrib > 0)
            attribList .= "B"
        
        CurChildID := oCtl.GetChild(CurID) ; get first child ID if any
        CurChildText := oCtl.GetText(CurChildID) ; get first child text if any
        
        While (CurChildID > 0) {
            CurLine .= ";" CurChildText
            
            CurChildID := oCtl.GetNext(CurChildID) ;  init for next child
            CurChildText := oCtl.GetText(CurChildText,CurChildID)
        }
        
        CurParentID := oCtl.GetParent(CurID) ; check if top level node or child
        If (CurParentID > 0)
            CurLine := "child;" CurLine
        
		; get icon
		; ========
		; If (hCtl)
			; iIndex := TreeGetIconIndex(hCtl,CurID)
		
        FinalData .= CurLine ";" attribList "`r`n"
        
        attribList := "" ; init/reset for next iteration
        CurID := oCtl.GetNext(CurID,"Full") ; initialize for next iteration/node
        CurText := oCtl.GetText(CurID)
    }
    
    return FinalData
}

; ====================================================================
; TreeGetIconIndex(hCtl,hItem) ; gets tree item icon index ; support function
; NOTE: you can store a "phantom icon index" and retrieve it without an ImageList if you wish
;       hCtl = control/TreeView hwnd        hItem = node ID from TV_GetNext() or TV_GetSelection()
; return values are ZERO BASED
; ====================================================================

; TreeGetIconIndex(hCtl,hItem) {
; TreeGetIconIndex(hCtl,hItem=0) {
	; If (!hItem) {
		; r := SendMessage(0x110A,0x9,0,,"ahk_id " hCtl) ; 0x110A TVM_GETNEXTITEM ; 0x9 current selection
		; If (r And r != "FAIL")
			; hItem := r
		; Else
			; return
	; }
	
	; vPIs64 := (A_PtrSize=8) ; determine system arch
	; vPtrType := vPIs64?"Int64":"Int" ; set data type
	; vSize1 := vPIs64?56:40 ; set pointer size
	
	; VarSetCapacity(TVITEM, vSize1, 0)
	; pBuf := &TVITEM ; capture pointer to structure
	; NumPut(0x2, &TVITEM, 0, "UInt") ; ; AHK2 changeable ;mask ;TVIF_IMAGE := 0x2 ; define that we want the img index
	
	; vMsg := A_IsUnicode?0x113E:0x110C ;TVM_GETITEMW := 0x113E ;TVM_GETITEMA := 0x110C ; define msg according to system arch
	; vOffset := vPIs64?8:4 ; set offset according to system arch
	
	; NumPut(0, &TVITEM, vPIs64?36:24, "Int") ;iImage
	; NumPut(hItem, &TVITEM, vPIs64?8:4, vPtrType) ;hItem ; put item handle into structure
	
	; vRet := SendMessage(vMsg,0,pBuf,,"ahk_id " hCtl) ;TVM_GETITEMW := 0x113E ;TVM_GETITEMA := 0x110C ; get img index
	; vImageIndex := NumGet(&TVITEM, vPIs64?36:24, "Int") ;iImage ; extract img index from structure
	
	; return vImageIndex
; }

; ====================================================================
; by TheArkive
; LoadTree(TreeData)
; ====================================================================

LoadTree(oCtl,TreeData) {
	If (!IsObject(oCtl))
		oCtl := GuiCtrlFromHwnd(oCtl) ; was hCtl
    TreeData := Trim(TreeData,OmitChars:=" `r`n`t")
    IsChild := 0, CurID := 0, ParentID := 0, IsExpanded := false
    
    Loop Parse TreeData, "`r", "`n"
    {
        CurLine := A_LoopField
        iLen := StrLen(CurLine)
        Loop Parse CurLine, Chr(59)
		{
            i := A_Index ; get number of tokens in CurLine
        }
		
        lastSep := InStr(CurLine,";",,1,i-1)
        firstSep := InStr(CurLine,";",,1,1)
        
        CheckChild := SubStr(CurLine,1,(firstSep-1)) ; get first token of CurLine (sep = ";")
        
        If (CheckChild = "child")
            IsChild := 1

        attribList := SubStr(CurLine,lastSep+1,iLen-lastSep)
        
        Loop Parse attribList
        {
            If (A_LoopField = "E")
                IsExpanded := true
            Else If (A_LoopField = "C")
                attribs .= "Check "
            Else If (A_LoopField = "B")
                attribs .= "Bold"
        }
        
        attribs := Trim(attribs,OmitChars:=" `r`n") ; get saved node attributes
        
        If (IsChild = 0)
            nodeList := SubStr(CurLine,1,lastSep-1)
        Else
            nodeList := SubStr(CurLine,firstSep+1,(lastSep-firstSep-1))
        
        nodeListFirst := InStr(nodeList,";",,1,1)

        If (nodeListFirst = 0) {
            FirstNode := nodeList
            ChildNodes := ""
        } Else {
            FirstNode := SubStr(nodeList,1,nodeListFirst-1)
            ChildNodes := SubStr(nodeList,(nodeListFirst+1),iLen-nodeListFirst)
        } ; ====================================================
        
        If (IsChild = 0) {
            CurID := oCtl.Add(FirstNode,0,attribs) ; define CurID for future ParentID operations
            If (ChildNodes != "") {
                Loop Parse ChildNodes, Chr(59) ; Chr(59) = ";"
				{
                    oCtl.Add(A_LoopField,CurID)
				}
			}
            
            If (IsExpanded)
                oCtl.Modify(CurID,"Expand")
            
            ParentID := oCtl.GetNext(CurID,"Full") ; define ParentID by navigating in "Full" mode, same as datafile creation
        } Else { ; if IsChild=true, FirstNode should already be created and ParentID should be the ID for that node
            CheckParentID := oCtl.Modify(ParentID,attribs)
            If (CheckParentID != ParentID)
                MsgBox("parent ID issue")
            
            If (ChildNodes != "") {
                Loop Parse ChildNodes, Chr(59)
				{
                    oCtl.Add(A_LoopField,ParentID)
				}
			}
            
            If (IsExpanded)
                oCtl.Modify(ParentID,"Expand")
            
            ParentID := oCtl.GetNext(ParentID,"Full") ; define ParentID by navigating in "Full" mode
        } ; ======================================= ; like how the datafile was made
		
        attribs := "" ; subsequent inits
        IsExpanded := false
        attribList := ""
        FirstNode := ""
        ChildNodes := ""
        IsChild := 0
        nodeList := ""
    }
}

; ====================================================================
; ListGetIconIndex(hCtl,vIndex) ; gets list item icon index ; support function
; NOTE: you can store a "phantom icon index" and retrieve it without an ImageList if you wish
;       it is possible to also get icon indexes for other columns
;       hCtl = control/TreeView hwnd        hItem = node ID from TV_GetNext() or TV_GetSelection()
; return values are ZERO BASED
; ====================================================================

; ListGetIconIndex(hCtl,vIndex,vCol = 1) {
	; vIndex := vIndex - 1 ; row number must be zero-based
	
	; vPIs64 := (A_PtrSize=8) ; determine system arch
	; vPtrType := vPIs64?"Int64":"Int" ; set data type
	; vSize1 := vPIs64?56:40 ; set pointer size
	
	; VarSetCapacity(LVITEM, vSize1, 0) ; create variable/structure
	; pBuf := &LVITEM ; capture pointer to structure
	; NumPut(0x2, &LVITEM, 0, "UInt") ;mask ;LVIF_IMAGE := 0x2
	
	; vMsg := A_IsUnicode?0x104B:0x1005 ;LVM_GETITEMW := 0x104B ;LVM_GETITEMA := 0x1005
	
	; NumPut(0, &LVITEM, vPIs64?36:28, "Int") ;iImage
	; NumPut(vIndex, &LVITEM, 4, "Int") ;iItem
	; NumPut(vCol - 1, &LVITEM, 8, "Int") ; Column number
	
	; SendMessage, %vMsg%, 0, pBuf,, ahk_id %hCtl% ;LVM_GETITEMW := 0x104B ;LVM_GETITEMA := 0x1005
	; vImageIndex := NumGet(&LVITEM, vPIs64?36:28, "Int") ;iImage
	
	; return vImageIndex
; }

; ====================================================================
; Set Icon for row "subItem" (aka collumn) within Listview
; Author: Tseug > http://www.autohotkey.com/board/topic/72072-listview-icons-in-more-than-first-column-example/
; From github: https://gist.github.com/hoppfrosch/11242617
; ====================================================================
; LV_SetSI(hList, iItem, iSubItem, iImage) {
	; vPIs64 := (A_PtrSize=8) ; determine system arch
	; vPtrType := vPIs64?"Int64":"Int" ; set data type

	;;;;;;;;;;;;;;;;;; struct = 20 + ptr + 8 + ptr + 12 + ptr + 8
	; lSize := 20 + A_PtrSize + 8 + A_PtrSize + 12 + A_PtrSize + 8 ; 72 on 64-bit ; 60 on 32-bit
	; VarSetCapacity(LVITEM, lSize, 0)	; original size = 60
	; LVM_SETITEM := 0x1006 , mask := 2   ; LVIF_IMAGE := 0x2
	; iItem-- , iSubItem-- , iImage--		; Note first column (iSubItem) is #ZERO, hence adjustment
	; NumPut(mask, LVITEM, 0, "UInt")
	; NumPut(iItem, LVITEM, 4, "Int")
	; NumPut(iSubItem, LVITEM, 8, "Int")
	; NumPut(iImage, LVITEM, 20+(A_PtrSize*2), "Int") ; original offset = 28
	
	; pBuf := &LVITEM
	; SendMessage, %LVM_SETITEM%, 0, %pBuf%,, ahk_id %hList% ; LVM_SETITEM = 0x1006
	; result := ErrorLevel
	; return result
; }

; ====================================================================
; by TheArkive
; TreeSetBold(BoldValue) ; operates on active TreeView
;     Sets a specified text value to bold.  All nodes with the matching text value are affected
; ====================================================================

TreeSetBold(oCtl,BoldValue) {
    CurID := oCtl.GetNext(), CurText := oCtl.CurText(CurID), i := 0
    While(CurID > 0) {
        If (CurText = BoldValue)
			oCtl.Modify(CurID,"+Bold"), i++
		Else
			oCtl.Modify(CurID,"-Bold")
        CurID := oCtl.GetNext(CurID,"Full"), CurText := oCtl.GetText(CurID)
    }
	return i
}

; ====================================================
; LV_IsChecked(oCtl,lRowNum)
; ====================================================
; This was taken directly from the AutoHotkey help files and turned into a function with a few extras
LV_IsChecked(oCtl,lRowNum) {
	nHwnd := oCtl.hwnd
    c := SendMessage(4140,lRowNum-1,0xF000,, "ahk_id " nHwnd)  ; 4140 is LVM_GETITEMSTATE. 0xF000 is LVIS_STATEIMAGEMASK.
    ; If (r = "FAIL") { ; if FAIL, then try again
        ; c := SendMessage(4140,lRowNum-1,0xF000,,"ahk_id " nHwnd) ; 4140 is LVM_GETITEMSTATE. 0xF000 is LVIS_STATEIMAGEMASK.
    ; }
    IsChecked := (c >> 12) - 1  ; This sets IsChecked to true if RowNumber is checked or false otherwise.
    If (IsChecked = "")
        IsChecked := -1
    return IsChecked
}


























; ====================================================
; AppendText(hEdit, ptrText)
; 	example: AppendText(ctlHwnd, &varText)
; Posted by TheGood:
;	https://autohotkey.com/board/topic/52441-append-text-to-an-edit-control/#entry328342
; ====================================================
; AppendText(hEdit, sInput, loc="bottom") {
    ; SendMessage, 0x000E, 0, 0,, ahk_id %hEdit%						;WM_GETTEXTLENGTH
	; If (loc = "bottom")
		; SendMessage, 0x00B1, ErrorLevel, ErrorLevel,, ahk_id %hEdit%	;EM_SETSEL
	; Else If (loc = "top")
		; SendMessage, 0x00B1, 0, 0,, ahk_id %hEdit%
    ; SendMessage, 0x00C2, False, &sInput,, ahk_id %hEdit%			;EM_REPLACESEL
; }

; ====================================================
; SB_SetProgress
; (w) by DerRaphael / Released under the Terms of EUPL 1.0 
; see http://ec.europa.eu/idabc/en/document/7330 for details
; URL: https://autohotkey.com/board/topic/34593-stdlib-sb-setprogress/
; ====================================================
; OPTIONS:
;	Background		BackgroundGreen, BackgroundFFFF33
; 	Range			Range0-1000 > Range-50-50 (-50 to 50) > Range-10--5 (-10 to -5)
;	c				cRed, cFFFF33 (bar color)
;	+/-Smooth		shows segmented, or themed progress bar (-Smooth for themed)
;	Enable, Disable, Show, Hide
; ====================================================
; Performance: DON'T set options in a loop that also sets the progress bar value/position.
; ====================================================
; SB_SetProgress(Value=0,Seg=1,Ops="")
; {										; Definition of Constants 
	; Static SB_GETRECT      := 0x40a      ; (WM_USER:=0x400) + 10
		; , SB_GETPARTS     := 0x406
		; , SB_PROGRESS                   ; Container for all used hwndBar:Seg:hProgress
		; , PBM_SETPOS      := 0x402      ; (WM_USER:=0x400) + 2
		; , PBM_SETRANGE32  := 0x406
		; , PBM_SETBARCOLOR := 0x409
		; , PBM_SETBKCOLOR  := 0x2001 
		; , dwStyle         := 0x50000001 ; forced dwStyle WS_CHILD|WS_VISIBLE|PBS_SMOOTH

	; Gui,+LastFound ; Find the hWnd of the currentGui's StatusbarControl
	; ControlGet,hwndBar,hWnd,,msctls_statusbar321

	; if (!StrLen(hwndBar)) { 
	  ; rErrorLevel := "FAIL: No StatusBar Control"     ; Drop ErrorLevel on Error
	; } else If (Seg<=0) {
	  ; rErrorLevel := "FAIL: Wrong Segment Parameter"  ; Drop ErrorLevel on Error
	; } else if (Seg>0) { ; Segment count
		; SendMessage, SB_GETPARTS, 0, 0,, ahk_id %hwndBar%
		; SB_Parts :=  ErrorLevel - 1
		; If ((SB_Parts!=0) && (SB_Parts<Seg)) {
			; rErrorLevel := "FAIL: Wrong Segment Count"  ; Drop ErrorLevel on Error
		; } else {				; Get Segment Dimensions in any case, so that the progress control
			; if (SB_Parts) {	; can be readjusted in position if neccessary
				; VarSetCapacity(RECT,16,0)     ; RECT = 4*4 Bytes / 4 Byte <=> Int
				; SendMessage,SB_GETRECT,Seg-1,&RECT,,ahk_id %hwndBar% ; Segment Size :: 0-base Index => 1. Element -> #0
				; If ErrorLevel
				   ; Loop,4
					  ; n%A_index% := NumGet(RECT,(a_index-1)*4,"Int")
				; else
				   ; rErrorLevel := "FAIL: Segmentdimensions" ; Drop ErrorLevel on Error
			; } else { ; We dont have any parts, so use the entire statusbar for our progress
				; n1 := n2 := 0
				; ControlGetPos,,,n3,n4,,ahk_id %hwndBar%
			; } ; if SB_Parts

		; If (InStr(SB_Progress,":" Seg ":")) {
			; hWndProg := (RegExMatch(SB_Progress, hwndBar "\:" seg "\:(?P<hWnd>([^,]+|.+))",p)) ? phWnd :
		; } else {
            ; If (RegExMatch(Ops,"i)-smooth"))
				; dwStyle ^= 0x1

            ; hWndProg := DllCall("CreateWindowEx","uint",0,"str","msctls_progress32"
				; ,"uint",0,"uint", dwStyle
				; ,"int",0,"int",0,"int",0,"int",0 ; segment-progress :: X/Y/W/H
				; ,"uint",DllCall("GetAncestor","uInt",hwndBar,"uInt",1) ; gui hwnd
				; ,"uint",0,"uint",0,"uint",0)

            ; SB_Progress .= (StrLen(SB_Progress) ? "," : "") hwndBar ":" Seg ":" hWndProg
		; } ; If InStr Prog <-> Seg

		; Black:=0x000000,Green:=0x008000,Silver:=0xC0C0C0,Lime:=0x00FF00,Gray:=0x808080		; HTML Colors
		; Olive:=0x808000,White:=0xFFFFFF,Yellow:=0xFFFF00,Maroon:=0x800000,Navy:=0x000080
		; Red:=0xFF0000,Blue:=0x0000FF,Fuchsia:=0xFF00FF,Aqua:=0x00FFFF

		; If (RegExMatch(ops,"i)\bBackground(?P<C>[a-z0-9]+)\b",bg)) {
			; if ((strlen(bgC)=6)&&(RegExMatch(bgC,"i)([0-9a-f]{6})")))
				; bgC := "0x" bgC
			; else if !(RegExMatch(bgC,"i)^0x([0-9a-f]{1,6})"))
				; bgC := %bgC%
			; if (bgC+0!="")
			  ; SendMessage, PBM_SETBKCOLOR, 0
				; , ((bgC&255)<<16)+(((bgC>>8)&255)<<8)+(bgC>>16) ; BGR
				; ,, ahk_id %hwndProg%
		; } ; If RegEx BGC
		; If (RegExMatch(ops,"i)\bc(?P<C>[a-z0-9]+)\b",fg)) {
			; if ((strlen(fgC)=6)&&(RegExMatch(fgC,"i)([0-9a-f]{6})")))
				; fgC := "0x" fgC
			; else if !(RegExMatch(fgC,"i)^0x([0-9a-f]{1,6})"))
				; fgC := %fgC%
			; if (fgC+0!="")
				; SendMessage, PBM_SETBARCOLOR, 0
					; , ((fgC&255)<<16)+(((fgC>>8)&255)<<8)+(fgC>>16) ; BGR
					; ,, ahk_id %hwndProg%
		; } ; If RegEx FGC

		; If ((RegExMatch(ops,"i)(?P<In>[^ ])?range((?P<Lo>\-?\d+)\-(?P<Hi>\-?\d+))?",r)) 
			; && (rIn!="-") && (rHi>rLo)) {    ; Set new LowRange and HighRange
			; SendMessage,0x406,rLo,rHi,,ahk_id %hWndProg%
		; } else if ((rIn="-") || (rLo>rHi)) {  ; restore defaults on remove or invalid values
			; SendMessage,0x406,0,100,,ahk_id %hWndProg%
		; } ; If RegEx Range
      
		; If (RegExMatch(ops,"i)\bEnable\b"))
			; Control, Enable,,, ahk_id %hWndProg%
		; If (RegExMatch(ops,"i)\bDisable\b"))
			; Control, Disable,,, ahk_id %hWndProg%
		; If (RegExMatch(ops,"i)\bHide\b"))
			; Control, Hide,,, ahk_id %hWndProg%
		; If (RegExMatch(ops,"i)\bShow\b"))
			; Control, Show,,, ahk_id %hWndProg%

		; ControlGetPos,xb,yb,,,,ahk_id %hwndBar%
		; ControlMove,,xb+n1,yb+n2,n3-n1,n4-n2,ahk_id %hwndProg%
		; SendMessage,PBM_SETPOS,value,0,,ahk_id %hWndProg%

		; } ; if Seg greater than count
   ; } ; if Seg greater zero

   ; If (regExMatch(rErrorLevel,"^FAIL")) {
      ; ErrorLevel := rErrorLevel
      ; Return -1
   ; } else 
      ; Return hWndProg
; }

; ====================================================
; OnLeftClick
; ====================================================
;
; How to capture left click when the control won't let you natively.
; Also how to avoid missing DoubleClick when trying to use AltSubmit.
; With this, you don't need to use AltSubmit just to get the "Normal"
; event, which is a waste if that is all you use it for.
;
; This code should probably be copied into the main script file, not pulled in as a library.

; OnMessage(0x0201,"LbDown") ; WM_LBUTTONDOWN

; LbDown(wParam, lParam, Msg, hwnd) { ; force WM_LBUTTONUP for list view
	; CtrlHwnd := "0x" Format("{:x}",hwnd)
	; If (CtrlHwnd = MyCtlHwnd) {
		; MouseGetPos, x, y ; thanks to jeeswg for x,y lParam - https://www.autohotkey.com/boards/viewtopic.php?f=6&t=68367
		; x := Format("0x{:02X}",x), y := Format("0x{:02X}",y), lParam := (x & 0xffff) | (y & 0xffff) << 16 
		; PostMessage, 0x0202, 0, %lParam%, , ahk_id %CtrlHwnd% ; WM_LBUTTONUP
	; }
; }

; OnMessage(0x0202,"LbUp") ; fires on listview double-click or when forced

; LbUp(wParam, lParam, Msg, hwnd) { ; only fires on double click???
	; CtrlHwnd := "0x" Format("{:x}",hwnd)
	
	; If (CtrlHwnd = MyCtlHwnd) { ; 0x103D = LVM_GETHOTITEM / 0x1042 = LVM_GETSELECTIONMARK
		; SendMessage, 0x1042, 0, 0, , ahk_id %CtrlHwnd% ; LVM_GETSELECTIONMARK = LVM_FIRST + 66
		; CurRow := ErrorLevel + 1 ; LVM_GETHOTITEM sets ErrorLevel to index, which is 0 based
		; /* or */
		; CurRow := LV_GetNext()
		; /* your code here, or make "CurRow" global */
	; }
; }

; =============================================
; OnKeyDown
; =============================================

; OnMessage(0x0100,"OnKeyDown") ; WM_KEYDOWN

; OnKeyDown(wParam, lParam, msg, hwnd) { ; wParam = keycode in decimal
    ; CtrlHwnd := "0x" Format("{:x}",hwnd) ; control hwnd formatted to match +HwndVarName
    
    ; If (CtrlHwnd = AppListFilterHwnd) { ; compare CtrlHwnd to your control's handle (hwnd)
        ; Msgbox % "YAH: " wParam " / " Format("{:x}",lParam) " / " Format("{:x}",wParam)
    ; }
; }

; =================================
; OnLeftDoubleClick
; =================================

; OnMessage(0x0203),"LDblClick") ; WM_LBUTTONDBLCLK 

; LDblClick(wParam, lParam, msg, hwnd) {

; }

; =================================
; OnWinActivate
; =================================
; wParam --> 1 = WA_ACTIVE /// 2 = WA_CLICKACTIVE /// 0 = WA_INACTIVE
; lParam = hwnd of window being activated or deactivaated

; OnMessage(0x06, "WM_ACTIVATE")

; WM_ACTIVATE(wParam, lParam) { 
	; if(wParam>0)
		; ToolTip, Window Activated!
; }