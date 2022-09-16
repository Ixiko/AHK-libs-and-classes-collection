/*
	Storing variables/files in JSON format inside AHK Script Demo
	created by oif2003 for AutoHotkey v2 a100 on 20 Nov 2018
*/
/*
#singleinstance force

;To use the demo simply run it twice going through the prompts each time.
;The json object is loaded automatically when the script starts and is
;saved automatically on exit.

doc.jso.run++
if Mod(doc.jso.run, 2) {
	doc.jso.firstName := InputBox("Enter your name: ")

	msgbox("Select file to attach")
	file := FileSelect()
	description := InputBox("Enter a file description: ")
	doc.pack(file, description)

	msgbox("Once script exits, view script file to see attachment.")
} else {
	msgbox("Hello " doc.jso.firstName "!")

	msgbox("Now we we unpack.")
	target := FileSelect(,doc.jso.file[1].2_dir "\" doc.jso.file[1].1_fileName ".test")
	doc.unpack(doc.jso.file[1].8_data, target)
	if doc.fileSHA256(target) == doc.jso.file[1].7_sha256 {
		msgbox("Success! Hash (SHA256) matches!")
	}

	doc.jso.file := ""
	doc.jso.firstName := ""
}
*/
;----------------------------------------------------------------------------------------------
;by oif2003 on 19 Nov 2018, written for AutoHotkey v2 a100
;----------------------------------------------------------------------------------------------
;Basic json class, call json(x) to convert between json string and ahk Object
;Note: proper json escape sequences have not been implmented, this version only
;escapes `" (escaped double quote, AHK style)
;----------------------------------------------------------------------------------------------
json(x)=>json.auto(x)	;if x is an object it returns a json string and vice versa
;----------------------------------------------------------------------------------------------
;This json converter operates as follows:
;	If given a json string:
;	1)	Replace all string literals with serialized tokens
;	2) 	Convert json string to ahk function string consisting of array(...) and object(...)
;	3)	Replace tokens with original strings
;	4)	Evaluate the ahk function expression string and return the resulting object
;
;	If given an ahk object:
;	1)	Recursively print output using obj2str
;	2)	isNumber and isArray are used to determine the format of the output (numbers are not quoted
;		and arrays sit inside brackets inside of braces)
;
class json {
	;auto input parser json string <=> ahk object
	auto(input) {
		if IsObject(input) {
			return this.obj2str(input)
		} else {
			return this.str2obj(input)
		}
	}

	;------------------------------------------------------------------------------------------
	;convert object to json string
	obj2str(obj, firstRun := true) {
		static output := ""
		static level := 0
		static noTab := false
		if firstRun {
			output := ""
		}

		if isObject(obj) {
			if obj.Count() {
				if isArray(obj) {	;if this is an array (based on A_Index == key)
					output .= (noTab ? "" : tabs(level)) "[`n"
					level++
					noTab := false
					for k, v in obj {
						this.obj2str(v, false)
						output .= (k != obj.Count() ? "," : "") "`n"
					}
					output .= tabs(--level) "]"
				} else {	;otherwise output as object
					output .= (noTab ? "" : tabs(level)) "{`n"
					level++
					noTab := false
					for k, v in obj {
						output .= tabs(level) '"' k '": '
						noTab := true
						this.obj2str(v,  false)
						noTab := false
						output .= (A_Index != obj.Count() ? "," : "") "`n"
					}
					output .= tabs(--level) "}"
				}
			} else {
				output .= "[]"
			}
		} else {
			if obj == "" {
				obj := "null"
			} else if !(obj is "Number") || !isNumber(obj) {	;don't put quotes around numbers
				obj := '"' obj '"'
			}
			output .= (noTab ? "" : tabs(level)) obj
		}

		return output

		isNumber(x) {	;quickly and dirty check.  Other ideas: use is Type first then do this
			return NumGet(&x, "UInt")   == x
				|| NumGet(&x, "Int")    == x || NumGet(&x, "Int64") == x
				|| NumGet(&x, "Double") == x || NumGet(&x, "Float") == x
				|| NumGet(&x, "Ptr")    == x || NumGet(&x, "UPtr") == x
				|| NumGet(&x, "Short")  == x || NumGet(&x, "UShort") == x
				|| NumGet(&x, "Char")   == x || NumGet(&x, "UChar") == x
		}

		isArray(arr) {	;another quick and dirty check: A_Index == Current Key ?
			if !IsObject(arr) {
				return false
			} else {
				for k, v in arr {
					if k != A_Index {
						return false
					}
				}
				return true
			}
		}

		tabs(n) {	;create tab string
			loop n {
				tab .= "`t"
			}
			return tab
		}
	}

	;------------------------------------------------------------------------------------------
	;covert json string to ahk function string then feed it thru the function parser
	str2obj(jstr) {
		funcStr := this.jstr2func(jstr)
		o := json.funcParser(strreplace(funcstr, '"'))
		return o
	}

	;recursively evaluate the function string
	funcParser(funcStr) {
		paren := InStr(funcStr, "(")
		if paren {
			innerStr := SubStr(funcStr, paren + 1, -1)
			parenCount := 0
			argStart := 1
			args := []
			loop parse innerStr {
				if A_LoopField == "(" {
					parenCount++
				} else if A_LoopField == ")" {
					parenCount--
				}

				if !parenCount && A_LoopField == "," {
					args.push(SubStr(innerStr, argStart, A_Index - argStart))
					argStart := A_Index + 1
				} else if A_Index == StrLen(innerStr) {
					args.push(SubStr(innerStr, argStart, A_Index - argStart + 1))
				}
			}

			for k, v in args {
				args[k] := this.funcParser(v)
			}

			return func(SubStr(funcStr, 1, paren - 1)).Call(args*)
		} else {
			this.restoreString(funcStr, this.dictionary)	;replace string tokens with their originals
			if funcStr is "Number" {
				return funcStr + 0
			} else {
				if funcStr == "null" {
					return
				} else if funcStr == "true" {
					return true
				} else if funcStr == "false" {
					return false
				} else if SubStr(funcStr, 1, 1) == '"' && SubStr(funcStr, -1, 1) == '"' {
					funcStr := SubStr(funcStr, 2, -1)	;remove quotation marks on strings
					return funcStr
				} else {
					return "Unhandled exception, check " A_ScriptName ", " A_ThisFunc ", " A_LineNumber
				}
			}
		}
	}

	;convert json string to function string in ahk. namely, arrary() and object()
	jstr2func(jstr, firstRun := true) {
		static tokenBase := 0x1abf - 1
		static commaToken := Chr(tokenBase + 1)
		static colonToken := Chr(tokenBase + 2)

		if firstRun {
			this.dictionary := this.tokenizeString(jstr)
			jstr := StrReplace(jstr, "`n")				;remove newline, tab, and space
			jstr := StrReplace(jstr, "`r")
			jstr := StrReplace(jstr, "`t")
			jstr := StrReplace(jstr, " ")
		}

		if !InStr(jstr, "[") && !InStr(jstr, "{") {
			return jstr
		} else {
			inner := findInnerMost(jstr)
			innerStr := SubStr(jstr, inner[1], inner[2] - inner[1] + 1)
			jstr := SubStr(jstr, 1, inner[1] - 1) str2func(innerStr) SubStr(jstr, inner[2] + 1)
			jstr := this.jstr2func(jstr, firstRun := false)

			return jstr
		}

		str2func(str) {		;convert string to function
			brace := InStr(str, "{")
			brack := InStr(str, "[")
			if brack {

				funcStr := 'Array('
				funcStrArr := StrSplit(SubStr(str, 2, -1), commaToken)
				for k, v in funcStrArr {
					funcStr .= str2func(v) (k != funcStrArr.Length() ? "," : "")
				}
				funcStr .= ")"
			} else if brace {
				funcStr := 'Object(' StrReplace(SubStr(str, 2), "}", ")")
				funcStr := StrReplace(funcStr, ':', ',')
			} else {
				return str
			}
			return funcStr
		}

		findInnerMost(str) {	;find innermost object/array
			braceCount := brackCount := maxCount := maxStart := maxEnd := 0

			loop parse str {
				if 			A_LoopField == "{" {
					braceCount++
				} else if 	A_LoopField == "}" {
					braceCount--
				} else if 	A_LoopField == "[" {
					brackCount++
				} else if 	A_LoopField == "]" {
					brackCount--
				}

				if braceCount + brackCount > maxCount {						;Find max cumulative count of [ and {
					maxCount := braceCount + brackCount
					maxStart := A_Index										;Update max [ / { location
					closing := SubStr(str, A_Index, 1) == "[" ? "]" : "}"
					maxEnd := InStr(str, closing, , A_Index)				;update where it ends
				}
			}
			return [maxStart, maxEnd]
		}
	}

	;------------------------------------------------------------------------------------------
	;helper methods
	restoreString(ByRef str, dictionary) {
		static tokenBase := 0x1abf - 1
		static strToken  := Chr(tokenBase + 3)
		static escapedQuote := Chr(tokenBase + 4)
		for k, v in dictionary {
			str := StrReplace(str, strToken k strToken, v, , 1)
		}
		str := StrReplace(str, escapedQuote, '"')
	}

	tokenizeString(ByRef str) {
		static tokenBase := 0x1abf - 1
		static strToken  := Chr(tokenBase + 3)
		static escapedQuote := Chr(tokenBase + 4)

		quoteCount :=  quoteStart := 0
		dictionary := []

		str := StrReplace(str, '``"', escapedQuote)

		loop parse str {
			if A_LoopField == '"' {
				quoteCount++

				if Mod(quoteCount, 2) {
					quoteStart := A_Index
				} else {
					quoteEnd := A_Index
					dictionary.push(SubStr(str, quoteStart, quoteEnd - quoteStart + 1))
				}
			}
		}

		for k, v in dictionary {
			str := StrReplace(str, v, strToken k strToken, , 1)
		}
		return dictionary
	}
}



;----------------------------------------------------------------------------------------------
;by oif2003 on 20 Nov 2018, written for AutoHotkey v2 a100
;----------------------------------------------------------------------------------------------
;Compress/Decompress file and converts them from binary to string so they can be stored as
;plaintext inside a script file.  This class will autoload the json object at the end of
;this file to doc.jso.  On exit, it will save to the same string automatically (provided you
;don't crash out, of course.
;	Methods: savejson, loadjson
class document {
	static label := "/* json" " " "attachements"
	static script

	__New() {
		global
		static init := new document()
		if init {
			return init
		}
		this.jso:= this.loadjson()
		onExit(()=>this.savejson())
		doc := this
	}

	savejson() {	;dumps the current doc.jso object into json string and saves it
		this.script := SubStr(this.script, 1, InStr(this.script, this.label) - 1)
		this.script := this.script this.label "`n" json(this.jso)
		FileOpen(A_ScriptFullPath, "w").Write(this.script)
	}

	loadjson() {	;loads the json string at the end of this file
		this.script := FileRead(A_ScriptFullPath)
		jstr := SubStr(this.script, InStr(this.script, this.label, true, -1) + StrLen(this.label) + 1)
		return json(jstr)
	}

	unpack(str, target) {	;unpack a file that has been stored inside the doc.jso object
		cryptString := str	;str is doc.jso.file[n].8_data

		;https://docs.microsoft.com/en-us/windows/desktop/api/compressapi/nf-compressapi-createcompressor
		COMPRESS_ALGORITHM_MSZIP        := 2    ;MSZIP compression algorithm
		COMPRESS_ALGORITHM_XPRESS       := 3 	;XPRESS compression algorithm
		COMPRESS_ALGORITHM_XPRESS_HUFF  := 4	;XPRESS compression algorithm with Huffman encoding
		COMPRESS_ALGORITHM_LZMS         := 5	;LZMS compression algorithm

		;first call to get buffer size
		DllCall("crypt32\CryptStringToBinary"
		   , "str", cryptString	            ;pszString
		   , "uint", 0			            ;cchString
		   , "uint", 1			            ;dwFlags
		   , "ptr", 0		    	        ;pbBinary
		   , "uint*", s	    	            ;pcbBinary
		   , "ptr", 0			            ;pdwSkip
		   , "ptr", 0			            ;pdwFlags
		)

		;set buffer size based on previous call (*2 for UTF)
		VarSetCapacity(buffer, s*2)
		DllCall("crypt32\CryptStringToBinary"
		   , "str", cryptString	            ;pszString
		   , "uint", 0			            ;cchString
		   , "uint", 1			            ;dwFlags
		   , "ptr", &buffer	    	        ;pbBinary
		   , "uint*", s	    	            ;pcbBinary
		   , "ptr", 0			            ;pdwSkip
		   , "ptr", 0			            ;pdwFlags
		)

		;Create Decompressor Handle
		DllCall("Cabinet.dll\CreateDecompressor"
		  , "UInt", COMPRESS_ALGORITHM_LZMS	    ;Algorithm,
		  , "Ptr",  0		                    ;AllocationRoutines,
		  , "Ptr*", dHandle                     ;CompressorHandle
		)

		size := s
		;first call to get buffer size (s)
		DllCall("Cabinet.dll\Decompress"
		  ,"Ptr", dHandle                   ;DecompressorHandle,
		  ,"Ptr", &buffer                   ;CompressedData,
		  ,"UInt", size                     ;CompressedDataSize,
		  ,"Ptr", &dBuffer                  ;UncompressedBuffer,
		  ,"UInt", 0                        ;UncompressedBufferSize,
		  ,"UInt*", s                       ;UncompressedDataSize
		)

		;set buffer size based on previous call
		_s := VarSetCapacity(dBuffer, s)
		DllCall("Cabinet.dll\Decompress"
		  ,"Ptr", dHandle                   ;DecompressorHandle,
		  ,"Ptr", &buffer                   ;CompressedData,
		  ,"UInt", size                     ;CompressedDataSize,
		  ,"Ptr", &dBuffer                  ;UncompressedBuffer,
		  ,"UInt", _s                       ;UncompressedBufferSize,
		  ,"UInt*", s                       ;UncompressedDataSize
		)

		DllCall("Cabinet.dll\CloseDecompressor", "Ptr", dHandle)

		FileDelete(target)
		FileOpen(target, "w").RawWrite(dbuffer,s)

	}

	pack(file, description) {	; packs and compresses a file, it is then stored as plaintext
		size    := FileGetSize(file)
		sha256  := this.fileSHA256(file)
		dlltext := FileRead(file, "RAW")
		_size 	:= size

		;https://docs.microsoft.com/en-us/windows/desktop/api/compressapi/nf-compressapi-createcompressor
		COMPRESS_ALGORITHM_MSZIP        := 2    ;MSZIP compression algorithm
		COMPRESS_ALGORITHM_XPRESS       := 3 	;XPRESS compression algorithm
		COMPRESS_ALGORITHM_XPRESS_HUFF  := 4	;XPRESS compression algorithm with Huffman encoding
		COMPRESS_ALGORITHM_LZMS         := 5	;LZMS compression algorithm

		DllCall("Cabinet.dll\CreateCompressor"
		  , "UInt", COMPRESS_ALGORITHM_LZMS	    ;Algorithm,
		  , "Ptr",  0		                    ;AllocationRoutines,
		  , "Ptr*", cHandle                     ;CompressorHandle
		)

		;https://docs.microsoft.com/en-us/windows/desktop/api/compressapi/nf-compressapi-compress
		;first call to get buffer size (s)
		DllCall("Cabinet.dll\Compress"
		  ,"Ptr", cHandle                   ;CompressorHandle,
		  ,"Ptr", &dlltext                  ;UncompressedData,
		  ,"UInt", size                     ;UncompressedDataSize,
		  ,"Ptr", &cBuffer                  ;CompressedBuffer,
		  ,"UInt", 0                        ;CompressedBufferSize,
		  ,"UInt*", s                       ;CompressedDataSize
		)

		;set buffer size based on previous call
		_s := VarSetCapacity(cBuffer, s)
		DllCall("Cabinet.dll\Compress"
		  ,"Ptr", cHandle                   ;CompressorHandle,
		  ,"Ptr", &dlltext                  ;UncompressedData,
		  ,"UInt", size                     ;UncompressedDataSize,
		  ,"Ptr", &cBuffer                  ;CompressedBuffer,
		  ,"UInt", _s                       ;CompressedBufferSize,
		  ,"UInt*", s                       ;CompressedDataSize
		)

		DllCall("Cabinet.dll\CloseCompressor", "Ptr", cHandle)

		size := s
		;https://docs.microsoft.com/en-us/windows/desktop/api/wincrypt/nf-wincrypt-cryptbinarytostringw
		;first call to find size (s) needed for our crypt string
		DllCall("crypt32\CryptBinaryToString"
		   , "Ptr", &cBuffer			    ;pbBinary   ptr to array of bytes
		   , "uint", size            	    ;cbBinary   length of array
		   , "uint", 1						;dwFlags    flags: 1 = 64 bit without headers
		   , "ptr", 0				        ;pszString  when this is 0, pccString returns needed size
		   , "uint*", s			            ;pccString
		)

		VarSetCapacity(cryptString, s := s * 2)     ;*2 for unicode
		;second call to get the actual string
		DllCall("crypt32\CryptBinaryToString"
		   , "Ptr", &cBuffer			    ;pbBinary   ptr to array of bytes
		   , "uint", size            	    ;cbBinary   length of array
		   , "uint", 1						;dwFlags    flags: 1 = 64 bit without headers
		   , "str", cryptString		        ;pszString  now this is ptr to buffer of string
		   , "uint*", s     		        ;pccString  size of buffer as previously determined
		)

		str .= cryptString
		SplitPath(file, fileName, dir)
		this.jso.file := []
		this.jso.file[1] :=	{1_fileName:fileName, 4_uncompressedSize: _size
							, 3_compressedSize: size, 5_added: formattime(A_Now), 6_description:description
							, 2_dir:dir, 7_sha256:sha256, 8_data:str}
	}

	fileSHA256(file) {	;using CertUtil to get SHA256
		static cPid := 0
		if !cPid {
			_A_DetectHiddenWindows := A_DetectHiddenWindows
			A_DetectHiddenWindows := true
			Run(A_ComSpec " /k ",,"Hide", cPid)
			WinWait("ahk_pid" cPid,, 10)
			DllCall("AttachConsole","uint",cPid)
			A_DetectHiddenWindows := _A_DetectHiddenWindows
			OnExit(()=>cleanUp(cPid))
		}

		objShell := ComObjCreate("WScript.Shell")
		objExec := objShell.Exec('certutil -hashfile "' file '" SHA256')
		strStdOut:=strStdErr:=""
		while !objExec.StdOut.AtEndOfStream
			 strStdOut := objExec.StdOut.ReadAll()
		while !objExec.StdErr.AtEndOfStream
			 strStdErr := objExec.StdErr.ReadAll()

		r := strStdOut strStdErr
		SplitPath(file, fileName)
		RegExMatch(r, "(?<=" fileName ":)(.|`r|`n)*(?=CertUtil)", match)
		return match.Value(0)

		;cleanUp function called on script exit (OnExit)
		cleanUp(_cPid) {
			_A_DetectHiddenWindows := A_DetectHiddenWindows
			A_DetectHiddenWindows := true
			DllCall("FreeConsole", "UInt")
			WinKill("ahk_pid" _cPid)
			A_DetectHiddenWindows := _A_DetectHiddenWindows
		}
	}
}

;===========================================================================================
/* json attachements
{
	"firstName": FirstRun,
	"run": 0
}
