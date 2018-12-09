	/*    	DESCRIPTION of function 
        	-------------------------------------------------------------------------------------------------------------------
			Description  	:	Object-oriented packaging http
			Link              	:	https://autohotkey.com/boards/viewtopic.php?t=21860
			Author         	:	arcticir
			Date	            	:	23-Aug-2016
			AHK-Version	:	AHK-V1?
			License         	:	
			Parameter(s)	:	input - url
													name 			- Naming
													head 			- parameter object
													option 			- parameter object
													type 			- Request method(get,post,head...)
													pug 				- Progress callback function
													end 				- Completion callback function
													decide 			- Get heads later, the specified function to determine whether to continue execution.
													gh 				- (true) Gets heads ; OR type:="head"
													agent 			- user-agent settings
													file 				- The path to save the download file
													fileName 		- Automatic file name,Its value is the default name can not be obtained when(as "Test.zip"), Need "file" the specified directory.
													fileExt 			- Similar. Specifies an alternate EXT
													bin 				- (true) Download file into a variable (f.bin)
													decode 		- (true) Decoding Web data (f.decode)
													json 				- (true) Converting Web data to object (f.json)
													hash 			- Specify type
													Verify 			- (true) Force verify size
													proxy
													charset
													referer
										Output:
													time - Time consuming
													heads - Output Headers
													list - Object-oriented Headers Item (f.list.Etag)
													size - data size
													err - Error message
													txet - page data
													bin - Save binary data files, If in
													hash - MD2/MD4/MD5/SHA1/SHA256/SHA384/SHA512, If in
													json - json-Object
													decode
													affix - Additional information
													gzip-size - Original size
													charset
			Remark(s)    	:	
			Dependencies	:	
			KeyWords    	:	
        	-------------------------------------------------------------------------------------------------------------------
	*/


oh(this,proxy:="",file:=""){
        IsObject(this)?"":this:={url:this,proxy:proxy,file:file}, this.time:=ahktime(), this.affix:=affix:=[],IsObject(this.head)?"":this.head:=[]
        ,this.post?(this.type:="post",IsObject(this.post)?oh_FormData(this,body):this.length:=StrPutVar(this.post,body,"utf-8")):""
        ,asynch := False,VarSetCapacity(callbackValue,A_PtrSize)
        ,VarSetCapacity(myStruct,60,0)
        ,numput(60,myStruct,0,"Uint") ; this dll function requires this to be set
        ,numput(1,myStruct,8,"Uint") ; SchemeLength
        ,numput(1,myStruct,20,"Uint") ; HostNameLength
        ;numput(1,myStruct,32,"Uint") ; UserNameLength
        ;numput(1,myStruct,40,"Uint") ; PasswordLength
        ,numput(1,myStruct,48,"Uint") ; UrlPathLength
        ,numput(1,myStruct,56,"Uint") ; ExtraInfoLength
        ,DllCall("Winhttp.dll\WinHttpCrackUrl","PTR",&(this.url),"UInt",StrLen(this.url),"UInt",0,"PTR",&myStruct)
        ,scheme := StrGet(NumGet(myStruct,4,"Ptr"),NumGet(myStruct,8,"UInt"))
        ;userName := StrGet(NumGet(myStruct,28,"Ptr"),NumGet(myStruct,32,"UInt"))
        ;password := StrGet(NumGet(myStruct,36,"Ptr"),NumGet(myStruct,40,"UInt"))
        ,hostName := StrGet(NumGet(myStruct,16,"Ptr"),NumGet(myStruct,20,"UInt"))
        ,port := NumGet(myStruct,24,"Int")
        ,urlPath := StrGet(NumGet(myStruct,44,"Ptr"),NumGet(myStruct,48,"UInt"))
        ,extraInfo := StrGet(NumGet(myStruct,52,"Ptr"),NumGet(myStruct,56,"UInt"))
        ,https := scheme = "https" ?(port:=port?port:443,True):False
        ,resource := urlPath . extraInfo
        if this.list
                IsObject(this.old)?"":this.old:=[],this.history.push(this.delete("list"))

;------                                                                         ------

        if (this.hs:=hSession := DllCall("Winhttp.dll\WinHttpOpen" ,uptr, &(this.Agent?this.Agent
                        :"Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.2806.0 Safari/537.36")
                        ,uint, this.proxy?3:1,uptr,this.proxy?&(this.proxy):0,uptr, 0,uint,asynch))
                and (this.hc:=hConnect:=DllCall("Winhttp.dll\WinHttpConnect",uptr,hSession,uptr,&hostName,ushort,port,uint,0))
                and (this.hr:=hRequest := DllCall("Winhttp.dll\WinHttpOpenRequest" ,uptr,hConnect ,uptr,this.type ? &(this.type) : 0 ,uptr,(resource) ? &resource : 0
                                ,uptr,(httpVersion) ? &httpVersion : 0 ,uptr,this.Referer ? &(this.Referer) : 0 ,uptr, 0 ,uint,(https) ? 0x00800000 : 0))
                for i,n in this.option
                {
                        VarSetCapacity(opt,sz:=NumSize(n)),NumPut(n,&opt,NumType(n))
                        if !DllCall("Winhttp.dll\WinHttpSetOption" ,uptr,hRequest ,uint,i ,uptr,&opt ,uint,sz)
                                this.err.="SetOption`t" i "-" n ": " A_LastError "-" ErrorMessage(A_LastError) "`n"
                }
                else    Return  oh_close(this,ErrorLevel "  " A_LastError " " ErrorMessage(A_LastError))

;------                                                                         ------

        for i,n in this.head
                ah .= i ": " n "`r`n"
        for i,n in {"Accept-Encoding":(this.gh?"":"gzip, ") "deflate"}
                this.head.haskey(i)?"":ah .= i ": " n "`r`n"

        VarSetCapacity(body) ? (i:=&body,n:=this.length?this.length:StrLen(body)*2) : i:=n:=0
        if !DllCall("Winhttp.dll\WinHttpSendRequest" ,uptr,hRequest ,uptr,&ah ,uint,StrLen(ah) ,uptr,i ,uint,n ,uint,n ,uptr,&callbackValue)
                Return  oh_close(this,"Send Request")

        if !DllCall("Winhttp.dll\WinHttpReceiveResponse",uptr,hRequest,uptr,0)
                Return  oh_close(this,"Response")

;------                                                                         ------

        VarSetCapacity(s, dwSize:=60000, 0)
        if DllCall("Winhttp.dll\WinHttpQueryHeaders",uptr,hRequest,uint,22,uptr,0,uptr, &s,UIntP, dwSize,uptr, 0)
        {
                VarSetCapacity(s,-1),this.heads:=s:=trim(s,"`n`r"),i:=InStr(s,"`r`n"),f:=StrSplit(SubStr(s,1,i-1), " ")
                ,this.list:=list:={HttpVersion:f[1],StatusCode:f[2],StatusText:f[3]}
                Loop, parse, % SubStr(s,i+2), `n, `r
                        (list[s:=Trim(SubStr(A_LoopField,1,InStr(A_LoopField,": ")-1))]
                                ? list[s].="; " Trim(SubStr(A_LoopField,InStr(A_LoopField,": ")+2))
                                : list[s]:= Trim(SubStr(A_LoopField,InStr(A_LoopField,": ")+2)))
        }
        if this.gh or (this.type="head") or (this.decide and (IsObject(f:=this.decide) or (f:=func(f))) ? f.call(this):"")
                return oh_close(this)

        if (len:=list["Content-Length"]) and this.pug and (isobject(this.pug) or this.pug:=func(this.pug))
        {
                ((i:=Round(len/1024)) < 1024) ?(Size_Units:=1024,Size_Total:= "/" i " K") : (Size_Units:=1048576,Size_Total:= "/" Round(i/1024, 1) " M")
                ,DllCall("QueryPerformanceFrequency","Int64*",Frequency)
                ,DllCall("QueryPerformanceCounter","Int64*",time_Mark)
                ,this.timeMark:=time_Mark,this.Frequency:=Frequency
        }

;------                                                                         ------

        Body := "",Size:=0,VarSetCapacity(dwDownloaded,8),r:=&dwSize
        Loop
        {
                dwSize := 0
                If (!DllCall("Winhttp.dll\WinHttpQueryDataAvailable",uptr,hRequest,uptr,r))
                        Return  oh_close(this,"DataAvailable")
                Else
                        dwSize := (dwSize)+0

                If (!dwSize)
                        Break

                VarSetCapacity(pszOutBuffer,(dwSize)+1,0)
                If !DllCall("Winhttp.dll\WinHttpReadData",uptr,hRequest,uptr,&pszOutBuffer,uint,dwSize,uptr,&dwDownloaded)
                {
                        this.err.="ReadData: " ErrorMessage(A_LastError) "`n"
                }
                Else
                {
                        VarSetCapacity(data, Size+dw:=Ord(dwDownloaded))
                        ,DllCall("RtlMoveMemory", "ptr", &data+Size, "ptr", &pszOutBuffer, "ptr", dw),Size+=dw

                        if this.pug and len
                        {
                                DllCall("QueryPerformanceCounter", "Int64*", Counter)
                                time:=(Counter-time_Mark)/Frequency
                                if  (time>=1)
                                {
                                this.pug.call({this:this,event:"Progres",total:len,Current:Size,Progres:Round(Size/Size_Units,1) Size_Total
                                ,scale:(Round(Size/len*100,1) " `%"),speed:(Round((((Size-Size_Mark)/1024)/time)) " KB")})
                                Size_Mark:=Size,time_Mark:=Counter
                                }
                        }
                }
                If (!dw) or (dwSize <= 0)
                        break
        }
        if this.pug
                this.pug.call({this:this,event:"Finish"})

;------                                                                         ------

        if (this.Verify or this.file or this.bin) and (len and (Size!=len))
                return oh_close(this,"Size Err:" Size "/" len)

        if InStr(list["Content-Encoding"],"gzip")
                size:=UnZipBuffer(&data, affix["gzip-size"]:=size, "",gzip),VarSetCapacity(data, size, 0)
                ,gzip:=DllCall("RtlMoveMemory", "ptr", &data, "ptr", &gzip, "ptr", Size)

        this.size:=size
        if this.hash
                this.hash:=oh_Hash(this.hash,&data,size)

        if this.bin or this.file=1
        {
                this.Delete("Bin"),this.SetCapacity("Bin",Size),DllCall("RtlMoveMemory","ptr",this.GetAddress("Bin"),"ptr",&data, "ptr",Size)
        }
        else    if this.file
        {
                if this.fileName
                {
                        if (s:=this.list["Content-Disposition"]) and r:=InStr(s, "filename=")
                                name:=(m:=InStr(s,";",,i:=r+10))?SubStr(s, i,m-i):SubStr(s, i)
                        this.file:=this.File "\" (name ? name : f.fileName)
                }
                else if f.fileExt
                {
                        if s:=this.list["Content-Type"]
                                ext:=SubStr(s, i:=InStr(s, "/")+1,(r:=InStr(s, ";"))?r-i:22)
                        this.file:=this.File "." (ext ? ext: this.fileExt)
                }
                FileExist(d:=SubStr(this.file,1,InStr(this.file,"\","",-1)))?"":DirCreate(d),FileOpen(this.file, "w").RawWrite(&data, size)
        }
        else
        {
                affix.charset:=eg:=this.charset?this.charset:(s:=InStr(t:=list["Content-Type"],"charset="))?substr(t,r:=s+8,(u:=InStr(t,";",,r))?u-r:10):ch:="UTF-8"
                ,s:=StrGet(&data, size>>(eg="utf-16"||eg="cp1200"),eg)
                if ch and InStr(t, "text`/html") and (i:=InStr(s,"charset=")) and (ch:=(i:=Trim(SubStr(s, e:=i+8, RegExMatch(s,"`'|`"|>|/",,i+9)-e),"`'`"/")) ? InStr(i,"gb")?"CP936":(instr(i,"cp") or instr(i,"-"))?i: StrReplace(i,"utf","utf-") :"") and (eg!=ch)
                        s:=StrGet(&data, size>>(r="utf-16"||r="cp1200"),affix.charset:=ch)
                this.text:=s
                if this.Decode
                        this.Decode:=Decode_All(s)
                if this.json and RegExMatch(s, "s)^[\[|\{].*[\]|\}]$")
                        this.json:=so(s,0)
                if !this.result
                        return oh_close(this),s
        }
        Return oh_close(this)
}

oh_close(f,s:=""){
        Loop,Parse,rcs
                if n:=f.delete("h" A_LoopField)
                        DllCall("winhttp\WinHttpCloseHandle", "Ptr", n)
        if s
        {
                f.err.=s
                if f.pug
                        f.pug.call({this:f,event:"Err"})
        }
        if f.end  and (isobject(f.end) or f.end:=func(f.end))
                f.end.call(f)
        Return f.time:=ahktime(f.time),f
}

oh_Hash(type,addr, length:=""){
	h := {MD2: 0x8001,MD4: 0x8002,MD5: 0x8003,SHA1: 0x8004,SHA256: 0x800c,SHA384: 0x800d,SHA512: 0x800e,1:0,2:1, 3:2, 4:3, 5:4, 6:5, 7:6, 8:7, 9:8, 10:9, 11:"a", 12:"b", 13:"c", 14:"d", 15:"e", 16:"f"}
	,hProv := hHash := o := "",hash := 0, hashlength := 0,(addr+0)?""
	:length?(length:=StrPutVar(addr,data,length)-1,addr:=&data)
		:(f := FileOpen(addr, "r"),VarSetCapacity(data, f.length, 0),addr:=&data,f.rawRead(&data, length:=f.length),f.Close())
	if (DllCall("advapi32\CryptAcquireContext", "Ptr*", hProv, "Ptr", 0, "Ptr", 0, "UInt", 24, "UInt", 0xf0000000))
	{
		if (DllCall("advapi32\CryptCreateHash", "Ptr", hProv, "UInt", h[type], "UInt", 0, "UInt", 0, "Ptr*", hHash))
		{
			if (DllCall("advapi32\CryptHashData", "Ptr", hHash, "Ptr", addr, "UInt", length, "UInt", 0))
			and DllCall("advapi32\CryptGetHashParam", "Ptr", hHash, "UInt", 2, "Ptr", 0, "UInt*", hashlength, "UInt", 0)
			and VarSetCapacity(hash, hashlength, 0)
			and DllCall("advapi32\CryptGetHashParam", "Ptr", hHash, "UInt", 2, "Ptr", &hash, "UInt*", hashlength, "UInt", 0)
				loop hashlength
					v := NumGet(hash, A_Index - 1, "UChar"),o .= h[(v >> 4) + 1] h[(v & 0xf) + 1]
			DllCall("advapi32\CryptDestroyHash", "Ptr", hHash)
		}
		DllCall("advapi32\CryptReleaseContext", "Ptr", hProv, "UInt", 0)
	}
	return o
}

oh_FormData(this,ByRef body){
        Boundary := SubStr(StrReplace(Sort("0|1|2|3|4|5|6|7|8|9|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z","D| Random"), "|"), 1, 12)
        crlf := "`r`n",line := "--" . Boundary
        VarSetCapacity(body,0),ohfset := 0
        For k, v in this.post
                If IsObject(v)
                {
                        For i, FileName in v
                        {
                                file:=FileOpen(FileName, "r"),n := file.ReadUInt()
                                ,buffer := line crlf "Content-Disposition: form-data; name=`"" . k . "`"; filename=`"" . FileName . "`"" . crlf
                                        . "Content-Type: " . ((n        = 0x474E5089) ? "image/png"
                                        : (n        = 0x38464947) ? "image/gif"
                                        : (n&0xFFFF = 0x4D42    ) ? "image/bmp"
                                        : (n&0xFFFF = 0xD8FF    ) ? "image/jpeg"
                                        : (n&0xFFFF = 0x4949    ) ? "image/tiff"
                                        : (n&0xFFFF = 0x4D4D    ) ? "image/tiff"
                                        : "application/octet-stream") . crlf . crlf
                                ,oh_memory(body,buffer,ohfset,StrLen(buffer),1)
                                ,bufferSize := VarSetCapacity(buffer,file.Length)
                                ,File.Tell(0),file.RawRead(&buffer, bufferSize)
                                ,oh_memory(body,buffer,ohfset,bufferSize,0)
                                ,oh_memory(body,crlf,ohfset,2,1)
                        }
                }
                Else
                {
                        buffer := line . crlf . "Content-Disposition: form-data; name=`"" . k "`"" . crlf . crlf . v . crlf
                        oh_memory(body,buffer,ohfset,StrLen(buffer),1)
                }
        oh_memory(body,buffer:= line "--" crlf,ohfset,StrLen(buffer),1)
        ,this.head["Content-Type"]:="multipart/form-data; boundary=" . Boundary
        ,this.length:=ohfset
}

oh_memory(ByRef f,ByRef k,ByRef p,ByRef s,t){
        r:=p,VarSetCapacity(f,p+= s),t?StrPut(k, (&f)+r, s, "CP0"):DllCall("RtlMoveMemory", "Ptr", &f+r, "Ptr", &k, "UInt", s)
}

str_f(Str,Split,Chars,Omit:="`r `t",f:=""){
	f?"":f:=[]
	Loop, parse,% Str,% Split, % Omit
		(s:=InStr(r:=A_LoopField,Chars))
			? (f[p:=Trim(SubStr(r, 1,s-1),Omit)]?(f[p].="||" Trim(SubStr(r, s+1)),Omit):(f[p]:=Trim(SubStr(r, s+1))),Omit)
			: f[r]:=""
    return f
}

Decode_Html(ByRef str){
	oscs := A_StringCaseSense
	StringCaseSense, On
	Loop, Parse,% "middot,·/nbsp, /#160, /lt,</#60,</gt,>/#62,>/amp,&/#38,&/quot,`"/#34,`"/apos,`'/#39,`'/cent,￠/#162,￠/pound,£/#163,£/yen,¥/#165,¥/euro,€/#8364,€/sect,§/#167,§/copy,©/#169,©/reg,®/#174,®/trade,™/#8482,™/times,×/#215,×/divide,÷/#247,÷/OElig,Œ/oelig,œ/Scaron,Š/scaron,š/Yuml,Ÿ/fnof,ƒ/circ,ˆ/tilde,˜/Alpha,Α/Beta,Β/Gamma,Γ/Delta,Δ/Epsilon,Ε/Zeta,Ζ/Eta,Η/Theta,Θ/Iota,Ι/Kappa,Κ/Lambda,Λ/Mu,Μ/Nu,Ν/Xi,Ξ/Omicron,Ο/Pi,Π/Rho,Ρ/Sigma,Σ/Tau,Τ/Upsilon,Υ/Phi,Φ/Chi,Χ/Psi,Ψ/Omega,Ω/alpha,α/beta,β/gamma,γ/delta,δ/epsilon,ε/zeta,ζ/eta,η/theta,θ/iota,ι/kappa,κ/lambda,λ/mu,μ/nu,ν/xi,ξ/omicron,ο/pi,π/rho,ρ/sigmaf,ς/sigma,σ/tau,τ/upsilon,υ/phi,φ/chi,χ/psi,ψ/omega,ω/thetasym,ϑ/upsih,ϒ/piv,ϖ/ensp, /emsp, /thinsp, /zwnj,‌/zwj,‍/lrm,‎/rlm,‏/ndash,–/mdash,—/lsquo,‘/rsquo,’/sbquo,‚/ldquo,“/rdquo,”/bdquo,„/dagger,†/Dagger,‡/bull,•/hellip,…/permil,‰/prime,′/Prime,″/lsaquo,‹/rsaquo,›/oline,‾/frasl,⁄/euro,€/image,ℑ/weierp,℘/real,ℜ/trade,™/alefsym,ℵ/larr,←/uarr,↑/rarr,→/darr,↓/harr,↔/crarr,↵/lArr,⇐/uArr,⇑/rArr,⇒/dArr,⇓/hArr,⇔/forall,∀/part,∂/exist,∃/empty,∅/nabla,∇/isin,∈/ni,∋/prod,∏/sum,∑/minus,−/lowast,∗/radic,√/prop,∝/infin,∞/ang,∠/and,∧/or,∨/cap,∩/cup,∪/int,∫/there4,∴/sim,∼/cong,≅/asymp,≈/ne,≠/equiv,≡/le,≤/ge,≥/sub,⊂/sup,⊃/nsub,⊄/sube,⊆/supe,⊇/oplus,⊕/otimes,⊗/perp,⊥/sdot,⋅/lceil,⌈/rceil,⌉/lfloor,⌊/rfloor,⌋/lang,⟨/rang,⟩/loz,◊/spades,♠/clubs,♣/hearts,♥/diams,♦", /
	(InStr(str,i:="&" SubStr(s,1,(r:=InStr(s:=A_LoopField,","))-1) ";")?str:=StrReplace(str,i,SubStr(s,r+1)):"")
	Return StringCaseSense(oscs),str
}

Decode_Escape(ByRef str){
	f:=[]
	if i:=InStr(str,"\u")
	for i,n in StrSplit(SubStr(str,i+2),"\u")
		(n and !f[b:=SubStr(n, 1, 4)]
			? (f[b]:=1,(s := Abs("0x" b))?(str:=StrReplace(str,"\u" b,Chr(s))):"")
			: "")
	return str
}

Decode_Ascii(ByRef str){
	Loop, Parse,01|02|03|04|05|06|07|08|09|0a|0b|0c|0d|0e|0f|10|11|12|13|14|15|16|17|18|19|1a|1b|1c|1d|1e|1f|20|21|22|23|24|25|26|27|28|29|2a|2b|2c|2d|2e|2f|30|31|32|33|34|35|36|37|38|39|3a|3b|3c|3d|3e|3f|40|41|42|43|44|45|46|47|48|49|4a|4b|4c|4d|4e|4f|50|51|52|53|54|55|56|57|58|59|5a|5b|5c|5d|5e|5f|60|61|62|63|64|65|66|67|68|69|6a|6b|6c|6d|6e|6f|70|71|72|73|74|75|76|77|78|79|7a|7b|7c|7d|7e|7f,|
	InStr(str,"\x" A_LoopField)?str:=StrReplace(str,"\x" A_LoopField,Chr("0x" A_LoopField)):""
	return str
}

Decode_All(ByRef str){
	return Decode_Html(Decode_Escape(Decode_Ascii(str)))
}

so(s,type:="",Mark:=""){
	static y:="`"",j:="`" `t",m:={"\b":Chr(08),"\\":"\","\t":"`t","\n":"`n","\f":Chr(12),"\r":"`r"},gu:="āЁξ"
	if Isobject(s)
	{
		if !InStr(Type(s),"Object")
			Return
		if !type
			(First:=type=0?1:2,type:={&s:1})
		else if type[&s]
			Return "**"
		else type[&s]:=1
		if !Count:=s.Count()
			Return "[]"
		if w:= (Count = s.Length())
			for k in s
				if (k != A_Index)
				{
					w:=""
					Break
				}
		if w
		{
			for i,n in s
				str.=(Isobject(n)?so(n,type): n+0=""?(gu n gu):n) ","
		}
		else
		{
			for i,n in s
				str.=(Isobject(i)?so(i,type):i+0=""?(gu i gu):i) ":" (Isobject(n)?so(n,type): n+0=""?(gu n gu):n) ","
		}

		if First
		{
			if First=1
			{
				StrReplace, str, %str%,% "`n",% "``n"
				StrReplace, str, %str%,% y,% "``" y
				StrReplace, str, %str%,% gu,% y
			}
			else
			{
				StrReplace, str, %str%,/,\/
				for c,z in m
					IF InStr(str,z)
						StrReplace, str, %str%,% z,% c
				StrReplace, str, %str%,% y,% "\" y
				StrReplace, str, %str%,% gu,% y
			}
		}
		Return str:=RTrim(str,","),w?"[" str "]":"{" str "}"
	}

	f:=[],i:=1,n:=type
	if n
		b:=StrLen(s),jx:=Mark.jx,json:=Mark.json
	else
	{
		if !(s:=Trim(s," `n`r`t")) or !regexmatch(s, "[\[\{]")
			Return s


		if json:=(n=0) ; so(s,0) json
		{
			for c,z in m
				if InStr(s,c)
					StrReplace,s,% s,% c,% z
			StrReplace, s, %s%,\/,/
			if e:=InStr(s,"\u")
				for e,n in StrSplit(SubStr(s, e+2), "\u")
					IF n and !f[b:=SubStr(n, 1, 4)]
					{
						IF d := Abs("0x" b)
							StrReplace,s,% s,% "\u" b,% Chr(d)
						f[b]:=1
					}
		}

		f:=[],b:=StrLen(s),n:=SubStr(s,i,1),d:=0,jx:=json?"\":"``"
		Mark:={jx:jx,json:json,d:d}
	}

	if (n="{")
		loop
		{
			if ((r?r[0]:"") = "}") or !i or !( i:=RegExMatch(s,"\S",n,i+1) ) or ((n:=n[0]) = "}")
				Return Mark.d:=i,f

			if InStr("[{",n)
				 (k:=so(SubStr(s,i),n,Mark),i+=Mark.D,i:=RegExMatch(s,"\S",t,InStr(s,":",,i)+1),(InStr("[{",t:=i?t[0]:"")
					? (f[so_json(K,json) ""]:=so(SubStr(s,i),t,Mark),i:=RegExMatch(s,",|\}",r,i+Mark.D))
					: ( ((t=y) 	? (p:=InStr(s,y,,i+1),p:=RegExMatch(s,",|\}",r,p),z:=Trim(SubStr(s,i+1,p-i-2))) 
									: (p:=RegExMatch(s,",|\}",r,i),z:=Trim(SubStr(s,i,p-i)),z:=z+0=""?so_Try(z):z+0))
								,f[so_json(K,json) ""]:=so_json(K,json),i:=p)) )
			else
				 (x:=InStr(s,":",,(n=y)?InStr(s,y,,i,2):i))
					? (k:= ((n=y)?SubStr(s,i+1,x-i-2):SubStr(s,i,x-i))
						,k:=(n=y ? Trim(k) : n="(" ? so_Try(Trim(k,"() `t")):Trim(k)),i:=RegExMatch(s,"\S",t,x+1)
						,InStr("[{",t:=i?t[0]:"")
							? (f[so_json(K,json)  ""]:=so(SubStr(s,i),t,Mark),i:=RegExMatch(s,",|\}",r,i+Mark.D))
							: ( ((t=y) 	? (p:=RegExMatch(s,",|\}",r,so_InStr(s,i,jx)),z:=Trim(SubStr(s,i+1,InStr(s,y,,p-b-1)-i-1))) 
									: (p:=RegExMatch(s,",|\}",r,i),z:=Trim(SubStr(s,i,p-i)),z:=z+0=""?so_Try(z):z+0))
								,f[so_json(K,json)  ""]:=so_json(Z,json),i:=p))
					: i:=0
		}

	if (n = "[")
		loop
		{
			if ((r?r[0]:"") = "]") or !i or !( i:=RegExMatch(s,"\S",n,i+1) ) or ((n:=n[0]) = "]")
				Return Mark.D:=i,f
			(InStr("[{",n)
				? (f.Push(so(SubStr(s,i),n,Mark)),i:=RegExMatch(s,",|\]",r,i+Mark.D))
				: (  (n=y) ? (p:=RegExMatch(s,",|\]",r,so_InStr(s,i,jx)),z:=(SubStr(s,i+1,InStr(s,y,,p-b-1)-i-1))) 
					: (p:=RegExMatch(s,",|\]",r,i),z:=Trim(SubStr(s,i,p-i)),z:=z+0=""?so_Try(z):z+0),i:=p
					,f.Push(so_json(Z,json))))
		}

}

so_json(s,json){
	static J:="\`"",P:="`""
	Return json AND InStr(s,J)?StrReplace(S,J,P):S
}

so_InStr(s,i,jx){
	while (p:=InStr(s,"`"",,i+1)) and (SubStr(s,p-1,1)=jx)
		i:=p
	Return p
}

so_Try(f){
	global
	Try
	Return  (%f%)
}
NumType(v){
  return InStr(v,".")?"Double":v>4294967295?"UInt64":v>65535?"UInt":v>255?"UShort":v>-1?"UChar":v>-129?"Char":v>-32769?"Short":v>-2147483649?"Int":"Int64"
}
NumSize(v){
  return InStr(v,".")||v>4294967295?8:v>65535?4:v>255?2:v>-129?1:v>-32769?2:v>-2147483649?4:8
}
ahktime(s:=0,i:=6) {
	static r:=(DllCall("QueryPerformanceFrequency",Int64P,r),r)
	Return DllCall("QueryPerformanceCounter",Int64P,n),(s ? Round((n-s)/r, i) : n)
}