Outlook_CopyMsgToFolder(destFolder, Folder) {
    olApp := ComObjActive("Outlook.Application")
    if (olApp.ActiveWindow.Class = 34)
        olItem := olApp.ActiveExplorer.Selection.Item(1)
    else if (olApp.ActiveWindow.Class = 35)
        olItem := olApp.ActiveWindow.CurrentItem
    olNewItem := olItem.Copy()
    olDestFolder := olApp.Session.Folders(Folder).Folders(destFolder)
    olNewItem.Move(olDestFolder)
    olApp := "", olItem := "", olNewItem := "", olDestFolder := ""
}