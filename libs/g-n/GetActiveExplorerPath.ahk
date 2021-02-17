; Title:   	https://github.com/valuex/UniverLink/blob/d1542ebf5a42dcb3aa5a296ba8c3f28e582ced22/Word-Excel-PowerPoint.ahk
; Link:
; Author:
; Date:
; for:     	AHK_L

/*


*/

GetActiveExplorerPath() {
    explorerHwnd := WinActive("ahk_class CabinetWClass")
    if (explorerHwnd)
    {
        for window in ComObjCreate("Shell.Application").Windows
        {
            if (window.hwnd==explorerHwnd)
                return window.Document.Folder.Self.Path
        }
    }
}