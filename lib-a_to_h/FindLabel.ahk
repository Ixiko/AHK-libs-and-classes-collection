FindLabel(Name){
return DllCall(A_MemoryModule?MemoryGetProcAddress(A_MemoryModule,"ahkFindLabel"):GetProcAddress(A_ModuleHandle,"ahkFindLabel"),"Str",Name,"CDecl PTR")
}