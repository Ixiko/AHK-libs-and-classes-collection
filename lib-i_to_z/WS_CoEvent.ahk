/*
CoEvent.ahk
*/

; Prefix is limited to 23 bytes.
ConnectObject(ByRef CoClass, pdisp, Prefix = "", DIID = "{00020400-0000-0000-C000-000000000046}")
{                                                       ; ^ IDispatch
	IID_IDispatch := "{00020400-0000-0000-C000-000000000046}"
   If !(pcp:=FindConnectionPoint(pdisp, DIID)) || ((DIID:=GetConnectionInterface(pcp))=IID_IDispatch)
   {
       DIID := GetDefaultConnection(pdisp)
	   pcp += pcp ? 0 : FindConnectionPoint(pdisp, DIID)
   }
	   
   If !ptinf:=GetTypeInfoOfGuid(pdisp, DIID)
   {
      MsgBox, No Event Interface Exists! Now exit the application.
      ExitApp
   }
   
   VarSetCapacity(CoClass,63,0)
   NumPut(CreateIDispatch(),CoClass)
   
   NumPut(1,CoClass,4)      ; AddRef()
   NumPut(ptinf,CoClass,8)  ; Release()
   NumPut(pdisp,CoClass,12) ; GetTypeInfoCount()
   NumPut(pcp,CoClass,16)   ; GetTypeInfo()
   
   DllCall("RtlMoveMemory", "Uint", &CoClass+24, "Uint", GUID4String(DIID,DIID), "Uint", 16)
   DllCall("lstrcpy", "Uint", &CoClass+40, "Uint", &Prefix)
   NumPut(Advise(pcp,&CoClass),CoClass,20)
   Return   &CoClass
}

GetDefaultConnection(pdisp)
{
	IID_IProvideClassInfo := "{B196B283-BAB4-101A-B69C-00AA00341D07}"
   If  pcinf := IUnknown_QueryInterface(pdisp, IID_IProvideClassInfo) || !pcinf
   		Return
   VarSetCapacity(DIID,16,0) ; sizeof(GUID) = 16
   If ! IProvideClassInfo2_GetGUID(pcinf, "Uint", pcinf, "Uint" , 1, "str", DIID) && !A_LastError
   		Return   String4GUID(DIID)
   VarSetCapacity(DIID,0)
   IProvideClassInfo_GetClassInfo(pcinf, ptinf)
   IUnknown_Release(pcinf)
   ITypeInfo_GetTypeAttr(ptinf, pattr)
   nCount := NumGet(pattr+48,0,"Ushort") ; pattr.?
   ITypeInfo_ReleaseTypeAttr(ptinf, pattr)
   pattr := 0
   Loop, %nCount%
   {
      ITypeInfo_GetImplTypeFlags(ptinf, A_Index-1, nFlags)
      If  !(nFlags & 1) || !(nFlags & 2)   ; ; 1: Default, 2: Source
      	Continue
      GetRefTypeOfImplType(ptinf, A_Index-1, hRefType)
      ITypeInfo_GetRefTypeInfo(ptinf, hRefType , prinf)
      ITypeInfo_GetTypeAttr(prinf, pattr)
      DIID   := String4GUID(pattr)
      ITypeInfo_ReleaseTypeAttr(prinf, pattr)
      IUnknown_Release(prinf)
      Break
   }
   IUnknown_Release(ptinf)
   Return   DIID
}

FindConnectionPoint(ppv, DIID)
{
	static IID_IConnectionPointContainer := "{B196B284-BAB4-101A-B69C-00AA00341D07}"
	pcc := IUnknown_QueryInterface(ppv, IID_IConnectionPointContainer)
	pcp := IConnectionPointContainer_FindConnectionPoint(pcc, DIID)
	IUnknown_Release(pcc)
	Return   pcp
}

Advise(pcp, psink)
{
	IConnectionPoint_Advise(pcp, psink, nCookie)
   Return   nCookie ; used for Unadvise
}

Unadvise(pcp, nCookie)
{
	IConnectionPoint_Unadvise(pcp, nCookie)
}

/*
TYPE ITypeLibVtbl
  QueryInterface    AS DWORD
  AddRef            AS DWORD
  Release           AS DWORD
  '
  ' TypeLib methods
  '
  GetTypeInfoCount  AS DWORD
  GetTypeInfo       AS DWORD
  GetTypeInfoType   AS DWORD
  GetTypeInfoOfGuid AS DWORD
  GetLibAttr        AS DWORD
  GetTypeComp       AS DWORD
  GetDocumentation  AS DWORD
  IsName            AS DWORD
  FindName          AS DWORD
  ReleaseTLibAttr   AS DWORD
END TYPE
*/
GetTypeInfoOfGuid(pdisp, GUID, LCID = 0)
{
	ptinf := IDispatch_GetTypeInfo(pdisp, 0, LCID)
	ITypeInfo_GetContainingTypeLib(ptinf, ptlib, idx)
	IUnknown_Release(ptinf), ptinf := 0
	ITypeLib_GetTypeInfoOfGuid(ptlib, GUID4String(GUID,GUID), ptinf)
	IUnknown_Release(ptlib)
	Return   ptinf
}

CreateIDispatch()
{
   Static   IDispatch
   If !VarSetCapacity(IDispatch)
   {
      VarSetCapacity(IDispatch,28,0) ; sizeof(IDispatch vtable) = 28
	  nParams=3112469
      Loop,   Parse,   nParams
         NumPut(RegisterCallback("DispInterface","",A_LoopField,A_Index-1),IDispatch,4*(A_Index-1))
   }
   Return &IDispatch
}

DispInterface(pthis, prm1=0, prm2=0, prm3=0, prm4=0, prm5=0, prm6=0, prm7=0, prm8=0)
{
   Critical
   hResult:=0
   If   A_EventInfo = 6
   {
      VarSetCapacity(Prefix,23), DllCall("lstrcpy","str",Prefix,"Uint",pthis+40)
      DllCall(NumGet(NumGet(1*(ptinf:=NumGet(pthis+8)))+28),"Uint",ptinf,"Uint",prm1,"UintP",pName,"Uint",1,"UintP",cNames), Unicode2Ansi(pName, sName), SysFreeString(pName)
      If  pfn:=RegisterCallback(Prefix . sName)
      DllCall(pfn, "Uint", pthis, "Uint", prm5, "Uint", prm6), DllCall("GlobalFree", "Uint", pfn)
   }
   Else If   A_EventInfo = 5
      hResult:=DllCall(NumGet(NumGet(1*(ptinf:=NumGet(pthis+8)))+40),"Uint",ptinf,"Uint",prm2,"Uint",prm3,"Uint",prm5)
   Else If   A_EventInfo = 4
      NumPut(NumGet(pthis+8),prm3+0)
   Else If   A_EventInfo = 3
      NumPut(1,prm1+0)
   Else If   A_EventInfo = 2
      NumPut(hResult:=NumGet(pthis+4)-1,pthis+4), hResult ? "" : Unadvise(pcp:=NumGet(pthis+16), NumGet(pthis+20)) . Release(pcp)
   Else If   A_EventInfo = 1
      NumPut(hResult:=NumGet(pthis+4)+1,pthis+4)
   Else If   A_EventInfo = 0
      InStr("{00000000-0000-0000-C000-000000000046}" . "{00020400-0000-0000-C000-000000000046}" . String4GUID(ptr:=pthis+24),String4GUID(prm1)) ? NumPut(pthis,prm2+0) . NumPut(NumGet(pthis+4)+1,pthis+4) : (hResult:=0x80004002)
   Return   hResult
}