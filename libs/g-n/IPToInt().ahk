msgbox % IPToInt("64.190.207.31", "H")
; params ip >> format (Hex, Decimal)

msgbox % 1+1

IPToInt(ip, fmt)
{
    RegExMatch(ip,"(\d+)\D+(\d+)\D+(\d+)\D+(\d+)",oct_)
    SetFormat, Integer, % fmt
    Int:=(oct_1*(256**3))+(oct_2*(256**2))+(oct_3*256)+oct_4
    SetFormat, Integer, D
    Return Int
}