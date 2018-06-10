; written by maestrith, edited by Masonjar13
urlDownloadToVar(url,raw:=0){
    
    if(!regExMatch(url,"i)https?://"))
        url:="https://" url
    try{
        hObject:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
        hObject.Open("GET",url)
        hObject.Send()
        return raw?hObject.ResponseBody:hObject.ResponseText
    }catch err{
        msgbox % err.message
    }
    return 0
}