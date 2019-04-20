stringify(obj){
    local outStr,i,a

    for i,a in obj
        outStr.=(a_index!=1?",":"") . (regExMatch(i,"\W")?"""" . i . """":i) . ": " . (isObject(a)?stringify(a):"""" . a . """")
    
    return "{" . outStr . "}"
}