commaFormat(num){
    num:=strSplit(num,.)
    nnum:=num[1]
    numlen:=strlen(nnum)
    loop,parse,nnum
        xnum.=!mod(numlen-a_index,3) && a_index != numlen ? a_loopfield "," : a_loopfield
    return num[2]?xnum "." num[2]:xnum
}