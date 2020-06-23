#SingleInstance force


_list_hotstring := ComObjCreate("Scripting.Dictionary")

_UpFirst(input)
{
	input := RegExReplace(input, "([^a-zA-Z]*)([a-z])?(.*)" , "$1$U2$3")
	return input
}



_UpAll(input)
{
	StringUpper, input, input
	return input
}



dispatchHotstring()
{
	global _list_hotstring
	key:=trim(A_ThisHotKey)
	macro:=_list_hotstring.item(key)
	
	StringRight, lastChar, macro, 1
	if(A_EndChar!=lastChar)
	{
		macro:=macro A_EndChar
	}
	
	ClipBoard:=macro
	Send ^v
}


addHotstring(key, val)
{
	global _list_hotstring
	
	; strip key of "::" if present
	key := RegExReplace(key, "(:\w*:)?(\w+)" , "$2")
	if(Trim(key)="")
	{
		MsgBox addHotstring::registering empty key is not allowed
		return
	}
	
	; key with first [a-z] letter in upper case
	keyu1 := ":CX:" _UpFirst(key)
	; key with everything in upper case
	keyuall := ":CX:" _UpAll(key)
	; default catchall key
	keydefault := ":X:" key
	

	if(keyu1==keyuall)
	{
	}else
	{
		_list_hotstring.item(keyuall) := _UpAll(val)
		Hotstring(keyuall , "dispatchHotstring", On)	
	}
	_list_hotstring.item(keyu1) := _UpFirst(val)
	_list_hotstring.item(keydefault) := val	
	Hotstring(keyu1 , "dispatchHotstring", On)
	Hotstring(keydefault , "dispatchHotstring", On)
}

