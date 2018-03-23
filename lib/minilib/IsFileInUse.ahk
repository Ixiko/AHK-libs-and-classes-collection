IsFileInUse(f,access:="rwd"){
return FileExist(f)&&!FileOpen(f,"w -" access)
}