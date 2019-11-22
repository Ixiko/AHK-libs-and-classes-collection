LoadLibrary(filename)
{
  static ref := {}
  if (!(ptr := p := DllCall("LoadLibrary", "str", filename, "ptr")))
    return 0
  ref[ptr,"count"] := (ref[ptr]) ? ref[ptr,"count"]+1 : 1
  p += NumGet(p+0, 0x3c, "int")+24
  o := {_ptr:ptr, __delete:func("FreeLibrary"), _ref:ref[ptr]}
  if (NumGet(p+0, (A_PtrSize=4) ? 92 : 108, "uint")<1 || (ts := NumGet(p+0, (A_PtrSize=4) ? 96 : 112, "uint")+ptr)=ptr || (te := NumGet(p+0, (A_PtrSize=4) ? 100 : 116, "uint")+ts)=ts)
    return o
  n := ptr+NumGet(ts+0, 32, "uint")
  Loop, % NumGet(ts+0, 24, "uint")
  {
    if (p := NumGet(n+0, (A_Index-1)*4, "uint"))
    {
      o[f := StrGet(ptr+p, "cp0")] := DllCall("GetProcAddress", "ptr", ptr, "astr", f, "ptr")
      if (Substr(f, 0)==(A_IsUnicode) ? "W" : "A")
        o[Substr(f, 1, -1)] := o[f]
    }
  }
  return o
}

FreeLibrary(lib)
{
  if (lib._ref.count>=1)
    lib._ref.count -= 1
  if (lib._ref.count<1)
    DllCall("FreeLibrary", "ptr", lib._ptr)
}