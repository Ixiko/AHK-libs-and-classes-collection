commaFormat(num){
    num:=strSplit(num,".")
    numlen:=strlen(num[1])

    loop,parse,% num[1]
        xnum.=!mod(numlen-a_index,3) && a_index != numlen ? a_loopfield "," : a_loopfield
    return num[2]?xnum "." num[2]:xnum
}