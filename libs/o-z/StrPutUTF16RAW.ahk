StrPutUTF16RAW(Str,byref Var,zeroterminated=1) { ;https://autohotkey.com/board/topic/90962-wie-erzeuge-ich-eine-bytefolge-der-utf-16le-codierung/ ;nnnik
	zeroterminated:=zeroterminated?2:0
	VarSetCapacity(Var,(var2:=(strlen(str)-1)*2)+zeroterminated,0)
	loop % var2 	{
		NumPut(Asc(str),Var,(A_Index-1)*2,"UShort")
		StringTrimLeft,str,str,1
	}
	return var2+zeroterminated
}