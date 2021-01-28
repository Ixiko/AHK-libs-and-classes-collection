OnMessage( 0x4E, "Treeview_BeginDrag" ) ; WM_NOTIFY
OnMessage( 0x200, "Treeview_Dragging" ) ; WM_MOUSEMOVE
OnMessage( 0x202, "Treeview_EndDrag" ) ; WM_LBUTTONUP

/*
; Add the Treeview
Gui, Add, TreeView, x0 y0 w200 h300 HWNDhTreeview
P1 := TV_Add("Apple", 0, "Expand" )
P1C1 := TV_Add("Apple juice", P1, "Expand" )
P2 := TV_Add("Orange", 0, "Expand" )
P2C1 := TV_Add("Orange juice", P2, "Expand" )
P2C2 := TV_Add("Orange soda", P2, "Expand" )
P2C2C1 := TV_Add("Tang", P2C2, "Expand" )
otherfruits = pear,kiwi,lime,grape,peach
Loop, parse, otherfruits, `,
	TV_ADD( A_LoopField, 0 )

; Show the GUI
Gui, Show, w200 h300
return 
; ----- End Auto-Execute section -----

guiclose:
exitapp
/*


Treeview_BeginDrag( wParam, lParam )
{
	global TV_is_dragging, hTreeview, hDragitem
	static TVM_SELECTITEM := 0x110B, TVGN_CARET := 0x9

	nmhdr_code := NumGet( lParam + 0, 8, "uint" )

	; TVN_BEGINDRAGA = 0xFFFFFE69, TVN_BEGINDRAGW = 0xFFFFFE38
	If ( nmhdr_code = 0xFFFFFE69 ) or ( nmhdr_code = 0xFFFFFE38 ) 
	{
		; Get the drag item out of the NMTREEVIEW structure
		hDragitem := NumGet( lParam + 0, 60, "uint" )

		; Select the item before dragging so it's clear what you're dragging
		SendMessage( hTreeview, TVM_SELECTITEM, TVGN_CARET, hDragitem )

		; If you were so inclined, you could initialize drag image stuff here:
		; 1. get a drag image (either by using TVM_SETIMAGE, which requires 
		;    that the Treeview control have been created with an associated
		;    imagelist) OR just use TVM_GETITEMRECT and fancy gdi-style stuff
		;    and make one yourself
		; 2. add the image to an imagelist and use the imagelist drag functions
		;    (read up on it at msdn)
		; 3. add the appropriate imagelist dragging code in the Treeview_Dragging()
		;    and Treeview_EndDrag() functions
		; 
		; I initially had some code here that was mostly working but (a) it was 
		; creating some strange visual artifacts and (b) I kind of prefer just using
		; insertion marks and highlighting the drop target.
		
		; Set the dragging flag
		TV_is_dragging := 1	
	}
}

Treeview_Dragging( wParam, lParam )
{
	global TV_is_dragging, hTreeview, height

	static TVM_HITTEST := 0x1111, TVM_SETINSERTMARK := 0x111A, TVM_GETITEMRECT := 0x1104
	static TVM_SELECTITEM := 0x110B, TVGN_DROPHILITE := 0x8, TVM_GETITEMHEIGHT := 0x111C

	If TV_is_dragging
	{
		if not height
			height := SendMessage( hTreeview, TVM_GETITEMHEIGHT, 0, 0 )

		; Get the mouse location out of lParam
		x := lParam & 0xFFFF
		y := lParam >> 16
		
		; Create the TVHITTESTINFO struct...
		VarSetCapacity( tvht, 16, 0 )
		NumPut( x, tvht, 0, "int" ), NumPut( y, tvht, 4, "int" )

		; ... to determine whether the pointer is over an item. If it is...
		If hitTarget := SendMessage( hTreeview, TVM_HITTEST, 0, &tvht )
		{
			; ... highlight the item as a drop target, and / or ...
			SendMessage( hTreeview, TVM_SELECTITEM, TVGN_DROPHILITE, hitTarget )

			; ... if the pointer is in the top or bottom quarter of the item,
			; show an insertion mark before or after, respectively.
			; This way you can decide whether to make the dragged item
			; a child or sibling of the drop target item.	
			;
			; If you really wanted, you could check here to see what kind of 
			; item hitTarget was and display the insertion mark accordingly.
			VarSetCapacity( rcitem, 16, 0 ), NumPut( hitTarget, rcitem )
			SendMessage( hTreeview, TVM_GETITEMRECT, 1, &rcitem )
			rcitem_top := NumGet( rcitem, 4, "int" )
			rcitem_bottom := NumGet( rcitem, 12, "int" )
			fAfter := 99 ; just a default that's not 0 or 1
			fAfter := ( y - rcitem_top ) < ( height/4 ) ? 0 : ( rcitem_bottom - y) < ( height/4 ) ? 1 : fAfter
			If ( fAfter = 99 )
				SendMessage( hTreeview, TVM_SETINSERTMARK, 0, 0 ) ; hide insertionmark
			Else
				SendMessage( hTreeview, TVM_SETINSERTMARK, fAfter, hitTarget ) ; show insertion mark
		}
	}
}

Treeview_EndDrag( wParam, lParam )
{
	global TV_is_dragging, hTreeview, hDragitem
	static TVM_SETINSERTMARK := 0x111A, TVM_SELECTITEM := 0x110B, TVGN_DROPHILITE := 0x8
	static TVM_HITTEST := 0x1111

	If TV_is_dragging
	{
		; Remove the drop-target highlighting and insertion mark
		SendMessage( hTreeview, TVM_SELECTITEM, TVGN_DROPHILITE, 0 )
		SendMessage( hTreeview, TVM_SETINSERTMARK, 1, 0 )

		; Add code here to handle the moving of the dragged node
		; - hDragitem is the handle to the item currently being dragged
		; - you can use the code from the WM_MOUSEMOVE to determine 
		;   where the pointer is and where/how the item should be inserted
		;
		; For the sake of simplicity, this script will always move the 
		; dragitem to be a child of the drop target
		
			; Get the mouse location out of lParam
			x := lParam & 0xFFFF
			y := lParam >> 16

			; Create the TVHITTESTINFO struct...
			VarSetCapacity( tvht, 16, 0 )
			NumPut( x, tvht, 0, "int" ), NumPut( y, tvht, 4, "int" )

			; ... to determine whether the pointer is over an item.
			If hDroptarget := SendMessage( hTreeview, TVM_HITTEST, 0, &tvht )
			{
				; Only do stuff if the droptarget is different from the drag item
				If ( hDragitem != hDroptarget )
				{
					; To prevent infinite loops, first make sure "parent" isn't actually a 
					; descendant of node (it's like going back in time and becoming your own
					; great-grandfather: no good can come of it)
					If not IsParentADescendant( hDragitem, hDroptarget )
					{
						AddNodeToParent( hDragitem, hDroptarget )
						TV_Modify( hDropTarget, "Expand" )
						TV_Delete( hDragitem )
					}
				}				
			}

		; Set the dragging flag and dragitem handle to false		
		TV_is_dragging := 0, hDragitem := 0
	}
}

IsParentADescendant( node, parent )
{
	dlist := GetDescendantsList( node )
	Loop, parse, dlist, `,
		If ( A_LoopField = parent )
			return 1
	return 0
}

; Wheeeee! Recursion is fun!
GetDescendantsList( node )
{
	If ( kid := TV_GetChild( node ) )
	{
		kids .= kid . "," . GetDescendantsList( kid )
		While ( kid := TV_GetNext( kid ) )
			kids .= kid . "," . GetDescendantsList( kid )
	}
	return kids
}

; I recurse! You recurse! We all recurse for Ira Curs! (or something )
AddNodeToParent( node, parent )
{	
	TV_GetText( t, node)
	node_id := TV_Add( t, parent, "Expand"  )
	If ( kid := TV_GetChild( node ) )
	{
		AddNodeToParent( kid, node_id )
		While ( kid := TV_GetNext( kid ) )
			AddNodeToParent( kid, node_id )
	}
	return node_id
}

SendMessage( hWnd, Msg, wParam, lParam )
{
	static SendMessageA

	If not SendMessageA
		SendMessageA := LoadDllFunction( "user32.dll", "SendMessageA" )
	
	return DllCall( SendMessageA, uint, hWnd, uint, Msg, uint , wParam, uint, lParam )
}

LoadDllFunction( file, function ) {
    if !hModule := DllCall( "GetModuleHandle", uint, &file, uint )
        hModule := DllCall( "LoadLibrary", uint, &file, uint )

    return DllCall("GetProcAddress", uint, hModule, uint, &function, uint)
}
