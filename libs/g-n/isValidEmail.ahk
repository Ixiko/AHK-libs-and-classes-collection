; returns True if valid
isValidEmail(emailstr){
    static regex := "is)^(?:""(?:\\\\.|[^""])*""|[^@]+)@(?=[^()]*(?:\([^)]*\)"
    . "[^()]*)*\z)(?![^ ]* (?=[^)]+(?:\(|\z)))(?:(?:[a-z\d() ]+(?:[a-z\d() -]*[()a-"
    . "z\d])?\.)+[a-z\d]{2,6}|\[(?:(?:1?\d\d?|2[0-4]\d|25[0-4])\.){3}(?:1?\d\d?|"
    . "2[0-4]\d|25[0-4])\]) *\z"
    return RegExMatch(emailstr, regex) != 0
}