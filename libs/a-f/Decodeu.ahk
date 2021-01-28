decodeu(ustr){
   Loop
    {
        if !ustr
            break
        if RegExMatch(ustr,"^\s*\\u([A-Fa-f0-9]{2})([A-Fa-f0-9]{2})(.*)",m)
        {
            word_u := Chr("0x" m2) Chr("0x" m1), ustr := m3, word_a := ""
            Unicode2Ansi(word_u,word_a,0)
            out .= word_a
        }
        else if RegExMatch(ustr, "^([a-zA-Z0-9\.\?\-\!\s]*)(.*)",n)
        {
            ustr := n2
            out .= n1
        }
    }
    return out
}

Unicode2Ansi(ByRef wString, ByRef sString, CP = 0)
{
     nSize := DllCall("WideCharToMultiByte"
      , "Uint", CP
      , "Uint", 0
      , "Uint", &wString
      , "int", -1
      , "Uint", 0
      , "int", 0
      , "Uint", 0
      , "Uint", 0)
   VarSetCapacity(sString, nSize)
   DllCall("WideCharToMultiByte"
      , "Uint", CP
      , "Uint", 0
      , "Uint", &wString
      , "int", -1
      , "str", sString
      , "int", nSize
      , "Uint", 0
      , "Uint", 0)
}