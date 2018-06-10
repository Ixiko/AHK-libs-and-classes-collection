fileUnblock(path){
    fileDelete,% path . ":Zone.Identifier:$DATA"
    return errorlevel
}