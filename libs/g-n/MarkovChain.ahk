input := "NONWORD NONWORD " clipboard " NONWORD"

msgBox % markovChain(markovArray(input))

markovChain(obj, prefix:="NONWORD NONWORD") {
    While (x != "NONWORD") {           
        suffix := obj[(prefix)], x := suffix[random(1, suffix.Length())]
        results .= (x == "NONWORD" ? "" : x) " "     
        prefix := StrSplit(prefix, " ").2 " " x
    }  
    return results 
}

markovArray(text) {

    arr := StrSplit(text, " "), markov := {}
    
    For e, v in arr {
        x := arr[e] " " arr[e+1]
        suffix := []
        If (markov.HasKey(x))
            suffix := markov[(x)]
        suffix.push(arr[e+2])
        markov[(x)] := suffix
        suffix := ""
    }
    return markov
}

random(x:=0, y:=9) {
    random, o, x, y
    return o
}