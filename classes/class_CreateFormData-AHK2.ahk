; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=7647
; Author:	egocarib
; Date:   	2017-10-15
; for:     	AHK2


/*
	CreateFormData - Creates "multipart/form-data" for http post

	Usage: CreateFormData(ByRef retData, ByRef retHeader, objParam)

		retData   - (out) Data used for HTTP POST.
		retHeader - (out) Content-Type header used for HTTP POST.
		objParam  - (in)  An object defines the form parameters.

		            To specify files, use array as the value. Example:
		                objParam := { "key1": "value1"
		                            , "upload[]": ["1.png", "2.png"] }

	Requirement: BinArr.ahk -- https://gist.github.com/tmplinshi/a97d9a99b9aa5a65fd20
	Version    : 1.20 / 2016-6-17 - Added CreateFormData_WinInet(), which can be used for VxE's HTTPRequest().
	             1.10 / 2015-6-23 - Fixed a bug
	             1.00 / 2015-5-14
*/

; Used for WinHttp.WinHttpRequest.5.1, Msxml2.XMLHTTP ...
CreateFormData(ByRef retData, ByRef retHeader, objParam) {
	New CreateFormData(retData, retHeader, objParam)
}

; Used for WinInet
CreateFormData_WinInet(ByRef retData, ByRef retHeader, objParam) {
	New CreateFormData(safeArr, retHeader, objParam)

	size := safeArr.MaxIndex() + 1
	VarSetCapacity(retData, size, 1)
	DllCall("oleaut32\SafeArrayAccessData", "ptr", ComObjValue(safeArr), "ptr*", pdata)
	DllCall("RtlMoveMemory", "ptr", &retData, "ptr", pdata, "ptr", size)
	DllCall("oleaut32\SafeArrayUnaccessData", "ptr", ComObjValue(safeArr))
}

Class CreateFormData {

	__New(ByRef retData, ByRef retHeader, objParam) {

		CRLF := "`r`n"

		Boundary := this.RandomBoundary()
		BoundaryLine := "------------------------------" . Boundary

		; Loop input paramters
		binArrs := []
		For k, v in objParam
		{
			If IsObject(v) {
				For i, FileName in v
				{
					str := BoundaryLine . CRLF
					     . "Content-Disposition: form-data; name=`"" . k . "`"; filename=`"" . FileName . "`"" . CRLF
					     . "Content-Type: " . this.MimeType(FileName) . CRLF . CRLF
					binArrs.Push( BinArr_FromString(str) )
					binArrs.Push( BinArr_FromFile(FileName) )
					binArrs.Push( BinArr_FromString(CRLF) )
				}
			} Else {
				str := BoundaryLine . CRLF
				     . "Content-Disposition: form-data; name=`"" . k "`"" . CRLF . CRLF
				     . v . CRLF
				binArrs.Push( BinArr_FromString(str) )
			}
		}

		str := BoundaryLine . "--" . CRLF
		binArrs.Push( BinArr_FromString(str) )

		retData := BinArr_Join(binArrs*)
		retHeader := "multipart/form-data; boundary=----------------------------" . Boundary
	}

	RandomBoundary() {
		str := "0|1|2|3|4|5|6|7|8|9|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z"
		Sort, str, D| Random
		str := StrReplace(str, "|")
		Return SubStr(str, 1, 12)
	}

	MimeType(FileName) {
		n := FileOpen(FileName, "r").ReadUInt()
		Return (n        = 0x474E5089) ? "image/png"
		     : (n        = 0x38464947) ? "image/gif"
		     : (n&0xFFFF = 0x4D42    ) ? "image/bmp"
		     : (n&0xFFFF = 0xD8FF    ) ? "image/jpeg"
		     : (n&0xFFFF = 0x4949    ) ? "image/tiff"
		     : (n&0xFFFF = 0x4D4D    ) ? "image/tiff"
		     : "application/octet-stream"
	}

}