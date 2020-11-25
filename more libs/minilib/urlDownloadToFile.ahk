urlDownloadToFile(url,fileDest="",method=0){
    if(a_batchLines!=-1){
        pBL:=a_batchLines
        setBatchLines -1
    }
    if(!fileDest){
        splitPath,url,fileDest
        fileDest:=a_scriptDir "\" fileDest
    }
    hObject:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
    hObject.Open("GET",url)
    hObject.Send()
    
    uBytes:=hObject.ResponseBody,cLen:=uBytes.maxIndex()
    fileHandle:=fileOpen(fileDest,"w")

; put to var, write once
    if(!method){
        varSetCapacity(f,cLen,0)
        loop % cLen+1
            numPut(uBytes[a_index-1],f,a_index-1,"UChar")
        err:=fileHandle.RawWrite(f,cLen+1)
    }

; skip var, write many times
    else{
        loop % cLen+1 
            err+=fileHandle.WriteUChar(uBytes[a_index-1])
        fileHandle.Close()
    }
    if(pBL)
        setBatchLines % pBL
    return err
}
