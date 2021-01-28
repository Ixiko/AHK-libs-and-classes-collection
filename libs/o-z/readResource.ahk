readResource(ByRef Var, Name, Type="#10") { 
  VarSetCapacity( Var, 128 ), VarSetCapacity( Var, 0 )
  If ! ( A_IsCompiled ) {
    FileGetSize, nSize, %Name%
    FileRead, Var, *c %Name%
    Return nSize
  }
  If hMod := DllCall( "GetModuleHandle", UInt,0 )
    If hRes := DllCall( "FindResource", UInt,hMod, Str, Name, Str, Type) ;RCDATA = #10
      If hData := DllCall( "LoadResource", UInt,hMod, UInt,hRes )
        If pData := DllCall( "LockResource", UInt,hData )
  Return VarSetCapacity( Var, nSize := DllCall( "SizeofResource", UInt,hMod, UInt,hRes ) )
      ,  DllCall( "RtlMoveMemory", Str,Var, UInt,pData, UInt,nSize )
Return 0    
}