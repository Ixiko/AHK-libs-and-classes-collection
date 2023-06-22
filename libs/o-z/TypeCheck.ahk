typecheck:
ctg := typ := "ukn"
;================================================================
;	EXECUTABLE
;================================================================
if (e_magic & 0xFFFF = 0x5A4D)			; Magic number (MZ)
	{
	ctg=exe							; set category to 'executable'
	reloc := NumGet(hdr, 24, "UShort")	; relocation table offset (0x40 for NE, LE, LX, W3, PE etc)
	if reloc != 0x40					; we got an old DOS executable
		{
		typ=OLD
		fdesc=old DOS executable
		newsz := NumGet(hdr, 2, "UShort")+512*(NumGet(hdr, 4, "UShort")-1)
		ext=exe
		fail := FALSE
		return
		}
	e_lfanew := NumGet(hdr, 60, "UInt")	; PE header offset
	if (e_lfanew >= fsz-4)
		{
		fdesc=corrupt DOS hdr
		ext=com
		return
		}
	else if (e_lfanew >= 500)			; we got a large DOS header
		{
		i := e_lfanew+248
		FileRead, hdr, *m%i% *c %myfile%	; read the large executable file header
		}
	hdr2 := &hdr+e_lfanew				; PE header address
	SetFormat, Integer, H
	sig := NumGet(hdr2+0, 0, "UInt")
	SetFormat, Integer, D
	if sig = 0x4550					; PE signature (PE)
		{
		typ=PE						; set type to 'PE'
		fdesc=PE exec (EXE)
		}
	else if sig = 0x454E					; NE signature (NE)
		{
		typ=NE
		fdesc=NE exec (DRV)
		ext=drv
		}
	else if sig = 0x454C					; LE signature (LE)
		{
		typ=LE
		fdesc=LE exec (VXD)
		ext=vxd
		}
	else fdesc=unknown executable (magic %e_magic% signature %sig%)
	}
;================================================================
;	ARCHIVER
;================================================================
else if (e_magic = 0x04034B50)				; zip signature (PK..)
	{
	ctg=arc
	typ=ZIP
	fdesc=ZIP archive
	ext=zip
	}
else if (e_magic = 0xAFBC7A37 && NumGet(hdr, 4, "UShort")=0x1C27)	; 7-zip signature (7z)
	{
	ctg=arc
	typ=7Z
	fdesc=7-ZIP archive
	ext=7z
	newsz := NumGet(hdr, 12, "UInt")+0x40	; this is size without header+header size (guessed)
	fail := FALSE
	}
else if e_magic = 0x21726152				; RAR signature (Rar!)
	{
	ctg=arc
	typ=RAR
	fdesc=RAR archive
	ext=rar
	}
else if (e_magic & 0xFFFF = 0x8B1F)			; gz signature
	{
	ctg=arc
	typ=GZ
	fdesc=GZ archive
	ext=gz
	}
else if e_magic = 0x00088B1F				; tgz signature
	{
	ctg=arc
	typ=TGZ
	fdesc=TGZ archive
	ext=tgz
	}
else if e_magic = 0x08088B1F				; tar.gz signature
	{
	ctg=arc
	typ=TARGZ
	fdesc=TAR.GZ archive
	ext=tar.gz
	}
else if i := SubStr(hdr, 3, 5) in -lh0-,-lh1-,-lh2-,-lh3-,-lh4-,-lh5-,-lh6-,-lh7-,-lhd-,-lhs-
	{
	ctg=arc
	typ=LZH
	fdesc=LZH archive
	ext=lzh
	}
else if (e_magic & 0xFFFFFF = 0x414855)		; uha signature (UHA.)
	{
	ctg=arc
	typ=UHA
	fdesc := "UHarc archive v0." ((e_magic>>24) &0xFF)
	ext=uha
	}
else if (e_magic = 0x204F4F5A && NumGet(hdr, 20, "UInt")=0xFDC4A7DC)		; zoo signature (ZOO )
	{
	ctg=arc
	typ=ZOO
	fdesc := SubStr(hdr, 1, 20)
	ext=zoo
	}
;================================================================
;	PICTURE
;================================================================
else if (e_magic & 0xFFFF = 0x4D42)			; bitmap signature (BM)
	{
	ctg=img
	typ=BMP
	fdesc=Bitmap image
	ext=bmp
	i := NumGet(hdr, 2, "UInt")
	if (i <= fsz)
		{
		newsz := i
		fail := FALSE
		}
	}
else if e_magic = 0x38464947				; GIF signature (GIF8) + '7a' or '9a'
	{
	ctg=img
	typ=GIF
	fdesc=GIF image
	ext=gif
	}
else if (e_magic & 0xFFFF = 0xD8FF)			; JPEG signature
	{
	ctg=img
	typ=JPG
	fdesc=JPEG image
	ext=jpg
	}
else if (e_magic = 0x474E5089 && NumGet(hdr, 4, "UInt")=0x0A1A0A0D)	; PNG signature (‰PNG)
	{
	ctg=img
	typ=PNG
	fdesc=PNG image
	ext=png
	}
else if (e_magic & 0xFFFFFF = 0x2A4949 OR e_magic & 0xFFFFFF = 0x2A4D4D)	; TIFF signature (II or MM)
	{
	ctg=img
	typ=TIF
	fdesc=TIFF image
	ext=tif
	}
;================================================================
;	VIDEO
;================================================================
else if (e_magic = 0x18000000 OR e_magic = 0x1C000000 OR e_magic = 0x20000000)	; video signature (ISO, MP4)
	{
	ctg=vid
	if NumGet(hdr, 4, "UInt")=0x70797466	; fourcc 'ftyp'
		vidtype := NumGet(hdr, 8, "UInt")	; mp42 or something
	fdesc=video %vidtype%
	ext=mp4
	}
else if (e_magic & 0xFFFFFF = 0x535743)				; Compressed Flash signature (CWS)+version byte
	{
	ctg=vid
	vidtype := (e_magic & 0xFF000000) >> 24
	fdesc=Adobe Flash video v%vidtype%
	ext=swf
	newsz := NumGet(hdr, 4, "UInt")	; this is uncompressed size, not file size !!!
	}
else if (e_magic & 0xFFFFFF = 0x535746)				; Uncompressed Flash signature (FWS)+version byte
	{
	ctg=vid
	vidtype := (e_magic & 0xFF000000) >> 24
	fdesc=Adobe Flash video v%vidtype%
	ext=swf
	newsz := NumGet(hdr, 4, "UInt")					; this is true file size for uncompressed Flash
	fail := FALSE
	}
;================================================================
;	AUDIO
;================================================================
else if e_magic = 0x5367674F				; Ogg signature (OggS)
	{
	ctg=aud
	typ=OGG
	fdesc=OGG audio
	ext=ogg
	}
else if (e_magic & 0xFFFFFF= 0x334449)		; MP3 signature (ID3)
	{
	ctg=aud
	typ=MP3
	fdesc=MP3 audio
	ext=mp3
	}
else if (e_magic = 0x46464952 && NumGet(hdr, 8, "UInt")=0x45564157)	; Wave signature (RIFF ....WAVE)
	{
	ctg=aud
	typ=WAV
	fdesc=Wave audio
	ext=wav
	}
;================================================================
;	DATABASE
;================================================================
else if (e_magic & 0xFF = 0x30)		; DBF signature
	{
	ctg=db
	typ=DBF
	r := NumGet(hdr, 1, "UChar")
	i := NumGet(hdr, 3, "UChar") "." NumGet(hdr, 2, "UChar") "." (r > 90 ? "19" : "20") SubStr("0" r, -1)
	fdesc=FoxPro database (DBF) created %i%
	ext=dbf
	newsz := NumGet(hdr, 8, "UShort")+NumGet(hdr, 10, "UShort")*NumGet(hdr, 4, "UShort")+1	; to check !
	fail := FALSE
	}
else if (e_magic = 0x00000400)		; CDX signature
	{
	ctg=db
	typ=CDX
	fdesc=FoxPro database (CDX)
	ext=cdx
	newsz := 256*NumGet(hdr, 12, "UChar")+NumGet(hdr, 13, "UChar")
	fail := FALSE
	}
else if (e_magic = 0x00000002)		; DDD profile signature
	{
	i := DllCall("MulDiv", Ptr, &hdr+4, "Int", 1, "Int", 1, AStr)
	if i=This is a DDD generated Profile.
		{
		ctg=db
		typ=DDD
		fdesc=Hitachi Drive Fitness Test profile
		ext=bin
		}
	}
else if (e_magic = 0x636E695A)		; Zinc Data File signature
	{
	i := DllCall("MulDiv", Ptr, &hdr, "Int", 1, "Int", 1, AStr)
	if InStr(i, "Zinc Data File")=1
		{
		ctg=db
		typ=ZDF
		fdesc := SubStr(i, 1, 18)
		ext=znc
		}
	}
;================================================================
;	DOCUMENT
;================================================================
else if (e_magic & 0xFFFF = 0x5F3F)			; HLP signature (?_)
	{
	ctg=doc
	typ=HLP
	fdesc=HLP help
	ext=hlp
	}
else if e_magic = 0x46535449				; CHM signature (ITSF)
	{
	ctg=doc
	typ=CHM
	fdesc=CHM help
	ext=chm
	}
else if e_magic = 0x46445025				; PDF signature (%PDF)
	{
	ctg=doc
	typ=PDF
	fdesc=PDF document
	ext=pdf
	}
else if e_magic = 0xE011CFD0				; MSI signature (D0CF11E0)
	{
	ctg=doc
	typ=MS
	r := NumGet(hdr, 4, "UInt")
	if r=0xE11AB1A1						; MS Office DOC or MSI archive
		{
		fdesc=MS Word/MSI
		ext=msi
		}
	else fdesc=some MS file
	}
;================================================================
;	SCRIPT LANGUAGE (C/C++/C#/js/PHP/HTML/AHK/AU3/etc)
;================================================================
else if InStr(hdr, "function(") OR InStr(hdr, "this.") OR InStr(hdr, "jQuery")
	{
	ctg=scr
	typ=JS
	fdesc=javascript
	ext=js
	}
;================================================================
;	PLAIN TEXT
;================================================================
else if (e_magic >= 0x20202020 && (e_magic & 0xFFFF < 0xFEFF))		; plain text signature possibly
	{
	ctg=txt
	typ=TXT
	fdesc=plain text
	ext=txt
	}
else if (e_magic & 0xFFFF = 0xFEFF OR e_magic & 0xFFFF = 0xFFFE)	; Unicode UTF-16 text
	{
	ctg=txt
	typ=UNI
	fdesc=Unicode UTF-16 text
	ext=txt
	}
; ISO has a block of 0x8000 zeroes, then 01 43 44 30 30 31 01 (.CD001.)
return
