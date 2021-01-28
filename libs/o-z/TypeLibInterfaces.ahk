/*

  Version: MPL 2.0/GPL 3.0/LGPL 3.0

  The contents of this file are subject to the Mozilla Public License Version
  2.0 (the "License"); you may not use this file except in compliance with
  the License. You may obtain a copy of the License at

  http://www.mozilla.org/MPL/

  Software distributed under the License is distributed on an "AS IS" basis,
  WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
  for the specific language governing rights and limitations under the License.

  The Initial Developer of the Original Code is
  Elgin <Elgin_1@zoho.eu>.
  Portions created by the Initial Developer are Copyright (C) 2010-2017
  the Initial Developer. All Rights Reserved.

  Contributor(s):

  Alternatively, the contents of this file may be used under the terms of
  either the GNU General Public License Version 3 or later (the "GPL"), or
  the GNU Lesser General Public License Version 3.0 or later (the "LGPL"),
  in which case the provisions of the GPL or the LGPL are applicable instead
  of those above. If you wish to allow use of your version of this file only
  under the terms of either the GPL or the LGPL, and not to allow others to
  use your version of this file under the terms of the MPL, indicate your
  decision by deleting the provisions above and replace them with the notice
  and other provisions required by the GPL or the LGPL. If you do not delete
  the provisions above, a recipient may use your version of this file under
  the terms of any one of the MPL, the GPL or the LGPL.

*/

; ==============================================================================
; ==============================================================================
; Contents
; ==============================================================================
; ==============================================================================
/*
Provides: definitions for interfaces, structures and constants to retrieve
data from type libraries

*/

class ITypeLib extends BaseComClass
{
	static __IID := "{00020402-0000-0000-C000-000000000046}"
	
	GetTypeInfoCount()
	{
		return DllCall(this.vt(3), "Ptr", this.Ptr, "UInt")
	}

	GetTypeInfo(Index)
	{
		out:=0
		return DllCall(this.vt(4), "Ptr", this.Ptr, "UInt", Index, "Ptr*", out, "Int")=0 ? new ITypeInfo(out) : 0	
	}

	GetTypeInfoType(Index)
	{
		out:=0
		return DllCall(this.vt(5), "Ptr", this.Ptr, "UInt", Index, "UInt*", out, "Int")=0 ? out : 0
	}
	
	GetLibAttr()
	{
		VarSetCapacity(out, TLIBATTR.SizeOf(),0)
		return DllCall(this.vt(7), "Ptr", this.Ptr, "Ptr*", out)=0 ? new TLIBATTR(out) : 0
	}
	
	GetDocumentation(Index)
	{
		Name:=0
		DocString:=0
		HelpContext:=0
		HelpFile:=0
		If (DllCall(this.vt(9), "Ptr", this.Ptr, "Int", Index, "ptr*", Name, "ptr*", DocString, "ptr*", HelpContext, "ptr*", HelpFile)=0)
		{
			TempInfo:=Object()
			TempInfo.Name:=StrGet(Name, "UTF-16")
			TempInfo.DocString:=StrGet(DocString, "UTF-16")
			TempInfo.HelpContext:=HelpContext
			TempInfo.HelpFile:=StrGet(HelpFile, "UTF-16")
		}
		return TempInfo
	}	
	
	ReleaseTLibAttr(Ptr)
	{
		DllCall(this.vt(12), "Ptr", this.Ptr, "Ptr", Ptr)
	}
	
}

class ITypeInfo extends BaseComClass
{
	static __IID := "{00020401-0000-0000-C000-000000000046}"
	
	GetTypeAttr()
	{
		VarSetCapacity(out, TYPEATTR.SizeOf(),0)
		return DllCall(this.vt(3), "Ptr", this.Ptr, "Ptr*", out, "Int")=0 ? new TYPEATTR(out) : 0	
	}
	
	GetFuncDesc(Index)
	{
		VarSetCapacity(out, FUNCDESC.SizeOf(),0)
		return DllCall(this.vt(5), "Ptr", this.Ptr, "Int", Index, "Ptr*", out, "Int")=0 ? new FUNCDESC(out) : 0
	}
	
	GetVarDesc(Index)
	{
		VarSetCapacity(out, VARDESC.SizeOf(),0)
		return, DllCall(this.vt(6), "Ptr", this.Ptr, "Int", Index, "Ptr*", out, "Int")=0 ? new VARDESC(out) : 0
	}
	
	GetNames(ID, MaxNum=1)
	{
		pcNames:=0
		VarSetCapacity(out, MaxNum * A_PtrSize, 0)
		HR:=DllCall(this.vt(7), "Ptr", this.Ptr, "Int", ID, "Ptr", &out, "UInt", MaxNum, "UInt*", pcNames, "Int")
		If (pcNames)
		{
			TempInfo:=Object()
			Loop, %pcNames%
			{
				TempInfo.Push(StrGet(NumGet(&out+A_PtrSize*(A_Index-1), "Ptr"), "UTF-16"))
			}
			return TempInfo
		}
		return HR
	}
	
	GetRefTypeOfImplType(Index)
	{
		out:=0
		If (DllCall(this.vt(8), "Ptr", this.Ptr, "UInt", Index, "UInt*", out, "Int")=0)
		{
			return this.GetRefTypeInfo(out+0)
		}
	}
	
	GetImplTypeFlags(Index)
	{
		out:=0
		If (DllCall(this.vt(9), "Ptr", this.Ptr, "UInt", Index, "UInt*", out, "Int")=0)
		{
			return out
		}
	}

	GetDocumentation(ID)
	{
		Name:=0
		DocString:=0
		HelpContext:=0
		HelpFile:=0
		If (DllCall(this.vt(12), "Ptr", this.Ptr, "Int", ID, "ptr*", Name, "ptr*", DocString, "ptr*", HelpContext, "ptr*", HelpFile)=0)
		{
			TempInfo:=Object()
			TempInfo.Name:=StrGet(Name, "UTF-16")
			TempInfo.DocString:=StrGet(DocString, "UTF-16")
			TempInfo.HelpContext:=HelpContext
			TempInfo.HelpFile:=StrGet(HelpFile, "UTF-16")
		}
		return TempInfo
	}
	
	GetRefTypeInfo(hRefType)
	{
		out:=0
		return DllCall(this.vt(14), "Ptr", this.Ptr, "Int", hRefType, "ptr*", out)=0 ? new ITypeInfo(out) : 0
	}

	GetMops(ID)
	{
		out:=0
		return DllCall(this.vt(17), "Ptr", this.Ptr, "Int", ID, "ptr*", out)=0 ? StrGet(out, "UTF-16") : 0
	}

	GetContainingTypeLib(byref pindex)
	{
		out:=0
		pindex:=0
		return DllCall(this.vt(18), "Ptr", this.Ptr, "Ptr*", out, "UInt*", pindex)=0 ? new ITypeLib(out) : 0
	}

	ReleaseTypeAttr(Ptr)
	{
		DllCall(this.vt(19), "Ptr", this.Ptr, "Ptr", Ptr)
	}
	
	ReleaseFuncDesc(Ptr)
	{
		DllCall(this.vt(20), "Ptr", this.Ptr, "Ptr", Ptr)
	}
	
	ReleaseVarDesc(Ptr)
	{
		DllCall(this.vt(21), "Ptr", this.Ptr, "Ptr", Ptr)
	}
	

;~ 4  (get-type-comp :pointer)
;~ 10  (get-ids-of-names :pointer)
;~ 11  (invoke :pointer)
;~ 13  (get-dll-entry :pointer)
;~ 15  (address-of-member :pointer)
;~ 16  (create-instance :pointer) 
}

; checked 32/64 bit
class ELEMDESC extends BaseStruct
{
	GetFromStruct(p)
	{
		this.tdesc := new TYPEDESC(p+0)
		this.idldesc := new IDLDESC(p+TYPEDESC.SizeOf())
		this.paramdesc := new PARAMDESC(p+TYPEDESC.SizeOf())
		return, 1
	}	
	
	SizeOf()
	{
		return TYPEDESC.SizeOf()+PARAMDESC.SizeOf()
	}
}


; checked 32/64 bit
class FUNCDESC extends BaseStruct
{
	GetFromStruct(p)
	{
		this.memid:=NumGet(p+0, "UInt")
		If (A_PtrSize=4)
		{
			this.lprgscode:=NumGet(NumGet(p+A_PtrSize, "UInt"))
			this.lprgelemdescParam:=NumGet(p+2*A_PtrSize, "Ptr")
			this.funckind:=NumGet(p+3*A_PtrSize, "UInt")
			this.invkind:=NumGet(p+4+3*A_PtrSize, "Short")
			this.callconv:=NumGet(p+8+3*A_PtrSize, "UInt")
			this.cParams:=NumGet(p+12+3*A_PtrSize, "Short")
			this.cParamsOpt:=NumGet(p+14+3*A_PtrSize, "UShort")
			this.oVft:=NumGet(p+16+3*A_PtrSize, "Short")
			this.cScodes:=NumGet(p+18+3*A_PtrSize, "Short")
			this.elemdescFunc:=new ELEMDESC(p+20+3*A_PtrSize)
			this.wFuncFlags:=NumGet(p+22+3*A_PtrSize+ELEMDESC.SizeOf(), "Short")
		}
		else
		{
			this.lprgscode:=NumGet(NumGet(p+8, "UInt"))
			this.lprgelemdescParam:=NumGet(p+16, "Ptr")
			this.funckind:=NumGet(p+24, "UInt")
			this.invkind:=NumGet(p+28, "Short")
			this.callconv:=NumGet(p+32, "UInt")
			this.cParams:=NumGet(p+36, "Short")
			this.cParamsOpt:=NumGet(p+38, "UShort")
			this.oVft:=NumGet(p+40, "Short")
			this.cScodes:=NumGet(p+42, "Short")
			this.elemdescFunc:=new ELEMDESC(p+48)
			this.wFuncFlags:=NumGet(p+80, "Short")
		}
		return, 1
	}
	
	SizeOf()
	{
		If (A_PtrSize=4)
		{
			return 28+2*A_PtrSize+ELEMDESC.SizeOf()
		}
		else
			return 88
	}
	
}

; checked 32/64 bit
class IDLDESC extends BaseStruct
{
	GetFromStruct(p)
	{
		this.dwReserved:= NumGet(p+0,"Ptr")
		this.wIDLFlags:= NumGet(p+A_PtrSize, "UShort")
		return, 1
	}	
	
	SizeOf()
	{
		return 2*A_PtrSize
	}
}

; checked 32/64 bit
class PARAMDESC extends BaseStruct
{
	GetFromStruct(p)
	{
		this.wParamFlags:=Numget(p+A_PtrSize,"UShort")
		if (this.wParamFlags & 0x20) ; hasdefault
		{
			this.pparamdescex:=new PARAMDESCEX(NumGet(p+0, "Ptr"))
		}
		else
			this.pparamdescex:=NumGet(p+0, "Ptr")
		return, 1
	}	
	
	SizeOf()
	{
		return 2*A_PtrSize
	}
}

; checked 32/64 bit
class PARAMDESCEX extends BaseStruct
{
	GetFromStruct(p)
	{
		this.cBytes:=NumGet(p+0, "UInt")
		If (this.cBytes=16 or this.cBytes=24)
		{
			this.varDefaultValue:=GetVariantData(p+8)
			return, 1
		}
		else
			return, 0
	}	
	
	SizeOf()
	{
		return 8+8+2*A_PtrSize
	}
}

; checked 32/64 bit
class TLIBATTR extends BaseStruct
{
	GetFromStruct(p)
	{
		this.guid:= GUID2Str(p)
		this.lcid:= NumGet(p+16, "UInt")
		this.syskind:= NumGet(p+20, "UInt")
		this.wMajorVerNum:= NumGet(p+24, "UShort")
		this.wMinorVerNum:= NumGet(p+26, "UShort")
		this.wLibFlags:= NumGet(p+28, "UShort")
		return, 1
	}
	
	SizeOf()
	{
		return 30+2
	}
}

; checked 32/64 bit
class TYPEATTR extends BaseStruct
{
	GetFromStruct(p)
	{
		this.guid:= GUID2Str(p)
		this.lcid:= NumGet(p+16, "UInt")
		this.dwReserved:= NumGet(p+20, "UInt")
		this.memidConstructor:= NumGet(p+24, "Int")
		this.memidDestructor:= NumGet(p+28, "Int")
		this.lpstrSchema:= StrGet(NumGet(p+32, "UPtr"), "UTF-16")
		this.cbSizeInstance:= NumGet(p+32+A_PtrSize, "UInt")
		this.typekind:= NumGet(p+36+A_PtrSize, "UInt")
		this.cFuncs:= NumGet(p+40+A_PtrSize, "UShort")
		this.cVars:= NumGet(p+42+A_PtrSize, "UShort")
		this.cImplTypes:= NumGet(p+44+A_PtrSize, "UShort")
		this.cbSizeVft:= NumGet(p+46+A_PtrSize, "UShort")
		this.cbAlignment:= NumGet(p+48+A_PtrSize, "UShort")
		this.wTypeFlags:= NumGet(p+50+A_PtrSize, "UShort")
		this.wMajorVerNum:= NumGet(p+52+A_PtrSize, "UShort")
		this.wMinorVerNum:= NumGet(p+54+A_PtrSize, "UShort")
		this.tdescAlias:= new TYPEDESC(p+56+A_PtrSize)
		this.idldescType:= new IDLDESC(p+56+A_PtrSize+TYPEDESC.SizeOf())
		return, 1
	}
	
	SizeOf()
	{
		return 56+A_PtrSize+TYPEDESC.SizeOf()+IDLDESC.SizeOf()
	}
}

; checked 32/64 bit
class TYPEDESC extends BaseStruct
{
	GetFromStruct(p)
	{
		this.vt:=NumGet(p+A_PtrSize, "UShort")
		If (this.vt=26 or this.vt=27) ; VtPtr VtSafearray
		{
			this.lptdesc:=new TYPEDESC(NumGet(p+0, "Ptr"))
		}
		else
		If (this.vt=28) ; or this.vt=0x2000) ;  VtCarray VtArray
		{
			this.lpadesc:=new ARRAYDESC(NumGet(p+0, "Ptr"))
		}
		else
		If (this.vt=29) ; VtPtr
		{
			this.hreftype:=NumGet(p+0, "Ptr")
		}
		return, 1
	}	
	
	SizeOf()
	{
		return 2*A_PtrSize
	}
}

; checked 32/64 bit
class ARRAYDESC extends BaseStruct
{
	GetFromStruct(p)
	{
		this.tdescElem:=new TYPEDESC(p+0)
		this.cDims:=NumGet(p+TYPEDESC.SizeOf(), "UShort")
		this.rgbounds:=Object()
		Loop, % this.cDims
		{
			this.rgbounds[A_Index-1]:=new SAFEARRAYBOUND(p+TYPEDESC.SizeOf()+4+(A_Index)*SAFEARRAYBOUND.SizeOf())
		}
		return, 1
	}	
	
	SizeOf()
	{
		return TYPEDESC.SizeOf()+A_PtrSize+SAFEARRAYBOUND.SizeOf()
	}
}

; checked 32/64 bit
class SAFEARRAYBOUND extends BaseStruct
{
	GetFromStruct(p)
	{
		this.cElements:=NumGet(p+0, "UInt")
		this.lLbound:=NumGet(p+4, "Int")
		return, 1
	}	
	
	SizeOf()
	{
		return 8
	}
}

class VARDESC extends BaseStruct
{
	GetFromStruct(p)
	{
		this.memid:=NumGet(p+0, "UInt")
		this.lpstrSchema:=NumGet(p+A_PtrSize, "Ptr")
		this.elemdescVar:=new ELEMDESC(p+3*A_PtrSize)
		this.wVarFlags:=NumGet(p+3*A_PtrSize+ELEMDESC.SizeOf(), "Short")
		this.varkind:=NumGet(p+4+3*A_PtrSize+ELEMDESC.SizeOf(), "Short")
		If (this.varkind=2)
		{
			this.oInst:=GetVariantData(NumGet(p+2*A_PtrSize, "Ptr"))
		}
		else
			this.lpvarvalue:=NumGet(p+2*A_PtrSize, "Int")
		return, 1
	}
	
	SizeOf()
	{
		return 4*A_PtrSize+ELEMDESC.SizeOf() 
	}
	
}


CALLCONV(kind)
{
	static Enum:={"CC_FASTCALL":0,"CC_CDECL":1,"CC_MSCPASCAL":2,"CC_PASCAL":2,"CC_MACPASCAL":3,"CC_STDCALL":4,"CC_FPFASTCALL":5,"CC_SYSCALL":6,"CC_MPWCDECL":7,"CC_MPWPASCAL":8,"CC_MAX":9,0:"CC_FASTCALL",1:"CC_CDECL",2:"CC_PASCAL",3:"CC_MACPASCAL",4:"CC_STDCALL",5:"CC_FPFASTCALL",6:"CC_SYSCALL",7:"CC_MPWCDECL",8:"CC_MPWPASCAL",9:"CC_MAX"}
	return Enum[kind]
}

FUNCFLAGS(flags)
{
	static Enum:={"FUNCFLAG_FRESTRICTED":0x1,"FUNCFLAG_FSOURCE":0x2,"FUNCFLAG_FBINDABLE":0x4,"FUNCFLAG_FREQUESTEDIT":0x8,"FUNCFLAG_FDISPLAYBIND":0x10,"FUNCFLAG_FDEFAULTBIND":0x20,"FUNCFLAG_FHIDDEN":0x40,"FUNCFLAG_FUSESGETLASTERROR":0x80,"FUNCFLAG_FDEFAULTCOLLELEM":0x100,"FUNCFLAG_FUIDEFAULT":0x200,"FUNCFLAG_FNONBROWSABLE":0x400,"FUNCFLAG_FREPLACEABLE":0x800,"FUNCFLAG_FIMMEDIATEBIND":0x1000}
	If (IsObject(flags))
	{
		Out:=0
		for index, flag in flags
			Out|=Enum[flag]
	}
	else
	{
		Out:=Object()
		For str, flag in Enum
		{
			If (flags & flag)
			Out.Push(str)
		}		
	}
	return Out
}

FUNCKIND(kind)
{
	static Enum:={"FUNC_VIRTUAL":0,"FUNC_PUREVIRTUAL":1,"FUNC_NONVIRTUAL":2,"FUNC_STATIC":3,"FUNC_DISPATCH":4,0:"FUNC_VIRTUAL",1:"FUNC_PUREVIRTUAL",2:"FUNC_NONVIRTUAL",3:"FUNC_STATIC",4:"FUNC_DISPATCH"}
	return Enum[kind]
}

IMPLTYPEFLAGS(flags)
{
	static Enum:={"IMPLTYPEFLAG_FDEFAULT":0x1,"IMPLTYPEFLAG_FSOURCE":0x2,"IMPLTYPEFLAG_FRESTRICTED":0x4,"IMPLTYPEFLAG_FDEFAULTVTABLE":0x8}
	If (IsObject(flags))
	{
		Out:=0
		for index, flag in flags
			Out|=Enum[flag]
	}
	else
	{
		Out:=Object()
		For str, flag in Enum
		{
			If (flags & flag)
			Out.Push(str)
		}		
	}
	return Out
}

INVOKEKIND(kind)
{
	static Enum:={"INVOKE_FUNC":1,"INVOKE_PROPERTYGET":2,"INVOKE_PROPERTYPUT":4,"INVOKE_PROPERTYPUTREF":8,1:"INVOKE_FUNC",2:"INVOKE_PROPERTYGET",4:"INVOKE_PROPERTYPUT",8:"INVOKE_PROPERTYPUTREF"}
	return Enum[kind]
}

LIBFLAGS(flags)
{
	static Enum:={"LIBFLAG_FRESTRICTED":0x1,"LIBFLAG_FCONTROL":0x2,"LIBFLAG_FHIDDEN":0x4,"LIBFLAG_FHASDISKIMAGE":0x8}
	If (IsObject(flags))
	{
		Out:=0
		for index, flag in flags
			Out|=Enum[flag]
	}
	else
	{
		Out:=Object()
		For str, flag in Enum
		{
			If (flags & flag)
			Out.Push(str)
		}		
	}
	return Out
}

PARAMFLAG(flags)
{
	static Enum:={"PARAMFLAG_NONE":0x0,"PARAMFLAG_FIN":0x1,"PARAMFLAG_FOUT":0x2,"PARAMFLAG_FLCID":0x4,"PARAMFLAG_FRETVAL":0x8,"PARAMFLAG_FOPT":0x10,"PARAMFLAG_FHASDEFAULT":0x20,"PARAMFLAG_FHASCUSTDATA":0x40}
	If (IsObject(flags))
	{
		Out:=0
		for index, flag in flags
			Out|=Enum[flag]
	}
	else
	{
		Out:=Object()
		For str, flag in Enum
		{
			If (flags & flag)
			Out.Push(str)
		}	
		If (flags=0)
			Out.Push("PARAMFLAG_NONE")
	}
	return Out
}

SYSKIND(kind)
{
	static Enum:={"SYS_WIN16":0,"SYS_WIN32":1,"SYS_MAC":2,"SYS_WIN64":3,0:"SYS_WIN16",1:"SYS_WIN32",2:"SYS_MAC",3:"SYS_WIN64"}
	return Enum[kind]
}

TYPEFLAGS(flags)
{
	static Enum:={"TYPEFLAG_FAPPOBJECT":0x1,"TYPEFLAG_FCANCREATE":0x2,"TYPEFLAG_FLICENSED":0x4,"TYPEFLAG_FPREDECLID":0x8,"TYPEFLAG_FHIDDEN":0x10,"TYPEFLAG_FCONTROL":0x20,"TYPEFLAG_FDUAL":0x40,"TYPEFLAG_FNONEXTENSIBLE":0x80,"TYPEFLAG_FOLEAUTOMATION":0x100,"TYPEFLAG_FRESTRICTED":0x200,"TYPEFLAG_FAGGREGATABLE":0x400,"TYPEFLAG_FREPLACEABLE":0x800,"TYPEFLAG_FDISPATCHABLE":0x1000,"TYPEFLAG_FREVERSEBIND":0x2000,"TYPEFLAG_FPROXY":0x4000}
	If (IsObject(flags))
	{
		Out:=0
		for index, flag in flags
			Out|=Enum[flag]
	}
	else
	{
		Out:=Object()
		For str, flag in Enum
		{
			If (flags & flag)
			Out.Push(str)
		}		
	}
	return Out
}

TYPEKIND(kind)
{
	static Enum:={"TKIND_ENUM":0,"TKIND_RECORD":1,"TKIND_MODULE":2,"TKIND_INTERFACE":3,"TKIND_DISPATCH":4,"TKIND_COCLASS":5,"TKIND_ALIAS":6,"TKIND_UNION":7,"TKIND_MAX":8,0:"TKIND_ENUM",1:"TKIND_RECORD",2:"TKIND_MODULE",3:"TKIND_INTERFACE",4:"TKIND_DISPATCH",5:"TKIND_COCLASS",6:"TKIND_ALIAS",7:"TKIND_UNION",8:"TKIND_MAX"}
	return Enum[kind]
}

VARKIND(kind)
{
	static Enum:={"VAR_PERINSTANCE":0,"VAR_STATIC":1,"VAR_CONST":2,"VAR_DISPATCH":3,0:"VAR_PERINSTANCE",1:"VAR_STATIC",2:"VAR_CONST",3:"VAR_DISPATCH"}
	return Enum[kind]
}

VARENUM(kind)
{
	static Enum:={"Vt_Empty":0,"Vt_Null":1,"Vt_I2":2,"Vt_I4":3,"Vt_R4":4,"Vt_R8":5,"Vt_Cy":6,"Vt_Date":7,"Vt_Bstr":8,"Vt_Dispatch":9,"Vt_Error":10,"Vt_Bool":11,"Vt_Variant":12,"Vt_Unknown":13,"Vt_Decimal":14,"Vt_I1":16,"Vt_Ui1":17,"Vt_Ui2":18,"Vt_Ui4":19,"Vt_I8":20,"Vt_Ui8":21,"Vt_Int":22,"Vt_Uint":23,"Vt_Void":24,"Vt_Hresult":25,"Vt_Ptr":26,"Vt_Safearray":27,"Vt_Carray":28,"Vt_Userdefined":29,"Vt_Lpstr":30,"Vt_Lpwstr":31,"Vt_Record":36,"Vt_IntPtr":37,"Vt_UintPtr":38,"Vt_Filetime":64,"Vt_Blob":65,"Vt_Stream":66,"Vt_Storage":67,"Vt_StreamedObject":68,"Vt_StoredObject":69,"Vt_BlobObject":70,"Vt_Cf":71,"Vt_Clsid":72,"Vt_VersionedStream":73,"Vt_BstrBlob":0xfff,"Vt_Vector":0x1000,"Vt_Array":0x2000,"Vt_Byref":0x4000,"Vt_Reserved":0x8000,"Vt_Illegal":0xffff,"Vt_Illegalmasked":0xfff,"Vt_Typemask":0xfff,0:"Vt_Empty",1:"Vt_Null",2:"Vt_I2",3:"Vt_I4",4:"Vt_R4",5:"Vt_R8",6:"Vt_Cy",7:"Vt_Date",8:"Vt_Bstr",9:"Vt_Dispatch",10:"Vt_Error",11:"Vt_Bool",12:"Vt_Variant",13:"Vt_Unknown",14:"Vt_Decimal",16:"Vt_I1",17:"Vt_Ui1",18:"Vt_Ui2",19:"Vt_Ui4",20:"Vt_I8",21:"Vt_Ui8",22:"Vt_Int",23:"Vt_Uint",24:"Vt_Void",25:"Vt_Hresult",26:"Vt_Ptr",27:"Vt_Safearray",28:"Vt_Carray",29:"Vt_Userdefined",30:"Vt_Lpstr",31:"Vt_Lpwstr",36:"Vt_Record",37:"Vt_IntPtr",38:"Vt_UintPtr",64:"Vt_Filetime",65:"Vt_Blob",66:"Vt_Stream",67:"Vt_Storage",68:"Vt_StreamedObject",69:"Vt_StoredObject",70:"Vt_BlobObject",71:"Vt_Cf",72:"Vt_Clsid",73:"Vt_VersionedStream",0xfff:"Vt_BstrBlob",0x1000:"Vt_Vector",0x2000:"Vt_Array",0x4000:"Vt_Byref",0x8000:"Vt_Reserved",0xffff:"Vt_Illegal"}
	return Enum[kind]

}

VT2AHK(kind)
{
	static Enum:={0:"Ptr",1:"Ptr",2:"Short",3:"Int",4:"Float",5:"Double",6:"Int64",7:"Int64",8:"Ptr",9:"Ptr",10:"Int",11:"Short",12:"Ptr",13:"Ptr",14:"Int64",16:"Char",17:"UChar",18:"UShort",19:"UInt",20:"Int64",21:"UInt64",22:"Int",23:"Uint",24:"Ptr",25:"Int",26:"Ptr",27:"Ptr",28:"Ptr",29:"Ptr",30:"Ptr",31:"Ptr",36:"Ptr",37:"Int*",38:"UInt*",64:"Ptr",65:"Ptr",66:"Ptr",67:"Ptr",68:"Ptr",69:"Ptr",70:"Ptr",71:"Ptr",72:"Ptr",73:"Ptr",0xfff:"Ptr",0x1000:"Ptr",0x2000:"Ptr",0x4000:"Ptr",0x8000:"Ptr",0xffff:"Ptr"}
	return Enum[kind]
}

VTSize(kind, bitness=0)
{
	static Enum4:={0:A_PtrSize,1:A_PtrSize,2:2,3:4,4:4,5:8,6:8,7:8,8:A_PtrSize,9:A_PtrSize,10:4,11:2,12:16,13:A_PtrSize,14:8,16:1,17:1,18:2,19:4,20:8,21:8,22:4,23:4,24:A_PtrSize,25:4,26:A_PtrSize,27:A_PtrSize,28:A_PtrSize,29:A_PtrSize,30:A_PtrSize,31:A_PtrSize,36:A_PtrSize,37:A_PtrSize,38:A_PtrSize,64:A_PtrSize,65:A_PtrSize,66:A_PtrSize,67:A_PtrSize,68:A_PtrSize,69:A_PtrSize,70:A_PtrSize,71:A_PtrSize,72:A_PtrSize,73:A_PtrSize,0xfff:A_PtrSize,0x1000:A_PtrSize,0x2000:A_PtrSize,0x4000:A_PtrSize,0x8000:A_PtrSize,0xffff:A_PtrSize}
	static Enum8:={0:A_PtrSize,1:A_PtrSize,2:2,3:4,4:4,5:8,6:8,7:8,8:A_PtrSize,9:A_PtrSize,10:4,11:2,12:24,13:A_PtrSize,14:8,16:1,17:1,18:2,19:4,20:8,21:8,22:4,23:4,24:A_PtrSize,25:4,26:A_PtrSize,27:A_PtrSize,28:A_PtrSize,29:A_PtrSize,30:A_PtrSize,31:A_PtrSize,36:A_PtrSize,37:A_PtrSize,38:A_PtrSize,64:A_PtrSize,65:A_PtrSize,66:A_PtrSize,67:A_PtrSize,68:A_PtrSize,69:A_PtrSize,70:A_PtrSize,71:A_PtrSize,72:A_PtrSize,73:A_PtrSize,0xfff:A_PtrSize,0x1000:A_PtrSize,0x2000:A_PtrSize,0x4000:A_PtrSize,0x8000:A_PtrSize,0xffff:A_PtrSize}
	If (bitness=0)
		bitness:=A_PtrSize
	return Enum%bitness%[kind]
}

