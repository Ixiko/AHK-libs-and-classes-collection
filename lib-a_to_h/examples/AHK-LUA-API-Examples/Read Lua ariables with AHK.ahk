#include AHK-LUA-API.ahk

L := luaL_newstate()

code =
(
    var = "String"
)

luaL_doString(L, code)

lua_getglobal(L, "var")
MsgBox, % lua_tostring(L, -1)

lua_close(L)