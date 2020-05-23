isBinFile(Filename,NumBytes=32,Minimum=4,complexunicode=1) {
	
	file:=FileOpen(Filename,"r")
	file.Position:=0 ;force position to 0 (zero)
	nbytes:=file.RawRead(rawbytes,NumBytes) ;read bytes
	file.Close() ;close file
	
	if (nbytes < Minimum) ;recommended 4 minimum for unicode detection
		return 0 ;asume text file, if too short
	
	t:=0, i:=0, bytes:=[] ;Initialize vars
	
	loop % nbytes ;create c-style bytes array
		bytes[(A_Index-1)]:=Numget(&rawbytes,(A_Index-1),"UChar")
	
	;determine BOM if possible/existant
	if (bytes[0]=0xFE && bytes[1]=0xFF)
		|| (bytes[0]=0xFF && bytes[1]=0xFE)
		return 0 ;text Utf-16 BE/LE file
	if (bytes[0]=0xEF && bytes[1]=0xBB && bytes[2]=0xBF)
		return 0 ;text Utf-8 file
	if (bytes[0]=0x00 && bytes[1]=0x00
		&& bytes[2]=0xFE && bytes[3]=0xFF)
		|| (bytes[0]=0xFF && bytes[1]=0xFE
		&& bytes[2]=0x00 && bytes[3]=0x00)
		return 0 ;text Utf-32 BE/LE file
		
	while(i<nbytes) {	
		;// ASCII
		if( bytes[i] == 0x09 || bytes[i] == 0x0A || bytes[i] == 0x0D
			|| (0x20 <= bytes[i] && bytes[i] <= 0x7E) ) {
			i += 1
			continue
		}
		;// non-overlong 2-byte
		if( (0xC2 <= bytes[i] && bytes[i] <= 0xDF)
			&& (0x80 <= bytes[i+1] && bytes[i+1] <= 0xBF) ) {
			i += 2
			continue
		}
		;// excluding overlongs, straight 3-byte, excluding surrogates
		if( ( bytes[i] == 0xE0 && (0xA0 <= bytes[i+1] && bytes[i+1] <= 0xBF)
			&& (0x80 <= bytes[i+2] && bytes[i+2] <= 0xBF) )
			|| ( ((0xE1 <= bytes[i] && bytes[i] <= 0xEC)
			|| bytes[i] == 0xEE || bytes[i] == 0xEF)
			&& (0x80 <= bytes[i+1] && bytes[i+1] <= 0xBF)
			&& (0x80 <= bytes[i+2] && bytes[i+2] <= 0xBF) 	)
			|| ( bytes[i] == 0xED && (0x80 <= bytes[i+1] && bytes[i+1] <= 0x9F)
			&& (0x80 <= bytes[i+2] && bytes[i+2] <= 0xBF) ) ) {
			i += 3
			continue
		}
		;// planes 1-3, planes 4-15, plane 16
		if( ( bytes[i] == 0xF0 && (0x90 <= bytes[i+1] && bytes[i+1] <= 0xBF)
			&& (0x80 <= bytes[i+2] && bytes[i+2] <= 0xBF)
			&& (0x80 <= bytes[i+3] && bytes[i+3] <= 0xBF) )
			|| ( (0xF1 <= bytes[i] && bytes[i] <= 0xF3)
			&& (0x80 <= bytes[i+1] && bytes[i+1] <= 0xBF)
			&& (0x80 <= bytes[i+2] && bytes[i+2] <= 0xBF)
			&& (0x80 <= bytes[i+3] && bytes[i+3] <= 0xBF) )
			|| ( bytes[i] == 0xF4 && (0x80 <= bytes[i+1] && bytes[i+1] <= 0x8F)
			&& (0x80 <= bytes[i+2] && bytes[i+2] <= 0xBF)
			&& (0x80 <= bytes[i+3] && bytes[i+3] <= 0xBF) ) ) {
			i += 4
			continue
		}
		t:=1
		break
	}
	
	if (t=0) ;the while-loop has no fails, then confirmed utf-8
		return 0
	;else do nothing and check again with the classic method below
	
	loop, %nbytes% {
		if (bytes[(A_Index-1)]<9) or (bytes[(A_Index-1)]>126)
			or ((bytes[(A_Index-1)]<32) and (bytes[(A_Index-1)]>13))
			return 1
	}
	
	return 0
}
