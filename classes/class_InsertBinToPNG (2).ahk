#Include gdip.ahk

class BinInPNG
{
	static _init:=0

	init()
	{
		if(this._init)
			Return 1
		If !this.pToken := Gdip_Startup()
		{
			MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
			Return -1
		}
		this._init:=1
		Return 0
	}

	selectPic(sFile)
	{
		if(!this._init)
			Return -1
		this.pBitmap:=Gdip_CreateBitmapFromFile(sFile)
		this.Width:=Gdip_GetImageWidth(this.pBitmap)
		this.Height:=Gdip_GetImageHeight(this.pBitmap)
		this.volume:=((this.Width*this.Height*3)//8)
		if(this.volume<=37)
			Return -2
		Return this.volume
	}

	getChar(char_Index)
	{
		if(!this.pBitmap)
			Return -1
		pixel_Index:=Ceil((char_Index*8-7)/3)
		y:=pixel_Index//this.Width+1
		x:=Mod(pixel_Index, this.Width)
		rgb_Index:=Mod(char_Index*8-7, 3)
		if(rgb_Index=0)
			loopCount:=4
		Else
			loopCount:=3
		array:={}
		Loop, % loopCount
		{
			Gdip_FromARGB(Gdip_GetPixel(this.pBitmap, x, y), A, R, G, B)
			array.Insert(R&0x1)
			array.Insert(G&0x1)
			array.Insert(B&0x1)
			x:=x=this.Width?1:x+1
			y:=x=1?y+1:y
		}
		if(rgb_Index=0)
			startCount:=3
		Else
			startCount:=rgb_Index
		output:=0
		Loop, 8
		{
			output<<=1
			output+=array[A_Index+startCount-1]
		}
		Return, output
	}

	putChar(uchar,char_Index)
	{
		if(!this.pBitmap)
			Return -1
		pixel_Index:=Ceil((char_Index*8-7)/3)
		y:=pixel_Index//this.Width+1
		x:=Mod(pixel_Index, this.Width)
		rgb_Index:=Mod(char_Index*8-7, 3)
		if(rgb_Index=0)
			startCount:=3
		Else
			startCount:=rgb_Index

		temp:=0x01000000>>(startCount*8)
		ARGB:=Gdip_GetPixel(this.pBitmap, x, y)
		Loop, 8
		{
			if(uchar&0x80)
				ARGB|=temp
			Else
				ARGB&=0xFFFFFFFF^temp
			uchar<<=1
			if(temp=0x1){
				temp=0x00010000
				Gdip_SetPixel(this.pBitmap, x, y, ARGB)
				x:=x=this.Width?1:x+1
				y:=x=1?y+1:y
				ARGB:=Gdip_GetPixel(this.pBitmap, x, y)
			} Else {
				temp>>=8
			}
		}
		Gdip_SetPixel(this.pBitmap, x, y, ARGB)
		Return 0
	}

	putStr(byref str,char_Index=1)
	{
		if(!this.pBitmap)
			Return -1
		if(!IsObject(str))
			Return -2

		pixel_Index:=Ceil((char_Index*8-7)/3)
		y:=pixel_Index//this.Width+1
		x:=Mod(pixel_Index, this.Width)
		rgb_Index:=Mod(char_Index*8-7, 3)
		if(rgb_Index=0)
			startCount:=3
		Else
			startCount:=rgb_Index
		temp:=0x01000000>>(startCount*8)

		ARGB:=Gdip_GetPixel(this.pBitmap, x, y)
		Loop, % str.MaxIndex()
		{
			uchar:=str[A_Index]
			Loop, 8
			{
				if(uchar&0x80)
					ARGB|=temp
				Else
					ARGB&=0xFFFFFFFF^temp
				uchar<<=1
				if(temp=0x1){
					temp:=0x00010000
					Gdip_SetPixel(this.pBitmap, x, y, ARGB)
					x:=x=this.Width?1:x+1
					y:=x=1?y+1:y
					ARGB:=Gdip_GetPixel(this.pBitmap, x, y)
				} Else {
					temp>>=8
				}
			}
		}
		Gdip_SetPixel(this.pBitmap, x, y, ARGB)
		Return 0
	}

	putStrFromHead(byref str)
	{
		return this.putStr(str,1)
	}

	putBinMsg(byref binMsg)
	{
		if(!IsObject(binMsg))
			Return -2
		if(binMsg.id!=0xb807dfb6)
			Return -1
		if(binMsg.head.filename.MaxIndex()+binMsg.content.MaxIndex()+17>=this.volume)
			Return this.volume-1-(binMsg.head.filename.MaxIndex()+binMsg.content.MaxIndex()+17)	;need more pixel
		this.putChar(binMsg.version,1)
		offset:=this.getChar(2)
		this.putChar((binMsg.version+offset)&0xff,3)
		this.putStr(binMsg.head.size,4)
		this.putStr(binMsg.head.filename,17)
		this.putStr(binMsg.content,17+binMsg.head.filename.MaxIndex())
		binMsg.free()
		Return 0
	}

	getBinMsg(filename="$FileName$")	;$FileName$ $NameNoExt$ $Ext$
	{
		if(!this.pBitmap)
			Return -1

		_head:={}
		_head.version:=this.getChar(1)

		if(_head.version!=0xA1)
			Return -2

		offset:=this.getChar(2)
		if((_head.version+offset&0xff)!=this.getChar(3))
			Return -3

		_head.size:={}
		Loop, 3
			_head.size.Insert(this.getChar(A_index+3))
		size:=(_head.size[1]<<16)|(_head.size[2]<<8)|(_head.size[3])

		_head.filename:={}
		Loop
		{
			_head.filename.Insert(this.getChar(A_index+16))
			if((A_Index&0x1)=0)	;str end check
			{
				if(_head.filename[A_Index]=0 and _head.filename[A_Index-1]=0)
					break
			}
		}
		; if(_head.filename.MaxIndex()<=2)
		; {
		; 	;no name
		; }
		VarSetCapacity(_name,_head.filename.MaxIndex())
		Loop, % _head.filename.MaxIndex()
			NumPut(_head.filename[A_index],_name,A_Index-1,"UChar")
		fullname:=strGetVar(_name)
		SplitPath, fullname,,,Ext,NameNoExt
		StringReplace, filename, filename,$FileName$,% fullname, All
		StringReplace, filename, filename,$NameNoExt$,% NameNoExt, All
		StringReplace, filename, filename,$Ext$,% Ext, All

		_content:={}
		Loop, % size
		{
			_content.Insert(this.getChar(A_Index+16+_head.filename.MaxIndex()))
		}
		oFile:=FileOpen(filename, "w")
		Loop, % size
			oFile.WriteUChar(_content[A_Index])
		oFile.Close()
	}

	savePng(sOutput)
	{
		Gdip_SaveBitmapToFile(this.pBitmap, sOutput ".png")
	}

	version()
	{
		Return, "alpha 0"
	}
}

/*

alpha 0:
字节1为版本号A1
字节2从原图中读取，为全局偏移量
字节3为添加偏移量的版本号
字节4,5,6为长度，最大16Mb
字节7-16保留
字节17-(结束0x00,0x00)为文件名
之后为内容

字节为MSB顺序

生成图像时，若空间不足文件名长度+17+1，则应提示空间不足
*/


class binMsg
{
	; static version:=0xA1

	__New(sFile)
	{
		IfNotExist, % sFile
			Return -1
		FileGetSize, size, % sFile, B
		if(size>10000000)
			Return -2
		oFile:=FileOpen(sFile, "r")
		this.content:={}
		while(!oFile.AtEOF){
			oFile.RawRead(bytes,1)
			this.content.Insert(asc(bytes))
		}

		size:=this.content.MaxIndex()	;they are not equal sometimes

		oFile.Close()
		this.head:={}
		this.head.version:=this.version
		this.head.size:={}
		this.head.size.Insert((size>>16)&0xff)
		this.head.size.Insert((size>>8)&0xff)
		this.head.size.Insert(size&0xff)
		this.head.filename:={}
		SplitPath, sFile, name
		nameLength:=strPutVar(name, str)*2
		Loop, % nameLength
			this.head.filename.Insert(NumGet(str,A_Index-1,"UChar"))
		Return this
	}

	addOffset(offset)
	{
		if(offset>=0)
		{
			offset&=0xff
		}
		Else
		{
			offset:=-offset
			offset&=0xff
			offset:=-offset
		}
		Loop, % this.content.maxIndex()
		{
			if(offset<0)
				this.content[A_Index]+=0x100
			this.content[A_Index]+=offset
			this.content[A_Index]&=0xff
		}
	}

	__Get(key)
	{
		if(key="length")
			Return, this.content.Maxindex()
		else if(key="version")
			Return, 0xA1
		else if(key="id")
			Return, 0xb807dfb6
		Else
			Msgbox,4096,, No key named %key%
		Return -1
	}

	free()
	{
		this.content:=""
		this.__Delete()
	}
}

strPutVar(string, ByRef var)
{
	VarSetCapacity(var,StrPut(string,"utf-16")*2)
	return StrPut(string, &var,"utf-16")
}

strGetVar(ByRef var)
{
	return StrGet(&var,"utf-16")
}
