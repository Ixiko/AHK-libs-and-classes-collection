/*
FormatDword

 _______________________________________________
|1_________8|9________16|17_______24|25_______32|
|11 00 10 00.00 00 00 00.10 01 01 10.00 00 10 00| = 32 bits.
|31  8bit   | 8bit      | 8bit      | 8bit     0| -> Bit 0-31.
|    msb    + next msb  | next lsb  + lsb       | Most and Least Significant Bit.
|    BYTE4  + BYTE3     + BYTE2     + BYTE1     | = 4 Byte / 4x8 bit.
|         HIWORD        |         LOWORD        | = 2 Word / 2x16 bit
|_____________________DWORD_____________________| = 1 Dword = 2 Word = 4 Byte = 1x32 bit.

____________________________________________________________________________________________________ By Megnatar.
*/

; Return the first two bytes in a 32 bit integer. MSB
HIWORD(Dword,Hex=0){
    BITS:=0x10,WORD:=0xFFFF
    return (!Hex)?((Dword>>BITS)&WORD):Format("{1:#x}",((Dword>>BITS)&WORD))
}

; Return the second two bytes in a 32bit Integer. LSB
LOWORD(Dword,Hex=0){
    WORD:=0xFFFF
    Return (!Hex)?(Dword&WORD):Format("{1:#x}",(Dword&WORD))
}

; Combine two WORD, to make one DWORD.
MAKELONG(LOWORD,HIWORD,Hex=0){
    BITS:=0x10,WORD:=0xFFFF
    return (!Hex)?((HIWORD<<BITS)|(LOWORD&WORD)):Format("{1:#x}",((HIWORD<<BITS)|(LOWORD&WORD)))
}

/* <-- Remove ore comment out this line, then run the script to test it!

LPARAM := Dword := 0x3200258
MsgBox % "Integer`t`t`tHexadecimal`n"
. "-----------------------------------------`n"
. "" HIWORD(Dword)  "`t`t`t" HIWORD(Dword, 1) "`n"
. "" LOWORD(Dword)  "`t`t`t" LOWORD(Dword, 1) "`n"
. "" MAKELONG(LOWORD(Dword), HIWORD(Dword))   "`t`t`t" MAKELONG(LOWORD(Dword), HIWORD(Dword) , 1)  "`n`n"
. "X = " HIWORD(LPARAM) "`n"
. "Y = " LOWORD(LPARAM) "`n"
