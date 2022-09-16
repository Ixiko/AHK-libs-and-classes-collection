CreateAppShortcut(linkFile, target, args, description, aumid, uninst) {
    lnk := ComObject('{00021401-0000-0000-C000-000000000046}' ; CLSID_ShellLink
                    ,'{000214F9-0000-0000-C000-000000000046}') ; IID_IShellLink
    
    ComCall(20, lnk, 'wstr', target)
    ComCall(11, lnk, 'wstr', args)
    ComCall(7, lnk, 'wstr', description)
    
    ; Set the System.AppUserModel.ID property via IPropertyStore
    props := ComObjQuery(lnk, '{886D8EEB-8CF2-4446-8D02-CDBA1DBDCF99}')
    static PKEY_AppUserModel_ID               := PKEY('{9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3}',  5)
    static PKEY_AppUserModel_UninstallCommand := PKEY('{9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3}', 37)
    setProp PKEY_AppUserModel_ID, aumid
    setProp PKEY_AppUserModel_UninstallCommand, uninst
    
    ; Save via IPersistFile
    pf := ComObjQuery(lnk, '{0000010B-0000-0000-C000-000000000046}')
    ComCall(6, pf, 'wstr', linkFile, 'int', true)
    
    setProp(key, value) {
        propvar := Buffer(24, 0), propref := ComValue(0x400C, propvar.ptr)
        propref[] := String(value)
        ComCall(6, props, 'ptr', key, 'ptr', propvar)
        propref[] := 0
    }
    
    PKEY(sguid, propID) {
        pk := Buffer(20)
        DllCall('ole32\IIDFromString', 'wstr', sguid, 'ptr', pk, 'hresult')
        NumPut('int', propID, pk, 16)
        return pk
    }
}
