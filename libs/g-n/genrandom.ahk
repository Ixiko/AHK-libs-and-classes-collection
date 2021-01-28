genrand(){
    static k = 1, N = 25, M:=7
     ;/* initial 25 seeds, change as you wish */
    static x:=[0x95f24dab, 0x0b685215, 0xe76ccae7, 0xaf3ec239, 0x715fad23,	0x24a590ad, 0x69e4b5ef, 0xbf456141, 0x96bc1b7b, 0xa7bdf825,	0xc1de75b7, 0x8858a9c9, 0x2da87693, 0xb657f9dd, 0xffdc8a9f,	0x8121da71, 0x8b823ecb, 0x885d05f5, 0x4e20cd47, 0x5a9ad5d9,	0x512c0c03, 0xea857ccd, 0x4cc1d30f, 0x8891a8a1, 0xa6b7aadb]
    static mag01:=[0x0, 0x8ebfd028] ; /* this is magic vector `a', don't change */
    if (k==N) { ; /* generate N words at one time */
      Loop % n-m
        x[kk:=A_Index] := x[A_Index+M] ^ (x[A_Index] >> 1) ^ mag01[mod(x[A_Index],2)+1]
      Loop % N-kk
      	x[kk+A_Index] := x[kk+A_Index+(M-N)] ^ (x[kk+A_Index] >> 1) ^ mag01[mod(x[A_Index], 2)+1]
      k:=1
    }
    y := x[k]
	y ^= (y >> 11)
	y ^= (y << 7) & 0x9D2C5680
	y ^= (y << 15) & 0xEFC60000
	y ^= (y >> 18)
    k++
	;y := (1 + ( y * ( 70 - (1 + 1))) / (1<<32) )
	;y := y / 0xffffffff
	;y := y * (1.0/4294967296.0) ; = 4294967295
	y := mod( y,  ((650 - 1 + 1) + 1))
	;msgbox, %y%
    return y ;(y>>32) ; / 0xffffffff
}