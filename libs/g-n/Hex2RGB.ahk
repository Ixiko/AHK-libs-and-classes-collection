hex2rgb(CR)
{
    H := InStr(CR, "0x") ? CR : (InStr(CR, "#") ? "0x" SubStr(CR, 2) : "0x" CR)
    return (H & 0xFF0000) >> 16 "," (H & 0xFF00) >> 8 "," (H & 0xFF)
}

MsgBox % hex2rgb("0x77c8d2")        ; 119,200,210
MsgBox % hex2rgb("#77c8d2")         ; 119,200,210
MsgBox % hex2rgb("77c8d2")          ; 119,200,210