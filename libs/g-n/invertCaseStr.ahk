invertCaseStr(str){
    loop,parse,str
        nStr.=asc(a_loopField)>96?chr(asc(a_loopField)-32):chr(asc(a_loopField)+32)
    return nStr
}