
;JEE_FileEmpty
;JEE_FileGetEncoding
;JEE_FileReadForce
;JEE_FileSetText

;==================================================

;empty/clear existing file (overwrite file)
;warning: use this function with caution
;JEE_ClearFile
JEE_FileEmpty(vPath)
{
	vAttrib := FileExist(vPath)
	if (vAttrib = "") || InStr(vAttrib, "D")
		return 0
	vSize := FileGetSize(vPath)
	if ErrorLevel
		return 0
	;else if (vSize = 0) ;overwrite even if already blank to set modified date
	;	return 1
	else if !oFile := FileOpen(vPath, "w")
		return 0
	oFile.Close()
	return 1
}

;==================================================

;e.g. vEnc := JEE_FileGetEncoding(vPath)
;output examples: CP1252, UTF-8, UTF-16
JEE_FileGetEncoding(vPath)
{
	if !(oFile := FileOpen(vPath, "r"))
		return
	vEnc := oFile.Encoding
	oFile.Close()
	return vEnc
}

;==================================================

JEE_FileReadForce(vPath, vEnc:="", vIncBomAlways:=0)
{
	if !oFile := FileOpen(vPath, "r")
		return
	vSize := oFile.Length
	VarSetCapacity(vData, vSize + 7, 0)

	if vIncBomAlways
	|| !((vEnc = "UTF-8") || (vEnc = "UTF-16"))
	|| !(vEnc = oFile.Encoding)
		oFile.Pos := 0
	oFile.RawRead(vData, vSize)
	oFile.Close()
	return StrGet(&vData, vSize, vEnc)
}

;==================================================

;warning: the parameter order differs from AHK's FileAppend command
;note: 'Path, Text, Enc', not: 'Text, Path, Enc'
;note: this can create a new file (as well as modify existing files)
;note: if vEnc is blank, and the file exists, the file's current encoding will be used
;note: if vEnc is blank, and the file does not exist, A_FileEncoding will be used
;JEE_FileWrite
JEE_FileSetText(vPath, vText, vEnc:="")
{
	if (vEnc = "")
		if FileExist(vPath)
		{
			if !(oFile := FileOpen(vPath, "r"))
				return 0
			vEnc := oFile.Encoding
			oFile.Close()
		}
		else
			vEnc := A_FileEncoding
	if !(oFile := FileOpen(vPath, "w"))
		return 0
	oFile.Encoding := vEnc
	if (vEnc = "UTF-8") || (vEnc = "UTF-16")
		oFile.Write(Chr(0xFEFF)) ;BOM
	oFile.Write(vText)
	oFile.Close()
}

;==================================================
