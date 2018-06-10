regExMatchI(haystack,needleRegEx,byref unquotedOutputVar="",startingPosition=1){
    return strI(regExMatch(strI(haystack),needleRegEx,unquotedOutputVar,startingPosition))
}