; **Probably needs to be run as admin**
; This script displays the Outlook addins. The user can choose to enable or disable the addins.

Gui, Add, ListView, vLV1 w800 h300, Connected|Description|ProgId|GUID
Gui, Add, Button, vB1 gToggleSelected w80, Toggle
Gui, Show
Refresh()
return

GuiClose() {
    ExitApp
}

OutlookConnect() {
    try olApp := ComObjActive("Outlook.Application")
    catch
        throw Exception("Unable to connect to Outlook.")
    return olApp
}

Refresh() {
    LV_Delete()  ; Clear the listview
    for COMAddIn, in OutlookConnect().COMAddIns
        LV_Add(""
            , (COMAddIn.Connect = -1 ? "En" : "Dis") "abled"
            ,  COMAddIn.Description
            ,  COMAddIn.ProgId
            ,  COMAddIn.Guid)
    LV_ModifyCol()  ; Auto-size each column to fit its contents.
}

ToggleSelected() {
    static ColumnNumber := 3
    olApp := OutlookConnect()
    RowNumber := 0  ; This causes the first loop iteration to start the search at the top of the list.
    Loop {  ; Get each selected row in the listview
        RowNumber := LV_GetNext(RowNumber)  ; Resume the search at the row after that found by the previous iteration.
        if !RowNumber  ; The above returned zero, so there are no more selected rows.
            break
        if LV_GetText(ProgId, RowNumber, ColumnNumber) {
            COMAddIn := olApp.COMAddIns.Item[ProgId]
            COMAddIn.Connect := COMAddIn.Connect = -1 ? 0 : -1
        }
    }
    Refresh()
}

; References
;   - https://autohotkey.com/boards/viewtopic.php?p=116938#p116938
;   - https://autohotkey.com/board/topic/71335-mickers-outlook-com-msdn-for-ahk-l/page-2#entry730111
