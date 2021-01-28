; Link:   	https://www.autohotkey.com/boards/viewtopic.php?t=61520#p260796
; Author:
; Date:
; for:     	AHK_L

/*


*/

; Adapted from COM Object reference "Outlook.Application"
; https://autohotkey.com/board/topic/56987-com-object-reference-autohotkey-v11/page-11#457708
olApp := ComObjActive("Outlook.Application")
olTestFolder := olApp.Session.Folders("myusername@myemail.com").Folders.Item("Test")
MsgBox % olLoopFolder(olTestFolder)
ExitApp

olLoopFolder(olFolder) {

    s := "Folder: " olFolder.Name "`r`n"
	for olItem in olFolder.Items
		s .= A_Index ">" olItem.Subject "`r`n"
    for olSubFolder in olFolder.Folders
        s .= "`r`n" olLoopFolder(olSubFolder)
    return s
}

; Minor modification. This version shows the folder "path"
olLoopFolderPath(olFolder, olFolderPath:="") {
    s := "Folder: " olFolderPath olFolder.Name "`r`n"
	for olItem in olFolder.Items
		s .= A_Index ">" olItem.Subject "`r`n"
    for olSubFolder in olFolder.Folders
        s .= "`r`n" olLoopFolder(olSubFolder, olFolderPath olFolder.Name "\")
    return s
}

; This version sorts the items and adds indentation.
olLoopFolderSort(olFolder, olFolderPath:="", Depth:=0) {
    Indent := Format("{:" Depth "}", "")
    s := Indent "Folder: " olFolderPath olFolder.Name "`r`n"
	for olItem in olSortItems(olFolder.Items)
		s .= Indent A_Index ">" olItem.Subject "`r`n"
    for olSubFolder in olFolder.Folders
        s .= "`r`n" olLoopFolderSort(olSubFolder, olFolderPath olFolder.Name "\", Depth + 8)
    return s
}

olSortItems(olMailItems, Property:="[Received]", Descending:=true){
    olMailItems.Sort(Property, Descending)
    return olMailItems
}