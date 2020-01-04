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