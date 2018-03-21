GUID_ToString(guid)
{
	local string := 0
	DllCall("Ole32\StringFromCLSID", "Ptr", guid, "Ptr*", string)
	return StrGet(string, "UTF-16")
}

GUID_FromString(str, byRef mem)
{
	VarSetCapacity(mem, 16, 00)
	return DllCall("Ole32\CLSIDFromString", "Str", str, "Ptr", &mem)
}

GUID_IsGUIDString(str)
{
	return RegExMatch(str, "^\{[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}\}$")
}

GUID_Create(byRef guid)
{
	VarSetCapacity(guid, 16, 00)
	return DllCall("Ole32\CoCreateGuid", "Ptr", &guid, "Int")
}