regExReplaceI(haystack,needleRegEx,replacement="",byref outputVarCount="",limit=-1,startingPosition=1){
    return strI(regExReplace(strI(haystack),needleRegEx,replacement,outputVarCount,limit,startingPosition))
}