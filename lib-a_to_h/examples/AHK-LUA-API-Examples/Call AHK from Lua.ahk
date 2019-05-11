#include AHK-LUA-API.ahk

L := luaL_newstate()
lua_register(L, "MsgBox", "LUAFUNC_MsgBox")
lua_register(L, "Test", "LUAFUNC_Test")

code =
(
    sum = Test(228, 1337, 666)
    MsgBox("sum = " .. sum)
)

luaL_doString(L, code)
lua_close(L)

LUAFUNC_MsgBox(L)
{
    MsgBox, % lua_tostring(L, 1)
    return 0
}

LUAFUNC_Test(L)
{
    sum := 0
    n := lua_gettop(L)
    loop % n
        sum += lua_tonumber(L, A_Index)
    lua_pushnumber(L, sum)
    return 1
}