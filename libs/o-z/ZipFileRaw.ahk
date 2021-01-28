If 0
	FileInstall,LiteZip.dll,Used to compress resources
ZipFileRaw(fileIn,fileOut,password:=""){
	static lib:=A_IsCompiled?ResourceLoadLibrary("LiteZip.dll"):MemoryLoadLibrary("LiteZip.dll"), init:=lib?"":MessageBox(0,"Error: LiteZip.dll was not found","Error"), CreateBuffer:=DynaCall(MemoryGetProcAddress(lib,"ZipCreateBuffer"),"t*tuia")
		 , AddZipBufferRaw:=DynaCall(MemoryGetProcAddress(lib,"ZipAddBufferRaw"),"ttui"),GetMemory:=DynaCall(MemoryGetProcAddress(lib,"ZipGetMemory"),"tt*ui*t*")
		 , CloseZip:=DynaCall(MemoryGetProcAddress(lib,"ZipClose"),"t"),AddZipBuffer:=DynaCall(MemoryGetProcAddress(lib,"ZipAddBufferW"),"tstui")
  If InStr(fileOut,"?") = 1{ ; ? => fileIn is a HEX, e.g. ZipFileRaw("0AC688FF000000AB9F","?C:\Temp\MyFile.txt")
    fileOut:=SubStr(fileOut,2),VarSetCapacity(file,sz:=StrLen(fileIn)//2)
    Loop sz
      NumPut("0x" SubStr(fileIn,2*A_Index-1,2),file,A_Index-1,"Char")
    pData:=&file
  } else if InStr(fileOut,"|"){ ; Raw Data: "sizeof fileIn|filename", e.g. ZipFileRaw(&fileIn,"20354|C:\Temp\MyFile.zip")
    sz:=SubStr(fileOut,1,InStr(fileOut,"|")-1)+0
    ,fileOut:=SubStr(fileOut,InStr(fileOut,"|") + 1)
    ,pData:=fileIn
  } else {	; ZipFileRaw("C:\Temp\MyFile.txt","C:\Temp\MyFile.zip")
  	FileGetSize,sz,% fileIn
  	FileRead,file,*c %fileIn%
    pData:=&file
  }
  if !sz{
    MsgBox Error FileIn %fileIn%
    return
  }
	CreateBuffer[hzip,0,sz*2,0] ; *2 to make sure we have enough room
	,AddZipBufferRaw[hzip,pData,sz] , result:=GetMemory[hzip,buffer,len,base]
	if (len>=sz)
		len:=sz,DllCall("UnmapViewOfFile","PTR",buffer),DllCall("CloseHandle","PTR",base),buffer:=pData
  If FileExist(fileout)
		FileDelete % fileout
	handle := CreateFile(fileout,1073741824,0,0,2,128) ; GENERIC_WRITE,,,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL
	if (handle < 1)
		MsgBox Error Open File %fileout%
	else
	{
		if password {
		  DllCall("crypt32\CryptBinaryToStringA","PTR",buffer,"UINT",len,"UInt",0x1,"PTR",0,"UInt*",encLen:=0)
		  ,VarSetCapacity(buff,16 + encLen,0)
		  ,DllCall("crypt32\CryptBinaryToStringA","PTR",buffer,"UINT",len,"UInt",0x1,"PTR",&buff,"UInt*",encLen)
		  if (!encLen:=CryptAES(buff,encLen+1,password)){ ; encLen + 1 due to terminating character returned by first call to CryptBinaryToStringA
			MsgBox Error CryptAES
			return
		  }
		  pBuff:=&buff
		} else pBuff:=buffer,encLen:=0
		hdr:=Struct("UInt[5]",[0x4034b50,0,len,sz,encLen])
		,HashData(pBuff,encLen?encLen:len,hdr[] + 4,4)
		if !WriteFile(handle,hdr[],sizeof(hdr),getvar(written:=0))
			MsgBox Error WriteFile
		if !WriteFile(handle,pBuff,encLen?encLen:len,getvar(written:=0))
			MsgBox Error WriteFile
		DllCall("CloseHandle",PTR,handle)
	}
	if (buffer!=pData)
		DllCall("UnmapViewOfFile","PTR",buffer),DllCall("CloseHandle","PTR",base)
	return sizeof(hdr) + (encLen?encLen:len)
}

/*
ZipFileRaw(fileIn,fileOut,pwd:=0){
	static lib:=DllCall("LoadLibrary",Str,"LiteZip.dll"), CreateBuffer:=DynaCall("LiteZip\ZipCreateBuffer","t*tuis")
		, AddZipBufferRaw:=DynaCall("LiteZip\ZipAddBufferRaw","ttui"),GetMemory:=DynaCall("LiteZip\ZipGetMemory","tt*ui*t*")
		, CloseZip:=DynaCall("LiteZip\ZipClose","t")
  If InStr(fileIn,"|"){
    fileIn:=SubStr(fileIn,2)
    VarSetCapacity(file,sz:=StrLen(fileIn)//2)
    Loop sz
      NumPut("0x" SubStr(fileIn,2*A_Index-1,2),file,A_Index-1,"Char")
  } else {
  	FileGetSize,sz,%fileIn%
  	FileRead,file,*c %fileIn%
  }
  if !sz{
    MsgBox Error FileIn %fileIn%
    return
  }
	CreateBuffer[hzip,0,sz*2,pwd] ; *2 to make sure we have enough room
	AddZipBufferRaw[hzip,&file,sz]
	result:=GetMemory[hzip,buffer,len,base]
	handle := DllCall("CreateFile","Str",fileout,"UInt",1073741824,"UInt", 0,"PTR", 0,"UInt", 2,"UInt", 128,"PTR", 0) ; GENERIC_WRITE,,,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL
	if (handle < 1)
		MsgBox Error Open File %fileout%
	else
	{
		VarSetCapacity(hdr,16,0),NumPut(0x4034b50,hdr,"UInt"),NumPut(len,hdr,8,"UInt"),NumPut(sz,hdr,12,"UInt")
		DllCall( "shlwapi\HashData", PTR,  buffer               ; Read data pointer
                            , UInt,  len 						; Read data size
                            , PTR,  &hdr + 4                 	; Write data pointer
                            , UInt,  4 )                      	; Write data length in bytes
		if (!DllCall("WriteFile","PTR",handle,"PTR", &hdr,"UInt", 16,"UInt*", written,"PTR", 0))
			MsgBox Error WriteFile
		if (!DllCall("WriteFile","PTR",handle,"PTR", buffer,"UInt", len,"UInt*", written,"PTR", 0))
			MsgBox Error WriteFile
		DllCall("CloseHandle",PTR,handle)
	}
	DllCall("UnmapViewOfFile",PTR,buffer)
	DllCall("CloseHandle",PTR,base)
	return len

}

/*
ZipFileRaw(fileIn,fileOut){
static lib:=DllCall("LoadLibrary",Str,"LiteZip.dll"),CreateBuffer:=DynaCall("LiteZip\ZipCreateBuffer","t*tuit")
,AddZipBufferRaw:=DynaCall("LiteZip\ZipAddBufferRaw","ttui"),GetMemory:=DynaCall("LiteZip\ZipGetMemory","tt*ui*t*")
,CloseZip:=DynaCall("LiteZip\ZipClose","t"),CloseHandle:=DynaCall("CloseHandle","t"),UnmapViewOfFile:=DynaCall("UnmapViewOfFile","t")
,WriteFile:=DynaCall("WriteFile","ttuiui*t"),HashData:=DynaCall("shlwapi\HashData","tuitui")
,hdr:=Struct("uint pkhdr,uint hash,uint comprs,uint uncomprs",{pkhdr:0x4034b50})
hdr.uncomprs:=sz:=FileGetSize(fileIn),file:=FileRead("*c " fileIn)
MsgBox % sz
CreateBuffer[hzip,0,1000000,0],AddZipBufferRaw[hzip,&file,sz],result:=GetMemory[hzip,buffer,len,base]
if 1>handle:=DllCall("CreateFile",Str,fileout,UInt,1073741824,UInt,0,PTR,0,UInt,2,UInt,128,PTR,0,PTR)
return 0
else if hdr.comprs:=len&&!HashData[buffer,len,hdr.hash[""],4]
if !WriteFile[handle,hdr[],16,written,0]||!WriteFile[handle,buffer,len,written,0]
return CloseHandle[handle],0
else CloseHandle[handle]
return UnmapViewOfFile[buffer],CloseHandle[base],len
}