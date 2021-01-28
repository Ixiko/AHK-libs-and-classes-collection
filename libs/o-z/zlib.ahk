zlib_Compress(Byref Compressed, Byref Data, DataLen, level = -1) {

	; http://www.autohotkey.com/forum/viewtopic.php?t=68170

	nSize := DllCall("zlib1\compressBound", "UInt", DataLen, "Cdecl")
	VarSetCapacity(Compressed,nSize)
	ErrorLevel := DllCall("zlib1\compress2", "ptr", &Compressed, "UIntP", nSize, "ptr", &Data, "UInt", DataLen, "Int"
				   , level    ;level 0 (no compression), 1 (best speed) - 9 (best compression)
				   , "Cdecl") ;0 means Z_OK

return ErrorLevel ? 0 : nSize
}

zlib_Decompress(Byref Decompressed, Byref CompressedData, DataLen, OriginalSize = -1) {

	; http://www.autohotkey.com/forum/viewtopic.php?t=68170

	OriginalSize := (OriginalSize > 0) ? OriginalSize : DataLen*10 ;should be large enough for most cases
	VarSetCapacity(Decompressed,OriginalSize)
	ErrorLevel := DllCall("zlib1\uncompress", "Ptr", &Decompressed, "UIntP", OriginalSize, "Ptr", &CompressedData, "UInt", DataLen)

return ErrorLevel ? 0 : OriginalSize
}

gz_compress(infilename, outfilename) {

	; http://www.autohotkey.com/forum/viewtopic.php?t=68170

	VarSetCapacity(sOutFileName, 260)
	DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "str", outfilename, "int", -1, "str", sOutFileName, "int", 260, "Uint", 0, "Uint", 0)
	infile := FileOpen(infilename, "r")
	outfile := DllCall("zlib1\gzopen", "Str" , sOutFileName , "Str", "wb", "Cdecl")
	if (!infile || !outfile)
	   return 0
	nBufferLen := 8192 ; can be increased if gzbuffer function is called beforehand
	VarSetCapacity(inbuffer,nBufferLen)
	while ((num_read := infile.RawRead(inbuffer, nBufferLen)) > 0)
	   DllCall("zlib1\gzwrite", "UPtr", outfile, "UPtr", &inbuffer, "UInt", num_read, "Cdecl")
	infile.Close()
	DllCall("zlib1\gzclose", "UPtr", outfile, "Cdecl")

return 1
}

gz_decompress(infilename, outfilename) {

	;http://www.autohotkey.com/forum/viewtopic.php?t=68170

	VarSetCapacity(sInFileName, 260)
	DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "str", infilename, "int", -1, "str", sInFileName, "int", 260, "Uint", 0, "Uint", 0)
	infile := DllCall("zlib1\gzopen", "Str" , sInFileName , "Str", "rb", "Cdecl")
	outfile := FileOpen(outfilename, "w")
	if (!infile || !outfile)
	   return 0
	VarSetCapacity(buffer,8192) ;can be increased after calling gzbuffer beforehand
	num_read = 0
	while ((num_read := DllCall("zlib1\gzread", "UPtr", infile, "UPtr", &buffer, "UInt", 8192, "Cdecl")) > 0)
	   outfile.RawWrite(buffer, num_read)
	DllCall("zlib1\gzclose", "UPtr", infile, "Cdecl")
	infile.Close()

return 1
}

/*
Return codes for the compression/decompression functions. Negative values are errors, positive values are used for special but normal events.
#define Z_OK            0
#define Z_STREAM_END    1
#define Z_NEED_DICT     2
#define Z_ERRNO        (-1)
#define Z_STREAM_ERROR (-2)
#define Z_DATA_ERROR   (-3)
#define Z_MEM_ERROR    (-4)
#define Z_BUF_ERROR    (-5)
#define Z_VERSION_ERROR (-6)

Compression levels.
#define Z_NO_COMPRESSION         0
#define Z_BEST_SPEED             1
#define Z_BEST_COMPRESSION       9
#define Z_DEFAULT_COMPRESSION  (-1)
*/