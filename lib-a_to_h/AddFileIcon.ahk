;---------------------------------------------------
; Function:
;     IconNumber := AddFileIcon( file, imageListID )
;
; IN:   file        = full file path
;       ImageListID = the ID of a previously created image list
;
; The function will read the icon associated with the file,
; add the icon to the image list and return the icon number
; to be used with the "Icon" property of TreeView or ListView
;
; Based on AutoHotkeys help for TreeView
;---------------------------------------------------
/*
#SingleInstance Force

ImageListID := IL_Create(10)

Gui Add, TreeView, w300 h300 vMainList ImageList%ImageListID%
Gui Show


; To test, change the below variables: Point the first to a folder with LNK files
; and the second to a folder with other files.
FolderWithLnks = C:\Documents and Settings\All Users\Start Menu\Programs\Accessories\Communications
FolderWithExes = C:\WINDOWS

Loop %FolderWithLnks%\*.*
{
  IconNumber := AddFileIcon( A_LoopFileFUllPath, ImageListID )
  TV_Add( A_LoopFileName, 0, "Icon" . IconNumber  )
}

Loop %FolderWithExes%\*.*
{
  IconNumber := AddFileIcon( A_LoopFileFUllPath, ImageListID )
  TV_Add( A_LoopFileName, 0, "Icon" . IconNumber  )
}

Return
*/
;---------------------------------------------------
; THE FUNCTION
;---------------------------------------------------
AddFileIcon( file, imageList ) {
  ; Ensure the variable has enough capacity to hold the longest file path. This is done
  ; because ExtractAssociatedIconA() needs to be able to store a new filename in it.
  VarSetCapacity(Filename, 260)
  sfi_size = 352
  VarSetCapacity(sfi, sfi_size)

  FileName := file

  ; Build a unique extension ID to avoid characters that are illegal in variable names,
  ; such as dashes.  This unique ID method also performs better because finding an item
  ; in the array does not require search-loop.
  SplitPath, FileName,,, FileExt  ; Get the file's extension.
  If FileExt in EXE,ICO,ANI,CUR
  {
    ExtID := FileExt  ; Special ID as a placeholder.
    IconNumber = 0  ; Flag it as not found so that these types can each have a unique icon.
  }
  Else  ; Some other extension/file-type, so calculate its unique ID.
  {
    ExtID = 0  ; Initialize to handle extensions that are shorter than others.
    Loop 7     ; Limit the extension to 7 characters so that it fits in a 64-bit value.
    {
      StringMid, ExtChar, FileExt, A_Index, 1
      If Not ExtChar  ; No more characters.
        Break
     
      ; Derive a Unique ID by assigning a different bit position to each character:
      ExtID := ExtID | (Asc(ExtChar) << (8 * (A_Index - 1)))
    }

    ; Check if this file extension already has an icon in the ImageLists. If it does,
    ; several calls can be avoided and loading performance is greatly improved,
    ; especially for a folder containing hundreds of files:
    IconNumber := IconArray%ExtID%
  }
   
  If Not IconNumber  ; There is not yet any icon for this extension, so load it.
  {
    ; Get the high-quality small-icon associated with this file extension:
    If not DllCall("Shell32\SHGetFileInfoA", "str", FileName, "uint", 0, "str", sfi, "uint", sfi_size, "uint", 0x101)  ; 0x101 is SHGFI_ICON+SHGFI_SMALLICON
      IconNumber = 9999999  ; Set it out of bounds to display a blank icon.
       
    Else ; Icon successfully loaded.
    {
      ; Extract the hIcon member from the structure:
      hIcon = 0
      Loop 4
      hIcon += *(&sfi + A_Index-1) << 8*(A_Index-1)
     
      ; Add the HICON directly to the small-icon and large-icon lists.
      ; Below uses +1 to convert the returned index from zero-based to one-based:
      IconNumber := DllCall("ImageList_ReplaceIcon", "uint", imageList, "int", -1, "uint", hIcon) + 1
     
      ; Now that it's been copied into the ImageLists, the original should be destroyed:
      DllCall("DestroyIcon", "uint", hIcon)
      ; Cache the icon to save memory and improve loading performance:
      IconArray%ExtID% := IconNumber
    }
  }

  ; The icon is now in the list, return its number
  Return IconNumber
}

/*
GuiEscape:
  ExitApp
Return
*/