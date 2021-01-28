/*
    Recupera la información de versión de un archivo.
    Parámetros:
        FileName: La ruta a el archivo.
    Return:
        Si tuvo éxito devuelve un objeto con las siguientes claves:
            Comments, InternalName, ProductName, CompanyName, LegalCopyright, ProductVersion, FileDescription, LegalTrademarks, PrivateBuild, FileVersion, OriginalFilename, SpecialBuild.
        Caso contrario devuelve 0.
    Ejemplo:
        For Each, Value In GetFileVersionInfo(A_ComSpec)
            Info .= Each . '`t|`t' . Value . '`n'
        MsgBox(Info)
*/
GetFileVersionInfo(FileName) ;WIN_V+
{
    Local Size, VS_VERSIONINFO, LangCP, OutputVar

    ;https://msdn.microsoft.com/en-us/library/windows/desktop/aa969435(v=vs.85).aspx
    If (!(Size := DllCall('Version.dll\GetFileVersionInfoSizeExW', 'UInt', 0x01, 'Str', '\\?\' . FileName, 'Ptr', 0, 'UInt')))
        Return (FALSE) 
    
    ;https://msdn.microsoft.com/en-us/library/windows/desktop/aa969434(v=vs.85).aspx
    VarSetCapacity(VS_VERSIONINFO, Size, 0)
    If (!DllCall('Version.dll\GetFileVersionInfoExW', 'UInt', 0x01, 'Str', '\\?\' . FileName, 'UInt', 0, 'UInt', Size, 'UPtr', &VS_VERSIONINFO, 'Int'))
        Return (FALSE)
    
    ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms647464(v=vs.85).aspx
    If (!DllCall('Version.dll\VerQueryValueW', 'UPtr', &VS_VERSIONINFO, 'Str', '\VarFileInfo\Translation', 'UPtrP', VERINFO, 'UIntP', 0))
        Return (FALSE)
    
    LangCP              := '\StringFileInfo\' . Format('{:04X}{:04X}', NumGet(VERINFO, 'UShort'), NumGet(VERINFO+2, 'UShort')) . '\'
    OutputVar           := {}
    
    Loop Parse, 'Comments|InternalName|ProductName|CompanyName|LegalCopyright|ProductVersion|FileDescription|LegalTrademarks|PrivateBuild|FileVersion|OriginalFilename|SpecialBuild', '|'
        If (DllCall('Version.dll\VerQueryValueW', 'UPtr', &VS_VERSIONINFO, 'Str', LangCP . A_LoopField, 'PtrP', VERINFO, 'UIntP', Size))
            OutputVar[A_LoopField] := StrGet(VERINFO, Size, 'UTF-16')
    
    Return (OutputVar)
}
