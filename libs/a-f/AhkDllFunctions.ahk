AhkDllFunctions(MemoryModule){
  If !MemoryModule
    return "
    (
    #DllImport, ahkFunction,`%A_DllPath`%\ahkFunction,Str,,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,Cdecl Str
    #DllImport, ahkPostFunction,`%A_DllPath`%\ahkPostFunction,Str,,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,Cdecl Str
    #DllImport, ahkExec,`%A_DllPath`%\ahkExec,Str,,Cdecl
    #DllImport, addScript,`%A_DllPath`%\addScript,Str,,UInt,0,Cdecl PTR
    #DllImport, addFile,`%A_DllPath`%\addFile,Str,,UInt,0,Cdecl PTR
    #DllImport, ahkExecuteLine,`%A_DllPath`%\ahkExecuteLine,PTR,0,UInt,0,UInt,0,Cdecl PTR
    #DllImport, ahkFindLabel,`%A_DllPath`%\ahkFindLabel,Str,,Cdecl PTR
    #DllImport, ahkFindFunc,`%A_DllPath`%\ahkFindFunc,Str,,Cdecl PTR
    #DllImport, ahkassign,`%A_DllPath`%\ahkAssign,Str,,Str,,Cdecl
    #DllImport, ahkgetvar,`%A_DllPath`%\ahkgetvar,Str,,UInt,0,Cdecl STR
    #DllImport, ahkLabel,`%A_DllPath`%\ahkLabel,Str,,UInt,0,Cdecl PTR
    #DllImport, ahkPause,`%A_DllPath`%\ahkPause,Str,,Cdecl
    
    )"
  LoopParse,ahkFunction.ahkPostFunction.ahkExec.addScript.addFile.ahkExecuteLine.ahkFindLabel.ahkFindFunc.ahkassign.ahkgetvar.ahkLabel.ahkPause,.
    %A_LoopField%:=MemoryGetProcAddress(memoryModule,A_LoopField)
  return "
    (
    #DllImport, ahkFunction,%ahkFunction%,Str,,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,Cdecl Str
    #DllImport, ahkPostFunction,%ahkPostFunction%,Str,,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,Cdecl Str
    #DllImport, ahkExec,%ahkExec%,Str,,Cdecl
    #DllImport, addScript,%addScript%,Str,,UInt,0,Cdecl PTR
    #DllImport, addFile,%addFile%,Str,,UInt,0,Cdecl PTR
    #DllImport, ahkExecuteLine,%ahkExecuteLine%,PTR,0,UInt,0,UInt,0,Cdecl PTR
    #DllImport, ahkFindLabel,%ahkFindLabel%,Str,,Cdecl PTR
    #DllImport, ahkFindFunc,%ahkFindFunc%,Str,,Cdecl PTR
    #DllImport, ahkassign,%ahkAssign%,Str,,Str,,Cdecl
    #DllImport, ahkgetvar,%ahkgetvar%,Str,,UInt,0,Cdecl STR
    #DllImport, ahkLabel,%ahkLabel%,Str,,UInt,0,Cdecl PTR
    #DllImport, ahkPause,%ahkPause%,Str,,Cdecl
    
    )"
}