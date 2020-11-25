getSelected(){
    cO:=clipboardAll
    clipboard:=
    send ^c
    clipWait,0.5
    if(errorlevel){
        clipboard:=c0
        return
    }
    path:=clipboard
    clipboard:=cO
    return path
}
