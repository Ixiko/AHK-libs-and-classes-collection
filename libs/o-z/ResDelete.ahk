ResDelete(dll,name,type:=10,language:=1033){
	return !(hUpdate:=BeginUpdateResourceW(dll))?0:(result:=EndUpdateResource(hUpdate,!result:=UpdateResource(hUpdate,type,name,language)),result)
}