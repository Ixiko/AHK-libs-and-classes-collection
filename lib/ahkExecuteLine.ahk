ahkExecuteline(pLine:=0,Mode:=0,Wait:=1){
static ahkExecuteLine
if !ahkExecuteLine
ahkExecuteLine:=DynaCall(A_IsDll&&A_MemoryModule?MemoryGetProcAddress(A_MemoryModule,"ahkExecuteLine"):DllCall("GetProcAddress","PTR",A_ModuleHandle,"AStr","ahkExecuteLine","PTR"),"t==tuiui")
return ahkExecuteLine[pLine,Mode,Wait]
}