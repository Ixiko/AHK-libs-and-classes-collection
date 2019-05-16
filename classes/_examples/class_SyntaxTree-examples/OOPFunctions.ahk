hasClass( obj, classObj )
{
	While obj := obj.base
		if ( classObj = obj )
			return 1
}

isClass( obj, classObj )
{
	return ( obj.base = classObj )
}

hasCalleable( obj, keyName )
{
	return ( fn := obj[ keyName ] ) && ( isFuncOrBoundFunc( fn ) || fn.hasKey( "call" ) )
}

hasValue( obj, value )
{
	for each, val in obj
		if ( val = value )
			return 1
	return 0
}

;taken from just me
;https://autohotkey.com/boards/viewtopic.php?p=156419#p156419
isFuncOrBoundFunc(P) { ; v1.1
   ; Extracted from Type() for v1 by Coco (as far as I remember)
	Static BF := NumGet(&(_ := Func("IsFuncOrBoundFunc").Bind()), "Ptr")
	Return (IsFunc(P) || (IsObject(P) && (NumGet(&P, "Ptr") = BF)))
}