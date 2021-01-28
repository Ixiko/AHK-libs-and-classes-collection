CriticalSection(cs:=0){
static 
static i:=0,crisec:={base:{__Delete:"criticalsection"}}
if IsObject(cs){
Loop i
DeleteCriticalSection(&c%i%)
Return i:=0
} else if cs
return DeleteCriticalSection(cs),cs
i++,VarSetCapacity(c%i%,24),InitializeCriticalSection(&c%i%)
Return &c%i%
}