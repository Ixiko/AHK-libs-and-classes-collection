; Title:   	https://www.autohotkey.com/boards/viewtopic.php?p=379926#p379926
; Link:
; Author:	SKAN
; Date:
; for:     	AHK_L

/*


*/

RefreshExplorer() {                ; By SKAN on D35D @ tiny.cc/refreshexplorer
Local Window
   ComObjCreate("Shell.Application").Windows.Item(ComObject(0x13,8)).Refresh()
   For  Window in ComObjCreate("Shell.Application").Windows
   If ( Window.Name="Windows Explorer" or Window.Name="File Explorer" )
        Window.Refresh()
}