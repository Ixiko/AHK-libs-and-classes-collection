regExMatchI(haystack,needleRegEx,byref unquotedOutputVar="",startingPosition=1){
    return abs(regExMatch(strI(haystack),needleRegEx,unquotedOutputVar,startingPosition)-strLen(haystack))
}
