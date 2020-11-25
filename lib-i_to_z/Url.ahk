/*
    Codifica una cadena en formato Url.
    Parámetros:
        Url     : La cadena de caracteres a codificar.
        Encoding: Codificación a usar. El estándar es UTF-8. UTF-16 es una implementación no estándar y no siempre es reconocida.
    Ejemplos:
        MsgBox('UTF-8:`n-----------------`nEncoded: ' . (e:=URLEncode(t:='•ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~ÁÑñ')) . '`n`nDecoded: ' . URLDecode(e) . '`n`nOriginal: ' . t)
        MsgBox('UTF-16:`n-----------------`nEncoded: ' . (e:=URLEncode(t:='•ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~ÁÑñ', 'UTF-16')) . '`n`nDecoded: ' . URLDecode(e) . '`n`nOriginal: ' . t)
        
*/
URLEncode(Url, Encoding := 'UTF-8'){
    
    Static Unreserved := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~'
    Static Data       := {    Size  : {'UTF-8': 1         , 'UTF-16': 2           }
                            , Type  : {'UTF-8': 'UChar'   , 'UTF-16': 'UShort'    }
                            , Format: {'UTF-8': '%{:02X}' , 'UTF-16': '%u{:04X}'  }  }
    Local V, R, Code
    
    VarSetCapacity(V, StrPut(Url, Encoding) * Data.Size[Encoding]), StrPut(Url, &V, Encoding)
    While (Code := NumGet(&V + Data.Size[Encoding] * (A_Index - 1), Data.Type[Encoding]))
        R .= InStr(Unreserved, Chr(Code)) ? Chr(Code) : Format(Data.Format[Encoding], Code)
    
    Return (R)
} ;http://rosettacode.org/wiki/URL_encoding#AutoHotkey | https://en.wikipedia.org/wiki/Percent-encoding




/*
    Decodifica una cadena en formato de Url (codificación de URL o por ciento).
    Parámetros:
        Url: La cadena de caracteres a decodificar.
    Nota:
        La codificación de la cadena pasada en Url es detectada automáticamente (UTF-8 o UTF-16).
*/
URLDecode(Url) {
    Local R, B, T
        , Encoding := InStr(Url, Chr(37) . 'u') ? 'UTF-16' : 'UTF-8'
        , Trim     := Encoding == 'UTF-16'      ? 2        : 1           ;%u     : %
        , Length   := Encoding == 'UTF-16'      ? 4        : 2           ;0x0000 : 0x00
    
    Loop Parse, Url
        R .= A_LoopField == Chr(37) ? Chr('0x' . SubStr(Url, A_Index + Trim, T:=Length)) : (--T > -Trim ? '' : A_LoopField)
    
    If (Encoding == 'UTF-8')    {
        VarSetCapacity(B, StrPut(R, 'UTF-8'))
        Loop Parse, R
            NumPut(Ord(A_LoopField), &B + A_Index - 1, 'UChar')
    }
    
    Return (Encoding == 'UTF-8' ? StrGet(&B, 'UTF-8') : R)
} ;https://autohotkey.com/boards/viewtopic.php?t=4868
