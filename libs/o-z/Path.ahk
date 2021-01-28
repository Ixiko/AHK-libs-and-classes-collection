/*
path splitting could be delayed until used, but is it worth it?
 - if this is used for all paths in FileContainer, a single delayed initialization would be better.  It should be as close to a string as possible until the very last moment

 _dir and _drive are a bit much...?

#levels
split into levels
make path comparison methods built into this library
*/
Path(p1,p2="",p3="",p4="",p5="",p6="",p7="",p8="",p9="")
{ ;dout_f(A_ThisFunc)
	static base
	if !base
		base := Object("__Call", "Path_caller", "__Get", "Path_getter")
	
	while ( (part := p%A_Index%) != "" and A_Index<=9)
		path .= IsObject(part) ? part.path : part
	
	SplitPath, path, name, dir, ext, nameNoExt, drive
	if ( isFolder := !name )
	{
		StringGetPos, pos, path, \, R2
		name := nameNoExt := SubStr(path,pos+2)
		dir  := SubStr(path,1,pos)
	}
	
	return Object("base",base,"path",path,"name",name,"dir",dir . "\","ext",ext,"nameNoExt",nameNoExt,"drive",drive . "\","isFolder",isFolder,"isFile",!isFolder)
}
; only 8 params here
Path_caller(self,func,p1="__deFault__",p2="__deFault__",p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
{ ;dout_f(A_ThisFunc)	
	if ! self.fileContainer
		self.fileContainer := FileContainer("list",self.path)
	
	if ( return_fc := (SubStr(func,1,1)=="_") )
		StringTrimLeft, func, func, 1
	fc := Call("FileContainer_" func, self.fileContainer,p1,p2,p3,p4,p5,p6,p7,p8)
	
	return ( return_fc ? fc : self)
}
Path_getter(self, key)
{
	if (key="_dir")
		self._dir := Path(self.dir)
	else if (key="_drive")
		self._drive := Path(self.drive)
}