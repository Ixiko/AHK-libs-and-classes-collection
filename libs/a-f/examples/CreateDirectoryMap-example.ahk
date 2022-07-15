if (path  := DirSelect(A_MyDocuments, 2, "Choose a directory to map out:"))
{
    fso   := ComObjCreate("Scripting.FileSystemObject") ; must create FileSystemObject to pass to function
    
    directoryMap := CreateDirectoryMap(fso, path) ; Create directory map

    try MsgBox directoryMap["Name"]                              ; get directory's name
    try MsgBox directoryMap["Parent"]                            ; get parent directory's name
    try MsgBox directoryMap["Contents"]["Folders"][1]["Name"]    ; get name of first folder found in directory
    try MsgBox directoryMap["Contents"]["File"][1]["Path"]       ; get path of first file found in directory
    try MsgBox directoryMap["Contents"]["Folders"][2]["Created"] ; get date & time created of second folder found in directory

     ; get date & time last modified of first file found in the third folder in directory
    try MsgBox directoryMap["Contents"]["Folders"][3]["Contents"]["Files"][1]["Modified"]

    ; get a list of details about each folder in directory
    folderDataList := ""
    for folder in directoryMap["Contents"]["Folders"]
        folderDataList .= A_Index ". " folder["Name"] "`n"
        .                 "Parent:`t" folder["Parent"] "`n"
        .                 "Created:`t" folder["Created"] "`n"
        .                 "Modified:`t" folder["Modified"] "`n"
        .                 "Location:`n" folder["Path"] "`n`n"
    MsgBox folderDataList

    fso := "" ; free object
}