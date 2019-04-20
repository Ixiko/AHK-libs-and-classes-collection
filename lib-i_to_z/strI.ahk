strI(str){
    varSetCapacity(nStr,sLen:=strLen(str))
;    sLen:=strLen(str)
    loop % sLen
        nStr.=subStr(str,sLen--,1)
    return nStr
}