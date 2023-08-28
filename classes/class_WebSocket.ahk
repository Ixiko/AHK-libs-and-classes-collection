
class WebSocket {
	
	; The primary HINTERNET handle to the websocket connection
	; This field should not be set externally.
	Ptr := 0
	
	; Whether the websocket is operating in Synchronous or Asynchronous mode.
	; This field should not be set externally.
	async := 0
	
	; The readiness state of the websocket.
	; This field should not be set externally.
	readyState := 0
	
	; The URL this websocket is connected to
	; This field should not be set externally.
	url := ""
	
	; Internal array of HINTERNET handles
	HINTERNETs := []
	
	; Internal buffer used to receive incoming data
	cache := "" ; Access ONLY by ObjGetAddress
	cacheSize := 8192
	
	; Internal buffer used to hold data fragments for multi-packet messages
	recData := ""
	recDataSize := 0
	
	; Aborted connection Event
	EVENT_ABORTED := { status: 1006 ; WEB_SOCKET_ABORTED_CLOSE_STATUS
		, reason: "The connection was closed without sending or receiving a close frame." }

	_LastError(Err := -1)
	{
		static module := DllCall("GetModuleHandle", "Str", "winhttp", "Ptr")
		Err := Err < 0 ? A_LastError : Err
		hMem := ""
		DllCall("Kernel32.dll\FormatMessage"
		, "Int", 0x1100 ; [in]           DWORD   dwFlags
		, "Ptr", module ; [in, optional] LPCVOID lpSource
		, "Int", Err    ; [in]           DWORD   dwMessageId
		, "Int", 0      ; [in]           DWORD   dwLanguageId
		, "Ptr*", hMem  ; [out]          LPTSTR  lpBuffer
		, "Int", 0      ; [in]           DWORD   nSize
		, "Ptr", 0      ; [in, optional] va_list *Arguments
		, "UInt") ; DWORD
		return StrGet(hMem), DllCall("Kernel32.dll\LocalFree", "Ptr", hMem, "Ptr")
	}
	
	; Internal function used to load the mcode event filter
	_StatusSyncCallback()
	{
		if this.pCode
			return this.pCode
		b64 := (A_PtrSize == 4)
		? "i1QkDIPsDIH6AAAIAHQIgfoAAAAEdTWLTCQUiwGJBCSLRCQQiUQkBItEJByJRCQIM8CB+gAACAAPlMBQjUQkBFD/cQyLQQj/cQT/0IPEDMIUAA=="
		: "SIPsSEyL0kGB+AAACAB0CUGB+AAAAAR1MEiLAotSGEyJTCQwRTPJQYH4AAAIAEiJTCQoSYtKCEyNRCQgQQ+UwUiJRCQgQf9SEEiDxEjD"
		if !DllCall("crypt32\CryptStringToBinary", "Str", b64, "UInt", 0, "UInt", 1, "Ptr", 0, "UInt*", s := 0, "Ptr", 0, "Ptr", 0)
			throw Exception("failed to parse b64 to binary")
		ObjSetCapacity(this, "code", s)
		this.pCode := ObjGetAddress(this, "code")
		if !DllCall("crypt32\CryptStringToBinary", "Str", b64, "UInt", 0, "UInt", 1, "Ptr", this.pCode, "UInt*", s, "Ptr", 0, "Ptr", 0) &&
			throw Exception("failed to convert b64 to binary")
		if !DllCall("VirtualProtect", "Ptr", this.pCode, "UInt", s, "UInt", 0x40, "UInt*", 0)
			throw Exception("failed to mark memory as executable")
		return this.pCode
		/* c++ source
			struct __CONTEXT {
				void *obj;
				HWND hwnd;
				decltype(&SendMessageW) pSendMessage;
				UINT msg;
			};
			void __stdcall WinhttpStatusCallback(
			void *hInternet,
			DWORD_PTR dwContext,
			DWORD dwInternetStatus,
			void *lpvStatusInformation,
			DWORD dwStatusInformationLength) {
				if (dwInternetStatus == 0x80000 || dwInternetStatus == 0x4000000) {
					__CONTEXT *context = (__CONTEXT *)dwContext;
					void *param[3] = { context->obj,hInternet,lpvStatusInformation };
					context->pSendMessage(context->hwnd, context->msg, (WPARAM)param, dwInternetStatus == 0x80000);
				}
			}
		*/
	}
	
	; Internal event dispatcher for compatibility with the legacy interface
	_Event(name, event)
	{
		this["On" name](event)
	}
	
	; Reconnect
	reconnect()
	{
		this.connect()
	}
	
	pRecData[] {
		get {
			return ObjGetAddress(this, "recData")
		}
	}
	
	__New(url, events := 0, async := true, headers := "")
	{
		this.url := url
		
		this.HINTERNETs := []
		
		; Force async to boolean
		this.async := async := !!async
		
		; Initialize the Cache
		ObjSetCapacity(this, "cache", this.cacheSize)
		this.pCache := ObjGetAddress(this, "cache")
		
		; Initialize the RecData
		; this.pRecData := ObjGetAddress(this, "recData")
		
		; Find the script's built-in window for message targeting
		dhw := A_DetectHiddenWindows
		DetectHiddenWindows, On
		this.hWnd := WinExist("ahk_class AutoHotkey ahk_pid " DllCall("GetCurrentProcessId"))
		DetectHiddenWindows, %dhw%
		
		; Parse the url
		if !RegExMatch(url, "Oi)^((?<SCHEME>wss?)://)?((?<USERNAME>[^:]+):(?<PASSWORD>.+)@)?(?<HOST>[^/:]+)(:(?<PORT>\d+))?(?<PATH>/.*)?$", m)
			throw Exception("Invalid websocket url")
		this.m := m
		
		; Open a new HTTP API instance
		if !(hSession := DllCall("Winhttp\WinHttpOpen"
			, "Ptr", 0  ; [in, optional]        LPCWSTR pszAgentW
			, "UInt", 0 ; [in]                  DWORD   dwAccessType
			, "Ptr", 0  ; [in]                  LPCWSTR pszProxyW
			, "Ptr", 0  ; [in]                  LPCWSTR pszProxyBypassW
			, "UInt", async * 0x10000000 ; [in] DWORD   dwFlags
			, "Ptr")) ; HINTERNET
			throw Exception("WinHttpOpen failed: " this._LastError())
		this.HINTERNETs.Push(hSession)
		
		; Connect the HTTP API to the remote host
		port := m.PORT ? (m.PORT + 0) : (m.SCHEME = "ws") ? 80 : 443
		if !(this.hConnect := DllCall("Winhttp\WinHttpConnect"
			, "Ptr", hSession ; [in] HINTERNET     hSession
			, "WStr", m.HOST  ; [in] LPCWSTR       pswzServerName
			, "UShort", port  ; [in] INTERNET_PORT nServerPort
			, "UInt", 0       ; [in] DWORD         dwReserved
			, "Ptr")) ; HINTERNET
			throw Exception("WinHttpConnect failed: " this._LastError())
		this.HINTERNETs.Push(this.hConnect)
		
		; Translate headers from array to string
		if IsObject(headers)
		{
			s := ""
			for k, v in headers
				s .= "`r`n" k ": " v
			headers := LTrim(s, "`r`n")
		}
		this.headers := headers
		
		; Set any event handlers from events parameter
		for k, v in IsObject(events) ? events : []
			if (k ~= "i)^(data|message|close|error|open)$")
				this["on" k] := v
		
		; Set up a handler for messages from the StatusSyncCallback mcode
		this.wm_ahkmsg := DllCall("RegisterWindowMessage", "Str", "AHK_WEBSOCKET_STATUSCHANGE_" &this, "UInt")
		OnMessage(this.wm_ahkmsg, this.WEBSOCKET_STATUSCHANGE.Bind({})) ; TODO: Proper binding
		
		; Connect on start
		this.connect()
	}
	
	connect() {
		; Collect pointer to SendMessageW routine for the StatusSyncCallback mcode
		static pSendMessageW := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "User32", "Ptr"), "AStr", "SendMessageW", "Ptr")
		
		; If the HTTP connection is closed, we cannot request a websocket
		if !this.HINTERNETs.Length()
			throw Exception("The connection is closed")
		
		; Shutdown any existing websocket connection
		this.shutdown()
		
		; Free any HINTERNET handles from previous websocket connections
		while (this.HINTERNETs.Length() > 2)
			DllCall("Winhttp\WinHttpCloseHandle", "Ptr", this.HINTERNETs.Pop())
		
		; Open an HTTP Request for the target path
		dwFlags := (this.m.SCHEME = "wss") ? 0x800000 : 0
		if !(hRequest := DllCall("Winhttp\WinHttpOpenRequest"
			, "Ptr", this.hConnect ; [in] HINTERNET hConnect,
			, "WStr", "GET"        ; [in] LPCWSTR   pwszVerb,
			, "WStr", this.m.PATH  ; [in] LPCWSTR   pwszObjectName,
			, "Ptr", 0             ; [in] LPCWSTR   pwszVersion,
			, "Ptr", 0             ; [in] LPCWSTR   pwszReferrer,
			, "Ptr", 0             ; [in] LPCWSTR   *ppwszAcceptTypes,
			, "UInt", dwFlags      ; [in] DWORD     dwFlags
			, "Ptr")) ; HINTERNET
			throw Exception("WinHttpOpenRequest failed: " this._LastError())
		this.HINTERNETs.Push(hRequest)
		
		if this.headers
		{
			if ! DllCall("Winhttp\WinHttpAddRequestHeaders"
				, "Ptr", hRequest      ; [in] HINTERNET hRequest,
				, "WStr", this.headers ; [in] LPCWSTR   lpszHeaders,
				, "UInt", -1           ; [in] DWORD     dwHeadersLength,
				, "UInt", 0x20000000   ; [in] DWORD     dwModifiers
				, "Int") ; BOOL
				throw Exception("WinHttpAddRequestHeaders failed: " this._LastError())
		}
		
		; Make the HTTP Request
		status := "00000"
		if (!DllCall("Winhttp\WinHttpSetOption", "Ptr", hRequest, "UInt", 114, "Ptr", 0, "UInt", 0, "Int")
			|| !DllCall("Winhttp\WinHttpSendRequest", "Ptr", hRequest, "Ptr", 0, "UInt", 0, "Ptr", 0, "UInt", 0, "UInt", 0, "UPtr", 0, "Int")
			|| !DllCall("Winhttp\WinHttpReceiveResponse", "Ptr", hRequest, "Ptr", 0)
			|| !DllCall("Winhttp\WinHttpQueryHeaders", "Ptr", hRequest, "UInt", 19, "Ptr", 0, "WStr", status, "UInt*", 10, "Ptr", 0, "Int")
			|| status != "101")
			throw Exception("Invalid status: " status)
		
		; Upgrade the HTTP Request to a Websocket connection
		if !(this.Ptr := DllCall("Winhttp\WinHttpWebSocketCompleteUpgrade", "Ptr", hRequest, "Ptr", 0))
			throw Exception("WinHttpWebSocketCompleteUpgrade failed: " this._LastError())
		
		; Close the HTTP Request, save the Websocket connection
		DllCall("Winhttp\WinHttpCloseHandle", "Ptr", this.HINTERNETs.Pop())
		this.HINTERNETs.Push(this.Ptr)
		this.readyState := 1
		
		; Configure asynchronous callbacks
		if (this.async)
		{
			; Populate context struct for the mcode to reference
			ObjSetCapacity(this, "__context", 4 * A_PtrSize)
			pCtx := ObjGetAddress(this, "__context")
			NumPut(&this         , pCtx + A_PtrSize * 0, "Ptr")
			NumPut(this.hWnd     , pCtx + A_PtrSize * 1, "Ptr")
			NumPut(pSendMessageW , pCtx + A_PtrSize * 2, "Ptr")
			NumPut(this.wm_ahkmsg, pCtx + A_PtrSize * 3, "UInt")
			
			if !DllCall("Winhttp\WinHttpSetOption"
				, "Ptr", this.Ptr   ; [in] HINTERNET hInternet
				, "UInt", 45        ; [in] DWORD     dwOption
				, "Ptr*", pCtx      ; [in] LPVOID    lpBuffer
				, "UInt", A_PtrSize ; [in] DWORD     dwBufferLength
				, "Int") ; BOOL
				throw Exception("WinHttpSetOption failed: " this._LastError())
			
			StatusCallback := this._StatusSyncCallback()
			if (-1 == DllCall("Winhttp\WinHttpSetStatusCallback"
				, "Ptr", this.Ptr       ; [in] HINTERNET               hInternet,
				, "Ptr", StatusCallback ; [in] WINHTTP_STATUS_CALLBACK lpfnInternetCallback,
				, "UInt", 0x80000       ; [in] DWORD                   dwNotificationFlags,
				, "UPtr", 0             ; [in] DWORD_PTR               dwReserved
				, "Ptr")) ; WINHTTP_STATUS_CALLBACK
				throw Exception("WinHttpSetStatusCallback failed: " this._LastError())
			
			; Make the initial request for data to receive an asynchronous response for
			if (ret := DllCall("Winhttp\WinHttpWebSocketReceive"
				, "Ptr", this.Ptr        ; [in]  HINTERNET                      hWebSocket,
				, "Ptr", this.pCache     ; [out] PVOID                          pvBuffer,
				, "UInt", this.cacheSize ; [in]  DWORD                          dwBufferLength,
				, "UInt*", 0             ; [out] DWORD                          *pdwBytesRead,
				, "UInt*", 0             ; [out] WINHTTP_WEB_SOCKET_BUFFER_TYPE *peBufferType
				, "UInt")) ; DWORD
				throw Exception("WinHttpWebSocketReceive failed: " ret)
		}
		
		; Fire the open event
		this._Event("Open", {timestamp:A_Now A_Msec, url: this.url})
	}
	
	WEBSOCKET_STATUSCHANGE(wp, lp, msg, hwnd) {
		if !lp {
			this.readyState := 3
			return
		}
		
		; Grab `this` from the provided context struct
		this := Object(NumGet(wp + A_PtrSize * 0, "Ptr"))
		
		; Don't process data when the websocket isn't ready
		if (this.readyState != 1)
			return
		
		; Grab the rest of the context data
		hInternet :=            NumGet(wp + A_PtrSize * 1, "Ptr")
		lpvStatusInformation := NumGet(wp + A_PtrSize * 2, "Ptr")
		dwBytesTransferred :=   NumGet(lpvStatusInformation + 0, "UInt")
		eBufferType :=          NumGet(lpvStatusInformation + 4, "UInt")
		
		; Mark the current size of the received data buffer for use as an offset
		; for the start of any newly provided data
		offset := this.recDataSize
		
		if (eBufferType > 3)
		{
			closeStatus := this.QueryCloseStatus()
			this.shutdown()
			this._Event("Close", {reason: closeStatus.reason, status: closeStatus.status})
			return
		}

		try {
			if (eBufferType == 0) ; BINARY
			{
				if offset ; Continued from a fragment
				{
					VarSetCapacity(data, offset + dwBytesTransferred)
					
					; Copy data from the fragment buffer
					DllCall("RtlMoveMemory"
					, "Ptr", &data
					, "Ptr", this.pRecData
					, "UInt", this.recDataSize)
					
					; Copy data from the new data cache
					DllCall("RtlMoveMemory"
					, "Ptr", &data + offset
					, "Ptr", this.pCache
					, "UInt", dwBytesTransferred)
					
					; Clear fragment buffer
					this.recDataSize := 0
					
					this._Event("Data", {data: &data, size: offset + dwBytesTransferred})
				}
				else ; No prior fragment
				{
					; Copy data from the new data cache
					VarSetCapacity(data, dwBytesTransferred)
					DllCall("RtlMoveMemory"
					, "Ptr", &data
					, "Ptr", this.pCache
					, "UInt", dwBytesTransferred)
					
					this._Event("Data", {data: &data, size: dwBytesTransferred})
				}
			}
			else if (eBufferType == 2) ; UTF8
			{
				if offset
				{
					; Continued from a fragment
					this.recDataSize += dwBytesTransferred
					ObjSetCapacity(this, "recData", this.recDataSize)
					
					DllCall("RtlMoveMemory"
					, "Ptr", this.pRecData + offset
					, "Ptr", this.pCache
					, "UInt", dwBytesTransferred)
					
					msg := StrGet(this.pRecData, "utf-8")
					this.recDataSize := 0
				}
				else ; No prior fragment
					msg := StrGet(this.pCache, dwBytesTransferred, "utf-8")
				
				this._Event("Message", {data: msg})
			}
			else if (eBufferType == 1 || eBufferType == 3) ; BINARY_FRAGMENT, UTF8_FRAGMENT
			{
				; Add the fragment to the received data buffer
				this.recDataSize += dwBytesTransferred
				ObjSetCapacity(this, "recData", this.recDataSize)
				DllCall("RtlMoveMemory"
				, "Ptr", this.pRecData + offset
				, "Ptr", this.pCache
				, "UInt", dwBytesTransferred)
			}
		}
		finally
		{
			askForMoreData := this.askForMoreData.Bind(this, hInternet)
			SetTimer, %askForMoreData%, -1
		}
	}
	
	askForMoreData(hInternet)
	{
		static ERROR_INVALID_OPERATION := 4317
		; Original implementation used a while loop here, but in my experience
		; that causes lost messages
		ret := DllCall("Winhttp\WinHttpWebSocketReceive"
		, "Ptr", hInternet       ; [in]  HINTERNET hWebSocket,
		, "Ptr", this.pCache     ; [out] PVOID     pvBuffer,
		, "UInt", this.cacheSize ; [in]  DWORD     dwBufferLength,
		, "UInt*", 0             ; [out] DWORD     *pdwBytesRead,
		, "UInt*", 0             ; [out]           *peBufferType
		, "UInt") ; DWORD
		if (ret && ret != ERROR_INVALID_OPERATION)
			this._Error({code: ret})
	}
	
	__Delete()
	{
		this.shutdown()
		; Free all active HINTERNETs
		while (this.HINTERNETs.Length())
			DllCall("Winhttp\WinHttpCloseHandle", "Ptr", this.HINTERNETs.Pop())
	}
	
	; Default error handler
	_Error(err)
	{
		if (err.code != 12030) {
			this._Event("Error", {code: ret})
			return
		}
		if (this.readyState == 3)
			return
		this.readyState := 3
		try this._Event("Close", this.EVENT_ABORTED)
	}
	
	queryCloseStatus() {
		usStatus := 0
		VarSetCapacity(vReason, 123, 0)
		if (!DllCall("Winhttp\WinHttpWebSocketQueryCloseStatus"
			, "Ptr", this.Ptr     ; [in]  HINTERNET hWebSocket,
			, "UShort*", usStatus ; [out] USHORT    *pusStatus,
			, "Ptr", &vReason     ; [out] PVOID     pvReason,
			, "UInt", 123         ; [in]  DWORD     dwReasonLength,
			, "UInt*", len        ; [out] DWORD     *pdwReasonLengthConsumed
			, "UInt")) ; DWORD
			return { status: usStatus, reason: StrGet(&vReason, len, "utf-8") }
		else if (this.readyState > 1)
			return this.EVENT_ABORTED
	}
	
	; eBufferType BINARY_MESSAGE = 0, BINARY_FRAGMENT = 1, UTF8_MESSAGE = 2, UTF8_FRAGMENT = 3
	sendRaw(eBufferType, pvBuffer, dwBufferLength) {
		if (this.readyState != 1)
			throw Exception("websocket is disconnected")
		if (ret := DllCall("Winhttp\WinHttpWebSocketSend"
			, "Ptr", this.Ptr        ; [in] HINTERNET                      hWebSocket
			, "UInt", eBufferType    ; [in] WINHTTP_WEB_SOCKET_BUFFER_TYPE eBufferType
			, "Ptr", pvBuffer        ; [in] PVOID                          pvBuffer
			, "UInt", dwBufferLength ; [in] DWORD                          dwBufferLength
			, "UInt")) ; DWORD
			this._Error({code: ret})
	}
	
	; sends a utf-8 string to the server
	send(str)
	{
		if (size := StrPut(str, "utf-8") - 1)
		{
			VarSetCapacity(buf, size, 0)
			StrPut(str, &buf, "utf-8")
			this.sendRaw(2, &buf, size)
		}
		else
			this.sendRaw(2, 0, 0)
	}
	
	receive()
	{
		if (this.async)
			throw Exception("Used only in synchronous mode")
		if (this.readyState != 1)
			throw Exception("websocket is disconnected")
		
		rec := {data: "", size: 0, ptr: 0}
		
		offset := 0
		while (!ret := DllCall("Winhttp\WinHttpWebSocketReceive"
			, "Ptr", this.Ptr           ; [in]  HINTERNET                      hWebSocket
			, "Ptr", this.pCache        ; [out] PVOID                          pvBuffer
			, "UInt", this.cacheSize    ; [in]  DWORD                          dwBufferLength
			, "UInt*", dwBytesRead := 0 ; [out] DWORD                          *pdwBytesRead
			, "UInt*", eBufferType := 0 ; [out] WINHTTP_WEB_SOCKET_BUFFER_TYPE *peBufferType
			, "UInt")) ; DWORD
		{
			switch eBufferType
			{
				case 0:
				if offset
				{
					rec.size += dwBytesRead
					ObjSetCapacity(rec, "data", rec.size)
					ptr := ObjGetAddress(rec, "data")
					DllCall("RtlMoveMemory", "Ptr", ptr + offset, "Ptr", this.pCache, "UInt", dwBytesRead)
				}
				else
				{
					rec.size := dwBytesRead
					ObjSetCapacity(rec, "data", rec.size)
					ptr := ObjGetAddress(rec, "data")
					DllCall("RtlMoveMemory", "Ptr", ptr, "Ptr", this.pCache, "UInt", dwBytesRead)
				}
				return rec
				case 1, 3:
				rec.size += dwBytesRead
				ObjSetCapacity(rec, "data", rec.size)
				ptr := ObjGetAddress(rec, "data")
				DllCall("RtlMoveMemory", "Ptr", rec + offset, "Ptr", this.pCache, "UInt", dwBytesRead)
				offset += dwBytesRead
				case 2:
				if (offset) {
					rec.size += dwBytesRead
					ObjSetCapacity(rec, "data", rec.size)
					ptr := ObjGetAddress(rec, "data")
					DllCall("RtlMoveMemory", "Ptr", ptr + offset, "Ptr", this.pCache, "UInt", dwBytesRead)
					return StrGet(ptr, "utf-8")
				}
				return StrGet(this.pCache, dwBytesRead, "utf-8")
				default:
				rea := this.queryCloseStatus()
				this.shutdown()
				try this._Event("Close", {status: rea.status, reason: rea.reason})
					return
			}
		}
		if (ret != 4317)
			this._Error({code: ret})
	}
	
	; sends a close frame to the server to close the send channel, but leaves the receive channel open.
	shutdown() {
		if (this.readyState != 1)
			return
		this.readyState := 2
		DllCall("Winhttp\WinHttpWebSocketShutdown", "Ptr", this.Ptr, "UShort", 1000, "Ptr", 0, "UInt", 0)
		this.readyState := 3
	}
}
