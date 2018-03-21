/* Function: UUIDCreate
 *     Generate UUID using Rpcrt4\UuidCreate[Sequential/Nil]
 * License:
 *     WTFPL [http://wtfpl.net/]
 * Syntax:
 *     sUUID := UUIDCreate( [ mode := 1 , format := "" , ByRef UUID := "" ] )
 * Parameter(s):
 *     sUUID     [retval] - UUID (string)
 *     mode     [in, opt] - Defaults to one(1) which uses 'Rpcrt4\UuidCreate',
 *                          otherwise specify two(2) for 'UuidCreateSequential'
 *                          OR zero(0) for 'UuidCreateNil'.
 *     format   [in, opt] - If 'format' contains an opening brace('{'), output
 *                          will be wrapped in braces. Include the letter 'U' to
 *                          convert output to uppercase. Default is blank.
 *     UUID  [byref, opt] - Pass this parameter if you need the raw UUID
 */
UUIDCreate(mode:=1, format:="", ByRef UUID:="")
{
	UuidCreate := "Rpcrt4\UuidCreate"
	if InStr("02", mode)
		UuidCreate .= mode? "Sequential" : "Nil"
	VarSetCapacity(UUID, 16, 0) ;// long(UInt) + 2*UShort + 8*UChar
	if (DllCall(UuidCreate, "Ptr", &UUID) == 0)
	&& (DllCall("Rpcrt4\UuidToString", "Ptr", &UUID, "UInt*", pString) == 0)
	{
		string := StrGet(pString)
		DllCall("Rpcrt4\RpcStringFree", "UInt*", pString)
		if InStr(format, "U")
			DllCall("CharUpper", "Ptr", &string)
		return InStr(format, "{") ? "{" . string . "}" : string
	}
}