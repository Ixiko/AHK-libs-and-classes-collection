; ----------------------------------------------------------------------------------------------------------------------
; Name .........: Icon library
; Description ..: Functions library to manage icons (creating, loading, destroying).
; AHK Version ..: AHK_L 1.1.13.01 x32/64 Unicode
; Author .......: Cyruz - http://ciroprincipe.info
; License ......: WTFPL - http://www.wtfpl.net/txt/copying/
; Changelog ....: Jul. 30, 2015 - v0.1 - First version.
; ----------------------------------------------------------------------------------------------------------------------

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: Icon_Create
; Description ..: Create an icon from a binary buffer and return a handle to it.
; Parameters ...: adrBuf     - Pointer to the binary data buffer containing the icon.
; ..............: nIconWidth - Width of the desired icon (used to retrieve the icon inside a multi-icon file).
; ..............: szBuf      - If the buffer contains raw, single icon data, we can specify its size and avoid data 
; ..............:              structure parsing. This can be useful when loading icon resources (type 3) from PE files.
; Return .......: Handle to the icon on success, 0 on error.
; Info .........: CreateIconFromResourceEx function - https://goo.gl/Fij4ZA
; ----------------------------------------------------------------------------------------------------------------------
Icon_Create(adrBuf, nIconWidth, szBuf:=0)
{
    If ( !szBuf )
    {
        Loop % NumGet( adrBuf+0, 4, "UShort" )
        {
            nOfft := 6 + 16*(A_Index-1)
            If ( NumGet( adrBuf+0, nOfft, "UChar" ) == nIconWidth )
            {
                szBuf  := NumGet( adrBuf+0, nOfft+8,  "UInt" )
                adrBuf += NumGet( adrBuf+0, nOfft+12, "UInt" )
                Break
            }
        }
    }
    ; VERSION = 0x30000
    Return DllCall( "CreateIconFromResourceEx", Ptr,adrBuf, UInt,szBuf, Int,1, UInt,0x30000
                                              , Int,nIconWidth, Int,nIconWidth, UInt,0 )
}

; ----------------------------------------------------------------------------------------------------------------------
; Name .........: Icon_Load function
; Description ..: Load an icon from a PE file as a resource or from an icon file.
; Parameters ...: sBinFile - Can be:
; ..............:            *  0 to load a resource from the current process executable.
; ..............:            *  The module name or the full path to its executable/dll to load a resource from it.
; ..............:            * -1 or any negative integer to load the icon from an icon file.
; ..............: sResName - The name of the resource or its integer identifier. If sBinFile is a negative integer, it
; ..............:            should be the full path to an icon file.
; ..............: nWidth   - Desired icon's width.
; Return .......: Handle to the icon on success or -1 on error.
; Info .........: LoadIconWihScalDown function - https://goo.gl/4DCmxW
; ----------------------------------------------------------------------------------------------------------------------
Icon_Load(sBinFile, sResName, nWidth)
{
    If ( sBinFile < 0 )
        hLib := 0
    Else
    {
        If ( !hLib := DllCall( "GetModuleHandle", Ptr,(sBinFile?&sBinFile:0) ) )
        {
            ; If the DLL isn't already loaded, load it as a data file.
            If ( !hLib := DllCall( "LoadLibraryEx", Str,sBinFile, Ptr,0, UInt,0x2 ) )
                Return -1, ErrorLevel := "LoadLibraryEx error`nReturn value = " hLib "`nLast error = " A_LastError
            bLoaded := 1
        }
    }
    
    Try 
    {
        If ( DllCall( "LoadIconWithScaleDown", Ptr,hLib, Ptr,(sResName+0==sResName?sResName:&sResName)
                                                   , Int,nWidth, Int,nWidth, PtrP,hIcon ) != 0 ) ; S_OK = 0
            Return -1, ErrorLevel := "LoadIconWithScaleDown error`nReturn value = " e
    }
    Finally
    {
        ; If we loaded the DLL, free it now.
        If ( bLoaded )
            DllCall( "FreeLibrary", Ptr,hLib )
    }

    Return hIcon
}

; ----------------------------------------------------------------------------------------------------------------------
; Name .........: Icon_Destroy function
; Description ..: Destroy an icon handle.
; Parameters ...: hIcon - Handle to the icon to be destroyed.
; Info .........: DestroyIcon function - https://goo.gl/LaivE8
; ----------------------------------------------------------------------------------------------------------------------
Icon_Destroy(hIcon)
{
    Return DllCall( "DestroyIcon", Ptr,hIcon )
}