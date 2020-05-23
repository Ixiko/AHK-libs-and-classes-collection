; EnumComMembers by TLM
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=71194&hilit=COM+Object+Reference
; https://gist.github.com/TLMcode/af02957c667b0b227ef649670ad19159#file-enumcommembers-ahk

EnumComMembers(pti) {
   static InvKind := {1:"method", 2:"get", 4:"put", 8:"putref"}
   if ComObjType(pti)=9 { ; if Com Object, get iTypeInfo Interface
      ptr := ComObjValue(pti)
      { ; Check if *ptr* has ITypeInfo Interface
         GetTypeInfoCount := vtable(ptr, 3)
         DllCall(GetTypeInfoCount, "ptr",ptr, "ptr*",HasITypeInfo)
         if Not HasITypeInfo {
            MsgBox ITypeInfo Interface not supported
            return
         }
      }
      GetTypeInfo := vTable(ptr, 4)
      if DllCall(GetTypeInfo, "ptr",ptr, "uint",0, "uint",0, "ptr*",pti)!=0
         return
   }
   { ; Com Methods
      GetTypeAttr := vTable(pti, 3)
      ReleaseTypeAttr := vTable(pti, 19)
      GetRefTypeOfImplType := vTable(pti, 8)
      GetRefTypeInfo := vTable(pti, 14)
      GetFuncDesc := vTable(pti, 5)
      ReleaseFuncDesc := vTable(pti, 20)
      GetDocumentation := vTable(pti, 12)
   }
   { ; get cFuncs (number of functions)
      DllCall(GetTypeAttr, "ptr",pti, "ptr*",typeAttr)
      cFuncs := NumGet(typeAttr+0, 40+A_PtrSize, "short")
      cImplTypes := NumGet(typeAttr+0, 44+A_PtrSize, "short")
      DllCall(ReleaseTypeAttr, "ptr",pti, "ptr",typeAttr)
   }
   if cImplTypes { ; Get Inherited Class (cImplTypes should be true)
      DllCall(GetRefTypeOfImplType, "ptr",pti, "int",0, "int*",pRefType)
      DllCall(GetRefTypeInfo, "ptr",pti, "ptr",pRefType, "ptr*", pti2)
      DllCall(GetDocumentation, "ptr",pti2, "int",-1, "ptr*",Name, "ptr",0, "ptr",0, "ptr",0) ; get Interface Name
      if StrGet(Name) != "IDispatch"
         t .= EnumComMembers(pti2) "`n"
      else
         ObjRelease(pti2)
   }
   Loop, %cFuncs% { ; get Member IDs
      DllCall(GetFuncDesc, "ptr",pti, "int",A_Index-1, "ptr*",FuncDesc)
      ID := NumGet(FuncDesc+0, "short") ; get Member ID
      n := NumGet(FuncDesc+0, 4+3*A_PtrSize, "int") ; get InvKind
      ; Args := NumGet(FuncDesc+0, 12+3*A_PtrSize, "short") ; get Num of Args
      ; Opt := NumGet(FuncDesc+0, 14+3*A_PtrSize, "short") ; get Num of Opt Args
      DllCall(ReleaseFuncDesc, "ptr",pti, "ptr",FuncDesc)
      DllCall(GetDocumentation, "ptr",pti, "int",ID, "ptr*",Name, "ptr",0, "ptr",0, "ptr",0)
      if StrGet(Name, "UTF-16") ; Exclude Members that didn't return a Name
         t .= ID "`t" StrGet(Name, "UTF-16") "`t" InvKind[n] "`n"
   }
   { ; formatting & cleanup
      t := SubStr(t,1,-1)
      Sort, t, ND`n
      ObjRelease(pti)
   }
   return t
}
vTable(ptr, n) { ; see ComObjQuery documentation
    return NumGet(NumGet(ptr+0), n*A_PtrSize)
}
GetTypeInfo(ptr) {
    if ComObjType( ptr ) = 9
        ptr := ComObjValue( ptr )

	; Check if *ptr* has ITypeInfo Interface
    GetTypeInfoCount := vtable( ptr, 3 )
    DllCall( GetTypeInfoCount, "ptr",ptr, "ptr*",HasITypeInfo )
    if Not HasITypeInfo
    {
        MsgBox ITypeInfo Interface not supported
        Exit
    }

    GetTypeInfo := vTable( ptr, 4 )
    if DllCall( GetTypeInfo, "ptr",ptr, "uint",0, "uint",0, "ptr*", pti ) = 0
        Return, pti
}
