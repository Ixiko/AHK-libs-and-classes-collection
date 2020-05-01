PathX(S, P*) {                                        ; PathX v0.63 by SKAN on D34U @ tiny.cc/pathx
Local K,V,N, u:={},  T:=dr:=di:=fn:=ex := A_IsUnicode ? Format("{:-260}","") : Format("{:-520}","")

  For K,V in P
    N := StrSplit(V,":",,2),  u[SubStr(N.1,1,2)] := N.2

  DllCall("GetFullPathName", "Str",Trim(S,""""), "UInt",260, "Str",T, "Ptr",0)
  DllCall("msvcrt\_wsplitpath", "WStr",T, "WStr",dr, "WStr",di, "WStr",fn, "WStr",ex, "Cdecl")

Return { "Drive"  : dr := u.dr ? u.dr : dr
       , "Dir"    : di := (u.dp) (u.di ? u.di : di) (u.ds)
       , "Fname"  : fn := (u.fp) (u.fn ? u.fn : fn) (u.fs)
       , "Ext"    : ex := (u.ex ? u.ex : ex)
       , "Folder" : (dr)(di)
       , "File"   : (fn)(ex)
       , "Full"   : (dr)(di)(fn)(ex) }
}