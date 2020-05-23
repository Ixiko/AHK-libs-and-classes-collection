#include library\Graphics.ahk

class Vision {

   class OCR{

      static Aries, Hermes, Kitsune
      ; Enter Aries, the Area Object used for screen capture.
      ; Enter Hermes the Subtitle Object used to display text.
      ; Enter Kitsune, the Image object to display bitmaps.

      start(){
         if (Vision.OCR.Aries != "" || Vision.OCR.Hermes != "")
            return

         SetSystemCursor("IDC_Cross")
         Hotkey, LButton, Null, On
         Hotkey, ^LButton, Null, On
         Hotkey, !LButton, Null, On
         Hotkey, +LButton, Null, On
         Hotkey, Escape, Null, On
         Hotkey, Enter, Null, On
         Hotkey, Space, Null, On

         boundcallback := ObjBindMethod(Vision.OCR, "ProcessFinale")
         Vision.OCR.Aries := new Graphics.Area(boundcallback, "AreaOCR", "0xDDDDDD")
         Vision.OCR.Aries.fileName := "Vision_OCR_screenshot.bmp"
         Vision.OCR.Aries.fileNamePreprocess := "Vision_OCR_preprocess.tif"
         Vision.OCR.Aries.fileNameConvert := "Vision_OCR_text"
         Vision.OCR.Aries.fileNameConvert2 := "Vision_OCR_text.txt"

         Vision.OCR.Hermes := new Graphics.Subtitle("Softsub", "dynamic")
         Vision.OCR.Hermes.Font("Avenir Next LT Pro Medium", A_ScreenHeight/45, "0xFFFFFF")
         Vision.OCR.Hermes.Position(0.25*A_ScreenWidth, (5/6)*A_ScreenHeight, 0.75*A_ScreenWidth, A_ScreenHeight, "center")
         Vision.OCR.Hermes.Margin(A_ScreenHeight/135)
         Vision.OCR.Hermes.AddLine("SoftSubLine1")

         Vision.OCR.Kitsune := new Graphics.Image("Preprocess")
         Vision.OCR.Warden()
         return
      }

      Warden(){
      static processSelect := ObjBindMethod(Vision.OCR, "processSelect")
      static processPreview := ObjBindMethod(Vision.OCR, "processPreview")
      static warden := ObjBindMethod(Vision.OCR, "Warden")

         if (GetKeyState("Escape", "P")) {
            Vision.OCR.Escape()
         }
         else if (GetKeyState("LButton", "P")) {
            Tooltip
            Vision.OCR.Aries.QuickSelect := true
            SetTimer, % processSelect, -10
            SetTimer, % processPreview, -100
         }
         else {
            Vision.OCR.Aries.Hover("Optical Character Recognition Selection Tool")
            SetTimer, % warden, -10
         }
         return
      }

      processSelect(){
      static processSelect := ObjBindMethod(Vision.OCR, "processSelect")

         if (GetKeyState("Escape", "P")) {                                          ; This is the escape pattern.
            Vision.OCR.Aries.Escape := true                                         ; Prevents copying to clipboard.
            Vision.OCR.Aries.Release()
         }

         if (Vision.OCR.Aries.QuickSelect == true)
            Vision.OCR.QuickSelect()
         else
            Vision.OCR.AdvancedSelect()

         if (Vision.OCR.Overlap() && Vision.OCR.Hermes.Async != 1) {
            Vision.OCR.Hermes.y1 := A_ScreenHeight / Vision.OCR.Hermes.y1
            ;Vision.OCR.Hermes.Async := 1
         }

         if not Vision.OCR.Aries.isRelease
            SetTimer, % processSelect, -10
         return
      }

      QuickSelect() {
         if (GetKeyState("LButton", "P")) {
            Vision.OCR.Aries.Draw()                                                 ; Draw Rectangle
            if (GetKeyState("Control", "P") || GetKeyState("Shift", "P")) {
               Vision.OCR.Aries.QuickSelect := false                                ; Exit QuickSelect.
               RestoreCursor()
               Vision.OCR.Hermes.Render("SoftSubLine1", "Advanced Mode")
               Vision.OCR.Hermes.RenderFinish()
            }
         }
         if (!GetKeyState("LButton", "P")) {
            Vision.OCR.Aries.Release()
         }
         ; Do not return.
      }

      AdvancedSelect(){

         if (GetKeyState("Enter", "P") || GetKeyState("Space", "P")) {
            if (GetKeyState("Control", "P")) {
               KeyWait, Space, T0.7
               if (ErrorLevel != true) {
                  Vision.OCR.Aries.Picture := (Vision.OCR.Aries.Picture == "" || Vision.OCR.Aries.Picture == false) ? true : false
                  if (Vision.OCR.Aries.Picture == true)
                     Vision.OCR.Kitsune.Render("Preprocess", Vision.OCR.Aries.fileNamePreprocess)
                  else
                     Vision.OCR.Kitsune.Hide()
               }
            }
            else {
               Vision.OCR.Hermes.Render("SoftSubLine1", "Copied to Clipboard.")
               Vision.OCR.Hermes.RenderFinish()
               Vision.OCR.Aries.Release()                                           ; Aries.Release initiates a Callback from when Aries was created.
            }
         }

         if (!GetKeyState("LButton", "P")){                                         ; When no buttons are held:
            Vision.OCR.Aries.Converge()                                             ; Converge Beta values to alpha values. (smartly)
            Vision.OCR.Aries.Origin()                                               ; Set X,Y coordinates once.
            if Vision.OCR.Aries.isMouseInside()
               Hotkey, LButton, Null, On
            else
               Hotkey, LButton,, Off
         }

         if (GetKeyState("LButton", "P")) {
            if (GetKeyState("Control", "P")) {                                      ; Ctrl + LButton
               if Vision.OCR.Aries.isMouseInside()
                  Vision.OCR.Aries.Enlarge()                                        ; Drag Rectangle Corners.
               else
                  Vision.OCR.Aries.Draw()                                           ; Redraw Rectangle.
            }
            else if (GetKeyState("Alt", "P")) {                                     ; Alt + LButton
               if Vision.OCR.Aries.isMouseInside()
                  Vision.OCR.Aries.Freeform()                                       ; Displace individual polygon points
            }
            else if (GetKeyState("Shift", "P")) {                                   ; Shift + LButton
               if Vision.OCR.Aries.isMouseInside()
                  Vision.OCR.Aries.Resize()                                         ; Resize Rectangle Edges
            }
            else {
               if Vision.OCR.Aries.isMouseInside()
                  Vision.OCR.Aries.Move()                                           ; Transform Rectangle, 2D
            }
         }
         ; Do not return.
      }

      Escape(){
         Hotkey, LButton,, Off
         Hotkey, ^LButton,, Off
         Hotkey, !LButton,, Off
         Hotkey, +LButton,, Off
         Hotkey, Escape,, Off
         Hotkey, Enter,, Off
         Hotkey, Space,, Off
         Tooltip
         RestoreCursor()
         return
      }


               ; ProcessPreview and ProcessCapture run in serial multitask mode. One lane, two cars.
               ; They have labels that are written right beneath the functions.
               ; Gui objects seem to be shared within the class. This is fortuitous for me.
               ; Additionally, many commands cannot accept function objects ["this.x1"]
                  ; Note: this.x1 is different from a navigation call: Vision.OCR.Aries.x1
               ; However, custom functions and while loops accept them easily.
               ; Thus object into variable conversions are required. ["x1 := this.x1"]
               ; Lastly, #Warn may throw up errors with large libraries. These can be safely ignored.

               ; Order Matters! If Preview is loaded before Capture, there are null x2 y2 coordinates causing screenshot
               ; to fail. This leads to FileWritten hogging up time as it looks for the screenshot to appear.

               ; It seems that the rationale behind ProcessPreview and ProcessCapture is the two SetTimers running
               ; asynchronically. However, despite my best efforts to copy the previous system, this asynchronicity
               ; eludes me.
                  ; SOLUTION: Those darned Sleep statements! With SetTimer enacting a Sleep and my Aries Object Functions
                  ; with their own sleep, the clock was not ticking. This has been fixed. Lesson learned.
               ; On Convergence And The Significance Of Asynchronous Processing
               ; Just run the convergence function twice. It checks for completion variables
               ; set by the exit routines of the two asynchronous functions.

               ; MINI GUIDE TO PROBLEM SOLVING.
               ; Picture the code as a stream of water, you can dam and irrigate sections to identify issues.
                  ; First, comment out suspicious code. You are now 90% sure they aren't the problem.
                  ; Second, Try isolating the problematic section and running it itself. This may not be possible
                  ; if your functions depend on complex functions, etc.
                  ; Third, if that doesn't work, then create mini functions. So, ProcessPreview -> miniProcessPreview.
                  ; Simplify the function to it's core. These mini functions are close to the problematic area and as you
                  ; simplify, you may stumble upon the answer like magic fairy unicorns pixie-led through the forest.
                  ; PS Comment your code by using essays detailing your problems so that only you will understand your code


      processPreview(){
      static processPreview := ObjBindMethod(Vision.OCR, "processPreview")

         Vision.OCR.Aries.Screenshot()

         if not Vision.OCR.Aries.isIdenticalScreenshot() {
            Vision.OCR.Preprocess(Vision.OCR.Aries.fileName, Vision.OCR.Aries.fileNamePreprocess)
            Vision.OCR.Convert(Vision.OCR.Aries.fileNamePreprocess, Vision.OCR.Aries.fileNameConvert)

            if (Vision.OCR.Aries.Picture == true)
               Vision.OCR.Kitsune.Render("Preprocess", Vision.OCR.Aries.fileNamePreprocess)

            database := FileOpen(Vision.OCR.Aries.fileNameConvert2, "r`n", "UTF-8")
            i := 0
            dialogue := ""

            while (i < 3) {
               data := database.ReadLine()
               data := RegExReplace(data, "^\s*(.*?)\s*$", "$1")
               if (data != "") {
                  dialogue .= (i == 0) ? data : ("`n" . data)
                  i++
               }
               if (database.AtEOF)
                  break
            }

            if (dialogue != "") {
               Vision.OCR.Hermes.Render("SoftSubLine1", dialogue)
               Vision.OCR.Hermes.RenderFinish()
            }
            else
               Vision.OCR.Hermes.Hide()

            database.Seek(0, 0)
            Vision.OCR.Aries.database := database.Read()
            database.Close()
         }

         if Vision.OCR.Aries.isRelease {
            Vision.OCR.Aries.processPreview := true
            return Vision.OCR.processFinale()
         }
         else
            SetTimer, % processPreview, -100
         return
      }

      processFinale(){
         if (Vision.OCR.Aries.isRelease == true && Vision.OCR.Aries.processPreview == true) {
            ;Aries uses a callback function that destroys itself. Callback verified working!
            Vision.OCR.Hermes.Destroy()
            Vision.OCR.Kitsune.Destroy()
            Vision.OCR.Escape()
            Vision.OCR.DeleteFiles()
            if (Vision.OCR.Aries.Escape != true)
               clipboard := Vision.OCR.Aries.database
            Vision.OCR.Aries := ""                                                             ; Goodbye aries, you were loved :c
            Vision.OCR.Hermes := ""
            Vision.OCR.Kitsune := ""
         }
         return
      }

      Overlap() {
         p1 := (Vision.OCR.Aries.x1_beta != "") ? Vision.OCR.Aries.x1_beta : Vision.OCR.Aries.x1
         p2 := (Vision.OCR.Aries.x2_beta != "") ? Vision.OCR.Aries.x2_beta : Vision.OCR.Aries.x2
         r1 := (Vision.OCR.Aries.y1_beta != "") ? Vision.OCR.Aries.y1_beta : Vision.OCR.Aries.y1
         r2 := (Vision.OCR.Aries.y2_beta != "") ? Vision.OCR.Aries.y2_beta : Vision.OCR.Aries.y2

         q1 := Vision.OCR.Hermes.x1
         q2 := Vision.OCR.Hermes.x2
         s1 := Vision.OCR.Hermes.y1
         s2 := Vision.OCR.Hermes.y2

         a := Union(p1, p2, q1, q2)
         b := Union(r1, r2, s1, s2)

         ;Tooltip % Vision.OCR.Hermes.x1 " " Vision.OCR.Hermes.y1 "`n" Vision.OCR.Hermes.x2 " " Vision.OCR.Hermes.y2 "`n`n`n" Vision.OCR.Aries.x1 " " Vision.OCR.Aries.y1 "`n" Vision.OCR.Aries.x2 " " Vision.OCR.Aries.y2
         return a && b
      }

      Preprocess(f_in, f_out){
         ocrPreProcessing := 1
         negateArg := 2
         performScaleArg := 1
         scaleFactor := 3.5

         RunWait, ..\leptonica_util\leptonica_util.exe %f_in%  %f_out%  %negateArg% 0.5  %performScaleArg% %scaleFactor%  %ocrPreProcessing% 5 2.5  %ocrPreProcessing% 2000 2000 0 0 0.0, , Hide
         return
      }

      Convert(f_in, f_out){
         RunWait, ..\tesseract\tesseract.exe %f_in% %f_out%, , Hide
         ;RunWait, tessa\tesseract.exe --tessdata-dir tessa\tessdata output\ocr_in.tif output\ocr, , Hide
         return
      }

      DeleteFiles(){
         FileDelete(Vision.OCR.Aries.fileName)
         FileDelete(Vision.OCR.Aries.fileNamePreprocess)
         FileDelete(Vision.OCR.Aries.fileNameConvert2)
      }
   }

}


ColorPicker(){
   SetSystemCursor("IDC_Cross")
   selection := 0
   pastColor := ""
   pastX := "", pastY := ""

   while (selection = 0){
      CoordMode, Mouse, Screen
      CoordMode, Pixel, Screen
      MouseGetPos, X, Y
      PixelGetColor, Color, X, Y, RGB

      if (Color != pastColor || X != pastX || Y != pastY) {
         pastColor := Color
         pastX := X, pastY := Y

         sRed    := Format("{:i}", "0x" SubStr(Color, 3, 2))
         sGreen  := Format("{:i}", "0x" SubStr(Color, 5, 2))
         sBlue   := Format("{:i}", "0x" SubStr(Color, 7, 2))

         cXYZ := sRGBtoXYZ(sRed,sGreen,sBlue)
         cLab := XYZtoLAB(cXYZ[0,0], cXYZ[1,0], cXYZ[2,0])

         Hex  := RegExReplace(Color, "^0x", "")
         sRGB := sRed ", " . sGreen ", " . sBlue
         XYZ  := cXYZ[0,1] ", " . cXYZ[1,1] ", " . cXYZ[2,1]
         Lab  := cLab[0,1] ", " . cLab[1,1] ", " . cLab[2,1]
         Name := NameThatColor(Hex)

         mX := X - 25
         mY := Y - 80
         Gui, Color:-Caption +ToolWindow +LastFound +AlwaysOnTop +Border
         Gui, Color:Color, %color%
         Gui, Color:Show, NoActivate x%mX% y%mY% w50 h50

         if (name)
            ToolTip, % "xy:`t" X ", " Y "`nsRGB:`t" sRGB "`nHex:`t" Hex "`nXYZ:`t" XYZ "`nLab:`t" Lab "`nName:`t" Name
         else
            ToolTip, % "xy:`t" X ", " Y "`nsRGB:`t" sRGB "`nHex:`t" Hex "`nXYZ:`t" XYZ "`nLab:`t" Lab
      }


      if GetKeyState("LButton", "P")
         selection := 1

      if GetKeyState("Space", "P")
         selection := 2

      if GetKeyState("Esc", "P")
         break
   }


   if (selection = 1) {
      Gui, Color:Destroy
      Tooltip, Saved [%Hex%] to Clipboard
      Clipboard := Hex
      RestoreCursor()

      KeyWait, LButton, T2
      if ErrorLevel
         Tooltip
      Tooltip
      return
   }
   else if (selection = 2) {
      Gui, Color:Destroy
      Tooltip
      RestoreCursor()

      Gui, Swatch:-Caption +ToolWindow +LastFound +AlwaysOnTop ;+Border
      Gui, Swatch:Color, Hex
      Gui, Swatch:Font, cFFFFFF s8, Verdana
      Gui, Swatch:Add, Text,, % "x" X " y" Y "`nsRGB: " sRGB "`nHex: " Hex "`nXYZ: " XYZ "`nLab: " Lab
      Gui, Swatch:Show, NoActivate x0 y0 w150 h500

      while (selection := 2) {


         if GetKeyState("Esc", "P")
            break
      }

      Gui, Swatch:Destroy
      return
   }

   Gui, Color:Destroy
   Tooltip
   RestoreCursor()
   return
}


sRGBtoXYZ(R,G,B){

   RGB := Object()

   RGB[0] := R
   RGB[1] := G
   RGB[2] := B

   for i, C in RGB {
      C := C / 255
      RGB[i] := (C > 0.04045) ? (((C + 0.055) / 1.055)**2.4) : (C / 12.92)
   }

   X := 0.4124564*RGB[0] + 0.3575761*RGB[1] + 0.1804375*RGB[2]                    ;Matrix Multiplication
   Y := 0.2126729*RGB[0] + 0.7151522*RGB[1] + 0.0721750*RGB[2]
   Z := 0.0193339*RGB[0] + 0.1191920*RGB[1] + 0.9503041*RGB[2]

   XYZ := Object()

   XYZ[0,0] := X*100
   XYZ[1,0] := Y*100
   XYZ[2,0] := Z*100

   XYZ[0,1] := Format("{:0.3f}", X*100)
   XYZ[1,1] := Format("{:0.3f}", Y*100)
   XYZ[2,1] := Format("{:0.3f}", Z*100)

   return XYZ
}

XYZtoLab(X, Y, Z){

   XYZ := Object()
   D65 := Object()

   XYZ[0] := X,      XYZ[1] := Y,       XYZ[2] := Z
   D65[0] := 95.047, D65[1] := 100.000, D65[2] := 108.883                         ;Reference white, 6500K, Blue Sky at Noon

   e := (6/29)**3
   k := (24389/27)

   for i, c in XYZ
      XYZ[i] := XYZ[i] / D65[i]                                                   ;Find Relative Color values based on D65

   for i, c in XYZ
      XYZ[i] := (c > e) ? (c**(1/3)) : (((k * c) + 16) / 116)                     ;Lab Function, no anonymous functions :(

   L := 116 *  XYZ[1] - 16
   a := 500 * (XYZ[0] - XYZ[1])
   b := 200 * (XYZ[1] - XYZ[2])

   Lab := Object()

   Lab[0,0] := L
   Lab[1,0] := a
   Lab[2,0] := b

   Lab[0,1] := Format("{:0.2f}", L)
   Lab[1,1] := Format("{:0.2f}", a)
   Lab[2,1] := Format("{:0.2f}", b)

   return Lab
}

NameThatColor(hex){

   Loop, Read, media\NameThatColor.txt
   {
      if (hex = RegExReplace(A_LoopReadLine, "\[""(.*?)"".*", "$1"))
         return RegExReplace(A_LoopReadLine, ".*?, ""(.*?)""\].*", "$1")
   }
   return
}
