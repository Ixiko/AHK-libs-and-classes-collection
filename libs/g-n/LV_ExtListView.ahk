; ----------------------------------------------------------------------------------------------------------------------
; Name .........: ExtListView library
; Description ..: Collection of functions dealing with the ListViews of external processes.
; AHK Version ..: AHK_L 1.1.13.01 x32/64 ANSI/Unicode
; Author .......: Cyruz - http://ciroprincipe.info
; License ......: WTFPL - http://www.wtfpl.net/txt/copying/
; Changelog ....: May  18, 2013 - v0.1 - First revision.
; ..............: Jun. 28, 2013 - v0.2 - Added resizable buffer option.
; ..............: Feb. 04, 2014 - v0.3 - Unicode and x64 compatibility.
; ..............: Apr. 10, 2014 - v1.0 - Code refactoring. Added encoding option and simple error management.
; ..............: May  04, 2014 - v1.1 - Detached the handles and memory allocation code.
; ..............: May  05, 2014 - v1.2 - Created ExtListView_GetAllItems and ExtListView_ToggleSelection functions.
; ..............: May  06, 2014 - v2.0 - Complete rewrite of the library. Code more modular and updateable. Separated
; ..............:                        code for De/Initialization, GetNextItem and GetItemText.
; ..............: Jul  24, 2017 - v2.1 - Fixed LVITEM size issue.

;
; ----------------------------------------------------------------------------------------------------------------------

ExtListView_GetSingleItem(ByRef objLV, sState, nCol) {                  	; Get the first item with the desired state.

    ; Function .....: ExtListView_GetSingleItem
    ; Description ..: Get the first item with the desired state.
    ; Parameters ...: objLV  - External ListView initialized object.
    ; ..............: sState - Status of the searched item. Common statuses are:
    ; ..............:          LVNI_ALL         - 0x0000
    ; ..............:          LVNI_FOCUSED     - 0x0001
    ; ..............:          LVNI_SELECTED    - 0x0002
    ; ..............:          LVNI_CUT         - 0x0004
    ; ..............:          LVNI_DROPHILITED - 0x0008
    ; ..............: nCol   - Column of the desired item (0-based index).
    ; Info .........: For more info on the sState parameter have a look at the MSDN docs for the LVM_GETNEXTITEM message:
    ; ..............: http://msdn.microsoft.com/en-us/library/windows/desktop/bb761057%28v=vs.85%29.aspx
    ; Return .......: Single item as a string.

    Try {

        If ( (nRow  := ExtListView_GetNextItem(objLV, -1, sState)) != 0xFFFFFFFF )
            sItem := ExtListView_GetItemText(objLV, nRow, nCol)

    } Catch e
      Throw e

    Return (sItem) ? sItem : 0
}

ExtListView_GetAllItems(ByRef objLV, sState:=0x0000) {                 	; Get all items that share the same status on the target ListView.

    ; ----------------------------------------------------------------------------------------------------------------------
    ; Function .....: ExtListView_GetAllItems
    ; Description ..: Get all items that share the same status on the target ListView.
    ; Parameters ...: objLV  - External ListView initialized object.
    ; ..............: sState - Status of the searched item. Common statuses are:
    ; ..............:          LVNI_ALL         - 0x0000
    ; ..............:          LVNI_FOCUSED     - 0x0001
    ; ..............:          LVNI_SELECTED    - 0x0002
    ; ..............:          LVNI_CUT         - 0x0004
    ; ..............:          LVNI_DROPHILITED - 0x0008
    ; Info .........: For more infor on the sState parameter have a look at the MSDN docs for the LVM_GETNEXTITEM message:
    ; ..............: http://msdn.microsoft.com/en-us/library/windows/desktop/bb761057%28v=vs.85%29.aspx
    ; Return .......: Multidimensional array containing ListView's items. Eg: array[row][column] := "SomeString".
    ; ----------------------------------------------------------------------------------------------------------------------

    Try {

        nRow := -1, objList := []
        Loop
        {
            If ( (nRow := ExtListView_GetNextItem(objLV, nRow, sState)) == 0xFFFFFFFF )
                Break
            x := A_Index, objList[x] := []
            Loop % objLV.cols
                objList[x][A_Index] := ExtListView_GetItemText(objLV, nRow, A_Index-1)
        }

    } Catch e
      Throw e

    Return ( objList.MaxIndex() ) ? objList : 0
}

ExtListView_ToggleSelection(ByRef objLV, bSelect:=1, nItem:=-1) {	; Select/deselect items in the target ListView.

	; ----------------------------------------------------------------------------------------------------------------------
	; Function .....: ExtListView_ToggleSelection
	; Description ..: Select/deselect items in the target ListView.
	; Parameters ...: objLV   - External ListView initializated object.
	; ..............: bSelect - 1 for selection, 0 for deselection.
	; ..............: nItem   - -1 for all items or "n" (0-based) for a specific ListView item.
	; ----------------------------------------------------------------------------------------------------------------------

    VarSetCapacity( LVITEM, objLV.szwritebuf, 0 )
    NumPut( 0x0008,                             	LVITEM, 0  ) 	; mask      	= LVIF_STATE    	= 0x0008.
    NumPut( nItem,                               	LVITEM, 4  ) 	; item
    NumPut( 0,                                      	LVITEM, 8  ) 	; iSubItem
    NumPut( (bSelect) ? 0x0002 : 0x0000, LVITEM, 12 ) 	; state       	= LVIS_SELECTED	= 0x0002 or 0x0000 (reset mask).
    NumPut( 0x0002,                             	LVITEM, 16 ) 	; stateMask	= LVIS_SELECTED	= 0x0002.

    If ( !DllCall( "WriteProcessMemory", Ptr,objLV.hproc, Ptr,objLV.pwritebuf, Ptr,&LVITEM, UInt,objLV.szwritebuf, UInt,0 ) )
        Throw Exception("objLV.pwritebuf: error writing memory", "WriteProcessMemory", "LastError: " A_LastError)
    SendMessage, 0x102B, % nItem, % objLV.pwritebuf,, % "ahk_id " objLV.hlv

return ErrorLevel
}

ExtListView_GetNextItem(ByRef objLV, nRow, lParam:=0x0000) {   	; Get the next item in the target ListView

	; ----------------------------------------------------------------------------------------------------------------------
	; Function .....: ExtListView_GetNextItem
	; Description ..: Get the next item in the target ListView.
	; Parameters ...: objLV  - External ListView initialized object.
	; ..............: nRow   - Row where to start the search for the next item (0-based index).
	; ..............: lParam - Status of the searched item. Common statuses are:
	; ..............:          LVNI_ALL         - 0x0000
	; ..............:          LVNI_FOCUSED     - 0x0001
	; ..............:          LVNI_SELECTED    - 0x0002
	; ..............:          LVNI_CUT         - 0x0004
	; ..............:          LVNI_DROPHILITED - 0x0008
	; Info .........: LVM_GETNEXTITEM - http://msdn.microsoft.com/en-us/library/windows/desktop/bb761057%28v=vs.85%29.aspx
	; Return .......: Item content as a string.
	; ----------------------------------------------------------------------------------------------------------------------
    ; LVM_GETNEXTITEM = LVM_FIRST (0x1000) + 12 = 0x100C.

    SendMessage, 0x100C, % nRow, % lParam,, % "ahk_id " objLV.hlv

Return ErrorLevel
}

ExtListView_GetItemText(ByRef objLV, nRow, nCol) {                        	; Get the text of the desired item

	; ----------------------------------------------------------------------------------------------------------------------
	; Function .....: ExtListView_GetItemText
	; Description ..: Get the text of the desired item.
	; Parameters ...: objLV - External ListView initializated object.
	; ..............: nRow  - Row of the desired item (0-based index).
	; ..............: nCol  - Column of the desired item (0-based index).
	; Return .......: Item content as a string.
	; ----------------------------------------------------------------------------------------------------------------------

    VarSetCapacity( LVITEM, objLV.szwritebuf, 0 )
    NumPut( 0x0001,          LVITEM, 0                          ) ; mask = LVIF_TEXT = 0x0001.
    NumPut( nRow,            LVITEM, 4                          ) ; iItem = Row to retrieve (0 = 1st row).
    NumPut( nCol,            LVITEM, 8                          ) ; iSubItem = The column index of the item to retrieve.
    NumPut( objLV.preadbuf,  LVITEM, 20 + (A_PtrSize - 4)       ) ; pszText = Pointer to item text string.
    NumPut( objLV.szreadbuf, LVITEM, 20 + ((A_PtrSize * 2) - 4) ) ; cchTextMax = Number of TCHARs in the buffer.

    If ( !DllCall( "WriteProcessMemory", Ptr,objLV.hproc, Ptr,objLV.pwritebuf, Ptr,&LVITEM, UInt,objLV.szwritebuf
                                       , UInt,0 ) )
        Throw Exception("objLV.pwritebuf: error writing memory", "WriteProcessMemory", "LastError: " A_LastError)

    ; LVM_GETITEMTEXTA = LVM_FIRST (0x1000) + 45  = 0x102D.
    ; LVM_GETITEMTEXTW = LVM_FIRST (0x1000) + 115 = 0x1073.
    LVM_GETITEMTEXT := (objLV.senc == "UTF-8" || objLV.senc == "UTF-16") ? 0x1073 : 0x102D
    SendMessage, %LVM_GETITEMTEXT%, %nRow%, % objLV.pwritebuf,, % "ahk_id " objLV.hlv

    VarSetCapacity(cRecvBuf, objLV.szreadbuf, 1)
    If ( !DllCall( "ReadProcessMemory", Ptr,objLV.hproc, Ptr,objLV.preadbuf, Ptr,&cRecvBuf, UInt,objLV.szreadbuf
                                      , Ptr,0 ) )
        Throw Exception("objLV.preadbuf: error reading memory", "ReadProcessMemory", "LastError: " A_LastError)

    Return StrGet(&cRecvBuf, objLV.szreadbuf, objLV.senc)
}

ExtListView_Initialize(sWnd, szReadBuf:=1024, sEnc:="CP0") {       	; Initialize the object containing ListView's related data

	; ----------------------------------------------------------------------------------------------------------------------
	; Function .....: ExtListView_Initialize
	; Description ..: Initialize the object containing ListView's related data.
	; Parameters ...: sWnd          - Title of the window containing the ListView.
	; ..............: szReadBuf         	- Size of the buffer used for reading the target process memory. It must be capable enough
	; ..............:                             	   to hold the longest cell in the ListView.
	; ..............: sEnc                   	- Target ListView's encoding. "CP0" for ANSI, "UTF-8" or "UTF-16" for Unicode.
	; Return .......: objLV           	- External ListView initializated object with the following keys:
	; ..............: objLV.swnd        	- Title of the window owning the ListView.
	; ..............: objLV.hwnd         	- Handle to the window owning the ListView.
	; ..............: objLV.hproc        	- Handle to the process owning the ListView.
	; ..............: objLV.hlv           	- Handle to the ListView.
	; ..............: objLV.hhdr         	- Handle to the header of the ListView.
	; ..............: objLV.rows         	- Number of rows in the ListView.
	; ..............: objLV.cols          	- Number of columns in the ListView.
	; ..............: objLV.senc          	- Encoding used by the process owning the ListView.
	; ..............: objLV.pwritebuf 	- Address to the buffer used to write the LVITEM message to the target ListView.
	; ..............: objLV.szwritebuf 	- Size of the write buffer.
	; ..............: objLV.preadbuf   	- Address to the buffer used to read the answer to the message sent.
	; ..............: objLV.szreadbuf  	- Size of the read buffer.
	; ----------------------------------------------------------------------------------------------------------------------

    objLV               	:= Object()
    objLV.swnd       	:= sWnd
    objLV.hwnd       	:= WinExist(sWnd)
    objLV.szwritebuf := 52 + (A_PtrSize * 2) + (A_PtrSize - 4) ; Size of LVITEM
    objLV.szreadbuf  := szReadBuf
    objLV.senc       	:= sEnc

    ControlGet, hLv, Hwnd,, SysListView321, % "ahk_id " objLV.hwnd
    objLV.hlv := hLv

    DllCall( "GetWindowThreadProcessId", Ptr,hLv, PtrP,dwProcessId )
    ; PROCESS_VM_OPERATION = 0x0008, PROCESS_VM_READ = 0x0010, PROCESS_VM_WRITE = 0x0020.
    If ( !(objLV.hproc := DllCall( "OpenProcess", UInt,0x0008|0x0010|0x0020, Int,0, UInt,dwProcessId )) )
        Throw Exception("objLV.hproc: error opening process", "OpenProcess", "LastError: " A_LastError)

    ; LVM_GETITEMCOUNT = LVM_FIRST (0x1000) + 4 = 0x1004.
    SendMessage, 0x1004, 0, 0,, % "ahk_id " objLV.hlv
    objLV.rows := ErrorLevel

    ; LVM_GETHEADER = LVM_FIRST (0x1000) + 31 = 0x101F.
    SendMessage, 0x101F, 0, 0,, % "ahk_id " objLV.hlv
    objLV.hhdr := ErrorLevel

    ; HDM_GETITEMCOUNT = HDM_FIRST (0x1200) + 0 = 0x1200.
    SendMessage, 0x1200, 0, 0,, % "ahk_id " objLV.hhdr
    objLV.cols := ErrorLevel

    ; Allocate memory on the target process before returning the object.
    If ( !__ExtListView_AllocateMemory(objLV) )
        Throw Exception("Error allocating memory", "__ExtListView_Initialize", "LastError: " A_LastError)

Return objLV
}

ExtListView_DeInitialize(ByRef objLV) {                                            	; DeInitialize the object

	; ----------------------------------------------------------------------------------------------------------------------
	; Function .....: ExtListView_DeInitialize
	; Description ..: DeInitialize the object.
	; Parameters ...: objLV - External ListView initialized object.
	; ----------------------------------------------------------------------------------------------------------------------
    ; Free the previously allocated memory on the target process.

    If ( !__ExtListView_DeAllocateMemory(objLV) )
        Throw Exception("Error deallocating memory", "__ExtListView_DeInitialize", "LastError: " A_LastError)
    DllCall( "CloseHandle", Ptr,objLV.hproc )
    objLV := ""
}

ExtListView_CheckInitObject(ByRef objLV) {                                    	; Check if the object is still referring to a valid ListView

	; ----------------------------------------------------------------------------------------------------------------------
	; Function .....: ExtListView_CheckInitObject
	; Description ..: Check if the object is still referring to a valid ListView.
	; Parameters ...: objLV - External ListView initialized object.
	; Return .......: 0 if false, handle of the window containing the ListView if true.
	; ----------------------------------------------------------------------------------------------------------------------

Return WinExist("ahk_id " objLV.hwnd)
}

__ExtListView_AllocateMemory(ByRef objLV) {                                	; Allocates memory into the target process

	; ----------------------------------------------------------------------------------------------------------------------
	; Function .....: __ExtListView_AllocateMemory
	; Description ..: Allocates memory into the target process.
	; Parameters ...: objLV - External ListView initialized object.
	; ----------------------------------------------------------------------------------------------------------------------
    ; MEM_COMMIT = 0x1000, PAGE_READWRITE = 0x4.

    If ( !(objLV.pwritebuf := DllCall( "VirtualAllocEx", Ptr,objLV.hproc, Ptr,0, UInt,objLV.szwritebuf, UInt,0x1000
                                                       , UInt,0x4 )) )
        Return 0
    If ( !(objLV.preadbuf  := DllCall( "VirtualAllocEx", Ptr,objLV.hproc, Ptr,0, UInt,objLV.szreadbuf,  UInt,0x1000
                                                       , UInt,0x4 )) )
        Return 0
    Return 1
}

__ExtListView_DeAllocateMemory(ByRef objLV) {                               ; Frees previously allocated memory

	; ----------------------------------------------------------------------------------------------------------------------
	; Function .....: __ExtListView_DeAllocateMemory
	; Description ..: Frees previously allocated memory.
	; Parameters ...: objLV - External ListView initialized object.
	; ----------------------------------------------------------------------------------------------------------------------
    ; MEM_RELEASE = 0x8000.

    If ( !DllCall( "VirtualFreeEx", Ptr,objLV.hproc, Ptr,objLV.pwritebuf, UInt,0, UInt,0x8000 ) )
        Return 0
    objLV.Remove("pwritebuf")
    If ( !DllCall( "VirtualFreeEx", Ptr,objLV.hproc, Ptr,objLV.preadbuf, UInt,0, UInt,0x8000 ) )
        Return 0
    objLV.Remove("preadbuf")
    Return 1
}

/* EXAMPLE CODE:

OnExit, QUIT
WINTITLE = Active Directory Users and Computers ahk_class MMCMainFrame
objLV := ExtListView_Initialize(WINTITLE)
HotKey, IfWinActive, %WINTITLE%
HotKey, ^!g, TOGGLESEL
Return

TOGGLESEL:
( ExtListView_CheckInitObject(objLV) ) ? objLV := ExtListView_Initialize(WINTITLE)
ExtListView_ToggleSelection(objLV, 1, 0)
Return

QUIT:
ExtListView_DeInitialize(objLV)
ExitApp

*/