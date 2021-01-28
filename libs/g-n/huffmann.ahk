; huffman compression in ahk / v0.5.1b
; (c|w) 01.07.2008 derRaphael@oleco.net / zLib style released
; *************************************************************************
;                              compression
; *************************************************************************
aHC_Compress(ByRef Data, ByRef compressedData, Size = 0, aHC_InfoStyle = 1){
	global aHC_Info, aHC_Current
	aHC_Current := "Compression"
	aHC_Info := ""
	OldFloat := A_FormatFloat
	SetFormat,Float,3.1
	HuffHead := "HuffmanCompressed 051", valuecount := 0
	if (size=0)                         ; If possible pass Size parameter - since Autohotkey 
		size := VarSetCapacity(Data,-1) ; wont properly handle binarydata correct due to \0
;~ tooltip, part one - get the count of unique chars the data
	Loop % size
	{
		value := NumGet(Data,A_Index-1,"Uchar")
		if (data_%value%=0) {
			valuecount++
			data_%value% := 0
		} else {
			data_%value%++
		}
	}
;~ tooltip, part two - byte usage statistic
	Loop,256
	{
		n := A_Index-1
		if (StrLen(data_%n%)!=0)
			out .= data_%n% " " n "`n"
		sd_%n% := ""
	}
;~ tooltip, part three - build huffman tree and encoding table
	Loop,
	{
		sort,out,N
		cc := ccount("`n",out)
		if (cc>1) {
			Loop,Parse,out,`n
				if (A_Index<3)
					n%A_index% := A_LoopField
				Else
					break
			v1a := RegExReplace(n1,"S)\s.*"), v1b := RegExReplace(n1,"S)\d+\s")
			v2a := RegExReplace(n2,"S)\s.*"), v2b := RegExReplace(n2,"S)\d+\s")
			v3a := v1a + v2a, v3b := "(#" v1b ",#" v2b ")"   ; 0 - 1
			nout := v3a " " v3b "`n"
			Loop,Parse,out,`n
				if (A_Index>2)
					nout .= A_loopField "`n"
			StringReplace,out,nout,`n`n,`n,All
			l1 := RegExReplace(v1b,"S)[^#\d]"), l1 := RegExReplace(l1,"S)##","#")
			l2 := RegExReplace(v2b,"S)[^#\d]"), l2 := RegExReplace(l2,"S)##","#")
			if (substr(l1,1,1)="#")
				l1 := SubStr(l1,2)
			if (substr(l2,1,1)="#")
				l2 := SubStr(l2,2)
			Loop,Parse,l1,#
				sd_%A_LoopField% := "0" sd_%A_LoopField%
			Loop,Parse,l2,#
				sd_%A_LoopField% := "1" sd_%A_LoopField%
		} else
			Break
	}
;~ tooltip, part four - building decompression table
	offset := 0, tokenCount := 0
	VarSetCapacity(compressedData,size*2,0)
	hhc := StrLen(HuffHead)
	Loop,% hhc
		NumPut(*(&HuffHead-1+A_index),compressedData,A_index-1,"UChar")
	Loop,256
	{
		n := A_Index-1
		l := StrLen(RegExReplace(sd_%n%,"S)[^01]"))
		if (l>0) {
			offset := ++tokencount*6+hhc+50
			NumPut(n,compressedData,offset-2,"Uchar")
			NumPut(l,compressedData,offset-1,"Uchar")
			NumPut(b2d(sd_%n%),compressedData,offset,"Uint")
		}
	}
	NumPut(tokenCount&255,compressedData,hhc+2,"UChar")
	NumPut(size,compressedData,hhc+5,"Uint")
	offset +=4
;~ tooltip, part five - compress origin data %size%
	pressed := ""
	Loop % size
	{
		value := NumGet(Data,A_Index-1,"Uchar")
		pressed .= sd_%value%
		Loop,
			if (Strlen(pressed)>8) {
				NumPut(b2d(substr(pressed,1,8)),compressedData,offset++,"uchar")
				pressed := substr(pressed,9)
			} else 
				Break
		
		percent := (a_index/Size)*100
		If (aHC_InfoStyle&1=1)
			aHC_Info := percent "%"
		else if (aHC_InfoStyle&3=3)
			aHC_Info := round(percent) "%"
	}
	if (Strlen(Pressed)!=0)
		Numput(b2d(pressed SubStr("00000000",1,8-strlen(pressed))),compressedData,offset,"uchar")
	NumPut(offset,compressedData,hhc+10,"Uint")
	SetFormat,Float,%OldFloat%
	return offset+1
}

; *************************************************************************
;                              decompression
; *************************************************************************
aHC_Decompress(ByRef compressedData, ByRef Data, aHC_InfoStyle = 1) {
	global aHC_Info, aHC_Current
	aHC_Current := "Decompression"
	aHC_Info := ""
	OldFloat := A_FormatFloat
	SetFormat,Float,3.1
;~ tooltip part one - check head
	HuffHead := "HuffmanCompressed 051", hhc := StrLen(HuffHead), hCheck := ""
	Loop, % hhc
		hCheck .= chr(*(&compressedData-1+a_index))

	if (hCheck!=HuffHead)                                ; err no compressed data
		Return -1                                        ; head found

;~ tooltip part two - build decompression table
	tokenCount := NumGet(compressedData,hhc+2,"UChar")
	if (tokenCount=0)
		tokenCount := 256
	dSize := NumGet(compressedData,hhc+5,"Uint")
	VarSetCapacity(Data,dSize,0)
	MaxTokenLength := 0
	
	Loop,% tokenCount
	{
		offset := A_Index*6+hhc+50, s := ""
		b := d2b(NumGet(compressedData,offset,"Uint"))
		Loop, % l := NumGet(compressedData,offset-1,"Uchar")
			s .= "0"
		b := SubStr(s,1,l-(strlen(b))) b
		_%b% := NumGet(compressedData,offset-2,"Uchar")
		if (strlen(b)>maxTokenLength)
			MaxTokenLength := b
	}
;~ tooltip part three - decompress!
	; take amount of bits from stream and find match in decompression table
	; thus resolving it into its origin binary value
	offset += 4, oc := 0
	Loop, 
	{
		bits := d2b(NumGet(compressedData,offset++,"uchar"))
		_tmp .= substr("00000000",1,8-strlen(bits)) bits
		match := ""
		Loop,Parse,_tmp
		{
			match .= A_LoopField, value := _%match%
			if (StrLen(value)!=0) {
				NumPut(value,Data,oc++,"uchar")
				match := ""
			}
		}
		if (StrLen(match)>0) {
			_tmp := match
		} Else
			_tmp := ""
		percent := (oc/dSize)*100
		If (aHC_InfoStyle&1=1)
			aHC_Info := percent "%"
		else if (aHC_InfoStyle&3=3)
			aHC_Info := round(percent) "%"
			
		if (strlen(_tmp)>maxTokenLength) {
			MsgBox ERR
			return -2						; internal Data Error - Shouldn't happen at all
		}
		if (oc=dSize)
			break
	}
	SetFormat,Float,%OldFloat%
	return dSize
}

; *************************************************************************
;                              Helperfunctions
; *************************************************************************
ccount(char,data) {
	OldFormat := A_FormatInteger
	SetFormat,Integer,H
	needle := "S)\" substr(asc(char),2)
	c := (RegExReplace(data,needle,char,counter)) ? counter : 0
	SetFormat,Integer,%OldFormat%
	c += 0
	Return c
}

b2d(str, dec=0) {
	Loop,% x := StrLen(str)
		dec += SubStr(str,x-a_index+1,1)*(2**(A_index-1))
	return dec
}

d2b(i, s = 0, c = 0) { 	; Thx Titan, http://www.autohotkey.com/forum/viewtopic.php?t=13522
   l := StrLen(i := Abs(i + u := i < 0))
   Loop, % Abs(s) + !s * l << 2
      b := u ^ 1 & i // (1 << c++) . b
   Return RegExReplace(b,"^0+")
}