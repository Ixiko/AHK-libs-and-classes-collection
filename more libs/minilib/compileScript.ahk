compileScript(file,out="",bin="",icon="",mpress=0){
    if(!a_ahkPath)
        return

    splitPath,a_ahkPath,,cDir
    cDir.="\Compiler"
    if(bin){
        splitPath,bin,,bDir
        bin:=!bDir?cDir "\" bin:bin
    }
    if(icon){
        splitPath,icon,,iDir
        icon:=!iDir?cDir "\" icon:icon
    }
    runWait,% cDir "\Ahk2Exe.exe /in """ file """" (out?" /out """ out """":"") (icon?" /icon """ icon """":"") (bin?" /bin """ bin """":"")(" /mpress " mpress)
    return a_lastError
}