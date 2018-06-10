translate_google(str,tl:="",sl:="",proxy:=""){
	ComObjError(false)
	http	:= ComObjCreate("WinHttp.WinHttpRequest.5.1")
	proxy?http.SetProxy(2,proxy):"",tl?"":tl:="en"
	http.open("POST","https://translate.google.com/translate_a/single?client=t&sl=" (sl?sl:"auto") "&tl=" tl "&hl=" tl "&dt=at&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&ie=UTF-8&oe=UTF-8&otf=1&ssel=3&tsel=3&pc=1&kc=2&tk=" translate_tl(str),1)

	http.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded;charset=utf-8")
	http.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0")
	http.send("q=" Uri_Encode(str))
	http.WaitForResponse(-1)
	if IsObject(Result:=so(http.responsetext,0)) && IsObject(Result.1) && Result.1.Length() {
		for i,n in Result.1
		text.= n.1 " "
	}
	Return text
}
;{hier öffnen für die Unterfunktionen der translate_google Funktion - hoffentlich deutlich schneller

so(s,n:="") {
	static JSON,JSONS,d,y:="`"",j:="`" `t",m:={"\b":Chr(08),"\\":"\","\t":"`t","\n":"`n","\f":Chr(12),"\r":"`r"},gu:="a??"
	if (Type(s)="Object")
	{
		for i,n in s
			str.= (Type(i)="Object"?so(i,1):i+0=""?(gu i gu):i)  ":"  (Type(n)="Object"?so(n,1): n+0=""?(gu n gu):n)  ","
		if !n
		{
			StringReplace, str, str,/,\/
			for c,z in m 
				IF InStr(str,z)
				StringReplace, str, str,% z,% c
			StringReplace, str, str,% y,% "\" y
			StringReplace, str, str,% gu,% y
		}
		Return "{" RTrim(str,",") "}"
	}
	if (Type(s)="string")
	{
		f:=[],i:=1
		if n
			b:=StrLen(s)
		else
		{
			if !(s:=Trim(s)) or !regexmatch(s, "[\[\{]")
				Return s
			if JSON:=(n=0) ; so(s,0) JSON
			{
				for c,z in m
					if InStr(s,c)
						StringReplace,s,s,% c,% z
				StringReplace, s, s,\/,/


				if e:=InStr(s,"\u")
					for e,n in StrSplit(SubStr(s, e+2), "\u")
						IF n and !f[b:=SubStr(n, 1, 4)]
						{
							IF d := Abs("0x" b)
								StringReplace,s,s,% "\u" b,% Chr(d)
							f[b]:=1
						}
			}
			f:=[],b:=StrLen(s),n:=SubStr(s,i,1),d:=0,JSONS:=JSON?"\":"``"
		}

		if (n="{")
			loop
			{
				if ((r?r[0]:"") = "}") or !i or !( i:=RegExMatch(s,"\S",n,i+1) ) or ((n:=n[0]) = "}")
					Return d:=i,f

				if InStr("[{",n)
					 (k:=so(SubStr(s,i),n),i+=d,i:=RegExMatch(s,"\S",t,InStr(s,":",,i)+1),(InStr("[{",t:=i?t[0]:"")
						? (f[SO_JSON(K,JSON) ""]:=so(SubStr(s,i),t),i:=RegExMatch(s,",|\}",r,i+d))
						: ( ((t=y) 	? (p:=InStr(s,y,,i+1),p:=RegExMatch(s,",|\}",r,p),z:=Trim(SubStr(s,i+1,p-i-2))) 
										: (p:=RegExMatch(s,",|\}",r,i),z:=Trim(SubStr(s,i,p-i)),z:=z+0=""?SO_Try(z):z+0))
									,f[SO_JSON(K,JSON) ""]:=SO_JSON(K,JSON),i:=p)) )
				else
					 (x:=InStr(s,":",,(n=y)?InStr(s,y,,i,2):i))
						? (k:= ((n=y)?SubStr(s,i+1,x-i-2):SubStr(s,i,x-i))
							,k:=(n=y ? Trim(k) : n="(" ? SO_Try(Trim(k,"() `t")):Trim(k)),i:=RegExMatch(s,"\S",t,x+1)
							,InStr("[{",t:=i?t[0]:"")
								? (f[SO_JSON(K,JSON)  ""]:=so(SubStr(s,i),t),i:=RegExMatch(s,",|\}",r,i+d))
								: ( ((t=y) 	? (p:=so_InStr(s,i,JSONS),p:=RegExMatch(s,",|\}",r,p),z:=Trim(SubStr(s,i+1,p-i-2))) 
										: (p:=RegExMatch(s,",|\}",r,i),z:=Trim(SubStr(s,i,p-i)),z:=z+0=""?SO_Try(z):z+0))
									,f[SO_JSON(K,JSON)  ""]:=SO_JSON(Z,JSON),i:=p))
						: i:=0
			}

		if (n = "[")
			loop
			{
				if ((r?r[0]:"") = "]") or !i or !( i:=RegExMatch(s,"\S",n,i+1) ) or ((n:=n[0]) = "]")
					Return d:=i,f
				(InStr("[{",n)
					? (f.Push(so(SubStr(s,i),n)),i:=RegExMatch(s,",|\]",r,i+d))
					: (  (n=y) ? (p:=so_InStr(s,i,JSONS),p:=RegExMatch(s,",|\]",r,p),z:=Trim(SubStr(s,i+1,p-i-2))) 
						: (p:=RegExMatch(s,",|\]",r,i),z:=Trim(SubStr(s,i,p-i)),z:=z+0=""?SO_Try(z):z+0),i:=p
						,f.Push(SO_JSON(Z,JSON))))
			}
	}
}

SO_JSON(s,JSON) {
	static J:="\`"",P:="`""
	Return JSON AND InStr(s,J)?StrReplace(S,J,P):S
}

SO_InStr(s,i,JSONS) {
	A= `"
	Loop
	{	
		p:=InStr(s,A,,i+1) 
		o:=SubStr(s,p-1,1)
			If (p=0) and (o<>JSON) {
					break
							}
		i:=p
	}
	Return p
}

SO_Try(f){
	global
	Try
	Return  (%f%)
}

Uri_Encode(str){
	n := StrPutVar(str, UTF8, "UTF-8"),f:={"30":1,"31":1,"32":1,"33":1,"34":1,"35":1,"36":1,"37":1,"38":1,"39":1,"41":1,"42":1,"43":1,"44":1,"45":1,"46":1,"47":1,"48":1,"49":1,"50":1,"51":1,"52":1,"53":1,"54":1,"55":1,"56":1,"57":1,"58":1,"59":1,"61":1,"62":1,"63":1,"64":1,"65":1,"66":1,"67":1,"68":1,"69":1,"70":1,"71":1,"72":1,"73":1,"74":1,"75":1,"76":1,"77":1,"78":1,"79":1,"2d":1,"2e":1,"4a":1,"4b":1,"4c":1,"4d":1,"4e":1,"4f":1,"5a":1,"5f":1,"6a":1,"6b":1,"6c":1,"6d":1,"6e":1,"6f":1,"7a":1,"7e":1}
	loop, strlen(hex:=BintoHex(&UTF8,n))/2-1
		Res .= f[r:=substr(hex, A_index*2-1,2)]?Chr("0x" r):"`%" r
	return Res
}

DateDiff(Start, End, unit){
   
    Diff := End
    Diff -= Start, %unit%
    
    return Diff
}

translate_tl(string){
	a := b :=datediff(time?time:A_NowUTC,"19700101","hours")
	n:= StrPutVar(string,utf8,"UTF-8")
	loop, strlen(hex:=BintoHex(&UTF8, n))/2-1
		a := translate_rl(a + ("0x" substr(hex, A_index*2-1,2)), "+-a^+6")
	a := Mod((0 > (a := translate_rl(a, "+-3^+b+-f"))) ? (a := (a & 2147483647) + 2147483648) : a,10 ** 6)
	return a "." (a ^ b)
}

translate_rl(a, b){
	c := 0
	while c < StrLen(b) - 2
	{
		d := SubStr(b, c+3, 1),d := (d >= "a") ? Ord(d) - 87 : d+0
		,d := (SubStr(b, c+2, 1) ==  "+") ? a >> d : a << d
		,a := (SubStr(b, c+1, 1) == "+") ? (a + d & 4294967295) : a ^ d
		,c += 3
	}
	
	a := ("0" . a) , a += 0
	
	return a
}

;}
