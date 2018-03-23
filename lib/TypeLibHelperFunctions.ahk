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
Provides: higher level functions to retrieve data from type libraries

*/

; sorded headings for file construction
TypeLibToHeadingsObj(TypeLib)
{
	If (TypeLib.__Class<>"ITypeLib")
	{
		throw "Not a valid type library."
		return 0
	}
	Out:=Object()
	Out._TypeLibraryInfo:=TypeLib.GetDocumentation(-1)
	Attr:=TypeLib.GetLibAttr()
	ObjMerge(Attr,Out._TypeLibraryInfo)
	Out._TypeLibraryInfo.LibFlagsNames:=LIBFLAGS(Attr.wLibFlags)
	Out._TypeLibraryInfo.syskindStr:=SYSKIND(Attr.syskind)
	Loop, % TypeLib.GetTypeInfoCount()
	{
		Progress, % (A_Index-1)/TypeLib.GetTypeInfoCount()*100, % A_Index-1 " of " TypeLib.GetTypeInfoCount(), Reading type library elements, Reading type library
		TK:=SubStr(TYPEKIND(TypeLib.GetTypeInfoType(A_Index-1)),7)
		EnsureObj(Out,TK)
		Out[TK].Push({"Name":TypeLib.GetDocumentation(A_Index-1).Name,"Index":A_Index-1})
	}
	TypeLib.ReleaseTLibAttr(Attr.__Ptr)
	Progress, Off
	return Out
}


; full view use for debugging purposes only
TypeLibToVerboseObj(TypeLib, Index=0)
{
	If (TypeLib.__Class<>"ITypeLib")
	{
		throw "Not a valid type library."
		return 0
	}
	Out:=TypeLib.GetDocumentation(-1)
	Attr:=TypeLib.GetLibAttr()
	ObjMerge(Attr,Out)
	Out.LibFlagsNames:=LIBFLAGS(Attr.wLibFlags)
	Out.syskindStr:=SYSKIND(Attr.syskind)
	If (Index)
	{
		Out[Index]:=TypeInfoToVerboseObj(TypeLib.GetTypeInfo(Index),TypeLib)
	}
	else
	{
		Loop, % TypeLib.GetTypeInfoCount()
		{
			fileappend, % "Info " A_Index-1 "`n", test.txt
		Progress, % (A_Index-1)/TypeLib.GetTypeInfoCount()*100, % A_Index-1 " of " TypeLib.GetTypeInfoCount(), Reading type library elements, Reading type library
			Out[A_Index-1]:=TypeInfoToVerboseObj(TypeLib.GetTypeInfo(A_Index-1),TypeLib)
		}
		Progress, Off
	}
	TypeLib.ReleaseTLibAttr(Attr.__Ptr)
	return Out
}

TypeInfoToVerboseObj(TypeInfo, Typelib)
{
	If (TypeLib.__Class<>"ITypeLib" or TypeInfo.__Class<>"ITypeInfo")
	{
		throw "Not a valid type library or type info type."
		return 0
	}
	Out:=TypeInfo.GetDocumentation(-1)
	Attr:=TypeInfo.GetTypeAttr()
	ObjMerge(Attr,Out)
	Out.typekindStr:=TYPEKIND(Attr.typekind)
	Out.wTypeFlagsSts:=TYPEFLAGS(Attr.wTypeFlags)
	Out.Variables:=Object()
	Loop, % Attr.cVars
	{
		fileappend, % "var " A_Index-1 "`n", test.txt
		Out.Variables[A_Index-1]:=Object()
		VarDescVar:=TypeInfo.GetVarDesc(A_Index-1)
		Out.Variables[A_Index-1]:=TypeInfo.GetDocumentation(VarDescVar.memid)
		ObjMerge(VarDescVar,Out.Variables[A_Index-1])
		TypeInfo.ReleaseVarDesc(VarDesc.__Ptr)
	}
	Out.Functions:=Object()
	Loop, % Attr.cFuncs
	{
		fileappend, % "func " A_Index-1 "`n", test.txt
		FuncIndex:=A_Index-1
		Out.Functions[FuncIndex]:=Object()
		FuncDescVar:=TypeInfo.GetFuncDesc(FuncIndex)
		Out.Functions[FuncIndex]:=TypeInfo.GetDocumentation(FuncDescVar.memid)
		ObjMerge(FuncDescVar,Out.Functions[FuncIndex])
		Out.Functions[FuncIndex].ReturnTypeStr:=VARENUM(FuncDescVar.elemdescFunc.tdesc.vt)
		Out.Functions[FuncIndex].Parameters:=Object()
		ParamNames:=TypeInfo.GetNames(FuncDescVar.memid,FuncDescVar.cParams+1)
		fileappend, % "Func" Funcindex " " Out.Functions[FuncIndex].Name "`n", test.txt
		Loop, % FuncDescVar.cParams
		{
			Out.Functions[FuncIndex].Parameters[A_Index-1]:=Object()
			Out.Functions[FuncIndex].Parameters[A_Index-1].ParamName:=ParamNames[A_Index+1]					
		fileappend, % "Param " A_Index-1 "/" FuncDescVar.cParams ";" ParamNames[A_Index+1] "`n", test.txt
			param:=new ELEMDESC(FuncDescVar.lprgelemdescParam+(A_Index-1)*ELEMDESC.SizeOf())
			ObjMerge(param,Out.Functions[FuncIndex].Parameters[A_Index-1])
			Out.Functions[FuncIndex].Parameters[A_Index-1].TypeStr:=GetVarStr(param, TypeInfo)					
		}
		TypeInfo.ReleaseFuncDesc(FuncDescVar.__Ptr)
	}
	Out.ImplementedTypes:=Object()
	Loop, % Attr.cImplTypes
	{
		Out.ImplementedTypes[A_Index-1]:=Object()
		Out.ImplementedTypes[A_Index-1].Name:=TypeInfo.GetRefTypeOfImplType(A_Index-1).GetDocumentation(-1).Name ; 
		; removed: do not recurse into implemented types for performance reasons
		;~ Out.ImplementedTypes[A_Index-1]:=TypeInfoToVerboseObj(TypeInfo.GetRefTypeOfImplType(A_Index-1), Typelib)
		Out.ImplementedTypes[A_Index-1].Flags:=IMPLTYPEFLAGS(TypeInfo.GetImplTypeFlags(A_Index-1))
	}
	TypeInfo.ReleaseTypeAttr(Attr.__Ptr)
	return Out
}

; standard TL view
TypeLibToCondensedObj(TypeLib, Index=0)
{
	If (TypeLib.__Class<>"ITypeLib")
	{
		throw "Not a valid type library."
		return 0
	}
	Out:=Object()
	Out._TypeLibraryInfo:=TypeLib.GetDocumentation(-1)
	Attr:=TypeLib.GetLibAttr()
	ObjMerge(Attr,Out._TypeLibraryInfo)
	Out._TypeLibraryInfo.LibFlagsNames:=LIBFLAGS(Attr.wLibFlags)
	Out._TypeLibraryInfo.syskindStr:=SYSKIND(Attr.syskind)
	If (Index)
	{
		Out[Index]:=TypeInfoToCondensedObj(TypeLib.GetTypeInfo(Index),TypeLib)
	}
	else
	{
		Loop, % TypeLib.GetTypeInfoCount()
		{
			Progress, % (A_Index-1)/TypeLib.GetTypeInfoCount()*100, % A_Index-1 " of " TypeLib.GetTypeInfoCount(), Reading type library elements, Reading type library
			TK:=TYPEKIND(TypeLib.GetTypeInfoType(A_Index-1))
			EnsureObj(Out,TK)
			Out[TK][TypeLib.GetDocumentation(A_Index-1).Name]:=TypeInfoToCondensedObj(TypeLib.GetTypeInfo(A_Index-1),TypeLib)
		}
		Progress, Off
	}
	TypeLib.ReleaseTLibAttr(Attr.__Ptr)
	return Out
}

TypeInfoToCondensedObj(TypeInfo, Typelib)
{
	If (TypeLib.__Class<>"ITypeLib" or TypeInfo.__Class<>"ITypeInfo")
	{
		throw "Not a valid type library or type info type."
		return 0
	}
	Out:=Object()
	Attr:=TypeInfo.GetTypeAttr()
	Out.GUID:=Attr.guid
	If (Attr.cVars)
	{
		Out.Variables:=Object()
		Loop, % Attr.cVars
		{
			Out.Variables[A_Index-1]:=Object()
			VarDescVar:=TypeInfo.GetVarDesc(A_Index-1)
			Doc:=TypeInfo.GetDocumentation(VarDescVar.memid)
			If (VarDescVar.varkind=0) ; Perinstance
			{
				Out.Variables[A_Index-1]:=Doc.Name "; Offset: " VarDescVar.lpvarvalue ", Type: " GetVarStr(VarDescVar.elemdescVar, TypeInfo)
				If (Doc.DocString<>"")
				  Out.Variables[A_Index-1]:=.="		`; " Doc.DocString
			}
			else
			If (VarDescVar.varkind=2) ; Const
			{
				
				Out.Variables[A_Index-1]:=Doc.Name " := "  VarDescVar.oInst
				If (Doc.DocString<>"")
					 Out.Variables[A_Index-1].="			`; " Doc.DocString 
				Out.Variables[A_Index-1].="; Type: " GetVarStr(VarDescVar.elemdescVar, TypeInfo)
			}
			TypeInfo.ReleaseVarDesc(VarDescVar.__Ptr)
		}
	}
	If (Attr.cFuncs)
	{
		Out.Functions:=Object()
		Loop, % Attr.cFuncs
		{
			FuncIndex:=A_Index-1
			FuncDescVar:=TypeInfo.GetFuncDesc(FuncIndex)
			Doc:=TypeInfo.GetDocumentation(FuncDescVar.memid)
			Name:=Doc.Name
			If Name not in QueryInterface,AddRef,Release,GetTypeInfoCount,GetTypeInfo,GetIDsOfNames,Invoke
			{
				tout:=INVOKEKIND(FuncDescVar.invkind) " " Name
				Out.Functions[FuncDescVar.oVft//A_PtrSize]:=tout
			}
			TypeInfo.ReleaseFuncDesc(FuncDescVar.__Ptr)
		}
	}
	If (Attr.cImplTypes)
	{
		Out.ImplementedTypes:=Object()
		If (Attr.typekind=5)	; TKIND_COCLASS
		{
			Loop, % Attr.cImplTypes
			{
				Name:=TypeInfo.GetRefTypeOfImplType(A_Index-1).GetDocumentation(-1).Name
				Out.ImplementedTypes.Insert(Name)
			}
		}
		else
		{
			Loop, % Attr.cImplTypes
			{
				Out.ImplementedTypes[TypeInfo.GetRefTypeOfImplType(A_Index-1).GetDocumentation(-1).Name]:=Object()
			}
		}
	}
	If (Attr.typekind=6)	; TKIND_ALIAS
	{
		Out.tdescAlias:=GetVarStrFromTD(Attr.tdescAlias, TypeInfo)
	}
	TypeInfo.ReleaseTypeAttr(Attr.__Ptr)
	return Out
}

GetRequiresInitialization(elemDescVar, TypeInfo)
{
	If (!IsObject(elemDescVar) or !IsObject(elemDescVar.tdesc))
		return
	return GetRequiresInitializationFromTD(elemDescVar.tdesc, TypeInfo)
}

GetRequiresInitializationFromTD(typeDescVar, TypeInfo)
{
	vstr:=""
	If (VARENUM(typeDescVar.vt))
	{
		If (typeDescVar.vt=26)
		{
			vstr:=GetRequiresInitializationFromTD(typeDescVar.lptdesc, TypeInfo)
		}
		else
		If (typeDescVar.vt=29)
		{
			ref:=TypeInfo.GetRefTypeInfo(typeDescVar.hreftype)
			refAttr:=ref.GetTypeAttr()
			If (refAttr.typekind=1 or refAttr.typekind=1)
				vstr:=ref.GetDocumentation(-1).Name
			ref.ReleaseTypeAttr(refAttr.__Ptr)
		}
	}
	return vstr
}

GetVarStr(elemDescVar, TypeInfo)
{
	If (!IsObject(elemDescVar) or !IsObject(elemDescVar.tdesc))
		return
	return GetVarStrFromTD(elemDescVar.tdesc, TypeInfo)
}

GetVarStrFromTD(typeDescVar, TypeInfo)
{
	If (VARENUM(typeDescVar.vt))
	{
		If (typeDescVar.vt=26)
		{
			vstr:=GetVarStrFromTD(typeDescVar.lptdesc, TypeInfo)
			If (vstr<>"")
				vstr.="*"
			else
				vstr:=VARENUM(typeDescVar.vt)
			return  vstr
		}
		else
		If (typeDescVar.vt=29)
		{
			ref:=TypeInfo.GetRefTypeInfo(typeDescVar.hreftype)
			return ref.GetDocumentation(-1).Name ; MEMBERID_NIL
		}
		else
		{
			return VARENUM(typeDescVar.vt)
		}
	}
	else
		return "VarType: " Format("{:#X}", typeDescVar.vt)
}

GetTypeObj(elemDescVar, TypeInfo)
{
	If (!IsObject(elemDescVar) or !IsObject(elemDescVar.tdesc))
		return
	TypeObj:=Object()
	GetTypeObjFromTD(elemDescVar.tdesc, TypeInfo, TypeObj)
	return TypeObj
}

GetTypeObjFromTD(typeDescVar, TypeInfo, TypeObj)
{
	to:=Object()
	to.Type:=typeDescVar.vt
	TypeObj.Push(to)
	If (typeDescVar.vt=26)
	{
		GetTypeObjFromTD(typeDescVar.lptdesc, TypeInfo, TypeObj)
	}
	else
	If (typeDescVar.vt=29)
	{
		ref:=TypeInfo.GetRefTypeInfo(typeDescVar.hreftype)
		Attr:=ref.GetTypeAttr()
		If (Attr.typekind=3 or Attr.typekind=4 or Attr.typekind=5)
			to.IsInterface:=1
		else
			to.IsInterface:=0
		If (Attr.typekind=0) ; TKIND_ENUM
			to.RefType:=19
		else
			to.RefType:=13
		to.Name:=ref.GetDocumentation(-1).Name
		ref.ReleaseTypeAttr(Attr.__Ptr)
	}
}

GetAHKDllCallTypeFromVarObj(TypeObj)
{
	If (TypeObj[1].Type=26 and TypeObj[2].Type<>0 and TypeObj[2].Type<>24 and TypeObj[2].Type<>29)
		return VT2AHK(TypeObj[2].Type) . "*"
	else
	If (TypeObj[1].Type=26 and TypeObj[2].Type=29)
	{
		If (TypeObj[2].RefType="")
			return "Ptr"
		else
			return VT2AHK(TypeObj[2].RefType)
	}
	else
	If (TypeObj[1].Type=29)
	{
		If (TypeObj[1].RefType="")
			return "Ptr"
		else
			return VT2AHK(TypeObj[1].RefType)
	}
	else
		return VT2AHK(TypeObj[1].Type)
}

GetTypeObjPostProcessing(TypeObj)
{
	tout:=Object()
	For index, type in TypeObj
	{
		If (type.Type=8)
			tout.Push("out:= StrGet(out)")
		else
		If (type.Type=12)
			tout.Push("out:=ComObject(0x400C, out+0, flag)[]")
		else
		If (type.Type=29 and type.IsInterface=1)
			tout.Push("out:= new " type.Name "(out)")
	}
	return tout
}