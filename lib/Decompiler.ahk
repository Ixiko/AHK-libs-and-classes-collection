#NoEnv

SetBatchLines, -1

Gui, Font, s16, Arial
Gui, Add, Edit, x10 y10 w450 h30 vPath gUpdate
Gui, Add, Button, x460 y10 w30 h30 gSelectFile, ...
Gui, Font, s12, Courier New
Gui, Add, Edit, x10 y50 w480 h340 vCode ReadOnly -Wrap, <Output>
Gui, Show, w496 h398, AutoHotkey Decompiler

If 0 = 1
    GuiControl,, Path, %1%
Return

GuiClose:
ExitApp

Update:
SetTimer, Decompile, -800
Return

GuiDropFiles:
Loop, Parse, A_GuiEvent, `n
{
    GuiControl,, Path, %A_LoopField%
    Break
}
Return

SelectFile:
FileSelectFile, Path, 3,, Select an AutoHotkey executable to decompile, *.exe
If !ErrorLevel
    GuiControl,, Path, %Path%
Return

Decompile:
GuiControlGet, Path,, Path
Attributes := FileExist(Path)
If !Attributes
{
    GuiControl,, Code, <Error>`nInvalid path: "%Path%".
    Return
}
If InStr(Attributes,"D")
{
    GuiControl,, Code, <Error>`nInvalid file: %Path%.
    Return
}
GuiControl,, Code, <Decompiling>
try Code := Decompile(Path)
catch e
{
    GuiControl,, Code, % "<Error>`n" . e.Message . "`nFunction: " . e.What . " (Line " . e.Line . ")"
    Return
}
GuiControl,, Code, %Code%
Return

Decompile(Path)
{
    ExtractDir := A_ScriptDir . "\ExtractFiles"
    PatchedPath := ExtractDir . "\Patched.exe"
    Payload := ExtractDir . "\winmm.dll"

    ;set up temporary directory
    try FileCreateDir, %ExtractDir%
    catch e
        throw Exception("Could not create temporary extraction directory: """ . ExtractDir . """.")

    ;make a copy of the executable to work with
    try FileCopy, %Path%, %PatchedPath%, 1
    catch e
    {
        try FileRemoveDir, %ExtractDir%, 1 ;clean up temporary directory
        throw Exception("Invalid executable path: """ . Path . """.")
    }

    ;read the executable contents
    Executable := FileOpen(PatchedPath,"rw")
    If !Executable
    {
        try FileRemoveDir, %ExtractDir%, 1 ;clean up temporary directory
        throw Exception("Could not access executable: """ . PatchedPath . """.")
    }
    Length := Executable.RawRead(Buffer,Executable.Length)
    If Length < 64 ;minimum executable size
    {
        try FileRemoveDir, %ExtractDir%, 1 ;clean up temporary directory
        throw Exception("Could not read executable: """ . PatchedPath . """.")
    }

    try SectionLength := GetSectionOffset(Buffer,".rsrc",SectionDataOffset) ;search for the resources section
    catch e
    {
        try FileRemoveDir, %ExtractDir%, 1 ;clean up temporary directory
        throw e
    }

    PatchedNames := [">UHK WITH ICON<",">UUTOHOTKEY SCRIPT<"]
    Success := False
    For Index, Name In [">AHK WITH ICON<",">AUTOHOTKEY SCRIPT<"]
    {
        ;obtain resource name in UTF-16
        Size := StrLen(Name)
        VarSetCapacity(uName,Size << 1)
        StrPut(Name,&uName,Size,"UTF-16")

        ;patch resource name if found
        Offset := SearchBuffer(&Buffer + SectionDataOffset,SectionLength,uName,Size)
        If Offset = -1
            Continue
        Offset += SectionDataOffset ;obtain absolute offset

        Success := True

        ;obtain new resource name in UTF-16
        NewName := PatchedNames[Index]
        Size := StrLen(NewName)
        VarSetCapacity(uName,Size << 1)
        StrPut(NewName,&uName,Size,"UTF-16")

        ;patch the resource name to prevent access by executable
        If !Executable.Seek(Offset)
        {
            try FileRemoveDir, %ExtractDir%, 1 ;clean up temporary directory
            throw Exception("Could not seek to resource position: " . Offset . ".")
        }
        If !Executable.RawWrite(uName,Size << 1)
        {
            try FileRemoveDir, %ExtractDir%, 1 ;clean up temporary directory
            throw Exception("Could not patch resource: """ . NewName . """.")
        }
    }
    If !Success ;resources not found
    {
        try FileRemoveDir, %ExtractDir%, 1 ;clean up temporary directory
        throw Exception("Invalid executable script resources: """ . PatchedPath . """.")
    }

    Executable.Close()

    ;determine the correct payload to use
    BinaryType := 0
    If !DllCall("GetBinaryType" . (A_IsUnicode ? "W" : "A"),"Str",PatchedPath,"UInt*",BinaryType)
        throw Exception("Could not determine executable type: """ . PatchedPath . """.")
    If BinaryType = 0 ;SCS_32BIT_BINARY
        PayloadPath := A_ScriptDir . "\payload.dll"
    Else If BinaryType = 6 ;SCS_64BIT_BINARY
        PayloadPath := A_ScriptDir . "\payload64.dll"
    Else
    {
        try FileRemoveDir, %ExtractDir%, 1 ;clean up temporary directory
        throw Exception("Invalid executable type: """ . BinaryType . """.")
    }

    ;deploy payload
    try FileCopy, %PayloadPath%, %Payload%, 1
    catch e
    {
        try FileRemoveDir, %ExtractDir%, 1 ;clean up temporary directory
        throw Exception("Could not deploy payload: """ . PayloadPath . """.")
    }

    ;run the executable
    try RunWait, %PatchedPath%, %ExtractDir%
    catch e
    {
        try FileRemoveDir, %ExtractDir%, 1 ;clean up temporary directory
        throw Exception("Could not run executable: """ . PatchedPath . """.")
    }

    ;obtain script extracted by payload
    SplitPath, PatchedPath,, OutDir,, OutNameNoExt
    ScriptPath := OutDir . "\" . OutNameNoExt . "-uncompiled.ahk"
    try FileRead, Code, %ScriptPath%
    catch e
    {
        try FileRemoveDir, %ExtractDir%, 1 ;clean up temporary directory
        throw Exception("Could read script code: """ . ScriptPath . """.")
    }

    try FileRemoveDir, %ExtractDir%, 1 ;clean up temporary directory

    Return, Code
}

GetSectionOffset(ByRef Buffer,Name,ByRef DataOffset)
{
    If NumGet(Buffer,0,"UShort") != 0x5A4D ;MS-DOS executable marker
        throw Exception("Invalid MS-DOS signature.")
    Offset := NumGet(Buffer,60,"UInt") ;read the "e_lfanew" field of the MS-DOS header for the file address of the PE header
    If NumGet(Buffer,Offset,"UInt") != 0x4550 ;IMAGE_NT_SIGNATURE
        throw Exception("Invalid NT signature.")
    Offset += 4 ;move past the file signature
    SectionsCount := NumGet(Buffer,Offset + 2,"UShort") ;read the "NumberOfSections" field of the IMAGE_FILE_HEADER structure for the number of sections present
    OptionalHeaderSize := NumGet(Buffer,Offset + 16,"UShort") ;read the "SizeOfOptionalHeader" field of the IMAGE_FILE_HEADER structure for the size of the optional header
    Offset += 20 ;move past the IMAGE_FILE_HEADER structure
    Marker := NumGet(Buffer,Offset,"UShort") ;IMAGE_OPTIONAL_HEADER marker
    If (Marker != 0x10B && Marker != 0x20B) ;IMAGE_NT_OPTIONAL_HDR32_MAGIC, IMAGE_NT_OPTIONAL_HDR64_MAGIC
        throw Exception("Invalid PE signature.")
    Offset += OptionalHeaderSize ;move past the IMAGE_OPTIONAL_HEADER structure

    Loop, %SectionsCount% ;loop through each section header
    {
        If StrGet(&Buffer + Offset,8,"UTF-8") = Name ;found header
        {
            DataLength := NumGet(Buffer,Offset + 16,"UInt")
            DataOffset := NumGet(Buffer,Offset + 20,"UInt")
            Return, DataLength
        }
        Offset += 40 ;move past the IMAGE_SECTION_HEADER structure
    }
    throw Exception("Could not find PE file section: """ . Name . """.")
}

SearchBuffer(pBuffer,BufferSize,ByRef Search,SearchSize) ;Boyer-Moore-Horspool algorithm
{
    ;preprocess search input
    ShiftTable := []
    Loop, 255
        ShiftTable[A_Index] := SearchSize
    Loop, % SearchSize - 1
        ShiftTable[NumGet(Search,A_Index - 1,"UChar")] := SearchSize - A_Index

    ;search buffer
    Offset := 0
    While, BufferSize >= SearchSize
    {
        ;scan from the end of the search input
        Position := SearchSize - 1
        While, NumGet(pBuffer + Offset,Position,"UChar") = NumGet(Search,Position,"UChar")
        {
            If Position = 0
                Return, Offset
            Position --
        }

        ;shift buffer if not found
        Value := ShiftTable[NumGet(pBuffer + Offset,SearchSize - 1,"UChar")]
        Offset += Value
        BufferSize -= Value
    }

    ;search input not found
    Return, -1
}