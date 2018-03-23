errormessage(E:=0){ 
static es,i
if !i
i:=VarSetCapacity(ES,1024)
FormatMessage(0x00001000,0,e?e:A_LastError,0,ES,1024),VarSetCapacity(ES,-1)
return StrReplace(ES,"`r`n"," ")
}