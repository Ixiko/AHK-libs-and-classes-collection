lua_LoadDLL(dll)
{
   return, DllCall("LoadLibrary", "str", dll)
}

lua_UnloadDLL(hDll)
{
   DllCall("FreeLibrary", "UInt", hDll)
}

lua_atPanic(ByRef l, panicf)
{
   Return, DllCall("lua51\lua_atPanic", "UInt", L, "UInt", panicF, "Cdecl")
}

lua_call(ByRef l, nargs, nresults)
{
   Return, DllCall("lua51\lua_pcall", "UInt", l, "Int", nargs, "Int", nresults, "Cdecl")
}

lua_checkstack(ByRef l, extra)
{
   Return, DllCall("lua51\lua_checkstack", "UInt", l, "Int", extra, "Cdecl Int")
}

lua_close(ByRef l)
{
   Return, DllCall("lua51\lua_close", "UInt", l, "Cdecl")
}

lua_concat(ByRef l, extra)
{
   Return, DllCall("lua51\lua_concat", "UInt", l, "Int", extra, "Cdecl")
}

lua_cpcall(ByRef l, func, ByRef ud)
{
   Return, DllCall("lua51\lua_cpcall", "UInt", l, "UInt", func, "UInt", ud, "Cdecl Int")
}

lua_createtable(ByRef l, narr, nrec)
{
   Return, DllCall("lua51\lua_createtable", "UInt", l, "Int", narr, "Int", nrec, "Cdecl")
}

lua_dump(ByRef l, writer, ByRef data)
{
   Return, DllCall("lua51\lua_dump", "UInt", l, "UInt", writer, "UInt", data, "Cdecl Int")
}

lua_equal(ByRef l, index1, index2)
{
   Return, DllCall("lua51\lua_equal", "UInt", l, "Int", index1, "Int", index2, "Cdecl Int")
}

lua_error(ByRef l)
{
   Return, DllCall("lua51\lua_error", "UInt", l, "Cdecl Int")
}

lua_gc(ByRef l, what, data)
{
   Return, DllCall("lua51\lua_gc", "UInt", l, "Int", what, "Int", data, "Cdecl Int")
}

;lua_getallofc(lua_State *L, void **ud)
; Returns the memory-allocation function of a given state.
; If ud is not NULL, Lua stores in *ud the opaque pointer passed to lua_newstate.

lua_getfenv(ByRef l, index)
{
   Return, DllCall("lua51\lua_getfenv", "UInt", l, "Int", index, "Cdecl")
}

lua_getfield(ByRef L, index, name)
{
   Return, DllCall("lua51\lua_getfield", "UInt", L, "Int", index, "Str", name, "Cdecl")
}

lua_getglobal(ByRef L, name)
{
   ;Return, DllCall("lua51\lua_getfield", "UInt", L, "Int", -10002, "Str", name, "Cdecl")
   Return, lua_getfield(L, -10002, name)
}

lua_getmetatable(ByRef L, index)
{
   Return, DllCall("lua51\lua_getmetatable", "UInt", L, "Int", index, "Cdecl Int")
}

lua_gettable(ByRef L, index)
{
   Return, DllCall("lua51\lua_gettable", "UInt", L, "Int", index, "Cdecl")
}

lua_gettop(ByRef l)
{
   Return, DllCall("lua51\lua_gettop", "UInt", l, "Cdecl Int")
}

lua_insert(ByRef l, index)
{
   Return, DllCall("lua51\lua_insert", "UInt", l, "Int", index, "Cdecl")
}

lua_isboolean(ByRef l, index)
{
   Return, DllCall("lua51\lua_isboolean", "UInt", L, "Int", index, "Cdecl Int")
}

lua_iscfunction(ByRef l, index)
{
   Return, DllCall("lua51\lua_iscfunction", "UInt", L, "Int", index, "Cdecl Int")
}

lua_isfunction(ByRef l, index)
{
   Return, DllCall("lua51\lua_isfunction", "UInt", L, "Int", index, "Cdecl Int")
}

lua_islightuserdata(ByRef l, index)
{
   Return, DllCall("lua51\lua_islightuserdata", "UInt", L, "Int", index, "Cdecl Int")
}

lua_isnil(ByRef l, index)
{
   Return, DllCall("lua51\lua_isnil", "UInt", L, "Int", index, "Cdecl Int")
}

lua_isnone(ByRef l, index)
{
   Return, DllCall("lua51\lua_isnone", "UInt", L, "Int", index, "Cdecl Int")
}

lua_isnoneornil(ByRef l, index)
{
   Return, DllCall("lua51\lua_isnoneornil", "UInt", L, "Int", index, "Cdecl Int")
}

lua_isnumber(ByRef l, index)
{
   Return, DllCall("lua51\lua_isnumber", "UInt", L, "Int", index, "Cdecl Int")
}

lua_isstring(ByRef l, index)
{
   Return, DllCall("lua51\lua_isstring", "UInt", L, "Int", index, "Cdecl Int")
}

lua_istable(ByRef l, index)
{
   Return, DllCall("lua51\lua_istable", "UInt", L, "Int", index, "Cdecl Int")
}

lua_isthread(ByRef l, index)
{
   Return, DllCall("lua51\lua_isthread", "UInt", L, "Int", index, "Cdecl Int")
}

lua_isuserdata(ByRef l, index)
{
   Return, DllCall("lua51\lua_isuserdata", "UInt", L, "Int", index, "Cdecl Int")
}

lua_lessthan(ByRef l, index)
{
   Return, DllCall("lua51\lua_lessthan", "UInt", L, "Int", index, "Cdecl Int")
}

lua_load(ByRef l, reader, ByRef data, ByRef chunkname)
{
   Return, DllCall("lua51\lua_load", "UInt", L, "UInt", reader, "UInt", data, "UInt", chunkname, "Cdecl Int")
}

lua_newstate(f, ByRef ud)
{
   Return, DllCall("lua51\lua_newstate", "UInt", f, "UInt", ud, "Cdecl UInt")
}

lua_newtable(ByRef l)
{
   ;Return, DllCall("lua51\lua_newtable", "UInt", l, "Cdecl")
   Return, lua_createTable(l, 0, 0)
}

lua_newthread(ByRef l)
{
   Return, DllCall("lua51\lua_newthread", "UInt", l, "Cdecl UInt")
}

;void *lua_newuserdata (lua_State *L, size_t size)
; This function allocates a new block of memory with the given size, pushes onto the
; stack a new full userdata with the block address, and returns this address.

lua_next(ByRef l, index)
{
   Return, DllCall("lua51\lua_next", "UInt", L, "Int", index, "Cdecl Int")
}

/*
;--------------------------------------------
;--- A typical traversal looks like this: ---
;--------------------------------------------
   ;table is in the stack at index 't'
   ;first key
   lua_pushnil(L)
   while (lua_next(L, t) != 0)
   {
    ;uses 'key' (at index -2) and 'value' (at index -1)
    msgbox % lua_typename(L, lua_type(L, -2)) " - " lua_typename(L, lua_type(L, -1))

    ;removes 'value'; keeps 'key' for next iteration
    lua_pop(L, 1);
   }
*/


lua_objlen(ByRef l, index)
{
   Return, DllCall("lua51\lua_objlen", "UInt", L, "Int", index, "Cdecl Int")
}

lua_pcall(ByRef l, nargs, nresults, errfunc)
{
   Return, DllCall("lua51\lua_pcall", "UInt", l, "Int", nargs, "Int", nresults, "UInt", errfunc, "Cdecl")
}

lua_pop(ByRef l, no)
{
   Return, DllCall("lua51\lua_pop", "UInt", l, "Int", no, "Cdecl")
}

lua_pushboolean(ByRef l, bool)
{
   Return, DllCall("lua51\lua_pushboolean", "UInt", l, "Int", bool, "Cdecl")
}

lua_pushcclosure(ByRef L, funcAddr, n)
{
   Return, DllCall("lua51\lua_pushcclosure", "UInt", L, "UInt", funcAddr, "Int", n, "Cdecl")
}

lua_pushcfunction(ByRef L, funcAddr)
{
   Return, DllCall("lua51\lua_pushcclosure", "UInt", L, "UInt", funcAddr, "Int", 0, "Cdecl")
   ;Return, lua_pushcclosure(L, funcAdd, 0)
}

;const char *lua_pushfstring (lua_State *L, const char *fmt, ...);
; Pushes onto the stack a formatted string and returns a pointer to this string.
; It is similar to the C function sprintf. also: lua_pushvfstring()

lua_pushinteger(ByRef l, int)
{
   Return, DllCall("lua51\lua_pushinteger", "UInt", l, "Int", int, "Cdecl")
}

lua_pushlightuserdata(ByRef l, ByRef p)
{
   Return, DllCall("lua51\lua_pushlightuserdata", "UInt", l, "UInt", p, "Cdecl")
}

lua_pushliteral(ByRef l, ByRef str)
{
   Return, DllCall("lua51\lua_pushliteral", "UInt", l, "UInt", str, "Cdecl")
}

lua_pushlstring(ByRef l, ByRef str, len)
{
   Return, DllCall("lua51\lua_pushlstring", "UInt", l, "UInt", str, "Int", len, "Cdecl")
}

lua_pushnil(ByRef l)
{
   Return, DllCall("lua51\lua_pushnil", "UInt", l, "Cdecl")
}

lua_pushnumber(ByRef l, no)
{
   Return, DllCall("lua51\lua_pushnumber", "UInt", l, "Double", no, "Cdecl")
}

lua_pushstring(ByRef l, ByRef str)
{
   Return, DllCall("lua51\lua_pushstring", "UInt", l, "Str", str, "Cdecl")
}

lua_pushthread(ByRef l)
{
   Return, DllCall("lua51\lua_pushthread", "UInt", l, "Cdecl")
}

lua_pushvalue(ByRef l, index)
{
   Return, DllCall("lua51\lua_pushvalue", "UInt", l, "Int", index, "Cdecl")
}

lua_rawequal(ByRef l, index1, index2)
{
   Return, DllCall("lua51\lua_rawequal", "UInt", l, "Int", index1, "Int", index2, "Cdecl Int")
}

lua_rawget(ByRef l, index)
{
   Return, DllCall("lua51\lua_rawget", "UInt", l, "Int", index, "Cdecl")
}

lua_rawgeti(ByRef l, index, n)
{
   Return, DllCall("lua51\lua_rawgeti", "UInt", l, "Int", index, "Int", n, "Cdecl")
}

lua_rawset(ByRef l, index)
{
   Return, DllCall("lua51\lua_rawset", "UInt", l, "Int", index, "Cdecl")
}

lua_rawseti(ByRef l, index, n)
{
   Return, DllCall("lua51\lua_rawseti", "UInt", l, "Int", index, "Int", n, "Cdecl")
}

lua_register(ByRef l, name, funcAddr)
{
   ;Return, DllCall("lua51\lua_register", "UInt", l, "Str", name, "UInt", funcAddr, "Cdecl")
   lua_pushcfunction(l, funcAddr)
   lua_setglobal(l, name)
}

lua_remove(ByRef l, index)
{
   Return, DllCall("lua51\lua_remove", "UInt", l, "Int", index, "Cdecl")
}

lua_replace(ByRef l, index)
{
   Return, DllCall("lua51\lua_replace", "UInt", l, "Int", index, "Cdecl")
}

lua_resume(ByRef l, narg)
{
   Return, DllCall("lua51\lua_resume", "UInt", l, "Int", narg, "Cdecl Int")
}

lua_setallocf(ByRef l, f, ByRef ud)
{
   Return, DllCall("lua51\lua_setallocf", "UInt", l, "UInt", f, "UInt", ud, "Cdecl")
}

lua_setfenv(ByRef l, index)
{
   Return, DllCall("lua51\lua_setfenv", "UInt", l, "Int", index, "Cdecl Int")
}

lua_setfield(ByRef L, index, name)
{
   Return, DllCall("lua51\lua_setfield", "UInt", L, "Int", index, "Str", name, "Cdecl")
}

lua_setglobal(ByRef L, name)
{
   ;Return, DllCall("lua51\lua_setfield", "UInt", L, "Int", -10002, "Str", name, "Cdecl")
   Return, lua_setfield(L, -10002, name)
}

lua_setmetatable(ByRef L, index)
{
   Return, DllCall("lua51\lua_setmetatable", "UInt", L, "Int", index, "Cdecl Int")
}

lua_settable(ByRef L, index)
{
   Return, DllCall("lua51\lua_settable", "UInt", L, "Int", index, "Cdecl")
}

lua_settop(ByRef l, index)
{
   Return, DllCall("lua51\lua_settop", "UInt", l, "Int", index, "Cdecl")
}

lua_status(ByRef l)
{
   Return, DllCall("lua51\lua_status", "UInt", l, "Cdecl")
}

lua_toboolean(ByRef l, no)
{
   Return, DllCall("lua51\lua_toboolean", "UInt", l, "Int", no, "Cdecl Int")
}

lua_tocfunction(ByRef l, no)
{
   Return, DllCall("lua51\lua_tocfunction", "UInt", l, "Int", no, "Cdecl UInt")
}

lua_tointeger(ByRef l, no)
{
   Return, DllCall("lua51\lua_tointeger", "UInt", l, "Int", no, "Cdecl Int")
}

lua_tolstring(ByRef l, no, size)
{
   Return, DllCall("lua51\lua_tolstring", "UInt", l, "Int", no, "Int", size, "Cdecl Str")
}

lua_tonumber(ByRef l, no)
{
   Return, DllCall("lua51\lua_tonumber", "UInt", l, "Int", no, "Cdecl Double")
}

lua_topointer(ByRef l, no)
{
   Return, DllCall("lua51\lua_topointer", "UInt", l, "Int", no, "Cdecl UInt")
}

lua_tostring(ByRef l, no)
{
   ;Return, DllCall("lua51\lua_tostring", "UInt", l, "Int", no, "Cdecl Str")
   Return, lua_tolstring(l, no, 0)
}

lua_tothread(ByRef l, no)
{
   Return, DllCall("lua51\lua_tothread", "UInt", l, "Int", no, "Cdecl UInt")
}

lua_touserdata(ByRef l, no)
{
   Return, DllCall("lua51\lua_touserdata", "UInt", l, "Int", no, "Cdecl UInt")
}

lua_type(ByRef l, no)
{
   Return, DllCall("lua51\lua_type", "UInt", l, "Int", no, "Cdecl Int")
}

lua_typename(ByRef l, tp)
{
   Return, DllCall("lua51\lua_typename", "UInt", l, "Int", tp, "Cdecl Str")
}

lua_xmove(ByRef from, ByRef to, n)
{
   Return, DllCall("lua51\lua_xmove", "UInt", from, "UInt", to, "Int", n, "Cdecl")
}

lua_yield(ByRef l, nresults)
{
   Return, DllCall("lua51\lua_yield", "UInt", l, "Int", nresults, "Cdecl Int")
}



;---------------------------------------------
; Load the standard Lua libraries
;---------------------------------------------
luaopen_base(ByRef l)
{
   Return, DllCall("lua51\luaopen_base", "UInt", l, "Cdecl")
}

luaopen_package(ByRef l)
{
   Return, DllCall("lua51\luaopen_package", "UInt", l, "Cdecl")
}

luaopen_string(ByRef l)
{
   Return, DllCall("lua51\luaopen_string", "UInt", l, "Cdecl")
}

luaopen_table(ByRef l)
{
   Return, DllCall("lua51\luaopen_table", "UInt", l, "Cdecl")
}

luaopen_math(ByRef l)
{
   Return, DllCall("lua51\luaopen_math", "UInt", l, "Cdecl")
}

luaopen_io(ByRef l)
{
   Return, DllCall("lua51\luaopen_io", "UInt", l, "Cdecl")
}

luaopen_os(ByRef l)
{
   Return, DllCall("lua51\luaopen_os", "UInt", l, "Cdecl")
}

luaopen_debug(ByRef l)
{
   Return, DllCall("lua51\luaopen_debug", "UInt", l, "Cdecl")
}

;---------------------------------------------
;luaL
;---------------------------------------------
luaL_buffinit(ByRef l, ByRef Buffer)
{
   Return, DllCall("lua51\luaL_buffinit", "UInt", l, "UInt", Buffer, "Cdecl")
}

luaL_callmeta(ByRef l, obj, ByRef e)
{
   Return, DllCall("lua51\luaL_callmeta", "UInt", l, "Int", obj, "Str", e, "Cdecl Int")
}

luaL_checkany(ByRef l, narg)
{
   Return, DllCall("lua51\luaL_checkany", "UInt", l, "Int", narg, "Cdecl")
}

luaL_checkint(ByRef l, no)
{
   Return, DllCall("lua51\luaL_checkint", "UInt", l, "Int", no, "Cdecl Int")
}

luaL_checkinteger(ByRef l, no)
{
   Return, DllCall("lua51\luaL_checkinteger", "UInt", l, "Int", no, "Cdecl Int")
}

luaL_checklong(ByRef l, no)
{
   Return, DllCall("lua51\luaL_checklong", "UInt", l, "Int", no, "Cdecl Int")
}

luaL_checklstring(ByRef l, no, ByRef len)
{
   Return, DllCall("lua51\luaL_checklstring", "UInt", l, "Int", no, "UInt", len, "Cdecl Str")
}

luaL_checknumber(ByRef l, no)
{
   Return, DllCall("lua51\luaL_checknumber", "UInt", l, "Int", no, "Cdecl Int")
}

luaL_checkoption(ByRef l, no, ByRef def, ByRef lst)
{
   Return, DllCall("lua51\luaL_checkoption", "UInt", l, "Int", no, "UInt", def, "UInt", lst, "Cdecl Int")
}

luaL_checkstack(ByRef l, no, ByRef msg)
{
   Return, DllCall("lua51\luaL_checkstack", "UInt", l, "Int", no, "Str", msg, "Cdecl")
}

luaL_checkstring(ByRef l, narg)
{
   Return, DllCall("lua51\luaL_checkstring", "UInt", l, "Int", narg, "Cdecl")
}

luaL_checktype(ByRef l, no, t)
{
   Return, DllCall("lua51\luaL_checktype", "UInt", l, "Int", no, "Int", t, "Cdecl")
}

luaL_checkudata(ByRef l, no, ByRef tname)
{
   Return, DllCall("lua51\luaL_checkudata", "UInt", l, "Int", no, "Str", tname, "Cdecl")
}

luaL_dofile(ByRef l, file)
{
   ;Return, DllCall("lua51\luaL_dofile", "UInt", l, "Str", file, "Cdecl Int")
   luaL_loadfile(l, file)
   Return % lua_pCall(l, 0, -1, 0)
}

luaL_dostring(ByRef l, ByRef str)
{
   ;Return, DllCall("lua51\luaL_dostring", "UInt", l, "Str", str, "Cdecl Int")
   luaL_loadstring(l, str)
   Return % lua_pCall(l, 0, -1, 0)
}

luaL_error(ByRef l, ByRef str)
{
   Return, DllCall("lua51\luaL_error", "UInt", l, "Str", str, "Cdecl Int")
}

luaL_getmetafield(ByRef l, no, ByRef e)
{
   Return, DllCall("lua51\luaL_getmetafield", "UInt", l, "Int", no, "Str", e, "Cdecl Int")
}

luaL_getmetatable(ByRef l, ByRef tname)
{
   Return, DllCall("lua51\luaL_getmetatable", "UInt", l, "Str", tname, "Cdecl")
}

luaL_gsub(ByRef l, ByRef s, ByRef p, ByRef r)
{
   Return, DllCall("lua51\luaL_gsub", "UInt", l, "UInt", s, "UInt", p, "UInt", r, "Cdecl Str")
}

luaL_loadbuffer(ByRef l, ByRef buff, sz, ByRef name)
{
   Return, DllCall("lua51\luaL_loadbuffer", "UInt", l, "UInt", buff, "Int", sz, "Str", name, "Cdecl Int")
}

luaL_loadfile(ByRef l, file)
{
   Return, DllCall("lua51\luaL_loadfile", "UInt", l, "Str", file, "Cdecl Int")
}

luaL_loadstring(ByRef l, ByRef s)
{
   Return, DllCall("lua51\luaL_loadstring", "UInt", l, "Str", s, "Cdecl Int")
}

luaL_newmetatable(ByRef l, ByRef tname)
{
   Return, DllCall("lua51\luaL_newmetatable", "UInt", l, "Str", tname, "Cdecl Int")
}

luaL_newstate()
{
   Return, DllCall("lua51\luaL_newstate", "Cdecl")
}

luaL_openlibs(ByRef l)
{
   Return, DllCall("lua51\luaL_openlibs", "UInt", l, "Cdecl")
}

;int luaL_optint (lua_State *L, int narg, int d);
;lua_Integer luaL_optinteger (lua_State *L, int narg, lua_Integer d);
;long luaL_optlong (lua_State *L, int narg, long d);
;const char *luaL_optlstring (lua_State *L, int narg, const char *d, size_t *l);
;lua_Number luaL_optnumber (lua_State *L, int narg, lua_Number d);
;const char *luaL_optstring (lua_State *L, int narg, const char *d);
;char *luaL_prepbuffer (luaL_Buffer *B);
;void luaL_pushresult (luaL_Buffer *B);
;int luaL_ref (lua_State *L, int t);
;void luaL_register (lua_State *L, const char *libname, const luaL_Reg *l)
;const char *luaL_typename (lua_State *L, int index);
;int luaL_typerror (lua_State *L, int narg, const char *tname);
;void luaL_unref (lua_State *L, int t, int ref);
;void luaL_where (lua_State *L, int lvl);

lua_registerAhkFunction(ByRef l)
{
   lua_register(l, "AutoTrim", RegisterCallback("AutoTrim","C"))
   lua_register(l, "BlockInput", RegisterCallback("BlockInput","C"))
   lua_register(l, "Click", RegisterCallback("Click","C"))
   lua_register(l, "ClipWait", RegisterCallback("ClipWait","C"))
   lua_register(l, "Control", RegisterCallback("Control","C"))
   lua_register(l, "ControlClick", RegisterCallback("ControlClick","C"))
   lua_register(l, "ControlFocus", RegisterCallback("ControlFocus","C"))
   lua_register(l, "ControlMove", RegisterCallback("ControlMove","C"))
   lua_register(l, "ControlSend", RegisterCallback("ControlSend","C"))
   lua_register(l, "ControlSendRaw", RegisterCallback("ControlSendRaw","C"))
   lua_register(l, "ControlSetText", RegisterCallback("ControlSetText","C"))
   lua_register(l, "CoordMode", RegisterCallback("CoordMode","C"))
   lua_register(l, "Critical", RegisterCallback("Critical","C"))
   lua_register(l, "DetectHiddenText", RegisterCallback("DetectHiddenText","C"))
   lua_register(l, "DetectHiddenWindows", RegisterCallback("DetectHiddenWindows","C"))
   lua_register(l, "Drive", RegisterCallback("Drive","C"))
   lua_register(l, "Edit", RegisterCallback("Edit","C"))
   lua_register(l, "EnvAdd", RegisterCallback("EnvAdd","C"))
   lua_register(l, "EnvSub", RegisterCallback("EnvSub","C"))
   lua_register(l, "EnvDiv", RegisterCallback("EnvDiv","C"))
   lua_register(l, "EnvMult", RegisterCallback("EnvMult","C"))
   lua_register(l, "EnvSet", RegisterCallback("EnvSet","C"))
   lua_register(l, "EnvUpdate", RegisterCallback("EnvUpdate","C"))
   lua_register(l, "Exit", RegisterCallback("Exit","C"))
   lua_register(l, "ExitApp", RegisterCallback("ExitApp","C"))
   lua_register(l, "FileAppend", RegisterCallback("FileAppend","C"))
   lua_register(l, "FileCopy", RegisterCallback("FileCopy","C"))
   lua_register(l, "FileCopyDir", RegisterCallback("FileCopyDir","C"))
   lua_register(l, "FileCreateDir", RegisterCallback("FileCreateDir","C"))
   lua_register(l, "FileCreateShortcut", RegisterCallback("FileCreateShortcut","C"))
   lua_register(l, "FileDelete", RegisterCallback("FileDelete","C"))
   lua_register(l, "FileMove", RegisterCallback("FileMove","C"))
   lua_register(l, "FileMoveDir", RegisterCallback("FileMoveDir","C"))
   lua_register(l, "FileRecycle", RegisterCallback("FileRecycle","C"))
   lua_register(l, "FileRecycleEmpty", RegisterCallback("FileRecycleEmpty","C"))
   lua_register(l, "FileRemoveDir", RegisterCallback("FileRemoveDir","C"))
   lua_register(l, "FileSetAttrib", RegisterCallback("FileSetAttrib","C"))
   lua_register(l, "FileSetTime", RegisterCallback("FileSetTime","C"))
   lua_register(l, "Gosub", RegisterCallback("Gosub","C"))
   lua_register(l, "Goto", RegisterCallback("Goto","C"))
   lua_register(l, "GroupActivate", RegisterCallback("GroupActivate","C"))
   lua_register(l, "GroupAdd", RegisterCallback("GroupAdd","C"))
   lua_register(l, "GroupClose", RegisterCallback("GroupClose","C"))
   lua_register(l, "GroupDeactivate", RegisterCallback("GroupDeactivate","C"))
   lua_register(l, "Gui", RegisterCallback("Gui","C"))
   lua_register(l, "GuiControl", RegisterCallback("GuiControl","C"))
   lua_register(l, "Hotkey", RegisterCallback("Hotkey","C"))
   lua_register(l, "IniDelete", RegisterCallback("IniDelete","C"))
   lua_register(l, "IniWrite", RegisterCallback("IniWrite","C"))
   lua_register(l, "KeyHistory", RegisterCallback("KeyHistory","C"))
   lua_register(l, "KeyWait", RegisterCallback("KeyWait","C"))
   lua_register(l, "ListHotkeys", RegisterCallback("ListHotkeys","C"))
   lua_register(l, "ListLines", RegisterCallback("ListLines","C"))
   lua_register(l, "ListVars", RegisterCallback("ListVars","C"))
   lua_register(l, "Menu", RegisterCallback("Menu","C"))
   lua_register(l, "MouseClick", RegisterCallback("MouseClick","C"))
   lua_register(l, "MouseClickDrag", RegisterCallback("MouseClickDrag","C"))
   lua_register(l, "MouseMove", RegisterCallback("MouseMove","C"))
   lua_register(l, "Msgbox", RegisterCallback("msgbox","C"))
   lua_register(l, "OnExit", RegisterCallback("OnExit","C"))
   lua_register(l, "OutputDebug", RegisterCallback("OutputDebug","C"))
   lua_register(l, "Pause", RegisterCallback("Pause","C"))
   lua_register(l, "PostMessage", RegisterCallback("PostMessage","C"))
   lua_register(l, "Process", RegisterCallback("Process","C"))
   lua_register(l, "Progress", RegisterCallback("Progress","C"))
   lua_register(l, "RegDelete", RegisterCallback("RegDelete","C"))
   lua_register(l, "RegWrite", RegisterCallback("RegWrite","C"))
   lua_register(l, "Reload", RegisterCallback("Reload","C"))
   lua_register(l, "RunAs", RegisterCallback("RunAs","C"))
   lua_register(l, "RunWait", RegisterCallback("RunWait","C"))
   lua_register(l, "Send", RegisterCallback("Send","C"))
   lua_register(l, "SendInput", RegisterCallback("SendInput","C"))
   lua_register(l, "SendMessage", RegisterCallback("SendMessage","C"))
   lua_register(l, "SendMode", RegisterCallback("SendMode","C"))
   lua_register(l, "SendPlay", RegisterCallback("SendPlay","C"))
   lua_register(l, "SendRaw", RegisterCallback("SendRaw","C"))
   lua_register(l, "SetBatchLines", RegisterCallback("SetBatchLines","C"))
   lua_register(l, "SetCapslockState", RegisterCallback("SetCapslockState","C"))
   lua_register(l, "SetControlDelay", RegisterCallback("SetControlDelay","C"))
   lua_register(l, "SetDefaultMouseSpeed", RegisterCallback("SetDefaultMouseSpeed","C"))
   lua_register(l, "SetEnv", RegisterCallback("SetEnv","C"))
   lua_register(l, "SetFormat", RegisterCallback("SetFormat","C"))
   lua_register(l, "SetKeyDelay", RegisterCallback("SetKeyDelay","C"))
   lua_register(l, "SetMouseDelay", RegisterCallback("SetMouseDelay","C"))
   lua_register(l, "SetNumlockState", RegisterCallback("SetNumlockState","C"))
   lua_register(l, "SetScrollLockState", RegisterCallback("SetScrollLockState","C"))
   lua_register(l, "SetStoreCapslockMode", RegisterCallback("SetStoreCapslockMode","C"))
   lua_register(l, "SetTimer", RegisterCallback("SetTimer","C"))
   lua_register(l, "SetTitleMatchMode", RegisterCallback("SetTitleMatchMode","C"))
   lua_register(l, "SetWinDelay", RegisterCallback("SetWinDelay","C"))
   lua_register(l, "SetWorkingDir", RegisterCallback("SetWorkingDir","C"))
   lua_register(l, "Shutdown", RegisterCallback("Shutdown","C"))
   lua_register(l, "Sleep", RegisterCallback("sleep","C"))
   lua_register(l, "Sort", RegisterCallback("Sort","C"))
   lua_register(l, "SoundBeep", RegisterCallback("SoundBeep","C"))
   lua_register(l, "SoundPlay", RegisterCallback("SoundPlay","C"))
   lua_register(l, "SoundSet", RegisterCallback("SoundSet","C"))
   lua_register(l, "SoundSetWaveVolume", RegisterCallback("SoundSetWaveVolume","C"))
   lua_register(l, "SplashImage", RegisterCallback("SplashImage","C"))
   lua_register(l, "SplashTextOff", RegisterCallback("SplashTextOff","C"))
   lua_register(l, "SplashTextOn", RegisterCallback("SplashTextOn","C"))
   lua_register(l, "StatusBarWait", RegisterCallback("StatusBarWait","C"))
   lua_register(l, "StringCaseSense", RegisterCallback("StringCaseSense","C"))
   lua_register(l, "Thread", RegisterCallback("Thread","C"))
   lua_register(l, "Tooltip", RegisterCallback("tooltip","C"))
   lua_register(l, "TrayTip", RegisterCallback("TrayTip","C"))
   lua_register(l, "UrlDownloadToFile", RegisterCallback("UrlDownloadToFile","C"))
   lua_register(l, "WinActivate", RegisterCallback("WinActivate","C"))
   lua_register(l, "WinActivateBottom", RegisterCallback("WinActivateBottom","C"))
   lua_register(l, "WinClose", RegisterCallback("WinClose","C"))
   lua_register(l, "WinHide", RegisterCallback("WinHide","C"))
   lua_register(l, "WinKill", RegisterCallback("WinKill","C"))
   lua_register(l, "WinMaximize", RegisterCallback("WinMaximize","C"))
   lua_register(l, "WinMenuSelectItem", RegisterCallback("WinMenuSelectItem","C"))
   lua_register(l, "WinMinimize", RegisterCallback("WinMinimize","C"))
   lua_register(l, "WinMinimizeAll", RegisterCallback("WinMinimizeAll","C"))
   lua_register(l, "WinMinimizeAllUndo", RegisterCallback("WinMinimizeAllUndo","C"))
   lua_register(l, "WinMove", RegisterCallback("WinMove","C"))
   lua_register(l, "WinRestore", RegisterCallback("WinRestore","C"))
   lua_register(l, "WinSet", RegisterCallback("WinSet","C"))
   lua_register(l, "WinSetTitle", RegisterCallback("WinSetTitle","C"))
   lua_register(l, "WinShow", RegisterCallback("WinShow","C"))
   lua_register(l, "WinWait", RegisterCallback("WinWait","C"))
   lua_register(l, "WinWaitActive", RegisterCallback("WinWaitActive","C"))
   lua_register(l, "WinWaitClose", RegisterCallback("WinWaitClose","C"))
   lua_register(l, "WinWaitNotActive", RegisterCallback("WinWaitNotActive","C"))

   lua_register(l, "ControlGet", RegisterCallback("ControlGet","C"))
   lua_register(l, "ControlGetFocus", RegisterCallback("ControlGetFocus","C"))
   lua_register(l, "ControlGetText", RegisterCallback("ControlGetText","C"))
   lua_register(l, "ControlGetPos", RegisterCallback("ControlGetPos","C"))
   lua_register(l, "DriveGet", RegisterCallback("DriveGet","C"))
   lua_register(l, "DriveSpaceFree", RegisterCallback("DriveSpaceFree","C"))
   lua_register(l, "EnvGet", RegisterCallback("EnvGet","C"))
   lua_register(l, "FileGetAttrib", RegisterCallback("FileGetAttrib","C"))
   lua_register(l, "FileGetShortcut", RegisterCallback("FileGetShortcut","C"))
   lua_register(l, "FileGetSize", RegisterCallback("FileGetSize","C"))
   lua_register(l, "FileGetTime", RegisterCallback("FileGetTime","C"))
   lua_register(l, "FileGetVersion", RegisterCallback("FileGetVersion","C"))
   lua_register(l, "FileRead", RegisterCallback("FileRead","C"))
   lua_register(l, "FileReadLine", RegisterCallback("FileReadLine","C"))
   lua_register(l, "FileSelectFile", RegisterCallback("FileSelectFile","C"))
   lua_register(l, "FileSelectFolder", RegisterCallback("FileSelectFolder","C"))
   lua_register(l, "FormatTime", RegisterCallback("FormatTime","C"))
   lua_register(l, "GetKeyState", RegisterCallback("GetKeyState","C"))
   lua_register(l, "GuiControlGet", RegisterCallback("GuiControlGet","C"))
   lua_register(l, "ImageSearch", RegisterCallback("ImageSearch","C"))
   lua_register(l, "IniRead", RegisterCallback("IniRead","C"))
   lua_register(l, "Input", RegisterCallback("Input","C"))
   lua_register(l, "InputBox", RegisterCallback("InputBox","C"))
   lua_register(l, "MouseGetPos", RegisterCallback("MouseGetPos","C"))
   lua_register(l, "PixelGetColor", RegisterCallback("PixelGetColor","C"))
   lua_register(l, "PixelSearch", RegisterCallback("PixelSearch","C"))
   lua_register(l, "Random", RegisterCallback("Random","C"))
   lua_register(l, "RegRead", RegisterCallback("RegRead","C"))
   lua_register(l, "Run", RegisterCallback("Run","C"))
   lua_register(l, "SoundGet", RegisterCallback("SoundGet","C"))
   lua_register(l, "SoundGetWaveVolume", RegisterCallback("SoundGetWaveVolume","C"))
   lua_register(l, "StatusBarGetText", RegisterCallback("StatusBarGetText","C"))
   lua_register(l, "SplitPath", RegisterCallback("SplitPath","C"))
   lua_register(l, "StringGetPos", RegisterCallback("StringGetPos","C"))
   lua_register(l, "StringLeft", RegisterCallback("StringLeft","C"))
   lua_register(l, "StringLen", RegisterCallback("StringLen","C"))
   lua_register(l, "StringLower", RegisterCallback("StringLower","C"))
   lua_register(l, "StringMid", RegisterCallback("StringMid","C"))
   lua_register(l, "StringReplace", RegisterCallback("StringReplace","C"))
   lua_register(l, "StringRight", RegisterCallback("StringRight","C"))
   lua_register(l, "StringTrimLeft", RegisterCallback("StringTrimLeft","C"))
   lua_register(l, "StringTrimRight", RegisterCallback("StringTrimRight","C"))
   lua_register(l, "StringUpper", RegisterCallback("StringUpper","C"))
   lua_register(l, "SysGet", RegisterCallback("SysGet","C"))
   lua_register(l, "Transform", RegisterCallback("Transform","C"))
   lua_register(l, "WinGet", RegisterCallback("WinGet","C"))
   lua_register(l, "WinGetActiveTitle", RegisterCallback("WinGetActiveTitle","C"))
   lua_register(l, "WinGetActiveStats", RegisterCallback("WinGetActiveStats","C"))
   lua_register(l, "WinGetClass", RegisterCallback("WinGetClass","C"))
   lua_register(l, "WinGetText", RegisterCallback("WinGetText","C"))
   lua_register(l, "WinGetTitle", RegisterCallback("WinGetTitle","C"))
   lua_register(l, "WinGetPos", RegisterCallback("WinGetPos","C"))

   lua_register(l, "ahkFunction", RegisterCallback("ahkFunction","C"))
   lua_register(l, "ahkGetVar", RegisterCallback("ahkGetVar","C"))
}

AutoTrim(L)
{
   arg1 := lua_tostring(L, 1)

   AutoTrim, %arg1%

   return 0
}

BlockInput(L)
{
   arg1 := lua_tostring(L, 1)

   BlockInput, %arg1%

   return 0
}

Click(L)
{
   arg1 := lua_tostring(L, 1)

   Click %arg1%

   return 0
}

ClipWait(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)

   if arg2 =
      arg2 := 1

   ClipWait, %arg1%, %arg2%

   return 0
}

Control(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)
   arg6 := lua_tostring(L, 6)
   arg7 := lua_tostring(L, 7)

   Control, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%, %arg6%, %arg7%

   return 0
}

ControlClick(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)
   arg6 := lua_tostring(L, 6)
   arg7 := lua_tostring(L, 7)
   arg8 := lua_tostring(L, 8)

   ControlClick, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%, %arg6%, %arg7%, %arg8%

   return 0
}

ControlFocus(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)

   ControlFocus, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%

   return 0
}

ControlMove(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)
   arg6 := lua_tostring(L, 6)
   arg7 := lua_tostring(L, 7)
   arg8 := lua_tostring(L, 8)
   arg9 := lua_tostring(L, 9)

   ControlMove, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%, %arg6%, %arg7%, %arg8%, %arg9%

   return 0
}

ControlSend(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)
   arg6 := lua_tostring(L, 6)

   ControlSend, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%, %arg6%

   return 0
}

ControlSendRaw(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)
   arg6 := lua_tostring(L, 6)

   ControlSendRaw, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%, %arg6%

   return 0
}

ControlSetText(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)
   arg6 := lua_tostring(L, 6)

   ControlSetText, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%, %arg6%

   return 0
}

CoordMode(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)

   CoordMode, %arg1%, %arg2%

   return 0
}

Critical(L)
{
   arg1 := lua_tostring(L, 1)

   if arg1 = off
      Critical, off
   else
      Critical %arg1%

   return 0
}

DetectHiddenText(L)
{
   arg1 := lua_tostring(L, 1)

   DetectHiddenText, %arg1%

   return 0
}

DetectHiddenWindows(L)
{
   arg1 := lua_tostring(L, 1)

   DetectHiddenWindows, %arg1%

   return 0
}

Drive(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)

   Drive, %arg1%, %arg2%, %arg3%

   return 0
}

Edit(L)
{
   Edit

   return 0
}

EnvAdd(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)

   EnvAdd, %arg1%, %arg2%, %arg3%

   return 0
}

EnvDiv(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)

   EnvDiv, %arg1%, %arg2%

   return 0
}

EnvMult(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)

   EnvMult, %arg1%, %arg2%

   return 0
}

EnvSet(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)

   EnvSet, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%

   return 0
}

EnvSub(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)

   EnvSub, %arg1%, %arg2%, %arg3%

   return 0
}

EnvUpdate(L)
{
   EnvUpdate

   return 0
}

Exit(L)
{
   arg1 := lua_tostring(L, 1)

   Exit, %arg1%

   return 0
}

ExitApp(L)
{
   arg1 := lua_tostring(L, 1)

   ExitApp, %arg1%

   return 0
}

FileAppend(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)

   FileAppend, %arg1%, %arg2%

   return 0
}

FileCopy(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)

   FileCopy, %arg1%, %arg2%, %arg3%

   return 0
}

FileCopyDir(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)

   FileCopyDir, %arg1%, %arg2%, %arg3%

   return 0
}

FileCreateDir(L)
{
   arg1 := lua_tostring(L, 1)

   FileCreateDir, %arg1%

   return 0
}

FileCreateShortcut(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)
   arg6 := lua_tostring(L, 6)
   arg7 := lua_tostring(L, 7)
   arg8 := lua_tostring(L, 8)
   arg9 := lua_tostring(L, 9)

   FileCreateShortcut, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%, %arg6%, %arg7%, %arg8%, %arg9%

   return 0
}

FileDelete(L)
{
   arg1 := lua_tostring(L, 1)

   FileDelete, %arg1%

   return 0
}

FileMove(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)

   FileMove, %arg1%, %arg2%, %arg3%

   return 0
}

FileMoveDir(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)

   FileMoveDir, %arg1%, %arg2%, %arg3%

   return 0
}

FileRecycle(L)
{
   arg1 := lua_tostring(L, 1)

   FileRecycle, %arg1%

   return 0
}

FileRecycleEmpty(L)
{
   arg1 := lua_tostring(L, 1)

   FileRecycleEmpty, %arg1%

   return 0
}

FileRemoveDir(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)

   FileRemoveDir, %arg1%, %arg2%

   return 0
}

FileSetAttrib(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)

   FileSetAttrib, %arg1%, %arg2%, %arg3%, %arg4%

   return 0
}

FileSetTime(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)

   FileSetTime, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%

   return 0
}

Gosub(L)
{
   arg1 := lua_tostring(L, 1)

   Gosub, %arg1%

   return 0
}

Goto(L)
{
   arg1 := lua_tostring(L, 1)

   Goto, %arg1%

   return 0
}

GroupActivate(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)

   GroupActivate, %arg1%, %arg2%

   return 0
}

GroupAdd(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)
   arg6 := lua_tostring(L, 6)

   GroupAdd, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%, %arg6%

   return 0
}

GroupClose(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)

   GroupClose, %arg1%, %arg2%

   return 0
}

GroupDeactivate(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)

   GroupDeactivate, %arg1%, %arg2%

   return 0
}

GuiControl(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)

   GuiControl, %arg1%, %arg2%, %arg3%

   return 0
}

Hotkey(L)
{
   Global
   local arg1, arg2, arg3, val, func

   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)

   if(arg1 == "IfWinActive" || arg1 == "IfWinExist")
      Hotkey, %arg1%, %arg2%, %arg3%
   else
   {
      if(arg2 == "On" || arg2 == "Off" || arg2 == "Toggle" || arg2 == "AltTab")
         Hotkey, %arg1%, %arg2%, %arg3%
      else
      {
         if numHotkeys =
            numHotkeys = 1
         else
            numHotkeys++

         key_%numHotkeys% := arg1
         label_%numHotkeys% := arg2
         state_%numHotkeys% := L

         Hotkey, %arg1%, globalHotkeyLabel, %arg3%
      }
   }

   return 0

   globalHotkeyLabel:
      loop, %numHotkeys%
      {
         if (key_%A_Index% == A_ThisHotkey)
         {
            func := label_%A_Index%
            Lb := state_%A_Index%

            ; the function name
            lua_getglobal(Lb, func)

            ; the first argument
            ;lua_pushstring(Lb, A_ThisHotkey)

            ; the second argument
            ;lua_pushstring(Lb, A_PriorHotkey)

            ; the second argument
            ;lua_pushstring(Lb, A_TimeSinceThisHotkey)

            ; the second argument
            ;lua_pushstring(Lb, A_TimeSincePriorHotkey)

            ; call the function with 2 arguments, return 1 result
            lua_call(Lb, 0, 0)
         }
      }
   return

}


IniDelete(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)

   IniDelete, %arg1%, %arg2%, %arg3%

   return 0
}

IniWrite(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)

   IniWrite, %arg1%, %arg2%, %arg3%, %arg4%

   return 0
}

KeyHistory(L)
{
   KeyHistory

   return 0
}

KeyWait(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)

   KeyWait, %arg1%, %arg2%

   return 0
}

ListHotkeys(L)
{
   ListHotkeys

   return 0
}

ListLines(L)
{
   arg1 := lua_tostring(L, 1)

   if arg1 =
      ListLines
   else
      ListLines, %arg1%

   return 0
}

ListVars(L)
{
   ListVars

   return 0
}

Menu(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)

   Menu, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%

   return 0
}

MouseClick(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)
   arg6 := lua_tostring(L, 6)
   arg7 := lua_tostring(L, 7)

   MouseClick, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%, %arg6%, %arg7%

   return 0
}

MouseClickDrag(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)
   arg6 := lua_tostring(L, 6)
   arg7 := lua_tostring(L, 7)

   MouseClickDrag, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%, %arg6%, %arg7%

   return 0
}

MouseMove(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)

   MouseMove, %arg1%, %arg2%, %arg3%, %arg4%

   return 0
}

OnExit(L)
{
   arg1 := lua_tostring(L, 1)

   OnExit, %arg1%

   return 0
}

OutputDebug(L)
{
   arg1 := lua_tostring(L, 1)

   OutputDebug, %arg1%

   return 0
}

Pause(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)

   Pause, %arg1%, %arg2%, %arg3%, %arg4%

   return 0
}

PostMessage(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)
   arg6 := lua_tostring(L, 6)
   arg7 := lua_tostring(L, 7)
   arg8 := lua_tostring(L, 8)

   PostMessage, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%, %arg6%, %arg7%, %arg8%

   return 0
}

Process(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)

   Process, %arg1%, %arg2%, %arg3%

   return 0
}

Progress(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)

   if arg1 = Off
      Progress, Off
   else
      Progress, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%

   return 0
}

RegDelete(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)

   RegDelete, %arg1%, %arg2%, %arg3%

   return 0
}

RegWrite(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)

   RegWrite, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%

   return 0
}

Reload(L)
{
   Reload

   return 0
}

RunAs(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)

   RunAs, %arg1%, %arg2%, %arg3%

   return 0
}

Send(L)
{
   arg1 := lua_tostring(L, 1)

   Send %arg1%

   return 0
}

SendRaw(L)
{
   arg1 := lua_tostring(L, 1)

   SendRaw %arg1%

   return 0
}

SendInput(L)
{
   arg1 := lua_tostring(L, 1)

   SendInput %arg1%

   return 0
}

SendPlay(L)
{
   arg1 := lua_tostring(L, 1)

   SendPlay %arg1%

   return 0
}

SendMessage(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)
   arg6 := lua_tostring(L, 6)
   arg7 := lua_tostring(L, 7)
   arg8 := lua_tostring(L, 8)

   SendMessage, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%, %arg6%, %arg7%, %arg8%

   return 0
}

SendMode(L)
{
   arg1 := lua_tostring(L, 1)

   SendMode %arg1%

   return 0
}

SetBatchLines(L)
{
   arg1 := lua_tostring(L, 1)

   SetBatchLines, %arg1%

   return 0
}

SetCapslockState(L)
{
   arg1 := lua_tostring(L, 1)

   SetCapslockState, %arg1%

   return 0
}

SetControlDelay(L)
{
   arg1 := lua_tostring(L, 1)

   SetControlDelay, %arg1%

   return 0
}

SetDefaultMouseSpeed(L)
{
   arg1 := lua_tostring(L, 1)

   SetDefaultMouseSpeed, %arg1%

   return 0
}

SetEnv(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)

   SetEnv, %arg1%, %arg2%

   return 0
}

SetFormat(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)

   SetFormat, %arg1%, %arg2%

   return 0
}

SetKeyDelay(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)

   SetKeyDelay, %arg1%, %arg2%, %arg3%

   return 0
}

SetMouseDelay(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)

   SetMouseDelay, %arg1%, %arg2%

   return 0
}

SetNumlockState(L)
{
   arg1 := lua_tostring(L, 1)

   SetNumlockState, %arg1%

   return 0
}

SetScrollLockState(L)
{
   arg1 := lua_tostring(L, 1)

   SetScrollLockState, %arg1%

   return 0
}

SetStoreCapslockMode(L)
{
   arg1 := lua_tostring(L, 1)

   SetStoreCapslockMode, %arg1%

   return 0
}

SetTimer(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)

   SetTimer, %arg1%, %arg2%, %arg3%

   return 0
}

SetTitleMatchMode(L)
{
   arg1 := lua_tostring(L, 1)

   SetTitleMatchMode, %arg1%

   return 0
}

SetWinDelay(L)
{
   arg1 := lua_tostring(L, 1)

   SetWinDelay, %arg1%

   return 0
}

SetWorkingDir(L)
{
   arg1 := lua_tostring(L, 1)

   SetWorkingDir, %arg1%

   return 0
}

Shutdown(L)
{
   arg1 := lua_tostring(L, 1)

   Shutdown, %arg1%

   return 0
}

Sort(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)

   Sort, %arg1%, %arg2%

   return 0
}

SoundBeep(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)

   SoundBeep, %arg1%, %arg2%

   return 0
}

SoundPlay(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)

   SoundPlay, %arg1%, %arg2%

   return 0
}

SoundSet(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)

   SoundSet, %arg1%, %arg2%, %arg3%, %arg4%

   return 0
}

SoundSetWaveVolume(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)

   SoundSetWaveVolume, %arg1%, %arg2%

   return 0
}

SplashImage(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)
   arg5 := lua_tostring(L, 6)

   if arg1 = off
      SplashImage, off
   else
      SplashImage, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%

   return 0
}

SplashTextOn(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)

   SplashTextOn, %arg1%, %arg2%, %arg3%, %arg4%

   return 0
}

SplashTextOff(L)
{
   SplashTextOff

   return 0
}

StatusBarWait(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)
   arg6 := lua_tostring(L, 6)
   arg7 := lua_tostring(L, 7)
   arg8 := lua_tostring(L, 8)

   StatusBarWait, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%, %arg6%, %arg7%, %arg8%

   return 0
}

StringCaseSense(L)
{
   arg1 := lua_tostring(L, 1)

   StringCaseSense, %arg1%

   return 0
}

Thread(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)

   if(arg1 = Interrupt || arg1 = interrupt)
      Thread, %arg1%, %arg2%, %arg3%
   else
      Thread, %arg1%, %arg2%

   return 0
}

TrayTip(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)

   TrayTip, %arg1%, %arg2%, %arg3%, %arg4%

   return 0
}

UrlDownloadToFile(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)

   UrlDownloadToFile, %arg1%, %arg2%

   return 0
}

WinActivate(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)

   WinActivate, %arg1%, %arg2%, %arg3%, %arg4%

   return 0
}

WinActivateBottom(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)

   WinActivateBottom, %arg1%, %arg2%, %arg3%, %arg4%

   return 0
}

WinClose(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)

   WinClose, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%

   return 0
}

WinHide(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)

   WinHide, %arg1%, %arg2%, %arg3%, %arg4%

   return 0
}

WinKill(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)

   WinKill, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%

   return 0
}

WinMaximize(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)

   WinMaximize, %arg1%, %arg2%, %arg3%, %arg4%

   return 0
}

WinMenuSelectItem(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)
   arg6 := lua_tostring(L, 6)
   arg7 := lua_tostring(L, 7)
   arg8 := lua_tostring(L, 8)
   arg9 := lua_tostring(L, 9)
   arg10 := lua_tostring(L, 10)
   arg11 := lua_tostring(L, 11)

   WinMenuSelectItem, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%, %arg6%, %arg7%, %arg8%, %arg9%, %arg10%, %arg11%

   return 0
}

WinMinimize(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)

   WinMinimize, %arg1%, %arg2%, %arg3%, %arg4%

   return 0
}

WinMinimizeAll(L)
{
   WinMinimizeAll

   return 0
}

WinMinimizeAllUndo(L)
{
   WinMinimizeAllUndo

   return 0
}

WinMove(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)
   arg6 := lua_tostring(L, 6)
   arg7 := lua_tostring(L, 7)
   arg8 := lua_tostring(L, 8)

   if arg3 !=
      WinMove, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%, %arg6%, %arg7%, %arg8%
   else
      WinMove, %arg1%, %arg2%

   return 0
}

WinRestore(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)

   WinRestore, %arg1%, %arg2%, %arg3%, %arg4%

   return 0
}

WinSet(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)
   arg6 := lua_tostring(L, 6)

   WinSet, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%, %arg6%

   return 0
}

WinSetTitle(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)

   if arg2 !=
      WinSetTitle, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%
   else
      WinSetTitle, %arg1%

   return 0
}

WinShow(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)

   WinShow, %arg1%, %arg2%, %arg3%, %arg4%

   return 0
}

WinWait(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)

   WinWait, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%

   return 0
}

WinWaitActive(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)

   WinWaitActive, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%

   return 0
}

WinWaitClose(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)

   WinWaitClose, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%

   return 0
}

WinWaitNotActive(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)

   WinWaitNotActive, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%

   return 0
}



msgbox(L)
{
   Options := lua_tostring(L, 1)
   Title := lua_tostring(L, 2)
   Text := lua_tostring(L, 3)
   Timeout := lua_tostring(L, 4)

   if (Text == "")
      msgbox, %Options%
   else
   {
      if Options = 0
         msgbox, 0, %Title%, %Text%, %Timeout%

      if Options = 1
         msgbox, 1, %Title%, %Text%, %Timeout%

      if Options = 2
         msgbox, 2, %Title%, %Text%, %Timeout%

      if Options = 3
         msgbox, 3, %Title%, %Text%, %Timeout%
   }

   return 0
}

sleep(L)
{
   time := lua_tostring(L, 1)

   Sleep, %time%

   return 0
}

tooltip(L)
{
   Text := lua_tostring(L, 1)
   X := lua_tostring(L, 2)
   Y := lua_tostring(L, 3)
   WhichTooltip := lua_tostring(L, 4)

   Tooltip, %Text%, %X%, %Y%, %WhichTooltip%

   return 0
}


Gui(L)
{
   Global

   ;Gui, sub-command [, Param2, Param3, Param4]
   SubCommand := lua_tostring(L, 1)
   Param2 := lua_tostring(L, 2)
   Param3 := lua_tostring(L, 3)
   Param4 := lua_tostring(L, 4)
   ;Gui,1:default
   Gui, %SubCommand%, %Param2%, %Param3%, %Param4%

   return 0
}





ControlGet(L)
{
   Cmd := lua_tostring(L, 1)
   Value := lua_tostring(L, 2)
   Control := lua_tostring(L, 3)
   WinTitle := lua_tostring(L, 4)
   WinText := lua_tostring(L, 5)
   ExcludeTitle := lua_tostring(L, 6)
   ExcludeText := lua_tostring(L, 7)

   ControlGet, v, %Cmd%, %Value%, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%

   lua_pushstring(L, v)
   Return, 1
}

ControlGetFocus(L)
{
   WinTitle := lua_tostring(L, 1)
   WinText := lua_tostring(L, 2)
   ExcludeTitle := lua_tostring(L, 3)
   ExcludeText := lua_tostring(L, 4)

   ControlGetFocus, v, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%

   lua_pushstring(L, v)
   Return, 1
}

ControlGetText(L)
{
   Control := lua_tostring(L, 1)
   WinTitle := lua_tostring(L, 2)
   WinText := lua_tostring(L, 3)
   ExcludeTitle := lua_tostring(L, 4)
   ExcludeText := lua_tostring(L, 5)

   ControlGetText, v, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%

   lua_pushstring(L, v)
   Return, 1
}

ControlGetPos(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)
   arg5 := lua_tostring(L, 5)
   arg6 := lua_tostring(L, 6)
   arg7 := lua_tostring(L, 7)

   ControlGetPos, outX, outY, %arg1%, %arg2%, %arg3%, %arg4%, %arg5%, %arg6%, %arg7%

   lua_pushstring(L, outX)
   lua_pushstring(L, outY)
   Return, 2
}

DriveGet(L)
{
   Cmd := lua_tostring(L, 1)
   Value := lua_tostring(L, 2)

   DriveGet, v, %Cmd%, %Value%

   lua_pushstring(L, v)
   Return, 1
}

DriveSpaceFree(L)
{
   path := lua_tostring(L, 1)

   DriveSpaceFree, v, %Path%

   lua_pushinteger(L, v)
   Return, 1
}

EnvGet(L)
{
   path := lua_tostring(L, 1)

   EnvGet, v, %EnvVarName%

   lua_pushstring(L, v)
   Return, 1
}

FileGetAttrib(L)
{
   FileName := lua_tostring(L, 1)

   FileGetAttrib, v, %Filename%

   lua_pushstring(L, v)
   Return, 1
}

FileGetShortcut(L)
{
   LinkFile := lua_tostring(L, 1)

   FileGetShortcut, %LinkFile%, OutTarget, OutDir, OutArgs, OutDescription, OutIcon, OutIconNum, OutRunState

   lua_pushstring(L, OutTarget)
   lua_pushstring(L, OutDir)
   lua_pushstring(L, OutArgs)
   lua_pushstring(L, OutDescription)
   lua_pushstring(L, OutIcon)
   lua_pushinteger(L, OutIconNum)
   lua_pushstring(L, OutRunState)
   Return, 7
}

FileGetSize(L)
{
   Filename := lua_tostring(L, 1)
   Units := lua_tostring(L, 2)

   FileGetSize, v, %Filename%, %Units%

   lua_pushinteger(L, v)
   Return, 1
}

FileGetTime(L)
{
   Filename := lua_tostring(L, 1)
   WhichTime := lua_tostring(L, 2)

   FileGetTime, v, %Filename%, %WhichTime%

   lua_pushstring(L, v)
   Return, 1
}

FileGetVersion(L)
{
   Filename := lua_tostring(L, 1)

   FileGetVersion, v, %Filename%

   lua_pushstring(L, v)
   Return, 1
}

FileRead(L)
{
   Filename := lua_tostring(L, 1)
   FileRead, v, %Filename%

   lua_pushstring(L, v)
   Return, 1
}

FileReadLine(L)
{
   Filename := lua_tostring(L, 1)
   LineNum := lua_tostring(L, 2)

   FileReadLine, v, %Filename%, %LineNum%

   lua_pushstring(L, v)
   Return, 1
}

FileSelectFile(L)
{
   Options := lua_tostring(L, 1)
   RootDir := lua_tostring(L, 2)
   Prompt := lua_tostring(L, 3)
   Filter := lua_tostring(L, 4)

   FileSelectFile, v, %Options%, %RootDir%, %Prompt%, %Filter%

   lua_pushstring(L, v)
   Return, 1
}

FileSelectFolder(L)
{
   StartingFolder := lua_tostring(L, 1)
   Options := lua_tostring(L, 2)
   Prompt := lua_tostring(L, 3)

   FileSelectFolder, v, %StartingFolder%, %Options%, %Prompt%

   lua_pushstring(L, v)
   Return, 1
}

FormatTime(L)
{
   YYYYMMDDHH24MISS := lua_tostring(L, 1)
   Format := lua_tostring(L, 2)

   FormatTime, v, %YYYYMMDDHH24MISS%, %Format%

   lua_pushstring(L, v)
   Return, 1
}

GetKeyState(L)
{
   WhichKey := lua_tostring(L, 1)
   Mode := lua_tostring(L, 2)

   GetKeyState, v, %WhichKey%, %Mode%

   lua_pushstring(L, v)
   Return, 1
}

GuiControlGet(L)
{
   Subcommand := lua_tostring(L, 1)
   ControlID := lua_tostring(L, 2)
   Param4 := lua_tostring(L, 3)

   GuiControlGet, v, %Subcommand%, %ControlID%, %Param4%

   lua_pushstring(L, v)
   Return, 1
}

ImageSearch(L)
{
   x1 := lua_tostring(L, 1)
   y1 := lua_tostring(L, 2)
   x2 := lua_tostring(L, 3)
   y2 := lua_tostring(L, 4)
   ImageFile := lua_tostring(L, 5)

   ImageSearch, OutputVarX, OutputVarY, %X1%, %Y1%, %X2%, %Y2%, %ImageFile%

   lua_pushinteger(L, OutputVarX)
   lua_pushinteger(L, OutputVarY)
   Return, 2
}

IniRead(L)
{
   Filename := lua_tostring(L, 1)
   Section := lua_tostring(L, 2)
   Key := lua_tostring(L, 3)
   Default := lua_tostring(L, 4)

   IniRead, v, %Filename%, %Section%, %Key%, %Default%

   lua_pushstring(L, v)
   Return, 1
}

Input(L)
{
   Options := lua_tostring(L, 1)
   EndKeys := lua_tostring(L, 2)
   MatchList := lua_tostring(L, 3)

   Input, v, %Options%, %EndKeys%, %MatchList%

   lua_pushstring(L, v)
   Return, 1
}

InputBox(L)
{
   Title := lua_tostring(L, 1)
   Prompt := lua_tostring(L, 2)
   HIDE := lua_tostring(L, 3)
   Width := lua_tostring(L, 4)
   Height := lua_tostring(L, 5)
   X := lua_tostring(L, 6)
   Y := lua_tostring(L, 7)
   Font := lua_tostring(L, 8)
   Timeout := lua_tostring(L, 9)
   Default := lua_tostring(L, 10)

   InputBox, v, %Title%, %Prompt%, %HIDE%, %Width%, %Height%, %X%, %Y%, , %Timeout%, %Default%

   lua_pushstring(L, v)
   Return, 1
}

MouseGetPos(L)
{
   Mode := lua_tostring(L, 1)

   MouseGetPos, OutputVarX, OutputVarY, OutputVarWin, OutputVarControl, %Mode%

   lua_pushinteger(L, OutputVarX)
   lua_pushinteger(L, OutputVarY)
   lua_pushstring(L, OutputVarWin)
   lua_pushstring(L, OutputVarControl)
   Return, 4
}

PixelGetColor(L)
{
   X := lua_tostring(L, 1)
   Y := lua_tostring(L, 2)
   RGB := lua_tostring(L, 3)

   PixelGetColor, v, %X%, %Y%, %RGB%

   lua_pushstring(L, v)
   Return, 1
}

PixelSearch(L)
{
   x1 := lua_tostring(L, 1)
   y1 := lua_tostring(L, 2)
   x2 := lua_tostring(L, 3)
   y2 := lua_tostring(L, 4)
   ColorID := lua_tostring(L, 5)
   Variation := lua_tostring(L, 6)
   Mode := lua_tostring(L, 7)

   PixelSearch, OutputVarX, OutputVarY, %X1%, %Y1%, %X2%, %Y2%, %ColorID%, %Variation%, %Mode%

   lua_pushinteger(L, OutputVarX)
   lua_pushinteger(L, OutputVarY)
   Return, 2
}

Random(L) {
   min := lua_tonumber(L, 1)
   max := lua_tonumber(L, 2)

   Random, v, %Min%, %Max%

   ; push the average
   lua_pushnumber(L, v)

   Return, 1
}

RegRead(L)
{
   RootKey := lua_tostring(L, 1)
   SubKey := lua_tostring(L, 2)
   ValueName := lua_tostring(L, 3)

   RegRead, v, %RootKey%, %SubKey%, %ValueName%

   lua_pushstring(L, v)
   Return, 1
}

Run(L)
{
   Target := lua_tostring(L, 1)
   WorkingDir := lua_tostring(L, 2)
   Mode := lua_tostring(L, 3)

   Run, %Target%, %WorkingDir%, %Mode%, %v%

   lua_pushstring(L, v)
   Return, 1
}

RunWait(L)
{
   Target := lua_tostring(L, 1)
   WorkingDir := lua_tostring(L, 2)
   Mode := lua_tostring(L, 3)

   RunWait, %Target%, %WorkingDir%, %Mode%, v

   lua_pushstring(L, v)
   Return, 1
}

SoundGet(L)
{
   ComponentType := lua_tostring(L, 1)
   ControlType := lua_tostring(L, 2)
   DeviceNumber := lua_tostring(L, 3)

   SoundGet, v, %ComponentType%, %ControlType%, %DeviceNumber%

   lua_pushstring(L, v)
   Return, 1
}

SoundGetWaveVolume(L)
{
   DeviceNumber := lua_tostring(L, 1)

   SoundGetWaveVolume, v, %DeviceNumber%

   lua_pushstring(L, v)
   Return, 1
}

StatusBarGetText(L)
{
   Part := lua_tostring(L, 1)
   WinTitle := lua_tostring(L, 2)
   WinText := lua_tostring(L, 3)
   ExcludeTitle := lua_tostring(L, 4)
   ExcludeText := lua_tostring(L, 5)

   StatusBarGetText, v, %Part%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%

   lua_pushstring(L, v)
   Return, 1
}

SplitPath(L)
{
   InputVar := lua_tostring(L, 1)

   SplitPath, InputVar, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive

   lua_pushstring(L, OutFileName)
   lua_pushstring(L, OutDir)
   lua_pushstring(L, OutExtension)
   lua_pushstring(L, OutNameNoExt)
   lua_pushstring(L, OutDrive)
   Return, 1
}

StringGetPos(L)
{
   InputVar := lua_tostring(L, 1)
   SearchText := lua_tostring(L, 2)
   Mode := lua_tostring(L, 3)
   Offset := lua_tostring(L, 4)

   StringGetPos, v, %InputVar%, %SearchText%, %Mode%, %Offset%

   lua_pushstring(L, v)
   Return, 1
}

StringLeft(L)
{
   InputVar := lua_tostring(L, 1)
   Count := lua_tostring(L, 2)

   StringLeft, v, %InputVar%, %Count%

   lua_pushstring(L, v)
   Return, 1
}

StringLen(L)
{
   InputVar := lua_tostring(L, 1)

   StringLen, v, %InputVar%

   lua_pushstring(L, v)
   Return, 1
}

StringLower(L)
{
   InputVar := lua_tostring(L, 1)
   T := lua_tostring(L, 2)

   StringLower, v, %InputVar%, %T%

   lua_pushstring(L, v)
   Return, 1
}

StringMid(L)
{
   InputVar := lua_tostring(L, 1)
   StartChar := lua_tostring(L, 2)
   Count := lua_tostring(L, 3)
   K := lua_tostring(L, 4)

   StringMid, v, %InputVar%, %StartChar%, %Count%, %K%

   lua_pushstring(L, v)
   Return, 1
}

StringReplace(L)
{
   InputVar := lua_tostring(L, 1)
   SearchText := lua_tostring(L, 2)
   ReplaceText := lua_tostring(L, 3)
   All := lua_tostring(L, 4)

   StringReplace, v, %InputVar%, %SearchText%, %ReplaceText%, %All%

   lua_pushstring(L, v)
   Return, 1
}

StringRight(L)
{
   InputVar := lua_tostring(L, 1)
   Count := lua_tostring(L, 2)

   StringRight, v, %InputVar%, %Count%

   lua_pushstring(L, v)
   Return, 1
}

StringTrimLeft(L)
{
   InputVar := lua_tostring(L, 1)
   Count := lua_tostring(L, 2)

   StringTrimLeft, v, %InputVar%, %Count%

   lua_pushstring(L, v)
   Return, 1
}

StringTrimRight(L)
{
   InputVar := lua_tostring(L, 1)
   Count := lua_tostring(L, 2)

   StringTrimRight, v, %InputVar%, %Count%

   lua_pushstring(L, v)
   Return, 1
}

StringUpper(L)
{
   InputVar := lua_tostring(L, 1)
   T := lua_tostring(L, 2)

   StringUpper, v, %InputVar%, %T%

   lua_pushstring(L, v)
   Return, 1
}

SysGet(L)
{
   Subcommand := lua_tostring(L, 1)
   Param3 := lua_tostring(L, 2)

   SysGet, v, %Subcommand%, %Param3%

   lua_pushstring(L, v)
   Return, 1
}

Transform(L)
{
   Cmd := lua_tostring(L, 1)
   Value1 := lua_tostring(L, 2)
   Value2 := lua_tostring(L, 3)

   Transform, v, %Cmd%, %Value1%, %Value2%

   lua_pushstring(L, v)
   Return, 1
}

WinGet(L)
{
   Cmd := lua_tostring(L, 1)
   WinTitle := lua_tostring(L, 2)
   WinText := lua_tostring(L, 3)
   ExcludeTitle := lua_tostring(L, 4)
   ExcludeText := lua_tostring(L, 5)

   WinGet, v, %Cmd%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%

   lua_pushstring(L, v)
   Return, 1
}

WinGetActiveTitle(L)
{
   WinGetActiveTitle, v

   lua_pushstring(L, v)
   Return, 1
}

WinGetActiveStats(L)
{
   WinGetActiveStats, a, b, c, d, e

   lua_pushstring(L, a)
   lua_pushstring(L, b)
   lua_pushstring(L, c)
   lua_pushstring(L, d)
   lua_pushstring(L, e)

   return 5
}

WinGetPos(L)
{
   arg1 := lua_tostring(L, 1)
   arg2 := lua_tostring(L, 2)
   arg3 := lua_tostring(L, 3)
   arg4 := lua_tostring(L, 4)

   WinGetPos, x, y, w, h, %arg1%, %arg2%, %arg3%, %arg4%

   lua_pushstring(L, x)
   lua_pushstring(L, y)
   lua_pushstring(L, w)
   lua_pushstring(L, h)
   return 4
}


WinGetClass(L)
{
   WinTitle := lua_tostring(L, 1)
   WinText := lua_tostring(L, 2)
   ExcludeTitle := lua_tostring(L, 3)
   ExcludeText := lua_tostring(L, 4)

   WinGetClass, v, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%

   lua_pushstring(L, v)
   Return, 1
}

WinGetText(L)
{
   WinTitle := lua_tostring(L, 1)
   WinText := lua_tostring(L, 2)
   ExcludeTitle := lua_tostring(L, 3)
   ExcludeText := lua_tostring(L, 4)

   WinGetText, v, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%

   lua_pushstring(L, v)
   Return, 1
}

WinGetTitle(L)
{
   WinTitle := lua_tostring(L, 1)
   WinText := lua_tostring(L, 2)
   ExcludeTitle := lua_tostring(L, 3)
   ExcludeText := lua_tostring(L, 4)

   WinGetTitle, v, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%

   lua_pushstring(L, v)
   Return, 1
}


ahkFunction(L)
{
   Global
   local n, Function, arg, res


   n := lua_gettop(L)

   Function := lua_tostring(L, 1)

   loop, %n%
   {
      if A_Index = 1
         continue

      arg%A_Index% := lua_tostring(L,A_Index)
   }

   if(IsFunc(Function))
   {
      if(n==1)
         res := %Function%()
      if(n==2)
         res := %Function%(arg2)
      if(n==3)
         res := %Function%(arg2,arg3)
      if(n==4)
         res := %Function%(arg2,arg3,arg4)
      if(n==5)
         res := %Function%(arg2,arg3,arg4,arg5)
      if(n==6)
         res := %Function%(arg2,arg3,arg4,arg5,arg6)
      if(n==7)
         res := %Function%(arg2,arg3,arg4,arg5,arg6,arg7)
      if(n==8)
         res := %Function%(arg2,arg3,arg4,arg5,arg6,arg7,arg8)
      if(n==9)
         res := %Function%(arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9)
      if(n==10)
         res := %Function%(arg2,arg3,arg4,arg5,arg6,arg7,arg9,arg10)
      if(n==11)
         res := %Function%(arg2,arg3,arg4,arg5,arg6,arg7,arg9,arg10,arg11)
      if(n==12)
         res := %Function%(arg2,arg3,arg4,arg5,arg6,arg7,arg9,arg10,arg11,arg12)
      if(n==13)
         res := %Function%(arg2,arg3,arg4,arg5,arg6,arg7,arg9,arg10,arg11,arg12,arg13)

   }

   lua_pushstring(L, res)
   Return, 1
}

ahkGetVar(L)
{
   varName := lua_tostring(L, 1)

   res := %varName%
   lua_pushstring(L, res)
   Return, 1
}