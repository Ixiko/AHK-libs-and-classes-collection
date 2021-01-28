; http://ahkscript.org/germans/forums/viewtopic.php?t=8918
/*
I should add, however, that it is NOT a general-purpose solution.
The client does not yet understand "transfer encoding".
If a server that sends its data "chunked" is caught, an MsgBox is output and the connection is terminated by timeout.
However, the content could be read.
(That's next on the todo list)
Apart from that, the client already has a lot of extras...
The cookie system works meanwhile with all 3 variants (Netscape, RFC 2109 and RFC 2965) perfectly.
Multipart messages (HTTP/1.1+) are also sent and received without problems (apart from "transfer encoding: chunked")
Requests with form data can be created and sent relatively easily.

I want to add the following features:
Transfer encoding: chunked (required for HTTP/1.1)
An XML parser (object class)
Transfer encoding: deflate (compression -> will I implement with "zlib")
*/

url(url) { ;RFC 1738
  if (isobject(url) && url.scheme)
    return url
  keys := ["url", "scheme", "username", "password", "host", "port", "resource", "path", "query", "fragment", "dir", "file"]
  if (!regexmatch(murl := url, "(?P<scheme>[^:]+):/{0,2}(?P<schemespec>.*)", m))
    return
  regexmatch(mschemespec, ((instr(mschemespec, "@")) ? "(?P<login>[^@]*)@" : "") "(?P<hostresourcefragment>.*)", m)
  regexmatch(mlogin, "(?P<username>[^:]*):{0,1}(?P<password>.*)", m)
  regexmatch(mhostresourcefragment, "(?P<hostport>[^/]*)(?P<resourcefragment>.*)", m)
  regexmatch(mhostport, "(?P<host>[^:]+):{0,1}(?P<port>.*)", m)
  regexmatch(mresourcefragment, "(?P<resource>[^#]*)(?P<fragment>#{0,1}.*)", m)
  regexmatch(mresource, "(?P<path>[^?;]*)(?P<query>[?;]{0,1}.*)", m)
  if (p := instr(mdir := mpath, "/", 0, 0)) {
    mdir := substr(mpath, 1, p)
    mfile := substr(mpath, p+1)
  }
  o := []
  if (q := substr(mquery, 2)) {
    o.queryarray := []
    Loop, parse, q, &
      o.queryarray[substr(l := A_LoopField, 1, (p := instr(l, "="))-1)] := substr(l, p+1)
  }
  for i, key in keys
    o[key] := m%key%
  return o
}

http_makeosversion() {
  VarSetCapacity(verinfo, 276, 0)
  NumPut(276, verinfo, 0, "uint")
  DllCall("GetVersionExW", "ptr", &verinfo)
  ver := "Windows" ((NumGet(verinfo, 16, "uint")=2) ? " NT" : "")
  return ver " " NumGet(verinfo, 4, "uint") "." NumGet(verinfo, 8, "uint")
}

http_makeuseragent(name="", versionmajor=1, versionminor=0, link="") {
  uagent := "Mozilla/5.0 (compatible; " ((link) ? "+" link "; " : "") http_makeosversion() ") "
  uagent .= ((name="") ? substr(A_ScriptName, 1, (p:=instr(A_ScriptName, ".", 0, 0)) ? p-1 : 0) : name)
  return uagent "/" versionmajor "." versionminor
}

http_getdate(httpdate) { ;RFC 1123 and RFC 850
  static mon := {Jan:1, Feb:2, Mar:3, Apr:4, May:5, Jun:6, Jul:7, Aug:8, Sep:9, Oct:10, Nov:11, Dec:12}
  if (!regexmatch(httpdate, "\s*(?P<WDay>[a-zA-Z]{3})\s*,\s*(?P<Day>\d+)\s+(?P<Mon>[a-zA-z]{3})\s+(?P<Year>\d{4})\s+(?P<Hour>\d+):(?P<Min>\d+):(?P<Sec>\d+)\s*(?P<Zone>.*)", m)) {
    if (!regexmatch(httpdate, "\s*(?P<Weekday>[a-zA-Z]+)\s*,\s*(?P<Day>\d+)-(?P<Mon>[a-zA-z]{3})-(?P<SYear>\d+)\s+(?P<Hour>\d+):(?P<Min>\d+):(?P<Sec>\d+)\s*(?P<Zone>.*)", m))
      return ""
  }
  if (mSYear!="")
    mYear := substr(A_YYYY, 1, 4-strlen(mSYear)) mSYear
  r := mYear ((mon[mMon]<10) ? "0" : "") mon[mMon] ((mDay<10) ? "0" : "") (mDay+0)
  r .= ((mHour<10) ? "0" : "") (mHour+0) ((mMin<10) ? "0" : "") (mMin+0) ((mSec<10) ? "0" : "") (mSec+0)
  return r
}

http_makedate(date="", local=0) { ;RFC 1123
  static wday := {1:"Sun", 2:"Mon", 3:"Tue", 4:"Wed", 5:"Thu", 6:"Fri", 7:"Sat"}
  static mon := {1:"Jan", 2:"Feb", 3:"Mar", 4:"Apr", 5:"May", 6:"Jun", 7:"Jul", 8:"Aug", 9:"Sep", 10:"Oct", 11:"Nov", 12:"Dec"}
  if (!date)
    date := A_NowUTC
  if (local) {
    timezone := A_NowUTC
    timezone -= A_Now, sec
    date += timezone, sec
  }
  if (!regexmatch(date, "\s*(?P<Year>\d{4})(?P<Mon>\d{2})(?P<Day>\d{2})(?P<Hour>\d{2})(?P<Min>\d{2})(?P<Sec>\d{2})", m))
    return ""
  date -= 16010101, days
  return wday[mod(date+2, 7)] ", " mDay " " mon[mMon+0] " " mYear " " mHour ":" mMin ":" mSec " GMT"
}

writeprivateprofile(file, section, key, value="") {
  if (!instr(file, ":"))
    file := A_WorkingDir ((substr(A_WorkingDir, 0)="\") ? "" : "\") ((substr(file, 1, 1)="\") ? substr(file, 2) : file)
  DllCall("CreateDirectoryW", "wstr", substr(file, 1, instr(file, "\", 0, 0)), "ptr", 0)
  if (value="")
    return DllCall("WritePrivateProfileStringW", "wstr", section, "wstr", key, "ptr", 0, "wstr", file)
  return DllCall("WritePrivateProfileStringW", "wstr", section, "wstr", key, "wstr", value, "wstr", file)
}

getprivateprofile(file, section="", key="") {
  if (!instr(file, ":"))
    file := A_WorkingDir ((substr(A_WorkingDir, 0)="\") ? "" : "\") ((substr(file, 1, 1)="\") ? substr(file, 2) : file)
  if (!fileexist(file))
    return ""
  if (section="") {
    VarSetCapacity(buf, (s := 1024)*2, 0)
    while ((r := DllCall("GetPrivateProfileSectionNamesW", "ptr", &buf, "uint", s, "wstr", file, "uint"))=s-2)
      VarSetCapacity(buf, (s *= 2)*2, 0)
    o := 0
    sections := []
    while (o<r*2 && (str := strget(&buf+o, r-round(o/2), "utf-16"))) {
      sections.insert(str)
      o += StrPut(str, "utf-16")*2
    }
    return sections
  }
  if (key="") {
    VarSetCapacity(buf, (s := 1024)*2, 0)
    while ((r := DllCall("GetPrivateProfileSectionW", "wstr", section, "ptr", &buf, "uint", s, "wstr", file, "uint"))=s-2)
      VarSetCapacity(buf, (s *= 2)*2, 0)
    o := 0
    keys := []
    while (o<r*2 && (str := strget(&buf+o, r-round(o/2), "utf-16"))) {
      keys[substr(str, 1, (p := instr(str, "="))-1)] := substr(str, p+1)
      o += StrPut(str, "utf-16")*2
    }
    return keys
  }
  VarSetCapacity(buf, (s := 1024)*2, 0)
  while ((r := DllCall("GetPrivateProfileStringW", "wstr", section, "wstr", key, "ptr", 0, "ptr", &buf, "uint", s, "wstr", file, "uint"))=s-2)
    VarSetCapacity(buf, (s *= 2)*2, 0)
  return strget(&buf, r, "utf-16")
}

urlencode(url, encoding="utf-8") { ;RFC 3986
  static lA := asc("a"), uA := asc("A"), n := asc("0")
  static accept := {asc("-"):1, asc("_"):1, asc("."):1, asc("~"):1}
  static h := {0:0, 1:1, 2:2, 3:3, 4:4, 5:5, 6:6, 7:7, 8:8, 9:9, 10:"A", 11:"B", 12:"C", 13:"D", 14:"E", 15:"F"}
  Loop, parse, url
  {
    VarSetCapacity(b, 4, 0)
    StrPut(A_LoopField, &b, 4, encoding)
    x := NumGet(b, 0, "uint")
    if ((x>=lA && x<=lA+25) || (x>=uA && x<=uA+25) || (x>=n && x<=n+9) || (accept[x])) {
      o .= A_LoopField
      continue
    }
    Loop, 4 {
      v := (x>>((A_Index-1)*8))&0xFF
      if (v)
        o .= "%" h[(v>>4)&0xF] h[v&0xF]
    }
  }
  return o
}

urldecode(url, encoding="utf-8") { ;RFC 3986
  VarSetCapacity(b, strlen(url)*4, 0)
  o := 0
  while (url) {
    if ((c := substr(url, 1, 1))="%") {
      h := "0x" substr(url, 2, 2)
      url := substr(url, 4)
      NumPut(h, b, o, "uchar")
      o += 1
      continue
    }
    NumPut(asc(c), b, o, "uchar")
    o += 1
    url := substr(url, 2)
  }
  return strget(&b, o, encoding)
}

class httprequest {
  __new(method="GET", url="") {
    global httpcookie
    this.cookie := new httpcookie(this)
    this.packageSize := 2816
    this.encoding := "utf-8"
    this.urlEncoding := "utf-8"
    this.timeout := 20000
    this.reset(method, url)
  }
  reset(method="GET", url="") {
    this.method := method
    this.url := (url="") ? this.url : url
    this.versionmajor := "1"
    this.versionminor := "1"
    this.header := []
    this.content := ""
    this.header["User-Agent"] := http_makeuseragent()
    this.header["Accept"] := "*/*"
    this.header["Accept-Language"] := "en-us"
    this.header["Accept-Charset"] := "ISO-8859-1,utf-8;q=0.7,*;q=0.7"
    this.header["Keep-Alive"] := "115"
    this.header["Connection"] := "keep-alive"
    this.header["X-Requested-With"] := "AutoHotkey/" A_AhkVersion
    return 1
  }
  setUrl(url="") {
    this.url := url
  }
  setMethod(method="GET") {
    this.method := method
  }
  appendHeader(header, value="") {
    this.header[header] := (this.header[header]) ? this.header[header] "`; " value : value
    return this.header[header]
  }
  setHeader(header, value="") {
    this.header[header] := value
    return this.header[header]
  }
  setContent(content, contenttype="*/*") {
    this.content := content
    this.header["Content-type"] := (content) ? contenttype : ""
    return (content) ? 1 : 0
  }
  setContentFile(file, contenttype="*/*") {
    global memory
    r := (this.content := new memory("file", file)) ? 1 : 0
    if (r)
      this.header["Content-type"] := contenttype
    return r
  }
  setContentForm(p*) {
    if (this.header["Content-type"]!="application/x-www-form-urlencoded")
      this.content := []
    Loop, % floor(p.maxindex()/2) {
      i := (A_Index-1)*2+1
      this.content[p[i]] := p[i+1]
    }
    this.header["Content-type"] := "application/x-www-form-urlencoded"
  }
  build(url="", method="") {
    global memory
    if (!(url := url((url!="") ? url : this.url)))
      return ""
    this.header["Host"] := url.host ((url.port) ? ":" url.port : "")
    this.header["Cookie"] := this.cookie.getCookie(url)
    encsize := (this.encoding="utf-16" || this.encoding="cp1200") ? 2 : 1
    if (this.header["Content-type"]="application/x-www-form-urlencoded") {
      for key, value in this.content
        c .= ((c) ? "&" : "") urlencode(key, this.urlEncoding) "=" urlencode(value, this.urlEncoding)
      contentmem := new memory(strput(c, this.encoding)-encsize)
      contentmem.encoding := this.encoding
      contentmem.strput(c)
    }
    else if (!isobject(this.content)) {
      contentmem := new memory(strput(this.content, this.encoding)-encsize)
      contentmem.encoding := this.encoding
      contentmem.strput(this.content)
    }
    else
      contentmem := this.content
    this.header["Content-Length"] := (contentmem.size) ? contentmem.size : ""
    method := (method!="") ? method : this.method
    h := method " " url.resource " HTTP/" this.versionmajor "." this.versionminor "`r`n"
    for key, value in this.header {
      if (key!="" && value !="")
        h .= key ": " value "`r`n"
    }
    h .= "`r`n"
    mem := new memory((hdrlen := strput(h, this.encoding)-encsize)+contentmem.size, 0)
    mem.encoding := this.encoding
    mem.strPut(h)
    mem.moveFrom(contentmem, 0, hdrlen)
    return mem
  }
  readable(url="", method="") {
    return this.build(url, method).strget()
  }
  send(url="", method="") {
    global tcp, httpresponse
    this.response := ""
    if (!(mem := this.build(url, method)))
      return 0
    if (!(tcp := new tcp))
      return 0
    tcp.timeout := this.timeout
    this.url := url := url((url!="") ? url : this.url)
    if (!tcp.connect(url.host, (url.port) ? url.port : 80))
      return 0
    if ((this.packageSize) && !(this.versionmajor=1 && this.versionminor=0)) {
      size := mem.size
      ptr := mem.ptr
      while (size) {
        s := ((size>this.packageSize) ? this.packageSize : size)
        if (tcp.send({ptr:ptr, size:s})!=s)
          return ""
        size -= s
        ptr += s
      }
    }
    else {
      if (tcp.send(mem)!=mem.size)
        return 0
    }
    this.socket := tcp
    this.response := new httpresponse(this)
    return 1
  }
  recvNext() {
    global memory
    if (!(tcp := this.socket))
      return -1
    if (this.response.result)
      return 1
    if (!(mem := tcp.recv()))
      return -1
    if (!this.response.memory.size) {
      recvmem := this.response.memory := new memory(mem.size)
      recvmem.encoding := this.response.encoding
      recvmem.moveFrom(mem.ptr, mem.size)
    }
    else {
      recvmem := this.response.memory
      recvmem.realloc((o := ((recvmem.size) ? recvmem.size : 0))+mem.size)
      recvmem.moveFrom(mem.ptr, mem.size, o)
    }
    return (this.response.__init()) ? 1 : 0
  }
  recv(follow=1) {
    r := 0
    while (r=0) {
      r := this.recvNext()
    }
    if (r<0)
      return 0
    while (follow && this.response.header["Location"]) {
      this.reset("GET")
      this.send(this.response.header["Location"])
      r := 0
      while (r=0) {
        r := this.recvNext()
      }
      if (r<0)
        return 0
    }
    return 1
  }
  __request(method, url, returntype="") {
    if (!this.send(url, method))
      return ""
    if (!this.recv())
      return ""
    if (returntype="xml")
      r := this.response.getContentXml()
    else if (instr(returntype, "file:")=1)
      return this.response.saveContent(substr(returntype, instr(returntype, ":")+1))
    else
      r := this.response.getContent()
    this.reset()
    return r
  }
  get(url, returntype="") {
    return this.__request("GET", url, returntype)
  }
  post(url, returntype="") {
    return this.__request("POST", url, returntype)
  }
}

class httpresponse {
  __new(request) {
    this.tcp := request.tcp
    this.request := (isobject(request)) ? request : ""
    this.encoding := (request.encoding) ? request.encoding : "utf-8"
  }
  __init() {
    global memory
    mem := this.memory
    str := mem.strGet()
    if (!(pA := instr(str, "`r`n`r`n")) && !(pB := instr(str, "`n`n")))
      return 0
    contentoffset := ((pA && pB) ? ((pA<pB) ? pA+2 : pB) : ((pA) ? pA+2 : pB))+1
    this.content := new memory(mem.size-contentoffset)
    this.content.moveFrom(mem.ptr+contentoffset, mem.size-contentoffset)
    if (!this.header) {
      this.header := []
      hdr := substr(str, 1, ((pA && pB) ? ((pA<pB) ? pA : pB) : ((pA) ? pA : pB))-1)
      hdr := regexreplace(regexreplace(regexreplace(hdr, "`r`n", "`n"), "`r", "`n"), "`t", " ")
      Loop, parse, hdr, `n
      {
        l := A_LoopField
        if (A_Index=1) {
          if (!(p := instr(l, " ")))
            return ""
          ver := substr(l, 1, p-1)
          stat := substr(l, p+1)
          if (!(p := instr(ver, "/")))
            return ""
          ver := substr(ver, p+1)
          if (!(p := instr(ver, ".")))
            return ""
          this.versionmajor := substr(ver, 1, p-1)
          this.versionminor := substr(ver, p+1)
          if (!(p := instr(stat, " ")))
            return ""
          this.status := substr(stat, 1, p-1)
          this.statusText := substr(stat, p+1)
          continue
        }
        if (!(p := instr(l, ":")))
          continue
        key := substr(l, 1, p-1)
        value := substr(l, p+1)
        while(substr(key, 0)=" ")
          key := substr(key, 1, -1)
        while(substr(value, 1, 1)=" ")
          value := substr(value, 2)
        if (key="" || value="")
          continue
        if (this.header[key]) {
          if (isobject(this.header[key]))
            this.header[key].insert(value)
          else
            this.header[key] := [this.header[key], value]
        }
        else
          this.header[key] := value
      }
    }
    if (this.header["Content-Length"]!="") {
      this.progress := mem.size/(contentoffset+this.header["Content-Length"])
      if (mem.size>=contentoffset+this.header["Content-Length"])
        r := 1
    }
    else if (this.header["Transfer-Encoding"]="chunked") {
      r := this.__chunked(0)
    }
    else if (this.header["Transfer-Encoding"])
      MsgBox, % "TRANSFER-ENCODING: " this.header["Transfer-Encoding"]
    else
      r := 1
    if (!r)
      return 0
    if (this.header["Set-Cookie"])
      this.request.cookie.setCookie(this.request.url, this.header["Set-Cookie"], this.header["Date"])
    if (this.header["Set-Cookie2"])
      this.request.cookie.setCookie2(this.request.url, this.header["Set-Cookie2"], this.header["Date"])
    this.progress := 1.000000
    for key, value in this.header
      msg .= key " = " value "`n"
    ;MsgBox, % "HEADER:`n`n" msg
    this.memory := ""
    this.request.socket := ""
    return 1
  }
  __chunked(mem=0) {
    global memory
    static maxsizelen := 32
    o := 0
    c := this.content
    s := 1
    while (s>0) {
      if (!(s := c.strget(o, maxsizelen)))
        return 0
      o += instr(s, "`n")
      regexmatch(s, "([a-fA-F0-9]+)", s)
      s := "0x" s1
      if (mem) {
        if (!n) {
          n := new memory(s+0)
          n.moveFrom(c.ptr+o, s+0)
        }
        else {
          n.realloc((os := n.size)+s)
          n.moveFrom(c.ptr+o, s+0, os)
        }
      }
     ; MsgBox, % "SIZE: " s+0 "`nCONTENT: " n.strget()
      o += s+2
    }
    if (mem)
      return n
    return 1
  }
  __content() {
    if (this.header["Transfer-Encoding"]="chunked")
      return this.__chunked(1)
    else
      return this.content
  }
  getContent(encoding="") {
    mem := this.__content()
    mem.encoding := (encoding) ? encoding : this.encoding
    return mem.strget()
  }
  getContentXml(encoding="") {
    global xmlparse
    return new xmlparse(this.getContent(encoding))
  }
  saveContent(filename, encoding="") {
    if (!(f := fileopen(filename, "w", encoding)))
      return 0
    mem := this.__content()
    f.rawwrite(mem.ptr, mem.size)
    f.close()
    return 1
  }
}

class httpcookie {
  __new(request) {
    this.request := request
    this.cookies := []
    this.enable := 1
  }
  __setCookie(url, cookie, httpdate="") {
    o := []
    Loop, parse, cookie, % ";", % " `t"
    {
      if (p := instr(l := A_LoopField, "=")) {
        key := substr(l, 1, p-1)
        value := substr(l, p+1)
        while (substr(key, 0)=" ")
          key := substr(key, 1, -1)
        while (substr(value, 1, 1)=" ")
          value := substr(value, 2)
      }
      else {
        key := l
        value := 1
      }
      if (A_Index=1) {
        cookiekey := key
        cookievalue := value
        continue
      }
      o[key] := value
    }
    if (p := instr(cookiepath := url.host, ".", 0, 0, 2))
      cookiepath := substr(cookiepath, p+1)
    cookiepath .= (o["Path"]) ? o["Path"] : url.dir
    if (!isobject(this.cookies[cookiepath]))
      this.cookies[cookiepath] := []
    cookiepath := this.cookies[cookiepath]
    cookiepath[cookiekey] := {value:urldecode(cookievalue)}
    if (exp := http_getdate(o["Expires"])) {
      if (date := http_getdate(httpdate)) {
        exp -= date, sec
        _exp := A_NowUTC
        _exp += exp, sec
        cookiepath[cookiekey].expires := _exp
      }
      else
        cookiepath[cookiekey].expires := exp
    }
    else if (o["Max-Age"]) {
      exp := A_NowUTC
      exp += o["Max-Age"]
      cookiepath[cookiekey].expires := exp
    }
    if (o["Secure"])
      cookiepath[cookiekey].secure := 1
    cookiepath[cookiekey].version := o["Version"]
    cookiepath[cookiekey].domain := o["Domain"]
    cookiepath[cookiekey].comment := o["Comment"]
    cookiepath[cookiekey].path := o["Path"]
    return 1
  }
  setCookie(url, cookie, httpdate="") {
    if (!isobject(url))
      url := url(url)
    n := 0
    if (isobject(cookie)) {
      for key, cook in cookie
        n += this.__setCookie(url, cook, httpdate)
    }
    else
      n += this.__setCookie(url, cookie, httpdate)
    return n
  }
  setCookie2(url, cookie, httpdate) {
    return this.setCookie(url, cookie, httpdate)
  }
  getCookie(url) {
    if (!isobject(url))
      url := url(url)
    Loop, 2
    {
      if (p := instr(cookiepath := url.host, ".", 0, 0, 2))
        cookiepath := substr(cookiepath, p+1)
      if (A_Index=1)
        cookiepath .= url.dir
      else
        cookiepath .= "/"
      for key, info in this.cookies[cookiepath] {
        if ((info.expires!="") && A_NowUTC>info.expires) {
          this.cookie[cookiepath] := ""
          continue
        }
        if (info.version!="")
          version := info.version
        if (info.domain!="")
          domain := info.domain
        o .= ((o) ? "; " : "") key "=" urlencode(info.value) ((domain!="") ? "; Domain:" domain : "")
      }
    }
    if (o="")
      return
    return ((version!="") ? "$Version=" version "; " : "") o
  }
  save(file) {
    n := 0
    for path, cpath in this.cookies {
      for cookie, ccookie in cpath {
        for key, value in ccookie
          n += (writeprivateprofile(file, "cookie:" path "?" cookie, key, value)) ? 1 : 0
      }
    }
    return n
  }
  load(file) {
    n := 0
    for i, section in getprivateprofile(file) {
      if (instr(section, "cookie:")!=1)
        continue
      _section := substr(section, strlen("cookie:")+1)
      if (!(p := instr(_section, "?")))
        continue
      path := substr(_section, 1, p-1)
      cookie := substr(_section, p+1)
      if (!isobject(this.cookies[path]))
        this.cookies[path] := []
      for i in (this.cookies[path][cookie] := getprivateprofile(file, section))
        n += 1
    }
    return n
  }
}

class socket {
  __new(p*) {
    global winsock
    this.winsock := new winsock
    this.received := 0
    this.sent := 0
    this.timeout := 20000
    if (!this.__init(p*))
      return ""
    if ((this.socket := DllCall("ws2_32\socket", "int", this.addressfamily, "int", this.type, "int", this.protocol, "ptr"))=-1)
      return ""
  }
  __delete() {
    DllCall("ws2_32\closesocket", "ptr", this.socket)
  }
  __received(add=0) {
    static received := 0
    this.received += add
    return received+add
  }
  __sent(add=0) {
    static sent := 0
    this.sent += add
    return sent+add
  }
  connectAddr(addr, addrlen) {
    return (DllCall("ws2_32\connect", "ptr", this.socket, "ptr", addr, "int", addrlen)=0) ? 1 : 0
  }
  connect(host, port) {
    addr := this.addrinfo(host, port)
    r := this.connectAddr(addr.addr, addr.len)
    this.freeaddrinfo(addr)
    return r
  }
  disconnect() {
    DllCall("ws2_32\closesocket", "ptr", this.socket)
    this.socket := DllCall("ws2_32\socket", "int", this.addressfamily, "int", this.type, "int", this.protocol, "ptr")
  }
  connected() {
    return 1
    return (DllCall("ws2_32\recv", "ptr", this.socket, "ptr", 0, "int", 0, "int", 0)=0) ? 1 : 0
  }
  send(msg) {
    if (isobject(msg))
      s := DllCall("ws2_32\send", "ptr", this.socket, "ptr", msg.ptr, "int", msg.size, "int", 0)
    else
      s := DllCall("ws2_32\send", "ptr", this.socket, "astr", msg, "int", strlen(msg), "int", 0)
    if (s<0)
      return 0
    this.__sent(s)
    return s
  }
  recvlen() {
    VarSetCapacity(blen, 4, 0)
    DllCall("ws2_32\ioctlsocket", "ptr", this.socket, "int", 0x4004667F, "ptr", &blen)
    return NumGet(blen, 0, "int")
  }
  recv(timeout="") {
    global memory
    if (!this.connected())
      return ""
    timeout := (timeout!="") ? timeout : this.timeout
    if (timeout>0) {
      timeout += A_TickCount
      while(A_TickCount<timeout) {
        if ((len := this.recvlen())>0)
          break
        sleep, 200
      }
    }
    else
      len := this.recvlen()
    if (!len)
      return ""
    mem := new memory(len)
    if ((l := DllCall("ws2_32\recv", "ptr", this.socket, "ptr", mem.ptr, "int", len, "int", 0))!=len) {
      this.__received((l<0) ? 0 : l)
      return ""
    }
    this.__received((l<0) ? 0 : l)
    mem.sent := l
    return mem
  }
  addrinfo(host, port) {
    VarSetCapacity(hints, 16+4*A_PtrSize, 0)
    NumPut(this.addressfamily, hints, 4, "int")
    NumPut(this.type, hints, 8, "int")
    NumPut(this.protocol, hints, 12, "int")
    DllCall("ws2_32\getaddrinfo", "astr", host, "astr", port, "ptr", &hints, "ptr*", addrinfo)
    o := []
    o.addr := NumGet(addrinfo+0, 16+2*A_PtrSize, "ptr")
    o.len := NumGet(addrinfo+0, 16, "ptr")
    o.addrinfo
    return o
  }
  freeaddrinfo(addr) {
    if (isobject(addr))
      addr := addr.addrinfo
    DllCall("ws2_32\freeaddrinfo", "ptr", addr)
  }
}

class tcp extends socket {
  __init(ipversion=4) {
    if (ipversion=4)
      this.addressfamily := 2
    else if (ipversion=6)
      this.addressfamily := 23
    else
      return 0
    this.type := 1
    this.protocol := 6
    return 1
  }
  ipversion(setversion=4) {
    this.__delete()
    return (this.__new(setversion)) ? 1 : 0
  }
}

class winsock {
  __new(version_major=2, version_minor=0) {
    if (!this.__starts()) {
      DllCall("LoadLibrary", "str", "ws2_32")
      VarSetCapacity(wsadata, 1024, 0)
      if (DllCall("ws2_32\WSAStartup", "ushort", version_major | (version_minor<<16), "ptr", &wsadata)!=0)
        return ""
    }
    this.__starts(1)
  }
  __starts(set="__?_") {
    static starts := 0
    if (set="__?_")
      return starts
    return (starts += ((set>0) ? 1 : ((starts>0) ? -1 : 0)))
  }
  __delete() {
    if (!this.__starts(-1)) {
      DllCall("ws2_32\WSACleanup")
      DllCall("FreeLibrary", "ptr", DllCall("GetModuleHandle", "str", "ws2_32", "ptr"))
    }
  }
}

class memory {
  __new(size, fill=0) {
    if ((size="file" || size="f") && fileexist(fill)) {
      if (!(file := fileopen(fill, "r")))
        return ""
      size := file.length
    }
    this.size := size
    if (!(this.ptr := DllCall("GlobalAlloc", "uint", 0, "ptr", size, "ptr")))
      return ""
    if (file) {
      if (file.rawread(this.ptr+0, this.size)<file.length)
        return ""
    }
    else if (fill!="")
      this.fill(fill)
    this.encoding := "utf-8"
  }
  __delete() {
    DllCall("GlobalFree", "ptr", this.ptr)
  }
  realloc(size, fill=0) {
    if (newptr := DllCall("GlobalAlloc", "uint", 0, "ptr", size, "ptr")) {
      if (this.move(newptr, size)) {
        DllCall("GlobalFree", "ptr", this.ptr)
        this.size := size
        return (this.ptr := newptr)
      }
    }
    return 0
  }
  move(dstptr, size=0, srcoffset=0) {
    if (isobject(dstptr))
      dstptr := dstptr.ptr
    len := (size>0 && size<=this.size-srcoffset) ? size : this.size-srcoffset
    DllCall("RtlMoveMemory", "ptr", dstptr, "ptr", this.ptr+srcoffset, "ptr", len)
    return len
  }
  moveFrom(srcptr, size=0, dstoffset=0) {
    if (isobject(srcptr))
      srcptr := srcptr.ptr
    len := (size>0 && size<=this.size-dstoffset) ? size : this.size-dstoffset
    DllCall("RtlMoveMemory", "ptr", this.ptr+dstoffset, "ptr", srcptr, "ptr", len)
    return len
  }
  maxSize() {
    return DllCall("GlobalSize", "ptr", this.ptr, "ptr")
  }
  fill(value=0, offset=0, size=0) {
    DllCall("RtlFillMemory", "ptr", this.ptr+offset, "ptr", (size>0) ? size : this.size-offset, "uchar", value)
  }
  zero(offset=0, size=0) {
    DllCall("RtlZeroMemory", "ptr", this.ptr+offset, "ptr", (size>0) ? size : this.size-offset)
  }
  compare(dstptr, size=0, srcoffset=0) {
    if (isobject(dstptr))
      dstptr := dstptr.ptr
    len := (size>0 && size<=this.size-srcoffset) ? size : this.size-srcoffset
    return (DllCall("ntdll\RtlCompareMemory", "ptr", dstptr, "ptr", this.ptr+srcoffset, "ptr", len)=size) ? 1 : 0
  }
  get(offset=0, type="ptr") {
    return NumGet(this.ptr+0, offset, type)
  }
  put(value, offset=0, type="ptr") {
    NumPut(value, this.ptr+0, offset, type)
  }
  strGet(offset=0, length=0) {
    return StrGet(this.ptr+offset, (!length) ? this.size-offset : length, this.encoding)
  }
  strPut(string, offset=0, length=0) {
    StrPut(string, this.ptr+offset, (!length) ? this.size-offset : length, this.encoding)
  }

  }

class xmlparse {
  __new(xml) {
    this.xml := xml
  }
  __findFirst(str, a, b, returnpos=1) {
    pA := instr(str, a)
    pB := instr(str, b)
    if (returnpos)
      return (pA && pB) ? ((pA<pB) ? pA : pB) : ((pA) ? pA : pB)
    return (pA && pB) ? ((pA<pB) ? a : b) : ((pA) ? a : b)
  }
  __trim(str, t=" ") {
    while (substr(str, 1, 1)=t)
      str := substr(str, 2)
    while (substr(str, 0)=t)
      str := substr(str, 1, -1)
    return str
  }
  __getOptions(xml) {
    s := substr(xml, instr(xml, "<"))
    pA := instr(s, " ")
    pB := instr(s, ">")
    if ((pA && pB && pB<pA) || (pB && !pA))
      return
    o := substr(s, pA+1, instr(s, ">", 0, pA+1)-pA-1)
    opts := []
    while (o := this.__trim(o))
    {
      if (!(p := this.__findFirst(o, " ", "=")))
      {
        if (o := this.__trim(o))
          opts.insert(o, " ")
        return opts
      }
      var := this.__trim(substr(o, 1, p-1))
      e := substr(o, p, 1)
      o := this.__trim(substr(o, p+1))
      if (e=" ")
      {
        opts.insert(var, " ")
        continue
      }
      if (this.__findFirst(o, """", "'")=1)
        value := substr(o, 2, (p:=instr(o, substr(o, 1, 1), 0, 2))-2)
      else
        value := substr(o, 1, (p:=instr(o, " "))-1)
      o := substr(o, p+1)
      opts.insert(var, value)
    }
    return opts
  }
  __getContent(xml) {
    c := substr(xml, instr(xml, ">")+1)
    return substr(c, 1, instr(c, "</", 0, 0)-1)
  }
  __readTag(xml)
  {
    s := substr(xml, instr(xml, "<"))
    t := substr(s, 2, this.__findFirst(s, " ", ">")-2)
    if (this.__findFirst(s, "/>", ">", 0)="/>")
      return substr(s, 1, instr(s, "/>")+1)
    b := substr(s, (p := instr(s, ">"))+1)
    s := substr(s, 1, p)
    pA := instr(b, "</" t ">")
    pB := this.__findFirst(b, "<" t " ", "<" t ">")
    if ((pA && pB && pB<pA) || (pB && !pA))
    {
      x := substr(b, 1, pB-1) this.__readTag(substr(b, pB))
      b := substr(b, strlen(x)+1)
      x .= substr(b, 1, instr(b, "</" t ">")-1)
      return s x "</" t ">"
    }
    if (pA)
      return s substr(b, 1, pA-1) "</" t ">"
    return s
  }
  find(tagname, occurrence=1) {
    global xmlparse
    while (occurrence>=1) {
      p := (p) ? p+1 : 1
      pA := instr(this.xml, "<" tagname ">", 0, p)
      pB := instr(this.xml, "<" tagname " ", 0, p)
      if (!(p := (pA && pB) ? ((pA<pB) ? pA : pB) : ((pA) ? pA : pB)))
        return ""
      occurrence -= 1
    }
    t := this.__readTag(substr(this.xml, p))
    o := new xmlparse(this.__getContent(t))
    o.tag := tagname
    o.option := this.__getOptions(t)
    return o
  }
  content(tagname, occurrence=1) {
    return this.find(tagname, occurrence).xml
  }
  array(tagname) {
    o := []
    while (f := this.find(tagname, i := ((i) ? i+1 : 1)))
      o.insert(f)
    return (i>1) ? o : ""
  }
  query(tagname, options) {
    while (f := this.find(tagname, i := ((i) ? i+1 : 1))) {
      qok := 1
      for key, value in options {
        if (f.option[key]!=value) {
          qok := 0
          break
        }
      }
      if (qok)
        return f
    }
    return ""
  }
}
