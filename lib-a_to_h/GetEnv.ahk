GetEnv(){
  global
  local __env__:=DllCall("GetEnvironmentStringsW","PTR"),__thisenv__,__temp__,__tempenv__:=__env__
  While __thisenv__:=SubStr(__temp__:=StrGet(__env__,"UTF-16"),1,InStr(__temp__,"=",1,2)-1)
    If ((__env__+=StrLen(__temp__)*2+2) && RegExMatch(__thisenv__,"^[\w_]+$")&&!Instr(".comspec.programfiles.","." __thisenv__ "."))
      EnvGet,%__thisenv__%,% __thisenv__
  DllCall("FreeEnvironmentStringsW","PTR",__tempenv__)
}