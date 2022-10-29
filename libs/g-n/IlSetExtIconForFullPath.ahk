/*
    IlSetExtIconForFullPath

    Purpose
        function name in full: List view set icon extension for full path
        
        Sets the correct icon in the image list and returns that number for usage in LV_Add()

    Notes
        This is modified from copy pasted code from the docs @ https://www.autohotkey.com/docs/commands/ListView.htm
        The code currently only does small icons. Could modify it to do large icons aswell. See 'ImageListID2' in the code below

    Params
        inputImageListHandle = handle to an image list created with IL_Create()
        inputFullFilePath = full file path + extension to retrieve set icon for

    Usage example
        ImageListID1 := IL_Create(10)
        fileFullPath := "C:\Windows\regedit.exe"

        IconNumber := IlSetExtIconForFullPath(ImageListID1, fileFullPath)
        LV_Add("Icon" Iconnumber, "test123")

    Returns
        The icon number in the image list for usage in LV_Add() that was set to the file extension's icon
*/
IlSetExtIconForFullPath(inputImageListHandle, inputFullFilePath) {
    static

    ; Calculate buffer size required for SHFILEINFO structure.
    If !sfi_size {
        sfi_size := A_PtrSize + 8 + (A_IsUnicode ? 680 : 340)
        VarSetCapacity(sfi, sfi_size)
    }

    ; retrieve the fucking file extension icon number
    ; Build a unique extension ID to avoid characters that are illegal in variable names,
    ; such as dashes. This unique ID method also performs better because finding an item
    ; in the array does not require search-loop.
    SplitPath, inputFullFilePath,,, FileExt  ; Get the file's extension.
    if FileExt in EXE,ICO,ANI,CUR
    {
        ExtID := FileExt  ; Special ID as a placeholder.
        IconNumber := 0  ; Flag it as not found so that these types can each have a unique icon.
    }
    else  ; Some other extension/file-type, so calculate its unique ID.
    {
        ExtID := 0  ; Initialize to handle extensions that are shorter than others.
        Loop 7     ; Limit the extension to 7 characters so that it fits in a 64-bit value.
        {
            ExtChar := SubStr(FileExt, A_Index, 1)
            if not ExtChar  ; No more characters.
                break
            ; Derive a Unique ID by assigning a different bit position to each character:
            ExtID := ExtID | (Asc(ExtChar) << (8 * (A_Index - 1)))
        }
        ; Check if this file extension already has an icon in the ImageLists. If it does,
        ; several calls can be avoided and loading performance is greatly improved,
        ; especially for a folder containing hundreds of files:
        IconNumber := IconArray%ExtID%
    }
    if not IconNumber  ; There is not yet any icon for this extension, so load it.
    {
        ; Get the high-quality small-icon associated with this file extension:
        if not DllCall("Shell32\SHGetFileInfo" . (A_IsUnicode ? "W":"A"), "Str", inputFullFilePath
            , "UInt", 0, "Ptr", &sfi, "UInt", sfi_size, "UInt", 0x101)  ; 0x101 is SHGFI_ICON+SHGFI_SMALLICON
            IconNumber := 9999999  ; Set it out of bounds to display a blank icon.
        else ; Icon successfully loaded.
        {
            ; Extract the hIcon member from the structure:
            hIcon := NumGet(sfi, 0)
            ; Add the HICON directly to the small-icon and large-icon lists.
            ; Below uses +1 to convert the returned index from zero-based to one-based:
            IconNumber := DllCall("ImageList_ReplaceIcon", "Ptr", inputImageListHandle, "Int", -1, "Ptr", hIcon) + 1
            DllCall("ImageList_ReplaceIcon", "Ptr", ImageListID2, "Int", -1, "Ptr", hIcon)
            ; Now that it's been copied into the ImageLists, the original should be destroyed:
            DllCall("DestroyIcon", "Ptr", hIcon)
            ; Cache the icon to save memory and improve loading performance:
            IconArray%ExtID% := IconNumber
        }
    }

    return IconNumber
}