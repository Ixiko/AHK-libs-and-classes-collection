/* Function: Guid_New
 *     Create a GUID(__GUID) object
 * Syntax:
 *     oGuid := Guid_New()
 */
Guid_New()
{
	return new __GUID
}
/* Function: Guid_FromStr
 *     Converts a GUID string into a GUID struct
 * Syntax:
 *     pGuid := Guid_FromStr( sGuid, ByRef VarOrAddress )
 * Parameter(s):
 *     pGuid              [retval] - address of the GUID struct
 *     sGuid                  [in] - string representation of the GUID
 *     VarOrAddress   [ByRef, out] - GUID, memory address or variable
 */
Guid_FromStr(sGuid, ByRef VarOrAddress)
{
	if IsByRef(VarOrAddress) && (VarSetCapacity(VarOrAddress) < 16)
		VarSetCapacity(VarOrAddress, 16) ; adjust capacity
	pGuid := IsByRef(VarOrAddress) ? &VarOrAddress : VarOrAddress
	if ( DllCall("ole32\CLSIDFromString", "WStr", sGuid, "Ptr", pGuid) < 0 )
		throw Exception("Invalid GUID", -1, sGuid)
	return pGuid ; return address of GUID struct
}
/* Function: Guid_ToStr
 *     Converts a GUID into a string of printable characters
 * Syntax:
 *     sGuid := Guid_ToStr( ByRef VarOrAddress )
 * Parameter(s):
 *     sGuid              [retval] - GUID string
 *     VarOrAddress    [ByRef, in] - GUID, memory address or variable
 */
Guid_ToStr(ByRef VarOrAddress)
{
	pGuid := IsByRef(VarOrAddress) ? &VarOrAddress : VarOrAddress
	VarSetCapacity(sGuid, 78) ; (38 + 1) * 2
	if !DllCall("ole32\StringFromGUID2", "Ptr", pGuid, "Ptr", &sGuid, "Int", 39)
		throw Exception("Invalid GUID", -1, Format("<at {1:p}>", pGuid))
	return StrGet(&sGuid, "UTF-16")
}
/* Class: __GUID
 *     Creates an object that represents a GUID
 * Remarks:
 *     Caller must use the Guid_New() function to construct a __GUID object
 */
class __GUID ; naming convention to avoid possible variable name conflict (global namespace)
{
	/* Property: Ptr
	 *     Returns the address of the GUID struct
	 * Syntax:
	 *     pGuid := oGuid.Ptr
	 *     pGuid := oGuid[] ; alternative syntax
	 * Parameter(s):
	 *     pGuid    [retval] - address of the GUID struct
	 *     oGuid        [in] - a __GUID object
	 *     Ptr          [in] - property name, read-only
	 */

	 /* Property: Str
	 *     Returns a string represntation of the GUID
	 * Syntax:
	 *     sGuid := oGuid.Str
	 * Parameter(s):
	 *     pGuid    [retval] - GUID string
	 *     oGuid        [in] - a __GUID object
	 *     Str          [in] - property name, read-only
	 */
	__Get(key:="", args*)
	{
		if (key == "") || (key = "Ptr") || (key = "Str")
		{
			if !pGuid := ObjGetAddress(this, "_GUID")
			{
				ObjSetCapacity(this, "_GUID", 94) ; 16 + (39 * 2)
				pGuid := ObjGetAddress(this, "_GUID")
				if ( DllCall("ole32\CoCreateGuid", "Ptr", pGuid) != 0 )
					throw Exception("Failed to create GUID", -1, Format("<at {1:p}>", pGuid))

				DllCall("ole32\StringFromGUID2", "Ptr", pGuid, "Ptr", pGuid + 16, "Int", 39)
			}
			return InStr("Ptr", key) ? pGuid : StrGet(pGuid + 16, "UTF-16")
		}
	}
}