ToChar(ByRef num,buf:=0){
	return NumGet(getvar(buf:=num+0),"Char")
}