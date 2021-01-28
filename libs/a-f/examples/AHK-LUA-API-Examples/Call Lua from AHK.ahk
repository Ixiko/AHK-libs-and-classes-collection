#include AHK-LUA-API.ahk

L := luaL_newstate()

code =
(
    function add(x, y)
        return x + y
    end
)

luaL_doString(L, code)
MsgBox, % LUAFUNC_add(L, 5, 13)
lua_close(L)

LUAFUNC_add(L, x, y)
{
   lua_getglobal(L, "add")
   lua_pushnumber(L, x)
   lua_pushnumber(L, y)
   lua_call(L, 2, 1)
   sum := lua_tointeger(L, -1)
   lua_pop(L, 1)
   return sum
}