; ----------------------------------------------------------------------------------------------------------------------
; Function .....: NetShareEnum
; Description ..: Implements the NetShareEnum Win32 API. Retrieves information about each shared resource on a server.
; Parameters ...: sName - DNS name of the computer where to run the function. If empty, will be localhost.
; Return .......: -1 - NetShareEnum error.
; ..............: -2 - NetApiBufferFree error.
; ..............: In case of success an array of objects describing the shares will be returned. The array has the
; ..............: following structure:
; ..............: Array[n] -> Object.netname
; ..............:          -> Object.type
; ..............:          -> Object.remark
; ..............:          -> Object.permissions
; ..............:          -> Object.max_uses
; ..............:          -> Object.current_uses
; ..............:          -> Object.path
; ..............:          -> Object.passwd
; ..............:          -> Object.reserved
; ..............:          -> Object.security_descriptor
; Remarks ......: The information returned are described by the SHARE_INFO_502 structure:
; ..............: http://msdn.microsoft.com/en-us/library/windows/desktop/bb525410%28v=vs.85%29.aspx
; AHK Version ..: AHK_L 1.1.13.01 x32/64 Unicode
; Author .......: Cyruz (http://ciroprincipe.info)
; License ......: WTFPL - http://www.wtfpl.net/txt/copying/
; Changelog ....: Apr. 13, 2014 - v0.1 - First version.
; ----------------------------------------------------------------------------------------------------------------------
NetShareEnum(sName:="") {
	Static szS_I_502 := (A_PtrSize == 4) ? 40 : 72

	; Level = 502
	If ( DllCall( "Netapi32.dll\NetShareEnum", Ptr,(sName)?&sName:0, UInt,502, PtrP,S_I_502, UInt,-1, UIntP,nER
											 , UIntP,nTE, UIntP,nResume ) )
		Return -1
	objShare := Object()
	Loop %nER%
	{
		addr := S_I_502 + szS_I_502 * (A_Index-1)
		objShare.Insert({ "netname"             : StrGet(NumGet(addr+0, 0, "Ptr"), "UTF-16")
			            , "type"                : NumGet(addr+0, A_PtrSize, "UInt")
						, "remark"              : StrGet(NumGet(addr+0, A_PtrSize * 2, "Ptr"), "UTF-16")
						, "permissions"         : NumGet(addr+0, A_PtrSize * 3, "UInt")
		                , "max_uses"            : NumGet(addr+0, (A_PtrSize == 4) ? 16 : 28, "UInt")
						, "current_uses"        : NumGet(addr+0, (A_PtrSize == 4) ? 20 : 32, "UInt")
						, "path"                : StrGet(NumGet(addr+0, (A_PtrSize == 4) ? 24 : 40, "Ptr"), "UTF-16")
					    , "passwd"              : StrGet(NumGet(addr+0, (A_PtrSize == 4) ? 28 : 48, "Ptr"), "UTF-16")
						, "reserved"            : StrGet(NumGet(addr+0, (A_PtrSize == 4) ? 32 : 56, "Ptr"), "UTF-16")
						, "security_descriptor" : NumGet(addr+0, (A_PtrSize == 4) ? 36 : 64, "Ptr") })
	}
	If ( DllCall( "Netapi32.dll\NetApiBufferFree", Ptr,S_I_502 ) )
		Return -2
	Return objShare
}