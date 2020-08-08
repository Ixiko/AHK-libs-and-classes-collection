; Hotkeys:
; F1 - show the menu
; Esc - clean-up and exitapp.
#warn all
#include ..\menu_drop.ahk
#include example1_constants.ahk

m := menuCreate()
lists := { CF_TEXT : [], CF_HDROP : [] } ; lists.CF_TEXT holds dropped text, lists.CF_HDROP holds dropped files

m.add 'Drop text here', ( (arr, *) => msgbox(arr_to_text(arr)) ).bind(lists.CF_TEXT)	; Handles CF_TEXT, menu item 0
m.add 'I do not accept any drops', (*) => msgbox('Nothing to see here.')				; Doesn't accept drops, menu item 1
m.add 'Drop files here', ( (arr, *) => msgbox(arr_to_text(arr)) ).bind(lists.CF_HDROP)	; Handles CF_HDROP, menu item 2

effect_map := map(	; For the pdwEffect parameter the IDropTarget methods
		0, {format : 'CF_TEXT', effect : DROPEFFECT_COPY}, ; menu item 0 accepts text
		2, {format : 'CF_HDROP', effect : DROPEFFECT_MOVE}, ; menu item 2 accepts files
		-1, DROPEFFECT_NONE	; used to track the most recent effect 
	)

get_pos := ((h) => menu_drop.pos_map[h]).bind(m.handle) ; menu_drop class tracks which menu item (zero based)
														; the mouse is hovering over, use this function to retrieve it.
														; This function is passed to the callback functions.

menu_drop.subscribe(
		m, 	; the menu
		{ 	; the callback functions
			Drop : func('DropCallback').bind(get_pos, effect_map, lists),
			DragEnter : func('DragEnterCallback').bind(get_pos, effect_map),
			DragOver : func('DragOverCallback').bind(get_pos, effect_map)
		}
)

F1::m.show

esc::
	menu_drop.unsubscribe m
	m := ''
	exitapp
return
; Callback functions:
DropCallback(get_pos, effect_map, lists, Data, grfKeyState, pt, pdwEffect) {
	; see IDropTarget::Drop
	local
	global S_OK
	if menu_item := SetEffect(get_pos, effect_map, Data, pdwEffect) {
		; these are verified by SetEffect
		format := effect_map[menu_item - 1].format ; -1 to counter SetEffect's +1
		list := lists.%format%
		for item in Data.%format%
			list.push item
	} else {
		; This should not really happen, because when pdwEffect is
		; set to DROPEFFECT_NONE this function should not be called.
		msgbox 'I do not accept this drop!'
	}
	return S_OK
}

DragEnterCallback(get_pos, effect_map, Data, grfKeyState, pt, pdwEffect) {
	; see IDropTarget::DragEnter	
	SetEffect get_pos, effect_map, Data, pdwEffect
	return S_OK
}
DragOverCallback(get_pos, effect_map, grfKeyState, pt, pdwEffect) {
	; see IDropTarget::DragOver
	numput 'uint', effect_map[-1], pdwEffect
	return S_OK	
}

; Help function to set the correct cursor effect.
SetEffect(get_pos, effect_map, Data, pdwEffect) {
	; Called to give the appropriate visual feedback.
	; If setting an effect for this menu item, return menu item index + 1, else 0
	local
	global DROPEFFECT_NONE
	menu_item := %get_pos%()
	if effect_map.has(menu_item) {
		; this menu item accepts a drop
		format := effect_map[menu_item].format
		if Data.hasownprop(format) {
			effect := effect_map[menu_item].effect
			effect_map[-1] := effect ; store the most recent effect. for use in DragOverCallback
			numput 'uint', effect, pdwEffect
			return menu_item + 1 
		}
	}
	effect_map[-1] := DROPEFFECT_NONE
	numput 'uint', DROPEFFECT_NONE, pdwEffect
	return 0
}


; Misc help functions

arr_to_text(arr) {
	local
	str := ''
	for v in arr
		str .= v . '`n'
	return str
}