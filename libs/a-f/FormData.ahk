; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=7647
; Author:	arcticir
; Date:   	2016-08-25
; for:     	AHK_L

/*		V2 HTTPRequest()
*/

FormData(ByRef body, Param){
	Boundary := SubStr(StrReplace(Sort("0|1|2|3|4|5|6|7|8|9|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z","D| Random"), "|"), 1, 12)
	crlf := "`r`n",line := "--" . Boundary
	VarSetCapacity(body,0),offset := 0
	For k, v in Param
		If IsObject(v)
		{
			For i, FileName in v
			{
				file:=FileOpen(FileName, "r"),n := file.ReadUInt()
				,buffer := line crlf "Content-Disposition: form-data; name=`"" . k . "`"; filename=`"" . FileName . "`"" . crlf
					. "Content-Type: " . ((n        = 0x474E5089) ? "image/png"
					: (n        = 0x38464947) ? "image/gif"
					: (n&0xFFFF = 0x4D42    ) ? "image/bmp"
					: (n&0xFFFF = 0xD8FF    ) ? "image/jpeg"
					: (n&0xFFFF = 0x4949    ) ? "image/tiff"
					: (n&0xFFFF = 0x4D4D    ) ? "image/tiff"
					: "application/octet-stream") . crlf . crlf
				,FormData_Memory(body,buffer,offset,StrLen(buffer),1)
				,bufferSize := VarSetCapacity(buffer,file.Length)
				,File.Tell(0),file.RawRead(&buffer, bufferSize)
				,FormData_Memory(body,buffer,offset,bufferSize,0)
				,FormData_Memory(body,crlf,offset,2,1)
			}
		}
		Else
		{
			buffer := line . crlf . "Content-Disposition: form-data; name=`"" . k "`"" . crlf . crlf . v . crlf
			FormData_Memory(body,buffer,offset,StrLen(buffer),1)
		}
	FormData_Memory(body,buffer:= line "--" crlf,offset,StrLen(buffer),1)
	return {"Content-Length":offset,"Content-Type":"multipart/form-data; boundary=" . Boundary}
}

FormData_Memory(ByRef f,ByRef k,ByRef p,ByRef s,t){
		VarSetCapacity(w,r:=p,0),DllCall("RtlMoveMemory", "Ptr", &w, "Ptr", &f, "UInt", r),VarSetCapacity(f,p+= s,0),DllCall("RtlMoveMemory", "Ptr", &f, "Ptr", &w, "UInt", r)
		,t?StrPut(k, (&f)+r, s, "CP0"):DllCall("RtlMoveMemory", "Ptr", &f+r, "Ptr", &k, "UInt", s)
}