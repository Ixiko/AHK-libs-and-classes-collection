/**
 *   OCR library by camerb
 *   v0.94 - 2011-09-08
 *
 * This OCR lib provides an easy way to check a part of the screen for
 * machine-readable text. You should note that OCR isn't a perfect technology,
 * and will frequently make mistakes, but it can give you a general idea of
 * what text is in a given area. For example, a common mistake that this OCR
 * function makes is that it frequently interprets slashes, lowercase L,
 * lowercase I, and the number 1 interchangably. Results can also vary
 * greatly based upon where the outer bounds of the area to scan are placed.
 *
 * Future plans include a function that will check if a given string is
 * displayed within the given coordinates on the screen.
 *
 * Home thread: http://www.autohotkey.com/forum/viewtopic.php?t=74227
 * With inspiration from: http://www.autohotkey.com/forum/viewtopic.php?p=93526#93526
*/


#Include GDIp.ahk
#Include CMDret.ahk


; the options parameter is a string and can contain any combination of the following:
;   debug - for use to show errors that GOCR spits out (not helpful for daily use)
;   numeric (or numeral, or number) - the text being scanned should be limited to
;            numbers only (no letters or special characters)
GetOCR(topLeftX="", topLeftY="", widthToScan="", heightToScan="", options="") {
   ;TODO validate to ensure that the coords are numbers

   prevBatchLines := A_BatchLines

   ;set defaults
   isActiveWindowMode := false

   if (topLeftY == "" AND widthToScan == "" AND heightToScan == "") {
      ;no coordinates were provided
      isSingleParamMode := true
      options := topLeftX
   }

   ;process options from the options param, if they are there
   if (options) {
      if InStr(options, "debug")
         isDebugMode:=true
      if InStr(options, "numeral")
         isNumericMode:=true
      if InStr(options, "numeric")
         isNumericMode:=true
      if InStr(options, "activeWindow")
         isActiveWindowMode:=true
      ;if InStr(options, "screenCoord")
      ;   isActiveWindowMode:=false
   }

   if (isSingleParamMode) {
      ;TODO throw error if not in the right coordmode
      ;or perhaps we can just process the entire screen
      topLeftX := 0
      topLeftY := 0
      if isActiveWindowMode
      {
         WinGetActiveStats, no, winWidth, winHeight, no, no
         widthToScan  := winWidth
         heightToScan := winHeight
      }
      else
      {
         ;TODO fix this so that it gets the full width and full height across all monitors
         widthToScan  := A_ScreenWidth
         heightToScan := A_ScreenHeight
      }
   }

   if (isActiveWindowMode) {
      WinGetPos, xOffset, yOffset, no, no, A
      topLeftX += xOffset
      topLeftY += yOffset
   }
   ;need to figure out if changing the coordmode will mess things up
      ;CoordMode, Mouse, Window
   ;else
      ;CoordMode, Mouse, Screen

   filenameJpg := "in.jpg"
   filenamePnm := "in.pnm"
   jpegQuality := 100
   djpegPath=djpeg.exe
   gocrPath=gocr.exe

   ;take a screenshot of the specified area
   pToken:=Gdip_Startup()
   pBitmap:=Gdip_BitmapFromScreen(topLeftX "|" topLeftY "|" widthToScan "|" heightToScan)
   Gdip_SaveBitmapToFile(pBitmap, filenameJpg, jpegQuality)
   Gdip_Shutdown(pToken)

   ; Wait for jpg file to exist
   while NOT FileExist(filenameJpg)
      Sleep, 10

   ;ensure the exes are there
   if NOT FileExist(djpegPath)
      return "ERROR: djpeg.exe not found in expected location"
   if NOT FileExist(gocrPath)
      return "ERROR: gocr.exe not found in expected location"

   ;convert the jpg file to pnm
   ;NOTE maybe converting to greyscale isn't the best idea
   ;  ... does it increase reliability or speed?
   convertCmd=djpeg.exe -pnm -grayscale %filenameJpg% %filenamePnm%
   CmdRet(convertCmd)

   ; Wait for pnm file to exist
   while NOT FileExist(filenamePnm)
      Sleep, 10

   ;run the OCR command using my mixed cmdret hack
   if isNumericMode
      additionalParams .= "-C 0-9 "
   runCmd=gocr.exe %additionalParams% %filenamePnm%
   result := CmdRet(runCmd)

   ;suppress warnings from GOCR (we don't care, give us nothing)
   if InStr(result, "NOT NORMAL")
      gocrError:=true
   if InStr(result, "strong rotation angle detected")
      gocrError:=true
   if InStr(result, "# no boxes found - stopped") ;multiple warnings show up with this in the string
      gocrError:=true

   if gocrError
   {
      if NOT isDebugMode
         result=
   }

   if isNumericMode
   {
      result := RegExReplace(result, "[ _]+", " ")
   }

   if NOT isDebugMode
   {
      ; Cleanup (preserve the files if in debug mode)
      FileDelete, %filenamePnm%
      FileDelete, %filenameJpg%
   }
   else
   {
      ;copy to an archive folder if in debug mode
      FileCreateDir, ocr-archive
      FormatTime, timestamp,, yyyy-MM-dd_HH-mm-ss
      FileCopy, %filenameJpg%, ocr-archive\%timestamp%.jpg
   }

   ;return to previous speed
   SetBatchlines, %prevBatchLines%

   return result
}

CMDret(CMD) {
   if RegExMatch(A_AHKversion, "^\Q1.0\E")
   {
      ;for AHK_basic
      StrOut:=CMDret_RunReturn(cmd)
   }
   else
   {
      ;for AHK_L
      VarSetCapacity(StrOut, 20000)
      RetVal := DllCall("cmdret.dll\RunReturn", "astr", CMD, "ptr", &StrOut)
      strget:="strget"
      StrOut:=%StrGet%(&StrOut, 20000, CP0)
   }
   Return, %StrOut%
}

