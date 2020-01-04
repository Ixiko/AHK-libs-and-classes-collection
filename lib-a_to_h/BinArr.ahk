
; Update: 2015-6-4 - Added BinArr_ToFile()

BinArr_FromString(str) {
	oADO := ComObjCreate("ADODB.Stream")

	oADO.Type := 2 ; adTypeText
	oADO.Mode := 3 ; adModeReadWrite
	oADO.Open()
	oADO.Charset := "UTF-8"
	oADO.WriteText(str)
	oADO.Position := 0
	oADO.Type := 1 ; adTypeBinary
	oADO.Position := 3 ; Skip UTF-8 BOM
	return oADO.Read, oADO.Close
}

BinArr_FromFile(FileName) {
	oADO := ComObjCreate("ADODB.Stream")

	oADO.Type := 1 ; adTypeBinary
	oADO.Open
	oADO.LoadFromFile(FileName)
	return oADO.Read, oADO.Close
}

BinArr_Join(Arrays*) {
	oADO := ComObjCreate("ADODB.Stream")

	oADO.Type := 1 ; adTypeBinary
	oADO.Mode := 3 ; adModeReadWrite
	oADO.Open
	For i, arr in Arrays
		oADO.Write(arr)
	oADO.Position := 0
	return oADO.Read, oADO.Close
}

BinArr_ToString(BinArr, Encoding := "UTF-8") {
	oADO := ComObjCreate("ADODB.Stream")

	oADO.Type := 1 ; adTypeBinary
	oADO.Mode := 3 ; adModeReadWrite
	oADO.Open
	oADO.Write(BinArr)

	oADO.Position := 0
	oADO.Type := 2 ; adTypeText
	oADO.Charset  := Encoding 
	return oADO.ReadText, oADO.Close
}

BinArr_ToFile(BinArr, FileName) {
	oADO := ComObjCreate("ADODB.Stream")

	oADO.Type := 1 ; adTypeBinary
	oADO.Open
	oADO.Write(BinArr)
	oADO.SaveToFile(FileName, 2)
	oADO.Close
}
