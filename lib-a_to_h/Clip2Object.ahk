Class Clip2Object {
  __Set(key,ByRef raw){
    static _AHKVar := "{Int64 ContentsInt64,Double ContentsDouble,PTR object},{char *mByteContents,LPTSTR CharContents},{UINT_PTR Length,_AHKVar *AliasFor},{UINT_PTR Capacity,UINT_PTR BIV},BYTE HowAllocated,BYTE Attrib,BYTE IsLocal,BYTE Type,LPTSTR Name"
    len:=this.SetCapacity(key,(var:=Struct(_AHKVar,getvar(raw))).AliasFor.Length)
    return len,DllCall("RtlMoveMemory","PTR",this.GetAddress(key),"PTR",var.AliasFor.mByteContents["",""],"PTR",var.AliasFor.Length)
  }

  Restore(key,ByRef raw){
    static _AHKVar := "{Int64 ContentsInt64,Double ContentsDouble,PTR object},{char *mByteContents,LPTSTR CharContents},{UINT_PTR Length,_AHKVar *AliasFor},{UINT_PTR Capacity,UINT_PTR BIV},BYTE HowAllocated,BYTE Attrib,BYTE IsLocal,BYTE Type,LPTSTR Name"
    if IsByRef(raw) && VarSetCapacity(raw,len:=this.GetCapacity(key),0)
      return Struct(_AhkVar,Struct(_AhkVar,getvar(raw)).AliasFor["",""],{Attrib:1,Length:len}).Length
            ,DllCall("RtlMoveMemory","PTR",&raw,"PTR",this.GetAddress(key),"PTR",len)
  }
}