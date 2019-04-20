/* 
AutoHotkey Version: 1.0.35+ 
Language:  English 
Platform:  Win2000/XP 
Author:    Laszlo Hars <www.Hars.US> 
Modified by: Christian Sander

Script to en/decrypt text files to text files 

Plus-minus Counter Mode: stream cipher using add/subtract with reduced range 
   (32...126). Characters outside remain unchanged (TAB, CR, LF, ...). 
   Lines will remain of the same length. If it leaks information, pad! 

The underlying cipher is TEA, the Tiny Encryption Algorithm 
http://www.simonshepherd.supanet.com/tea.htm It is one of the fastest and most 
efficient cryptographic algorithms. It was developed by David Wheeler and Roger 
Needham at the Computer Laboratory of Cambridge University. It is a Feistel 
cipher, which uses operations from mixed (orthogonal) algebraic groups - XOR, 
ADD and SHIFT in this case. It encrypts 64 data bits at a time using a 128-bit 
key. It seems highly resistant to differential cryptanalysis, and achieves 
complete diffusion (where a one bit difference in the plaintext will cause 
approximately 32 bit differences in the ciphertext) after only six rounds. 

As a test, the script reads its source file and saves the ciphertext with 
   extension .enc to the same directory. 
If it exists, the decrypted file is saved with extension .dec instead 

Version:   1.0  2005.07.08  First created 
*/ 

Encrypt(text)
{
	StringCaseSense Off 
	AutoTrim Off 
	k1 := 0x11111111                 ; 128-bit secret key 
	k2 := 0x22222222 
	k3 := 0x33333333                 ; choose wisely! 
	k4 := 0x44444444 
	k5 := 0x12345678                 ; starting counter value 
	i = 9                         ; pad-index, force restart 
	p = 0                         ; counter to be encrypted 

	Loop Parse, text, `n, `r 
	{ 
	  L =                        ; processed line 
	  Loop % StrLen(A_LoopField) 
	  { 
		 i++ 
		 IfGreater i,8, {        ; all 9 pad values exhausted 
			u := p 
			v := k5              ; another secret 
			p++                  ; increment counter 
			TEA(u,v, k1,k2,k3,k4) 
			s := Stream9(u,v)         ; 9 pads from encrypted counter 
			i = 0 
		 } 
		 StringMid c, A_LoopField, A_Index, 1 
		 a := Asc(c) 
		 if a between 32 and 126 
		 {                       ; chars > 126 or < 31 unchanged 
			a += s[i]
			IfGreater a, 126, SetEnv, a, % a-95 
			c := Chr(a) 
		 } 
		 L = %L%%c%              ; attach encrypted character 
	  } 
	  encrypted .=L "`n"
	}
	if(Substr(text,0)!="`n")
		encrypted := Substr(encrypted, 1, strLen(encrypted)-1)
	Return encrypted
}

Decrypt(text)
{
	StringCaseSense Off 
	AutoTrim Off 
	k1 := 0x11111111                 ; 128-bit secret key 
	k2 := 0x22222222 
	k3 := 0x33333333                 ; choose wisely! 
	k4 := 0x44444444 
	k5 := 0x12345678                 ; starting counter value 
	i = 9                         ; pad-index, force restart 
	p = 0                         ; counter to be encrypted 
	decrypted := ""
	Loop Parse, text, `n, `r 
	{ 
	  L =                        ; processed line 
	  Loop % StrLen(A_LoopField) 
	  { 
		 i++ 
		 IfGreater i,8, {        ; all 9 pad values exhausted 
			u := p 
			v := k5              ; another secret 
			p++                  ; increment counter 
			TEA(u,v, k1,k2,k3,k4) 
			s := Stream9(u,v)         ; 9 pads from encrypted counter 
			i = 0 
		 } 
		 StringMid c, A_LoopField, A_Index, 1 
		 a := Asc(c) 
		 if a between 32 and 126 
		 {                       ; chars > 126 or < 31 unchanged 
			a -= s[i] 
			IfLess a, 32, SetEnv, a, % a+95 
			c := Chr(a) 
		 } 
		 L = %L%%c%              ; attach encrypted character 
	  } 
	  decrypted .= L "`n"
	}
	if(Substr(text,0)!="`n")
		decrypted := Substr(decrypted, 1, strLen(decrypted)-1)
	Return decrypted
}


TEA(ByRef y,ByRef z,k0,k1,k2,k3) ; (y,z) = 64-bit I/0 block 
{                                ; (k0,k1,k2,k3) = 128-bit key 
   IntFormat = %A_FormatInteger% 
   SetFormat Integer, D          ; needed for decimal indices 
   s := 0 
   d := 0x9E3779B9 
   Loop 32 
   { 
      k := "k" . s & 3           ; indexing the key 
      y := 0xFFFFFFFF & (y + ((z << 4 ^ z >> 5) + z  ^  s + %k%)) 
      s := 0xFFFFFFFF & (s + d)  ; simulate 32 bit operations 
      k := "k" . s >> 11 & 3 
      z := 0xFFFFFFFF & (z + ((y << 4 ^ y >> 5) + y  ^  s + %k%)) 
   } 
   SetFormat Integer, %IntFormat% 
   y += 0 
   z += 0                        ; Convert to original ineger format 
} 

Stream9(x,y)                     ; Convert 2 32-bit words to 9 pad values 
{                                ; 0 <= s[0], s[1], ... s[8] <= 94 
   s := []
   s[0] := Floor(x*0.000000022118911147) ; 95/2**32 
   Loop 8 
   { 
      z := (y << 25) + (x >> 7) & 0xFFFFFFFF 
      y := (x << 25) + (y >> 7) & 0xFFFFFFFF 
      x = %z%
      s[A_Index] := Floor(x * 0.000000022118911147) 
   } 
   return s
}