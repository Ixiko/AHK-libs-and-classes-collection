; Link:   	https://autohotkey.com/board/topic/16888-uint64-int64-using-large-unsigned-hexdecimals/
; Author:	Laszlo
; Date:
; for:     	AHK_L
; title:        UInt64 <--> Int64: Using large unsigned hex/decimals

; AHK cannot process UINT64 numbers directly.
; Literal integers larger than 2**63-1 are treated as overflow, and replaced by 0x7fffffffffffffff.
; If you get these numbers from other applications (like from majkinetor's hex viewer),
; you have to convert them to signed Int64 numbers,
; to let them wrap around (treating the leftmost bit as sign).
; After processing we can convert them back to UInt64. Here are functions for this.

/* ;;;;; TEST CASES ;;;;;

MsgBox % UDec( 0x0)                ; 0

MsgBox % UDec( 0x1)                ; 1

MsgBox % UDec( 0x12)               ; 18

MsgBox % UDec( 0x7fffffffffffffff) ; 9223372036854775807

MsgBox % UDec(-0x8000000000000000) ; 9223372036854775808

MsgBox % UDec(-0x7fffffffffffffff) ; 9223372036854775809

MsgBox % UDec(-0x2)                ; 18446744073709551614

MsgBox % UDec(-0x1)                ; 18446744073709551615


MsgBox % UHex( 0x0)                ; 0x0

MsgBox % UHex( 0x1)                ; 0x1

MsgBox % UHex( 0x12)               ; 0x12

MsgBox % UHex( 0x7fffffffffffffff) ; 0x7fffffffffffffff

MsgBox % UHex(-0x8000000000000000) ; 0x8000000000000000

MsgBox % UHex(-0x7fffffffffffffff) ; 0x8000000000000001

MsgBox % UHex(-0x2)                ; 0xfffffffffffffffe

MsgBox % UHex(-0x1)                ; 0xffffffffffffffff


SetFormat Integer, HEX

MsgBox % UDecToInt64(0000000000000000000)  ; 0x0

MsgBox % UDecToInt64(0000000000000000001)  ; 0x1

MsgBox % UDecToInt64(0000000000000000018)  ; 0x12

MsgBox % UDecToInt64(9223372036854775807)  ; 0x7fffffffffffffff

MsgBox % UDecToInt64(9223372036854775808)  ;-0x8000000000000000

MsgBox % UDecToInt64(9223372036854775809)  ;-0x7fffffffffffffff

MsgBox % UDecToInt64(18446744073709551614) ;-0x2

MsgBox % UDecToInt64(18446744073709551615) ;-0x1

MsgBox % UDecToInt64(18446744073709551616) ; 0x0

MsgBox % UDecToInt64(18446744073709551617) ; 0x1

MsgBox % UDecToInt64(18446744073709551618) ; 0x2


MsgBox % UHexToInt64(0x0000000000000000) ; 0x0

MsgBox % UHexToInt64(0x0000000000000001) ; 0x1

MsgBox % UHexToInt64(0x0000000000000010) ; 0x10

MsgBox % UHexToInt64(0x705DA80000000123) ; 0x705DA80000000123

MsgBox % UHexToInt64(0xC05DA80000000000) ;-0x3FA2580000000000

MsgBox % UHexToInt64(0xC05DA8000000000A) ;-0x3FA257FFFFFFFFF6

MsgBox % UHexToInt64(0xC05DA800000000FF) ;-0x3FA257FFFFFFFF01


*/

UDec(i) { ; internal Int64 --> UInt64 string
   VarSetCapacity(S,20)
   DllCall("msvcrt\sprintf", Str,S, Str,"%I64u", Int64,i)
   Return S
}

UHex(i) { ; internal Int64 --> Unsigned Hex string
   VarSetCapacity(S,18)
   DllCall("msvcrt\sprintf", Str,S, Str,"0x%I64x", Int64,i)
   Return S
}

UDecToInt64(d) { ; unsigned <= 20 digit decimal string --> Int64
   Return StrLen(d) < 19 ? d : SubStr(d,1,StrLen(d)-2)*100 + SubStr(d,-1)
}

UHexToInt64(x) { ; unsigned <= 16 digit hex string --> Int64
   Return StrLen(x) < 18 ? x : (SubStr(x,1,StrLen(x)-1)<<4) + abs("0x" . SubStr(x,0))
}



