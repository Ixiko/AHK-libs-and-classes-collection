; _libGoogleEarth.ahk  version 1.23
; by David Tryse   davidtryse@gmail.com
; http://david.tryse.net/googleearth/
; http://code.google.com/p/googleearth-autohotkey/
; License:  GPLv2+
; 
; Script for AutoHotkey   ( http://www.autohotkey.com/ )
; This file contains functions for:
; * reading / setting coordinates for Google Earth
; * converting different format coordinates (moved to _libGoogleEarth.ahk)
; * reading/writing Exif GPS coordinates from JPEG files (moved to _libGoogleEarth.ahk)
; 
; Needs ws4ahk.ahk library:  http://www.autohotkey.net/~easycom/
; Functions for Exif GPS data needs exiv2.exe:  http://www.exiv2.org/
; Functions for Exif GPS data will optionally use cmdret.dll if present (to avoid temp files for command output):  http://www.autohotkey.com/forum/topic3687.html
; 
; The script uses the Google Earth COM API  ( http://earth.google.com/comapi/ )
;
; Version history:
; 1.23   -   add GEfeature() function for hiding/showing GE Layers (even while movie recorder is running)
; 1.22   -   split into _libGoogleEarth.ahk and _libGoogleEarthCOM.ahk (avoid loading Windows Scripting env and COM API functions in LatLongConversion/GoogleEarthTiler)
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



#include ws4ahk.ahk
#include _libGoogleEarth.ahk
#NoEnv

WS_Initialize()

VBCode =
(
   Dim googleEarth
   Dim camPos
   Dim FocusPointLatitude
   Dim FocusPointLongitude
   Dim FocusPointAltitude
   Dim FocusPointAltitudeMode
   Dim Range
   Dim Tilt
   Dim Azimuth
   Dim Speed
   Dim pointPos
   Dim googleEarthTime
   Dim layer
   Dim display
  
   Function testGe()
	Set googleEarth = CreateObject("GoogleEarth.ApplicationGE")
	testGe = googleEarth.IsInitialized()
   end Function

   Function gePos()
	Set googleEarth = CreateObject("GoogleEarth.ApplicationGE")
	Set camPos = googleEarth.GetCamera(1)
	gePos = camPos.FocusPointLatitude & ":" & camPos.FocusPointLongitude & ":" & camPos.FocusPointAltitude & ":" & camPos.FocusPointAltitudeMode & ":" & camPos.Range & ":" & camPos.Tilt & ":" & camPos.Azimuth & ":"
   end Function

   Function geSetPos(FocusPointLatitude, FocusPointLongitude, FocusPointAltitude, FocusPointAltitudeMode, Range, Tilt, Azimuth, Speed)
	Set googleEarth = CreateObject("GoogleEarth.ApplicationGE")
	Set geSetPos = googleEarth.SetCameraParams(FocusPointLatitude, FocusPointLongitude, FocusPointAltitude, FocusPointAltitudeMode, Range, Tilt, Azimuth, Speed)
   end Function

   Function gePoint()
	Set googleEarth = CreateObject("GoogleEarth.ApplicationGE")
	Set pointPos = googleEarth.GetPointOnTerrainFromScreenCoords(0,0)
	gePoint = pointPos.Latitude & ":" & pointPos.Longitude & ":" & pointPos.Altitude & ":" & pointPos.ProjectedOntoGlobe & ":" & pointPos.ZeroElevationExaggeration & ":"
   end Function

   Function geTimePlay()
	Set googleEarthTime = CreateObject("GoogleEarth.AnimationControllerGE")
	googleEarthTime.Play()
   end Function

   Function geTimePause()
	Set googleEarthTime = CreateObject("GoogleEarth.AnimationControllerGE")
	googleEarthTime.Pause()
   end Function

   Function geFeature(layer,display)
	Set googleEarth = CreateObject("GoogleEarth.ApplicationGE")
	googleEarth.GetFeatureByName(layer).Visibility = display
   end Function

)

WS_Exec(VBCode)

; ==============================================================================================================
;AltitudeModeGE { RelativeToGroundAltitudeGE = 1, AbsoluteAltitudeGE = 2 }
;
;Defines the altitude's reference origin for the focus point.
;    RelativeToGroundAltitudeGE 	Sets the altitude of the element relative to the actual ground elevation of a particular location. If the ground elevation of a location is exactly at sea level and the altitude for a point is set to 9 meters, then the placemark elevation is 9 meters with this mode. However, if the same placemark is set over a location where the ground elevation is 10 meters above sea level, then the elevation of the placemark is 19 meters.
;    AbsoluteAltitudeGE 		Sets the altitude of the element relative to sea level, regardless of the actual elevation of the terrain beneath the element. For example, if you set the altitude of a placemark to 10 meters with an absolute altitude mode, the placemark will appear to be at ground level if the terrain beneath is also 10 meters above sea level. If the terrain is 3 meters above sea level, the placemark will appear elevated above the terrain by 7 meters. A typical use of this mode is for aircraft placement.

; ==============================================================================================================


; ================================================================== GOOGLE EARTH FUNCTIONS ==================================================================

; check if Google Earth is initialized (returns 0 if logged out from server, 1 if ready - starts GE if not running)
IsGEinit() {
	WS_Eval(theValue, "testGe()")
	return theValue
}

;call with GetGEpos(FocusPointLatitude,FocusPointLongitude,FocusPointAltitude,FocusPointAltitudeMode,Range,Tilt,Azimuth)
GetGEpos(byref FocusPointLatitude, byref FocusPointLongitude, byref FocusPointAltitude, byref FocusPointAltitudeMode, byref Range, byref Tilt, byref Azimuth) {
	If not IsGErunning()
		return 1
	WS_Eval(theValue, "gePos()")
	StringReplace theValue,theValue,`,,.,All		; fix for localized OS - thanks Antti Rasi
	StringSplit word_array,theValue,:,
	FocusPointLatitude	= %word_array1%
	FocusPointLongitude	= %word_array2%
	FocusPointAltitude	= %word_array3%
	FocusPointAltitudeMode	= %word_array4%
	Range			= %word_array5%
	Tilt			= %word_array6%
	Azimuth			= %word_array7%
	If Tilt contains E
		Tilt = 0
	If Azimuth contains E
		Azimuth = 0
	If FocusPointLatitude contains E
		FocusPointLatitude := SubStr(FocusPointLatitude, 1, InStr(FocusPointLatitude, "E")-1) * (0.1 ** SubStr(FocusPointLatitude, InStr(FocusPointLatitude, "E")+2))
	If FocusPointLongitude contains E
		FocusPointLongitude := SubStr(FocusPointLongitude, 1, InStr(FocusPointLongitude, "E")-1) * (0.1 ** SubStr(FocusPointLongitude, InStr(FocusPointLongitude, "E")+2))
}

;call with GetGEpoint(PointLatitude, PointLongitude, PointAltitude, PointProjectedOntoGlobe, pointZeroElevationExaggeration)
;GetGEpoint(byref PointLatitude, byref PointLongitude, byref PointAltitude, byref PointProjectedOntoGlobe, byref pointZeroElevationExaggeration) {
GetGEpoint(byref PointLatitude, byref PointLongitude, byref PointAltitude) {
	If not IsGErunning()
		return 1
	WS_Eval(theValue, "gePoint()")
	StringReplace theValue,theValue,`,,.,All		; fix for localized OS - thanks Antti Rasi
	StringSplit word_array,theValue,:,
	PointLatitude	= %word_array1%
	PointLongitude	= %word_array2%
	PointAltitude	= %word_array3%
	;PointProjectedOntoGlobe	= %word_array4%
	;pointZeroElevationExaggeration	= %word_array5%
	If PointAltitude contains E
		PointAltitude = 0
	If PointLatitude contains E
		PointLatitude := SubStr(PointLatitude, 1, InStr(PointLatitude, "E")-1) * (0.1 ** SubStr(PointLatitude, InStr(PointLatitude, "E")+2))
	If PointLongitude contains E
		PointLongitude := SubStr(PointLongitude, 1, InStr(PointLongitude, "E")-1) * (0.1 ** SubStr(PointLongitude, InStr(PointLongitude, "E")+2))
}

;call with SetGEpos(FocusPointLatitude, FocusPointLongitude, FocusPointAltitude, FocusPointAltitudeMode, Range, Tilt, Azimuth, Speed)
SetGEpos(FocusPointLatitude, FocusPointLongitude, FocusPointAltitude = 0, FocusPointAltitudeMode = 2, Range = 50000, Tilt = 0, Azimuth = 0, Speed = 1) {
	wsfunction = geSetPos(%FocusPointLatitude%, %FocusPointLongitude%, %FocusPointAltitude%, %FocusPointAltitudeMode%, %Range%, %Tilt%, %Azimuth%, %Speed%)
	WS_Eval(returnval, wsfunction)
	return returnval
}

;call with FlyToPhoto(jpegfilename) or FlyToPhoto(jpegfilename, Range, Tilt, Azimuth)
FlyToPhoto(fullfilename, range = 50000, tilt = 0, azimuth = 0) {
	IfNotExist %fullfilename%
		return 1
	GetGEpos(FocusPointLatitude, FocusPointLongitude, FocusPointAltitude, FocusPointAltitudeMode, xRange, xTilt, xAzimuth)
	GetPhotoLatLong(fullfilename, FocusPointLatitude, FocusPointLongitude)
	SetGEpos(FocusPointLatitude, FocusPointLongitude, FocusPointAltitude, FocusPointAltitudeMode, Range, Tilt, Azimuth, Speed)
}

;call with GEtimePlay()
GEtimePlay() {
	wsfunction = geSetPos(%FocusPointLatitude%, %FocusPointLongitude%, %FocusPointAltitude%, %FocusPointAltitudeMode%, %Range%, %Tilt%, %Azimuth%, %Speed%)
	WS_Eval(returnval, "geTimePlay()")
	return returnval
}

;call with GEtimePause()
GEtimePause() {
	wsfunction = geSetPos(%FocusPointLatitude%, %FocusPointLongitude%, %FocusPointAltitude%, %FocusPointAltitudeMode%, %Range%, %Tilt%, %Azimuth%, %Speed%)
	WS_Eval(returnval, "geTimePause()")
	return returnval
}

;call with GEfeature("Trees",1) - for hiding/showing GE Layers (even while movie recorder is running)
GEfeature(layer,display) {
	wsfunction = geFeature("%layer%",%display%)
	WS_Eval(returnval, wsfunction)
	return returnval
}
