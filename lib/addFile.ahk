addFile(Script,waitExecute:=0){
static addFile
if !addFile
addFile:=DynaCall(A_IsDll&&A_MemoryModule?MemoryGetProcAddress(A_MemoryModule,"addFile"):DllCall("GetProcAddress","PTR",A_ModuleHandle,"AStr","addFile","PTR"),"i==si")
return addFile[Script,waitExecute]
}