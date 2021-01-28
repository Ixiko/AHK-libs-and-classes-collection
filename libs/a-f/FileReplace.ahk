FileReplace(ByRef data,file,Encoding:=""){
	FileDelete % file
	If ErrorLevel&&FileExist(file)
		Return 0
	If Encoding
		FileAppend % data,% file
	else FileAppend % data,% file,% Encoding
	return !ErrorLevel
}