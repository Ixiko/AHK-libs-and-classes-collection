ExpandEnv(str) {
	VarSetCapacity(dest, 2000)
	DllCall("ExpandEnvironmentStrings", "str", str, "str", dest, int, 1999, "Cdecl int")
	return dest
}