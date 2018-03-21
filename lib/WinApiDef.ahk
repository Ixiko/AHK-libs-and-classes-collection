WinApiDef(def){
	static buf,init:=UnZipRawMemory(LoadResource(handle:=GetModuleHandle(A_DllPath),res:=DllCall("FindResource","PTR",handle,"Str","C974C3B7677A402D93B047DA402587C7","PTR",10,"PTR")),SizeOfResource(handle,res),buf),list:=StrGet(&buf,"UTF-8")
	defpos:=InStr(list,"\" def)+1,	dllpos:=InStr(list,A_Tab,1,defpos)+1
	If SubStr(list,defpos+StrLen(def),1)=","
		return SubStr(list,dllpos,InStr(list,"\",1,dllpos)-dllpos+1) SubStr(list,defpos,InStr(list,"\",1,defpos+1)-defpos)
}