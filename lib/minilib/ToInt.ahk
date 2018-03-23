ToInt(ByRef num,buf:=0){
	return num:=NumGet(getvar(buf:=num+0),"Int")
}