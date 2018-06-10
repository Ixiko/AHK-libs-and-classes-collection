; ----------------------------------------------------------------------------------------------------------------------
; Name .........: UpdRes library
; Description ..: This library allows to load a resource from a PE file and update it. It's something written in a 
; ..............: couple of minutes, so don't expect it to work in all situations.
; AHK Version ..: AHK_L 1.1.13.01 x32/64 Unicode
; Author .......: Cyruz  (http://ciroprincipe.info)
; License ......: WTFPL - http://www.wtfpl.net/txt/copying/
; Changelog ....: May  24, 2014 - v0.1 - First version.
; ..............: Jan. 11, 2015 - v0.2 - Added the UpdateArrayOfResources and UpdateDirOfResources functions.
; ..............: Jul. 28, 2015 - v0.3 - Added EnumerateResources function and better error management.
; ----------------------------------------------------------------------------------------------------------------------

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: UpdRes_LockResource
; Description ..: Load the specified resource and retrieve a pointer to its binary data.
; Parameters ...: sBinFile - PE file whose resource is to be retrieved. If = 0 the resource will be retrieved in the 
; ..............:            current process.
; ..............: sResName - The name of the resource or its integer identifier.
; ..............: nResType - The resource type.
; ..............: szData   - Byref parameter containing the size of the resource data.
; Return .......: A pointer to the first byte of the resource, 0 on error.
; Info .........: Resource Types - http://msdn.microsoft.com/en-us/library/windows/desktop/ms648009%28v=vs.85%29.aspx
; ----------------------------------------------------------------------------------------------------------------------
UpdRes_LockResource(sBinFile, sResName, nResType, ByRef szData)
{
    If ( !hLib := DllCall( "GetModuleHandle", Ptr,(sBinFile?&sBinFile:0) ) )
    {
        ; If the DLL isn't already loaded, load it as a data file.
        If ( !hLib := DllCall( "LoadLibraryEx", Str,sBinFile, Ptr,0, UInt,0x2 ) )
            Return 0, ErrorLevel := "LoadLibraryEx error`nReturn value = " hLib "`nLast error = " A_LastError
        bLoaded := 1
    }
    
    Try
    {
        If ( !hRes := DllCall( "FindResource", Ptr,hLib, Ptr,(sResName+0==sResName?sResname:&sResName), Ptr,nResType ) )
            Return 0, ErrorLevel := "FindResource error`nReturn value = " hRes "`nLast error = " A_LastError
        
        If ( !szData := DllCall( "SizeofResource", Ptr,hLib, Ptr,hRes ) )
            Return 0, ErrorLevel := "SizeofResource error`nReturn value = " szData "`nLast error = " A_LastError
        
        If ( !hData := DllCall( "LoadResource", Ptr,hLib, Ptr,hRes ) )
            Return 0, ErrorLevel := "LoadResource error`nReturn value = " hData "`nLast error = " A_LastError
        
        If ( !pData := DllCall( "LockResource", Ptr,hData ) )
            Return 0, ErrorLevel := "LockResource error`nReturn value = " pData "`nLast error = " A_LastError
    }
    Finally
    {
        ; If we loaded the DLL, free it now.
        If ( bLoaded )
            DllCall( "FreeLibrary", Ptr,hLib )
    }
    
    Return pData
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: UpdRes_UpdateResource
; Description ..: Update the specified resource in the specified PE file.
; Parameters ...: sBinFile - PE file whose resource is to be updated.
; ..............: bDelOld  - Delete all old resources if 1 or leave them intact if 0.
; ..............: sResName - The name of the resource.
; ..............: nResType - The resource type.
; ..............: nLangId  - Language identifier of the resource to be updated.
; ..............: pData    - Pointer to resource data. Must not point to ANSI data.
; ..............: szData   - Size of the resource data.
; Return .......: 1 on success, 0 on error.
; Info .........: Lang. Identifiers - http://msdn.microsoft.com/en-us/library/windows/desktop/dd318691%28v=vs.85%29.aspx
; ----------------------------------------------------------------------------------------------------------------------
UpdRes_UpdateResource(sBinFile, bDelOld, sResName, nResType, nLangId, pData, szData)
{
    If ( !hMod := DllCall( "BeginUpdateResource", Str,sBinFile, Int,bDelOld ) )
        Return 0, ErrorLevel := "BeginUpdateResource error`nReturn value = " hMod "`nLast error = " A_LastError
        
    If ( !e := DllCall( "UpdateResource", Ptr,hMod, Ptr,nResType, Str,sResName, UInt,nLangId, Ptr,pData, UInt,szData ) )
        Return 0, ErrorLevel := "UpdateResource error`nReturn value = " e "`nLast error = " A_LastError
    
    If ( !e := DllCall( "EndUpdateResource", Ptr,hMod, Int,0 ) )
        Return 0, ErrorLevel := "EndUpdateResource error`nReturn value = " e "`nLast error = " A_LastError
    
    Return 1
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: UpdRes_UpdateArrayOfResources
; Description ..: Update the specified array of resources in the specified PE file.
; Parameters ...: sBinFile - PE file whose resources are to be updated.
; ..............: bDelOld  - Delete all old resources if 1 or leave them intact if 0.
; ..............: objRes   - Array of objects describing the resources to update. Must be structured as follows:
; ..............:            objRes[n].ResName  - The name of the resource.
; ..............:            objRes[n].ResType  - The resource type.
; ..............:            objRes[n].LangId   - Language identifier of the resource to be updated.
; ..............:            objRes[n].DataAddr - Pointer to resource data. Must not point to ANSI data.
; ..............:            objRes[n].DataSize - Size of the resource data.
; Return .......: Number of resources updated on success, 0 on error.
; ----------------------------------------------------------------------------------------------------------------------
UpdRes_UpdateArrayOfResources(sBinFile, bDelOld, ByRef objRes)
{
    If ( !IsObject(objRes) )
        Return 0, ErrorLevel := "Array of resources object is not an object."
        
    If ( !hMod := DllCall( "BeginUpdateResource", Str,sBinFile, Int,bDelOld ) )
        Return 0, ErrorLevel := "BeginUpdateResource error`nReturn value = " hMod "`nLast error = " A_LastError
    
    Loop % objRes.MaxIndex()
    {
        If ( !DllCall( "UpdateResource", Ptr,hMod, Ptr,objRes[A_Index].ResType, Str,objRes[A_Index].ResName
                                       , UInt,objRes[A_Index].LangId, Ptr,objRes[A_Index].DataAddr
                                       , UInt,objRes[A_Index].DataSize ) )
            Continue
        nUpdated := A_Index
    }
    
    If ( !e := DllCall( "EndUpdateResource", Ptr,hMod, Int,0 ) )
        Return 0, ErrorLevel := "EndUpdateResource error`nReturn value = " e "`nLast error = " A_LastError
    
    Return nUpdated
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: UpdRes_UpdateDirOfResources
; Description ..: Add the resources in the desired directory in the specified PE file. Only the file in the root
; ..............: directory will be added, any subdirectory will be ignored. All the resources will be added with the 
; ..............: same resource type and language identifier.
; Parameters ...: sResDir  - Directory containing the resources to add to the PE file.
; ..............: sBinFile - PE file whose resources are to be updated.
; ..............: bDelOld  - Delete all old resources if 1 or leave them intact if 0.
; ..............: nResType - The resource type.
; ..............: nLangId  - Language identifier of the resources to be updated.
; Return .......: Number of resources updated on success, 0 on error.
; ----------------------------------------------------------------------------------------------------------------------
UpdRes_UpdateDirOfResources(sResDir, sBinFile, bDelOld, nResType, nLangId)
{    
    If ( !FileExist(sBinFile) || !InStr(FileExist(sResDir), "D") )
        Return 0, ErrorLevel := "Binary file or resources directory not existing."
    
    Try
    {
        objRes := Object()
        Loop, %sResDir%\*.*
        {
            objFile := FileOpen(A_LoopFileLongPath, "r")
            ; PAGE_READONLY = 2
            If ( !hMap := DllCall( "CreateFileMapping", Ptr,objFile.__Handle, Ptr,0, UInt,2, UInt,0, UInt,0, Ptr,0 ) )
            {
                objFile.Close()
                Continue
            }
            ; FILE_MAP_READ = 4
            If ( !pMap := DllCall( "MapViewOfFile", Ptr,hMap, UInt,4, UInt,0, UInt,0, UInt,0 ) )
            {
                DllCall( "CloseHandle", Ptr,hMap ), objFile.Close()
                Continue
            }
            objRes.Insert({ "ResName"  : A_LoopFileName
                          , "ResType"  : nResType
                          , "LangId"   : nLangId
                          , "DataAddr" : pMap
                          , "DataSize" : objFile.Length
                          , "__oFile"  : objFile
                          , "__hMap"   : hMap
                          , "__pMap"   : pMap })
        }
        nUpdated := UpdRes_UpdateArrayOfResources(sBinFile, bDelOld, objRes)
    }
    Finally
    {
        Loop % objRes.MaxIndex()
            DllCall( "UnmapViewOfFile", Ptr,objRes[A_Index].__pMap )
          , DllCall( "CloseHandle", Ptr,objRes[A_Index].__hMap )
          , objRes[A_Index].__oFile.Close()
        ObjRelease(objRes)
    }
    
    Return nUpdated
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: UpdRes_EnumerateResources
; Description ..: Enumerate all the resources of a specific type inside a binary file.
; Parameters ...: sBinFile - PE file whose resources are to be enumerated. If = 0 the current process resources will be 
; ..............:            enumerated.
; ..............: nResType - The resource type.
; Return .......: List of enumerated resources, 0 on error.
; Info .........: EnumResourceNames: https://msdn.microsoft.com/en-us/library/windows/desktop/ms648037(v=vs.85).aspx
; ----------------------------------------------------------------------------------------------------------------------
UpdRes_EnumerateResources(sBinFile, nResType)
{
    If ( !hLib := DllCall( "GetModuleHandle", Ptr,(sBinFile?&sBinFile:0) ) )
    {
        ; If the DLL isn't already loaded, load it as a data file.
        If ( !hLib := DllCall( "LoadLibraryEx", Str,sBinFile, Ptr,0, UInt,0x2 ) )
            Return 0, ErrorLevel := "LoadLibraryEx error`nReturn value = " hLib "`nLast error = " A_LastError
        bLoaded := 1
    }
    
    Try
    {
        ; Enumerate the resources of type nResType.
        cbEnum := RegisterCallback( "__UpdRes_EnumeratorCallback" ), adrEnumList := 0
        DllCall( "EnumResourceNames", Ptr,hLib, Ptr,nResType, Ptr,cbEnum, Ptr,&adrEnumList )
        DllCall( "GlobalFree", Ptr,cbEnum )
    }
    Finally
    {
        ; If we loaded the DLL, free it now.
        If ( bLoaded )
            DllCall( "FreeLibrary", Ptr,hLib )
    }
    
    ; Recover the address of the enumeration string and get it.
    Return StrGet(NumGet(&adrEnumList))
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: __UpdRes_EnumeratorCallback
; Description ..: Enumerator callback for the UpdRes_EnumerateResources function. Do not call directly.
; Info .........: EnumResNameProc: https://msdn.microsoft.com/en-us/library/windows/desktop/ms648034(v=vs.85).aspx
; ----------------------------------------------------------------------------------------------------------------------
__UpdRes_EnumeratorCallback(hModule, lpszType, lpszName, lParam)
{
    Static sEnumList := ""
    
    ; Concatenate the string and put its address in the lParam parameter.
    sEnumList .= "[Type] " lpszType " [Name] " lpszName "`n"
    NumPut( &sEnumList, lParam+0 )
    
    Return true
}
