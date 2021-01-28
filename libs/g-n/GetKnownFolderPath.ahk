/*
    Recupera la ruta completa de una carpeta conocida.
    Parámetros:
        Guid: El GUID que identifica a la carpeta. Ver 'https://msdn.microsoft.com/en-us/library/windows/desktop/dd378457%28v=vs.85%29.aspx'.
            {905e63b6-c1bf-494e-b29c-65b732d3d21a} = A_ProgramFiles
            {A77F5D77-2E2B-44C3-A6A2-ABA601054A51} = A_Programs
            {0139D44E-6AFE-49F2-8690-3DAFCAE6FFB8} = A_ProgramsCommon
            {3EB685DB-65F9-4CF6-A03A-E3EF65729F3D} = A_AppData
            {62AB5D82-FDC1-4DC3-A9DD-070D1D495D97} = A_AppDataCommon 
            {B4BFCC3A-DB2C-424C-B029-7FE99A87C641} = A_Desktop 
            {C4AA340D-F20F-4863-AFEF-F87EF2E6BA25} = A_DesktopCommon
            {625B53C3-AB48-4EC1-BA1F-A1EF4146FC19} = A_StartMenu 
            {A4115719-D62E-491D-AA7C-E74B8BE3B067} = A_StartMenuCommon
            {B97D20BB-F46A-4C97-BA10-5E3608430854} = A_Startup
            {82A5EA35-D9CD-47C5-9629-E15D2F714E6E} = A_StartupCommon
            {FDD39AD0-238F-46AF-ADB4-6C85480369C7} = A_MyDocuments
            {ED4824AF-DCE4-45A8-81E2-FC7965083634} = A_DocumentsCommon
            {4BD8D571-6D19-48D3-BE97-422220080E43} = A_MyMusic
            {33E28130-4E1E-4676-835A-98395C3BC3BB} = A_MyPictures
            {18989B1D-99B5-455B-841C-AB7C74E4DDFC} = A_MyVideo
            {AE50C081-EBD2-438A-8655-8A092E34987A} = A_Recent
            {8983036C-27C0-404B-8F08-102D10DCFD74} = A_SendTo
    Return:
        Si tuvo éxito devuelve la ruta a la carpeta (la ruta no termina con '\'), caso contrario devuelve 0.
    Ejemplo:
        MsgBox(GetKnownFolderPath('{724EF170-A42D-4FEF-9F26-B60E846FBA4F}'))
*/
GetKnownFolderPath(GUID) ;WIN_V+
{
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms680589(v=vs.85).aspx
    Local CLSID
    VarSetCapacity(CLSID, 16, 0)
    If (DllCall('Ole32.dll\CLSIDFromString', 'Str' , GUID      ;lpsz
                                           , 'UPtr', &CLSID    ;pclsid
                                           , 'UInt'))          ;ReturnType
        Return (FALSE)
    
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb762188(v=vs.85).aspx
    Local pBuffer
    If (DllCall('Shell32.dll\SHGetKnownFolderPath', 'UPtr' , &CLSID      ;rfid
                                                  , 'UInt' , 0           ;dwFlags
                                                  , 'Ptr'  , 0           ;hToken
                                                  , 'UPtrP', pBuffer     ;ppszPath
                                                  , 'UInt'))             ;ReturnType (HRESULT)
        Return (FALSE)
    Local Path := StrGet(pBuffer, 'UTF-16')

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms680722(v=vs.85).aspx
    DllCall('Ole32.dll\CoTaskMemFree', 'UPtr', pBuffer)

    Return (Path)
}