; Link:   	https://autohotkey.com/board/topic/64602-function-control-panel-ask-for-help/
; Author:	Learning one
; Date:
; for:     	AHK_L

/*

	MsgBox % ControlPanel()	; shows list of control panel items
	ControlPanel("System")		; runs specified control panel item

*/

ControlPanel(ControlPanelItem = "") {	; by Learning one.
	if (ControlPanelItem = "") {	; than return list of control panel items
		For oCplItem In ComObjCreate("Shell.Application").Namespace(0x0003).Items
			ItemsList .= oCplItem.Name "`n"
		Sort, ItemsList
		return RTrim(ItemsList, "`n")
	}
	else {	; run specified control panel item
		For oCplItem In ComObjCreate("Shell.Application").Namespace(0x0003).Items {
			If (oCplItem.Name = ControlPanelItem) {
				oCplItem.Verbs.Item(0).DoIt
				return 1
			}
		}
	}
}