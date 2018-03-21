AhkSelf(){
   static functions :="
(Join
ahkFunction:s==stttttttttt|ahkPostFunction:i==stttttttttt|
ahkdll:ut==sss|ahktextdll:ut==sss|ahkReady:|ahkReload:i|
ahkTerminate:i=i|addFile:ut==sucuc|addScript:ut==si|ahkExec:ui==s|
ahkassign:ui==ss|ahkExecuteLine:ut=utuiui|ahkFindFunc:ut==s|
ahkFindLabel:ut==s|ahkgetvar:s==sui|ahkLabel:ui==sui|ahkPause:i=s|ahkIsUnicode:
)"
  object:={}
  Loop,Parse,functions,|
  {
    v:=StrSplit(A_LoopField,":")
    If !FuncPTR:=A_MemoryModule?MemoryGetProcAddress(A_MemoryModule,v.1):DllCall("GetProcAddress","PTR",A_ModuleHandle,"AStr",v.1,"PTR")
      continue
    If v.1="ahkFunction"||v.1="ahkPostFunction"
      dynacall_:=DynaCall(FuncPTR,v.2,"",0,0,0,0,0,0,0,0,0,0)
    else
      dynacall_:=DynaCall(FuncPtr,v.2)
    object[v.1]:=dynacall_
  }
  return object
}