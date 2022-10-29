CreateDirectoryMap(fso, path){ ; Returns data for all folders & files found (name, path, date created, date last modified, parent folder name, contents within (files/folders)
    
    dir := fso.GetFolder(path) ; Get contents of specified directory

    ; Create array if subfolders/files exist, else make empty string
    (folders := dir.SubFolders) ? folderData := [] : folderData := ""
    (files   := dir.Files     ) ? fileData   := [] : fileData   := ""

    ; if subfolders exist, push map of folder data into array
    if (IsObject(folderData))   
        for folder in folders
            folderData.Push( Map("Name",     folder.Name, 
                                 "Path",     folder.Path, 
                                 "Created",  folder.DateCreated,
                                 "Modified", folder.DateLastModified,
                                 "Parent",   folder.ParentFolder.Name,
                                 "Contents", CreateDirectoryMap(fso, folder.Path)) ) ; Recurse through all folders found below specified directory
    
    ; if files exist, push map of file data into array
    if (IsObject(fileData))
        for file in files
		fileData.Push( Map("Name",     file.Name, 
                           "Path",     file.Path, 
                           "Created",  file.DateCreated,
                           "Modified", file.DateLastModified,
                           "Parent",   file.ParentFolder.Name) )

    return Map("Name",     dir.Name,                ; string
               "Path",     path,                    ; string
               "Created",  dir.DateCreated,         ; string
               "Modified", dir.DateLastModified,    ; string
               "Parent",   dir.ParentFolder.Name,   ; string
               "Contents", Map("Folders", folderData, "Files", fileData)) ; Map with Array of nested Map objects
}