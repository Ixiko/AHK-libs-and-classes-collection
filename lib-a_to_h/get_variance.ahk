;get_variance.ahk

get_variance(bcolor, fcolor)
{

 	StringLen, Length, bcolor
	EnvDiv, Length, 2
	StartChar=1

	Loop
	 {
		StringMid,Chunk,bcolor,%StartChar%,2
		Chunk%A_Index%=%Chunk%
		IfEqual, A_Index, %Length%, Break
		EnvAdd, StartChar, 2

	 }

bcolorr := Chunk2
bcolorg := Chunk3
bcolorb := Chunk4


	StringLen, Length, fcolor
	EnvDiv, Length, 2
	StartChar=1

	Loop
 	{
		StringMid,Chunk,fcolor,%StartChar%,2
		Chunk%A_Index%=%Chunk%
		IfEqual, A_Index, %Length%, Break
		EnvAdd, StartChar, 2

	}

fcolorr := Chunk2
fcolorg := Chunk3
fcolorb := Chunk4

hexpref = 0x
rdiff := (hexPref . bcolorr) - (hexPref . fcolorr)
gdiff := (hexPref . bcolorg) - (hexPref . fcolorg)
bdiff := (hexPref . bcolorb) - (hexPref . fcolorb)

Absrdiff := Abs(rdiff)
Absgdiff := ABS(gdiff)
Absbdiff := ABS(bdiff)
variance := ( Absrdiff + Absgdiff + Absbdiff )

return variance
}



