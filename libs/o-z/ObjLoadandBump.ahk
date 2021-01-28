ObjDump(obj,ByRef var,mode:=0){
	If IsObject(var)
	{ ; FileAppend mode
		If FileExist(obj)
		{
			FileDelete,%obj%
			If ErrorLevel
				return
		}
		f:=FileOpen(obj,"rw-rwd"),VarSetCapacity(v,sz:=RawObjectSize(var,mode),0)
			,RawObject(var,&v,mode),count:=sz//65536,ptr:=&v
		Loop % count
			f.RawWrite(ptr+0,65536),ptr+=65536
		return sz,f.RawWrite(ptr+0,Mod(sz,65536)),f.Close()
	}
	else
		return sz,VarSetCapacity(var,sz:=RawObjectSize(obj,mode),0),RawObject(obj,&var,mode)
}

RawObject(obj,addr,buf:=0){
	; Type.Enum:    Char.1 UChar.2 Short.3 UShort.4 Int.5 UInt.6 Int64.7 UInt64.8 Double.9 String.10 Object.11
	for k,v in obj
	{ ; 9 = Int64 for size and Char for type
		(IsObject(k)
			? (NumPut(-11,addr+0,"Char"),NumPut(sz:=RawObjectSize(k,buf),addr+1,"UInt64"),RawObject(k,addr+9),addr+=sz+9)
			: (k+0="")
				? (NumPut(-10,addr+0,"Char"),NumPut(StrPut(k,addr+9)*(A_IsUnicode?2:1),addr+1,"UInt64"),addr+=NumGet(addr+1,"UInt64")+9)
				: (NumPut( InStr(k,".")?-9:k>4294967295?-8:k>65535?-6:k>255?-4:k>-1?-2:k>-129?-1:k>-32769?-3:k>-2147483649?-5:-7,addr+0,"Char")
					,NumPut(k,addr+1,InStr(k,".")?"Double":k>4294967295?"UInt64":k>65535?"UInt":k>255?"UShort":k>-1?"UChar":k>-129?"Char":k>-32769?"Short":k>-2147483649?"Int":"Int64")
					,addr+=InStr(k,".")||k>4294967295?9:k>65535?5:k>255?3:k>-129?2:k>-32769?3:k>-2147483649?5:9))

		(IsObject(v)
			? (NumPut( 11,addr+0,"Char"),NumPut(sz:=RawObjectSize(v,buf),addr+1,"UInt64"),RawObject(v,addr+9),addr+=sz+9)
			: (v+0="")
				? (NumPut( 10,addr+0,"Char"),NumPut(sz:=buf?obj.GetCapacity(k):StrPut(v)*(A_IsUnicode?2:1),addr+1,"Int64"),DllCall("RtlMoveMemory","PTR",addr+9,"PTR",&v,"PTR",sz),addr+=sz+9)
				: (NumPut( InStr(v,".")?9:v>4294967295?8:v>65535?6:v>255?4:v>-1?2:v>-129?1:v>-32769?3:v>-2147483649?5:7,addr+0,"Char")
					,NumPut(v,addr+1,InStr(v,".")?"Double":v>4294967295?"UInt64":v>65535?"UInt":v>255?"UShort":v>-1?"UChar":v>-129?"Char":v>-32769?"Short":v>-2147483649?"Int":"Int64")
					,addr+=InStr(v,".")||v>4294967295?9:v>65535?5:v>255?3:v>-129?2:v>-32769?3:v>-2147483649?5:9))


	}
}

RawObjectSize(obj,buf:=0,sz:=0){
	; 9 = Int64 for size and Char for type
	for k,v in obj
	{
		sz +=(IsObject(k)
			? (RawObjectSize(k,buf)+9) : ((k+0="")
				? (StrPut(k)*(A_IsUnicode?2:1)+9)
				: InStr(k,".")||k>4294967295?9:k>65535?5:k>255?3:k>-129?2:k>-32769?3:k>-2147483649?5:9))
		+(IsObject(v)
			?  RawObjectSize(v,buf)+9 : ((v+0="")
				? (buf?obj.GetCapacity(k):StrPut(v)*(A_IsUnicode?2:1))+9
				: InStr(v,".")||v>4294967295?9:v>65535?5:v>255?3:v>-129?2:v>-32769?3:v>-2147483649?5:9))
	}
	return sz
}

ObjLoad(addr,sz:=""){
	; Arrays to retrieve type and size from number type
	static type:=["Char","UChar","Short","UShort","Int","UInt","Int64","UInt64","Double"],num:=[1,1,2,2,4,4,8,8,8]
	end:=addr+sz, obj:=[]
	While % addr<end ; 9 = Int64 for size and Char for type
		k:=(NumGet(addr+0,"Char")=-11
			? (ObjLoad(addr+9,sz:=NumGet(addr+1,"UInt64")),addr+=sz+9)
			: NumGet(addr+0,"Char")=-10
				? (StrGet(addr+9),addr+=NumGet(addr+1,"UInt64")+9)
				: (NumGet(addr+1,type[sz:=-1*NumGet(addr+0,"Char")]),addr+=num[sz]+1))

		,(NumGet(addr+0,"Char")= 11
			? (obj[k]:=ObjLoad(addr+9,sz:=NumGet(addr+1,"PTR")),addr+=sz+9)
			: NumGet(addr+0,"Char")= 10
				? (obj.SetCapacity(k,sz:=NumGet(addr+1,"UInt64")),DllCall("RtlMoveMemory","PTR",obj.GetAddress(k),"PTR",addr+9,"PTR",sz),addr+=sz+9)
				: (obj[k]:=NumGet(addr+1,type[sz:=NumGet(addr+0,"Char")]),addr+=num[sz]+1))

	return obj
}

ObjFileLoad(File){
	If !FileExist(File)
		return
	FileGetSize,sz,% File
	FileRead,v,*c %File%
	If ErrorLevel||!sz
		return
	return ObjLoad(&v,sz)
}