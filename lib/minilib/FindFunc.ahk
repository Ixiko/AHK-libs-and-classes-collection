FindFunc(Name){
return DllCall(A_MemoryModule?MemoryGetProcAddress(A_MemoryModule,"ahkFindFunc"):GetProcAddress(A_ModuleHandle,"ahkFindFunc"),"Str",Name,"CDecl PTR")
}