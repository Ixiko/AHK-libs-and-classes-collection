
;MsgBox, % "jpg = " GetFileAssoc("jpg") "`npdf = " GetFileAssoc("pdf")


GetFileAssoc(extension) {                       	; Returns the full path to the program associated with a given extension
    VarSetCapacity(numChars, 4)
    DllCall("Shlwapi.dll\AssocQueryStringW", "UInt", 0x0, "UInt"
        , 0x2, "WStr", "." . extension, "Ptr", 0, "Ptr", 0, "Ptr", &numChars)
    numChars:= NumGet(&numChars, 0, "UInt")
    VarSetCapacity(progPath, numChars*2)
    DllCall("Shlwapi.dll\AssocQueryStringW", "UInt", 0x0, "UInt"
        , 0x2, "WStr", "." . extension, "Ptr", 0, "Ptr", &progPath, "Ptr", &numChars)
    return StrGet(&progPath,NumGet(&numChars, 0, "UInt"),"UTF-16")
}