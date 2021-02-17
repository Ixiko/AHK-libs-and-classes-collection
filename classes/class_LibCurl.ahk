Class Curl {
	Static autoCleanup := True
	Static dllFilename := ""    ; 
	Static dllHandle   := 0     ; 
	Static activePool  := {}    ; Handles to performing instances to access from callbacks
	
	
	; Prepares class by loading libcurl (and openssl) dll-libraries from a given path.
	; This function must be called first. May throw exceptions.
	; 
	; Following libraries required:
	;   32-bit              64-bit                    Where to download
	;   libcurl.dll       | libcurl-x64.dll        @  https://curl.se/download.html
	;   libssl-1_1.dll    | libssl-1_1-x64.dll     @  https://wiki.openssl.org/index.php/Binaries
	;   libcrypto-1_1.dll | libcrypto-1_1-x64.dll  @  https://wiki.openssl.org/index.php/Binaries
	;
	; If you get 'Unable to load libcurl.dll', check error code:
	;   126 (0x7E) - ERROR_MOD_NOT_FOUND  - Are all libs (both Libcurl and OpenSSL) present?
	;   193 (0xC1) - ERROR_BAD_EXE_FORMAT - Aren't you loading 32-bit libs from 64-bit exe?
	
	Initialize(dllPath := "") {
		If (Curl.dllHandle != 0)
			Return
		
		Curl.dllFilename := (A_PtrSize == 4)
		?  "libcurl.dll"
		:  "libcurl-x64.dll"
		
		; Change working dir so libcurl can load ssl-libraries from the same path
		oldWorkingDir := A_WorkingDir
		SetWorkingDir % dllPath
		Curl.dllHandle := DllCall("LoadLibrary", "Str", Curl.dllFilename, "Ptr")
		SetWorkingDir % oldWorkingDir
		
		If (Curl.dllHandle == 0)
			Throw Exception(Format("Unable to load {1}`nErrorCode: {2}", Curl.dllFilename, A_LastError), -1)
		
		; 0x03 - CURL_GLOBAL_ALL
		retCode := DllCall(Curl.dllFilename . "\curl_global_init", "Int", 0x03, "CDecl")
		If (retCode != 0)
			Throw Exception("Call to curl_global_init failed.`nErrorCode: " . retCode, -1)
		
		If (Curl.autoCleanup)
			OnExit(ObjBindMethod(Curl, "Deinitialize"))
		
		Curl.Opt.Init()
		Curl.Info.Init()
		
		Curl._CB_Write    := RegisterCallback(Curl._WriteCallback    , "CDecl")
		Curl._CB_Header   := RegisterCallback(Curl._HeaderCallback   , "CDecl")
		Curl._CB_Read     := RegisterCallback(Curl._ReadCallback     , "CDecl")
		Curl._CB_Progress := RegisterCallback(Curl._ProgressCallback , "CDecl")
		Curl._CB_Debug    := RegisterCallback(Curl._DebugCallback    , "CDecl")
		
		Return Curl.dllHandle
	}
	
	
	Deinitialize() {
		DllCall(Curl.dllFilename . "\curl_global_cleanup", "CDecl")
		DllCall("FreeLibrary", "Ptr", Curl.dllHandle)
		Curl.dllHandle := 0
	}
	
	
	; Read struct, taking care of members alignment.
	; Returns object with given names and according values from that struct.
	; Currently used in .GetVersionInfo, look into it for reference.
	
	_ReadStruct(structPtr, pairs*) {
		result  := []
		elemPos := 0
		
		For index, elem In pairs {
			If (index & 1) {
				elemName := elem
				Continue
			}
			
			readSize := False ? 0
			:  (elem == "Int64")  ?  8
			:  (elem ~= "Char")   ?  1
			:  (elem ~= "Short")  ?  2
			:  (elem ~= "Int")    ?  4
			:  (elem == "Float")  ?  4
			:  (elem == "Double") ?  8  :  A_PtrSize
			
			elemPos := Ceil(elemPos / readSize) * readSize  ; Padding
			elemVal := NumGet(0+structPtr, elemPos, elem)
			elemPos += readSize
			
			If (elem ~= "Str") {
				isAnsi := (elem == "AStr") || ((elem == "Str") && (A_IsUnicode == False))
				elemVal := StrGet(elemVal, isAnsi ? "CP0" : "UTF-16")
			}
			
			result[elemName] := elemVal
		}
		
		result._structSize := elemPos  ; Total struct size
		
		Return result
	}
	
	
	; Returns version info string
	
	GetVersion() {
		Return DllCall(Curl.dllFilename . "\curl_version", "AStr")
	}
	
	
	; Returns version info object
	
	GetVersionInfo() {
		infoStruct := DllCall(Curl.dllFilename . "\curl_version_info", "Int", 0x7, "Ptr")  ; 0x7 - CURLVERSION_EIGHT, 
		
		versionAge := NumGet(infoStruct, 0, "Int")
		
		structPairs := [""
		. "age"            , "Int"
		, "version"        , "AStr"
		, "version_num"    , "UInt"
		, "host"           , "AStr"
		, "features"       , "Int"
		, "ssl_version"    , "AStr"
		, "ssl_version_num", "Int"
		, "libz_version"   , "AStr"
		, "protocols"      , "Ptr"]
		
		If (versionAge >= 3) {  ; CURLVERSION_FOURTH or higher (>= 7.16.1, 2007-01-29)
			structPairs.Push(""
			. "ares"          , "AStr"
			, "ares_num"      , "Int"
			, "libidn"        , "AStr"
			, "iconv_ver_num" , "Int"
			, "libssh_version", "AStr")
		}
		
		If (versionAge >= 4) {  ; CURLVERSION_FIFTH or higher (>= 7.57.0, 2017-11-29)
			structPairs.Push(""
			. "brotli_ver_num" , "UInt"   ; (MAJOR << 24) | (MINOR << 12) | PATCH
			, "brotli_version" , "AStr")
		}
		
		If (versionAge >= 5) {  ; CURLVERSION_SIXTH or higher (>= 7.66.0, 2019-09-11)
			structPairs.Push(""
			. "nghttp2_ver_num" , "UInt"  ; (MAJOR << 16) | (MINOR << 8) | PATCH
			, "nghttp2_version" , "AStr"
			, "quic_version"    , "AStr")
		}
		
		If (versionAge >= 6) {  ; CURLVERSION_SEVENTH or higher (>= 7.70.0, 2020-04-29)
			structPairs.Push(""
			. "cainfo", "AStr"
			, "capath", "AStr")
		}
		
		If (versionAge >= 7) {  ; CURLVERSION_EIGHTH or higher (>= 7.71.0, 2020-06-24)
			structPairs.Push(""
			. "zstd_ver_num" , "UInt"  ; (MAJOR << 24) | (MINOR << 12) | PATCH
			, "zstd_version" , "AStr")
		}
		
		versionInfo := Curl._ReadStruct(infoStruct, structPairs*)
		
		; Convert features bitmask to string
		featuresList := [""
		. "IPV6"          ; IPv6-enabled
		, "KERBEROS4"     ; Kerberos V4 auth is supported (deprecated)
		, "SSL"           ; SSL options are present
		, "LIBZ"          ; libz features are present
		, "NTLM"          ; NTLM auth is supported
		, "GSSNEGOTIATE"  ; Negotiate auth is supported (deprecated)
		, "DEBUG"         ; Built with debug capabilities
		, "ASYNCHDNS"     ; Asynchronous DNS resolves
		, "SPNEGO"        ; SPNEGO auth is supported
		, "LARGEFILE"     ; Supports files larger than 2GB
		, "IDN"           ; Internationized Domain Names are supported
		, "SSPI"          ; Built against Windows SSPI
		, "CONV"          ; Character conversions supported
		, "CURLDEBUG"     ; Debug memory tracking supported
		, "TLSAUTH_SRP"   ; TLS-SRP auth is supported
		, "NTLM_WB"       ; NTLM delegation to winbind helper is supported
		, "HTTP2"         ; HTTP2 support built-in
		, "GSSAPI"        ; Built against a GSS-API library
		, "KERBEROS5"     ; Kerberos V5 auth is supported
		, "UNIX_SOCKETS"  ; Unix domain sockets support
		, "PSL"           ; Mozilla's Public Suffix List, used for cookie domain verification
		, "HTTPS_PROXY"   ; HTTPS-proxy support built-in
		, "MULTI_SSL"     ; Multiple SSL backends available
		, "BROTLI"        ; Brotli features are present.
		, "ALTSVC"        ; Alt-Svc handling built-in
		, "HTTP3"         ; HTTP3 support built-in
		, "ZSTD"          ; zstd features are present
		, "UNICODE"       ; Unicode support on Windows
		, "HSTS"]         ; HSTS is supported
		
		featuresStr := ""
		Loop % featuresList.Length() {
			If ((versionInfo.features >> (A_Index-1)) & 1)
				featuresStr .= featuresList[A_Index] . ";"
		}
		versionInfo.features := SubStr(featuresStr, 1, -1)
		
		; Join entries of protocols array
		protocolsStr := ""
		Loop {
			protocolPtr := NumGet(0+versionInfo.protocols, (A_Index-1)*A_PtrSize, "Ptr")
			If (protocolPtr == 0)
				Break
			protocolsStr .= StrGet(protocolPtr, "CP0") . ";"
		}
		versionInfo.protocols := SubStr(protocolsStr, 1, -1)
		
		Return versionInfo
	}
	
	
	; Returns unix-time for a given timestamp string.
	; For a list of acceptable formats see https://curl.se/libcurl/c/curl_getdate.html
	; Additionally you can pass YYYYMMDDH24MISS format.
	
	GetDate(dateString := "") {
		If (dateString == "")
			dateString := A_NowUTC
		
		If (dateString ~= "^\d+$") {  ; YMDH24MISS
			dateString += 0, Days     ; Fill missing elements
			dateString := RegexReplace(dateString, "^(\d{8})(\d\d)(\d\d)(\d\d).*$", "$1 $2:$3:$4")
		}
		
		Return DllCall(Curl.dllFilename . "\curl_getdate", "AStr", dateString, "Ptr", 0, "CDecl Ptr")
	}
	
	
	_Free(ptr) {
		DllCall(Curl.dllFilename . "\curl_free", "Ptr", ptr, "CDecl")
	}
	
	
	; Returns url-encoded string, optionally converting to a non-native encoding.
	; If 'getPointer' argument is true, function returns a pointer to the encoded string.
	; If you get the pointer, you must call Curl._Free(ptr) when you done with it.
	
	EscapeStr(srcString, encodeAs := "", getPointer := False) {
		If (encodeAs == "")
			encodeAs := "UTF-8"
		
		strBuffer  := ""
		charSize   := (("UTF-16" = encodeAs) || ("CP1200" = encodeAs))  ?  2  :  1
		bufferSize := StrPut(srcString, encodeAs) * charSize
		
		VarSetCapacity(strBuffer, bufferSize)
		StrPut(srcString, &strBuffer, encodeAs)
		
		urlencoded := DllCall(Curl.dllFilename . "\curl_easy_escape"
		, "Ptr", 0
		, "Ptr", &strBuffer
		, "Int", bufferSize-charSize  ; Omit null-terminator
		, "CDecl Ptr")
		
		If (getPointer == True)
			Return urlencoded
		
		result := StrGet(urlencoded, "CP0")
		Curl._Free(urlencoded)
		Return result
	}
	
	
	; Returns URL-decoded string, optionally converting it from a given encoding to a native one.
	; If 'getPointer' argument is a variable or non-false, function returns a pointer to decoded string.
	; If 'getPointer' argument is a variable, its value will be set to the length of decoded string.
	; If you get the pointer, you must call Curl._Free(ptr) when you done with it.
	
	UnescapeStr(srcString, decodeAs := "", ByRef getPointer := False) {
		If (decodeAs == "")
			decodeAs := "UTF-8"
		
		strBuffer  := ""
		bufferSize := StrPut(srcString, "CP0")
		outLength  := 0
		
		VarSetCapacity(strBuffer, bufferSize)
		StrPut(srcString, &strBuffer, "CP0")
		
		urldecoded := DllCall(Curl.dllFilename . "\curl_easy_unescape"
		, "Ptr" , 0
		, "Ptr" , &strBuffer
		, "Int" , 0           ; Omit inLength - strBuffer should be null-terminated
		, "Int*", outLength)
		
		If (IsByRef(getPointer) || (getPointer != False)) {
			getPointer := outLength
			Return urldecoded
		}
		
		result := StrGet(urldecoded, decodeAs)
		Curl._Free(urldecoded)
		Return result
	}
	
	
	; Callbacks
	; =========
	; Note: because those are class methods, arguments are shifted by one,
	; and 'this' variable is actually stores the first argument.
	
	_WriteCallback(size, sizeBytes, userdata) {
		dataPtr  := this
		dataSize := size * sizeBytes
		curlInstance := Curl.activePool[userdata]
		
		; User callback
		userCallbackReply := ""
		If (curlInstance.OnWrite) {
			userCallbackReply := curlInstance.OnWrite.Call(dataPtr, dataSize, curlInstance)
		}
		
		; If (userCallbackReply = "Pause")
		; 	Return 0x10000001  ; CURL_WRITEFUNC_PAUSE
		
		If (userCallbackReply != "")
			Return userCallbackReply
		
		If (curlInstance._writeTo) {
			n := curlInstance._writeTo.RawWrite(dataPtr, dataSize)
			Return n
		}
		Return dataSize
	}
	
	
	_HeaderCallback(size, sizeBytes, userdata) {
		dataPtr  := this
		dataSize := size * sizeBytes
		curlInstance := Curl.activePool[userdata]
		
		; User callback
		userCallbackReply := ""
		If (curlInstance.OnHeader) {
			userCallbackReply := curlInstance.OnHeader.Call(dataPtr, dataSize, curlInstance)
		}
		
		If (userCallbackReply != "")
			Return userCallbackReply
		
		If (curlInstance._headerTo)
			Return curlInstance._headerTo.RawWrite(dataPtr, dataSize)
		
		Return dataSize
	}
	
	
	_ReadCallback(size, sizeBytes, userdata) {
		dataPtr  := this
		dataSize := size * sizeBytes
		curlInstance := Curl.activePool[userdata]
		
		userCallbackReply := ""
		If (curlInstance.OnRead)
			userCallbackReply := curlInstance.OnRead.Call(dataPtr, dataSize, curlInstance)
		
		; If (userCallbackReply = "Pause")
		; 	Return 0x10000001  ; CURL_READFUNC_PAUSE
		
		If (userCallbackReply != "")
			Return userCallbackReply
		
		If (curlInstance._readFrom) {
			Return curlInstance._readFrom.RawRead(dataPtr, dataSize)
		}
		
		Return dataSize
	}
	
	
	_ProgressCallback(params*) {
		userdata := this
		curlInstance := Curl.activePool[userdata]
		
		dlTotal := NumGet(params+0*8, "Int64")
		dlNow   := NumGet(params+1*8, "Int64")
		ulTotal := NumGet(params+2*8, "Int64")
		ulNow   := NumGet(params+3*8, "Int64")
		
		If !(curlInstance.OnProgress)
			Return 0
		
		userCallbackReply := curlInstance.OnProgress.Call(dlTotal, dlNow, ulTotal, ulNow, curlInstance)
		
		If (userCallbackReply = "Unpause") {
			curlInstance._Pause(0, 0)
			Return 0
		}
		
		If (userCallbackReply != "")
			Return userCallbackReply
		
		Return 0
	}
	
	
	_DebugCallback(infoType, dataPtr, size, userdata) {
		Static DBG_TYPE := ["Text", "Header_In", "Header_Out", "Data_In", "Data_Out", "SSL_In", "SSL_Out"]
		
		handle := this
		curlInstance := Curl.activePool[userdata]
		
		If (curlInstance.OnDebug)
			curlInstance.OnDebug.Call(infoType, dataPtr, size, curlInstance)
		
	}
	
	
	
	; Helper functions
	; ================
	
	; Tries to detect mime-type by url or data.
	; For a list of detected mime-types see https://docs.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/platform-apis/ms775147(v=vs.85)
	SniffMimeType(url := "", dataPtr := 0, dataSize := 256) {
		result := ""
		VarSetCapacity(result, A_PtrSize, 0)
		
		s := DllCall("UrlMon.dll\FindMimeFromData"
		, "Ptr"  , 0             ; LPBC    pBC,
		, "WStr" , url           ; LPCWSTR pwzUrl,
		, "Ptr"  , dataPtr       ; LPVOID  pBuffer,
		, "UInt" , dataSize      ; DWORD   cbSize,
		, "Ptr"  , 0             ; LPCWSTR pwzMimeProposed,
		, "UInt" , 0             ; DWORD   dwMimeFlags,
		, "Ptr"  , &result       ; LPWSTR  *ppwzMimeOut,
		, "UInt" , 0)            ; DWORD   dwReserved
		
		Return StrGet(NumGet(result, 0, "Ptr"), "UTF-16")
	}
	
	
	
	; Instance methods
	; ================
	
	__New() {
		this._handle := DllCall(Curl.dllFilename . "\curl_easy_init", "CDecl Ptr")
		this._usedLists := {}  ; Trash bin for linked-lists to be deleted
		
		; User callbacks
		this.OnWrite    := ""
		this.OnRead     := ""
		this.OnHeader   := ""
		this.OnProgress := ""
		this.OnDebug    := ""
		
		; Input/output
		this._writeTo  := ""
		this._headerTo := ""
		this._readFrom := ""
	}
	
	__Delete() {
		this._FreeUsedLists()
		DllCall(Curl.dllFilename . "\curl_easy_cleanup", "Ptr", this._handle, "CDecl")
	}
	
	; Remove used linked-lists
	_FreeUsedLists() {
		For optId, slip In this._usedLists {
			Curl._FreeSList(slip)
		}
		
		this._usedLists := {}
	}
	
	
	Reset() {
		this._FreeUsedLists()
		DllCall(Curl.dllFilename . "\curl_easy_reset", "Ptr", this._handle, "CDecl")
		
		this._writeTo  := ""
		this._headerTo := ""
		this._readFrom := ""
	}
	
	
	_Pause(pauseRecv := True, pauseSend := True) {
		pauseBitmask := (!!pauseRecv << 0) & (!!pauseSend << 2)
		
		DllCall(Curl.dllFilename . "\curl_easy_pause"
		, "Ptr", this._handle
		, "Int", pauseBitmask
		, "CDecl")
	}
	
	
	_SetLastCode(retCode, source := "") {
		this.lastCode       := retCode
		this.lastCodeText   := DllCall(Curl.dllFilename . "\curl_easy_strerror", "Int", retCode, "CDecl AStr")
		this.lastCodeSource := source
		
		Return retCode
	}
	
	
	; Sets option for curl instance.
	; Use last parameter if you need to set argument type explicitly.
	; This can be useful, for example, to set NULL.
	
	SetOpt(optionId, argument, argType := "") {
		;                  1:LONG 2:OBJP 3:STRP  4:SLIP 5:FUNP 6:OFFT   7:BLOB
		Static argTypes := ["Int", "Ptr", "AStr", "Ptr", "Ptr", "Int64", "Ptr"]
		Static AHK_ARG  := 100000  ; See Curl.Opt.Init
		
		If (argType == "") {
			argTypeN := optionId // AHK_ARG
			argType  := argTypes[argTypeN]
			
			If (argTypeN == 4) {
				Curl._FreeSList( this._usedLists[optionId] )  ; Remove previous linked-list (if any)
				argument := Curl._ArrayToSList(argument)      ; Convert array to linked-list
				this._usedLists[optionId] := argument         ; Put to trash bin for eventual cleanup
			}
		}
		
		optionId := Mod(optionId, AHK_ARG)
		
		retCode := DllCall(Curl.dllFilename . "\curl_easy_setopt"
		, "Ptr"  , this._handle
		, "Int"  , optionId
		, argType, argument
		, "CDecl Int")
		
		Return this._SetLastCode(retCode, "OPT:" . optionId)
	}
	
	
	GetInfo(infoId) {
		result := 0
		
		retCode := DllCall(Curl.dllFilename . "\curl_easy_getinfo"
		, "Ptr", this._handle
		, "Int", infoId
		, "Ptr", &result
		, "CDecl Int")
		
		this._SetLastCode(retCode, "INFO:" . infoId)
		
		If (retCode != 0)
			Return
		
		argTypeN := infoId >> 20  ; infoId // 0x100000, see Curl.Info.Init
		
		If (argTypeN == 1)  ; STRP - String
			Return StrGet(NumGet(&result+0, "Ptr"), "CP0")
		
		If (argTypeN == 2)  ; LONG - Long
			Return NumGet(&result+0, "Int")
		
		If (argTypeN == 3)  ; DBLE - Double
			Return NumGet(&result+0, "Double")
		
		If (argTypeN == 4)  ; SLIP - SList pointer
			If ((infoId == Curl.Info.SSL_ENGINES)
			||  (infoId == Curl.Info.COOKIELIST))
				Return Curl.SListToArray( NumGet(&result+0, "Ptr") )
		
		If (argTypeN == 5)  ; SOCK - Socket
			Return NumGet(&result+0, "Int")
		
		If (argTypeN == 6)  ; OFFT - curl_off_t
			Return NumGet(&result+0, "Int64")
		
		Return NumGet(&result+0, "Ptr")
	}
	
	
	; Set output/input files or variables
	
	WriteToFile(filename) {
		Return (this._writeTo := new Curl.Storage.File(filename, "w"))
	}
	
	WriteToMem(maxCapacity := 0) {
		Return (this._writeTo := new Curl.Storage.MemBuffer(0, maxCapacity))
	}
	
	WriteToNone() {
		Return (this._writeTo := "")
	}
	
	
	HeaderToFile(filename) {
		Return (this._headerTo := new Curl.Storage.File(filename, "w"))
	}
	
	HeaderToMem(maxCapacity := 0) {
		Return (this._headerTo := new Curl.Storage.MemBuffer(0, maxCapacity))
	}
	
	HeaderToNone() {
		Return (this._headerTo := "")
	}
	
	
	ReadFromFile(filename) {
		Return (this._readFrom := new Curl.Storage.File(filename, "r"))
	}
	
	ReadFromMem(dataPtr, dataSize) {
		Return (this._readFrom := new Curl.Storage.MemBuffer(dataPtr+0, 0, dataSize))
	}
	
	ReadFromNone() {
		Return (this._readFrom := "")
	}

	
	
	Perform() {
		; Store handle in global pool so callbacks can access the instance
		Curl.activePool[this._handle] := this
		
		; Prepare callbacks, removing old callbacks if necessary.
		needWriteCallback := True
		this.SetOpt(Curl.Opt.WRITEDATA    , (!needWriteCallback ? 0 : this._handle))
		this.SetOpt(Curl.Opt.WRITEFUNCTION, (!needWriteCallback ? 0 : Curl._CB_Write))
		
		needHeaderCallback := (this._headerTo || this.OnHeader)
		this.SetOpt(Curl.Opt.HEADERDATA     , (!needHeaderCallback ? 0 : this._handle))
		this.SetOpt(Curl.Opt.HEADERFUNCTION , (!needHeaderCallback ? 0 : Curl._CB_Header))
		
		needReadCallback := (this._readFrom || this.OnRead)
		this.SetOpt(Curl.Opt.READDATA     , (!needReadCallback ? 0 : this._handle))
		this.SetOpt(Curl.Opt.READFUNCTION , (!needReadCallback ? 0 : Curl._CB_Read))
		
		needProgressCallback := (this.OnProgress)
		this.SetOpt(Curl.Opt.NOPROGRESS       , (!needProgressCallback ? 1 : 0))
		this.SetOpt(Curl.Opt.XFERINFODATA     , (!needProgressCallback ? 0 : this._handle))
		this.SetOpt(Curl.Opt.XFERINFOFUNCTION , (!needProgressCallback ? 0 : Curl._CB_Progress))
		
		needDebugCallback := (this.OnDebug)
		this.SetOpt(Curl.Opt.VERBOSE       , (!needDebugCallback ? 0 : 1))
		this.SetOpt(Curl.Opt.DEBUGDATA     , (!needDebugCallback ? 0 : this._handle))
		this.SetOpt(Curl.Opt.DEBUGFUNCTION , (!needDebugCallback ? 0 : Curl._CB_Debug))
		
		(this._writeTo)   ?  this._writeTo.Open()
		(this._headerTo)  ?  this._headerTo.Open()
		(this._readFrom)  ?  this._readFrom.Open()
		
		; TODO: cookies? headers?
		retCode := DllCall(Curl.dllFilename . "\curl_easy_perform", "Ptr", this._handle, "CDecl")
		
		(this._writeTo)   ?  this._writeTo.Close()
		(this._headerTo)  ?  this._headerTo.Close()
		(this._readFrom)  ?  this._readFrom.Close()
		
		Curl.activePool.Delete(this._handle)
		
		Return this._SetLastCode(retCode, "Perform")
	}
	
	
	; Shortcut methods
	; ----------------
	; In the methods below you'll encounter lots of 'stopAtNonZero' list-expressions.
	; Due to short-circuit evaluation, execution of these lists will stop at first non-zero value.
	; This trick eliminates the necessity to check return codes of SetOpt, and some parameters.
	
	; Convert string of authorization methods to CURLAUTH_* code.
	; Example: "Digest|DigestIE";  "BEARER ONLY";  "AnySafe"
	
	_GetAuthCode(authString) {
		If ("Any" = authString)
			Return ~(1<<4)  ; All except CURLAUTH_DIGEST_IE
		
		If ("AnySafe" = authString)
			Return ~(1 | (1<<4))  ; All except CURLAUTH_BASIC and CURLAUTH_DIGEST_IE
		
		Return 0
		| (!!(authString ~= "i)Basic")     << 0)
		| (!!(authString ~= "i)Digest\b")  << 1)
		| (!!(authString ~= "i)Negotiate") << 2)
		| (!!(authString ~= "i)GSSAPI")    << 2)
		| (!!(authString ~= "i)NTLM\b")    << 3)
		| (!!(authString ~= "i)DigestIE")  << 4)
		| (!!(authString ~= "i)NTLM_WB")   << 5)
		| (!!(authString ~= "i)Bearer")    << 6)
		| (!!(authString ~= "i)Only")      << 31)
	}
	
	
	SetURL(urlString, method := "") {
		stopAtNonZero := 0
		||  this.SetOpt(Curl.Opt.URL, urlString)
		||  (method == "")
		||  this.SetMethod(method)
		
		Return this.lastCode
	}
	
	
	SetMethod(methodName) {
		retCode := False ? 0
		:  (methodName == "HEAD")  ?  this.SetOpt(Curl.Opt.NOBODY  , 1)
		:  (methodName == "GET")   ?  this.SetOpt(Curl.Opt.HTTPGET , 1)
		:  (methodName == "POST")  ?  this.SetOpt(Curl.Opt.POST    , 1)
		:  (methodName == "PUT")   ?  this.SetOpt(Curl.Opt.UPLOAD  , 1)
		:  this.SetOpt(Curl.Opt.CUSTOMREQUEST, methodName)
		
		Return retCode
	}
	
	
	SetCredentials(user, pass, httpAuth := "") {
		stopAtNonZero := 0
		||  this.SetOpt(Curl.Opt.USERNAME, user)
		||  this.SetOpt(Curl.Opt.PASSWORD, pass)
		||  (httpAuth == "")
		||  this.SetOpt(Curl.Opt.HTTPAUTH, Curl._GetAuthCode(httpAuth))
		
		Return this.lastCode
	}
	
	
	SetProxy(proxyUrl, tunnel := "") {
		stopAtNonZero := 0
		||  this.SetOpt(Curl.Opt.PROXY, proxyUrl)
		||  (tunnel == "")
		||  this.SetOpt(Curl.Opt.HTTPPROXYTUNNEL, !!tunnel)
		
		Return this.lastCode
	}
	
	
	SetProxyCredentials(user, pass, proxyAuth := "") {
		stopAtNonZero := 0
		||  this.SetOpt(Curl.Opt.PROXYUSERNAME, user)
		||  this.SetOpt(Curl.Opt.PROXYPASSWORD, pass)
		||  (proxyAuth == "")
		||  this.SetOpt(Curl.Opt.PROXYAUTH, Curl._GetAuthCode(proxyAuth))
		
		Return this.lastCode
	}
	
	
	; Sets custom HTTP headers for request.
	; Pass an array of "Header: value" strings.
	; Use empty value ("Header: ") to disable internally used header.
	; Use semicolon ("Header;") to add the header with no value.
	SetHeaders(headers) {
		Return this.SetOpt(Curl.Opt.HTTPHEADER, headers)
	}
	
	; Related options:  Curl.Opt.HEADEROPT,  Curl.Opt.UNRESTRICTED_AUTH
	SetProxyHeaders(headers) {
		Return this.SetOpt(Curl.Opt.PROXYHEADER, headers)
	}
	
	SetUserAgent(useragent) {
		Return this.SetOpt(Curl.Opt.USERAGENT, useragent)
	}
	
	SetReferer(referer) {
		Return this.SetOpt(Curl.Opt.REFERER, referer)
	}
	
	; Sets cookie HTTP header.
	; See also .SetCookieFile, .SetCookieJar, Curl.Opt.COOKIELIST, Curl.Opt.COOKIESESSION
	SetCookie(cookie) {
		Return this.SetOpt(Curl.Opt.COOKIE, cookie)
	}
	
	
	; Set maximum allowed number of redirects, -1 = unlimited
	SetRedirects(redirects, autoReferer := "") {
		stopAtNonZero := 0
		||  this.SetOpt(Curl.Opt.FOLLOWLOCATION, (redirects != 0))
		||  (redirects == 0)
		||  this.SetOpt(Curl.Opt.MAXREDIRS, redirects)
		||  (autoReferer == "")
		||  this.SetOpt(Curl.Opt.AUTOREFERER, !!autoReferer)
		
		Return this.lastCode
	}
	
	
	; Empty string will enable the cookie engine
	SetCookieFile(filename) {
		Return this.SetOpt(Curl.Opt.COOKIEFILE, filename)
	}
	
	SetCookieJar(filename) {
		Return this.SetOpt(Curl.Opt.COOKIEJAR, filename)
	}
	
	
	SetPostForm(formObject) {
		formString := ""
		
		For key, value In formObject {
			formString .= Format("{1}={2}&"
			,  Curl.EscapeStr(key)
			,  Curl.EscapeStr(value) )
		}
		
		formString := SubStr(formString, 1, -1)  ; Trim last '&'
		
		this.SetOpt(Curl.Opt.COPYPOSTFIELDS, formString, "AStr")
	}
	
	
	SetPostData(dataPtr, dataSize) {
		this.SetOpt(Curl.Opt.POSTFIELDSIZE, dataSize)
		this.SetOpt(Curl.Opt.COPYPOSTFIELDS, dataPtr)
	}
	
	
	SetPostMime(mimeObject) {
		If (IsObject(mimeObject))
			mimeObject := Curl.ArrayToMime(mimeObject)
		
		this.SetOpt(Curl.Opt.MIMEPOST, mimeObject)
		
		Return mimeObject
	}
	
	
	
	; Converts array of objects representing mime-parts to mime structure.
	; It is used to work with MIMEPOST and 'multipart/formdata'.
	; Example mime-part object: {
	;   {   name     : "partName"
	;     , type     : "text/plain"
	;     , filename : "saveAsThis.txt"
	;     , filedata : "localFile.txt"
	;     , encoder  : "base64"
	;     , dataPtr  : &myBinaryVar
	;     , dataSize : 1024
	;     , headers  : ["Custom-Head: mooo"]
	;     , subparts : [...array of mime-parts...]
	;   }
	; All properties are optional, only existing properties will be used for created mime-part.
	; If error will occur at any stage, mime structure will be erased.
	; It is user's duty to FreeMime after usage.
	
	ArrayToMime( pArray, cHandle := "" ) {
		If (cHandle == "")
			cHandle := this._handle
		
		rootPtr := DllCall(Curl.dllFilename . "\curl_mime_init",  "Ptr", cHandle,  "CDecl Ptr")
		If (rootPtr == 0)
			Return 0
		
		Loop % pArray.Length() {
			part := pArray[A_Index]
			
			If (IsObject(part) == 0)
				Continue
			
			partPtr := DllCall(Curl.dllFilename . "\curl_mime_addpart",  "Ptr", rootPtr,  "CDecl Ptr")
			
			If (partPtr == 0) {
				DllCall(Curl.dllFilename . "\curl_mime_free",  "Ptr", rootPtr,  "CDecl")
				Return 0
			}
			
			setSuccess := 0  ; If anything but zero at the end - error has occured.
			
			If (part.HasKey("name"))
				setSuccess += DllCall(Curl.dllFilename . "\curl_mime_name"
				,  "Ptr" , partPtr
				,  "AStr", part.name
				,  "CDecl Int")
			
			If (part.HasKey("type"))
				setSuccess += DllCall(Curl.dllFilename . "\curl_mime_type"
				,  "Ptr" , partPtr
				,  "AStr", part.type
				,  "CDecl Int")
			
			If (part.HasKey("filedata"))
				setSuccess += DllCall(Curl.dllFilename . "\curl_mime_filedata"
				,  "Ptr" , partPtr
				,  "AStr", part.filedata
				,  "CDecl Int")
			
			If (part.HasKey("filename"))
				setSuccess += DllCall(Curl.dllFilename . "\curl_mime_filename"
				,  "Ptr", partPtr
				,  "AStr", part.filename
				,  "CDecl Int")
			
			If (part.HasKey("encoder"))
				setSuccess += DllCall(Curl.dllFilename . "\curl_mime_encoder"
				,  "Ptr" , partPtr
				,  "AStr", part.encoder
				,  "CDecl Int")
			
			If (part.HasKey("dataptr")
			&&  part.HasKey("datasize")) {
				setSuccess += DllCall(Curl.dllFilename . "\curl_mime_data"
				  ,  "Ptr" , partPtr
				  ,  "Ptr" , part.dataptr
				  ,  "UInt", part.datasize
				  ,  "CDecl Int")
			}
			
			If (part.HasKey("headers")) {
				If (IsObject(part.headers)) {
					slHeaders := Curl._ArrayToSList(part.headers)
				} Else {  ; Assume pointer to already created list
					slHeaders := part.headers
				}
				
				setSuccess += DllCall(Curl.dllFilename . "\curl_mime_headers"
				  ,  "Ptr", partPtr
				  ,  "Ptr", slHeaders
				  ,  "Int", 1  ; Own this list, it will be removed with this mime.
				  ,  "CDecl Int")
				
				this._usedLists[partPtr . "_header"] := slHeaders
			}
			
			If (part.HasKey("subparts"))
			&& (IsObject(part.subparts))
			&& (part.subparts.Length() >= 1)
			{
				mimeSubparts := Curl.ArrayToMime(part.subparts)
				setSuccess += DllCall(Curl.dllFilename . "\curl_mime_subparts"
				,  "Ptr", partPtr
				,  "Ptr", mimeSubparts
				,  "CDecl Int")
			}
			
			If (setSuccess != 0) {
				Curl.FreeMime(rootPtr)
				Return 0
			}
		}
		
		Return rootPtr
	}
	
	
	FreeMime( mimeHandle ) {
		DllCall(Curl.dllFilename . "\curl_mime_free",  "Ptr", mimeHandle,  "CDecl")
	}
	
	
	
	; Linked-list
	; ===========
	
	; Converts an array of strings to linked-list.
	; Returns pointer to linked-list, or 0 if something went wrong.
	
	_ArrayToSList(strArray) {
		ptrSList := 0
		ptrTemp  := 0
		
		Loop % strArray.Length() {
			ptrTemp := DllCall(Curl.dllFilename . "\curl_slist_append"
			, "Ptr" , ptrSList
			, "AStr", strArray[A_Index]
			, "CDecl Ptr")
			
			If (ptrTemp == 0) {
				Curl._FreeSList(ptrSList)
				Return 0
			}
			
			ptrSList := ptrTemp
		}
		
		Return ptrSList
	}
	
	
	; Converts linked-list to an array of strings.
	
	_SListToArray(ptrSList) {
		result  := []
		ptrNext := ptrSList
		
		Loop {
			If (ptrNext == 0)
				Break
			
			ptrData := NumGet(ptrNext, 0, "Ptr")
			ptrNext := NumGet(ptrNext, A_PtrSize, "Ptr")
			
			result.Push(StrGet(ptrData, "CP0"))
		}
		
		Return result
	}
	
	
	_FreeSList(ptrSList) {
		If ((ptrSList == "") || (ptrSList == 0))
			Return
		
		DllCall(Curl.dllFilename . "\curl_slist_free_all", "Ptr", ptrSList, "CDecl")
	}
	
	
	
	; Interfaces to store input/output data
	
	Class Storage {
		
		; Wrapper for file. Shouldn't be used directly.
		Class File {
			__New(filename, accessMode := "w") {
				this._filename   := filename
				this._accessMode := accessMode
				this._fileObject := ""
			}
			
			Open() {
				If (this._accessMode == "w") {
					RegexMatch(this._filename, "^.+(?=[\\\/])", fileDirPath)
					If (fileDirPath)
						FileCreateDir % fileDirPath
					
					this._fileObject := FileOpen(this._filename, this._accessMode, "CP0")
				}
			}
			
			Close() {
				this._fileObject.Close()
			}
			
			Write(data) {
				If (this._fileObject == "")
					Return -1
				
				Return this._fileObject.Write(data)
			}
			
			RawWrite(srcDataPtr, srcDataSize) {
				If (this._fileObject == "")
				|| (this._accessMode != "w")
					Return -1
				
				Return this._fileObject.RawWrite(srcDataPtr+0, srcDataSize)
			}
			
			RawRead(dstDataPtr, dstDataSize) {
				If (this._fileObject == "")
				|| (this._accessMode != "r")
					Return -1
				
				Return this._fileObject.RawRead(dstDataPtr+0, dstDataSize)
			}
			
			Seek(offset, origin := 0) {
				Return !(this._fileObject.Seek(offset, origin))
			}
		}
		
		; Wrapper for memory buffer, similar to regular FileObject
		Class MemBuffer {
			__New(dataPtr := 0, maxCapacity := 0, dataSize := 0) {
				this._data     := ""
				this._dataPos  := 0
				
				maxCapacity := Max(maxCapacity, dataSize)
				
				If (maxCapacity == 0)
					maxCapacity := 8*1024*1024  ; 8 Mb
				
				If (dataPtr != 0) {
					this._dataMax  := maxCapacity
					this._dataSize := dataSize
					this._dataPtr  := dataPtr
				} Else
				; No argument, store inside class.
				{
					this._dataSize := 0
					this._dataMax  := ObjSetCapacity(this, "_data", maxCapacity)
					this._dataPtr  := ObjGetAddress(this, "_data")
				}
			}
			
			Open() {
				; Do nothing
			}
			
			Close() {
				this.Seek(0,0)
			}
			
			Write(data) {
				srcDataSize := StrPut(srcText, "CP0")
				
				If ((this._dataPos + srcDataSize) > this._dataMax)
					Return -1
				
				StrPut(data, this._dataPtr + this._dataPos, "CP0")
				
				this._dataPos  += srcDataSize
				this._dataSize := Max(this._dataSize, this._dataPos)
				
				Return srcDataSize
			}
			
			RawWrite(srcDataPtr, srcDataSize) {
				If ((this._dataPos + srcDataSize) > this._dataMax)
					Return -1
				
				DllCall("ntdll\memcpy"
				, "Ptr" , this._dataPtr + this._dataPos
				, "Ptr" , srcDataPtr+0
				, "Int" , srcDataSize)
				
				this._dataPos  += srcDataSize
				this._dataSize := Max(this._dataSize, this._dataPos)
				
				Return srcDataSize
			}
			
			GetAsText(encoding := "UTF-8") {
				isEncodingWide := ((encoding = "UTF-16") || (encoding = "CP1200"))
				textMaxLength  := this._dataSize / (isEncodingWide ? 2 : 1)
				Return StrGet(this._dataPtr, textMaxLength, encoding)
			}
			
			RawRead(dstDataPtr, dstDataSize) {
				dataLeft := this._dataSize - this._dataPos
				dstDataSize := Min(dstDataSize, dataLeft)
				
				DllCall("ntdll\memcpy"
				, "Ptr" , dstDataPtr
				, "Ptr" , this._dataPtr + this._dataPos
				, "Int" , dstDataSize)
				
				Return dstDataSize
			}
			
			Seek(offset, origin := 0) {
				newDataPos := offset
				+ ( (origin == 0) ? 0               ; SEEK_SET
				  : (origin == 1) ? this._dataPos   ; SEEK_CUR
				  : (origin == 2) ? this._dataSize  ; SEEK_END
				  : 0 )                             ; Unknown 'origin', use SEEK_SET
				
				If (newDataPos > this._dataSize)
				|| (newDataPos < 0)
					Return 1  ; CURL_SEEKFUNC_FAIL
				
				this._dataPos := newDataPos
				Return 0  ; CURL_SEEKFUNC_OK
			}
			
			Tell() {
				Return this._dataPos
			}
			
			Length() {
				Return this._dataSize
			}
		}
	}
	
	
	
	; Enumerations
	; ============
	
	; Options used by SetOpt.
	; 
	; A set of functions was added in libcurl 7.73:
	; - curl_easyoption *curl_easy_option_by_id(CURLoption id);
	; - curl_easyoption *curl_easy_option_by_name(const char *name);
	; - curl_easyoption *curl_easy_option_next(const struct curl_easyoption *prev);
	; These can simplify things greatly, but it's too early to implement, I think.
	
	Class Opt {
		Static _initialized := False
		
		Init() {
			If (this._initialized == True)
				Return
			
			AHK_ARG := 100000  ; To auto-determine argument type, see .SetOpt
			
			LONG :=     0 + AHK_ARG * 1  ; Long
			OBJP := 10000 + AHK_ARG * 2  ; Object pointer
			STRP := 10000 + AHK_ARG * 3  ; String pointer
			SLIP := 10000 + AHK_ARG * 4  ; Linked-list pointer
			FUNP := 20000 + AHK_ARG * 5  ; Function pointer
			OFFT := 30000 + AHK_ARG * 6  ; Curl_off_t (Int64)
			BLOB := 40000 + AHK_ARG * 7  ; Blob struct pointer
			
			CBPT := OBJP                 ; Argument pointer passed to callback
			BITS := LONG                 ; Long argument with a set of values/bitmask
			
			; List of options
			;   OPT_Name   - As in CURLOPT_<Name>
			;   Type       - Required argument type
			;   Index      - Option's numeric index
			;   Category   - Category tag, as seen in 'curl_easy_setopt' man
			;   Available  - Latest version when option was changed:
			;     Always - Option was available since the big bang
			;     7.0.0  - Option was added or last modified in this version
			;     R      - Option was renamed in this version
			;     ~      - Option was changed in some way in this version
			;     /      - Option was deprecated in this version
			;     !      - Option may not be supported on your platform
			;     B      - Apart from version, there is also Build requirements (see below)
			;     H      - Apart from version, there is also built HTTP support required
			;     Build  - Libcurl (or SSL backend) must be built in certain way for option to work
			;     HTTP   - Libcurl must be built with HTTP support
			
			; OPT_Name                            Type  Index  Category Available  Description  (Affected protocols)
			; ===============================     ====  =====  ======== =========  =================================
			this["WRITEDATA"]                  := CBPT +   1  ; [CLBK]  7.9.7  R   Data pointer to pass to the write callback
			this["URL"]                        := STRP +   2  ; [NET ]  7.31.0 ~   URL to work on
			this["PORT"]                       := LONG +   3  ; [NET ]  Always     Port number to connect to  (Most)
			this["PROXY"]                      := STRP +   4  ; [NET ]  7.50.2 ~   Proxy to use  (All but file)
			this["USERPWD"]                    := STRP +   5  ; [AUTH]  Always     User name and password  (Most)
			this["PROXYUSERPWD"]               := STRP +   6  ; [AUTH]  Always     Proxy user name and password  (Most)
			this["RANGE"]                      := STRP +   7  ; [PROT]  7.20.0     Range requests  (HTTP, FTP, FILE, RTSP, SFTP)
			this["READDATA"]                   := CBPT +   9  ; [CLBK]  7.9.7  R   Data pointer to pass to the read callback
			this["ERRORBUFFER"]                := OBJP +  10  ; [ERR ]  Always     Error message buffer
			this["WRITEFUNCTION"]              := FUNP +  11  ; [CLBK]  7.18.0 ~   Callback for writing data
			this["READFUNCTION"]               := FUNP +  12  ; [CLBK]  7.18.0 ~   Callback for reading data
			this["TIMEOUT"]                    := LONG +  13  ; [CONN]  Always     Timeout for the entire request
			this["INFILESIZE"]                 := LONG +  14  ; [PROT]  7.23.0 ~   Size of file to send  (Many)
			this["POSTFIELDS"]                 := OBJP +  15  ; [HTTP]  Always     Send a POST with this data  (HTTP)
			this["REFERER"]                    := STRP +  16  ; [HTTP]  HTTP       Referer: header  (HTTP)
			this["FTPPORT"]                    := STRP +  17  ; [FTP ]  7.19.5 ~   Use active FTP  (FTP)
			this["USERAGENT"]                  := STRP +  18  ; [HTTP]  HTTP       User-Agent: header  (HTTP(S))
			this["LOW_SPEED_LIMIT"]            := LONG +  19  ; [CONN]  Always     Low speed limit to abort transfer
			this["LOW_SPEED_TIME"]             := LONG +  20  ; [CONN]  Always     Time to be below the speed to trigger low speed abort
			this["RESUME_FROM"]                := LONG +  21  ; [PROT]  Always     Resume a transfer  (HTTP, FTP, SFTP, FILE)
			this["COOKIE"]                     := STRP +  22  ; [HTTP]  HTTP       Cookie(s) to send
			this["HTTPHEADER"]                 := SLIP +  23  ; [HTTP]  HTTP       Custom HTTP headers
			this["HTTPPOST"]                   := OBJP +  24  ; [HTTP]  7.56.0 /   DEPRECATED, use MIMEPOST. Multipart formpost HTTP POST
			this["SSLCERT"]                    := STRP +  25  ; [SSL ]  Build      Client cert  (TLS-based)
			this["KEYPASSWD"]                  := STRP +  26  ; [SSL ]  7.16.4 R   Client key password  (TLS-based)
			this["CRLF"]                       := LONG +  27  ; [PROT]  7.40.0 ~   Convert newlines
			this["QUOTE"]                      := SLIP +  28  ; [FTP ]  7.24.0     Commands to run before transfer  (SFTP and FTP)
			this["HEADERDATA"]                 := CBPT +  29  ; [CLBK]  Always     Data pointer to pass to the header callback
			this["COOKIEFILE"]                 := STRP +  31  ; [HTTP]  HTTP       File to read cookies from
			this["SSLVERSION"]                 := BITS +  32  ; [SSL ]  7.39.0 ~   SSL version to use  (TLS-based)
			this["TIMECONDITION"]              := BITS +  33  ; [PROT]  Always     Make a time conditional request  (HTTP, FTP, RTSP, FILE)
			this["TIMEVALUE"]                  := LONG +  34  ; [PROT]  Always     Time value for the time conditional request  (HTTP, FTP, RTSP, FILE)
			this["CUSTOMREQUEST"]              := STRP +  36  ; [PROT]  7.34.0 ~   Custom request/method  (HTTP, FTP, IMAP, POP3 and SMTP)
			this["STDERR"]                     := OBJP +  37  ; [ERR ]  Always     stderr replacement stream
			this["POSTQUOTE"]                  := SLIP +  39  ; [FTP ]  Build      Commands to run after transfer  (FTP, SFTP)
			this["VERBOSE"]                    := LONG +  41  ; [BHVR]  Always     Display verbose information
			this["HEADER"]                     := LONG +  42  ; [BHVR]             Include the header in the body output  (Most)
			this["NOPROGRESS"]                 := LONG +  43  ; [BHVR]  Always     Shut off the progress meter
			this["NOBODY"]                     := LONG +  44  ; [PROT]  Always     Do not get the body contents  (Most)
			this["FAILONERROR"]                := LONG +  45  ; [ERR ]  HTTP       Fail on HTTP 4xx errors  (HTTP)
			this["UPLOAD"]                     := LONG +  46  ; [PROT]  Always     Upload data  (Most)
			this["POST"]                       := LONG +  47  ; [HTTP]  HTTP       Issue an HTTP POST request  (HTTP)
			this["DIRLISTONLY"]                := LONG +  48  ; [PROT]  7.21.5 ~   List only  (FTP, SFTP and POP3)
			this["APPEND"]                     := LONG +  50  ; [FTP ]  7.16.4 R   Append to remote file  (FTP)
			this["NETRC"]                      := BITS +  51  ; [AUTH]  Always     Enable .netrc parsing  (Most)
			this["FOLLOWLOCATION"]             := LONG +  52  ; [HTTP]  HTTP       Follow HTTP redirects  (HTTP(S))
			this["TRANSFERTEXT"]               := LONG +  53  ; [PROT]  FTP        Use text transfer  (FTP)
			this["PUT"]                        := LONG +  54  ; [HTTP]  7.12.1 /   DEPRECATED, use UPLOAD. Issue an HTTP PUT request  (HTTP)
			this["PROGRESSFUNCTION"]           := FUNP +  56  ; [CLBK]  Always     OBSOLETE callback for progress meter
			this["XFERINFODATA"]               := CBPT +  57  ; [CLBK]  7.32.0     Data pointer to pass to the progress meter callback
			this["PROGRESSDATA"]               := CBPT +  57  ; [CLBK]  7.32.0     Data pointer to pass to the progress meter callback
			this["AUTOREFERER"]                := LONG +  58  ; [HTTP]  HTTP       Automatically set Referer: header  (HTTP)
			this["PROXYPORT"]                  := LONG +  59  ; [NET ]  Always     Proxy port to use
			this["POSTFIELDSIZE"]              := LONG +  60  ; [HTTP]  HTTP       The POST data is this big  (HTTP)
			this["HTTPPROXYTUNNEL"]            := LONG +  61  ; [NET ]  Always     Tunnel through the HTTP proxy  (All network protocols)
			this["INTERFACE"]                  := STRP +  62  ; [NET ]  7.24.0 ~   Bind connection locally to this
			this["KRBLEVEL"]                   := STRP +  63  ; [SSL ]  7.16.3 R   Kerberos security level  (FTP)
			this["SSL_VERIFYPEER"]             := LONG +  64  ; [SSL ]  Build      Verify the SSL certificate  (TLS-based)
			this["CAINFO"]                     := STRP +  65  ; [SSL ]  7.60.0 ~   CA cert bundle  (TLS-based)
			this["MAXREDIRS"]                  := LONG +  68  ; [HTTP]  HTTP       Maximum number of redirects to follow  (HTTP(S))
			this["FILETIME"]                   := LONG +  69  ; [PROT]  7.49.0 ~   Request file modification date and time  (HTTP, FTP, SFTP, FILE)
			this["TELNETOPTIONS"]              := SLIP +  70  ; [MISC]  Telnet     TELNET options  (TELNET)
			this["MAXCONNECTS"]                := LONG +  71  ; [CONN]  Always     Maximum number of connections in the connection pool  (Most)
			this["FRESH_CONNECT"]              := LONG +  74  ; [CONN]  Always     Use a new connection  (Most)
			this["FORBID_REUSE"]               := LONG +  75  ; [CONN]  Always     Prevent subsequent connections from re-using this  (Most)
			this["RANDOM_FILE"]                := STRP +  76  ; [SSL ]  Always     Provide source for entropy random data
			this["EGDSOCKET"]                  := STRP +  77  ; [SSL ]  Build      Identify EGD socket for entropy  (TLS-based)
			this["CONNECTTIMEOUT"]             := LONG +  78  ; [CONN]  Always     Timeout for the connection phase
			this["HEADERFUNCTION"]             := FUNP +  79  ; [CLBK]  Always     Callback for writing received headers  (HTTP, FTP, POP3, IMAP and more)
			this["HTTPGET"]                    := LONG +  80  ; [HTTP]  HTTP       Do an HTTP GET request  (HTTP(S))
			this["SSL_VERIFYHOST"]             := LONG +  81  ; [SSL ]  Build      Verify the host name in the SSL certificate  (TLS-based)
			this["COOKIEJAR"]                  := STRP +  82  ; [HTTP]  HTTP       File to write cookies to
			this["SSL_CIPHER_LIST"]            := STRP +  83  ; [SSL ]  Build      Ciphers to use  (TLS-based)
			this["HTTP_VERSION"]               := BITS +  84  ; [HTTP]  HTTP       HTTP version to use  (HTTP)
			this["FTP_USE_EPSV"]               := LONG +  85  ; [FTP ]  FTP        Use EPSV  (FTP)
			this["SSLCERTTYPE"]                := STRP +  86  ; [SSL ]  7.9.3  B   Client cert type  (TLS-based)
			this["SSLKEY"]                     := STRP +  87  ; [SSL ]  Build      Client key  (TLS-based)
			this["SSLKEYTYPE"]                 := STRP +  88  ; [SSL ]  Build      Client key type  (TLS-based)
			this["SSLENGINE"]                  := STRP +  89  ; [SSL ]  Build      Use identifier with SSL engine  (TLS-based)
			this["SSLENGINE_DEFAULT"]          := LONG +  90  ; [SSL ]  Build      Default SSL engine  (TLS-based)
			this["DNS_CACHE_TIMEOUT"]          := LONG +  92  ; [NET ]  Always     Timeout for DNS cache
			this["PREQUOTE"]                   := SLIP +  93  ; [FTP ]  Build      Commands to run just before transfer  (FTP)
			this["DEBUGFUNCTION"]              := FUNP +  94  ; [CLBK]  Always     Callback for debug information
			this["DEBUGDATA"]                  := CBPT +  95  ; [CLBK]  Always     Data pointer to pass to the debug callback
			this["COOKIESESSION"]              := LONG +  96  ; [HTTP]  HTTP       Start a new cookie session
			this["CAPATH"]                     := STRP +  97  ; [SSL ]  7.56.0     Path to CA cert bundle  (TLS-based)
			this["BUFFERSIZE"]                 := LONG +  98  ; [NET ]  7.53.0 ~   Ask for alternate buffer size
			this["NOSIGNAL"]                   := LONG +  99  ; [BHVR]  7.10       Do not install signal handlers
			this["SHARE"]                      := OBJP + 100  ; [MISC]  Always     Share object to use
			this["PROXYTYPE"]                  := BITS + 101  ; [NET ]  Always     Proxy type  (Most)
			this["ACCEPT_ENCODING"]            := STRP + 102  ; [HTTP]             Accept-Encoding and automatic decompressing data  (HTTP)
			this["PRIVATE"]                    := OBJP + 103  ; [MISC]  7.10.3     Private pointer to store
			this["HTTP200ALIASES"]             := SLIP + 104  ; [HTTP]  7.10.3     Alternative versions of 200 OK
			this["UNRESTRICTED_AUTH"]          := LONG + 105  ; [HTTP]  HTTP       Do not restrict authentication to original host  (HTTP)
			this["FTP_USE_EPRT"]               := LONG + 106  ; [FTP ]  7.10.5     Use EPTR
			this["HTTPAUTH"]                   := BITS + 107  ; [AUTH]             HTTP server authentication methods
			this["SSL_CTX_FUNCTION"]           := FUNP + 108  ; [CLBK]  7.54.0     Callback for SSL context logic  (TLS-based)
			this["SSL_CTX_DATA"]               := CBPT + 109  ; [CLBK]  7.54.0     Data pointer to pass to the SSL context callback  (TLS-based)
			this["FTP_CREATE_MISSING_DIRS"]    := LONG + 110  ; [FTP ]  7.19.4     Create missing directories on the remote server  (FTP and SFTP)
			this["PROXYAUTH"]                  := BITS + 111  ; [AUTH]  7.10.7     HTTP proxy authentication methods  (HTTP)
			this["FTP_RESPONSE_TIMEOUT"]       := LONG + 112  ; [FTP ]  7.10.8     Timeout for FTP responses  (FTP)
			this["IPRESOLVE"]                  := BITS + 113  ; [CONN]  Always     IP version to resolve to
			this["MAXFILESIZE"]                := LONG + 114  ; [PROT]  Always     Maximum file size to get  (HTTP, FTP)
			this["INFILESIZE_LARGE"]           := OFFT + 115  ; [PROT]  7.23.0 ~   Size of file to send  (Many)
			this["RESUME_FROM_LARGE"]          := OFFT + 116  ; [PROT]  7.11.0     Resume a transfer  (HTTP, FTP, SFTP, FILE)
			this["MAXFILESIZE_LARGE"]          := OFFT + 117  ; [PROT]  7.11.0     Maximum file size to get  (HTTP, FTP)
			this["NETRC_FILE"]                 := STRP + 118  ; [AUTH]  7.10.9     .netrc file name
			this["USE_SSL"]                    := BITS + 119  ; [CONN]  7.16.4 R   Use TLS/SSL  (FTP, SMTP, POP3, IMAP)
			this["POSTFIELDSIZE_LARGE"]        := OFFT + 120  ; [HTTP]  HTTP       The POST data is this big  (HTTP(S))
			this["TCP_NODELAY"]                := LONG + 121  ; [NET ]  7.50.2 ~   Disable the Nagle algorithm
			this["FTPSSLAUTH"]                 := BITS + 129  ; [FTP ]  7.12.2     Control how to do TLS  (FTP)
			this["IOCTLFUNCTION"]              := FUNP + 130  ; [CLBK]  7.12.3     DEPRECATED, use SEEKFUNCTION. Callback for I/O operations  (HTTP)
			this["IOCTLDATA"]                  := CBPT + 131  ; [CLBK]  7.12.3     Data pointer to pass to the I/O callback  (HTTP)
			this["FTP_ACCOUNT"]                := STRP + 134  ; [FTP ]  7.13.0     Send ACCT command  (FTP)
			this["COOKIELIST"]                 := STRP + 135  ; [HTTP]             Add or control cookies
			this["IGNORE_CONTENT_LENGTH"]      := LONG + 136  ; [HTTP]  7.46.0 ~   Ignore Content-Length  (HTTP)
			this["FTP_SKIP_PASV_IP"]           := LONG + 137  ; [FTP ]  7.14.2     Ignore the IP address in the PASV response  (FTP)
			this["FTP_FILEMETHOD"]             := BITS + 138  ; [FTP ]  7.15.1     Specify how to reach files  (FTP)
			this["LOCALPORT"]                  := LONG + 139  ; [NET ]  7.15.2     Bind connection locally to this port
			this["LOCALPORTRANGE"]             := LONG + 140  ; [NET ]  7.15.2     Bind connection locally to port range
			this["CONNECT_ONLY"]               := LONG + 141  ; [CONN]  7.15.2     Only connect, nothing else  (HTTP, SMTP, POP3 and IMAP)
			this["CONV_FROM_NETWORK_FUNCTION"] := FUNP + 142  ; [CLBK]  Build      Callback for code base conversion  (FTP, SMTP, IMAP, POP3)
			this["CONV_TO_NETWORK_FUNCTION"]   := FUNP + 143  ; [CLBK]  Build      Callback for code base conversion  (FTP, SMTP, IMAP, POP3)
			this["CONV_FROM_UTF8_FUNCTION"]    := FUNP + 144  ; [CLBK]  Build      Callback for code base conversion  (TLS-based protocols.)
			this["MAX_SEND_SPEED_LARGE"]       := OFFT + 145  ; [CONN]  7.15.5     Cap the upload speed to this  (All but file)
			this["MAX_RECV_SPEED_LARGE"]       := OFFT + 146  ; [CONN]  7.15.5     Cap the download speed to this  (All but file)
			this["FTP_ALTERNATIVE_TO_USER"]    := STRP + 147  ; [FTP ]  7.15.5     Alternative to USER  (FTP)
			this["SOCKOPTFUNCTION"]            := FUNP + 148  ; [CLBK]  7.21.5 ~   Callback for sockopt operations
			this["SOCKOPTDATA"]                := CBPT + 149  ; [CLBK]  7.16.0     Data pointer to pass to the sockopt callback
			this["SSL_SESSIONID_CACHE"]        := LONG + 150  ; [SSL ]  7.16.0     Disable SSL session-id cache  (TLS-based)
			this["SSH_AUTH_TYPES"]             := BITS + 151  ; [SSH ]  7.28.0     SSH authentication types  (SCP, SFTP)
			this["SSH_PUBLIC_KEYFILE"]         := STRP + 152  ; [SSH ]  7.26.0 ~   File name of public key  (SCP, SFTP)
			this["SSH_PRIVATE_KEYFILE"]        := STRP + 153  ; [SSH ]  7.16.1     File name of private key  (SCP, SFTP)
			this["FTP_SSL_CCC"]                := LONG + 154  ; [FTP ]  7.16.1     Back to non-TLS again after authentication  (FTP)
			this["TIMEOUT_MS"]                 := LONG + 155  ; [CONN]  Always     Millisecond timeout for the entire request
			this["CONNECTTIMEOUT_MS"]          := LONG + 156  ; [CONN]  Always     Millisecond timeout for the connection phase
			this["HTTP_TRANSFER_DECODING"]     := LONG + 157  ; [HTTP]  7.16.2     Disable Transfer decoding
			this["HTTP_CONTENT_DECODING"]      := LONG + 158  ; [HTTP]  7.16.2     Disable Content decoding
			this["NEW_FILE_PERMS"]             := LONG + 159  ; [MISC]  7.16.4     Mode for creating new remote files  (SFTP, SCP, FILE)
			this["NEW_DIRECTORY_PERMS"]        := LONG + 160  ; [MISC]  7.16.4     Mode for creating new remote directories  (SFTP, SCP, FILE)
			this["POSTREDIR"]                  := BITS + 161  ; [HTTP]  7.26.0 ~   How to act on redirects after POST  (HTTP(S))
			this["SSH_HOST_PUBLIC_KEY_MD5"]    := STRP + 162  ; [SSH ]  7.17.1     MD5 of host's public key  (SCP, SFTP)
			this["OPENSOCKETFUNCTION"]         := FUNP + 163  ; [CLBK]  7.17.1     Callback for socket creation
			this["OPENSOCKETDATA"]             := CBPT + 164  ; [CLBK]  7.17.1     Data pointer to pass to the open socket callback
			this["COPYPOSTFIELDS"]             := OBJP + 165  ; [HTTP]  7.17.1     Send a POST with this data - and copy it  (HTTP(S))
			this["PROXY_TRANSFER_MODE"]        := LONG + 166  ; [PROT]  7.18.0     Add transfer mode to URL over proxy  (FTP over proxy)
			this["SEEKFUNCTION"]               := FUNP + 167  ; [CLBK]  7.18.0     Callback for seek operations  (HTTP, FTP, SFTP)
			this["SEEKDATA"]                   := CBPT + 168  ; [CLBK]  7.18.0     Data pointer to pass to the seek callback  (HTTP, FTP, SFTP)
			this["CRLFILE"]                    := STRP + 169  ; [SSL ]  7.19.0     Certificate Revocation List  (TLS-based)
			this["ISSUERCERT"]                 := STRP + 170  ; [SSL ]  Build      Issuer certificate  (TLS-based)
			this["ADDRESS_SCOPE"]              := LONG + 171  ; [NET ]  7.19.0     IPv6 scope for local addresses  (IPv6)
			this["CERTINFO"]                   := LONG + 172  ; [SSL ]  SSL        Extract certificate info  (TLS-based)
			this["USERNAME"]                   := STRP + 173  ; [AUTH]  7.19.1     User name  (Most)
			this["PASSWORD"]                   := STRP + 174  ; [AUTH]  7.19.1     Password  (Most)
			this["PROXYUSERNAME"]              := STRP + 175  ; [AUTH]  7.19.1     Proxy user name  (Most)
			this["PROXYPASSWORD"]              := STRP + 176  ; [AUTH]  7.19.1     Proxy password  (Most)
			this["NOPROXY"]                    := STRP + 177  ; [NET ]  7.19.4     Filter out hosts from proxy use  (Most)
			this["TFTP_BLKSIZE"]               := LONG + 178  ; [TFTP]  7.19.4     TFTP block size  (TFTP)
			this["SOCKS5_GSSAPI_NEC"]          := LONG + 180  ; [NET ]  7.19.4     Socks5 GSSAPI NEC mode  (Most)
			this["PROTOCOLS"]                  := LONG + 181  ; [NET ]  7.19.4     Allowed protocols
			this["REDIR_PROTOCOLS"]            := LONG + 182  ; [NET ]  7.19.4     Protocols to allow redirects to
			this["SSH_KNOWNHOSTS"]             := STRP + 183  ; [SSH ]  7.19.6     File name with known hosts  (SCP, SFTP)
			this["SSH_KEYFUNCTION"]            := FUNP + 184  ; [SSH ]  7.19.6     Callback for known hosts handling  (SCP, SFTP)
			this["SSH_KEYDATA"]                := CBPT + 185  ; [SSH ]  7.19.6     Custom pointer to pass to ssh key callback  (SCP, SFTP)
			this["MAIL_FROM"]                  := STRP + 186  ; [SMTP]  7.20.0     Address of the sender  (SMTP)
			this["MAIL_RCPT"]                  := SLIP + 187  ; [SMTP]  7.34.0     Address of the recipients  (SMTP)
			this["FTP_USE_PRET"]               := LONG + 188  ; [FTP ]  7.20.0     Use PRET  (FTP)
			this["RTSP_REQUEST"]               := BITS + 189  ; [RTSP]  7.20.0     RTSP request  (RTSP)
			this["RTSP_SESSION_ID"]            := STRP + 190  ; [RTSP]  7.20.0     RTSP session-id  (RTSP)
			this["RTSP_STREAM_URI"]            := STRP + 191  ; [RTSP]  7.20.0     RTSP stream URI  (RTSP)
			this["RTSP_TRANSPORT"]             := STRP + 192  ; [RTSP]  7.20.0     RTSP Transport: header  (RTSP)
			this["RTSP_CLIENT_CSEQ"]           := LONG + 193  ; [RTSP]  7.20.0     Client CSEQ number  (RTSP)
			this["RTSP_SERVER_CSEQ"]           := LONG + 194  ; [RTSP]  7.20.0     CSEQ number for RTSP Server->Client request  (RTSP)
			this["INTERLEAVEDATA"]             := CBPT + 195  ; [CLBK]  7.20.0     Data pointer to pass to the RTSP interleave callback  (RTSP)
			this["INTERLEAVEFUNCTION"]         := FUNP + 196  ; [CLBK]  7.20.0     Callback for RTSP interleaved data  (RTSP)
			this["WILDCARDMATCH"]              := LONG + 197  ; [BHVR]  7.21.0     Transfer multiple files according to a file name pattern  (FTP)
			this["CHUNK_BGN_FUNCTION"]         := FUNP + 198  ; [CLBK]  7.21.0     Callback for wildcard download start of chunk  (FTP)
			this["CHUNK_END_FUNCTION"]         := FUNP + 199  ; [CLBK]  7.21.0     Callback for wildcard download end of chunk  (FTP)
			this["FNMATCH_FUNCTION"]           := FUNP + 200  ; [CLBK]  7.21.0     Callback for wildcard matching  (FTP)
			this["CHUNK_DATA"]                 := CBPT + 201  ; [CLBK]  7.21.0     Data pointer to pass to the chunk callbacks  (FTP)
			this["FNMATCH_DATA"]               := CBPT + 202  ; [CLBK]  7.21.0     Data pointer to pass to the wildcard matching callback  (FTP)
			this["RESOLVE"]                    := SLIP + 203  ; [CONN]  7.42.0 ~   Provide fixed/fake name resolves
			this["TLSAUTH_USERNAME"]           := STRP + 204  ; [AUTH]  7.21.4     TLS authentication user name  (TLS-based)
			this["TLSAUTH_PASSWORD"]           := STRP + 205  ; [AUTH]  7.21.4     TLS authentication password  (TLS-based)
			this["TLSAUTH_TYPE"]               := STRP + 206  ; [AUTH]  Build      TLS authentication methods  (TLS-based)
			this["TRANSFER_ENCODING"]          := LONG + 207  ; [HTTP]  7.21.6     Request Transfer-Encoding  (HTTP)
			this["CLOSESOCKETFUNCTION"]        := FUNP + 208  ; [CLBK]  7.21.7     Callback for closing socket
			this["CLOSESOCKETDATA"]            := CBPT + 209  ; [CLBK]  7.21.7     Data pointer to pass to the close socket callback  (All but file)
			this["GSSAPI_DELEGATION"]          := BITS + 210  ; [SSL ]  7.22.0     Disable GSS-API delegation  (HTTP)
			this["DNS_SERVERS"]                := STRP + 211  ; [CONN]  Build      Preferred DNS servers
			this["ACCEPTTIMEOUT_MS"]           := LONG + 212  ; [CONN]  7.24.0     Timeout for waiting for the server's connect back to be accepted  (FTP)
			this["TCP_KEEPALIVE"]              := LONG + 213  ; [NET ]  7.25.0     Enable TCP keep-alive
			this["TCP_KEEPIDLE"]               := LONG + 214  ; [NET ]  7.25.0     Idle time before sending keep-alive
			this["TCP_KEEPINTVL"]              := LONG + 215  ; [NET ]  Always     Interval between keep-alive probes
			this["SSL_OPTIONS"]                := BITS + 216  ; [SSL ]  7.25.0     Control SSL behavior  (TLS-based)
			this["MAIL_AUTH"]                  := STRP + 217  ; [SMTP]  7.25.0     Authentication address  (SMTP)
			this["SASL_IR"]                    := LONG + 218  ; [AUTH]  7.31.0     Enable SASL initial response  (IMAP, POP3 and SMTP)
			this["XFERINFOFUNCTION"]           := FUNP + 219  ; [CLBK]  7.32.0     Callback for progress meter
			this["XOAUTH2_BEARER"]             := STRP + 220  ; [AUTH]  7.33.0     OAuth2 bearer token  (IMAP, POP3, SMTP)
			this["DNS_INTERFACE"]              := STRP + 221  ; [CONN]  7.33.0 B   Bind name resolves to this interface
			this["DNS_LOCAL_IP4"]              := STRP + 222  ; [CONN]  Build      Bind name resolves to this IP4 address
			this["DNS_LOCAL_IP6"]              := STRP + 223  ; [CONN]  Build      Bind name resolves to this IP6 address
			this["LOGIN_OPTIONS"]              := STRP + 224  ; [AUTH]  7.34.0     Login options  (IMAP, POP3, SMTP)
			this["SSL_ENABLE_NPN"]             := LONG + 225  ; [SSL ]  7.36.0     Enable use of NPN  (HTTP)
			this["SSL_ENABLE_ALPN"]            := LONG + 226  ; [SSL ]  7.36.0     Enable use of ALPN  (HTTP)
			this["EXPECT_100_TIMEOUT_MS"]      := LONG + 227  ; [HTTP]  7.36.0     100-continue timeout  (HTTP)
			this["PROXYHEADER"]                := SLIP + 228  ; [HTTP]  7.37.0     Custom HTTP headers sent to proxy  (HTTP)
			this["HEADEROPT"]                  := BITS + 229  ; [HTTP]  7.37.0     Control custom headers  (HTTP)
			this["PINNEDPUBLICKEY"]            := STRP + 230  ; [SSL ]  7.58.1 ~   Set pinned SSL public key  (TLS-based)
			this["UNIX_SOCKET_PATH"]           := STRP + 231  ; [NET ]  7.40.0 !   Path to a Unix domain socket  (All but file)
			this["SSL_VERIFYSTATUS"]           := LONG + 232  ; [SSL ]  7.41.0     Verify the SSL certificate's status  (TLS-based)
			this["SSL_FALSESTART"]             := LONG + 233  ; [SSL ]  7.42.0     Enable TLS False Start  (TLS-based)
			this["PATH_AS_IS"]                 := LONG + 234  ; [NET ]  7.42.0     Disable squashing /../ and /./ sequences in the path
			this["PROXY_SERVICE_NAME"]         := STRP + 235  ; [NET ]  7.49.0     Proxy authentication service name
			this["SERVICE_NAME"]               := STRP + 236  ; [NET ]  7.49.0 ~   Authentication service name  (HTTP, FTP, IMAP, POP, SMTP)
			this["PIPEWAIT"]                   := LONG + 237  ; [HTTP]  7.43.0     Wait on connection to pipeline on it  (HTTP(S))
			this["DEFAULT_PROTOCOL"]           := STRP + 238  ; [NET ]  7.45.0     Default protocol
			this["STREAM_WEIGHT"]              := LONG + 239  ; [HTTP]  7.46.0     Set this HTTP/2 stream's weight  (HTTP/2)
			this["STREAM_DEPENDS"]             := OBJP + 240  ; [HTTP]  7.46.0     This HTTP/2 stream depends on another  (HTTP/2)
			this["STREAM_DEPENDS_E"]           := OBJP + 241  ; [HTTP]  7.46.0     This HTTP/2 stream depends on another exclusively  (HTTP/2)
			this["TFTP_NO_OPTIONS"]            := LONG + 242  ; [TFTP]  7.48.0     Do not send TFTP options requests  (TFTP)
			this["CONNECT_TO"]                 := SLIP + 243  ; [NET ]  7.49.0     Connect to a specific host and port
			this["TCP_FASTOPEN"]               := LONG + 244  ; [NET ]  7.49.0 !   Enable TFO, TCP Fast Open
			this["KEEP_SENDING_ON_ERROR"]      := LONG + 245  ; [ERR ]  7.51.0 H   Keep sending on HTTP >= 300 errors  (HTTP)
			this["PROXY_CAINFO"]               := STRP + 246  ; [SSL ]  7.52.0     Proxy CA cert bundle  (HTTPS-proxy)
			this["PROXY_CAPATH"]               := STRP + 247  ; [SSL ]  7.56.0 ~   Path to proxy CA cert bundle  (All over HTTPS-proxy)
			this["PROXY_SSL_VERIFYPEER"]       := LONG + 248  ; [SSL ]  7.52.0 B   Verify the proxy SSL certificate
			this["PROXY_SSL_VERIFYHOST"]       := LONG + 249  ; [SSL ]  7.52.0 B   Verify the host name in the proxy SSL certificate  (All over HTTPS-proxy.)
			this["PROXY_SSLVERSION"]           := BITS + 250  ; [SSL ]  7.52.0     Proxy SSL version to use
			this["PROXY_TLSAUTH_USERNAME"]     := STRP + 251  ; [AUTH]  7.52.0     Proxy TLS authentication user name
			this["PROXY_TLSAUTH_PASSWORD"]     := STRP + 252  ; [AUTH]  7.52.0     Proxy TLS authentication password
			this["PROXY_TLSAUTH_TYPE"]         := STRP + 253  ; [AUTH]  7.52.0 B   Proxy TLS authentication methods
			this["PROXY_SSLCERT"]              := STRP + 254  ; [SSL ]  7.52.0     Proxy client cert  (HTTPS-proxy)
			this["PROXY_SSLCERTTYPE"]          := STRP + 255  ; [SSL ]  7.52.0 B   Proxy client cert type
			this["PROXY_SSLKEY"]               := STRP + 256  ; [SSL ]  7.52.0 B   Proxy client key
			this["PROXY_SSLKEYTYPE"]           := STRP + 257  ; [SSL ]  7.52.0     Proxy client key type  (HTTPS-proxy)
			this["PROXY_KEYPASSWD"]            := STRP + 258  ; [SSL ]  7.52.0     Proxy client key password  (HTTPS-proxy)
			this["PROXY_SSL_CIPHER_LIST"]      := STRP + 259  ; [SSL ]  7.52.0 B   Proxy ciphers to use
			this["PROXY_CRLFILE"]              := STRP + 260  ; [SSL ]  7.52.0     Proxy Certificate Revocation List  (HTTPS-proxy)
			this["PROXY_SSL_OPTIONS"]          := LONG + 261  ; [SSL ]  7.52.0     Control proxy SSL behavior  (TLS-based)
			this["PRE_PROXY"]                  := STRP + 262  ; [NET ]  7.52.0     Socks proxy to use  (All but file)
			this["PROXY_PINNEDPUBLICKEY"]      := STRP + 263  ; [SSL ]  7.52.0 B   Set the proxy's pinned SSL public key  (TLS-based)
			this["ABSTRACT_UNIX_SOCKET"]       := STRP + 264  ; [NET ]  7.53.0 !   Path to an abstract Unix domain socket
			this["SUPPRESS_CONNECT_HEADERS"]   := LONG + 265  ; [CLBK]  7.54.0     Suppress proxy CONNECT response headers from user callbacks
			this["REQUEST_TARGET"]             := STRP + 266  ; [HTTP]  7.55.0     Set the request target  (HTTP)
			this["SOCKS5_AUTH"]                := BITS + 267  ; [NET ]  7.55.0     Socks5 authentication methods
			this["SSH_COMPRESSION"]            := LONG + 268  ; [SSH ]  7.56.0     Enable SSH compression  (SCP, SFTP)
			this["MIMEPOST"]                   := OBJP + 269  ; [PROT]  7.56.0     Post/send MIME data  (HTTP, SMTP, IMAP)
			this["TIMEVALUE_LARGE"]            := OFFT + 270  ; [PROT]  7.59.0     Time value for the time conditional request  (HTTP, FTP, RTSP, FILE)
			this["HAPPY_EYEBALLS_TIMEOUT_MS"]  := LONG + 271  ; [CONN]  7.59.0     Timeout for happy eyeballs
			this["RESOLVER_START_FUNCTION"]    := FUNP + 272  ; [CLBK]  7.59.0     Callback to be called before a new resolve request is started
			this["RESOLVER_START_DATA"]        := CBPT + 273  ; [CLBK]  7.59.0     Data pointer to pass to resolver start callback
			this["HAPROXYPROTOCOL"]            := LONG + 274  ; [NET ]  7.60.0 H   Send an HAProxy PROXY protocol v1 header
			this["DNS_SHUFFLE_ADDRESSES"]      := LONG + 275  ; [CONN]  7.60.0     Shuffle addresses before use
			this["TLS13_CIPHERS"]              := STRP + 276  ; [SSL ]  7.61.0     TLS 1.3 cipher suites to use  (TLS-based)
			this["PROXY_TLS13_CIPHERS"]        := STRP + 277  ; [SSL ]  7.61.0     Proxy TLS 1.3 cipher suites to use  (TLS-based)
			this["DISALLOW_USERNAME_IN_URL"]   := LONG + 278  ; [AUTH]  7.61.0     Don't allow username in URL  (Several)
			this["DOH_URL"]                    := STRP + 279  ; [NET ]  7.62.0     Use this DOH server for name resolves
			this["UPLOAD_BUFFERSIZE"]          := LONG + 280  ; [PROT]  7.62.0     Set upload buffer size
			this["UPKEEP_INTERVAL_MS"]         := LONG + 281  ; [CONN]  7.62.0     Sets the interval at which connection upkeep are performed
			this["CURLU"]                      := OBJP + 282  ; [PROT]  7.63.0     Set URL to work on with CURLU *
			this["TRAILERFUNCTION"]            := FUNP + 283  ; [HTTP]  7.64.0 H   Set callback for sending trailing headers  (HTTP)
			this["TRAILERDATA"]                := CBPT + 284  ; [HTTP]  7.64.0 H   Custom pointer passed to the trailing headers callback  (HTTP)
			this["HTTP09_ALLOWED"]             := LONG + 285  ; [HTTP]  7.64.0 H   Allow HTTP/0.9 responses
			this["ALTSVC_CTRL"]                := LONG + 286  ; [HTTP]  7.64.1     Enable and configure Alt-Svc: treatment  (HTTPS)
			this["ALTSVC"]                     := STRP + 287  ; [HTTP]  7.64.1     Specify the Alt-Svc: cache file name  (HTTPS)
			this["MAXAGE_CONN"]                := LONG + 288  ; [CONN]  7.65.0     Limit the age of connections for reuse
			this["SASL_AUTHZID"]               := STRP + 289  ; [AUTH]  7.66.0     SASL authorisation identity (identity to act as)  (IMAP, POP3 and SMTP)
			this["MAIL_RCPT_ALLLOWFAILS"]      := LONG + 290  ; [SMTP]  7.69.0     Allow RCPT TO command to fail for some recipients  (SMTP)
			this["SSLCERT_BLOB"]               := BLOB + 291  ; [SSL ]  7.71.0     Client cert memory buffer  (TLS-based)
			this["SSLKEY_BLOB"]                := BLOB + 292  ; [SSL ]  7.71.0     Client key memory buffer  (TLS-based)
			this["PROXY_SSLCERT_BLOB"]         := BLOB + 293  ; [SSL ]  7.71.0     Proxy client cert memory buffer  (TLS-based)
			this["PROXY_SSLKEY_BLOB"]          := BLOB + 294  ; [SSL ]  7.71.0     Proxy client key  (TLS-based)
			this["ISSUERCERT_BLOB"]            := BLOB + 295  ; [SSL ]  7.71.0     Issuer certificate memory buffer  (TLS-based)
			this["PROXY_ISSUERCERT"]           := STRP + 296  ; [SSL ]  7.71.0     Proxy issuer certificate  (TLS-based)
			this["PROXY_ISSUERCERT_BLOB"]      := BLOB + 297  ; [SSL ]  7.71.0     Proxy issuer certificate memory buffer  (TLS-based)
			this["SSL_EC_CURVES"]              := STRP + 298  ; [    ]  7.73.0
			this["HSTS_CTRL"]                  := LONG + 299  ; [    ]  7.74.0
			this["HSTS"]                       := STRP + 300  ; [    ]  7.74.0
			this["HSTSREADFUNCTION"]           := FUNP + 301  ; [    ]  7.74.0
			this["HSTSREADDATA"]               := CBPT + 302  ; [    ]  7.74.0
			this["HSTSWRITEFUNCTION"]          := FUNP + 303  ; [    ]  7.74.0
			this["HSTSWRITEDATA"]              := CBPT + 304  ; [    ]  7.74.0
			
			this._initialized := True
		}
	}
	
	
	Class Info {
		Static _initialized := False
		
		Init() {
			If (this._initialized == True)
				Return
			
			STRP := 0x100000  ; String
			LONG := 0x200000  ; Long
			DBLE := 0x300000  ; Double
			SLIP := 0x400000  ; SList pointer
			OBJP := 0x400000  ; Pointer
			SOCK := 0x500000  ; Socket
			OFFT := 0x600000  ; curl_off_t
			
			this["EFFECTIVE_URL"]             := STRP +   1  ; 7.4        Last used URL  (HTTP(S))
			this["RESPONSE_CODE"]             := LONG +   2  ; 7.10.8     Last received response code  (HTTP, FTP and SMTP)
			this["TOTAL_TIME"]                := DBLE +   3  ; 7.4.1      Total time of previous transfer
			this["NAMELOOKUP_TIME"]           := DBLE +   4  ; 7.4.1      Time from start until name resolving completed
			this["CONNECT_TIME"]              := DBLE +   5  ; 7.4.1      Time from start until remote host or proxy completed
			this["PRETRANSFER_TIME"]          := DBLE +   6  ; 7.4.1      Time from start until just before the transfer begins
			this["SIZE_UPLOAD"]               := DBLE +   7  ; 7.4.1      Deprecated. Number of bytes uploaded
			this["SIZE_UPLOAD_T"]             := OFFT +   7  ; 7.55.0     Number of bytes uploaded
			this["SIZE_DOWNLOAD"]             := DBLE +   8  ; 7.4.1      Deprecated. Number of bytes downloaded
			this["SIZE_DOWNLOAD_T"]           := OFFT +   8  ; 7.55.0     Number of bytes downloaded
			this["SPEED_DOWNLOAD"]            := DBLE +   9  ; 7.4.1      Deprecated. Average download speed
			this["SPEED_DOWNLOAD_T"]          := OFFT +   9  ; 7.55.0     Average download speed
			this["SPEED_UPLOAD"]              := DBLE +  10  ; 7.4.1      Deprecated. Average upload speed
			this["SPEED_UPLOAD_T"]            := OFFT +  10  ; 7.55.0     Average upload speed
			this["HEADER_SIZE"]               := LONG +  11  ; 7.4.1      Number of bytes of all headers received
			this["REQUEST_SIZE"]              := LONG +  12  ; 7.4.1      Number of bytes sent in the issued HTTP requests
			this["SSL_VERIFYRESULT"]          := LONG +  13  ; 7.5    B   Certificate verification result  (TLS-based)
			this["FILETIME"]                  := LONG +  14  ; 7.5        Remote time of the retrieved document  (HTTP(S), FTP(S), SFTP)
			this["FILETIME_T"]                := OFFT +  14  ; 7.59.0     Remote time of the retrieved document  (HTTP(S), FTP(S), SFTP)
			this["CONTENT_LENGTH_DOWNLOAD"]   := DBLE +  15  ; 7.6.1      Deprecated. Content length from the Content-Length header  (HTTP(S))
			this["CONTENT_LENGTH_DOWNLOAD_T"] := OFFT +  15  ; 7.55.0     Content length from the Content-Length header  (HTTP(S))
			this["CONTENT_LENGTH_UPLOAD"]     := DBLE +  16  ; 7.6.1      Deprecated. Upload size
			this["CONTENT_LENGTH_UPLOAD_T"]   := OFFT +  16  ; 7.55.0     Upload size
			this["STARTTRANSFER_TIME"]        := DBLE +  17  ; 7.9.2      Time from start until just when the first byte is received
			this["CONTENT_TYPE"]              := STRP +  18  ; 7.9.4      Content type from the Content-Type header  (HTTP(S))
			this["REDIRECT_TIME"]             := DBLE +  19  ; 7.9.7      Time taken for all redirect steps before the final transfer
			this["REDIRECT_COUNT"]            := LONG +  20  ; 7.9.7      Total number of redirects that were followed  (HTTP(S))
			this["PRIVATE"]                   := STRP +  21  ; 7.10.3     User's private data pointer
			this["HTTP_CONNECTCODE"]          := LONG +  22  ; 7.10.7     Last proxy CONNECT response code  (HTTP)
			this["HTTPAUTH_AVAIL"]            := LONG +  23  ; 7.57.0 ~   Available HTTP authentication methods  (HTTP(S))
			this["PROXYAUTH_AVAIL"]           := LONG +  24  ; 7.57.0 ~   Available HTTP proxy authentication methods  (HTTP(S))
			this["OS_ERRNO"]                  := LONG +  25  ; 7.12.2     The errno from the last failure to connect
			this["NUM_CONNECTS"]              := LONG +  26  ; 7.12.3     Number of new successful connections used for previous transfer
			this["SSL_ENGINES"]               := SLIP +  27  ; 7.12.3 B   A list of OpenSSL crypto engines  (TLS-based)
			this["COOKIELIST"]                := SLIP +  28  ; 7.14.1     List of all known cookies  (HTTP(S))
			this["LASTSOCKET"]                := LONG +  29  ; 7.45.0 /   Last socket used
			this["FTP_ENTRY_PATH"]            := STRP +  30  ; 7.21.4 ~   The entry path after logging in to an FTP server  (FTP(S) and SFTP)
			this["REDIRECT_URL"]              := STRP +  31  ; 7.18.2     URL a redirect would take you to, had you enabled redirects  (HTTP(S))
			this["PRIMARY_IP"]                := STRP +  32  ; 7.19.0     IP address of the last connection  (Network-based)
			this["APPCONNECT_TIME"]           := DBLE +  33  ; 7.19.0     Time from start until SSL/SSH handshake completed
			this["CERTINFO"]                  := OBJP +  34  ; 7.50.0 ~   Certificate chain  (All TLS-based)
			this["CONDITION_UNMET"]           := LONG +  35  ; 7.19.4     Whether or not a time condition was met or 304 HTTP response  (HTTP and some)
			this["RTSP_SESSION_ID"]           := STRP +  36  ; 7.20.0     RTSP session ID  (RTSP)
			this["RTSP_CLIENT_CSEQ"]          := LONG +  37  ; 7.20.0     RTSP CSeq that will next be used  (RTSP)
			this["RTSP_SERVER_CSEQ"]          := LONG +  38  ; 7.20.0     RTSP CSeq that will next be expected  (RTSP)
			this["RTSP_CSEQ_RECV"]            := LONG +  39  ; 7.20.0     RTSP CSeq last received  (RTSP)
			this["PRIMARY_PORT"]              := LONG +  40  ; 7.21.0     Port of the last connection
			this["LOCAL_IP"]                  := STRP +  41  ; 7.21.0     Local-end IP address of last connection
			this["LOCAL_PORT"]                := LONG +  42  ; 7.21.0     Local-end port of last connection
			this["TLS_SESSION"]               := OBJP +  43  ; 7.48.0 ~   TLS session info that can be used for further processing  See  (TLS-based)
			this["ACTIVESOCKET"]              := SOCK +  44  ; 7.45.0     The session's active socket
			this["TLS_SSL_PTR"]               := OBJP +  45  ; 7.48.0     TLS session info that can be used for further processing  (TLS-based)
			this["HTTP_VERSION"]              := LONG +  46  ; 7.50.0     The http version used in the connection  (HTTP)
			this["PROXY_SSL_VERIFYRESULT"]    := LONG +  47  ; 7.52.0     Proxy certificate verification result
			this["PROTOCOL"]                  := LONG +  48  ; 7.52.0     The protocol used for the connection
			this["SCHEME"]                    := STRP +  49  ; 7.52.0     The scheme used for the connection
			this["TOTAL_TIME_T"]              := OFFT +  50  ; 7.61.0     Total time of previous transfer
			this["NAMELOOKUP_TIME_T"]         := OFFT +  51  ; 7.61.0     Time from start until name resolving completed
			this["CONNECT_TIME_T"]            := OFFT +  52  ; 7.61.0     Time from start until remote host or proxy completed
			this["PRETRANSFER_TIME_T"]        := OFFT +  53  ; 7.61.0     Time from start until just before the transfer begins
			this["STARTTRANSFER_TIME_T"]      := OFFT +  54  ; 7.61.0     Time from start until just when the first byte is received
			this["REDIRECT_TIME_T"]           := OFFT +  55  ; 7.61.0     Time taken for all redirect steps before the final transfer
			this["APPCONNECT_TIME_T"]         := OFFT +  56  ; 7.61.0     Time from start until SSL/SSH handshake completed
			this["RETRY_AFTER"]               := OFFT +  57  ; 7.66.0     The value from the from the Retry-After header  (HTTP(S))
			this["EFFECTIVE_METHOD"]          := STRP +  58  ; 7.72.0     Last used HTTP method  (HTTP(S))
			this["PROXY_ERROR"]               := LONG +  59  ; 7.73.0     Detailed proxy error  (All over SOCKS)
			
			this._initialized := True
		}
	}
}