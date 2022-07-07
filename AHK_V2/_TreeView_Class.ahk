global PROCESS_TERMINATE                  := (0x0001)  
global PROCESS_CREATE_THREAD              := (0x0002)  
global PROCESS_SET_SESSIONID              := (0x0004)  
global PROCESS_VM_OPERATION               := (0x0008)  
global PROCESS_VM_READ                    := (0x0010)  
global PROCESS_VM_WRITE                   := (0x0020)  
global PROCESS_DUP_HANDLE                 := (0x0040)  
global PROCESS_CREATE_PROCESS             := (0x0080)  
global PROCESS_SET_QUOTA                  := (0x0100)  
global PROCESS_SET_INFORMATION            := (0x0200)  
global PROCESS_QUERY_INFORMATION          := (0x0400)  
global PROCESS_SUSPEND_RESUME             := (0x0800)  
global PROCESS_QUERY_LIMITED_INFORMATION  := (0x1000)

;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------

global PAGE_NOACCESS          := 0x01     
global PAGE_READONLY          := 0x02     
global PAGE_READWRITE         := 0x04     
global PAGE_WRITECOPY         := 0x08     
global PAGE_EXECUTE           := 0x10     
global PAGE_EXECUTE_READ      := 0x20     
global PAGE_EXECUTE_READWRITE := 0x40     
global PAGE_EXECUTE_WRITECOPY := 0x80     
global PAGE_GUARD            := 0x100     
global PAGE_NOCACHE          := 0x200     
global PAGE_WRITECOMBINE     := 0x400     
global MEM_COMMIT           := 0x1000     
global MEM_RESERVE          := 0x2000     
global MEM_DECOMMIT         := 0x4000     
global MEM_RELEASE          := 0x8000     
global MEM_FREE            := 0x10000     
global MEM_PRIVATE         := 0x20000     
global MEM_MAPPED          := 0x40000     
global MEM_RESET           := 0x80000     
global MEM_TOP_DOWN       := 0x100000     
global MEM_WRITE_WATCH    := 0x200000     
global MEM_PHYSICAL       := 0x400000     
global MEM_ROTATE         := 0x800000     
global MEM_LARGE_PAGES  := 0x20000000     
global MEM_4MB_PAGES    := 0x80000000     

;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------

; ======================================================================================================================
; Function:         Constants for TreeView controls
; AHK version:      1.1.05+
; Language:         English
; Version:          1.0.00.00/2012-04-01/just me
; ======================================================================================================================
; CCM_FIRST = 0x2000
; TV_FIRST  = 0x1100
; TVN_FIRST = -400
; ======================================================================================================================
; Class ================================================================================================================
Global WC_TREEVIEW             := "SysTreeView32"
; Messages =============================================================================================================
Global TVM_CREATEDRAGIMAGE     := 0x1112 ; (TV_FIRST + 18)
Global TVM_DELETEITEM          := 0x1101 ; (TV_FIRST + 1)
Global TVM_EDITLABELA          := 0x110E ; (TV_FIRST + 14)
Global TVM_EDITLABELW          := 0x1141 ; (TV_FIRST + 65)
Global TVM_ENDEDITLABELNOW     := 0x1116 ; (TV_FIRST + 22)
Global TVM_ENSUREVISIBLE       := 0x1114 ; (TV_FIRST + 20)
Global TVM_EXPAND              := 0x1102 ; (TV_FIRST + 2)
Global TVM_GETBKCOLOR          := 0x112F ; (TV_FIRST + 31)
Global TVM_GETCOUNT            := 0x1105 ; (TV_FIRST + 5)
Global TVM_GETEDITCONTROL      := 0x110F ; (TV_FIRST + 15)
Global TVM_GETEXTENDEDSTYLE    := 0x112D ; (TV_FIRST + 45)
Global TVM_GETIMAGELIST        := 0x1108 ; (TV_FIRST + 8)
Global TVM_GETINDENT           := 0x1106 ; (TV_FIRST + 6)
Global TVM_GETINSERTMARKCOLOR  := 0x1126 ; (TV_FIRST + 38)
Global TVM_GETISEARCHSTRINGA   := 0x1117 ; (TV_FIRST + 23)
Global TVM_GETISEARCHSTRINGW   := 0x1140 ; (TV_FIRST + 64)
Global TVM_GETITEMA            := 0x110C ; (TV_FIRST + 12)
Global TVM_GETITEMHEIGHT       := 0x111C ; (TV_FIRST + 28)
Global TVM_GETITEMPARTRECT     := 0x1148 ; (TV_FIRST + 72) ; >= Vista
Global TVM_GETITEMRECT         := 0x1104 ; (TV_FIRST + 4)
Global TVM_GETITEMSTATE        := 0x1127 ; (TV_FIRST + 39)
Global TVM_GETITEMW            := 0x113E ; (TV_FIRST + 62)
Global TVM_GETLINECOLOR        := 0x1129 ; (TV_FIRST + 41)
Global TVM_GETNEXTITEM         := 0x110A ; (TV_FIRST + 10)
Global TVM_GETSCROLLTIME       := 0x1122 ; (TV_FIRST + 34)
Global TVM_GETSELECTEDCOUNT    := 0x1146 ; (TV_FIRST + 70) ; >= Vista
Global TVM_GETTEXTCOLOR        := 0x1120 ; (TV_FIRST + 32)
Global TVM_GETTOOLTIPS         := 0x1119 ; (TV_FIRST + 25)
Global TVM_GETUNICODEFORMAT    := 0x2006 ; (CCM_FIRST + 6) CCM_GETUNICODEFORMAT
Global TVM_GETVISIBLECOUNT     := 0x1110 ; (TV_FIRST + 16)
Global TVM_HITTEST             := 0x1111 ; (TV_FIRST + 17)
Global TVM_INSERTITEMA         := 0x1100 ; (TV_FIRST + 0)
Global TVM_INSERTITEMW         := 0x1142 ; (TV_FIRST + 50)
Global TVM_MAPACCIDTOHTREEITEM := 0x112A ; (TV_FIRST + 42)
Global TVM_MAPHTREEITEMTOACCID := 0x112B ; (TV_FIRST + 43)
Global TVM_SELECTITEM          := 0x110B ; (TV_FIRST + 11)
Global TVM_SETAUTOSCROLLINFO   := 0x113B ; (TV_FIRST + 59)
Global TVM_SETBKCOLOR          := 0x111D ; (TV_FIRST + 29)
Global TVM_SETEXTENDEDSTYLE    := 0x112C ; (TV_FIRST + 44)
Global TVM_SETIMAGELIST        := 0x1109 ; (TV_FIRST + 9)
Global TVM_SETINDENT           := 0x1107 ; (TV_FIRST + 7)
Global TVM_SETINSERTMARK       := 0x111A ; (TV_FIRST + 26)
Global TVM_SETINSERTMARKCOLOR  := 0x1125 ; (TV_FIRST + 37)
Global TVM_SETITEMA            := 0x110D ; (TV_FIRST + 13)
Global TVM_SETITEMHEIGHT       := 0x111B ; (TV_FIRST + 27)
Global TVM_SETITEMW            := 0x113F ; (TV_FIRST + 63)
Global TVM_SETLINECOLOR        := 0x1128 ; (TV_FIRST + 40)
Global TVM_SETSCROLLTIME       := 0x1121 ; (TV_FIRST + 33)
Global TVM_SETTEXTCOLOR        := 0x111E ; (TV_FIRST + 30)
Global TVM_SETTOOLTIPS         := 0x1118 ; (TV_FIRST + 24)
Global TVM_SETUNICODEFORMAT    := 0x2005 ; (CCM_FIRST + 5) ; CCM_SETUNICODEFORMAT
Global TVM_SHOWINFOTIP         := 0x1147 ; (TV_FIRST + 71) ; >= Vista
Global TVM_SORTCHILDREN        := 0x1113 ; (TV_FIRST + 19)
Global TVM_SORTCHILDRENCB      := 0x1115 ; (TV_FIRST + 21)
; Notifications ========================================================================================================
Global TVN_ASYNCDRAW           := -420 ; (TVN_FIRST - 20) >= Vista
Global TVN_BEGINDRAGA          := -427 ; (TVN_FIRST - 7)
Global TVN_BEGINDRAGW          := -456 ; (TVN_FIRST - 56)
Global TVN_BEGINLABELEDITA     := -410 ; (TVN_FIRST - 10)
Global TVN_BEGINLABELEDITW     := -456 ; (TVN_FIRST - 59)
Global TVN_BEGINRDRAGA         := -408 ; (TVN_FIRST - 8)
Global TVN_BEGINRDRAGW         := -457 ; (TVN_FIRST - 57)
Global TVN_DELETEITEMA         := -409 ; (TVN_FIRST - 9)
Global TVN_DELETEITEMW         := -458 ; (TVN_FIRST - 58)
Global TVN_ENDLABELEDITA       := -411 ; (TVN_FIRST - 11)
Global TVN_ENDLABELEDITW       := -460 ; (TVN_FIRST - 60)
Global TVN_GETDISPINFOA        := -403 ; (TVN_FIRST - 3)
Global TVN_GETDISPINFOW        := -452 ; (TVN_FIRST - 52)
Global TVN_GETINFOTIPA         := -412 ; (TVN_FIRST - 13)
Global TVN_GETINFOTIPW         := -414 ; (TVN_FIRST - 14)
Global TVN_ITEMCHANGEDA        := -418 ; (TVN_FIRST - 18) ; >= Vista
Global TVN_ITEMCHANGEDW        := -419 ; (TVN_FIRST - 19) ; >= Vista
Global TVN_ITEMCHANGINGA       := -416 ; (TVN_FIRST - 16) ; >= Vista
Global TVN_ITEMCHANGINGW       := -417 ; (TVN_FIRST - 17) ; >= Vista
Global TVN_ITEMEXPANDEDA       := -406 ; (TVN_FIRST - 6)
Global TVN_ITEMEXPANDEDW       := -455 ; (TVN_FIRST - 55)
Global TVN_ITEMEXPANDINGA      := -405 ; (TVN_FIRST - 5)
Global TVN_ITEMEXPANDINGW      := -454 ; (TVN_FIRST - 54)
Global TVN_KEYDOWN             := -412 ; (TVN_FIRST - 12)
Global TVN_SELCHANGEDA         := -402 ; (TVN_FIRST - 2)
Global TVN_SELCHANGEDW         := -451 ; (TVN_FIRST - 51)
Global TVN_SELCHANGINGA        := -401 ; (TVN_FIRST - 1)
Global TVN_SELCHANGINGW        := -450 ; (TVN_FIRST - 50)
Global TVN_SETDISPINFOA        := -404 ; (TVN_FIRST - 4)
Global TVN_SETDISPINFOW        := -453 ; (TVN_FIRST - 53)
Global TVN_SINGLEEXPAND        := -415 ; (TVN_FIRST - 15)
; Styles ===============================================================================================================
Global TVS_CHECKBOXES          := 0x0100
Global TVS_DISABLEDRAGDROP     := 0x0010
Global TVS_EDITLABELS          := 0x0008
Global TVS_FULLROWSELECT       := 0x1000
Global TVS_HASBUTTONS          := 0x0001
Global TVS_HASLINES            := 0x0002
Global TVS_INFOTIP             := 0x0800
Global TVS_LINESATROOT         := 0x0004
Global TVS_NOHSCROLL           := 0x8000 ; TVS_NOSCROLL overrides this
Global TVS_NONEVENHEIGHT       := 0x4000
Global TVS_NOSCROLL            := 0x2000
Global TVS_NOTOOLTIPS          := 0x0080
Global TVS_RTLREADING          := 0x0040
Global TVS_SHOWSELALWAYS       := 0x0020
Global TVS_SINGLEEXPAND        := 0x0400
Global TVS_TRACKSELECT         := 0x0200
; Exstyles =============================================================================================================
Global TVS_EX_AUTOHSCROLL         := 0x0020 ; >= Vista
Global TVS_EX_DIMMEDCHECKBOXES    := 0x0200 ; >= Vista
Global TVS_EX_DOUBLEBUFFER        := 0x0004 ; >= Vista
Global TVS_EX_DRAWIMAGEASYNC      := 0x0400 ; >= Vista
Global TVS_EX_EXCLUSIONCHECKBOXES := 0x0100 ; >= Vista
Global TVS_EX_FADEINOUTEXPANDOS   := 0x0040 ; >= Vista
Global TVS_EX_MULTISELECT         := 0x0002 ; >= Vista - Not supported. Do not use.
Global TVS_EX_NOINDENTSTATE       := 0x0008 ; >= Vista
Global TVS_EX_NOSINGLECOLLAPSE    := 0x0001 ; >= Vista - Intended for internal use; not recommended for use in applications.
Global TVS_EX_PARTIALCHECKBOXES   := 0x0080 ; >= Vista
Global TVS_EX_RICHTOOLTIP         := 0x0010 ; >= Vista
; Others ===============================================================================================================
; Item flags
Global TVIF_CHILDREN           := 0x0040
Global TVIF_DI_SETITEM         := 0x1000
Global TVIF_EXPANDEDIMAGE      := 0x0200 ; >= Vista
Global TVIF_HANDLE             := 0x0010
Global TVIF_IMAGE              := 0x0002
Global TVIF_INTEGRAL           := 0x0080
Global TVIF_PARAM              := 0x0004
Global TVIF_SELECTEDIMAGE      := 0x0020
Global TVIF_STATE              := 0x0008
Global TVIF_STATEEX            := 0x0100 ; >= Vista
Global TVIF_TEXT               := 0x0001
; Item states
Global TVIS_BOLD               := 0x0010
Global TVIS_CUT                := 0x0004
Global TVIS_DROPHILITED        := 0x0008
Global TVIS_EXPANDED           := 0x0020
Global TVIS_EXPANDEDONCE       := 0x0040
Global TVIS_EXPANDPARTIAL      := 0x0080
Global TVIS_OVERLAYMASK        := 0x0F00
Global TVIS_SELECTED           := 0x0002
Global TVIS_STATEIMAGEMASK     := 0xF000
Global TVIS_USERMASK           := 0xF000
; TVITEMEX uStateEx
Global TVIS_EX_ALL             := 0x0002 ; not documented
Global TVIS_EX_DISABLED        := 0x0002 ; >= Vista
Global TVIS_EX_FLAT            := 0x0001
; TVINSERTSTRUCT hInsertAfter
Global TVI_FIRST               := -65535 ; (-0x0FFFF)
Global TVI_LAST                := -65534 ; (-0x0FFFE)
Global TVI_ROOT                := -65536 ; (-0x10000)
Global TVI_SORT                := -65533 ; (-0x0FFFD)
; TVM_EXPAND wParam
Global TVE_COLLAPSE            := 0x0001
Global TVE_COLLAPSERESET       := 0x8000
Global TVE_EXPAND              := 0x0002
Global TVE_EXPANDPARTIAL       := 0x4000
Global TVE_TOGGLE              := 0x0003
; TVM_GETIMAGELIST wParam
Global TVSIL_NORMAL            := 0
Global TVSIL_STATE             := 2
; TVM_GETNEXTITEM wParam
Global TVGN_CARET              := 0x0009
Global TVGN_CHILD              := 0x0004
Global TVGN_DROPHILITE         := 0x0008
Global TVGN_FIRSTVISIBLE       := 0x0005
Global TVGN_LASTVISIBLE        := 0x000A
Global TVGN_NEXT               := 0x0001
Global TVGN_NEXTSELECTED       := 0x000B ; >= Vista (MSDN)     
Global TVGN_NEXTVISIBLE        := 0x0006
Global TVGN_PARENT             := 0x0003
Global TVGN_PREVIOUS           := 0x0002
Global TVGN_PREVIOUSVISIBLE    := 0x0007
Global TVGN_ROOT               := 0x0000
; TVM_SELECTITEM wParam
Global TVSI_NOSINGLEEXPAND     := 0x8000 ; Should not conflict with TVGN flags.
; TVHITTESTINFO flags
Global TVHT_ABOVE              := 0x0100
Global TVHT_BELOW              := 0x0200
Global TVHT_NOWHERE            := 0x0001
Global TVHT_ONITEMBUTTON       := 0x0010
Global TVHT_ONITEMICON         := 0x0002
Global TVHT_ONITEMINDENT       := 0x0008
Global TVHT_ONITEMLABEL        := 0x0004
Global TVHT_ONITEMRIGHT        := 0x0020
Global TVHT_ONITEMSTATEICON    := 0x0040
Global TVHT_TOLEFT             := 0x0800
Global TVHT_TORIGHT            := 0x0400
Global TVHT_ONITEM             := 0x0046 ; (TVHT_ONITEMICON | TVHT_ONITEMLABEL | TVHT_ONITEMSTATEICON)
; TVGETITEMPARTRECTINFO partID (>= Vista)
Global TVGIPR_BUTTON           := 0x0001
; NMTREEVIEW action
Global TVC_BYKEYBOARD          := 0x0002
Global TVC_BYMOUSE             := 0x0001
Global TVC_UNKNOWN             := 0x0000
; TVN_SINGLEEXPAND return codes
Global TVNRET_DEFAULT          := 0
Global TVNRET_SKIPOLD          := 1
Global TVNRET_SKIPNEW          := 2


; ======================================================================================================================

;--------------------------------------------------------------------------------------------------
; Title:  Remote TreeView class
;         This class allows a script to work with TreeViews controlled by a third party process.
;
;         8/30/2012  Released for beta testing
;
;         8/31/2012  Added a wait parameter to SetSelection
;                    Changed name of ExpandCollapse to Expand
;                    Changed default WaitTime of Expand to 0
;
;         9/2/2012	 Removed GetState method and replaced it with the IsBold, IsChecked, IsExpanded
; 					 and IsSelected methods.
;
;         9/7/2012   Added Check method.
;                    For ease of use, changed parameters of SetSelection, Expand and IsChecked methods.
;
;         9/17/2012  Extended the "Full" option of GetNext() to allow it to transverse sub-trees. 
;                    Given a starting node, all decendents of that node will be  transversed depth
;                    first. Those nodes which are not descendants of the starting node will NOT be
;                    visited. To traverse the entire tree, including the real root, pass zero as the
;                    starting node.
;
;         11/02/2014 Fix for GetText and ddditional function from just me
;                    See http://ahkscript.org/boards/viewtopic.php?f=5&t=4998#p29339
;
class RemoteTreeView
{
	;----------------------------------------------------------------------------------------------
	; Method: __New
	;         Stores the TreeView's Control HWnd in the object for later use
	;
	; Parameters:
	;         TVHnd			- HWND of the TreeView control
	;
	; Returns:
	;         Nothing
	;
	__New(TVHnd)
	{
		this.TVHnd := TVHnd
	}
	
	;----------------------------------------------------------------------------------------------
	; Method: SetSelection
	;         Makes the given item selected and expanded. Optionally scrolls the 
	;         TreeView so the item is visible.
	;
	; Parameters:
	;         pItem			- Handle to the item you wish selected
	;
	; Returns:
	;         TRUE if successful, or FALSE otherwise
	;
	SetSelection(pItem)
	{
		; ORI SendMessage TVM_SELECTITEM, TVGN_CARET|TVSI_NOSINGLEEXPAND, pItem, , % "ahk_id " this.TVHnd
		; sle118 : 
		SendMessage TVM_SELECTITEM, TVGN_FIRSTVISIBLE, pItem, , "ahk_id " this.TVHnd
		return ErrorLevel
	}
	
	;----------------------------------------------------------------------------------------------
	; Method: GetSelection
	;         Retrieves the currently selected item
	;
	; Parameters:
	;         None
	;
	; Returns:
	;         Handle to the selected item if successful, Null otherwise.
	;
	GetSelection()
	{
		SendMessage TVM_GETNEXTITEM, TVGN_CARET, 0, , "ahk_id " this.TVHnd
		return ErrorLevel
	}
	
	;----------------------------------------------------------------------------------------------
	; Method: GetRoot
	;         Retrieves the root item of the treeview
	;
	; Parameters:
	;         None
	;
	; Returns:
	;         Handle to the topmost or very first item of the tree-view control
	;         if successful, NULL otherwise.
	;
	GetRoot()
	{
		SendMessage TVM_GETNEXTITEM, TVGN_ROOT, 0, , "ahk_id " this.TVHnd
		return ErrorLevel
	}

	;----------------------------------------------------------------------------------------------
	; Method: GetParent
	;         Retrieves an item's parent
	;
	; Parameters:
	;         pItem			- Handle to the item
	;
	; Returns:
	;         Handle to the parent of the specified item. Returns
	;         NULL if the item being retrieved is the root node of the tree.
	;
	GetParent(pItem)
	{
		SendMessage TVM_GETNEXTITEM, TVGN_PARENT, pItem, , "ahk_id " this.TVHnd
		return ErrorLevel
	}

	;----------------------------------------------------------------------------------------------
	; Method: GetChild
	;         Retrieves an item's first child
	;
	; Parameters:
	;         pItem			- Handle to the item
	;
	; Returns:
	;         Handle to the first Child of the specified item, NULL otherwise.
	;
	GetChild(pItem)
	{
		SendMessage TVM_GETNEXTITEM, TVGN_CHILD, pItem, , "ahk_id " this.TVHnd
		return ErrorLevel
	}

	;----------------------------------------------------------------------------------------------
	; Method: GetNext
	;         Returns the handle of the sibling below the specified item (or 0 if none).
	;
	; Parameters:
	;         pItem			- (Optional) Handle to the item
	;
	;         flag          - (Optional) "FULL" or "F"
	;
	; Returns:
	;         This method has the following modes:
	;              1. When all parameters are omitted, it returns the handle
	;                 of the first/top item in the TreeView (or 0 if none). 
	;
	;              2. When the only first parameter (pItem) is present, it returns the 
	;                 handle of the sibling below the specified item (or 0 if none).
	;                 If the first parameter is 0, it returns the handle of the first/top
	;                 item in the TreeView (or 0 if none).
	;
	;              3. When the second parameter is "Full" or "F", the first time GetNext()
	;                 is called the hItem passed is considered the "root" of a sub-tree that 
	;                 will be transversed in a depth first manner. No nodes except the
	;                 decendents of that "root" will be visited. To traverse the entire tree, 
	;                 including the real root, pass zero in the first call.
	;
	;                 When all descendants have benn visited, the method returns zero.
	;
	; Example:
	;				hItem = 0  ; Start the search at the top of the tree.
	;				Loop
	;				{
	;					hItem := MyTV.GetNext(hItem, "Full")
	;					if not hItem  ; No more items in tree.
	;						break
	;					ItemText := MyTV.GetText(hItem)
	;					MsgBox The next Item is %hItem%, whose text is "%ItemText%".
	;				}
	;
	GetNext(pItem := 0, flag := "")
	{
		static Root := -1
		
		if (RegExMatch(flag, "i)^\s*(F|Full)\s*$")) {
			if (Root = -1) {
				Root := pItem
			}
			SendMessage TVM_GETNEXTITEM, TVGN_CHILD, pItem, , "ahk_id " this.TVHnd
			if (ErrorLevel = 0) {
				SendMessage TVM_GETNEXTITEM, TVGN_NEXT, pItem, , "ahk_id " this.TVHnd
				if (ErrorLevel = 0) {
					Loop {
						SendMessage TVM_GETNEXTITEM, TVGN_PARENT, pItem, , "ahk_id " this.TVHnd
						if (ErrorLevel = Root) {
							Root := -1
							return 0
						}
						pItem := ErrorLevel
						SendMessage TVM_GETNEXTITEM, TVGN_NEXT, pItem, , "ahk_id " this.TVHnd
					} until ErrorLevel
				}
			}
			return ErrorLevel
		}
		
		Root := -1
		if (!pItem)
			SendMessage TVM_GETNEXTITEM, TVGN_ROOT, 0, , "ahk_id " this.TVHnd
		else
			SendMessage TVM_GETNEXTITEM, TVGN_NEXT, pItem, , "ahk_id " this.TVHnd
		return ErrorLevel
	}

	;----------------------------------------------------------------------------------------------
	; Method: GetPrev
	;         Returns the handle of the sibling above the specified item (or 0 if none).
	;
	; Parameters:
	;         pItem			- Handle to the item
	;
	; Returns:
	;         Handle of the sibling above the specified item (or 0 if none).
	;
	GetPrev(pItem)
	{
		SendMessage TVM_GETNEXTITEM, TVGN_PREVIOUS, pItem, , "ahk_id " this.TVHnd
		return ErrorLevel
	}
	
	;----------------------------------------------------------------------------------------------
	; Method: Expand
	;         Expands or collapses the specified tree node
	;
	; Parameters:
	;         pItem			- Handle to the item
	;
	;         flag			- Determines whether the node is expanded or collapsed.
	;                         true : expand the node (default)
	;                         false : collapse the node
	;
	;
	; Returns:
	;         Nonzero if the operation was successful, or zero otherwise.
	;
	Expand(pItem, DoExpand := true)
	{
		flag := DoExpand ? TVE_EXPAND : TVE_COLLAPSE
		SendMessage TVM_EXPAND, flag, pItem, , "ahk_id " this.TVHnd
		return ErrorLevel
	}

	;----------------------------------------------------------------------------------------------
	; Method: Check
	;         Changes the state of a treeview item's check box
	;
	; Parameters:
	;         pItem			- Handle to the item
	;
	;         fCheck        - If true, check the node
	;                         If false, uncheck the node
	;
	;         Force			- If true (default), prevents this method from failing due to 
	;                         the node having an invalid initial state. See IsChecked 
	;                         method for more info.
	;
	; Returns:
	;         Returns true if if successful, otherwise false
	;
	; Remarks:
	;         This method makes pItem the current selection.
	;
	Check(pItem, fCheck, Force := true)
	{
		SavedDelay := A_KeyDelay
		SetKeyDelay 30
		
		CurrentState := this.IsChecked(pItem, false)
		if (CurrentState = -1) 
			if (Force) {
				ControlSend "", "{Space}", "ahk_id " this.TVHnd
				CurrentState := this.IsChecked(pItem, false)
			}
			else 
				return false
		
		if (CurrentState and not fCheck) or (not CurrentState and fCheck )
			ControlSend "", "{Space}", "ahk_id " this.TVHnd
		
		SetKeyDelay SavedDelay
		return true
	}

    ;----------------------------------------------------------------------------------------------
    ; Method: GetText
    ;         Retrieves the text/name of the specified node
    ;
    ; Parameters:
    ;         pItem         - Handle to the item
    ;
    ; Returns:
    ;         The text/name of the specified Item. If the text is longer than 127, only
    ;         the first 127 characters are retrieved.
    ;
    ; Fix from just me (http://ahkscript.org/boards/viewtopic.php?f=5&t=4998#p29339)
	;
    GetText(pItem)
    {
        TVM_GETITEM := A_IsUnicode ? TVM_GETITEMW : TVM_GETITEMA

        ProcessId := WinGetPid("ahk_id " this.TVHnd)
        hProcess := OpenProcess(PROCESS_VM_OPERATION|PROCESS_VM_READ
                               |PROCESS_VM_WRITE|PROCESS_QUERY_INFORMATION
                               , false, ProcessId)

        ; Try to determine the bitness of the remote tree-view's process
        ProcessIs32Bit := A_PtrSize = 8 ? False : True
        If (A_Is64bitOS) && DllCall("Kernel32.dll\IsWow64Process", "Ptr", hProcess, "UIntP", WOW64)
            ProcessIs32Bit := WOW64

        Size := ProcessIs32Bit ?  60 : 80 ; Size of a TVITEMEX structure

        _tvi := VirtualAllocEx(hProcess, 0, Size, MEM_COMMIT, PAGE_READWRITE)
        _txt := VirtualAllocEx(hProcess, 0, 256,  MEM_COMMIT, PAGE_READWRITE)

        ; TVITEMEX Structure
        VarSetCapacity(tvi, Size, 0)
        NumPut(TVIF_TEXT|TVIF_HANDLE, tvi, 0, "UInt")
        If (ProcessIs32Bit)
        {
            NumPut(pItem, tvi,  4, "UInt")
            NumPut(_txt , tvi, 16, "UInt")
            NumPut(127  , tvi, 20, "UInt")
        }
        Else
        {
            NumPut(pItem, tvi,  8, "UInt64")
            NumPut(_txt , tvi, 24, "UInt64")
            NumPut(127  , tvi, 32, "UInt")
        }

        VarSetCapacity(txt, 256, 0)
        WriteProcessMemory(hProcess, _tvi, &tvi, Size)
        SendMessage TVM_GETITEM, 0, _tvi, ,  "ahk_id " this.TVHnd
        ReadProcessMemory(hProcess, _txt, txt, 256)

        VirtualFreeEx(hProcess, _txt, 0, MEM_RELEASE)
        VirtualFreeEx(hProcess, _tvi, 0, MEM_RELEASE)
        CloseHandle(hProcess)

        return txt
    }
 
	;----------------------------------------------------------------------------------------------
	; Method: EditLabel
	;         Begins in-place editing of the specified item's text, replacing the text of the 
	;         item with a single-line edit control containing the text. This method implicitly 
	;         selects and focuses the specified item.
	;
	; Parameters:
	;         pItem			- Handle to the item
	;
	; Returns:
	;         Returns the handle to the edit control used to edit the item text if successful, 
	;         or NULL otherwise. When the user completes or cancels editing, the edit control 
	;         is destroyed and the handle is no longer valid.
	;
	EditLabel(pItem)
	{
		TVM_EDITLABEL := A_IsUnicode ? TVM_EDITLABELW : TVM_EDITLABELA
		SendMessage TVM_EDITLABEL, 0, pItem, , "ahk_id " this.TVHnd
		return ErrorLevel
	}
	
	;----------------------------------------------------------------------------------------------
	; Method: GetCount
	;         Returns the total number of expanded items in the control
	;
	; Parameters:
	;         None
	;
	; Returns:
	;         Returns the total number of expanded items in the control 
	;
	GetCount()
	{
		SendMessage TVM_GETCOUNT, 0, 0, , "ahk_id " this.TVHnd
		return ErrorLevel
	}
	
	;----------------------------------------------------------------------------------------------
	; Method: IsChecked
	;         Retrieves an item's checked status
	;
	; Parameters:
	;         pItem			- Handle to the item
	;
	;         Force			- If true (default), forces the node to return a valid state.
	;                         Since this involves toggling the state of the check box, it
	;                         can have undesired side effects. Make this false to disable 
	;                         this feature.
	; Returns:
	;         Returns 1 if the item is checked, 0 if unchecked.
	;
	;         Returns -1 if the checkbox state cannot be determined because no checkbox
	;         image is currently associated with the node and Force is false. 
	;
	; Remarks:
	;         Due to a "feature" of Windows, a checkbox can be displayed even if no checkbox image
	;         is associated with the node. It is important to either check the actual value returned 
	;         or make the Force parameter true.
	; 
	;         This method makes pItem the current selection.
	;
	IsChecked(pItem, Force := true)
	{
		SavedDelay := A_KeyDelay
		SetKeyDelay 30
		
		this.SetSelection(pItem)
		SendMessage TVM_GETITEMSTATE, pItem, 0, , "ahk_id " this.TVHnd
		State := ((ErrorLevel & TVIS_STATEIMAGEMASK) >> 12) - 1
		
		if (State = -1 and Force) {
			ControlSend "", "{Space 2}", "ahk_id " this.TVHnd
			SendMessage TVM_GETITEMSTATE, pItem, 0, , "ahk_id " this.TVHnd
			State := ((ErrorLevel & TVIS_STATEIMAGEMASK) >> 12) - 1
		}
		
		SetKeyDelay SavedDelay
		return State
	}
	
	;----------------------------------------------------------------------------------------------
	; Method: IsBold
	;         Check if a node is in bold font
	;
	; Parameters:
	;         pItem			- Handle to the item
	;
	; Returns:
	;         Returns true if the item is in bold, false otherwise.
	;
	IsBold(pItem)
	{
		SendMessage TVM_GETITEMSTATE, pItem, 0, , "ahk_id " this.TVHnd
		return (ErrorLevel & TVIS_BOLD) >> 4
	}
	
	;----------------------------------------------------------------------------------------------
	; Method: IsExpanded
	;         Check if a node has children and is expanded
	;
	; Parameters:
	;         pItem			- Handle to the item
	;
	; Returns:
	;         Returns true if the item has children and is expanded, false otherwise.
	;
	IsExpanded(pItem)
	{
		SendMessage TVM_GETITEMSTATE, pItem, 0, , "ahk_id " this.TVHnd
		return (ErrorLevel & TVIS_EXPANDED) >> 5
	}
	
	;----------------------------------------------------------------------------------------------
	; Method: IsSelected
	;         Check if a node is Selected
	;
	; Parameters:
	;         pItem			- Handle to the item
	;
	; Returns:
	;         Returns true if the item is selected, false otherwise.
	;
	IsSelected(pItem)
	{
		SendMessage TVM_GETITEMSTATE, pItem, 0, , "ahk_id " this.TVHnd
		return (ErrorLevel & TVIS_SELECTED) >> 1
	}
	
}
;==================================================================================================
;
;	Functions
;
;==================================================================================================


;----------------------------------------------------------------------------------------------
; Function: OpenProcess
;         Opens an existing local process object.
;
; Parameters:
;         DesiredAccess - The desired access to the process object. 
;
;         InheritHandle - If this value is TRUE, processes created by this process will inherit
;                         the handle. Otherwise, the processes do not inherit this handle.
;
;         ProcessId     - The Process ID of the local process to be opened. 
;
; Returns:
;         If the function succeeds, the return value is an open handle to the specified process.
;         If the function fails, the return value is NULL.
;
OpenProcess(DesiredAccess, InheritHandle, ProcessId)
{
	return DllCall("OpenProcess"
	             , "Int", DesiredAccess
				 , "Int", InheritHandle
				 , "Int", ProcessId
				 , "Ptr")
}

;----------------------------------------------------------------------------------------------
; Function: CloseHandle
;         Closes an open object handle.
;
; Parameters:
;         hObject       - A valid handle to an open object
;
; Returns:
;         If the function succeeds, the return value is nonzero.
;         If the function fails, the return value is zero.
;
CloseHandle(hObject)
{
	return DllCall("CloseHandle"
	             , "Ptr", hObject
				 , "Int")
}

;----------------------------------------------------------------------------------------------
; Function: VirtualAllocEx
;         Reserves or commits a region of memory within the virtual address space of the 
;         specified process, and specifies the NUMA node for the physical memory.
;
; Parameters:
;         hProcess      - A valid handle to an open object. The handle must have the 
;                         PROCESS_VM_OPERATION access right.
;
;         Address       - The pointer that specifies a desired starting address for the region 
;                         of pages that you want to allocate. 
;
;                         If you are reserving memory, the function rounds this address down to 
;                         the nearest multiple of the allocation granularity.
;
;                         If you are committing memory that is already reserved, the function rounds 
;                         this address down to the nearest page boundary. To determine the size of a 
;                         page and the allocation granularity on the host computer, use the GetSystemInfo 
;                         function.
;
;                         If Address is NULL, the function determines where to allocate the region.
;
;         Size          - The size of the region of memory to be allocated, in bytes. 
;
;         AllocationType - The type of memory allocation. This parameter must contain ONE of the 
;                          following values:
;								MEM_COMMIT
;								MEM_RESERVE
;								MEM_RESET
;
;         ProtectType   - The memory protection for the region of pages to be allocated. If the 
;                         pages are being committed, you can specify any one of the memory protection 
;                         constants:
;								 PAGE_NOACCESS
;								 PAGE_READONLY
;								 PAGE_READWRITE
;								 PAGE_WRITECOPY
;								 PAGE_EXECUTE
;								 PAGE_EXECUTE_READ
;								 PAGE_EXECUTE_READWRITE
;								 PAGE_EXECUTE_WRITECOPY
;
; Returns:
;         If the function succeeds, the return value is the base address of the allocated region of pages.
;         If the function fails, the return value is NULL.
;
VirtualAllocEx(hProcess, Address, Size, AllocationType, ProtectType)
{
	return DllCall("VirtualAllocEx"
				 , "Ptr", hProcess
				 , "Ptr", Address
				 , "UInt", Size
				 , "UInt", AllocationType
				 , "UInt", ProtectType
				 , "Ptr")
}

;----------------------------------------------------------------------------------------------
; Function: VirtualFreeEx
;         Releases, decommits, or releases and decommits a region of memory within the 
;         virtual address space of a specified process
;
; Parameters:
;         hProcess      - A valid handle to an open object. The handle must have the 
;                         PROCESS_VM_OPERATION access right.
;
;         Address       - The pointer that specifies a desired starting address for the region 
;                         to be freed. If the dwFreeType parameter is MEM_RELEASE, lpAddress 
;                         must be the base address returned by the VirtualAllocEx function when 
;                         the region is reserved.
;
;         Size          - The size of the region of memory to be allocated, in bytes. 
;
;                         If the FreeType parameter is MEM_RELEASE, dwSize must be 0 (zero). The function 
;                         frees the entire region that is reserved in the initial allocation call to 
;                         VirtualAllocEx.
;
;                         If FreeType is MEM_DECOMMIT, the function decommits all memory pages that 
;                         contain one or more bytes in the range from the Address parameter to 
;                         (lpAddress+dwSize). This means, for example, that a 2-byte region of memory
;                         that straddles a page boundary causes both pages to be decommitted. If Address 
;                         is the base address returned by VirtualAllocEx and dwSize is 0 (zero), the
;                         function decommits the entire region that is allocated by VirtualAllocEx. After 
;                         that, the entire region is in the reserved state.
;
;         FreeType      - The type of free operation. This parameter can be one of the following values:
;								MEM_DECOMMIT
;								MEM_RELEASE
;
; Returns:
;         If the function succeeds, the return value is a nonzero value.
;         If the function fails, the return value is 0 (zero). 
;
VirtualFreeEx(hProcess, Address, Size, FType)
{
	return DllCall("VirtualFreeEx"
				 , "Ptr", hProcess
				 , "Ptr", Address
				 , "UINT", Size
				 , "UInt", FType
				 , "Int")
}

;----------------------------------------------------------------------------------------------
; Function: WriteProcessMemory
;         Writes data to an area of memory in a specified process. The entire area to be written 
;         to must be accessible or the operation fails
;
; Parameters:
;         hProcess      - A valid handle to an open object. The handle must have the 
;                         PROCESS_VM_WRITE and PROCESS_VM_OPERATION access right.
;
;         BaseAddress   - A pointer to the base address in the specified process to which data 
;                         is written. Before data transfer occurs, the system verifies that all 
;                         data in the base address and memory of the specified size is accessible 
;                         for write access, and if it is not accessible, the function fails.
;
;         Buffer        - A pointer to the buffer that contains data to be written in the address 
;                         space of the specified process.
;
;         Size          - The number of bytes to be written to the specified process.
;
;         NumberOfBytesWritten   
;                       - A pointer to a variable that receives the number of bytes transferred 
;                         into the specified process. This parameter is optional. If NumberOfBytesWritten 
;                         is NULL, the parameter is ignored.
;
; Returns:
;         If the function succeeds, the return value is a nonzero value.
;         If the function fails, the return value is 0 (zero). 
;
WriteProcessMemory(hProcess, BaseAddress, Buffer, Size, ByRef NumberOfBytesWritten := 0)
{
	return DllCall("WriteProcessMemory"
				 , "Ptr", hProcess
				 , "Ptr", BaseAddress
				 , "Ptr", Buffer
				 , "Uint", Size
				 , "UInt*", NumberOfBytesWritten
				 , "Int")
}

;----------------------------------------------------------------------------------------------
; Function: ReadProcessMemory
;         Reads data from an area of memory in a specified process. The entire area to be read 
;         must be accessible or the operation fails
;
; Parameters:
;         hProcess      - A valid handle to an open object. The handle must have the 
;                         PROCESS_VM_READ access right.
;
;         BaseAddress   - A pointer to the base address in the specified process from which to 
;                         read. Before any data transfer occurs, the system verifies that all data 
;                         in the base address and memory of the specified size is accessible for read 
;                         access, and if it is not accessible the function fails.
;
;         Buffer        - A pointer to a buffer that receives the contents from the address space 
;                         of the specified process.
;
;         Size          - The number of bytes to be read from the specified process.
;
;         NumberOfBytesWritten   
;                       - A pointer to a variable that receives the number of bytes transferred 
;                         into the specified buffer. If lpNumberOfBytesRead is NULL, the parameter 
;                         is ignored.
;
; Returns:
;         If the function succeeds, the return value is a nonzero value.
;         If the function fails, the return value is 0 (zero). 
;
ReadProcessMemory(hProcess, BaseAddress, ByRef Buffer, Size, ByRef NumberOfBytesRead := 0)
{
	return DllCall("ReadProcessMemory"
	             , "Ptr", hProcess
				 , "Ptr", BaseAddress
				 , "Ptr", &Buffer
				 , "UInt", Size
				 , "UInt*", NumberOfBytesRead
				 , "Int")
}

;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------


