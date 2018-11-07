;Message Authentication / Secure hash in AHK alone by Laszlo
;https://autohotkey.com/board/topic/4632-message-authentication-secure-hash-in-ahk-alone/

/*									DESCRIPTION
(Hash functions map arbitrary length input to a short, fixed length output, like checksums or CRC, cyclic redundancy codes. Secure hash functions make it hard to find two inputs computing the same or similar output or to find an input, which hashes to a given output.)

We can compute cryptographically secure hash functions coded entirely in AHK, using, for example the TEA cipher. They are used for Message Authentication Codes (MAC) and Modification Detection Codes (MDC). MAC is normally keyed: a secret key allows the computation (the same as verification) of the MAC value, which proves that the message came from a certain sender and it has not been changed. MDC is normally unkeyed: everybody can compute the MDC value (and so verify if the message has not been changed). An additional requirement for MDC is that it should be infeasible (requiring too much computational work) to construct another message with the same MDC value. MDC is much more secure than CRC, which used to verify the integrity of data or code, but also it is slower to compute.

XCBC MAC
~~~~~~~
The basic idea is ciphertext chaining, that is, encrypting blocks of the message each XOR-ed with the ciphertext of the previous encryption. The last block of the message needs to be padded to the length of the cipher block. To be able to distinguish padded text from non-padded one, the last encryption needs a different key. This key could be just XOR-ed to the message block, which is shorter than the key in case of TEA.

All together, the TEA-XCBC MAC needs 256 bits secret key, divided into a 128-bit encryption key, and two 64-bit modifier keys, one applied to unpadded last message blocks, the other one to padded last message blocks. The MAC is only 64 bits (16 hex digits). Because of the Birthday Paradox, after about a billion (2**30) messages some MAC values could come up again, with non-negligible probability. It usually does not pose a serious security threat. If it did, two MAC values could be concatenated, which were computed with different keys.

Double-pipe Merkle-Damgard Hash (DMD-MDC)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
In this case the requirements for the hash function are stricter. For example, if the authenticity of a program is in question: an attacker modifies the code (maybe just with a single bit flip), and tries to add a few more bits to the end of the file, such that it provides the same MDC. The attacker has now all the information about the MDC algorithm, there is no secret key involved. Trying 2**32 different bit combinations is feasible on fast computers. Therefore, the MDC value has to be longer, at least 128 bits (32 hex digits).

There are a number of attacks known against iterated (cascaded) hash functions (e.g. Joux' attacks). If the internal state (the information passed between iterations) is n-bits, the complexity of a collision finding attack could be only 2**(n/2). This means, that the internal data path has to be also at least 128-bit wide, too.

The Double-pipe MDC (DMDC) is constructed from the TEA cipher, based on the Matyas-Meyer-Oseas iterative MDC. Below TEA(M,K) is the encryption function of the message M with the key K = {I, J}.

I[i] := TEA(M[i], {I[i–1], J[i–1]}) XOR M[i]
J[i] := TEA(M[i], {J[i–1], I[i–1]}) XOR M[i]

Here I[0] and J[0] are two predefined 64-bit constants (fixed keys). The message needs to be padded to a multiple of 64 bits, with the usual way: appending bits 1000... Again, to break the undesirable property that the hash of a continued text can be computed from the original hash and the appended text, the last block of the possibly padded message is modified by XOR-ing another constant (fixed key), different if the message needed padding or not.

Below is a script for demonstrating the concept. There are many optimization possibilities.
- The TEA cipher seems to be secure enough with 8 iterations, instead of the standard 32.
- The code reads the entire file and converts it to hex, stored in an AHK variable. It could be better to read only one, or a few blocks (of 64 bits each) at a time, without closing and re-opening the file.
- The functions could use ByRef parameters for the input data. This way there was no need to make a copy of it at call.

Even with all these speedups the script is too slow for large files (a MByte looks already too large). It is easy to convert the script to C and compile it to a DLL for more than a hundred fold acceleration. However, experimenting with this script is easier and it gives some insight into the theory of secure hashing.
*/


/*                              	EXAMPLE(s)
	
						
			k0 = 0x11111111                  ; 128-bit secret key (example)
			k1 = 0x22222222
			k2 = 0x33333333
			k3 = 0x44444444
			
			l0 = 0x12345678                  ; 64- bit 2nd secret key (example)
			l1 = 0x12345678
			
			m0 = 0x87654321                  ; 64- bit 3rd secret key (example)
			m1 = 0x87654321
			
			;---- Read its own file, display its XCBC and DMDC as test ----
			
			res := HexRead(A_ScriptFullPath,x)
			TrayTip,,ErrorLevel = %ErrorLevel%`nBytes Read = %res%
			
			MsgBox % "XCBC = "XCBC(x, 0,0, k0,k1,k2,k3, l0,l1, m0,m1)
			MsgBox % "DMDC = "DMDC(x)
			
			
			
	*/


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; TEA cipher ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Block encryption with the TEA cipher
; [y,z] = 64-bit I/0 block
; [k0,k1,k2,k3] = 128-bit key
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TEA(ByRef y,ByRef z, k0,k1,k2,k3) {
   s = 0
   d = 0x9E3779B9
   Loop 32                       ; could be reduced to 8 for speed
   {
      k := "k" . s & 3           ; indexing the key
      y := 0xFFFFFFFF & (y + ((z << 4 ^ z >> 5) + z  ^  s + %k%))
      s := 0xFFFFFFFF & (s + d)  ; simulate 32 bit operations
      k := "k" . s >> 11 & 3
      z := 0xFFFFFFFF & (z + ((y << 4 ^ y >> 5) + y  ^  s + %k%))
   }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; XCBC-MAC ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; x  = long hex string input
; [u,v] = 64-bit initial value (0)
; [k0,k1,k2,k3] = 128-bit key
; [l0,l1] = 64-bit key for not padded last block
; [m0,m1] = 64-bit key for padded last block
; Return 16 hex digits (64 bits) digest
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

XCBC(x, u,v, k0,k1,k2,k3, l0,l1, m0,m1) {
   Loop % Ceil(StrLen(x)/16)-1   ; full length intermediate message blocks
      XCBCstep(u, v, x, k0,k1,k2,k3)

   If (StrLen(x) = 16)           ; full length last message block
   {
      u := u ^ l0                ; l-key modifies last state
      v := v ^ l1
      XCBCstep(u, v, x, k0,k1,k2,k3)
   }
   Else {                        ; padded last message block
      u := u ^ m0                ; m-key modifies last state
      v := v ^ m1
      x = %x%100000000000000
      XCBCstep(u, v, x, k0,k1,k2,k3)
   }

   Return Hex8(u) . Hex8(v)      ; 16 hex digits returned
}

XCBCstep(ByRef u, ByRef v, ByRef x, k0,k1,k2,k3) {
   StringLeft  p, x, 8           ; Msg blocks
   StringMid   q, x, 9, 8
   StringTrimLeft x, x, 16
   p = 0x%p%
   q = 0x%q%
   u := u ^ p
   v := v ^ q
   TEA(u,v,k0,k1,k2,k3)
}

Hex8(i) {
   SetFormat Integer, Hex
   i += 0                        ; convert to hex
   SetFormat Integer, D
   StringTrimLeft i, i, 2        ; remove leading 0x
   i = 0000000%i%                ; pad with 7 MS 0's
   StringRight i, i, 8           ; take 8 LS hex digits
   Return i
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DMDC DMC ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; x  = long hex sting input
; Return 32 hex digits (128 bit) digest
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


DMDC(x) {
   i0 = 0x11111111               ; 64-bit fixed I key (example)
   i1 = 0x22222222
   j0 = 0x55555555               ; 64-bit fixed J key (example)
   j1 = 0x66666666
   l0 = 0x12345678               ; 64- bit no-pad fixed key (example)
   l1 = 0x0fedcba9
   m0 = 0x87654321               ; 64- bit pad fixed key (example)
   m1 = 0x9abcdef0

   Loop % Ceil(StrLen(x)/16)-1   ; full length intermediate message blocks
   {
      Get16(p,q, x)
      DMDCstep(p,q, i0,i1, j0,j1)
   }

   If (StrLen(x) = 16)           ; full length last message block
   {
      Get16(p,q, x)
      p := p ^ l0                ; l-key modifyes last state
      q := q ^ l1
      DMDCstep(p,q, i0,i1, j0,j1)
   }
   Else {                        ; padded last message block
      x = %x%100000000000000
      Get16(p,q, x)
      p := p ^ m0                ; m-key modifyes last state
      q := q ^ m1
      DMDCstep(p,q, i0,i1, j0,j1)
   }
                                 ; 32 hex digits returned
   Return Hex8(i0) . Hex8(i1) . Hex8(j0) . Hex8(j1)
}

DMDCstep(p,q, ByRef i0, ByRef i1, ByRef j0, ByRef j1) {
   r = %p%                       ; copies of the message block
   s = %q%
   t = %p%
   u = %q%
   TEA(r,s, i0,i1,j0,j1)         ; encryption
   TEA(t,u, j0,j1,i0,i1)
   i0 := r ^ p                   ; update keys
   i1 := s ^ q
   j0 := t ^ p
   j1 := u ^ q
}

Get16(ByRef p, ByRef q, ByRef x) {
   StringLeft  p, x, 8           ; Msg block
   StringMid   q, x, 9, 8
   StringTrimLeft x, x, 16       ; remove used msg block
   p = 0x%p%
   q = 0x%q%
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; HexRead ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  - Open binary file
;  - Read n bytes (n = 0: all)
;  - From offset (offset < 0: counted from end)
;  - Close file
;  (Hex)data (replaced) <- file[offset + 0..n-1]
;  Return #bytes actually read
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

HexRead(file, ByRef data, n=0, offset=0) {
   h := DllCall("CreateFile","Str",file,"Uint",0x80000000,"Uint",3,"UInt",0,"UInt",3,"Uint",0,"UInt",0)
   IfEqual h,-1, SetEnv, ErrorLevel, -1
   IfNotEqual ErrorLevel,0,Return,0 ; couldn't open the file

   m = 0                            ; seek to offset
   IfLess offset,0, SetEnv,m,2
   r := DllCall("SetFilePointerEx","Uint",h,"Int64",offset,"UInt *",p,"Int",m)
   IfEqual r,0, SetEnv, ErrorLevel, -3
   IfNotEqual ErrorLevel,0, {
      t = %ErrorLevel%              ; save ErrorLevel to be returned
      DllCall("CloseHandle", "Uint", h)
      ErrorLevel = %t%              ; return seek error
      Return 0
   }

   TotalRead = 0
   data =
   IfEqual n,0, SetEnv n,0xffffffff ; almost infinite

   format = %A_FormatInteger%       ; save original integer format
   SetFormat Integer, Hex           ; for converting bytes to hex

   Loop %n%
   {
      result := DllCall("ReadFile","UInt",h,"UChar *",c,"UInt",1,"UInt *",Read,"UInt",0)
      if (!result or Read < 1 or ErrorLevel)
         break
      TotalRead += Read             ; count read
      c += 0                        ; convert to hex
      StringTrimLeft c, c, 2        ; remove 0x
      c = 0%c%                      ; pad left with 0
      StringRight c, c, 2           ; always 2 digits
      data = %data%%c%              ; append 2 hex digits
   }

   IfNotEqual ErrorLevel,0, SetEnv,t,%ErrorLevel%

   h := DllCall("CloseHandle", "Uint", h)
   IfEqual h,-1, SetEnv, ErrorLevel, -2
   IfNotEqual t,,SetEnv, ErrorLevel, %t%

   SetFormat Integer, %format%      ; restore original format
   Totalread += 0                   ; convert to original format
   Return TotalRead
}