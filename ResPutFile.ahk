ResPutFile(File,dll,name,type:=10,language:=0){
If hUpdate:=BeginUpdateResourceW(dll){
FileGetSize,nSize,%File%
If nSize {
FileRead,bin,*c %File%
result:=UpdateResource(hUpdate,name,type,language,&Bin,nSize)
}
result:=EndUpdateResource(hUpdate,!result)
} else return 0
return result
}