class classString ;Just to be sure that I haven't named any of my local variables like this
{
	
	__New( string )
	{
		This.str := string
	}
	
	getNextAfter( pos, byref length := "" )
	{
		length := strLen( char := chr( ord( str := This.SubStr( pos, 2 ) ) ) )
		if ( str == "`r`n" )
			char := str, length := 2
		return char
	}
	
	subStr( pos:=1, length:=1 )
	{
		return SubStr( This.str, pos, length )
	}
	
}