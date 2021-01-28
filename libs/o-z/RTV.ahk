;-------------------------------------------------------------------------------------------
; Title:	Remote TreeView
;			Functions for working with remote TreeView controls
;>
;			This is set of function to work with TreeViews controled by third party process.
;			This process requires some data to be injected into remote process address space
;			thus this library depends on *Remote Buffer* module.
;

;----------------------------------------------------------------------------------------- 
; Function: Initialise
;			Initialization function
;
; Parameters:
;			hwParent	- HWND of the window containing TreeView
;			hwTV		- HWND of the TreeView
;
; Remarks:
;			All other functions will operate upon those two HWND's
;
TV_Initialise( hwParent, hwTV ){
	global
	static init

	TV_hwHost		:= hwParent
	TV_hwTV			:= hwTV 

	;API MESSAGES
	if !init
	{
		TVE_EXPAND		= 2

		TVM_EXPAND		= 0x1102
		TVM_GETITEM		= 0x110C
		TVM_GETNEXTITEM = 0x110A
		TVM_SELECTITEM  = 4363

		TVGN_ROOT		= 0
		TVGN_NEXT		= 1
		TVGN_CHILD		= 4
		TVGN_PARENT		= 3
		TVGN_CARET		= 9

		TVIF_STATE		= 8
		TVIS_SELECTED	= 2

		init := true
	}
}

;----------------------------------------------------------------------------
; Function:	FindDrive
;			Find the drive item in "My Computer" branch
;
; Parameters: 
;			drive	- Drive letter to find
;
; Returns:
;			Handle to the item that display's drive letter
;
; Remarks:
;			This is specific to Explorer's TreeView and ther system windows wich 
;			use the same presentation of file system hierarchy (like Browse For Folders
;			standard dialog and similar).
;
TV_FindDrive( drive )
{
	global TV_hwTV, TVGN_ROOT, TVM_GETNEXTITEM

	myComputer := TV_GetResString("{20D04FE0-3AEA-1069-A2D8-08002B30309D}")

	;get root 
	SendMessage TVM_GETNEXTITEM, TVGN_ROOT, 0, ,ahk_id %TV_hwTV% 
	root = %ErrorLevel% 
	
	hwMC := TV_FindChild( root, myComputer ) 
	TV_Expand( hwMC )

	return TV_FindChild( hwMC, drive, 1 )
}

;----------------------------------------------------------------------------------------- 
; Function: SetPath
;			Set the location of selected item in the TreeView hierarchy
;
; Parameters:
;			path	- path to set
;
; Returns: 
;			true on success false on failure
;
; Remarks:
;			Path is *not* the file system path. If remote TreeView item has N ancestors Pi,
;			its path will be TP1\TP2\TP3...\TPN\Titem, where TP signifies text of the item P
;			
TV_SetPath( path )
{
	global TV_hwTV

	StringLeft drive, path, 2
	
	parent := TV_FindDrive( drive )
	TV_Expand( parent )

	loop, Parse, path, \
	{
		;skip drive, I already set this
		if (A_Index = 1)
			 continue 

		
		child := TV_FindChild(parent, A_LoopField)

		if (child = 0)
			return 0

		parent := child		

		;it appers that when expanding drive it needs more time
		if (A_Index = 2)
			TV_Expand( parent, 200)
		else
			TV_Expand( parent )

	}

	return TV_Select(parent)
}

;-----------------------------------------------------------------------------------------
; Function:	Select
;			Select item
;
TV_Select( item )
{
	global
	SendMessage TVM_SELECTITEM, TVGN_CARET, item, ,ahk_id %TV_hwTV% 
	return %ErrorLevel%
}

;-----------------------------------------------------------------------------------------
; Function:	Expand
;			Expand item
;
; Parameters:
;			item	 - Item to be expanded
;			waitTime - Time to wait for expansion, by default 50ms
;
TV_Expand( item, waitTime=50 )
{
	global
	SendMessage TVM_EXPAND, TVE_EXPAND, item, ,ahk_id %TV_hwTV% 
	Sleep %waitTime%	;allow it to expand
	return %ErrorLevel%
}

;----------------------------------------------------------------------------------------- 
; Function: FindChild
;			Find child by its text. Start searching from the given item
;
; Parameters:	
;			p_start	- Start searching from this item
;			p_txt	- Text to search for
;			p_mode  - Item's text contains (1) or is equal (0) to the given text
;
; Returns: 
;			Item handle or zero if no item is found
;
TV_FindChild( p_start, p_txt, p_mode=0 )
{
	global TV_hwHost, TV_hwTV, TVM_GETITEM, TVM_GETNEXTITEM, TVGN_CHILD, TVGN_NEXT

	;open remote buffers 
	bufID   := RemoteBuf_Open(TV_hwHost, 128) 
	bufAdr  := RemoteBuf_Get(bufID) 

	;Copy items name to the host adr space
	; so I can compare strings there, without transfering them here 
	r_txt	 := RemoteBuf_Open(TV_hwHost, 128)
	r_txtAdr := RemoteBuf_Get( text )
	RemoteBuf_Write( r_txt, txt, strlen(txt) )

	r_sTV    := RemoteBuf_Open(TV_hwHost, 40) 
	r_stvAdr := RemoteBuf_Get(r_sTV) 

	VarSetCapacity(sTV,   40, 1)    ;10x4 = 40 
	NumPut(0x011,  sTV, 0)   ;set mask to TVIF_TEXT | TVIF_HANDLE  = 0x001 | 0x0010  
	NumPut(bufAdr, sTV, 16)  ;set txt pointer 
	NumPut(127,    sTV, 20)  ;set txt size 


	;get first child
	SendMessage TVM_GETNEXTITEM, TVGN_CHILD, p_start, ,ahk_id %TV_hwTV% 
	child = %ErrorLevel% 
	loop
	{
		;set TVITEM item handle 
		NumPut(child, sTV, 4)    
	    RemoteBuf_Write(r_sTV, sTV, 40)		

		;get the text
		SendMessage TVM_GETITEM, 0, r_stvAdr ,, ahk_id %TV_hwTV% 
		VarSetCapacity(txt, 128, 1)
	    RemoteBuf_Read(bufID, txt, 64 ) 

		if (p_mode=0)
			if (txt = p_txt)
				break
		
		if (p_mode=1)
			 if InStr(txt, p_txt)
				break


		;get next sybiling
		SendMessage TVM_GETNEXTITEM, TVGN_NEXT, child, ,ahk_id %TV_hwTV% 
		child = %ErrorLevel% 
		if (child=0)
			break
	}

	RemoteBuf_Close( r_sTV )
	RemoteBuf_Close( r_txt )
	RemoteBuf_Close( bufID )

	return %child%
}


;----------------------------------------------------------------------------------------- 
; Function: GetTxt
;			Get the text of the item with given handle
;
; Parameters:
;			item	- Handle of the item which text is to be returned
;
; Returns:
;			Item's text
;
TV_GetTxt( item )
{
	global TV_hwHost, TV_hwTV, TVM_GETITEM

	;open remote buffers 
	bufID   := RemoteBuf_Open(TV_hwHost, 128) 
	bufAdr  := RemoteBuf_Get(bufID) 

	r_sTV	 := RemoteBuf_Open(TV_hwHost, 40) 
	r_stvAdr := RemoteBuf_Get(r_sTV) 

	VarSetCapacity(sTV,   40, 1)    ;10x4 = 40 
	NumPut(0x011,  sTV, 0)   ;set mask to TVIF_TEXT | TVIF_HANDLE  = 0x001 | 0x0010  
	NumPut(bufAdr, sTV, 16)  ;set txt pointer 
	NumPut(127,    sTV, 20)  ;set txt size 

	;set TVITEM item handle 
    NumGet(item, sTV, 4)    
    RemoteBuf_Write(r_sTV, sTV, 40)

	;get the text
    SendMessage TVM_GETITEM, 0, r_stvAdr ,, ahk_id %TV_hwTV% 

	;read from remote buffer
	VarSetCapacity(txt, 128, 1)
    RemoteBuf_Read(bufID, txt, 64 ) 

	RemoteBuf_Close( bufID )
	RemoteBuf_Close( r_sTV )

	return txt
}

;----------------------------------------------------------------------------------------- 
; Get the location of selected item in the TreeView hierarchy
;
;	Returns: item1\item2...\...\selected_item
;
TV_GetPath() 
{ 
    global TV_hwHost, TV_hwTV, TVM_GETITEM, TVM_GETNEXTITEM, TVGN_PARENT, TVGN_NEXT, TVGN_ROOT, TVGN_CARET

   ;open remote buffers 
	bufID   := RemoteBuf_Open(TV_hwHost, 64) 
	bufAdr   := RemoteBuf_Get(bufID) 

	r_sTV   := RemoteBuf_Open(TV_hwHost, 40) 
	r_stvAdr   := RemoteBuf_Get(r_sTV) 

	;get root 
	SendMessage TVM_GETNEXTITEM, TVGN_ROOT, 0, ,ahk_id %TV_hwTV% 
	root = %ErrorLevel% 
    
	;get current selection 
	SendMessage TVM_GETNEXTITEM, TVGN_CARET, 0, ,ahk_id %TV_hwTV% 
	item = %ErrorLevel% 

	VarSetCapacity(sTV,   40, 1)     ;10x4 = 40 
	NumPut(0x011,   sTV, 0)   ;set mask to TVIF_TEXT | TVIF_HANDLE  = 0x001 | 0x0010  
	NumPut(bufAdr,  sTV, 16)  ;set txt pointer 
	NumPut(127,     sTV, 20)  ;set txt size 
    
	VarSetCapacity(txt, 64, 1) 

	loop 
	{ 
      ;set TVITEM item handle 
      NumPut(item, sTV, 4)    
      RemoteBuf_Write(r_sTV, sTV, 40) 

      ;send tv_getitem message 
      SendMessage TVM_GETITEM, 0, r_stvAdr ,, ahk_id %TV_hwTV% 

      ;read from remote buffer and append the path 
      RemoteBuf_Read(bufID, txt, 64 )

      ;check for the drive 
      StringGetPos i, txt, :
      if i > 0 
      { 
         StringMid txt, txt, i, 2 
         epath = %txt%\%epath%
         break 
      } 
      else 
         epath := txt "\" epath

      ;get parent
      SendMessage TVM_GETNEXTITEM, TVGN_PARENT, item, ,ahk_id %TV_hwTV% 
      item = %ErrorLevel% 
      if (item = root) 
         break 
   } 

	RemoteBuf_Close( bufID ) 
	RemoteBuf_Close( r_sTV ) 


	StringLeft epath, epath, strlen(epath)-1 
	return epath 
} 

;----------------------------------------------------------------------------------------- 
; PRIVATE
;-----------------------------------------------------------------------------------------

TV_getResString( p_clsid )
{
	key = SOFTWARE\Classes\CLSID\%p_clsid%
	RegRead res, HKEY_LOCAL_MACHINE, %key%, LocalizedString
	
;get dll and resource id 
	StringGetPos idx, res, -, R
    StringMid, resID, res, idx+2, 256
	StringMid, resDll, res, 2, idx - 2
	resDll := TV_ExpandEnvVars(resDll)
	
;get string from resource
	VarSetCapacity(buf, 256)
	hDll := DllCall("LoadLibrary", "str", resDll)
	Result := DllCall("LoadString", "uint", hDll, "uint", resID, "str", buf, "int", 128)

	return buf
}

;----------------------------------------------------------------------------------------- 

TV_expandEnvVars(ppath)
{
	VarSetCapacity(dest, 2000) 
	DllCall("ExpandEnvironmentStrings", "str", ppath, "str", dest, int, 1999, "Cdecl int") 
	return dest
}

;--------------------------------------------------------------------------------------------------------------------- 
; Group: About 
;      o Ver 1.0 by majkinetor. See <http://www.autohotkey.com/forum/topic17299.html>
;      o Licenced under Creative Commons Attribution-Noncommercial <http://creativecommons.org/licenses/by-nc/3.0/>