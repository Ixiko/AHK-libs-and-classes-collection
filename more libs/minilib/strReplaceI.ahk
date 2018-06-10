strReplaceI(haystack,searchText,replaceText="",byref outputVarCount="",limit=-1){
    return strI(strReplace(strI(haystack),searchText,replaceText,outputVarCount,limit))
}