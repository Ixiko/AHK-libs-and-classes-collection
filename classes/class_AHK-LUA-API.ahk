/*
	AHK-LUA-API

	MIT License

	Copyright (c) 2018 Rinat_Namazov

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
*/

global LUAJIT_MODE_ENGINE		:= 0	; Set mode for whole JIT engine.
global LUAJIT_MODE_DEBUG		:= 1	; Set debug mode (idx = level).
global LUAJIT_MODE_FUNC			:= 2	; Change mode for a function.
global LUAJIT_MODE_ALLFUNC		:= 3	; Recurse into subroutine protos.
global LUAJIT_MODE_ALLSUBFUNC	:= 4	; Change only the subroutines.
global LUAJIT_MODE_TRACE		:= 5	; Flush a compiled trace.
global LUAJIT_MODE_WRAPCFUNC	:= 0x10 ; Set wrapper mode for C function calls.
global LUAJIT_MODE_MAX
global LUA_TNONE				:= -1
global LUA_TNIL					:= 0
global LUA_TBOOLEAN				:= 1
global LUA_TLIGHTUSERDATA		:= 2
global LUA_TNUMBER				:= 3
global LUA_TSTRING				:= 4
global LUA_TTABLE				:= 5
global LUA_TFUNCTION			:= 6
global LUA_TUSERDATA			:= 7
global LUA_TTHREAD				:= 8
global LUA_REGISTRYINDEX		:= -10000
global LUA_ENVIRONINDEX			:= -10001
global LUA_GLOBALSINDEX			:= -10002
global BUFSIZ					:= 512
global LUAL_BUFFERSIZE			:= (BUFSIZ > 16384 ? 8192 : BUFSIZ)
global LUA_GCSTOP				:= 0
global LUA_GCRESTART			:= 1
global LUA_GCCOLLECT			:= 2
global LUA_GCCOUNT				:= 3
global LUA_GCCOUNTB				:= 4
global LUA_GCSTEP				:= 5
global LUA_GCSETPAUSE			:= 6
global LUA_GCSETSTEPMUL			:= 7

lua_pop(ByRef L, n)
{
	lua_settop(L, -n - 1)
}

lua_newtable(ByRef L)
{
	return lua_createtable(L, 0, 0)
}

lua_register(ByRef L, n, f)
{
	if f is not integer
		f := RegisterCallback(f, "CDecl")
	lua_pushcfunction(L, f)
	lua_setglobal(L, n)
}

lua_pushcfunction(ByRef L, f)
{
	return lua_pushcclosure(L, f, 0)
}

lua_strlen(ByRef L, i)
{
	return lua_objlen(L, i)
}

lua_isfunction(ByRef L, n)
{
	return (lua_type(L, n) == LUA_TFUNCTION)
}

lua_istable(ByRef L, n)
{
	return (lua_type(L, n) == LUA_TTABLE)
}

lua_islightuserdata(ByRef L, n)
{
	return (lua_type(L, n) == LUA_TLIGHTUSERDATA)
}

lua_isnil(ByRef L, n)
{
	return (lua_type(L, n) == LUA_TNIL)
}

lua_isboolean(ByRef  L, n)
{
	return (lua_type(L, n) == LUA_TBOOLEAN)
}

lua_isthread(ByRef  L, n)
{
	return (lua_type(L, n) == LUA_TTHREAD)
}

lua_isnone(ByRef L, n)
{
	return (lua_type(L, n) == LUA_TNONE)
}

lua_isnoneornil(ByRef L, n)
{
	return (lua_type(L, n) <= 0)
}

lua_pushliteral(ByRef L, s)
{
	return lua_pushlstring(L, s, strlen(s))
}

lua_setglobal(ByRef L, s)
{
	return lua_setfield(L, LUA_GLOBALSINDEX, s)
}

lua_getglobal(ByRef L, s)
{
	return lua_getfield(L, LUA_GLOBALSINDEX, s)
}

lua_tostring(ByRef L, i)
{
	return lua_tolstring(L, i, 0)
}

lua_open()
{
	return luaL_newstate()
}

lua_getregistry(ByRef L)
{
	return lua_pushvalue(L, LUA_REGISTRYINDEX)
}

lua_getgccount(ByRef L)
{
	return lua_gc(L, LUA_GCCOUNT, 0)
}

lua_upvalueindex(i)
{
	return LUA_GLOBALSINDEX - i
}

luaL_fileresult(ByRef L, stat, ByRef fname)
{
	return DllCall("lua51.dll\luaL_fileresult", "Ptr", L, "Int", stat, "Str", fname, "CDecl Int")
}

luaL_execresult(ByRef L, stat)
{
	return DllCall("lua51.dll\luaL_execresult", "Ptr", L, "Int", stat, "CDecl Int")
}

luaL_findtable(ByRef L, idx, ByRef fname, szhint)
{
	return DllCall("lua51.dll\luaL_findtable", "Ptr", L, "Int", idx, "Str", fname, "Int", szhint, "CDecl Str")
}

luaL_openlib(ByRef L, ByRef libname, ByRef l2, nup)
{
	return DllCall("lua51.dll\luaL_openlib", "Ptr", L, "Str", libname, "UInt", l2, "Int", nup, "CDecl")
}

luaL_register(ByRef L, ByRef libname, ByRef l2)
{
	return DllCall("lua51.dll\luaL_register", "Ptr", L, "Str", libname, "UInt", l2, "CDecl")
}

luaL_gsub(ByRef L, ByRef s, ByRef p, ByRef r)
{
	return DllCall("lua51.dll\luaL_gsub", "Ptr", L, "Str", s, "Str", p, "Str", r, "CDecl Str")
}

luaL_prepbuffer(ByRef B)
{
	return DllCall("lua51.dll\luaL_prepbuffer", "UInt", B, "CDecl UInt")
}

luaL_addlstring(ByRef B, ByRef s, l2)
{
	return DllCall("lua51.dll\luaL_addlstring", "UInt", B, "Str", s, "Int", l2, "CDecl")
}

luaL_addstring(ByRef B, ByRef s)
{
	return DllCall("lua51.dll\luaL_addstring", "UInt", B, "Str", s, "CDecl")
}

luaL_pushresult(ByRef B)
{
	return DllCall("lua51.dll\luaL_pushresult", "UInt", B, "CDecl")
}

luaL_addvalue(ByRef B)
{
	return DllCall("lua51.dll\luaL_addvalue", "UInt", B, "CDecl")
}

luaL_buffinit(ByRef L, ByRef B)
{
	return DllCall("lua51.dll\luaL_buffinit", "Ptr", L, "UInt", B, "CDecl")
}

luaL_ref(ByRef L, t)
{
	return DllCall("lua51.dll\luaL_ref", "Ptr", L, "Int", t, "CDecl Int")
}

luaL_unref(ByRef L, t, ref)
{
	return DllCall("lua51.dll\luaL_unref", "Ptr", L, "Int", t, "Int", ref, "CDecl")
}

luaL_newstate()
{
	return DllCall("lua51.dll\luaL_newstate", "CDecl Ptr")
}

lua_newstate(f, ByRef ud)
{
	return DllCall("lua51.dll\lua_newstate", "UInt", f, "UInt", ud, "CDecl Ptr")
}

luaopen_base(ByRef L)
{
	return DllCall("lua51.dll\luaopen_base", "Ptr", L, "CDecl Int")
}

luaopen_bit(ByRef L)
{
	return DllCall("lua51.dll\luaopen_bit", "Ptr", L, "CDecl Int")
}

luaopen_debug(ByRef L)
{
	return DllCall("lua51.dll\luaopen_debug", "Ptr", L, "CDecl Int")
}

luaopen_ffi(ByRef L)
{
	return DllCall("lua51.dll\luaopen_ffi", "Ptr", L, "CDecl Int")
}

luaL_openlibs(ByRef L)
{
	return DllCall("lua51.dll\luaL_openlibs", "Ptr", L, "CDecl")
}

luaopen_io(ByRef L)
{
	return DllCall("lua51.dll\luaopen_io", "Ptr", L, "CDecl Int")
}

luaopen_jit(ByRef L)
{
	return DllCall("lua51.dll\luaopen_jit", "Ptr", L, "CDecl Int")
}

luaopen_math(ByRef L)
{
	return DllCall("lua51.dll\luaopen_math", "Ptr", L, "CDecl Int")
}

luaopen_os(ByRef L)
{
	return DllCall("lua51.dll\luaopen_os", "Ptr", L, "CDecl Int")
}

luaopen_package(ByRef L)
{
	return DllCall("lua51.dll\luaopen_package", "Ptr", L, "CDecl Int")
}

luaopen_string(ByRef L)
{
	return DllCall("lua51.dll\luaopen_string", "Ptr", L, "CDecl Int")
}

luaopen_table(ByRef L)
{
	return DllCall("lua51.dll\luaopen_table", "Ptr", L, "CDecl Int")
}

lua_status(ByRef L)
{
	return DllCall("lua51.dll\lua_status", "Ptr", L, "CDecl Int")
}

lua_checkstack(ByRef L, size)
{
	return DllCall("lua51.dll\lua_checkstack", "Ptr", L, "Int", size, "CDecl Int")
}

luaL_checkstack(ByRef L, size, ByRef msg)
{
	return DllCall("lua51.dll\luaL_checkstack", "Ptr", L, "Int", size, "Str", msg, "CDecl")
}

lua_xmove(ByRef from, ByRef to, n)
{
	return DllCall("lua51.dll\lua_xmove", "Ptr", from, "Ptr", to, "Int", n, "CDecl")
}

lua_gettop(ByRef L)
{
	return DllCall("lua51.dll\lua_gettop", "Ptr", L, "CDecl Int")
}

lua_settop(ByRef L, idx)
{
	return DllCall("lua51.dll\lua_settop", "Ptr", L, "Int", idx, "CDecl")
}

lua_remove(ByRef L, idx)
{
	return DllCall("lua51.dll\lua_remove", "Ptr", L, "Int", idx, "CDecl")
}

lua_insert(ByRef L, idx)
{
	return DllCall("lua51.dll\lua_insert", "Ptr", L, "Int", idx, "CDecl")
}

lua_replace(ByRef L, idx)
{
	return DllCall("lua51.dll\lua_replace", "Ptr", L, "Int", idx, "CDecl")
}

lua_pushvalue(ByRef L, idx)
{
	return DllCall("lua51.dll\lua_pushvalue", "Ptr", L, "Int", idx, "CDecl")
}

lua_type(ByRef L, idx)
{
	return DllCall("lua51.dll\lua_type", "Ptr", L, "Int", idx, "CDecl Int")
}

luaL_checktype(ByRef L, idx, tt)
{
	return DllCall("lua51.dll\luaL_checktype", "Ptr", L, "Int", idx, "Int", tt, "CDecl")
}

luaL_checkany(ByRef L, idx)
{
	return DllCall("lua51.dll\luaL_checkany", "Ptr", L, "Int", idx, "CDecl")
}

lua_typename(ByRef L, t)
{
	return DllCall("lua51.dll\lua_typename", "Ptr", L, "Int", t, "CDecl Str")
}

lua_iscfunction(ByRef L, idx)
{
	return DllCall("lua51.dll\lua_iscfunction", "Ptr", L, "Int", idx, "CDecl Int")
}

lua_isnumber(ByRef L, idx)
{
	return DllCall("lua51.dll\lua_isnumber", "Ptr", L, "Int", idx, "CDecl Int")
}

lua_isstring(ByRef L, idx)
{
	return DllCall("lua51.dll\lua_isstring", "Ptr", L, "Int", idx, "CDecl Int")
}

lua_isuserdata(ByRef L, idx)
{
	return DllCall("lua51.dll\lua_isuserdata", "Ptr", L, "Int", idx, "CDecl Int")
}

lua_rawequal(ByRef L, idx1, idx2)
{
	return DllCall("lua51.dll\lua_rawequal", "Ptr", L, "Int", idx1, "Int", idx2, "CDecl Int")
}

lua_equal(ByRef L, idx1, idx2)
{
	return DllCall("lua51.dll\lua_equal", "Ptr", L, "Int", idx1, "Int", idx2, "CDecl Int")
}

lua_lessthan(ByRef L, idx1, idx2)
{
	return DllCall("lua51.dll\lua_lessthan", "Ptr", L, "Int", idx1, "Int", idx2, "CDecl Int")
}

lua_tonumber(ByRef L, idx)
{
	return DllCall("lua51.dll\lua_tonumber", "Ptr", L, "Int", idx, "CDecl Double")
}

luaL_checknumber(ByRef L, idx)
{
	return DllCall("lua51.dll\luaL_checknumber", "Ptr", L, "Int", idx, "CDecl Double")
}

luaL_optnumber(ByRef L, idx, def)
{
	return DllCall("lua51.dll\luaL_optnumber", "Ptr", L, "Int", idx, "Double", def, "CDecl Double")
}

lua_tointeger(ByRef L, idx)
{
	return DllCall("lua51.dll\lua_tointeger", "Ptr", L, "Int", idx, "CDecl Int")
}

luaL_checkinteger(ByRef L, idx)
{
	return DllCall("lua51.dll\luaL_checkinteger", "Ptr", L, "Int", idx, "CDecl Int")
}

luaL_optinteger(ByRef L, idx, def)
{
	return DllCall("lua51.dll\luaL_optinteger", "Ptr", L, "Int", idx, "Int", def, "CDecl Int")
}

lua_toboolean(ByRef L, idx)
{
	return DllCall("lua51.dll\lua_toboolean", "Ptr", L, "Int", idx, "CDecl Int")
}

lua_tolstring(ByRef L, idx, ByRef len)
{
	return DllCall("lua51.dll\lua_tolstring", "Ptr", L, "Int", idx, "Int", len, "CDecl Str")
}

luaL_checklstring(ByRef L, idx, ByRef len)
{
	return DllCall("lua51.dll\luaL_checklstring", "Ptr", L, "Int", idx, "Int", len, "CDecl Str")
}

luaL_optlstring(ByRef L, idx, ByRef def, ByRef len)
{
	return DllCall("lua51.dll\luaL_optlstring", "Ptr", L, "Int", idx, "Str", def, "Int", len, "CDecl Str")
}

luaL_checkoption(ByRef L, idx, ByRef def, ByRef const)
{
	return DllCall("lua51.dll\luaL_checkoption", "Ptr", L, "Int", idx, "Str", def, "Str", const, "CDecl Int")
}

lua_objlen(ByRef L, idx)
{
	return DllCall("lua51.dll\lua_objlen", "Ptr", L, "Int", idx, "CDecl Int")
}

lua_tocfunction(ByRef L, idx)
{
	return DllCall("lua51.dll\lua_tocfunction", "Ptr", L, "Int", idx, "CDecl UInt")
}

lua_touserdata(ByRef L, idx)
{
	return DllCall("lua51.dll\lua_touserdata", "Ptr", L, "Int", idx, "CDecl")
}

lua_tothread(ByRef L, idx)
{
	return DllCall("lua51.dll\lua_tothread", "Ptr", L, "Int", idx, "CDecl Ptr")
}

lua_topointer(ByRef L, idx)
{
	return DllCall("lua51.dll\lua_topointer", "Ptr", L, "Int", idx, "CDecl UInt")
}

lua_pushnil(ByRef L)
{
	return DllCall("lua51.dll\lua_pushnil", "Ptr", L, "CDecl")
}

lua_pushnumber(ByRef L, n)
{
	return DllCall("lua51.dll\lua_pushnumber", "Ptr", L, "Double", n, "CDecl")
}

lua_pushinteger(ByRef L, n)
{
	return DllCall("lua51.dll\lua_pushinteger", "Ptr", L, "Int", n, "CDecl")
}

lua_pushlstring(ByRef L, ByRef str, len)
{
	return DllCall("lua51.dll\lua_pushlstring", "Ptr", L, "Str", str, "Int", len, "CDecl")
}

lua_pushstring(ByRef L, ByRef str)
{
	return DllCall("lua51.dll\lua_pushstring", "Ptr", L, "Str", str, "CDecl")
}

lua_pushvfstring(ByRef L, ByRef fmt)
{
	return DllCall("lua51.dll\lua_pushvfstring", "Ptr", L, "Str", fmt, "CDecl Str")
}

lua_pushfstring(ByRef L, ByRef fmt)
{
	return DllCall("lua51.dll\lua_pushfstring", "Ptr", L, "Str", fmt, "CDecl Str")
}

lua_pushcclosure(ByRef L, f, n)
{
	return DllCall("lua51.dll\lua_pushcclosure", "Ptr", L, "UInt", f, "Int", n, "CDecl")
}

lua_pushboolean(ByRef L, b)
{
	return DllCall("lua51.dll\lua_pushboolean", "Ptr", L, "Int", b, "CDecl")
}

lua_pushlightuserdata(ByRef L, ByRef p)
{
	return DllCall("lua51.dll\lua_pushlightuserdata", "Ptr", L, "UInt", p, "CDecl")
}

lua_createtable(ByRef L, narray, nrec)
{
	return DllCall("lua51.dll\lua_createtable", "Ptr", L, "Int", narray, "Int", nrec, "CDecl")
}

luaL_newmetatable(ByRef L, ByRef tname)
{
	return DllCall("lua51.dll\luaL_newmetatable", "Ptr", L, "Str", tname, "CDecl Int")
}

lua_pushthread(ByRef L)
{
	return DllCall("lua51.dll\lua_pushthread", "Ptr", L, "CDecl Int")
}

lua_newthread(ByRef L)
{
	return DllCall("lua51.dll\lua_newthread", "Ptr", L, "CDecl Ptr")
}

lua_newuserdata(ByRef L, size)
{
	return DllCall("lua51.dll\lua_newuserdata", "Ptr", L, "Int", size, "CDecl")
}

lua_concat(ByRef L, n)
{
	return DllCall("lua51.dll\lua_concat", "Ptr", L, "Int", n, "CDecl")
}

lua_gettable(ByRef L, idx)
{
	return DllCall("lua51.dll\lua_gettable", "Ptr", L, "Int", idx, "CDecl")
}

lua_getfield(ByRef L, idx, ByRef k)
{
	return DllCall("lua51.dll\lua_getfield", "Ptr", L, "Int", idx, "Str", k, "CDecl")
}

lua_rawget(ByRef L, idx)
{
	return DllCall("lua51.dll\lua_rawget", "Ptr", L, "Int", idx, "CDecl")
}

lua_rawgeti(ByRef L, idx, n)
{
	return DllCall("lua51.dll\lua_rawgeti", "Ptr", L, "Int", idx, "Int", n, "CDecl")
}

lua_getmetatable(ByRef L, idx)
{
	return DllCall("lua51.dll\lua_getmetatable", "Ptr", L, "Int", idx, "CDecl Int")
}

luaL_getmetafield(ByRef L, idx, ByRef field)
{
	return DllCall("lua51.dll\luaL_getmetafield", "Ptr", L, "Int", idx, "Str", field, "CDecl Int")
}

lua_getfenv(ByRef L, idx)
{
	return DllCall("lua51.dll\lua_getfenv", "Ptr", L, "Int", idx, "CDecl")
}

lua_next(ByRef L, idx)
{
	return DllCall("lua51.dll\lua_next", "Ptr", L, "Int", idx, "CDecl Int")
}

lua_getupvalue(ByRef L, idx, n)
{
	return DllCall("lua51.dll\lua_getupvalue", "Ptr", L, "Int", idx, "Int", n, "CDecl Str")
}

lua_upvalueid(ByRef L, idx, n)
{
	return DllCall("lua51.dll\lua_upvalueid", "Ptr", L, "Int", idx, "Int", n, "CDecl")
}

lua_upvaluejoin(ByRef L, idx1, n1, idx2, n2)
{
	return DllCall("lua51.dll\lua_upvaluejoin", "Ptr", L, "Int", idx1, "Int", n1, "Int", idx2, "Int", n2, "CDecl")
}

luaL_checkudata(ByRef L, idx, ByRef tname)
{
	return DllCall("lua51.dll\luaL_checkudata", "Ptr", L, "Int", idx, "Str", tname, "CDecl")
}

lua_settable(ByRef L, idx)
{
	return DllCall("lua51.dll\lua_settable", "Ptr", L, "Int", idx, "CDecl")
}

lua_setfield(ByRef L, idx, ByRef k)
{
	return DllCall("lua51.dll\lua_setfield", "Ptr", L, "Int", idx, "Str", k, "CDecl")
}

lua_rawset(ByRef L, idx)
{
	return DllCall("lua51.dll\lua_rawset", "Ptr", L, "Int", idx, "CDecl")
}

lua_rawseti(ByRef L, idx, n)
{
	return DllCall("lua51.dll\lua_rawseti", "Ptr", L, "Int", idx, "Int", n, "CDecl")
}

lua_setmetatable(ByRef L, idx)
{
	return DllCall("lua51.dll\lua_setmetatable", "Ptr", L, "Int", idx, "CDecl Int")
}

lua_setfenv(ByRef L, idx)
{
	return DllCall("lua51.dll\lua_setfenv", "Ptr", L, "Int", idx, "CDecl Int")
}

lua_setupvalue(ByRef L, idx, n)
{
	return DllCall("lua51.dll\lua_setupvalue", "Ptr", L, "Int", idx, "Int", n, "CDecl Str")
}

lua_call(ByRef L, nargs, nresults)
{
	return DllCall("lua51.dll\lua_call", "Ptr", L, "Int", nargs, "Int", nresults, "CDecl")
}

lua_pcall(ByRef L, nargs, nresults, errfunc)
{
	return DllCall("lua51.dll\lua_pcall", "Ptr", L, "Int", nargs, "Int", nresults, "Int", errfunc, "CDecl Int")
}

lua_cpcall(ByRef L, func, ByRef ud)
{
	return DllCall("lua51.dll\lua_cpcall", "Ptr", L, "UInt", func, "UInt", ud, "CDecl Int")
}

luaL_callmeta(ByRef L, idx, ByRef field)
{
	return DllCall("lua51.dll\luaL_callmeta", "Ptr", L, "Int", idx, "Str", field, "CDecl Int")
}

lua_yield(ByRef L, nresults)
{
	return DllCall("lua51.dll\lua_yield", "Ptr", L, "Int", nresults, "CDecl Int")
}

lua_resume(ByRef L, nargs)
{
	return DllCall("lua51.dll\lua_resume", "Ptr", L, "Int", nargs, "CDecl Int")
}

lua_gc(ByRef L, what, data)
{
	return DllCall("lua51.dll\lua_gc", "Ptr", L, "Int", what, "Int", data, "CDecl Int")
}

lua_getallocf(ByRef L, ud)
{
	return DllCall("lua51.dll\lua_getallocf", "Ptr", L, "UInt", ud, "CDecl UInt")
}

lua_setallocf(ByRef L, f, ByRef ud)
{
	return DllCall("lua51.dll\lua_setallocf", "Ptr", L, "UInt", f, "UInt", ud, "CDecl")
}

lua_getlocal(ByRef L, ByRef ar, n)
{
	return DllCall("lua51.dll\lua_getlocal", "Ptr", L, "UInt", ar, "Int", n, "CDecl Str")
}

lua_setlocal(ByRef L, ByRef ar, n)
{
	return DllCall("lua51.dll\lua_setlocal", "Ptr", L, "UInt", ar, "Int", n, "CDecl Str")
}

lua_getinfo(ByRef L, ByRef what, ByRef ar)
{
	return DllCall("lua51.dll\lua_getinfo", "Ptr", L, "Str", what, "UInt", ar, "CDecl Int")
}

lua_getstack(ByRef L, level, ByRef ar)
{
	return DllCall("lua51.dll\lua_getstack", "Ptr", L, "Int", level, "UInt", ar, "CDecl Int")
}

lua_sethook(ByRef L, func, mask, count)
{
	return DllCall("lua51.dll\lua_sethook", "Ptr", L, "UInt", func, "Int", mask, "Int", count, "CDecl Int")
}

lua_gethook(ByRef L)
{
	return DllCall("lua51.dll\lua_gethook", "Ptr", L, "CDecl UInt")
}

lua_gethookmask(ByRef L)
{
	return DllCall("lua51.dll\lua_gethookmask", "Ptr", L, "CDecl Int")
}

lua_gethookcount(ByRef L)
{
	return DllCall("lua51.dll\lua_gethookcount", "Ptr", L, "CDecl Int")
}

lua_atpanic(ByRef L, panicf)
{
	return DllCall("lua51.dll\lua_atpanic", "Ptr", L, "UInt", panicf, "CDecl UInt")
}

luaL_dofile(ByRef L, fn)
{
	luaL_loadfile(L, fn)
	return lua_pCall(l, 0, -1, 0)
}

luaL_dostring(ByRef L, ByRef s)
{
	luaL_loadstring(L, s)
	return lua_pCall(L, 0, -1, 0)
}

lua_error(ByRef L)
{
	return DllCall("lua51.dll\lua_error", "Ptr", L, "CDecl Int")
}

luaL_argerror(ByRef L, narg, ByRef msg)
{
	return DllCall("lua51.dll\luaL_argerror", "Ptr", L, "Int", narg, "Str", msg, "CDecl Int")
}

luaL_typerror(ByRef L, narg, ByRef xname)
{
	return DllCall("lua51.dll\luaL_typerror", "Ptr", L, "Int", narg, "Str", xname, "CDecl Int")
}

luaL_where(ByRef L, level)
{
	return DllCall("lua51.dll\luaL_where", "Ptr", L, "Int", level, "CDecl")
}

luaL_error(ByRef L, ByRef fmt)
{
	return DllCall("lua51.dll\luaL_error", "Ptr", L, "Str", fmt, "CDecl Int")
}

lua_loadx(ByRef L, reader, ByRef data, ByRef chunkname, ByRef mode)
{
	return DllCall("lua51.dll\lua_loadx", "Ptr", L, "UInt", reader, "UInt", data, "Str", chunkname, "Str", mode, "CDecl Int")
}

lua_load(ByRef L, reader, ByRef data, ByRef chunkname)
{
	return DllCall("lua51.dll\lua_load", "Ptr", L, "UInt", reader, "UInt", data, "Str", chunkname, "CDecl Int")
}

luaL_loadfilex(ByRef L, ByRef filename, ByRef mode)
{
	return DllCall("lua51.dll\luaL_loadfilex", "Ptr", L, "Str", filename, "Str", mode, "CDecl Int")
}

luaL_loadfile(ByRef L, ByRef filename)
{
	return DllCall("lua51.dll\luaL_loadfile", "Ptr", L, "Str", filename, "CDecl Int")
}

luaL_loadbufferx(ByRef L, ByRef buf, size, ByRef name, ByRef mode)
{
	return DllCall("lua51.dll\luaL_loadbufferx", "Ptr", L, "Str", buf, "Int", size, "Str", name, "Str", mode, "CDecl Int")
}

luaL_loadbuffer(ByRef L, ByRef buf, size, ByRef name)
{
	return DllCall("lua51.dll\luaL_loadbuffer", "Ptr", L, "Str", buf, "Int", size, "Str", name, "CDecl Int")
}

luaL_loadstring(ByRef L, ByRef s)
{
	return DllCall("lua51.dll\luaL_loadstring", "Ptr", L, "Str", s, "CDecl Int")
}

lua_dump(ByRef L, writer, ByRef data)
{
	return DllCall("lua51.dll\lua_dump", "Ptr", L, "UInt", writer, "UInt", data, "CDecl Int")
}

lua_close(ByRef L)
{
	return DllCall("lua51.dll\lua_close", "Ptr", L, "CDecl")
}

luaJIT_setmode(ByRef L, idx, mode)
{
	return DllCall("lua51.dll\luaJIT_setmode", "Ptr", L, "Int", idx, "Int", mode, "CDecl Int")
}