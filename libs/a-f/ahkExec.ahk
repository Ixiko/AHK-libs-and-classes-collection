ahkExec(Script){
static ahkExec
if !ahkExec
ahkExec:=DynaCall(A_IsDll&&A_MemoryModule?MemoryGetProcAddress(A_MemoryModule,"ahkExec"):DllCall("GetProcAddress","PTR",A_ModuleHandle,"AStr","ahkExec","PTR"),"i==s")
Errorlevel := ahkExec[Script]
}