; _libGoogleEarth.ahk  version 1.25
; by David Tryse   davidtryse@gmail.com
; http://david.tryse.net/googleearth/
; http://code.google.com/p/googleearth-autohotkey/
; License:  GPLv2+
; 
; Script for AutoHotkey   ( http://www.autohotkey.com/ )
; This file contains functions for:
; * reading / setting coordinates for Google Earth (moved to _libGoogleEarthCOM.ahk)
; * converting different format coordinates
; * reading/writing Exif GPS coordinates from JPEG files
; 
; Needs ws4ahk.ahk library:  http://www.autohotkey.net/~easycom/ (only in _libGoogleEarthCOM.ahk)
; Functions for Exif GPS data needs exiv2.exe:  http://www.exiv2.org/
; 
; The script uses the Google Earth COM API  ( http://earth.google.com/comapi/ ) (only in _libGoogleEarthCOM.ahk)
;
; Version history:
; 1.25   -   fix descript.ion functions to handle filenames with () brackets, swap cmdret.dll for builtin function to capture command output, some coord conversion fixes
; 1.24   -   fix IsGErunning()
; 1.23   -   fix IsGErunning() and ImageDim()
; 1.22   -   split into _libGoogleEarth.ahk and _libGoogleEarthCOM.ahk (avoid loading Windows Scripting env and COM API functions in LatLongConversion/GoogleEarthTiler)
; 	     -   fix non-cmdret.dll captureOutput() function
; 1.21   -   IsGEinit() function to check if Google Earth is initialized (returns 0 if logged out from server, 1 if ready & starts GE if not already running)
; 1.20   -   fix for exiv2.exe in path containing space (thanks Jim Smith for bug report)
; 1.19   -   new functions : GetJPEGComment, SetJPEGComment, WriteFileDescription, SetXmpTag, GetXmpTag
; 1.18   -   fix IsGErunning() for Google Earth Pro / add GEtimePlay() & GEtimePause() functions to control time-slider (GE builtin time-control is hidden when recording movies)
; 1.17   -   update ImageDim() to use byref parameters, update Deg2Dec() to understand "degrees", "minutes", "seconds" etc.
; 1.16   -   added FileDescription() function (only reads descript.ion atm, not jpeg comment)
; 1.15   -   Fix for localized OS with "," instead of "." as decimal separator (thanks Antti Rasi)
; 1.14   -   remake Deg2Dec() to understand when Lat and Long are different format - one is Deg Min and one Deg Min Sec etc.
; 1.13   -   make Deg2Dec() understand "Deg Min" and "Deg" formats in addition to Deg Min Sec
; 1.12   -   added ImageDim() function to get image width/height using imagemagick (or plain autohotkey if identify.exe can't be found - slow..)
; 1.11   -   added GetGEpoint() function to read Altitude from GE * added GetPhotoLatLongAlt()/SetPhotoLatLongAlt() functions to read/write JPEG Altitude Exif



#NoEnv

; ================================================================== COORDINATE CONVERSION ==================================================================

; call with latvar=Deg2Dec(coord,"lat") or longvar=Deg2Dec(coord,"long") - no 2nd param returns lat, long
; Input should be Degrees Minutes Seconds in any of these formats:
;    8 deg 32' 54.73" South	119 deg 29' 28.98" East
;    8°32'54.73"S, 119°29'28.98"E
;    8:32:54S,119:29:28E
; Output: -8.548333, 119.491383
Deg2Dec(DegCoord, mode = "both") {
	StringReplace DegCoord,DegCoord,and,%A_Space%,All	; replace all possible separators with space before StringSplit
	StringReplace DegCoord,DegCoord,`,,%A_Space%,All
	StringReplace DegCoord,DegCoord,’,,%A_Space%,All
	StringReplace DegCoord,DegCoord,degrees,%A_Space%,All
	StringReplace DegCoord,DegCoord,degree,%A_Space%,All
	StringReplace DegCoord,DegCoord,degs,%A_Space%,All
	StringReplace DegCoord,DegCoord,deg,%A_Space%,All
	StringReplace DegCoord,DegCoord,d,%A_Space%,All
	StringReplace DegCoord,DegCoord,°,%A_Space%,All
	StringReplace DegCoord,DegCoord,º,%A_Space%,All
	StringReplace DegCoord,DegCoord,`;,%A_Space%,All
	StringReplace DegCoord,DegCoord,minutes,%A_Space%,All
	StringReplace DegCoord,DegCoord,minute,%A_Space%,All
	StringReplace DegCoord,DegCoord,mins,%A_Space%,All
	StringReplace DegCoord,DegCoord,min,%A_Space%,All
	StringReplace DegCoord,DegCoord,m,%A_Space%,All
	StringReplace DegCoord,DegCoord,',%A_Space%,All
	StringReplace DegCoord,DegCoord,seconds,%A_Space%,All
	StringReplace DegCoord,DegCoord,second,%A_Space%,All
	StringReplace DegCoord,DegCoord,secs,%A_Space%,All
	StringReplace DegCoord,DegCoord,sec,%A_Space%,All
	StringReplace DegCoord,DegCoord,`",%A_Space%,All
	StringReplace DegCoord,DegCoord,:,%A_Space%,All
	StringReplace DegCoord,DegCoord,(,%A_Space%,All
	StringReplace DegCoord,DegCoord,),%A_Space%,All
	StringReplace DegCoord,DegCoord,South,S
	StringReplace DegCoord,DegCoord,North,N
	StringReplace DegCoord,DegCoord,East,E
	StringReplace DegCoord,DegCoord,West,W
	StringReplace DegCoord,DegCoord,S,%A_Space%S		; add space before south/west/north/east to separate as a new word
	StringReplace DegCoord,DegCoord,N,%A_Space%N
	StringReplace DegCoord,DegCoord,E,%A_Space%E
	StringReplace DegCoord,DegCoord,W,%A_Space%W
	StringReplace DegCoord,DegCoord,%A_Tab%,%A_Space%,All
	Loop {  		 	; loop to replace all double spaces (otherwise StringSplit wont work properly)
		StringReplace DegCoord,DegCoord,%A_Space%%A_Space%,%A_Space%,All UseErrorLevel
		if ErrorLevel = 0 	; No more replacements needed.
			break
	}
	DegCoord = %DegCoord% 		; remove start/end spaces
	Lat :=
	Loop, parse, DegCoord, %A_Space%,
	{
		if (A_Index = 1)
			LatD := A_LoopField
		else if (A_Index = 2) and (A_LoopField = "S")	; format is Deg
			Lat := LatD * -1
		else if (A_Index = 2) and (A_LoopField = "N")	; format is Deg
			Lat := LatD * 1
		else if (A_Index = 2)
			LatM := A_LoopField
		else if (A_Index = 3) and (A_LoopField = "S")	; format is Deg Min
			Lat := (LatD + LatM/60) * -1
		else if (A_Index = 3) and (A_LoopField = "N")	; format is Deg Min
			Lat := (LatD + LatM/60) * 1
		else if (A_Index = 3)
			LatS := A_LoopField
		else if (A_Index = 4) and (A_LoopField = "S")	; format is Deg Min Sec
			Lat := (LatD + LatM/60 + LatS/60/60) * -1
		else if (A_Index = 4) and (A_LoopField = "N")	; format is Deg Min Sec
			Lat := (LatD + LatM/60 + LatS/60/60) * 1
		if (A_Index = 4 and not Lat)
			return "error"
		if (Lat) {
			LatEnd := A_Index		; save where Latitude ends - for Longitude loop
			Break
		}
	}
	Long :=
	Loop, parse, DegCoord, %A_Space%,
	{
		if (A_Index = LatEnd+1)
			LongD := A_LoopField
		else if (A_Index = LatEnd+2) and (A_LoopField = "W")	; format is Deg
			Long := LongD * -1
		else if (A_Index = LatEnd+2) and (A_LoopField = "E")	; format is Deg
			Long := LongD * 1
		else if (A_Index = LatEnd+2)
			LongM := A_LoopField
		else if (A_Index = LatEnd+3) and (A_LoopField = "W")	; format is Deg Min
			Long := (LongD + LongM/60) * -1
		else if (A_Index = LatEnd+3) and (A_LoopField = "E")	; format is Deg Min
			Long := (LongD + LongM/60) * 1
		else if (A_Index = LatEnd+3)
			LongS := A_LoopField
		else if (A_Index = LatEnd+4) and (A_LoopField = "W")	; format is Deg Min Sec
			Long := (LongD + LongM/60 + LongS/60/60) * -1
		else if (A_Index = LatEnd+4) and (A_LoopField = "E")	; format is Deg Min Sec
			Long := (LongD + LongM/60 + LongS/60/60) * 1
		if (A_Index = LatEnd+4 and not Long)
			return "error"
		if (Long) {
			Break
		}
	}
	If mode = lat
		return Lat
	If mode = long
		return Long
	If mode = both
		return Lat ", " Long
}

; call with latvar=Deg2Dec(decimalcoord,"lat") or latlong=Dec2Deg("-10.4949666667,105.5996")
; Input: -10.4949666667  105.5996   or    -10.4949666667,105.5996
; Output: 10° 29' 41.88'' S, 105° 35' 58.56'' E
Dec2Deg(DecCoord, mode = "both") {
	StringReplace DecCoord,DecCoord,`",%A_Space%,All
	StringReplace DecCoord,DecCoord,`,,%A_Space%,All
	StringReplace DecCoord,DecCoord,:,%A_Space%,All
	StringReplace DecCoord,DecCoord,%A_Tab%,%A_Space%,All
	Loop {   ; loop to replace all double spaces (otherwise StringSplit wont work properly)
		StringReplace DecCoord,DecCoord,%A_Space%%A_Space%,%A_Space%,All UseErrorLevel
		if ErrorLevel = 0  ; No more replacements needed.
			break
	}
	DecCoord = %DecCoord%  ; remove start/end spaces
	StringSplit word, DecCoord, %A_Space%`,%A_Tab%
	LatDeg := Floor(word1**2**0.5)
	LatMin := Floor((word1**2**0.5 - LatDeg) * 60)
	LatSec := Round((word1**2**0.5 - LatDeg - LatMin/60) * 60 * 60,2)
	LatPol = N
	If (word1 < 0)
		LatPol = S
	Lat := LatDeg "° " LatMin "' " LatSec "'' " LatPol
	LongDeg := Floor(word2**2**0.5)
	LongMin := Floor((word2**2**0.5 - LongDeg) * 60)
	LongSec := Round((word2**2**0.5 - LongDeg - LongMin/60) * 60 * 60,2)
	LongPol = E
	If (word2 < 0)
		LongPol = W
	Long := LongDeg "° " LongMin "' " LongSec "'' " LongPol
	If mode = lat
		return Lat
	If mode = long
		return Long
	If mode = both
		return Lat ", " Long
}

; call with latvar=Deg2Rel(deccoord,"lat") or latlong=Dec2Deg(deccoord)
; Input: -0.932269, -78.605725
; Output: 0/1 55/1 5617/100, 78/1 36/1 2061/10       (useful for raw Exif GPS)
Dec2Rel(DecCoord, mode = "both") {
	StringReplace DecCoord,DecCoord,`",%A_Space%,All
	StringReplace DecCoord,DecCoord,`,,%A_Space%,All
	StringReplace DecCoord,DecCoord,:,%A_Space%,All
	StringReplace DecCoord,DecCoord,%A_Tab%,%A_Space%,All
	Loop {   ; loop to replace all double spaces (otherwise StringSplit wont work properly)
		StringReplace DecCoord,DecCoord,%A_Space%%A_Space%,%A_Space%,All UseErrorLevel
		if ErrorLevel = 0  ; No more replacements needed.
			break
	}
	DecCoord = %DecCoord%
	StringSplit word, DecCoord, %A_Space%`,%A_Tab%
	LatDeg := Floor(word1**2**0.5)
	LatMin := Floor((word1**2**0.5 - LatDeg) * 60)
	LatSec := Round((word1**2**0.5 - LatDeg - LatMin/60) * 60 * 60 * 100,0)
	Lat := LatDeg "/1 " LatMin "/1 " LatSec "/100"
	LongDeg := Floor(word2**2**0.5)
	LongMin := Floor((word2**2**0.5 - LongDeg) * 60)
	LongSec := Round((word2**2**0.5 - LongDeg - LongMin/60) * 60 * 60 * 100,0)
	Long := LongDeg "/1 " LongMin "/1 " LongSec "/100"
	If mode = lat
		return Lat
	If mode = long
		return Long
	If mode = both
		return Lat ", " Long
}

; ================================================================== GOOGLE EARTH FUNCTIONS ==================================================================

; simple check if the Google Earth client is running or not
IsGErunning() {
	SetTitleMatchMode 2	; change from 3 to 2 to match also Google Earth Pro etc. - thanks Marty Michener
	; If WinExist("Google Earth") and WinExist("ahk_class QWidget", "LayerWidget")
	If WinExist("Google Earth ahk_class QWidget")
	    return 1
	return 0
}

; ================================================================== JPEG EXIF GPS FUNCTIONS ==================================================================

;call with GetPhotoLatLong(fullfilename, FocusPointLatitude, FocusPointLongitude) or GetPhotoLatLong(fullfilename, FocusPointLatitude, FocusPointLongitude, "c:\prog\exiv2\exiv2.exe")
GetPhotoLatLong(fullfilename, byref FocusPointLatitude, byref FocusPointLongitude, toolpath = "exiv2.exe") {
	GetPhotoLatLongAlt(fullfilename, FocusPointLatitude, FocusPointLongitude, PointAltitude, toolpath)
	PointAltitude :=
}

;call with GetPhotoLatLong(fullfilename, FocusPointLatitude, FocusPointLongitude, PointAltitude) or GetPhotoLatLong(fullfilename, FocusPointLatitude, FocusPointLongitude, PointAltitude, "c:\prog\exiv2\exiv2.exe")
GetPhotoLatLongAlt(fullfilename, byref FocusPointLatitude, byref FocusPointLongitude, byref PointAltitude, toolpath = "exiv2.exe") {
	IfNotExist %fullfilename%
		return 2
	SplitPath fullfilename, filename, dir
	If (toolpath = "gpsini") {
		IniRead Pos, %dir%\gps.ini, %filename%, GPS Position
		FocusPointLatitude	:= Deg2Dec(Pos,"lat")
		FocusPointLongitude	:= Deg2Dec(Pos,"long")
	} else {
		CMD := """" toolpath """ -u -Pkt """ fullfilename """"
		StrOut := captureOutput(CMD)
		Loop, parse, StrOut, `n`r
		{
			If (SubStr(A_LoopField, 1, 28) = "Exif.GPSInfo.GPSLatitudeRef ") {
				LatRef := SubStr(A_LoopField, 30)
				LatRef = %LatRef%
			}
			If (SubStr(A_LoopField, 1, 25) = "Exif.GPSInfo.GPSLatitude ") {
				Lat := SubStr(A_LoopField, 30)
				Lat = %Lat%
			}
			If (SubStr(A_LoopField, 1, 29) = "Exif.GPSInfo.GPSLongitudeRef ") {
				LongRef := SubStr(A_LoopField, 30)
				LongRef = %LongRef%
			}
			If (SubStr(A_LoopField, 1, 26) = "Exif.GPSInfo.GPSLongitude ") {
				Long := SubStr(A_LoopField, 30)
				Long = %Long%
			}
			If (SubStr(A_LoopField, 1, 28) = "Exif.GPSInfo.GPSAltitudeRef ") {
				AltRef := SubStr(A_LoopField, 30)
				AltRef = %AltRef%
			}
			If (SubStr(A_LoopField, 1, 25) = "Exif.GPSInfo.GPSAltitude ") {
				Alt := SubStr(A_LoopField, 30)
				StringReplace Alt,Alt, m,
				Alt = %Alt%
			}
		}
		FocusPointLatitude	:= Deg2Dec(Lat " " LatRef ", " Long " " LongRef, "lat")
		FocusPointLongitude	:= Deg2Dec(Lat " " LatRef ", " Long " " LongRef, "long")
		If (AltRef = "Below sea level")
			Alt := Round(-Alt,1)
		PointAltitude		:= Alt
	}
}

;call with SetPhotoLatLong(fullfilename, FocusPointLatitude, FocusPointLongitude)
SetPhotoLatLong(fullfilename, FocusPointLatitude, FocusPointLongitude, toolpath = "exiv2.exe") {
	SetPhotoLatLongAlt(fullfilename, FocusPointLatitude, FocusPointLongitude,"",toolpath)
}

;call with SetPhotoLatLongAlt(fullfilename, FocusPointLatitude, FocusPointLongitude, FocusPointAltitude)
;EXIV2 commandline like:   exiv2.exe -M"set Exif.GPSInfo.GPSVersionID 2 2 0 0" -M"set Exif.GPSInfo.GPSLatitude 13/1 28/1 3208/100" -M"set Exif.GPSInfo.GPSLatitudeRef N" -M"set Exif.GPSInfo.GPSLongitude 103/1 29/1 3490/100" -M"set Exif.GPSInfo.GPSLongitudeRef E" -M"set Exif.GPSInfo.GPSAltitude 1810/100" -M"set Exif.GPSInfo.GPSAltitudeRef 0" "image.jpg"
SetPhotoLatLongAlt(fullfilename, FocusPointLatitude, FocusPointLongitude, FocusPointAltitude, toolpath = "exiv2.exe") {
	IfNotExist %fullfilename%
		return 2
	SplitPath fullfilename, filename, dir
	If (FocusPointLatitude < 0)
		LatRef = S
	Else
		LatRef = N
	If (FocusPointLongitude < 0)
		LongRef = W
	Else
		LongRef = E
	LatRel := Dec2Rel(FocusPointLatitude ", " FocusPointLongitude, "lat")
	LongRel := Dec2Rel(FocusPointLatitude ", " FocusPointLongitude, "long")
	AltRel := Round(FocusPointAltitude * 100,0) "/100"
	IfEqual FocusPointAltitude
		CMD := """" toolpath """ -M""set Exif.GPSInfo.GPSVersionID 2 2 0 0"" -M""set Exif.GPSInfo.GPSLatitude " LatRel """ -M""set Exif.GPSInfo.GPSLatitudeRef " LatRef """ -M""set Exif.GPSInfo.GPSLongitude " LongRel """ -M""set Exif.GPSInfo.GPSLongitudeRef " LongRef """ -M""del Exif.GPSInfo.GPSAltitudeRef"" -M""del Exif.GPSInfo.GPSAltitude"" """ fullfilename """"
	Else
		CMD := """" toolpath """ -M""set Exif.GPSInfo.GPSVersionID 2 2 0 0"" -M""set Exif.GPSInfo.GPSLatitude " LatRel """ -M""set Exif.GPSInfo.GPSLatitudeRef " LatRef """ -M""set Exif.GPSInfo.GPSLongitude " LongRel """ -M""set Exif.GPSInfo.GPSLongitudeRef " LongRef """ -M""set Exif.GPSInfo.GPSAltitude " AltRel """ -M""set Exif.GPSInfo.GPSAltitudeRef 0"" """ fullfilename """"
	StrOut := captureOutput(CMD)
		;Msgbox, 48, Error, %StrOut%`n`nCommand line:`n`n%CMD%
}

;call with ErasePhotoLatLong(fullfilename)
ErasePhotoLatLong(fullfilename, toolpath = "exiv2.exe") {
	IfNotExist %fullfilename%
		return 2
	SplitPath fullfilename, filename, dir
	CMD := """" toolpath """ -M""del Exif.GPSInfo.GPSVersionID"" -M""del Exif.GPSInfo.GPSLatitude"" -M""del Exif.GPSInfo.GPSLatitudeRef"" -M""del Exif.GPSInfo.GPSLongitude"" -M""del Exif.GPSInfo.GPSLongitudeRef"" -M""del Exif.GPSInfo.GPSAltitudeRef"" -M""del Exif.GPSInfo.GPSAltitude"" -M""del Exif.GPSInfo.GPSTrack"" """ fullfilename """"
	StrOut := captureOutput(CMD)
}

; ================================================================== OTHER JPEG EXIF/XMP etc. FUNCTIONS ==================================================================

;call with GetExif(fullfilename, ExifDataOutputVar)
GetExif(fullfilename, byref StrOut, toolpath = "exiv2.exe") {
	IfNotExist %fullfilename%
		return 2
	SplitPath fullfilename, filename, dir
	CMD := """" toolpath """ -Pkt """ fullfilename """"
	StrOut := captureOutput(CMD)
}

;call with GetJPEGComment(fullfilename, JPEGCommentOutputVar)
GetJPEGComment(fullfilename, byref StrOut, toolpath = "exiv2.exe") {
	IfNotExist %fullfilename%
		return 2
	SplitPath fullfilename, filename, dir
	CMD := """" toolpath """ -pc """ fullfilename """"
	StrOut := captureOutput(CMD)
	StrOut := RegExReplace(StrOut, "\r\n$", "") ; strip newline at the end
}

;call with SetJPEGComment(fullfilename, newComment)
SetJPEGComment(fullfilename, newComment, toolpath = "exiv2.exe") {
	IfNotExist %fullfilename%
		return 2
	SplitPath fullfilename, filename, dir
	IfEqual, newComment,
	{
		CMD := """" toolpath """ -dc """ fullfilename """"	; delete comment
		StrOut := captureOutput(CMD)
		IfNotEqual, StrOut,
			return 1
	}
	StringReplace, newComment, newComment, `", \`", All		; add \ before any double quotes
	CMD := """" toolpath """ -c """ newComment """ """ fullfilename """"
	StrOut := captureOutput(CMD)
	IfNotEqual, StrOut,
		return 1
}

;call with SetXmpTag(fullfilename, tagname, tagdata)
SetXmpTag(fullfilename, tagname, tagdata, toolpath = "exiv2.exe") {
	IfNotExist %fullfilename%
		return 2
	SplitPath fullfilename, filename, dir
	StringReplace, tagname, tagname, `", \`", All		; add \ before any double quotes
	StringReplace, tagdata, tagdata, `", \`", All		; add \ before any double quotes
	IfEqual, tagdata,
		CMD := """" toolpath """ -M""del Xmp.xmp." tagname """ """ fullfilename """"	; delete tag
	Else
		CMD := """" toolpath """ -M""set Xmp.xmp." tagname " " tagdata """ """ fullfilename """"
	StrOut := captureOutput(CMD)
	IfNotEqual, StrOut,
		return 1
}

;call with GetXmpTag(fullfilename, tagname, XMPtagOutputVar)
GetXmpTag(fullfilename, tagname, byref XMPtagOutputVar, toolpath = "exiv2.exe") {
	IfNotExist %fullfilename%
		return 2
	SplitPath fullfilename, filename, dir
	StringReplace, tagname, tagname, `", \`", All		; add \ before any double quotes
	CMD := """" toolpath """ -px """ fullfilename """"
	StrOut := captureOutput(CMD)
	XMPtagOutputVar =
	Loop, parse, StrOut, `n`r
	{
		If (SubStr(A_LoopField, 1, 9+StrLen(tagname)) = "Xmp.xmp." tagname " ") {
			XMPtagOutputVar := SubStr(A_LoopField, 60)
			XMPtagOutputVar = %XMPtagOutputVar%
		}
	}
}

ImageDim(fullfilename, byref ImgWidth, byref ImgHeight, ImageMagickTool = "", skipifnoIM = "0") {
	IfNotExist %fullfilename%
		return 2
	SplitPath fullfilename, filename, dir
	If not (ImageMagickTool)
		ImageMagickTool := findFile("identify.exe")
	If (ImageMagickTool) {
		CMD := """" ImageMagickTool """ -quiet -ping -format ""%wx%hx"" """ fullfilename """" ; shows 640x480x - 2nd x to avoid including linefeed when splitting string below
		StrOut := captureOutput(CMD)
		If (SubStr(StrOut, 1, 12) == "identify.exe") {
			return 3
		} else {
			StringSplit, ImgXYtmp, StrOut, x ; split string on x
			ImgWidth = %ImgXYtmp1%
			ImgHeight = %ImgXYtmp2%
			return 0
		}
	} else if not (skipifnoIM) {
		DHW:=A_DetectHiddenWindows
		DetectHiddenWindows, ON
		Gui, 99:-Caption
		Gui, 99:Margin, 0, 0
		Gui, 99:Show,Hide w2592 h2592, ImageWxH.Temporary.GUI
		Gui, 99:Add, Picture, x0 y0 , %fullfilename%
		Gui, 99:Show,AutoSize Hide, ImageWxH.Temporary.GUI
		WinGetPos, , ,ImgWidth,ImgHeight, ImageWxH.Temporary.GUI
		Gui, 99:Destroy
		DetectHiddenWindows, %DHW%
		return 0
	}
}

; read file description (from descript.ion file)
FileDescription(FileFullname) {
  SplitPath, FileFullname, Name, Dir
  FileRead, DescriptIon, %Dir%\descript.ion
  Name := RegExReplace(RegExReplace(Name, "\(", "\("), "\)", "\)")
  If RegExMatch(DescriptIon, "m)^""?" Name """?[ \t]*(.*)", Descr)	; find line with file description (w/wo quotes around filename)
	return Descr1
}

; write file description (to descript.ion file)
WriteFileDescription(FileFullname, newDescription) {
  SplitPath, FileFullname, Name, Dir
  DescriptIonFile := Dir "\descript.ion"
  StringReplace, newDescription, newDescription, `r`n, , All		; drop linefeeds
  newDescription = %newDescription% 	; trim start/end spaces
  IfEqual, newDescription,			; wipe current description
  {
	FileRead, DescriptIon, %DescriptIonFile%
	DescriptIon := RegExReplace(DescriptIon, "m)^""?" Name """?[ \t]*(.*)", "", ReplacementsDone)	; blank line with current description (w/wo quotes on filename)
	if (ReplacementsDone) {
		StringReplace, DescriptIon, DescriptIon, `r`n`r`n, `r`n, All 		; drop double linefeeds
		FileDelete, %DescriptIonFile%
		FileAppend, %DescriptIon%, %DescriptIonFile%
	}
  } else if (not FileExist(DescriptIonFile)) {		; if no descript.ion file just append description to new file
	ThisDescriptIon := """" Name """" " " newDescription "`r`n"
	FileAppend, %ThisDescriptIon%, %DescriptIonFile%
  } else {		; description exists - replace
	ThisDescriptIon := """" Name """" " " newDescription
	FileRead, DescriptIon, %DescriptIonFile%
	Name2 := RegExReplace(RegExReplace(Name, "\(", "\("), "\)", "\)")
	DescriptIon := RegExReplace(DescriptIon, "m)^""?" Name2 """?[ \t]*(.*)", ThisDescriptIon, ReplacementsDone)	; replace line with current description (w/wo quotes on filename)
	if (ReplacementsDone = 0)
		DescriptIon := DescriptIon "`r`n" ThisDescriptIon "`r`n"		; if no description currently add line at the end
	StringReplace, DescriptIon, DescriptIon, `r`n`r`n, `r`n, All 		; drop double linefeeds
	FileDelete, %DescriptIonFile%
	FileAppend, %DescriptIon%, %DescriptIonFile%
  }
}

; ================================================================== INTERNAL FUNCTIONS ==================================================================

; http://www.autohotkey.com/forum/viewtopic.php?t=16823	StdoutToVar_CreateProcess by Sean
; simplified to remove streaming/input-strings
captureOutput(sCmd, sDir = "") {
	DllCall("CreatePipe", "UintP", hStdOutRd, "UintP", hStdOutWr, "Uint", 0, "Uint", 0)
	DllCall("SetHandleInformation", "Uint", hStdOutWr, "Uint", 1, "Uint", 1)
	VarSetCapacity(pi, 16, 0)
	NumPut(VarSetCapacity(si, 68, 0), si)	; size of si
	NumPut(0x100	, si, 44)		; STARTF_USESTDHANDLES
	NumPut(hStdOutWr, si, 60)		; hStdOutput
	NumPut(hStdOutWr, si, 64)		; hStdError
	If Not DllCall("CreateProcess", "Uint", 0, "Uint", &sCmd, "Uint", 0, "Uint", 0, "int", True, "Uint", 0x08000000, "Uint", 0, "Uint", sDir ? &sDir : 0, "Uint", &si, "Uint", &pi)	; bInheritHandles and CREATE_NO_WINDOW
		return -1
	DllCall("CloseHandle", "Uint", NumGet(pi,0))
	DllCall("CloseHandle", "Uint", NumGet(pi,4))
	DllCall("CloseHandle", "Uint", hStdOutWr)
	VarSetCapacity(sTemp, nTemp:=4095)
	Loop {
		If	DllCall("ReadFile", "Uint", hStdOutRd, "Uint", &sTemp, "Uint", nTemp, "UintP", nSize:=0, "Uint", 0)&&nSize
		{
			NumPut(0,sTemp,nSize,"Uchar"), VarSetCapacity(sTemp,-1), sOutput.=sTemp
		}
		Else
			Break
	}
	DllCall("CloseHandle", "Uint", hStdOutRd)
	Return	sOutput
}

;captureOutput1(CMD) {
;	cmdretDllPath := findFile("cmdret.dll")
;	IfEqual cmdretDllPath
;		return captureOutput2(CMD)
;	else {
;		VarSetCapacity(StrOut, 32000)
;		DllCall(cmdretDllPath "\RunReturn", "str", CMD, "str", StrOut)
;		return StrOut
;	}
;}

;captureOutput2(CMD) {
;	Random, rand, 11111111, 99999999
;	StringReplace, CMD, CMD, `%, `%`%, All
;	FileAppend, %CMD% > %A_Temp%\_output_%rand%.tmp, %A_Temp%\_output_%rand%_tmp.bat
;	RunWait, cmd /c %A_Temp%\_output_%rand%_tmp.bat,, Hide
;	FileDelete, %A_Temp%\_output_%rand%_tmp.bat
;	FileRead, StrOut, %A_Temp%\_output_%rand%.tmp
;	; FileGetSize, size, %A_Temp%\_output_%rand%.tmp
;	FileDelete, %A_Temp%\_output_%rand%.tmp
;	return StrOut
;}


; find cmdret.dll - function is used internally for deciding if to use cmdret.dll or "Run,,,hide" to get exiv2.exe command output
; %temp% is included in the search path to be able to use "FileInstall cmdret.dll, %A_Temp%\cmdret.dll" in compiled scripts
findFile(filetofind) {
	EnvGet, SearchFolders, Path
	SearchFolders := A_ScriptDir ";" A_Temp ";" A_AhkPath ";" SearchFolders
	Loop, Parse, SearchFolders, `;
	{
		IfExist, %A_LoopField%\%filetofind%
			return A_LoopField "\" filetofind
	}
}
