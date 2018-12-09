;~ FileSelectFile,FileName,,%A_ScriptDir%,Select a file to generate a MD5 from

;~ IfExist,%FileName%
;~ {
	;~ MD5 := MD5_File(FileName)

	;~ MsgBox % "MD5 copied to clipboard: " . Clipboard := MD5
;~ }

MD5_File(FileName)
{
	Ptr := A_PtrSize ? "Ptr" : "UInt"
	
	;Adapted from SKAN's MD5 functions - http://www.autohotkey.com/forum/topic64211.html
	H := DllCall("CreateFile",Ptr,&FileName,"UInt",0x80000000,"UInt",3,"UInt",0,"UInt",3,"UInt",0,"UInt",0)
	, DllCall("GetFileSizeEx","UInt",H,"Int64*",FileSize)
	, FileSize := FileSize = -1 ? 0 : FileSize
	, VarSetCapacity(Data,FileSize,0)
	, DllCall("ReadFile",Ptr,H,Ptr,&Data,"UInt",FileSize,"UInt",0,"UInt",0)
	, DllCall("CloseHandle",Ptr,H)
	, VarSetCapacity(MD5_CTX,104,0)
	, DllCall("advapi32\MD5Init",Ptr,&MD5_CTX)
	, DllCall("advapi32\MD5Update",Ptr,&MD5_CTX,Ptr,&Data,"UInt",FileSize)
	, DllCall("advapi32\MD5Final",Ptr,&MD5_CTX)

	FileMD5 := ""
	Loop % StrLen(Hex:="123456789ABCDEF0")
		N := NumGet(MD5_CTX,87+A_Index,"Char"), FileMD5 .= SubStr(Hex,N>>4,1) . SubStr(Hex,N&15,1)

	VarSetCapacity(Data,FileSize,0)
	, VarSetCapacity(Data,0)

	Return FileMD5
}