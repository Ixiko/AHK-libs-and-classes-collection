CRC_8            := [0x07, False, 8, 0x00, 0x00]                      ; CRC-8
CRC_32           := [0xedb88320, True, 32, 0xffffffff, 0xffffffff]    ; CRC-32
CRC_16_AUG_CCITT := [0x1021, False, 16, 0x1d0f, 0x0000]               ; CRC-16/AUG-CCITT
CRC_64_XZ        := ["0xc96c5795d7870f42", True,  64, "0xffffffffffffffff", "0xffffffffffffffff"] ; CRC-64/XZ


FileGetSize, nBytes, %A_AhkPath%
FileRead, Bin, *c %A_AhkPath%
MsgBox % mCrc(&Bin, nBytes, CRC_64_XZ*)

VarSetCapacity(sStr, 128)
nBytes := StrPut("AutoHotkey", &sStr, 128, "utf-8") - 1

MsgBox % mCrc(&sStr, nBytes, CRC_32*)
MsgBox % mCrc(&sStr, nBytes, CRC_16_AUG_CCITT*)
MsgBox % mCrc(&sStr, nBytes, CRC_8*)