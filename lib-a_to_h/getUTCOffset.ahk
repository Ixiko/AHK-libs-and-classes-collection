; retrieve the UTC offset by timezone
getUTCOffset(timezone){
    static regStr:="U)UTC Offset:<\/a>[^+-]+([+-])(\d{1,2}):?(\d{1,2})?<"
    static url:="https://www.timeanddate.com/time/zones/"
    
    regExMatch(urlDownloadToVar(url . strToLower(timezone)),regStr,cT)
    return cT?{sign: cT1,hour: cT2,minute: (cT3?cT3:0)}:0
}