
/******************************************************************************

	; ahk forum : http://www.autohotkey.com/community/viewtopic.php?f=2&t=84054
	; StructClass Make Helper : http://www.autohotkey.net/~chaidy/Ahk%20Source/CStruct/CStruct_ScriptMaker.rar

	< CStruct_Base class - AHK_L (32bit & 64bit) >

	ver 5.8 - last update 2012.05.07		: add 'm_struct.tCls" - refer to m_template[this.__class]
   
	<Properties>
	struct.member 							: set or get struct member's value.
											  (ex. var := rect.right , rect.top := 1 , struct.rect := new CRect(0,0,100,100) )
	struct.member["count"]					: get struct member array count. normaly 1 return.
	struct.member["type"]					: get struct member type.
	struct.member["size"]					: get struct member type size. its same "sizeof(type)"
	struct.member["Ptr"] or [""]			: get struct member address. (ex. Numget(rect.top["Ptr"],0,"Uint") )
	struct.Ptr   or   struct[""]			: get struct starting address. (ex. GetWindowRect(hwnd, rect.ptr) )
	struct.size  or   struct["size"]		: get struct size. (ex. cbSize := struct.size )
   
	struct.stringArrayMember := "hello." 	: set string to struct character array member. ( possable array type: CHAR,TCHAR,WCHAR )
	struct.LPSTRtypeMember["bufferSize"]	: set or get capacity for include string buffer. (its need for receive string data from win api)
	struct.LPSTRtypeMember := stringVar 	: set include string from stringVar. (auto capacity allocate for string buffer.)
	struct.LPSTRtypeMember := "String" 		: set include string from "String". but exclude number data in thease "42344", "330", ...
	struct.LPSTRtypeMember := &var			: not include string. only save variable address value.
   
   
	<Method>
	- AddStructVar(varName, varType, arrayCount, unionState)
		ex1. use window api variable type (byte, int, char, LPSTR, HICON, ...)
			AddStructVar("width", "int")     AddStructVar("winName", "wchar", 32)
         
		ex2. use defined CStruct class type (CPoint, CRect, ...)
			AddStructVar("pt", "CPoint")     AddStructVar("ptArray", "CPoint", 10)

		ex3. define union member
			AddStructVar("a" , "Byte" , "union_start")
			AddStructVar("b" , "Word")
			AddStructVar("c" , "DWord" , "union_end")
		 
		ex4. define bitfield type member
			AddStructVar("b" , "Word" , "bit:4")
			
		<Caution>
		- It's best not to use arrayCountVar if possable. i strongly recommend use a numeric constant instead of variable.
			good 		: 					AddStructVar("a" , "Word" , 10)
			not good 	: count := 10   ,	AddStructVar("a" , "Word" , count)
		- why not good	: struct class can't make from template if AddStructVar(.. ) has arrayCountVar variable.
						  perfomance bad as a result of not use numeric constant.
		- but why need	: it's use last AddStructVar line if variable size of the required buffer for end of the struct.
		  it's example 	- structure	: http://msdn.microsoft.com/en-us/library/dd162755(v=VS.85).aspx
						- CStruct	: http://www.autohotkey.com/community/viewtopic.php?f=2&t=84054#p534383

            
	- SetStructCapacity()				: allocate memory for added struct var.
   
	- CopyFrom(Ptr or CStructObj)		: copy from 'Same struct' address or same CStruct object.
	- ToString()						: get struct member normaly infomation.
	- TreeView()						: Show Structure Object on TreeView.(CStruct_Base.TreeView() - show class template)
	- Clone()							: get clone object.
	- CheckName(name)					: check struct member name validation. use in inherit class.
	- GetData(name, n)					: get struct member data. use in inherit class. (n: arrayNumber, "ptr", "type", "count")
	- SizeOf(varType)					: get varType size. 0 return if undefined type.
	- Encoding(name, type, mode)  		: get default encoding. possable override in inherit class. (mode : get or set)
   
   
	<method overridding model> 
	__Get(name, arryNum=0)					; struct has array member and access to array member in __Get() method .
	{ 										; in inherit class then must insert second parameter 'arryNum=0'
	}
	__Set(name, ByRef param1, param2*)		; must need 'ByRef' param1
	{
	}


	<structure class making sample>
	class CSample extends CStruct_Base						; must write "extends CStruct_Base"
	{
		__New()												; or  __New(param*)
		{
			this.AddStructVar("a", "int")					; <- int a;
			this.AddStructVar("b", "int", 3) 				; <- int b[3]
			this.AddStructVar("c", "int", "bit:3")			; <- int c :3;
			this.AddStructVar("d", "dword", "union_start")	; <- union { dword d;
			this.AddStructVar("e", "CRect")					; <- RECT e;
			this.AddStructVar("f", "char", 2, "union_end")	; <- char f[2]; }
			this.SetStructCapacity()						; allocate struct memory
		}
	}
*/

;******************************************************************************

;0 : not exit after error msg.
;1 : exit after error msg
CStruct_Base__Flag_ExitAppAfterErrorMsg := 1

class CStruct_Base
{
	static m_template := {}

	__New()
	{
		if (this.__class="CStruct_Base")
			this.__ErrorMsg("error_basenew", this.__class)
	}
	__Initialize()
	{
		tCls := this.m_template[this.__class]
		this.m_struct := (!tCls.sizeVariable and tCls.dummy)? tCls.dummy : {"addr":0, "data":"", child:{}}
		if tCls.dummy
			this.m_useDummy := 1  ,  tCls.dummy := ""
		if this.m_useDummy
			return
		if !tCls.sizeVariable and this.__MakeThisClassFromTemplate()
			this.m_useTemplate := 1
		if !this.m_useTemplate
		{
			this.m_union := {"state":0, "state_old":0, "offset":0, "size":0}
			this.m_bitField := {"bitCount":0, "size_old":0, "offset_old":0}
		}
		if !tCls or (tCls.sizeVariable and tCls.created)
			this.m_template[this.__class] := {"varList":{}, "varOrder":{}}
	}
	
	__Delete()
	{
		tCls := this.m_struct.tCls
		if !tCls.sizeVariable and !tCls.dummy
			tCls.dummy := this.m_struct
	}
	
	__Get(name, number=0)
	{
		if ("m_"<>SubStr(name, 1, 2)) and (name<>"__class")
			return this.GetData(name, number, 1)
	}
	GetData(name, number=0, callFrom__Get=0)
	{
		mObj := this.m_struct
		tCls := mObj.tCls
		if (name="ptr") or (name="")
			return mObj.addr
		else if (name="__base")
			return "CStruct_Base"
		else if (name="size")
			return mObj.addr? tCls.size : this.__GetNextVarOffset()
		if vObj := tCls.varList[name]
		{
			name_exist = 1
			if (number="ptr") or (number="")
				return mObj.addr + vObj.o
			if (number="count")
				return vObj.c
			if (number="type")
				return vObj.org
			if (number="size")
				return vObj.s
			if (number="bufferSize")
				return ObjGetCapacity(mObj.string, name)
			if (number=0)
			{
				orgType := vObj.org
				encoding := this.Encoding(name, vObj.org, "get")
				if (vObj.c = 1)
				{
					if callFrom__Get and InStr(orgType, "STR")
					{
						if encoding
							return StrGet(NumGet(mObj.addr, vObj.o, vObj.t), encoding)
						else
							return StrGet(NumGet(mObj.addr, vObj.o, vObj.t))
					}
					number := 1
				}
				else
				{
					if orgType in CHAR,TCHAR,WCHAR
						if encoding
							return StrGet(mObj.addr+vObj.o, vObj.c, encoding)
						else
							return StrGet(mObj.addr+vObj.o, vObj.c)
					return Object("error", 1)
				}
			}
			if (vObj.t="CStruct_Base")
				return mObj.child[name][number]
			else
			{
				if (number<=vObj.c)
				{
					if !mObj.addr
						return this.__ErrorMsg("error_addr", this.__Class "." A_ThisFunc)
					if !vObj.bc
						return NumGet(mObj.addr, vObj.o + vObj.s * (number-1), vObj.t)
					;bitfield get
					if (number=1)
					{
						field := NumGet(mObj.addr, vObj.o, vObj.t)
						mask = 0x
						loop % vObj.s
							mask .= "ff"
						mask >>= vObj.s*8 - vObj.bc  ,	mask <<= vObj.bo  ,  field &= mask
						return field >> vObj.bo
					}
				}
			}
		}
		if !name_exist
			return this.__ErrorMsg("error_notexistname", this.__Class "." A_thisFunc, name)
	}
	
	__Set(name, ByRef first, second*)
	{
		if ("m_"<>SubStr(name, 1, 2))
		{
			mObj := this.m_struct
			tCls := mObj.tCls
			if vObj := tCls.varList[name]
			{
				name_exist = 1
				if !mObj.addr
					return this.__ErrorMsg("error_addr", this.__Class "." A_ThisFunc)
				if !ObjHasKey(second, 1)
				{
					if (vObj.t="CStruct_Base")
					{
						if (mObj.child[name][1].__class=first.__class)
						{
							mObj.child[name][1].CopyFrom(first)
							return first
						}
					}
					else
					{
						orgType := vObj.org
						if first is not Integer
							strValue := 1
						if (vObj.c>1) and InStr(",CHAR,TCHAR,WCHAR,", "," orgType ",")
						{
							if encoding := this.Encoding(name, vObj.org, "set")
							{
								codeSize := this.__GetEncodingSize(encoding)
								size := StrPut(first, encoding) * codeSize
								if (size <= vObj.c * vObj.s)
									result := StrPut(first, mObj.addr+vObj.o, vObj.c, encoding)
							}
							else
								result := StrPut(first, mObj.addr+vObj.o, vObj.c-1)
							if result
								return first
						}
						else if (vObj.c=1) and InStr(orgType, "STR") and (strValue or IsByRef(first))
						{
							if addr := this.__StringInclude(name, orgType, first)
								return first  ,  NumPut(addr, mObj.addr, vObj.o, vObj.t)
						}
						else if !vObj.bc
						{
							NumPut(first+0, mObj.addr, vObj.o, vObj.t)
							return first
						}
						else
						{
							;bitfield set
							field := NumGet(mObj.addr, vObj.o, vObj.t)
							maskAll = 0x
							loop % vObj.s
								maskAll .= "ff"
							mask1 := maskAll
							mask2 := mask1 >>= vObj.s*8 - vObj.bc  ,  mask1 <<= vObj.bo  ,  mask1 ^= maskAll
							field &= mask1  ,  mask2 &= first+0    ,  mask2 <<= vObj.bo  ,  field |= mask2
							NumPut(field, mObj.addr, vObj.o, vObj.t)
							return first
						}
						return
					}
				}
				else	;if ObjHasKey(second, 1)
				{
					if (first="bufferSize") and (vObj.c=1) and InStr(vObj.org, "STR") and (second[1]>=0)
						return second[1]  ,  this.__SetSizeForIncludeString(name, second[1])
					if (first<1) or (first>vObj.c)
						return
					if (vObj.t="CStruct_Base")
					{
						obj := mObj.child[name][first]
						if (obj.__class=second[1].__class)
						{
							obj.CopyFrom(second[1])
							return second[1]
						}
					}
					else
					{
						NumPut(second[1]+0, mObj.addr, vObj.o + vObj.s * (first-1), vObj.t)
						return second[1]
					}
				}
			}
			if !name_exist
				return this.__ErrorMsg("error_notexistname", this.__Class "." A_thisFunc, name)
		}
	}
	
	;------------------------------------------------------------
	AddStructVar(ByRef name, orgType, ByRef arrayCount=1, unionState="")
	{
		if !this.m_struct
			this.__Initialize()
		if this.m_useDummy or this.m_useTemplate
			return
		
		tCls := this.m_struct.tCls := this.m_template[this.__class]
		if IsByRef(name) or IsByRef(arrayCount)
		{
			tCls.sizeVariable := 1
			if (arrayCount=0)
				return
		}

		count := arrayCount
		orgCount := count , orgUState := unionState
		if count is not Integer
		{
			StringReplace, bitCount, count, % " ",, All
			bitCount := RegExReplace(bitCount, "i)bit:")
		}
		if bitCount is Integer
			count := 0
		else
			bitCount := 0
		if count is not Integer
		if (unionState="")
			unionState := count , count := 1
		uObj := this.m_union
		uObj.state_old := uObj.state
		if (unionState="union_start")
			uObj.state := 1 , uObj.state_old := 0
		else if (unionState="union_end")
			uObj.state := 2
		else if (unionState<>"")
		{
			msg = `"%unionState%`" : sentence error.
			return this.__ErrorMsg("error_addvar", A_ThisFunc, name, orgType, orgCount, orgUState, msg)
		}
		if (uObj.state=0)
			uObj.offset := uObj.size := 0
		if (uObj.state=3)
			uObj.state := 0
		if count is not integer
			countInvalid := 1
		if (count<0)
			countInvalid := 1
			
		if !name or !orgType or countInvalid or (!goodName:=this.CheckName(name, 1))
		or (badType:=RegExMatch(RegExReplace(orgType, "\."), "\W")) or (badType:=RegExMatch(orgType, "\.\."))
		or (badBit := !count and (bitCount<=0))
		{
			msg := (!orgType or badType)? "invalid varType." : !name? "Invalid varName." : goodName=0? """" name """  can't use this varName." 
			: goodName=""? """" name """ : already exist this varName." : countInvalid? """" count """ invalid array count." 
			: badBit? """bit:" bitCount """ invalid bit field count": ""
			return this.__ErrorMsg("error_addvar", A_ThisFunc, name, orgType, orgCount, orgUState, msg)
		}
		
		count := count<1 ? 1 : count
		size := 0
		if !InStr(orgType, ".") and (size := this.sizeof( type := this.wintype(orgType) ))
		{
			allSize := size * count
			if bitCount and (size*8<bitCount)
				return this.__ErrorMsg("error_addvar", A_ThisFunc, name, orgType, orgCount, orgUState
				, """bit:" bitCount """ type of bit field too small for number of bits")
		}
		else
		{
			cls := this.__MakeClass(orgType)
			if (badType:=(cls.__base<>"CStruct_Base")) or bitCount
			{
				msg := badType? """" orgType """ : invalid this varType." : bitCount? """bit:" bitCount 
				. """ bit field can't use with a struct class type" : ""
				return this.__ErrorMsg("error_addvar", A_ThisFunc, name, orgType, orgCount, orgUState, msg)
			}
			type := "CStruct_Base"
			size := cls.size
			allSize := size * count
			
			child := this.m_struct.child
			if !IsObject(child[name])
				child[name] := {}
			child[name].Insert(cls)
			loop % count-1
				child[name].Insert(this.__MakeClass(orgType))
		}
		
		;Get varList obj from class template object
		vList := tCls.varList
		if !tCls.size
			tCls.size := 0
		if !IsObject(vList[name])
			vList[name] := {}

		sizeBackup := tCls.size
		if (uObj.state=1)and(uObj.state_old=0) or (uObj.state=0)and(uObj.state_old=3)
			unionStateChange := 1
		if ((uObj.state=2)and(uObj.state_old=1)) or ((uObj.state=1)and(uObj.state_old=1))
		{
			if (uObj.state=2)
				uObj.state := 3
			vList[name].o := uObj.offset
			uObj.size := uObj.size<allSize? allSize:uObj.size
			tCls.size := uObj.offset + uObj.size
			union := 1
		}
		else 
		{
			vList[name].o := this.__GetNextVarOffset((type="CStruct_Base")? pack:=this.m_template[orgType].pack : size)
			tCls.size := vList[name].o + uObj.size := allSize
			if (uObj.state=1)
				uObj.offset := vList[name].o
		}

		if bitCount
		{
			tCls.size := sizeBackup
			bitObj := this.__GetNextVarBitObj(bitCount, size, unionStateChange, union)
			vList[name].o := bitObj.offset
			vList[name].bo := bitObj.bitOffset
			vList[name].bc := bitCount
			tCls.size += bitObj.addSize
		}

		vList[name].t := type
		vList[name].s := size
		vList[name].c := count
		vList[name].org := orgType
		pack := (type="CStruct_Base")? pack : size
		if !tCls.pack
			tCls.pack := pack
		else
			tCls.pack := (tCls.pack>pack)? tCls.pack : pack
		tCls.varOrder.Insert(name)
		if (type="CStruct_Base")
		{
			if !tCls.child
				tCls.child := {}
			tCls.child.Insert(name, orgType)
		}
		
		this.m_bitField.offset_old := vList[name].o
		this.m_bitField.size_old := bitCount? size : 0
	}
	
	;------------------------------------------------------------
	SetStructCapacity(ParentPutAddress=0)
	{
		mObj := this.m_struct
		tCls := mObj.tCls
		if this.m_useDummy
		{
			DllCall("RtlZeroMemory", "Ptr",mObj.addr, "UInt",tCls.size)
			return
		}
		
		if !ParentPutAddress and !this.m_useTemplate
		{
			tCls.size := this.__GetNextVarOffset()
			if this.m_union
				this.m_union := "" 
			if this.m_bitField
				this.m_bitField := ""
			tCls.created := 1
		}
		
		if (mObj.addr<>0)
			ObjSetCapacity(mObj, "data", mObj.addr := 0)
		if ParentPutAddress
			mObj.addr := ParentPutAddress
		else
		{
			ObjSetCapacity(mObj, "data", tCls.size)
			mObj.addr := ObjGetAddress(mObj, "data")
			DllCall("RtlZeroMemory", "Ptr",mObj.addr, "UInt",tCls.size)
		}
		;child struct starting address put.
		;tCls:templateObj, vObj:varObj , mObj:memberObj, cArray:sameNameArray
		vList := tCls.varList
		for cName, cArray in mObj.child
		{
			vObj := vList[cName]
			for number, obj in cArray
				obj.SetStructCapacity(mObj.addr + (vObj.o + vObj.s * (number-1)))
		}
	}
   
	Clone()
	{
		cls := this.__MakeClass(this.__class)
		cls.CopyFrom(this)
		return cls
	}

	CopyFrom(from)
	{
		fObj := from.m_struct
		mObj := this.m_struct
		tCls := mObj.tCls
		if !mObj.addr
			return this.__ErrorMsg("error_addr", this.__Class "." A_ThisFunc)
		if !IsObject(from)
		{
			DllCall("RtlMoveMemory", "Ptr",mObj.addr, "Ptr",from , "UInt",tCls.size)
			return
		}
		if (this.__class<>from.__class)
			return
		DllCall("RtlMoveMemory", "Ptr",mObj.addr, "Ptr",fObj.addr , "UInt",tCls.size<fObj.tCls.size? tCls.size : fObj.tCls.size)
		for name in fObj.string
		{
			vObj := tCls.varList[name]
			mObj.string[name] := ""
			size := ObjSetCapacity(mObj.string, name, ObjGetCapacity(fObj.string, name))
			DllCall("RtlMoveMemory", "Ptr", addr := ObjGetAddress(mObj.string, name), "Ptr", ObjGetAddress(fObj.string, name), "UInt", size)
			NumPut(addr, mObj.addr, vObj.o, vObj.t)
		}
	}
	
	; 1 return : ok
	; 0 return : invalid var name
	;"" return : exist var name
	CheckName(name, check_duplication=0)
	{
		if name in count,type,ptr,size,__base,__class
			return 0
		if ("m_"=SubStr(name, 1, 2))
			return 0
		tCls := this.m_struct.tCls
		if ObjHasKey(tCls.varList, name)
			return (check_duplication and !tCls.created)? "" : 1
		else
			return check_duplication? 1 : 0
	}

	;------------------------------------------------------------
	;kind of string type : CHAR,TCHAR,WCHAR , STR,LPSTR,TSTR,LPTSTR,LPCTSTR,WSTR,LPWSTR,LPCWSTR
	;mode = get or set
	Encoding(name="", type="", mode="")
	{
		static uni  := "UTF-16"
		static ansi := "CP0"
		if A_IsUnicode
		{
			if type in CHAR,STR,LPSTR,LPCSTR
				return ansi
		}
		else
		{
			IfInString, type, W
				return uni
		}
		return ""
	}

	;STR type data copy and encoding then its address return
	;return : address=sucess , 0=fail
	__StringInclude(name, type, string)
	{
		if !this.m_struct.string
			this.m_struct.string := {}
		sObj := this.m_struct.string
		encoding := this.Encoding(name, type, "set")
		codeSize := this.__GetEncodingSize(encoding)
		length := encoding? StrPut(string, encoding) : StrPut(string)
		size := this.__SetSizeForIncludeString(name, length * codeSize + 2)
		DllCall("RtlZeroMemory" , "Ptr",addr:=ObjGetAddress(sObj, name) , "UInt",size)
		if encoding
			result := StrPut(string, addr, length, encoding)
		else
			result := StrPut(string, addr)
		if result
			return addr
		return 0
	}
	
	__SetSizeForIncludeString(name, size)
	{
		if !hasObj := this.m_struct.string
			this.m_struct.string := {}
		vObj := this.m_struct.tCls.varList[name]
		sObj := this.m_struct.string
		if !hasObj or !ObjHasKey(sObj, name)
		{
			sObj[name] := ""
			result := ObjSetCapacity(sObj, name, size)
		}
		else
		{
			result := size_old := ObjGetCapacity(sObj, name)
			if (size>size_old)
			{
				VarSetCapacity(str_old, size_old)
				DllCall("RtlMoveMemory", "Ptr", &str_old, "Ptr", ObjGetAddress(sObj, name), "UInt", size_old)
				result := ObjSetCapacity(sObj, name, size)
				DllCall("RtlMoveMemory", "Ptr", ObjGetAddress(sObj, name), "Ptr", &str_old, "UInt", size_old)
			}
		}
		return result
	}
	
	__GetEncodingSize(encoding)
	{
		if !encoding
			return A_IsUnicode? 2 : 1
		if encoding=CP0
			return 1
		if encoding in UTF-16,CP1200
			return 2
		if encoding in UTF-8
			return 4				;UTF-8 maximum size = 4
		return A_IsUnicode? 2 : 1
	}
	
	;------------------------------------------------------------
	;structure memory packing
	__GetNextVarOffset(nextVarSize=0)
	{
		tCls := this.m_template[this.__class]
		if !nextVarSize
			nextVarSize := tCls.pack? tCls.pack : 1
		;nextVarSize : 1,2,4,8,...
		if (tCls.size=0) or (nextVarSize<=1)
			return tCls.size
		shareSize := tCls.size//8 * 8
		restSize  := tCls.size - shareSize
		if !restSize
			return tCls.size
		if (nextVarSize>=8)
			return shareSize+8
		if (restSize<=nextVarSize)
			return shareSize+nextVarSize
		else
		{
			s := restSize//nextVarSize * nextVarSize
			r := restSize - s
			return r? shareSize+s+nextVarSize : shareSize+s
		}
	}

	;bitfield make
	__GetNextVarBitObj(bitCount, size, stateChange, union)
	{
		tCls := this.m_template[this.__class]
		mObj := this.m_struct
		bObj := this.m_bitField
		rObj := {}
		nextOffset := this.__GetNextVarOffset(size)
		if (bObj.size_old=0) or (bObj.size_old<>size) or stateChange
		{
			rObj.offset := nextOffset , rObj.bitOffset := 0 , rObj.addSize := size
			bObj.bitCount := bitCount
		}
		else if union
			rObj.Offset := bObj.offset_old , rObj.bitOffset := 0 , rObj.addSize := 0
		else
		{
			bitOver := (bObj.bitCount+bitCount) // (size*8) and Mod(bObj.bitCount+bitCount, size*8)
			rObj.offset := bitOver? nextOffset : bObj.offset_old
			rObj.bitOffset := bitOver? 0 : bObj.bitCount
			rObj.addSize := bitOver? size : 0
			bObj.bitCount := bitOver? bitCount : bObj.bitCount+bitCount
		}
		return rObj
	}

	__MakeClass(name)
	{
		loop Parse, name, .
			cls := (A_Index = 1 ? %A_LoopField% : cls[A_LoopField])
		return new cls
	}
	
	; class template use
	__MakeThisClassFromTemplate()
	{
		if !IsObject(this.m_template[clsName := this.__class])
			return 0
		tCls  := this.m_struct.tCls := this.m_template[clsName]
		child := this.m_struct.child
		for vName, clsName in tCls.child
		{
			if !child[vName]
				child[vName] := {}
			loop % tCls.varList[vName].c
				child[vName].Insert(this.__MakeClass(clsName))
		}
		return 1
	}

	__ErrorMsg(error_id, from, v*)
	{
		if (error_id="error_addr")
			MsgBox,, Error, % "event from: " from "()`n`nnot allocated struct memory.`n`n"
			. """this.SetStructCapacity()""  insert to """ this.__class ".__New()"""
		if (error_id="error_addvar")
			MsgBox,, Error, % this.__Class "." from "(varName`, varType`, arrayCount, unionState)`n`nvarName = """ v[1]
			. """`nvarType = """ v[2] """" . "`narrayCount = " v[3] . "`nunionState = " v[4]
			. ((v.MaxIndex()=5)and(v[5])? "`n`n" v[5] : "")
		if (error_id="error_notexistname")
			MsgBox,, Error, % "from: " from "()`n`n""" v[1] """  is not a member this Struct."
		if (error_id="error_basenew")
			MsgBox,, Error, % "from: " from "()`n`ndon't make ""CStruct_Base"" instance.`n`n" 
			. "this class only use base class."
		
		global CStruct_Base__Flag_ExitAppAfterErrorMsg
		if CStruct_Base__Flag_ExitAppAfterErrorMsg
			ExitApp
	}

	sizeof(type_name)
	{
		if (type_name="")
			return 0
		; http://l.autohotkey.net/docs/commands/DllCall.htm#types
		static Ptr:=A_PtrSize,UPtr:=A_PtrSize,Int64:=8,UInt64:=8,Int:=4,UInt:=4,Short:=2,UShort:=2,Char:=1,UChar:=1,Float:=4,Double:=8
		type_match := (%type_name%)
		if !type_match
			type_name := this.wintype(type_name)
		if !type_name
			return 0
		return (%type_name%)
	}
	
	wintype(type_name)
	{
		; http://msdn.microsoft.com/en-us/library/aa383751(v=vs.85).aspx
		static ATOM:="UShort",BOOL:="Int",BOOLEAN:="UChar",BSTR:="UPtr",BYTE:="UChar",CHAR:="Char",COLORREF:="UInt",DOUBLE:="Double",DWORD32:="UInt"
		,DWORD64:="UInt64",DWORD:="UInt",DWORD_PTR:="UPtr",DWORDLONG:="UInt64",FLOAT:="Float",HACCEL:="UPtr",HALF_PTR:=A_PtrSize=8?"Int":"Short"
		,HANDLE:="UPtr",HBITMAP:="UPtr",HBRUSH:="UPtr",HCOLORSPACE:="UPtr",HCONV:="UPtr",HCONVLIST:="UPtr",HCURSOR:="UPtr",HDC:="UPtr"
		,HDDEDATA:="UPtr",HDESK:="UPtr",HDROP:="UPtr",HDWP:="UPtr",HENHMETAFILE:="UPtr",HFILE:="Int",HFONT:="UPtr",HGDIOBJ:="UPtr",HGLOBAL:="UPtr"
		,HHOOK:="UPtr",HICON:="UPtr",HINSTANCE:="UPtr",HKEY:="UPtr",HKL:="UPtr",HLOCAL:="UPtr",HMENU:="UPtr",HMETAFILE:="UPtr",HMODULE:="UPtr"
		,HMONITOR:="UPtr",HPALETTE:="UPtr",HPEN:="UPtr",HRESULT:="Int",HRGN:="UPtr",HRSRC:="UPtr",HSZ:="UPtr",HWINSTA:="UPtr",HWND:="UPtr"
		,INT32:="Int",INT64:="Int64",INT:="Int",INT_PTR:="Ptr",LANGID:="UShort",LCID:="UInt",LCTYPE:="UInt",LGRPID:="UInt",LONG32:="Int"
		,LONG64:="Int64",LONG:="Int",LONG_PTR:="Ptr",LONGLONG:="Int64",LPARAM:="Ptr",LPBOOL:="UPtr",LPBYTE:="UPtr",LPCOLORREF:="UPtr"
		,LPCSTR:="UPtr",LPCTSTR:="UPtr",LPCVOID:="UPtr",LPCWSTR:="UPtr",LPDWORD:="UPtr",LPHANDLE:="UPtr",LPINT:="UPtr",LPLONG:="UPtr"
		,LPSTR:="UPtr",LPTSTR:="UPtr",LPVOID:="UPtr",LPWORD:="UPtr",LPWSTR:="UPtr",LRESULT:="Ptr",PBOOL:="Ptr",PBOOLEAN:="Ptr",PBYTE:="Ptr"
		,PCHAR:="Ptr",PCSTR:="Ptr",PCTSTR:="Ptr",PCWSTR:="Ptr",PDWORD32:="Ptr",PDWORD64:="Ptr",PDWORD:="Ptr",PDWORD_PTR:="Ptr",PDWORDLONG:="Ptr"
		,PFLOAT:="Ptr",PHALF_PTR:="Ptr",PHANDLE:="UPtr",PHKEY:="UPtr",PINT32:="UPtr",PINT64:="UPtr",PINT:="UPtr",PINT_PTR:="UPtr",PLCID:="UPtr"
		,PLONG32:="UPtr",PLONG64:="UPtr",PLONG:="UPtr",PLONG_PTR:="UPtr",PLONGLONG:="UPtr",POINTER_32:="UInt",POINTER_64:="Ptr"
		,POINTER_SIGNED:="Ptr",POINTER_UNSIGNED:="UPtr",PSHORT:="UPtr",PSIZE_T:="UPtr",PSSIZE_T:="UPtr",PSTR:="UPtr",PTBYTE:="UPtr",PTCHAR:="UPtr"
		,PTR:="Ptr",PTSTR:="UPtr",PUCHAR:="UPtr",PUHALF_PTR:="UPtr",PUINT32:="UPtr",PUINT64:="UPtr",PUINT:="UPtr",PUINT_PTR:="UPtr"
		,PULONG32:="UPtr",PULONG64:="UPtr",PULONG:="UPtr",PULONG_PTR:="UPtr",PULONGLONG:="UPtr",PUSHORT:="UPtr",PVOID:="UPtr",PWCHAR:="UPtr"
		,PWORD:="UPtr",PWSTR:="UPtr",SC_HANDLE:="UPtr",SC_LOCK:="UPtr",SERVICE_STATUS_HANDLE:="UPtr",SHORT:="Short",SIZE_T:="UPtr",SSIZE_T:="Ptr"
		,TBYTE:=A_IsUnicode?"UShort":"UChar",TCHAR:=A_IsUnicode?"UShort":"UChar",UCHAR:="UChar",UHALF_PTR:=A_PtrSize=8?"UInt":"UShort"
		,UINT32:="UInt",UINT64:="UInt64",UINT:="UInt",UINT_PTR:="UPtr",ULONG32:="UInt",ULONG64:="UInt64",ULONG:="UInt",ULONG_PTR:="UPtr"
		,ULONGLONG:="UInt64",UPTR:="UPtr",USHORT:="UShort",USN:="Int64",VOID:="Ptr",WCHAR:="UShort",WNDPROC:="UPtr",WORD:="UShort",WPARAM:="UPtr"
		return (%type_name%)
	}

	ToString(t="")
	{
		mObj := this.m_struct
		tCls := mObj.tCls
		if !mObj.addr
			return this.__ErrorMsg("error_addr", this.__Class "." A_ThisFunc)
		tab := "    "
		for order, name in tCls.varOrder
		{
			vObj := tCls.varList[name]
			if (vObj.t="CStruct_Base")
			{
				for i, v in mObj.child[name]
				{
					str .= "`n" t name " { " v.ToString(t tab)
					StringRight, chr, str, 1
					str .= (chr="`n")? t "}`n" : " }`n"
				}
			}
			else
			{
				nArr := this[name]	; => this.__Get(name,0)
				if (nArr.error)
				{
					nArr =
					loop % vObj.c
						nArr .= ", " this.GetData(name, A_index)
					StringReplace, nArr, nArr, % ", "
					nArr = { %nArr% }
				}
				else if (vObj.c>1) or ((vObj.c=1) and InStr(vObj.org, "STR"))
					nArr = `"%nArr%`"
				StringRight, chr, str, 1
				str .= (chr="`n")? ("`, " t name "=" nArr ) : ("`, " name "=" nArr)
			}
		}
		StringReplace, str, str, % "`n`n",  `n, all
		StringReplace, str, str, % "`n`, ", `n, all
		if (SubStr(str, 1, 2)="`, ")
			StringReplace, str, str, % "`, "
		return str
	}

	TreeView(Obj="", Option="", hParent="", r="", tObj="")
	{
		global CStruct_Base_hTreeView
		if (r = "")
		{
			if (!IsObject(Obj))
			{
				if (obj)
				guiTitle := Obj
				if (this.__class="CStruct_Base")
				{
					Obj := this.m_template  ,  r := "template"
					guiTitle := (!guiTitle)? "Structure Class template" : guiTitle
				}
				else
				Obj := this
			}
			
			iFormat := A_FormatInteger
			SetFormat, integer, D
			Gui +LastFound
			hWnd := WinExist()
			loop 99
				Gui % (nDefaultGui := A_Index) ":+LastFoundExist"
			until (WinExist() = hWnd)
			loop 70
				Gui % (nGui := A_index+29) ":+LastFoundExist"
			until (hwnd:=WinExist() = 0)
			if !hwnd
			{
				SetFormat, integer, % iFormat
				return
			}
			Gui % nGui ":Default"
			Gui +ToolWindow +Resize +LabelCStruct_Base_TreeView
			Gui Margin, -1, -1
			Gui Add, TreeView, w500 r18 hWndhWnd
			global CStruct_Base_hTreeView
			CStruct_Base_hTreeView := CStruct_Base_hTreeView? CStruct_Base_hTreeView : object()
			CStruct_Base_hTreeView.Insert(nGui, hWnd)
			Gui Show, x0 y0, % "[" (A_PtrSize=8? "64bit ":"") (A_IsUnicode? "Uni Ver":"Ansi Ver")
				. "] No. " nGui-29 (guiTitle? " - " guiTitle : "")
			if 0
			{
				CStruct_Base_TreeViewEscape:
				CStruct_Base_TreeViewClose:
				Gui % A_Gui ":Destroy"
				return
				CStruct_Base_TreeViewSize:
				CStruct_Base.__Anchor(CStruct_Base_hTreeView[A_Gui], "wh")
				return
			}
		}

		if (Obj.__base="CStruct_Base")
		{
			if (tObj = "")
				tObj := {}
			tCls  := Obj.m_struct.tCls
			vList := tCls.varList
			mObj := Obj.m_struct
			tObj.Insert("*" Obj.__class, "size = " tCls.size " , address = " mObj.addr)
			for order, name in tCls.varOrder
			{
				vObj := vList[name]
				prop := vObj.s (vObj.c>1? " , count : " vObj.c : "")
				if (vObj.t="CStruct_Base")
				{
					for array, cObj in mObj.child[name]
					{
						scnt := strlen(tCls.size) - strlen(offset := vObj.o+vObj.s*(array-1))
						loop % scnt
							offset := "0" offset
						data := InStr(data:=cObj.ToString(), "`n")? "{ ... }" : "{ " data " }"
						tObj.Insert(fullName := "[" offset "] " name (vObj.c>1? "[" array "]":"") " = " data, Object())
						this.TreeView(cObj, "", "", -1, tObj[fullName])
					}
				}
				else
				{
					scnt := strlen(tCls.size) - strlen(offset := vObj.o)
					loop % scnt
						offset := "0" offset
					
					data := Obj[name]
					str =
					loop % vObj.c
					{
						if !data.error
							hex := this.__Dec2Base(NumGet(mObj.addr+vObj.o+vObj.s*(A_index-1)
							, 0, vObj.s=1? "UCHAR": vObj.s=2? "USHORT": vObj.s=4? "UINT": vObj.t), 16)
						str .= ", " (data.error? Obj.GetData(name, A_index) : hex)
					}
					StringReplace, str, str, % ", "
					if data.error
						data = { %str% }
					else if (vObj.c>1)
						prop .= " , hex={ " str " }"
					else if (vObj.c=1) and ObjHasKey(mObj.string, name)
					{
						ptr := Obj.GetData(name)
						prop .= " , Pointer : " ptr ((ptr=ObjGetAddress(mObj.string, name))? " , Pointed include buffer : " 
						. Obj.GetData(name, "buffersize") " byte" : "")
					}
					else if (vObj.c=1) and InStr(vObj.org, "STR")
						prop .= " , Pointer : " Obj.GetData(name)
					
					if vObj.bc
					{
						scnt := strlen(vObj.s*8) - strlen(bitOffset := vObj.bo)
						Loop % scnt
							bitOffset := "0" bitOffset
						offset .= "][" bitOffset
						prop .= " , " vObj.bc "bit : 0~" 2**vObj.bc-1
						scnt := vObj.bc - strlen(bin := this.__Dec2Base(data, 2))
						loop % scnt
							bin := "0" bin
						data .= "  [b]:" bin
					}
					
					tObj.Insert("[" offset "] " name (strlen(data)? " = " data:""), Object(vObj.org, prop))
				}
			}
			if (r = -1)
				return
			r := ""
			SetFormat, integer, % iFormat
			Obj := tObj
		}
		
		if (IsObject(Obj))
		{
			if (r = "")
				r := 1
			
			for k, v in Obj
			{
				if (IsObject(v))
					if (r = "template") and (k = "dummy")
						TV_Add(k " : [object]", hParent, Option)
					else
						this.TreeView(v, Option, TV_Add(k, hParent, Option), r)
				else
					TV_Add(k (strlen(v)? " : " v : ""), hParent, Option)
			}
		}
		if (nDefaultGui)
			Gui % nDefaultGui ":Default"
	}

	__Anchor(i, a = "", r = false) 
	{
		static c, cs = 12, cx = 255, cl = 0, g, gs = 8, gl = 0, gpi, gw, gh, z = 0, k = 0xffff
		If z = 0
			VarSetCapacity(g, gs * 99, 0), VarSetCapacity(c, cs * cx, 0), z := true
		If (!WinExist("ahk_id" . i)) {
			GuiControlGet, t, Hwnd, %i%
			If ErrorLevel = 0
				i := t
			Else ControlGet, i, Hwnd, , %i%
		}
		VarSetCapacity(gi, 68, 0), DllCall("GetWindowInfo", "UInt", gp := DllCall("GetParent", "UInt", i), "UInt", &gi)
			, giw := NumGet(gi, 28, "Int") - NumGet(gi, 20, "Int"), gih := NumGet(gi, 32, "Int") - NumGet(gi, 24, "Int")
		If (gp != gpi) {
			gpi := gp
			Loop, %gl%
				If (NumGet(g, cb := gs * (A_Index - 1), "Int") == gp) {
					gw := NumGet(g, cb + 4, "Short"), gh := NumGet(g, cb + 6, "Short"), gf := 1
					Break
				}
			If (!gf)
				NumPut(gp, g, gl, "Int"), NumPut(gw := giw, g, gl + 4, "Short"), NumPut(gh := gih, g, gl + 6, "Short"), gl += gs
		}
		ControlGetPos, dx, dy, dw, dh, , ahk_id %i%
		Loop, %cl%
			If (NumGet(c, cb := cs * (A_Index - 1), "Int") == i) {
				If a =
				{
				cf = 1
				Break
				}
				giw -= gw, gih -= gh, as := 1, dx := NumGet(c, cb + 4, "Short"), dy := NumGet(c, cb + 6, "Short")
				, cw := dw, dw := NumGet(c, cb + 8, "Short"), ch := dh, dh := NumGet(c, cb + 10, "Short")
				Loop, Parse, a, xywh
				If A_Index > 1
					av := SubStr(a, as, 1), as += 1 + StrLen(A_LoopField)
							, d%av% += (InStr("yh", av) ? gih : giw) * (A_LoopField + 0 ? A_LoopField : 1)
				DllCall("SetWindowPos", "UInt", i, "Int", 0, "Int", dx, "Int", dy
				, "Int", InStr(a, "w") ? dw : cw, "Int", InStr(a, "h") ? dh : ch, "Int", 4)
				If r != 0
				DllCall("RedrawWindow", "UInt", i, "UInt", 0, "UInt", 0, "UInt", 0x0101) ; RDW_UPDATENOW | RDW_INVALIDATE
				Return
			}
		If cf != 1
			cb := cl, cl += cs
		bx := NumGet(gi, 48, "Int"), by := NumGet(gi, 16, "Int") - NumGet(gi, 8, "Int") - gih - NumGet(gi, 52, "Int")
		If cf = 1
			dw -= giw - gw, dh -= gih - gh
		NumPut(i, c, cb, "Int"), NumPut(dx - bx, c, cb + 4, "Short"), NumPut(dy - by, c, cb + 6, "Short")
			, NumPut(dw, c, cb + 8, "Short"), NumPut(dh, c, cb + 10, "Short")
		Return, true
	}
	
	__Dec2Base(n, b)
	{
		return (n < b ? "" : this.__Dec2Base(n//b,b)) . ((d:=Mod(n,b)) < 10 ? d : Chr(d+55))
	}
}


;-------------------------------------------------------------------------------------
;               Window API Structure Class
;-------------------------------------------------------------------------------------

; http://msdn.microsoft.com/en-us/library/dd162805%28VS.85%29.aspx 
class CPoint extends CStruct_Base
{
	__New(Param*)
	{
		this.AddStructVar("x", "int")
		this.AddStructVar("y", "int")
		this.SetStructCapacity()
		
		if (Param.MaxIndex()=1) and (Param[1].__class=this.__class)
			this.CopyFrom(Param[1])
		else if (Param.MaxIndex()=2) {
			this.x := Param[1]
			this.y := Param[2]
		}
	}

	__Get(name)
	{
		if name=int64
			return NumGet(base.GetData("ptr"), "INT64")
	}
	__Set(name, v)
	{
		if name=int64
			return v  ,  NumPut(v+0, base.GetData("ptr"), "INT64")
	}
}

;-------------------------------------------------------------------------------------
; http://msdn.microsoft.com/en-us/library/dd145106%28VS.85%29.aspx 
class CSize extends CStruct_Base
{
	__New(Param*)
	{
		this.AddStructVar("width" , "int")
		this.AddStructVar("height", "int")
		this.SetStructCapacity()
		
		if (Param.MaxIndex()=1) and (Param[1].__class=this.__class)
			this.CopyFrom(Param[1])
		else if (Param.MaxIndex()=2) {
			this.width  := Param[1]
			this.height := Param[2]
		}
	}
}

;-------------------------------------------------------------------------------------
; http://msdn.microsoft.com/en-us/library/dd162897%28VS.85%29.aspx 
class CRect extends CStruct_Base
{
	; CRect(CRect)
	; CRect(CPoint, CPoint)
	; CRect(CPoint, CSize)
	; CRect(CPoint, right, bottom)
	; CRect(left, top, right, bottom)
	__New(Param*)
	{
		this.AddStructVar("left",   "int")
		this.AddStructVar("top",    "int")
		this.AddStructVar("right",  "int")
		this.AddStructVar("bottom", "int")
		this.SetStructCapacity()
		
		if (Param[1].__class=this.__class) {
			this.CopyFrom(Param[1])
		}
		else if (Param[1].__class="CPoint") and (Param[2].__class="CPoint") {
			this.left := Param[1].x,   this.top := Param[1].y, this.right := Param[2].x,   this.bottom := Param[2].y
		}
		else if (Param[1].__class="CPoint") and (Param[2].__class="CSize") {
			this.left := Param[1].x,   this.top := Param[1].y, this.right := Param[1].x + Param[2].width, this.bottom := Param[1].y + Param[2].height
		}
		else if (Param[1].__class="CPoint") and (Param[2].__class="") and (Param[3].__class="")
			this.left := Param[1].x,   this.top := Param[1].y, this.right := Param[2],   this.bottom := Param[3]
		else if (Param.MaxIndex()=4) {
			this.left := Param[1], this.top := Param[2], this.right := Param[3], this.bottom := Param[4]
		}
	}
	
	__Get(name)
	{
		if name=width
			return this.right - this.left
		if name=height
			return this.bottom - this.top
	}
	
	GetSizeOfRect()
	{
		size := this.__MakeClass("CSize")
		size.width  := this.width
		size.height := this.height
		return size
	}
	
	ToString()
	{
		return base.Tostring() "`, " "*width=" this.width "`, *height=" this.height
	}
}

;-------------------------------------------------------------------------------------
;http://msdn.microsoft.com/en-us/library/windows/desktop/ms632610(v=vs.85).aspx
class CWindowInfo extends CStruct_Base
{
	__New()
	{
		this.AddStructVar("cbSize", "DWORD")
		this.AddStructVar("rcWindow", "CRect")    ;<-- Use CRect class.(already defined class)
		this.AddStructVar("rcClient", "CRect")    ;<-- Use CRect class.
		this.AddStructVar("dwStyle", "DWORD")
		this.AddStructVar("dwExStyle", "DWORD")
		this.AddStructVar("dwWindowStatus", "DWORD")
		this.AddStructVar("cxWindowBorders", "UINT")
		this.AddStructVar("cyWindowBorders", "UINT")
		this.AddStructVar("atomWindowType", "ATOM")
		this.AddStructVar("wCreatorVersion", "WORD")
		this.SetStructCapacity()
	}
}

;-------------------------------------------------------------------------------------
;http://msdn.microsoft.com/en-us/library/windows/desktop/ms632611(v=vs.85).aspx
class CWindowPlacement extends CStruct_Base
{
	__New()
	{
		this.AddStructVar("length", "UINT")
		this.AddStructVar("flags", "UINT")
		this.AddStructVar("showCmd", "UINT")
		this.AddStructVar("ptMinPosition", "CPoint")  ;<-- Use CPoint class.(already defined class)
		this.AddStructVar("ptMaxPosition", "CPoint")
		this.AddStructVar("rcNormalPosition", "CRect")
		this.SetStructCapacity()
	}
}

;-------------------------------------------------------------------------------------
;http://msdn.microsoft.com/en-us/library/windows/desktop/ms724950(v=vs.85).aspx
class CSystemTime extends CStruct_Base
{
	__New()
	{
		this.AddStructVar("wYear", "WORD")
		this.AddStructVar("wMonth", "WORD")
		this.AddStructVar("wDayOfWeek", "WORD")
		this.AddStructVar("wDay", "WORD")
		this.AddStructVar("wHour", "WORD")
		this.AddStructVar("wMinute", "WORD")
		this.AddStructVar("wSecond", "WORD")
		this.AddStructVar("wMilliseconds", "WORD")
		this.SetStructCapacity()
	}
}

;-------------------------------------------------------------------------------------
;http://msdn.microsoft.com/en-us/library/windows/desktop/ms725481(v=vs.85).aspx
class CTimeZoneInformation extends CStruct_Base
{
	__New()
	{
		this.AddStructVar("Bias", "LONG")
		this.AddStructVar("StandardName", "WCHAR", 32)
		this.AddStructVar("StandardDate", "CSystemTime")
		this.AddStructVar("StandardBias", "LONG")
		this.AddStructVar("DaylightName", "WCHAR", 32)
		this.AddStructVar("DaylightDate", "CSystemTime")
		this.AddStructVar("DaylightBias", "LONG")
		this.SetStructCapacity()
	}
}

;-------------------------------------------------------------------------------------
;http://msdn.microsoft.com/en-us/library/dd145065(v=vs.85).aspx
class CMoniterInfo extends CStruct_Base
{
	__New()
	{
		this.AddStructVar("cbSize", "DWORD")
		this.AddStructVar("rcMonitor", "CRect")
		this.AddStructVar("rcWork", "CRect")
		this.AddStructVar("dwFlags", "DWORD")
		this.SetStructCapacity()
		
		this.cbSize := this.size
	}
}

;-------------------------------------------------------------------------------------
;http://msdn.microsoft.com/en-us/library/dd183569(v=vs.85).aspx
;DllCall("EnumDisplayDevices", "PTR",0 , UINT,0 , Ptr,DisplayDevice[""] , UINT,0)
class CDisplayDevice extends CStruct_Base
{
	__New()
	{
		this.AddStructVar("cb", "DWORD")
		this.AddStructVar("DeviceName", "TCHAR", 32)
		this.AddStructVar("DeviceString", "TCHAR", 128)
		this.AddStructVar("StateFlags", "DWORD")
		this.AddStructVar("DeviceID", "TCHAR", 128)
		this.AddStructVar("DeviceKey", "TCHAR", 128)
		this.SetStructCapacity()
		
		this.cb := this.size
	}
}

;-------------------------------------------------------------------------------------
;http://msdn.microsoft.com/en-us/library/windows/desktop/ms684824(v=vs.85).aspx
class CPerformanceInfo extends CStruct_Base
{
	__New()
	{
		this.AddStructVar("cb", "DWORD")
		this.AddStructVar("CommitTotal", "SIZE_T")
		this.AddStructVar("CommitLimit", "SIZE_T")
		this.AddStructVar("CommitPeak", "SIZE_T")
		this.AddStructVar("PhysicalTotal", "SIZE_T")
		this.AddStructVar("PhysicalAvailable", "SIZE_T")
		this.AddStructVar("SystemCache", "SIZE_T")
		this.AddStructVar("KernelTotal", "SIZE_T")
		this.AddStructVar("KernelPaged", "SIZE_T")
		this.AddStructVar("KernelNonpaged", "SIZE_T")
		this.AddStructVar("PageSize", "SIZE_T")
		this.AddStructVar("HandleCount", "DWORD")
		this.AddStructVar("ProcessCount", "DWORD")
		this.AddStructVar("ThreadCount", "DWORD")
		this.SetStructCapacity()
	}
}

;-------------------------------------------------------------------------------------
;http://msdn.microsoft.com/en-us/library/windows/desktop/ms684839(v=vs.85).aspx
class CProcessEntry32 extends CStruct_Base
{
	__New(param*)
	{
		this.AddStructVar("dwSize", "DWORD")
		this.AddStructVar("cntUsage", "DWORD")
		this.AddStructVar("th32ProcessID", "DWORD")
		this.AddStructVar("th32DefaultHeapID", "ULONG_PTR")
		this.AddStructVar("th32ModuleID", "DWORD")
		this.AddStructVar("cntThreads", "DWORD")
		this.AddStructVar("th32ParentProcessID", "DWORD")
		this.AddStructVar("pcPriClassBase", "LONG")
		this.AddStructVar("dwFlags", "DWORD")
		this.AddStructVar("szExeFile", "TCHAR", 260)    ;MAX_PATH = 260
		this.SetStructCapacity()
		
		this.dwSize := this.size
		if (this.__class=param[1].__class)
			this.CopyFrom(param[1])
	}
}

;-------------------------------------------------------------------------------------
;http://msdn.microsoft.com/en-us/library/windows/desktop/ms684225(v=vs.85).aspx
class CModuleEntry32 extends CStruct_Base
{
	__New(param*)
	{
		this.AddStructVar("dwSize", "DWORD")
		this.AddStructVar("th32ModuleID", "DWORD")
		this.AddStructVar("th32ProcessID", "DWORD")
		this.AddStructVar("GlblcntUsage", "DWORD")
		this.AddStructVar("ProccntUsage", "DWORD")
		this.AddStructVar("modBaseAddr", "UPtr")      ;BYTE* --> UPtr
		this.AddStructVar("modBaseSize", "DWORD")
		this.AddStructVar("hModule", "HMODULE")
		this.AddStructVar("szModule", "TCHAR", 256)   ;MAX_MODULE_NAME32 + 1 = 256
		this.AddStructVar("szExePath", "TCHAR", 260)  ;MAX_PATH = 260
		this.SetStructCapacity()
		
		this.dwSize := this.size
		if (this.__class=param[1].__class)
			this.CopyFrom(param[1])
	}
}

;-------------------------------------------------------------------------------------
;http://msdn.microsoft.com/en-us/library/windows/desktop/aa373931(v=vs.85).aspx
class CGuid extends CStruct_Base
{
	__New()
	{
		this.AddStructVar("Data1", "DWORD")
		this.AddStructVar("Data2", "WORD")
		this.AddStructVar("Data3", "WORD")
		this.AddStructVar("Data4", "BYTE", 8)
		this.SetStructCapacity()
	}
}

;-------------------------------------------------------------------------------------
;http://msdn.microsoft.com/en-us/library/windows/desktop/bb773352.aspx
;DllCall( "Shell32\Shell_NotifyIcon" (A_IsUnicode ? "W" : "A") , UInt,0x1, UInt,NID[""] )
class CNotifyIconData extends CStruct_Base
{
	__New()
	{
		this.AddStructVar("cbSize", "DWORD")
		this.AddStructVar("hWnd", "HWND")
		this.AddStructVar("uID", "UINT")
		this.AddStructVar("uFlags", "UINT")
		this.AddStructVar("uCallbackMessage", "UINT")
		this.AddStructVar("hIcon", "HICON")
		this.AddStructVar("szTip", "TCHAR", 64)
		this.AddStructVar("dwState", "DWORD")
		this.AddStructVar("dwStateMask", "DWORD")
		this.AddStructVar("szInfo", "TCHAR", 256)
		this.AddStructVar("uTimeout", "UINT", "union_start")
		this.AddStructVar("uVersion", "UINT", "union_end")
		this.AddStructVar("szInfoTitle", "TCHAR", 64)
		this.AddStructVar("dwInfoFlags", "DWORD")
		this.AddStructVar("guidItem", "CGuid")        ; use CGuid class
		this.AddStructVar("hBalloonIcon", "HICON")
		this.SetStructCapacity()
		
		this.cbSize := this.size
	}
}

;-------------------------------------------------------------------------------------
; http://msdn.microsoft.com/en-us/library/windows/desktop/dd757625(v=vs.85).aspx
; http://msdn.microsoft.com/en-us/library/windows/desktop/dd757627(v=vs.85).aspx 
class Ctimecaps extends CStruct_Base
{
	__New()
	{
		this.AddStructVar("wPeriodMin", "UINT")
		this.AddStructVar("wPeriodMax", "UINT")
		this.SetStructCapacity()
	}
}