#include AHK-LUA-API.ahk

L := luaL_newstate()

lua_register(L, "MsgBox", "LUAFUNC_MsgBox")
lua_register(L, "Hotkey", "LUAFUNC_Hotkey")

code =
(
    Hotkey("!1", "Show", "On")
    function Show(ThisHotKey)
        MsgBox("ThisHotKey = " .. ThisHotKey)
    end
)

luaL_doString(L, code)

LUAFUNC_MsgBox(L)
{
    MsgBox, % lua_tostring(L, 1)
    return 0
}

LUAFUNC_Hotkey(L)
{
    static HotKeyCount := 0, ARGS := {}
    ARGS.Push({L: L, ARG1: lua_tostring(L, 1), ARG2: lua_tostring(L, 2), ARG3: lua_tostring(L, 3)})
    HotKeyCount++
    Hotkey, % ARGS[HotKeyCount]["ARG1"], LuaHotKey, % ARGS[HotKeyCount]["ARG3"]
    lua_pushnumber(L, ErrorLevel)
    return 1
 
    LuaHotKey:
        for k, v in ARGS
        {
            if (A_ThisHotkey == v["ARG1"])
            {
                lua_getglobal(v["L"], v["ARG2"])
                lua_pushstring(v["L"], A_ThisHotkey)
                lua_call(v["L"], 1, 0)
            }
        }
    return
}