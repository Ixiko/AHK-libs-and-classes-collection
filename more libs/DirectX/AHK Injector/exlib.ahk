#persistent
#include <memlib\memlib>

print(msg = "")
{
	static hnd
	if not hnd
		{
			DllCall("AllocConsole")
			hnd := DllCall("GetStdHandle", "int", -11)
		}
	return dllcall("WriteConsole", "int", hnd , "ptr", &msg, "int", strlen(msg))
}

global g_globals := {}
config := strsplit(A_ScriptOptions, "^")	
for k, v in config
{
	Key := SubStr(v, 1, 1)
	if (Key = "-")
		g_globals[SubStr(v, 2, strlen(v)-1)] := config[k + 1]	
	else if (Key = "/")
		g_globals[SubStr(v, 2, strlen(v)-1)] := True
}