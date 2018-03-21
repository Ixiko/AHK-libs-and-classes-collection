;Title: TreeViewX
;		TreeViewX  extends standard TreeView control to support moving, deleting & inserting.

;----------------------------------------------------------------------------------------
; Function: TVX
;			Initialisation function. Mandatory to call before you show the TreeView.
; 
; Parameters:
;			pTree		- AHK name of the TreeView control
;			pSub		- Subroutine for TreeViewX, the same rules as in g.
;			pOptions	- String containing space delimited options for setting up TreeViewX
;			pUserData	- Base name of the array holding user data. 
;						  This array is indexed using tree view item handles.
;			
; Options: 
;			HasRoot		- TreeViewX has root item - the one containing all other items. 
;						  Root item can't be moved, edited or delited, and items can not
;						  be moved or created outside of it. This option need to be set 
;						  after root is already added to the menu, as TreeViewX need to
;						  know the root menu handle.
;						  
;		CollapseOnMove	- When moving item out of of its container, this option makes container collapse
;		EditOnInsert	- Automaticaly enters edit mode upon insertion of new item
;
; Example:
;>
;>	 	TVX("MyTree", "Handler", "HasRoot CollapseOnMove")
;>
TVX( pTree, pSub, pOptions="", pUserData="" ) {
	global

	if InStr(pOptions, "HasRoot")	{
		TVX_HasRoot  := 1
		TVX_root := TV_GetNext()
	}
	
	if InStr(pOptions, "CollapseOnMove")
	  	TVX_CollapseOnMove := 1

	if InStr(pOptions, "EditOnInsert")
		TVX_EditOnInsert	:= 	1

	TVX_userData := pUserData
	TVX_sub := pSub
	GuiControl, +AltSubmit -ReadOnly +gTVX_OnEvent, %pTree%
}

;----------------------------------------------------------------------------------------
; Function: Walk
;			Walk the menu and rise events
; 
; Parameters:
;			root		- menu to iterate, can be simple item also
;			label		- event handler
;			event_type	- event argument 1 - Event type
;			event_param	- event argument 2 - Item upon which event is rised
;			
;
;				   Type						  Param
;
;			+  - Iteration start,			root handle
;			M  - Menu item,					menu handle 
;			I  - Item,						item handle
;			E  - End of menu				menu handle			(pseudo item)
;			-  - Iteration end				root handle			(pseudo item)
;
TVX_Walk(root, label, ByRef event_type, ByRef event_param){
	local n, t, p, c,	pref, bSetEnd, lastParent, rootsParent, tmp

	; start event for menus
	event_type := "+"
	event_param := root
	GoSub %label%

	if !TV_GetChild(root)
		return
	
	; this will be exit condition. If we come to roots parent, stop walking.
	rootsParent := TV_GetParent(root)
	
	lastParent := root
	c := root
	loop {
		c := TV_GetNext(c, "Full")
		TV_GetText(tmp, c)

		; Check if this item is submenu. If so, set the lastParent
		if ( TV_GetChild(c) ){	
			lastParent := c
			event_type := "M"
		}
		else event_type := "I"			; not a submenu, it is normal item

		event_param := c
		GoSub %label%		
	

		; Check if c is the last item in the current submenu
		; Do so by taking the next item and checking its parent.
		; If the parent is different then "lastParent" current item is 
		;  at the end of the its submenu. 
		n := TV_GetNext(c, "FULL")
		if (n)
		{
			p := TV_GetParent(n)
			if ( p != lastParent){	
				t := lastParent
				lastParent := p
			}
			else continue

			; It is the last child
			Loop {	; rise "E" (end of menu) event 
				event_type := "E"
				event_param := t
				GoSub %label%

				t := TV_GetParent(t)
				if (t = rootsParent) {	; rise "-" (end of walk) event
					event_type := "-"
					event_param := t
					GoSub %label%
					return
				}
				if (p = t)
					break
			}

		} else 
			Loop {
				 ;this is the end of the complite menu, so close all open submenus, if any
				 if (lastParent = root)	 {
					event_type := "-" 
					event_param := root
					GoSub %label%
					return
				 }
				
				 event_type := "E"
				 event_param := lastParent
				 GoSub %label%
				 lastParent := TV_GetParent(lastParent)
			}	
	}
}

;----------------------------------------------------------------------------------------------
; Function:		Move
;				Moves tree view item up or down
;
; Parameters:
;				item		-	Handle of the item to move
;				direction	-   "u" or "d" (Up & Down)
;
; Returns:
;				Handle of the item
;
; Remarks:
;				Item to be moved is copied to the new place then source item is deleted. This
;				creates new handle for the moved item. New handle will be returned by the function.
;
TVX_Move(item, direction){
	local newc, newp, t, p, n

	p := TV_GetPrev(item)
	n := TV_GetNext(item)

	if (TVX_HasRoot)
	{
		 if	TV_GetNext()=item
			return

		 if (direction="u")
		 {
			 if (p = 0 && TV_GetParent(item)=TV_GetNext())			;don't let item go above root
			 {
				TV_Modify(item)
				TVX_sel:=item
				return
			 }
		 }
	 }


	; Do so by coping an item bellow calculated item and deleting the old one.
	; Return handle of new item
 	
	; newc - calculated child after which "item" should be created. 
	; newp -  ... and its parent

	; if moving down
	if (direction = "d")
	{
		; handle end of submenu
		if !n
		{
			newc := TV_GetParent(item)

			; check the end of the entire list
			if (TVX_HasRoot && newc = TVX_root)
				return

			if TVX_CollapseOnMove
				TV_Modify(newc, "-Expand")

			newp := TV_GetParent(newc)
		}
		; somewhere in the middle 
		else 
		{
   			; if submenu, go into it
			t := TV_Get(n, "E")
			if (t = n)
			{
				newp := n
				newc := "First"
			}
			; not a submenu
			else
			{
				newc := n
				newp := TV_GetParent(n)
			}    
		}
	}

	; if moving up
	if (direction = "u")
	{
		;going up - handle start of the submenu
		if !p
		{
			t := TV_GetParent(item)
			if TVX_CollapseOnMove
				TV_Modify(t, "-Expand")
																					  
			newc := TV_GetPrev(t)
																											  
			; handle start of the menu again
			if !newc
			{
				newp := TV_GetParent(t)
				newc := "First"
			}
			else
				newp := TV_GetParent(newc)
		}
		; somewhere in the middle
		else
		{
   			; if submenu is expanded, go into it
			t := TV_Get(p, "E")
			if (t = p)
			{
				newc := "First"
				newp := t
			}
			else
			{
				t := TV_GetPrev(p)
				;check the top of the list
				if !t
				{
					newc := "First"
					newp := TV_GetParent(p)				
				}
				else 
				{
					newc := t
					newp := TV_GetParent(newc)
				}
			}
		}
	}

	newc := TVX_CopyItem(newc, newp, item)
	TV_Delete(item)
	return newc
}


;---------------------------------------------------------------------------------------------
; TVX_Walk event handler wrapped in the function
;	
; Function that copies menu item to the destination item. 
; Handle of destination item is specified in the global variable TVX_copyDest.
; 
TVX_CopyProc(iType, item) {
	local c, txt
	static lastParent
	
	TV_GetText(txt, item)
	if iType in +
	{
		lastParent := TVX_copyDest
		TV_Modify(TVX_copyDest, "", txt)
		
		if TVX_userData
		{
			%TVX_userData%%TVX_copyDest% := %TVX_userData%%item%
			%TVX_userData%%item% := ""
		}
	}

	if iType in I,M
	{
		c := TV_Add(txt, lastParent)
		if iType = M
			lastParent := c

		if TVX_userData
		{
			%TVX_userData%%c% := %TVX_userData%%item%
			%TVX_userData%%item% := ""
		}
	}

	if iType = E
		lastParent := TV_GetParent(lastParent)	
}

;----------------------------------------------

_TVX_CopyProc:
	TVX_CopyProc(TVX_itemType, TVX_param)
return

;-----------------------------------------------------------------------------------------------
; Create new item after the child "destc" with parent "destp" and copy the "source" item into it
;
TVX_CopyItem(destc, destp, source){
	global 

	;create the holder and call the copy function
	TVX_copyDest := TV_Add("", destp , destc )
	TVX_Walk(source, "_TVX_CopyProc", TVX_itemType, TVX_param)

	return TVX_copyDest
}

;----------------------------------------------------------------------------------------------
; Used to control moving
;
TVX_OnItemSelect(pItemId){
	global

	if (TVX_bSelfSelect)	{	
		TVX_bSelfSelect := false
		return true
	}	

	TVX_prevSel := TVX_sel
	TVX_sel := pItemId

	if GetKeyState("Shift") && (TVX_lastKey=38 || TVX_lastKey=40)
	 if (pItemId != TVX_root)
	 {
	  	TVX_sel := TVX_Move( TVX_prevSel, TVX_lastKey=40 ? "d" : "u")
		TVX_prevSel := pItemId

		
		TVX_bSelfSelect := true
		TV_Modify(TVX_sel, "Select Bold")
		return true
	 }

	 return false
}

;----------------------------------------------------------------------------------------------

TVX_OnKeyPress(pKey){
	local tp, sel

	TVX_lastKey := pKey

	if (TVX_bSelfPress)	{	
		TVX_bSelfPress := false
		return true
	}	

	;delete
	if pKey = 46
	{
		; use GetSelection instead Editor_sel since if key is pressed and hold
		; TVX_OnSelect handler may not be called before delete to set the TVX_sel

		sel := TV_GetSelection()
		if (TVX_HasRoot && sel = TVX_root)
			return false

		; is shift delete is pressed return - some problems with this combination
		if (GetKeyState("Shift"))
			return false

		TV_Delete(sel)
		return true
	}

	;insert
	if pKey = 45
	{
		tp := TV_GetParent(TVX_sel)
		if (TVX_sel = TVX_root)
			tp := TVX_root

		tp := TV_Add("__ new item __", tp, "Bold " . TVX_sel)
		if GetKeyState("Shift")
		{
			TV_Add("__ new item __", tp, "Bold First ")
			TV_Modify(tp,"Expand", "__ new group __")
		}

		if (TVX_EditOnInsert)
		{
			TVX_bSelfPress := TVX_bSelfSelect := true
			TV_Modify(tp, "Select")
			Send, {F2}
		}

		return true
	}

	return false
}

;----------------------------------------------------------------------------------------------
; g soubroutine for Tree View
;
TVX_OnEvent:
	if (A_GuiEvent="S")
		if TVX_OnItemSelect(A_EventInfo)
			return

	if (A_GuiEvent="K")
		if TVX_OnKeyPress(A_EventInfo)
			return
	
	;if not the Xtended property send event to the caller
	gosub %TVX_sub%
return