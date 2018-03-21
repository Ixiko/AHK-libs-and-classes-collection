StrPutVar(string,ByRef var,encoding){
VarSetCapacity(var,StrPut(string,encoding)
*((encoding="utf-16"||encoding="cp1200")?2:1),00)
return StrPut(string,&var,encoding),VarSetCapacity(var,-1)
}