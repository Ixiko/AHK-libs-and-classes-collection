/*
	A system for handling a collection of preferences/settings with multiple prioritized override levels across extended objects.

	For online documentation
	See http://www.autohotkey.net/~Rapte_Of_Suzaku/Documentation/files/Prefs-ahk.html

	Release #1
	
	Joshua A. Kinnison
	2010-09-26, 16:08
*/
Prefs_init(b,default_func)
{
	static base
	if !base
		base := Object(	"__Set",	"Prefs_setter"
					,	"__Get",	"Prefs_getter"
					,	"__Call",	"Prefs_caller"
					,	"Remove",	"Prefs_remove"
					,	"override",	"Prefs_override")
	
	if !IsObject(b)
		return "need an object..."
	
	;b._prefs := dout_object(Object("base",base),1)
	b._prefs := Object("_",Object(),"base",base)
	
	bc := b
	b._prefs._[0] := 1
	
	while (bc := bc.base)
	{
		; skip until older preference object is found
		if !(old_prefs := bc._prefs)
			continue
		
		; copy the previous preference object
		;dout_o(old_prefs,"old preference object for absorbption")
		enum := ObjNewEnum(old_prefs._)
		while enum[key,value]
			b._prefs._[key] := value
		
		; # of default functions is all the old ones + 1 new
		b._prefs._[0] := old_prefs._[0]+1
		
		break
	}
	
	; insert in the new default function
	b._prefs._.Insert(1,default_func)
	;ObjInsert(b._prefs,1,default_func)
	;dout_object(
}
Prefs_setter(prefs,name,value)
{
	;dout_f(A_ThisFunc)
	prefs._[name] := value ? value : "__noThing__"
	;dout("set to " prefs._[name])
	return value
}
Prefs_getter(prefs,name)
{
	;dout_f(A_ThisFunc)
	if (name != "_" and name!="base")
		return prefs._[name]
}
Prefs_caller(prefs, func, n1, ByRef r1="__deFault__",n2="",ByRef r2="__deFault__",n3="",ByRef r3="__deFault__",n4="",ByRef r4="__deFault__",n5="",ByRef r5="__deFault__",n6="",ByRef r6="__deFault__")
{	
	;dout_f(A_ThisFunc)
	; only handle calls for obj._prefs()
	if IsObject(func)
	{
		
		While (name := n%A_Index%)
		{	
			var = r%A_Index%
			
			Loop 1 
			{
				; first priority goes to method-level overrides
				if (%var%!="__deFault__")
				{
					;dout(name " - using method-level override '" %var% "'")
					break
				}
				
				; second priority goes to object-level overrides
				if ( (%var% := prefs[name]) != "")		
				{
					;dout(name " - using object-level override '" %var% "'")
					break
				}
				
				; final priority goes to default values 
				Loop % prefs[0]							
				{
					default := prefs[A_Index]
					;dout("using default function " default)
					if ( (%var% := %default%(name)) != "" )
					{
						;dout(name " - using default value '" %var% "' from " default)
						break 2
					}
					;dout("couldn't find anything")
					;Msgbox couldn't find anything...
				}
				
				MsgBox ERROR - preference %name% not found
				;dout_fm(A_ThisFunc)
			}
			
			; post processing
			if (%var% == "__noThing__")
				%var%:=""
		}
		return r1 ; for simple 1 preference get syntax
	}
}
Prefs_remove(prefs,name)
{
	return prefs._.Remove(name)
}
Prefs_override(prefs,n1,v1="",n2="",v2="",n3="",v3="",n4="",v4="",n5="",v5="",n6="",v6="")
{
	;dout_f(A_ThisFunc)
	while (name:= n%A_Index%)
		prefs[name] := v%A_Index%
}
