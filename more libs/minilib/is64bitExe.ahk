is64bitExe(path){
  dllCall("GetBinaryType","astr",path,"uint*",type)
  return 6=type
}