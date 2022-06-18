; #Requires AutoHotkey v1.1
; https://github.com/TheArkive/DLFile_ahk2
; https://www.autohotkey.com/boards/viewtopic.php?f=83&p=447903#p447903
; ===================================================================================
; Example
; ===================================================================================
; It is important to note that this class is NOT async.  It is theoretically possible
; to do some type of multi-thread download, but this is not a true async implementation.
; Therefore when calling the Start() method, exection will halt in that thread until
; another thread sets:
;
;   obj.cancel := true
;
; While it may be theoretically possible to implement multi-thread downloading, or
; even multiple simultaneous downloads, this is not entirely an ideal way to do it.
; A true "async" implementation is necessary for this become ideal.
;
; The "async" capabilities with the WinHTTP API require "thread safe" execution.  And
; with AutoHotkey, if I'm not mistaken, this is not supported.  I did try a true async
; version and managed to consistently fail in a mind-boggling number of different ways.
; I almost never got the same error twice.
;
; If someone wants to school me, please do :-)
; ===================================================================================

url:=["https://dl.google.com/android/repository/commandlinetools-win-8092744_latest.zip"
     ,"https://dl.google.com/android/repository/commandlinetools-win-7583922_latest.zip"]
dest := A_Desktop ; on batch, dest must be folder, otherwise, on single file/url input dest should be the file to create.


DL := new DLFile(url,dest,"callback")
Msgbox % "F2 = Cancel`n`nF3 = Resume`n`nESC = Exit"

Progress, W500 , % " ", % " ", Download File / F2 = Cancel / F3 = Resume / ESC = Exit, Consolas
Progress, Show

;;;; DL.del_on_cancel := true ; enable/uncommen this to delete partial files after cancel

DL.Start()

callback(o:="") {
    Progress, % o.perc, % "KBps: " Round(o.bps/1024)  "   /   Progress: " o.perc "%", % o.file
}

F2::DL.cancel := true
F3::DL.Start()
ESC::ExitApp

; ===================================================================================
; USAGE:
;
;   DLFile(url, dest, callback := "", del_on_cancel := false)
;
;   Params:
;
;   - url = a single url string, or an array of URLs
;
;   - dest = When url is a single url, this must be a filename (full path) to create.
;            When url is an array of URLs, then this must be a folder name.
;
;   - callback = a func object
;
;       The callback func must accept a single param.  The param is an object with
;       the following properties:
;
;       - size  = total file size
;       - bytes = bytes downloaded so far
;       - bps   = the avg bytes per second
;       - file  = the file name
;       - perc  = percent complete
;       - url   = the full url
;       - dest  = specified destination dir/file
;       - cb    = the callback function object
;
;   - del_on_cancel
;
;       Set this param to TRUE in order to have an incomplete temp file deleted on cancel.
;
;   Object properties:
;
;       - obj.del_on_cancel = set this to true to clean up a partial download after abort
;
;       - obj.cancel = set this to true to interrupt the download
;
;   Object methods:
;
;       - obj.Start() = Starts the download.  You can set del_on_cancel before
;                       starting the download.
;
;       - obj.CheckLength() = Manually check the length of the requested URL.
;                             It is not necessary to call this manually for the
;                             sake of downloading the file.  This is done internally.
;                             This is only useful if you wish to query the file size
;                             for some other purpose, ie. to display the file size
;                             in a GUI control.
;
;       - obj.CheckPartial(bytes:=false) = Check for a partial download and automatically
;                                          calculate and return the percent complete.
;                                          Optionally specify TRUE for the 'bytes' param
;                                          and get the current size in bytes of the
;                                          partial file.
;
;   WARNING:
;
;       Do not destroy the object during a download.  If you do, the handles will
;       likely not be able to be closed properly.  To gracefully terminate a
;       download, you must set:
;
;           obj.cancel := true
;
;       It is highly suggested to not use any other methods defined in this class
;       directly, unless you are doing something advanced, in which case proceed
;       with caution, and avoid buffer overrun errors.
; ===================================================================================

class DLFile {
    del_on_cancel := false
    
    __New(url, dest, cb:="", del_on_cancel:=false) {
        this.url := url, this.dest := dest, this.del_on_cancel := del_on_cancel
        this.timer := ObjBindMethod(this,"_timer")
        this.cb := (IsFunc(cb) ? Func(cb) : "")
    }
    
    Start() {
        this.cancel := this.resume := 0
        
        If !this.url.Length() {
            this._SplitUrl(this.url,&protocol,&server,&port,&_dir_file,&_file)
            this.dir_file := _dir_file, this.file := _file, this.server := server, this.port := port
            this.StartDL()
        } Else {
            If !(InStr(FileExist(this.dest),"D")) {
                MsgBox "Destination must be a directory when processing a batch."
                return
            }
            While this.url.Length() && !this.cancel {
                this._SplitUrl(this.url[1],protocol,server,port,_dir_file,_file)
                this.dir_file := _dir_file, this.file := _file, this.server := server, this.port := port
                this.size := this.perc := this.bytes := this.lastBytes := this.bps := this.cancel := this.resume := 0
                this.StartDL()
            }
        }
    }
    
    StartDL() {
        cb := this.cb
        temp_file := (this.url.Length()) ? (this.dest "\" this.file ".temp") : (this.dest ".temp")
        dest_file := (this.url.Length()) ? (this.dest "\" this.file) : (this.dest)
        this.hSession := this.Open()
        this.hConnect := this.Connect(this.hSession, this.server, this.port)
        
        If FileExist(temp_file) { ; check for 'dest.temp' file
            length := this.CheckLength(false) ; do not call this.Abort() on CheckLength()
            this.hRequest := this.OpenRequest(this.hConnect,"GET",this.dir_file)
            file_buf := FileOpen(temp_file,"a")
            this.SendRequest(this.hRequest,"Range: bytes=-" (length-file_buf.Length)) ; specify range to download
            this.ReceiveResponse(this.hRequest)
            headers := this.QueryHeaders(this.hRequest), rsp := headers["response-code"]
            
            If (rsp = 206 || rsp = 200) { ; if request is valid, set size and bytes already downloaded
                this.size := RegExReplace(headers["content-range"],"bytes \d+\-\d+/(\d+)","$1")
                this.bytes := this.lastBytes := file_buf.Length, this.resume := true
            } Else this.CloseHandle(this.hRequest) ; abort hRequest and recreate below
        }
        
        If !this.resume { ; recreate request to download the full file
            this.hRequest := this.OpenRequest(this.hConnect,"GET",this.dir_file)
            r1 := this.SendRequest(this.hRequest)
            r2 := this.ReceiveResponse(this.hRequest)
            headers := this.QueryHeaders(this.hRequest)
            file_buf := FileOpen(temp_file,"rw")
            this.size := headers["content-length"]
        }
        
        this.bps_arr := []
        this.SetTimer(this.timer,250)
        
        While(d_size := this.QueryDataSize(this.hRequest)) {
            If (this.cancel)
                Break
            this.ReadData(this.hRequest,d_size,file_buf) ; reads data and writes to file
            this.bytes += d_size
        }
        this.SetTimer(this.timer,0)
        
        If !this.cancel { ; ensure finished stats on completion
            this.bytes:=this.size, this.bps:=0, this.perc:=100
            (this.url.Length()) ? this.url.RemoveAt(1) : ""
        }
        If IsFunc(cb)
            %cb%(this)
        
        file_buf.Close()
        If !this.cancel             ; remove ".temp" on complete
            FileMove, % temp_file, % dest_file
        Else If this.del_on_cancel  ; delete partial download if enabled
            FileDelete, % temp_file
        this.Abort()                ; cleanup handles
    }
    
    SetTimer(fnc,time) {
        time := (time=0) ? "Off" : time
        SetTimer, % fnc, % time
    }
    
    _timer() {
        cb := this.cb
        If IsFunc(cb) {
            this.bps_arr.Push(this.bytes - this.lastBytes)
            this.bps := this._get_avg(this.bps_arr)
            this.perc := Round(this.bytes/this.size*100)
            this.lastBytes := this.bytes
            %cb%(this)
        }
    }
    
    ; CheckPartial(bytes:=false) {
        ; length := this.CheckLength(true), result := 0
        ; If FileExist(this.dest ".temp") {
            ; f := FileOpen(this.dest ".temp","r"), size := f.Length, f.Close()
            ; result := bytes ? size : Round(size/length)
        ; } return result
    ; }
    
    CheckLength(abort:=true) {
        this.hSession := this.Open()
        this.hConnect := this.Connect(this.hSession, this.server, this.port)
        this.hRequest := this.OpenRequest(this.hConnect,"HEAD",this.dir_file)
        this.SendRequest(this.hRequest), this.ReceiveResponse(this.hRequest)
        length := this.QueryHeaders(this.hRequest,"content-length")
        this.CloseHandle(this.hRequest), this.hRequest := 0, (abort ? this.Abort() : "")
        return length
    }
    
    _get_avg(bps_arr, result:=0) {
        For i, val in bps_arr
            result += val
        return Round(result / bps_arr.Length() * 4)
    }
    
    _SplitUrl(url, ByRef protocol, ByRef server, ByRef port, ByRef _dir_file, ByRef _file) {
        protocol := RegExReplace(url,"^(https|http).+","$1")
        s_p := StrSplit(RegExReplace(url,"^https?://([^/]+).+","$1"),":")
        server := s_p[1]
        port := (!s_p.HasKey(2)?0:s_p[2])
        _dir_file := RegExReplace(url,"^\Q" protocol "://" server "\E","")
        _file := RegExReplace(url,".+?/([^/]+)$","$1")
    }
    
    __Delete() {
        ((this.hRequest) ? this.Abort() : "")
    }
    
    ; ==============================================================================
    ; prxType := 1
    ; WINHTTP_ACCESS_TYPE_DEFAULT_PROXY    0 ; WINHTTP_ACCESS_TYPE_NAMED_PROXY      3
    ; WINHTTP_ACCESS_TYPE_NO_PROXY         1 ; WINHTTP_ACCESS_TYPE_AUTOMATIC_PROXY  4
    ;
    ; dwFlags (DWORD) - combine zero or more
    ; WINHTTP_FLAG_ASYNC              0x10000000  // this session is asynchronous (where supported)
    ; WINHTTP_FLAG_SECURE_DEFAULTS    0x30000000  // note that this flag also forces async
    Open(userAgent:="WinHTTP/5.0", prxType:=1, prxName:=0, prxBypass:=0, dwFlags:=0) {
        return DllCall("Winhttp\WinHttpOpen","Str",userAgent,"UInt",prxType,(!prxName?"UPtr":"Str"),prxName
                                         ,(!prxBypass?"UPtr":"Str"),prxBypass,"UInt",dwFlags)
    }
    
    ; ==============================================================================
    ; dwFlags := 0xFFFFFFFF ; all notifications
    SetCallback(hSession, pCallback, dwFlags) {
        return DllCall("Winhttp\WinHttpSetStatusCallback","UPtr",hSession,"UPtr",pCallback,"UInt",dwFlags,"UPtr",0)
    }
    
    ; ==============================================================================
    ; verb (string)
    ; _file (string)
    ; ref = referrer (string)
    ; dwFlags (DWORD) - combine values below
    ;
    ; WINHTTP_FLAG_SECURE                0x00800000  // use SSL if applicable (HTTPS)
    ; WINHTTP_FLAG_ESCAPE_PERCENT        0x00000004  // if escaping enabled, escape percent as well
    ; WINHTTP_FLAG_NULL_CODEPAGE         0x00000008  // assume all symbols are ASCII, use fast convertion
    ; WINHTTP_FLAG_BYPASS_PROXY_CACHE    0x00000100  // add "pragma: no-cache" request header
    ; WINHTTP_FLAG_REFRESH               WINHTTP_FLAG_BYPASS_PROXY_CACHE
    ; WINHTTP_FLAG_ESCAPE_DISABLE        0x00000040  // disable escaping
    ; WINHTTP_FLAG_ESCAPE_DISABLE_QUERY  0x00000080  // if escaping enabled escape path part, but do not escape query
    OpenRequest(hConnect, verb, _file:="/", ref:=0, media_types:="*/*", dwFlags:=0x00800000) {
        Static iu := (A_IsUnicode?2:1)
        types_arr := StrSplit(media_types,":"," ")
        VarSetCapacity(types_buf,A_PtrSize*(types_arr.Length()+1),0)
        For i, _type in types_arr
            NumPut(&_type,types_buf,(i-1)*A_PtrSize,"UPtr")
        r := DllCall("Winhttp\WinHttpOpenRequest","UPtr",hConnect,"Str",verb,"Str",_file,"UPtr",0
                                        ,(!ref?"UPtr":"Str"),ref,"UPtr",&types_buf,"UInt",dwFlags)
        return r
    }
    
    ; ==============================================================================
    Connect(hSession, server, port:=0) {
        return (this.hConnect := DllCall("Winhttp\WinHttpConnect","UPtr",hSession,"Str",server,"UInt",port,"UInt",0))
    }
    
    ; ==============================================================================
    ; exH = extra headers (string)
    ; exD = extra data (buffer)
    ; exD2 = additional data size to be sent with WinHttpWriteData()
    ; ID  = context ID (user defined DWORD)
    SendRequest(hRequest, exH:=0, exD:=0, exD2:=0, ID:=0) {
        DllCall("Winhttp\WinHttpSendRequest","UPtr",hRequest
                                            ,(!exH?"UPtr":"Str"),exH
                                            ,"Int",(exH?-1:0)
                                            ,"UPtr",(exD?&exD:0)
                                            ,"UInt",(exD_sz:=(exD?VarSetCapacity(exD):0))
                                            ,"UInt",exD_sz+exD2
                                            ,"UPtr",ID)
    }
    ; ==============================================================================
    ReceiveResponse(hRequest) {
        return DllCall("Winhttp\WinHttpReceiveResponse","UPtr",hRequest,"UPtr",0)
    }
    
    ; ==============================================================================
    ; This method pulls- raw-headers-crlf = 22 (all headers) by default.
    ; Optionally specify a specific header to get only that value.
    ; Default return value, with no header specified, returns a map() of all headers.
    ;
    ; extra values added:   http-version, response-code, response-code-text
    QueryHeaders(hRequest,header:="") {
        fnc := "Winhttp\WinHttpQueryHeaders"
        r1 := DllCall(fnc,"UPtr",hRequest,"UInt",22,"UPtr",0,"UPtr",0,"UInt*",size,"UPtr",0)
        VarSetCapacity(buf,size,0)
        r2 := DllCall(fnc,"UPtr",hRequest,"UInt",22,"UPtr",0,"UPtr",&buf,"UInt*",size,"UPtr",0)
        full_hdrs := StrGet(&buf), _map := {}
        
        Loop, Parse, full_hdrs, `n, `r
        {
            If RegExMatch(A_LoopField,"O)^HTTP/([\d\.]+) (\d+) (.+)",m) {
                _map["http-version"] := m[1]
                _map["response-code"] := m[2]
                _map["response-code-text"] := m[3]
            } Else If (hdr_name:=SubStr(A_LoopField,1,(sep:=InStr(A_LoopField,":"))-1))
                _map[hdr_name] := SubStr(A_LoopField,sep+1)
        }
        return (header && _map.HasKey(header)) ? _map[header] : _map
    }
    
    QueryDataSize(hRequest) {
        chunk := 0
        r := DllCall("Winhttp\WinHttpQueryDataAvailable","UPtr",hRequest,"UInt*",chunk)
        return chunk
    }
    
    ReadData(hRequest,size,_file) { ; for now bytesRead isn't actually used
        VarSetCapacity(buf,size,0)
        r := DllCall("Winhttp\WinHttpReadData","UPtr",hRequest,"UPtr",&buf,"UInt",size,"UInt*",bytesRead)
        w := _file.RawWrite(buf,size)
    }
    
    CloseHandle(handle) {
        return DllCall("Winhttp\WinHttpCloseHandle","UPtr",handle)
    }
    
    Abort() {
        If this.hRequest && !(this.CloseHandle(this.hRequest))
                throw Exception("Unable to close request handle.",-1)
        If this.hConnect && !(this.CloseHandle(this.hConnect))
            throw Exception("Unable to close connect handle.",-1)
        If this.hSession && !(this.CloseHandle(this.hSession))
            throw Exception("Unable to close session handle.",-1)
        this.hRequest := this.hConnect := this.hSession := 0
    }
}



; dbg(_in) { ; AHK v1
    ; Loop, Parse, _in, `n, `r
        ; OutputDebug, AHK: %A_LoopField%
; }


; ====================================================================
; list of header codes
; ====================================================================
; accept = 24
; accept-charset = 25
; accept-encoding = 26
; accept-language = 27
; accept-ranges = 42
; age = 48
; allow = 7
; authentication-info = 76
; authorization = 28
; cache-control = 49
; connection = 23
; content-base = 50
; content-description = 4
; content-disposition = 47
; content-encoding = 29
; content-id = 3
; content-language = 6
; content-length = 5
; content-location = 51
; content-md5 = 52
; content-range = 53
; content-transfer-encoding = 2
; content-type = 1
; cookie = 44
; cost = 15
; custom = 65535
; date = 9
; derived-from = 14
; etag = 54
; expect = 68
; expires = 10
; forwarded = 30
; from = 31
; host = 55
; if-match = 56
; if-modified-since = 32
; if-none-match = 57
; if-range = 58
; if-unmodified-since = 59
; last-modified = 11
; link = 16
; location = 33
; max = 78
; max-forwards = 60
; message-id = 12
; mime-version = 0
; orig-uri = 34
; passport-config = 78
; passport-urls = 77
; pragma = 17
; proxy-authenticate = 41
; proxy-authorization = 61
; proxy-connection = 69
; proxy-support = 75
; public = 8
; range = 62
; raw-headers = 21
; raw-headers-crlf = 22
; referer = 35
; refresh = 46
; request-method = 45
; retry-after = 36
; server = 37
; set-cookie = 43
; status-code = 19
; status-text = 20
; title = 38
; transfer-encoding = 63
; unless-modified-since = 70
; upgrade = 64
; uri = 13
; user-agent = 39
; vary = 65
; version = 18
; via = 66
; warning = 67
; www-authenticate = 40



