; Script:    Vis2.ahk
; Author:    iseahound
; Date:      2017-08-19
; Recent:    2018-04-04

#include <Gdip_All>
#include <JSON>


; ImageIdentify() - Label and identify objects in images.
ImageIdentify(image:="", search:="", options:=""){
   return Vis2.ImageIdentify(image, search, options)
}

; OCR() - Convert pictures of text into text.
OCR(image:="", language:="", options:=""){
   return Vis2.OCR(image, language, options)
}

class Vis2 {

   class ImageIdentify extends Vis2.functor {
      call(self, image:="", search:="", options:=""){
         return (image != "") ? (new Vis2.provider.GoogleCloudVision()).ImageIdentify(image, search, options)
            : Vis2.core.returnText({"provider":(new Vis2.provider.GoogleCloudVision(search)), "tooltip":"Image Identification Tool", "splashImage":true})
      }
   }

   class OCR extends Vis2.functor {
      call(self, image:="", language:="", options:=""){
         return (image != "") ? (new Vis2.provider.Tesseract()).OCR(image, language, options)
            : Vis2.core.returnText({"provider":(new Vis2.provider.Tesseract(language)), "tooltip":"Optical Character Recognition Tool", "textPreview":true})
      }

      google(){
         return (image != "") ? (new Vis2.provider.Tesseract()).OCR(image, language, options).google()
            : Vis2.core.returnText({"provider":(new Vis2.provider.Tesseract(language)), "tooltip":"Any selected text will be Googled.", "textPreview":true, "noCopy":true}).google()
      }
   }

   class core {

      ; returnText() is a wrapper function of Vis2.core.ux.start()
      ; Unlike Vis2.core.ux.start(), this function will return a string of text.
      returnText(obj := ""){
         obj := IsObject(obj) ? obj : {}
         obj.callback := "returnText"
         if (Vis2.core.ux.start(obj) == "") {
            while !(EXITCODE := Vis2.obj.EXITCODE)
               Sleep 1
            text := Vis2.obj.database
            Vis2.obj.callbackConfirmed := true
            text.base.google := ObjBindMethod(Vis2.Text, "google")
            text.base.clipboard := ObjBindMethod(Vis2.Text, "clipboard")
            return (EXITCODE > 0) ? text : ""
         }
      }

      class ux {

         ; start() is the function that launches the user interface.
         ; This can be called directly without calling Vis2.core.returnText().
         start(obj := ""){
         static void := ObjBindMethod({}, {})

            if (Vis2.obj != "")
               return "Already in use."

            Vis2.Graphics.Startup()
            Vis2.stdlib.setSystemCursor(32515) ; IDC_Cross := 32515
            Hotkey, LButton, % void, On
            Hotkey, ^LButton, % void, On
            Hotkey, !LButton, % void, On
            Hotkey, +LButton, % void, On
            Hotkey, RButton, % void, On
            Hotkey, Escape, % void, On

            Vis2.obj := IsObject(obj) ? obj : {}
            Vis2.obj.EXITCODE := 0 ; 0 = in progress, -1 = escape, 1 = success
            Vis2.obj.selectMode := "Quick"
            Vis2.obj.area := new Vis2.Graphics.Area("Vis2_Aries", "0x7FDDDDDD")
            Vis2.obj.image := new Vis2.Graphics.Image("Vis2_Kitsune").Hide()
            Vis2.obj.subtitle := new Vis2.Graphics.Subtitle("Vis2_Hermes")

            Vis2.obj.style1_back := {"x":"center", "y":"83%", "padding":"1.35%", "color":"DD000000", "radius":8}
            Vis2.obj.style1_text := {"q":4, "size":"2.23%", "font":"Arial", "z":"Arial Narrow", "justify":"left", "color":"White"}
            Vis2.obj.style2_back := {"x":"center", "y":"83%", "padding":"1.35%", "color":"FF88EAB6", "radius":8}
            Vis2.obj.style2_text := {"q":4, "size":"2.23%", "font":"Arial", "z":"Arial Narrow", "justify":"left", "color":"Black"}
            Vis2.obj.subtitle.render(Vis2.obj.tooltip, Vis2.obj.style1_back, Vis2.obj.style1_text)

            return Vis2.core.ux.waitForUserInput()
         }

         waitForUserInput(){
         static escape := ObjBindMethod(Vis2.core.ux, "escape")
         static waitForUserInput := ObjBindMethod(Vis2.core.ux, "waitForUserInput")
         static selectImage := ObjBindMethod(Vis2.core.ux.process, "selectImage")
         static textPreview := ObjBindMethod(Vis2.core.ux.process, "textPreview")

            if (GetKeyState("Escape", "P")) {
               Vis2.obj.EXITCODE := -1
               SetTimer, % escape, -9
               return
            }
            else if (GetKeyState("LButton", "P")) {
               SetTimer, % selectImage, -10
               if (Vis2.obj.textPreview)
                  SetTimer, % textPreview, -25
               else
                  Vis2.obj.subtitle.render("Waiting for user selection...", Vis2.obj.style2_back, Vis2.obj.style2_text)
            }
            else {
               Vis2.obj.area.origin()
               SetTimer, % waitForUserInput, -10
            }
            return
         }

         class process {

            selectImage(){
            static selectImage := ObjBindMethod(Vis2.core.ux.process, "selectImage")

               if (GetKeyState("Escape", "P")) {
                  Vis2.obj.EXITCODE := -1
                  return Vis2.core.ux.process.finale(A_ThisFunc)
               }

               if (Vis2.obj.selectMode == "Quick")
                  Vis2.core.ux.process.selectImageQuick()
               if (Vis2.obj.selectMode == "Advanced")
                  Vis2.core.ux.process.selectImageAdvanced()

               if (Vis2.core.ux.overlap()) {
                  if (Vis2.obj.textPreview && Vis2.obj.dialogue != Vis2.obj.dialogue_past) {
                     Vis2.obj.dialogue_past := Vis2.obj.dialogue
                     Vis2.obj.style1_back.y := (Vis2.obj.style1_back.y == "83%") ? "2.07%" : "83%"
                     Vis2.obj.subtitle.render(Vis2.obj.dialogue, Vis2.obj.style1_back, Vis2.obj.style1_text)
                  }
                  else if !(Vis2.obj.textPreview) {
                     Vis2.obj.style2_back.y := (Vis2.obj.style2_back.y == "83%") ? "2.07%" : "83%"
                     Vis2.obj.subtitle.render("Still patiently waiting for user selection...", Vis2.obj.style2_back, Vis2.obj.style2_text)
                  }
               }

               if !(Vis2.obj.unlock.1 ~= "^Vis2.core.ux.process.selectImage" || Vis2.obj.unlock.2 ~= "^Vis2.core.ux.process.selectImage")
                  SetTimer, % selectImage, -10
               return
            }

            selectImageQuick(){
               if (GetKeyState("LButton", "P")) {
                  if (GetKeyState("Control", "P") || GetKeyState("Alt", "P") || GetKeyState("Shift", "P"))
                     Vis2.core.ux.process.selectImageTransition()
                  else if (GetKeyState("RButton", "P")) {
                     Vis2.obj.area.move()
                     if (!Vis2.obj.area.isMouseOnCorner() && Vis2.obj.area.isMouseStopped())
                        Vis2.obj.area.draw() ; Error Correction of Offset
                  }
                  else
                     Vis2.obj.area.draw()
               }
               else
                  Vis2.core.ux.process.finale(A_ThisFunc)
               ; Do not return.
            }

            selectImageTransition(){
            static void := ObjBindMethod({}, {})

               DllCall("SystemParametersInfo", "uInt",0x57, "uInt",0, "uInt",0, "uInt",0) ; RestoreCursor()
               Hotkey, Space, % void, On
               Hotkey, ^Space, % void, On
               Hotkey, !Space, % void, On
               Hotkey, +Space, % void, On
               Vis2.obj.note_01 := Vis2.Graphics.Subtitle.Render("Advanced Mode", "time: 2500, xCenter y75% p1.35% cFFB1AC r8", "c000000 s2.23%")
               Vis2.obj.tokenMousePressed := 1
               Vis2.obj.selectMode := "Advanced" ; Exit selectImageQuick.
               Vis2.obj.key := {}
               Vis2.obj.action := {}
            }

            selectImageAdvanced(){
            static void := ObjBindMethod({}, {})

               if ((Vis2.obj.area.width() < -25 || Vis2.obj.area.height() < -25) && !Vis2.obj.note_02)
                  Vis2.obj.note_02 := Vis2.Graphics.Subtitle.Render("Press Alt + LButton to create a new selection anywhere on screen", "time: 6250, x: center, y: 67%, p1.35%, c: FCF9AF, r8", "c000000 s2.23%")

               Vis2.obj.key.LButton := GetKeyState("LButton", "P") ? 1 : 0
               Vis2.obj.key.RButton := GetKeyState("RButton", "P") ? 1 : 0
               Vis2.obj.key.Space   := GetKeyState("Space", "P")   ? 1 : 0
               Vis2.obj.key.Control := GetKeyState("Control", "P") ? 1 : 0
               Vis2.obj.key.Alt     := GetKeyState("Alt", "P")     ? 1 : 0
               Vis2.obj.key.Shift   := GetKeyState("Shift", "P")   ? 1 : 0

               ; Check if mouse is inside on activation.
               Vis2.obj.action.Control_LButton := (Vis2.obj.area.isMouseInside() && Vis2.obj.key.Control && Vis2.obj.key.LButton)
                  ? 1 : (Vis2.obj.key.Control && Vis2.obj.key.LButton) ? Vis2.obj.action.Control_LButton : 0
               Vis2.obj.action.Shift_LButton   := (Vis2.obj.area.isMouseInside() && Vis2.obj.key.Shift && Vis2.obj.key.LButton)
                  ? 1 : (Vis2.obj.key.Shift && Vis2.obj.key.LButton) ? Vis2.obj.action.Shift_LButton : 0
               Vis2.obj.action.LButton         := (Vis2.obj.area.isMouseInside() && Vis2.obj.key.LButton)
                  ? 1 : (Vis2.obj.key.LButton) ? Vis2.obj.action.LButton : 0
               Vis2.obj.action.RButton         := (Vis2.obj.area.isMouseInside() && Vis2.obj.key.RButton)
                  ? 1 : (Vis2.obj.key.RButton) ? Vis2.obj.action.RButton : 0

               ;___|¯¯¯|___ 00011111000 Keypress
               ;___|_______ 0001----000 Activation Function (pseudo heaviside)
               Vis2.obj.action.Control_Space   := (Vis2.obj.key.Control && Vis2.obj.key.Space)
                  ? ((!Vis2.obj.action.Control_Space) ? 1 : -1) : 0
               Vis2.obj.action.Alt_Space       := (Vis2.obj.key.Alt && Vis2.obj.key.Space)
                  ? ((!Vis2.obj.action.Alt_Space) ? 1 : -1) : 0
               Vis2.obj.action.Shift_Space     := (Vis2.obj.key.Shift && Vis2.obj.key.Space)
                  ? ((!Vis2.obj.action.Shift_Space) ? 1 : -1) : 0
               Vis2.obj.action.Alt_LButton     := (Vis2.obj.key.Alt && Vis2.obj.key.LButton)
                  ? ((!Vis2.obj.action.Alt_LButton) ? 1 : -1) : 0

               ; Ensure only Space is pressed.
               Vis2.obj.action.Space := (Vis2.obj.key.Space && !Vis2.obj.key.Control && !Vis2.obj.key.Alt && !Vis2.obj.key.Shift)
                  ? ((!Vis2.obj.action.Space) ? 1 : -1) : 0

               ; Space Hotkeys
               if (Vis2.obj.action.Control_Space = 1){
                  Vis2.obj.image.render(Vis2.obj.provider.getPreprocessImage(), 0.5)
                  Vis2.obj.image.toggleVisible()
               } else if (Vis2.obj.action.Alt_Space = 1){
                  Vis2.obj.area.toggleCoordinates()
               } else if (Vis2.obj.action.Shift_Space = 1){

               } else if (Vis2.obj.action.Space = 1)
                  Vis2.core.ux.process.finale(A_ThisFunc) ; Exit function.

               ; Mouse Hotkeys
               if (Vis2.obj.action.Control_LButton)
                  Vis2.obj.area.resizeCorners()
               else if (Vis2.obj.action.Alt_LButton = 1)
                  Vis2.obj.area.origin()
               else if (Vis2.obj.action.Alt_LButton = -1)
                  Vis2.obj.area.draw()
               else if (Vis2.obj.action.Shift_LButton)
                  Vis2.obj.area.resizeEdges()
               else if (Vis2.obj.action.LButton || Vis2.obj.action.RButton)
                  Vis2.obj.area.move()
               else {
                  Vis2.obj.area.hover() ; Collapse Stack
                  if Vis2.obj.area.isMouseInside() {
                     Hotkey, LButton, % void, On
                     Hotkey, RButton, % void, On
                  } else {
                     Hotkey, LButton, % void, Off
                     Hotkey, RButton, % void, Off
                  }
               }
               ; Do not return.
            }

            textPreview(bypass:=""){
            static textPreview := ObjBindMethod(Vis2.core.ux.process, "textPreview")

               if (!Vis2.obj.unlock.1 || bypass) {
                  if (coordinates := Vis2.obj.Area.ScreenshotRectangle()) {
                     (overlap := Vis2.core.ux.overlap()) ? Vis2.obj.subtitle.hide() : ""
                     pBitmap := Gdip_BitmapFromScreen(coordinates) ; To avoid the grey tint, call Area.Hide() but this will cause flickering.
                     (overlap) ? Vis2.obj.subtitle.show() : ""
                     if !(coordinates == Vis2.obj.coordinates && Vis2.stdlib.Gdip_isBitmapEqual(pBitmap, Vis2.obj.pBitmap)) {
                        Gdip_DisposeImage(Vis2.obj.pBitmap)
                        Vis2.obj.coordinates := coordinates
                        Vis2.obj.pBitmap := pBitmap

                        ; Process screenshot.
                        try {
                           if (Vis2.obj.provider.file != "")
                              Gdip_SaveBitmapToFile(pBitmap, Vis2.obj.provider.file, Vis2.obj.provider.jpegQuality)
                           if (Vis2.obj.provider.base64 != "")
                              Vis2.obj.provider.base64 := Vis2.stdlib.Gdip_EncodeBitmapTo64string(pBitmap, Vis2.obj.provider.ext, Vis2.obj.provider.jpegQuality)
                           Vis2.obj.provider.preprocess()
                           if (Vis2.obj.image.isVisible() == true)
                              Vis2.obj.image.render(Vis2.obj.provider.getPreprocessImage(), 0.5)
                           Vis2.obj.provider.convert()
                           Vis2.obj.database := Vis2.obj.provider.getText()
                        }
                        catch e {
                           MsgBox, 16,, % "Exception thrown!`n`nwhat: " e.what "`nfile: " e.file
                              . "`nline: " e.line "`nmessage: " e.message "`nextra: " e.extra "`ncoordinates: " coordinates
                        }

                        ; Retrieve three lines of text.
                        dialogue := ""
                        i := 1
                        Loop, Parse, % Vis2.obj.database, `r`n
                        {
                           data := RegExReplace(A_LoopField, "^\s*(.*?)\s*$", "$1")
                           if (data != "") {
                              dialogue .= (dialogue) ? ("`n" . data) : data
                              i++
                           }
                        } until (i > 3)

                        if (dialogue != "") {
                           Vis2.obj.firstDialogue := true
                           Vis2.obj.dialogue := dialogue
                        }
                        else
                           Vis2.obj.dialogue := (Vis2.obj.firstDialogue == true) ? "ERROR: No Text Data Found" : "Searching for text..."

                        if !(bypass)
                           Vis2.obj.Subtitle.Render(Vis2.obj.dialogue, Vis2.obj.style1_back, Vis2.obj.style1_text)
                     }
                     else {
                        Gdip_DisposeImage(pBitmap)
                     }
                  }
               }

               if (Vis2.obj.unlock.1)
                  return Vis2.core.ux.process.finale(A_ThisFunc)
               else
                  SetTimer, % textPreview, -100
               return
            }

            finale(key){
            static escape := ObjBindMethod(Vis2.core.ux, "escape")

               (IsObject(Vis2.obj.unlock) && key != Vis2.obj.unlock.1) ? Vis2.obj.unlock.push(key) : (Vis2.obj.unlock := [key])

               if (key ~= "^Vis2.core.ux.process.selectImage") {
                  Vis2.obj.Area.ChangeColor(0x01FFFFFF) ; Lighten Area object, but do not hide or delete it until key up.
                  if (!Vis2.obj.textPreview)
                     Vis2.core.ux.process.textPreview("bypass")
               }

               if (Vis2.obj.unlock.MaxIndex() == 2) {
                  if (Vis2.obj.area.screenshotRectangle() != Vis2.obj.coordinates)
                     Vis2.core.ux.process.textPreview("bypass")
                  if (Vis2.obj.database != "" && Vis2.obj.EXITCODE == 0) {
                     if (Vis2.obj.noCopy != true) {
                        clipboard := Vis2.obj.database
                        t := 2500
                        if (Vis2.obj.splashImage == true) {
                           t := 5000
                           w := Gdip_GetImageWidth(Vis2.obj.pBitmap)
                           h := Gdip_GetImageHeight(Vis2.obj.pBitmap)
                           Vis2.Graphics.Subtitle.Render("", {"time":t, "x":((A_ScreenWidth-w)/2)-10, "y":((A_ScreenHeight-h)/2)-10, "w":w+20, "h":h+20, "color":"Black"})
                           Vis2.Graphics.Image.Render(Vis2.obj.pBitmap, 1, t).Border()
                        }
                        Vis2.obj.Subtitle.Hide()
                        Vis2.Graphics.Subtitle.Render(Vis2.obj.dialogue
                           , {"time":t, "x":"center", "y":"83%", "padding":"1.35%", "color":"Black", "radius":8}, {"q":4, "size":"2.23%", "font":"Arial", "z":"Arial Narrow", "justify":"left", "color":"White"})
                        Vis2.Graphics.Subtitle.Render("Saved to Clipboard.", "time: " t ", x: center, y: 75%, p: 1.35%, c: F9E486, r: 8", "c: 0x000000, s:2.23%, f:Arial")
                     }
                     Vis2.obj.EXITCODE := 1
                  }
                  Vis2.obj.EXITCODE := (Vis2.obj.EXITCODE == 0) ? -1 : Vis2.obj.EXITCODE
                  SetTimer, % escape, -9
               }
               return
            }
         }

         escape(){
         static escape := ObjBindMethod(Vis2.core.ux, "escape")
         static void := ObjBindMethod({}, {})

            if (Vis2.obj.callback) {
               if !(Vis2.obj.callbackConfirmed) {
                  SetTimer, % escape, -9
                  return
               }
            }

            ; Delete temporary image and text files.
            Gdip_DisposeImage(Vis2.obj.pBitmap)
            Vis2.obj.provider.cleanup()
            Vis2.obj.area.destroy()
            Vis2.obj.image.destroy()
            Vis2.obj.subtitle.destroy()
            Vis2.obj.note_01.hide() ; Let them time out instead of Destroy()
            Vis2.obj.note_02.destroy()
            Vis2.obj := "" ; Goodbye all, you were loved :c
            Vis2.Graphics.Shutdown()

            ; Fixes a bug where AHK does not detect key releases if there is an admin-level window beneath.
            if WinActive("ahk_id" Vis2.obj.area.hwnd) {
               KeyWait Control
               KeyWait Alt
               KeyWait Shift
               KeyWait RButton
               KeyWait LButton
               KeyWait Space
               KeyWait Escape
            }

            Hotkey, LButton, % void, Off
            Hotkey, ^LButton, % void, Off
            Hotkey, !LButton, % void, Off
            Hotkey, +LButton, % void, Off
            Hotkey, RButton, % void, Off
            Hotkey, Escape, % void, Off
            Hotkey, Space, % void, Off
            Hotkey, ^Space, % void, Off
            Hotkey, !Space, % void, Off
            Hotkey, +Space, % void, Off

            return DllCall("SystemParametersInfo", "uInt",0x57, "uInt",0, "uInt",0, "uInt",0) ; RestoreCursor()
         }

         overlap() {
            p1 := Vis2.obj.area.x1()
            p2 := Vis2.obj.area.x2()
            r1 := Vis2.obj.area.y1()
            r2 := Vis2.obj.area.y2()

            q1 := Vis2.obj.subtitle.x1()
            q2 := Vis2.obj.subtitle.x2()
            s1 := Vis2.obj.subtitle.y1()
            s2 := Vis2.obj.subtitle.y2()

            a := (p1 < q1 && q1 < p2) || (p1 < q2 && q2 < p2) || (q1 < p1 && p1 < q2) || (q1 < p2 && p2 < q2)
            b := (r1 < s1 && s1 < r2) || (r1 < s2 && s2 < r2) || (s1 < r1 && r1 < s2) || (s1 < r2 && r2 < s2)

            ;Tooltip % a "`t" b "`n`n" p1 "`t" r1 "`n" p2 "`t" r2 "`n`n" q1 "`t" s1 "`n" q2 "`t" s2
            return (a && b)
         }

         suspend(){
            static void := ObjBindMethod({}, {})
            Hotkey, LButton, % void, Off
            Hotkey, ^LButton, % void, Off
            Hotkey, !LButton, % void, Off
            Hotkey, +LButton, % void, Off
            Hotkey, RButton, % void, Off
            Hotkey, Escape, % void, Off
            Hotkey, Space, % void, Off
            Hotkey, ^Space, % void, Off
            Hotkey, !Space, % void, Off
            Hotkey, +Space, % void, Off
            DllCall("SystemParametersInfo", "uInt",0x57, "uInt",0, "uInt",0, "uInt",0) ; RestoreCursor
            Vis2.obj.area.hide()
            return
         }

         resume(){
            Hotkey, LButton, % void, On
            Hotkey, ^LButton, % void, On
            Hotkey, !LButton, % void, On
            Hotkey, +LButton, % void, On
            Hotkey, RButton, % void, On
            Hotkey, Escape, % void, On

            if (Vis2.obj.selectMode == "Quick")
               Vis2.stdlib.setSystemCursor(32515) ; IDC_Cross := 32515

            if (Vis2.obj.selectMode == "Advanced") {
               Hotkey, Space, % void, On
               Hotkey, ^Space, % void, On
               Hotkey, !Space, % void, On
               Hotkey, +Space, % void, On
            }
            Vis2.obj.area.show()
            return
         }
      }
   }

   class functor {

      __Call(method, ByRef arg := "", args*) {
      ; When casting to Call(), use a new instance of the "function object"
      ; so as to avoid directly storing the properties(used across sub-methods)
      ; into the "function object" itself.
      ; Thanks to coco for this code. Modified by iseahound.
         if IsObject(method)
            return (new this).Call(method, arg, args*)
         else if (method == "")
            return (new this).Call(arg, args*)
      }
   }

   class Graphics {

      static pToken, Gdip := 0

      Startup(){
         global pToken
         return Vis2.Graphics.pToken := (Vis2.Graphics.Gdip++ > 0) ? Vis2.Graphics.pToken : (pToken) ? pToken : Gdip_Startup()
      }

      Shutdown(){
         global pToken
         return Vis2.Graphics.pToken := (--Vis2.Graphics.Gdip <= 0) ? ((pToken) ? pToken : Gdip_Shutdown(Vis2.Graphics.pToken)) : Vis2.Graphics.pToken
      }

      Name(){
         VarSetCapacity(UUID, 16, 0)
         if (DllCall("rpcrt4.dll\UuidCreate", "ptr", &UUID) != 0)
             return (ErrorLevel := 1) & 0
         if (DllCall("rpcrt4.dll\UuidToString", "ptr", &UUID, "uint*", suuid) != 0)
             return (ErrorLevel := 2) & 0
         return A_TickCount "n" SubStr(StrGet(suuid), 1, 8), DllCall("rpcrt4.dll\RpcStringFree", "uint*", suuid)
      }

      class Area{

         ScreenWidth := A_ScreenWidth, ScreenHeight := A_ScreenHeight,
         action := ["base"], x := [0], y := [0], w := [1], h := [1], a := ["top left"], q := ["bottom right"]

         __New(name := "", color := "0x7FDDDDDD") {
            this.name := name := (name == "") ? Vis2.Graphics.Name() "_Graphics_Area" : name "_Graphics_Area"
            this.color := color

            Vis2.Graphics.Startup()
            Gui, %name%:New, +LastFound +AlwaysOnTop -Caption -DPIScale +E0x80000 +ToolWindow +hwndSecretName, % this.name
            Gui, %name%:Show, % (this.isDrawable()) ? "NoActivate" : ""
            this.hwnd := SecretName
            this.hbm := CreateDIBSection(this.ScreenWidth, this.ScreenHeight)
            this.hdc := CreateCompatibleDC()
            this.obm := SelectObject(this.hdc, this.hbm)
            this.G := Gdip_GraphicsFromHDC(this.hdc)
            Gdip_SetSmoothingMode(this.G, 4) ;Adds one clickable pixel to the edge.
            this.pBrush := Gdip_BrushCreateSolid(this.color)
         }

         __Delete(){
            Vis2.Graphics.Shutdown()
         }

         Destroy(){
            Gdip_DeleteBrush(this.pBrush)
            SelectObject(this.hdc, this.obm)
            DeleteObject(this.hbm)
            DeleteDC(this.hdc)
            Gdip_DeleteGraphics(this.G)
            Gui, % this.name ":Destroy"
         }

         Hide(){
            DllCall("ShowWindow", "ptr",this.hWnd, "int",0)
         }

         Show(){ ; NoActivate
            DllCall("ShowWindow", "ptr",this.hWnd, "int",8)
         }

         ToggleVisible(){
            this.isVisible() ? this.Hide() : this.Show()
         }

         isVisible(){
            return DllCall("IsWindowVisible", "ptr",this.hWnd)
         }

         isDrawable(win := "A"){
             static WM_KEYDOWN := 0x100,
             static WM_KEYUP := 0x101,
             static vk_to_use := 7
             ; Test whether we can send keystrokes to this window.
             ; Use a virtual keycode which is unlikely to do anything:
             PostMessage, WM_KEYDOWN, vk_to_use, 0,, % win
             if !ErrorLevel
             {   ; Seems best to post key-up, in case the window is keeping track.
                 PostMessage, WM_KEYUP, vk_to_use, 0xC0000000,, % win
                 return true
             }
             return false
         }

         DetectScreenResolutionChange(){
            if (this.ScreenWidth != A_ScreenWidth || this.ScreenHeight != A_ScreenHeight) {
               this.ScreenWidth := A_ScreenWidth, this.ScreenHeight := A_ScreenHeight
               SelectObject(this.hdc, this.obm)
               DeleteObject(this.hbm)
               DeleteDC(this.hdc)
               Gdip_DeleteGraphics(this.G)
               this.hbm := CreateDIBSection(this.ScreenWidth, this.ScreenHeight)
               this.hdc := CreateCompatibleDC()
               this.obm := SelectObject(this.hdc, this.hbm)
               this.G := Gdip_GraphicsFromHDC(this.hdc)
               Gdip_SetSmoothingMode(this.G, 4)
            }
         }

         Redraw(x, y, w, h){
            Critical On
            this.DetectScreenResolutionChange()
            Gdip_GraphicsClear(this.G)
            Gdip_FillRectangle(this.G, this.pBrush, x, y, w, h)
            if (this.coordinates)
               Vis2.Graphics.Subtitle.Draw("x: " x " │ y: " y " │ w: " w " │ h: " h
                  , {"a":"top_right", "x":"right", "y":"top", "color":"Black"}, {"font":"Lucida Sans Typewriter", "size":"1.67%"}, this.G)
            UpdateLayeredWindow(this.hwnd, this.hdc, 0, 0, this.ScreenWidth, this.ScreenHeight)
            Critical Off
         }

         ChangeColor(color){
            this.color := color
            Gdip_DeleteBrush(this.pBrush)
            this.pBrush := Gdip_BrushCreateSolid(this.color)
            this.Redraw(this.x[this.x.MaxIndex()], this.y[this.y.MaxIndex()], this.w[this.w.MaxIndex()], this.h[this.h.MaxIndex()])
         }

         ShowCoordinates(){
            this.coordinates := true
            this.Redraw(this.x[this.x.MaxIndex()], this.y[this.y.MaxIndex()], this.w[this.w.MaxIndex()], this.h[this.h.MaxIndex()])
         }

         HideCoordinates(){
            this.coodinates := false
            this.Redraw(this.x[this.x.MaxIndex()], this.y[this.y.MaxIndex()], this.w[this.w.MaxIndex()], this.h[this.h.MaxIndex()])
         }

         ToggleCoordinates(){
            this.coordinates := !this.coordinates
            this.Redraw(this.x[this.x.MaxIndex()], this.y[this.y.MaxIndex()], this.w[this.w.MaxIndex()], this.h[this.h.MaxIndex()])
         }

         Propagate(v){
            this.a[v] := (this.a[v] == "") ? this.a[v-1] : this.a[v]
            this.q[v] := (this.q[v] == "") ? this.q[v-1] : this.q[v]
            this.x[v] := (this.x[v] == "") ? this.x[v-1] : this.x[v]
            this.y[v] := (this.y[v] == "") ? this.y[v-1] : this.y[v]
            this.w[v] := (this.w[v] == "") ? this.w[v-1] : this.w[v]
            this.h[v] := (this.h[v] == "") ? this.h[v-1] : this.h[v]
         }

         BackPropagate(pasts){
            action := this.action.pop()
            a := this.a.pop()
            q := this.q.pop()
            x := this.x.pop()
            y := this.y.pop()
            w := this.w.pop()
            h := this.h.pop()

            dx := x - this.x[pasts-1]
            dy := y - this.y[pasts-1]
            dw := w - this.w[pasts-1]
            dh := h - this.h[pasts-1]

            i := pasts-1
            while (i >= 1) {
               this.x[i] += dx
               this.y[i] += dy
               this.w[i] += dw
               this.h[i] += dh
               i--
            }
         }

         Converge(v := ""){
            v := (v) ? v : this.action.MaxIndex()

            if (v > 2) {
               this.action := [this.action[v-1], this.action[v]]
               this.a := [this.a[v-1], this.a[v]]
               this.q := [this.q[v-1], this.q[v]]
               this.x := [this.x[v-1], this.x[v]]
               this.y := [this.y[v-1], this.y[v]]
               this.w := [this.w[v-1], this.w[v]]
               this.h := [this.h[v-1], this.h[v]]
            }
         }

         Debug(function){
            v := (v) ? v : this.action.MaxIndex()
            Tooltip % function "`t" v . "`n" v-1 ": " this.action[v-1]
               . "`n" this.x[v-2] ", " this.y[v-2] ", " this.w[v-2] ", " this.h[v-2]
               . "`n" this.x[v-1] ", " this.y[v-1] ", " this.w[v-1] ", " this.h[v-1]
               . "`n" this.x[v] ", " this.y[v] ", " this.w[v] ", " this.h[v]
               . "`nAnchor:`t" this.a[v] "`nMouse:`t" this.q[v] "`t" this.isMouseInside()
         }

         Hover(){
            CoordMode, Mouse, Screen
            MouseGetPos, x_hover, y_hover
            this.x_hover := x_hover
            this.y_hover := y_hover

            ; Resets the stack to 1.
            if (A_ThisFunc != this.action[this.action.MaxIndex()]){
               this.action := [A_ThisFunc]
               this.a := [this.a.pop()]
               this.q := [this.q.pop()]
               this.x := [this.x.pop()]
               this.y := [this.y.pop()]
               this.w := [this.w.pop()]
               this.h := [this.h.pop()]
            }
         }

         Origin(v := ""){
            CoordMode, Mouse, Screen
            MouseGetPos, x_mouse, y_mouse

            if (A_ThisFunc != this.action[this.action.MaxIndex()]){
               this.action.push(A_ThisFunc)
               this.x_hover := x_mouse
               this.y_hover := y_mouse
            }

            v := (v) ? v : this.action.MaxIndex()

            if (x_mouse != this.x_last || y_mouse != this.y_last) {
               this.x_last := x_mouse, this.y_last := y_mouse

               this.x[v] := x_mouse
               this.y[v] := y_mouse

               this.Propagate(v)
               this.Redraw(x_mouse, y_mouse, 1, 1) ;stabilize x/y corrdinates in window spy.
            }
         }

         Draw(v := ""){
            CoordMode, Mouse, Screen
            MouseGetPos, x_mouse, y_mouse

            if (A_ThisFunc == this.action[this.action.MaxIndex()-1]){
               this.BackPropagate(this.action.MaxIndex())
               this.x_hover := x_mouse
               this.y_hover := y_mouse
               pass := 1
            }
            if (A_ThisFunc != this.action[this.action.MaxIndex()]){
               this.Converge()
               this.action.push(A_ThisFunc)
               this.x_hover := x_mouse
               this.y_hover := y_mouse
               pass := 1
            }

            v := (v) ? v : this.action.MaxIndex()
            dx := x_mouse - this.x_hover
            dy := y_mouse - this.y_hover
            xr := (x_mouse > this.x[v-1]) ? 1 : 0
            yr := (y_mouse > this.y[v-1]) ? 1 : 0

            if (pass == 1 || x_mouse != this.x_last || y_mouse != this.y_last) {
               this.x_last := x_mouse, this.y_last := y_mouse

               this.x[v] := (xr) ? this.x[v-1] : x_mouse
               this.y[v] := (yr) ? this.y[v-1] : y_mouse
               this.w[v] := (xr) ? x_mouse - this.x[v-1] : this.x[v-1] - x_mouse
               this.h[v] := (yr) ? y_mouse - this.y[v-1] : this.y[v-1] - y_mouse

               this.a[v] := (xr && yr) ? "top left" : (xr && !yr) ? "bottom left" : (!xr && yr) ? "top right" : "bottom right"
               this.q[v] := (xr && yr) ? "bottom right" : (xr && !yr) ? "top right" : (!xr && yr) ? "bottom left" : "top left"

               this.Propagate(v)
               this.Redraw(this.x[v], this.y[v], this.w[v], this.h[v])
            }
         }

         Move(v := ""){
            CoordMode, Mouse, Screen
            MouseGetPos, x_mouse, y_mouse

            if (A_ThisFunc != this.action[this.action.MaxIndex()]){
               this.Converge()
               this.action.push(A_ThisFunc)
               this.x_hover := x_mouse
               this.y_hover := y_mouse
               pass := 1
            }

            v := (v) ? v : this.action.MaxIndex()
            dx := x_mouse - this.x_hover
            dy := y_mouse - this.y_hover

            if (pass == 1 || x_mouse != this.x_last || y_mouse != this.y_last) {
               this.x_last := x_mouse, this.y_last := y_mouse

               this.x[v] := this.x[v-1] + dx
               this.y[v] := this.y[v-1] + dy

               this.Propagate(v)
               this.Redraw(this.x[v], this.y[v], this.w[v], this.h[v])
            }
         }

         ResizeCorners(v := ""){
            CoordMode, Mouse, Screen
            MouseGetPos, x_mouse, y_mouse

            if (A_ThisFunc != this.action[this.action.MaxIndex()]){
               this.Converge()
               this.action.push(A_ThisFunc)
               this.x_hover := x_mouse
               this.y_hover := y_mouse
               pass := 1
            }

            v := (v) ? v : this.action.MaxIndex()
            xr := this.x_hover - this.x[v-1] - (this.w[v-1] / 2)
            yr := this.y[v-1] - this.y_hover + (this.h[v-1] / 2) ; Keep Change Change
            dx := x_mouse - this.x_hover
            dy := y_mouse - this.y_hover

            if (pass == 1 || x_mouse != this.x_last || y_mouse != this.y_last) {
               this.x_last := x_mouse, this.y_last := y_mouse

               if (xr < -1 && yr > 1) {
                  r := "top left"
                  this.x[v] := this.x[v-1] + dx
                  this.y[v] := this.y[v-1] + dy
                  this.w[v] := this.w[v-1] - dx
                  this.h[v] := this.h[v-1] - dy
               }
               if (xr >= -1 && yr > 1) {
                  r := "top right"
                  this.x[v] := this.x[v-1]
                  this.y[v] := this.y[v-1] + dy
                  this.w[v] := this.w[v-1] + dx
                  this.h[v] := this.h[v-1] - dy
               }
               if (xr < -1 && yr <= 1) {
                  r := "bottom left"
                  this.x[v] := this.x[v-1] + dx
                  this.y[v] := this.y[v-1]
                  this.w[v] := this.w[v-1] - dx
                  this.h[v] := this.h[v-1] + dy
               }
               if (xr >= -1 && yr <= 1) {
                  r := "bottom right"
                  this.x[v] := this.x[v-1]
                  this.y[v] := this.y[v-1]
                  this.w[v] := this.w[v-1] + dx
                  this.h[v] := this.h[v-1] + dy
               }

               this.Propagate(v)
               this.Redraw(this.x[v], this.y[v], this.w[v], this.h[v])
            }
         }

         ; This works by finding the line equations of the diagonals of the rectangle.
         ; To identify the quadrant the cursor is located in, the while loop compares it's y value
         ; with the function line values f(x) = m * xr and y = -m * xr.
         ; So if yr is below both theoretical y values, then we know it's in the bottom quadrant.
         ; Be careful with this code, it converts the y plane inversely to match the Decartes tradition.

         ; Safety features include checking for past values to prevent flickering
         ; Sleep statements are required in every while loop.

         ResizeEdges(v := ""){
            CoordMode, Mouse, Screen
            MouseGetPos, x_mouse, y_mouse

            if (A_ThisFunc != this.action[this.action.MaxIndex()]){
               this.Converge()
               this.action.push(A_ThisFunc)
               this.x_hover := x_mouse
               this.y_hover := y_mouse
               pass := 1
            }

            v := (v) ? v : this.action.MaxIndex()
            m := -(this.h[v-1] / this.w[v-1])                              ; slope (dy/dx)
            xr := this.x_hover - this.x[v-1] - (this.w[v-1] / 2)           ; draw a line across the center
            yr := this.y[v-1] - this.y_hover + (this.h[v-1] / 2)           ; draw a vertical line halfing it
            dx := x_mouse - this.x_hover
            dy := y_mouse - this.y_hover

            if (pass == 1 || x_mouse != this.x_last || y_mouse != this.y_last) {
               this.x_last := x_mouse, this.y_last := y_mouse

               if (m * xr >= yr && yr > -m * xr)
                  r := "left",                this.x[v] := this.x[v-1] + dx,               this.w[v] := this.w[v-1] - dx
               if (m * xr < yr && yr > -m * xr)
                  r := "top",                 this.y[v] := this.y[v-1] + dy,               this.h[v] := this.h[v-1] - dy
               if (m * xr < yr && yr <= -m * xr)
                  r := "right",   this.w[v] := this.w[v-1] + dx
               if (m * xr >= yr && yr <= -m * xr)
                  r := "bottom",  this.h[v] := this.h[v-1] + dy

               this.Propagate(v)
               this.Redraw(this.x[v], this.y[v], this.w[v], this.h[v])
            }
         }

         isMouseInside(){
            CoordMode, Mouse, Screen
            MouseGetPos, x_mouse, y_mouse
            return (x_mouse >= this.x[this.x.MaxIndex()]
               && x_mouse <= this.x[this.x.MaxIndex()] + this.w[this.w.MaxIndex()]
               && y_mouse >= this.y[this.y.MaxIndex()]
               && y_mouse <= this.y[this.y.MaxIndex()] + this.h[this.h.MaxIndex()])
         }

         isMouseOutside(){
            return !this.isMouseInside()
         }

         isMouseOnCorner(){
            CoordMode, Mouse, Screen
            MouseGetPos, x_mouse, y_mouse
            return (x_mouse == this.x[this.x.MaxIndex()] || x_mouse == this.x[this.x.MaxIndex()] + this.w[this.w.MaxIndex()])
               && (y_mouse == this.y[this.y.MaxIndex()] || y_mouse == this.y[this.y.MaxIndex()] + this.h[this.h.MaxIndex()])
         }

         isMouseOnEdge(){
            CoordMode, Mouse, Screen
            MouseGetPos, x_mouse, y_mouse
            return ((x_mouse >= this.x[this.x.MaxIndex()] && x_mouse <= this.x[this.x.MaxIndex()] + this.w[this.w.MaxIndex()])
               && (y_mouse == this.y[this.y.MaxIndex()] || y_mouse == this.y[this.y.MaxIndex()] + this.h[this.h.MaxIndex()]))
               OR ((y_mouse >= this.y[this.y.MaxIndex()] && y_mouse <= this.y[this.y.MaxIndex()] + this.h[this.h.MaxIndex()])
               && (x_mouse == this.x[this.x.MaxIndex()] || x_mouse == this.x[this.x.MaxIndex()] + this.w[this.w.MaxIndex()]))
         }

         isMouseStopped(){
            CoordMode, Mouse, Screen
            MouseGetPos, x_mouse, y_mouse
            return x_mouse == this.x_last && y_mouse == this.y_last
         }

         ScreenshotRectangle(){
            x := this.x1(), y := this.y1(), w := this.width(), h := this.height()
            return (w > 0 && h > 0) ? (x "|" y "|" w "|" h) : ""
         }

         x1(){
            return this.x[this.x.MaxIndex()]
         }

         x2(){
            return this.x[this.x.MaxIndex()] + this.w[this.w.MaxIndex()]
         }

         y1(){
            return this.y[this.y.MaxIndex()]
         }

         y2(){
            return this.y[this.y.MaxIndex()] + this.h[this.h.MaxIndex()]
         }

         width(){
            return this.w[this.w.MaxIndex()]
         }

         height(){
            return this.h[this.h.MaxIndex()]
         }
      }

      Class CustomFont{
         /*
         CustomFont v2.00 (2016-2-24) by tmplinshi
         ---------------------------------------------------------
         Description: Load font from file or resource, without needed install to system.
         ---------------------------------------------------------
         Useage Examples:

            * Load From File
               font1 := New CustomFont("ewatch.ttf")
               Gui, Font, s100, ewatch

            * Load From Resource
               Gui, Add, Text, HWNDhCtrl w400 h200, 12345
               font2 := New CustomFont("res:ewatch.ttf", "ewatch", 80) ; <- Add a res: prefix to the resource name.
               font2.ApplyTo(hCtrl)

            * The fonts will removed automatically when script exits.
              To remove a font manually, just clear the variable (e.g. font1 := "").
         */

         static FR_PRIVATE  := 0x10

         __New(FontFile, FontName="", FontSize=30) {
            if RegExMatch(FontFile, "i)res:\K.*", _FontFile) {
               this.AddFromResource(_FontFile, FontName, FontSize)
            } else {
               this.AddFromFile(FontFile)
            }
         }

         AddFromFile(FontFile) {
            DllCall( "AddFontResourceEx", "Str", FontFile, "UInt", this.FR_PRIVATE, "UInt", 0 )
            this.data := FontFile
         }

         AddFromResource(ResourceName, FontName, FontSize = 30) {
            static FW_NORMAL := 400, DEFAULT_CHARSET := 0x1

            nSize    := this.ResRead(fData, ResourceName)
            fh       := DllCall( "AddFontMemResourceEx", "Ptr", &fData, "UInt", nSize, "UInt", 0, "UIntP", nFonts )
            hFont    := DllCall( "CreateFont", Int,FontSize, Int,0, Int,0, Int,0, UInt,FW_NORMAL, UInt,0
                        , Int,0, Int,0, UInt,DEFAULT_CHARSET, Int,0, Int,0, Int,0, Int,0, Str,FontName )

            this.data := {fh: fh, hFont: hFont}
         }

         ApplyTo(hCtrl) {
            SendMessage, 0x30, this.data.hFont, 1,, ahk_id %hCtrl%
         }

         __Delete() {
            if IsObject(this.data) {
               DllCall( "RemoveFontMemResourceEx", "UInt", this.data.fh    )
               DllCall( "DeleteObject"           , "UInt", this.data.hFont )
            } else {
               DllCall( "RemoveFontResourceEx"   , "Str", this.data, "UInt", this.FR_PRIVATE, "UInt", 0 )
            }
         }

         ; ResRead() By SKAN, from http://www.autohotkey.com/board/topic/57631-crazy-scripting-resource-only-dll-for-dummies-36l-v07/?p=609282
         ResRead( ByRef Var, Key ) {
            VarSetCapacity( Var, 128 ), VarSetCapacity( Var, 0 )
            If ! ( A_IsCompiled ) {
               FileGetSize, nSize, %Key%
               FileRead, Var, *c %Key%
               Return nSize
            }

            If hMod := DllCall( "GetModuleHandle", UInt,0 )
               If hRes := DllCall( "FindResource", UInt,hMod, Str,Key, UInt,10 )
                  If hData := DllCall( "LoadResource", UInt,hMod, UInt,hRes )
                     If pData := DllCall( "LockResource", UInt,hData )
                        Return VarSetCapacity( Var, nSize := DllCall( "SizeofResource", UInt,hMod, UInt,hRes ) )
                           ,  DllCall( "RtlMoveMemory", Str,Var, UInt,pData, UInt,nSize )
            Return 0
         }
      }

      class Image{

         ScreenWidth := A_ScreenWidth, ScreenHeight := A_ScreenHeight

         __New(name := "") {
            this.name := name := (name == "") ? Vis2.Graphics.Name() "_Graphics_Image" : name "_Graphics_Image"

            Vis2.Graphics.Startup()
            Gui, %name%: New, +LastFound +AlwaysOnTop -Caption -DPIScale +E0x80000 +ToolWindow +hwndSecretName, % this.name
            this.hwnd := SecretName
            DllCall("ShowWindow", "ptr",this.hwnd, "int",8)
            this.hbm := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
            this.hdc := CreateCompatibleDC()
            this.obm := SelectObject(this.hdc, this.hbm)
            this.G := Gdip_GraphicsFromHDC(this.hdc)
            Gdip_SetInterpolationMode(this.G, 7)
         }

         __Delete(){
            Vis2.Graphics.Shutdown()
         }

         Border() {
            Gui, % this.name ": +Border"
            UpdateLayeredWindow(this.hwnd, this.hdc, (A_ScreenWidth-this.w)/2, (A_ScreenHeight-this.h)/2, this.w, this.h)
            return this
         }

         Destroy() {
            SelectObject(this.hdc, this.obm)
            DeleteObject(this.hbm)
            DeleteDC(this.hdc)
            Gdip_DeleteGraphics(this.G)
            Gui, % this.name ":Destroy"
            return this
         }

         Hide() {
            Gui, % this.name ":Show", Hide
            return this
         }

         Show() {
            Gui, % this.name ":Show", NoActivate
            return this
         }

         ToggleVisible() {
            if DllCall("IsWindowVisible", "UInt", this.hwnd)
               Gui, % this.name ":Show", Hide
            else
               Gui, % this.name ":Show", NoActivate
            return this
         }

         isVisible() {
            return DllCall("IsWindowVisible", "UInt", this.hwnd)
         }

         Render(file, scale := 1, time := 0) {
            if (this.hwnd){
               this.scale := scale
               if (time) {
                  self_destruct := ObjBindMethod(this, "Destroy")
                  SetTimer, % self_destruct, % -1 * time
               }
               Critical On
               if FileExist(file)
                  f := pBitmap := Gdip_CreateBitmapFromFile(file)
               else pBitmap := file
               Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap)
               this.DetectScreenResolutionChange(Width, Height)
               Gdip_DrawImage(this.G, pBitmap, 0, 0, Floor(Width*scale), Floor(Height*scale), 0, 0, Width, Height)
               UpdateLayeredWindow(this.hwnd, this.hdc, 0, 0, Floor(Width*scale), Floor(Height*scale))
               this.w := Floor(Width*scale)
               this.h := Floor(Height*scale)
               if f
                  Gdip_DisposeImage(pBitmap)
               Critical Off
               return this
            }
            else {
               parent := ((___ := RegExReplace(A_ThisFunc, "^(.*)\..*\..*$", "$1")) != A_ThisFunc) ? ___ : ""
               Loop, Parse, parent, .
                  parent := (A_Index=1) ? %A_LoopField% : parent[A_LoopField]
               _image := (parent) ? new parent.image() : new image()
               return _image.Render(file, scale, time)
            }
         }

         DetectScreenResolutionChange(w:="", h:=""){
            w := (w) ? w : A_ScreenWidth
            h := (h) ? h : A_ScreenHeight
            if (this.ScreenWidth != w || this.ScreenHeight != h) {
               this.ScreenWidth := w, this.ScreenHeight := h
               SelectObject(this.hdc, this.obm)
               DeleteObject(this.hbm)
               DeleteDC(this.hdc)
               Gdip_DeleteGraphics(this.G)
               this.hbm := CreateDIBSection(this.ScreenWidth, this.ScreenHeight)
               this.hdc := CreateCompatibleDC()
               this.obm := SelectObject(this.hdc, this.hbm)
               this.G := Gdip_GraphicsFromHDC(this.hdc)
               Gdip_SetInterpolationMode(this.G, 7)
            }
         }
      }

      class Subtitle{

         layers := {}, ScreenWidth := A_ScreenWidth, ScreenHeight := A_ScreenHeight

         __New(name := ""){
            parent := ((___ := RegExReplace(A_ThisFunc, "^(.*)\..*\..*$", "$1")) != A_ThisFunc) ? ___ : ""
            Loop, Parse, parent, .
               this.parent := (A_Index=1) ? %A_LoopField% : this.parent[A_LoopField]

            this.parent.Startup()
            Gui, New, +LastFound +AlwaysOnTop -Caption -DPIScale +E0x80000 +ToolWindow +hwndSecretName
            this.hwnd := SecretName
            this.name := (name != "") ? name "_Subtitle" : "Subtitle_" this.hwnd
            DllCall("ShowWindow", "ptr",this.hwnd, "int",8)
            DllCall("SetWindowText", "ptr",this.hwnd, "str",this.name)
            this.hbm := CreateDIBSection(this.ScreenWidth, this.ScreenHeight)
            this.hdc := CreateCompatibleDC()
            this.obm := SelectObject(this.hdc, this.hbm)
            this.G := Gdip_GraphicsFromHDC(this.hdc)
            this.colorMap := this.colorMap()
         }

         __Delete(){
            this.parent.Shutdown()
         }

         FreeMemory(){
            SelectObject(this.hdc, this.obm)
            DeleteObject(this.hbm)
            DeleteDC(this.hdc)
            Gdip_DeleteGraphics(this.G)
            return this
         }

         Destroy(){
            this.FreeMemory()
            DllCall("DestroyWindow", "ptr",this.hwnd)
            return this
         }

         Hide(){
            DllCall("ShowWindow", "ptr",this.hwnd, "int",0)
            return this
         }

         Show(){
            DllCall("ShowWindow", "ptr",this.hwnd, "int",8)
            return this
         }

         ToggleVisible(){
            this.isVisible() ? this.Hide() : this.Show()
            return this
         }

         isVisible(){
            return DllCall("IsWindowVisible", "ptr",this.hwnd)
         }

         ClickThrough(){
            DetectHiddenWindows On
            WinSet, ExStyle, +0x20, % "ahk_id" this.hwnd
            DetectHiddenWindows Off
            return this
         }

         DetectScreenResolutionChange(w:="", h:=""){
            w := (w) ? w : A_ScreenWidth
            h := (h) ? h : A_ScreenHeight
            if (this.ScreenWidth != w || this.ScreenHeight != h) {
               this.ScreenWidth := w, this.ScreenHeight := h
               SelectObject(this.hdc, this.obm)
               DeleteObject(this.hbm)
               DeleteDC(this.hdc)
               Gdip_DeleteGraphics(this.G)
               this.hbm := CreateDIBSection(this.ScreenWidth, this.ScreenHeight)
               this.hdc := CreateCompatibleDC()
               this.obm := SelectObject(this.hdc, this.hbm)
               this.G := Gdip_GraphicsFromHDC(this.hdc)
            }
         }

         Draw(text := "", style1 := "", style2 := "", pGraphics := "") {
            if (pGraphics == "") {
               pGraphics := this.G
               if (this.rendered == true) {
                  this.rendered := false
                  this.layers := {}
                  this.x := this.y := this.xx := this.yy := ""
                  Gdip_GraphicsClear(this.G)
               }
               this.layers.push([text, style1, style2])
            }

            ; Remember styles so that they can be loaded next time.
            style1 := (style1) ? this.style1 := style1 : this.style1
            style2 := (style2) ? this.style2 := style2 : this.style2

            static q1 := "i)^.*?(?<!-|:|:\s)\b(?![^\(]*\))"
            static q2 := "(:\s?)?\(?(?<value>(?<=\()[\s\-\da-z\.#%]+(?=\))|[\-\da-z\.#%]+).*$"

            time := (style1.t) ? style1.t : (style1.time) ? style1.time
                  : (!IsObject(style1) && (___ := RegExReplace(style1, q1 "(t(ime)?)" q2, "${value}")) != style1) ? ___
                  : (style2.t) ? style2.t : (style2.time) ? style2.time
                  : (!IsObject(style2) && (___ := RegExReplace(style2, q1 "(t(ime)?)" q2, "${value}")) != style2) ? ___
                  : 0

            if (time) {
               self_destruct := ObjBindMethod(this, "Destroy")
               SetTimer, % self_destruct, % -1 * time
            }

            static alpha := "^[A-Za-z]+$"
            static decimal := "^(\-?\d+(\.\d*)?)$"
            static integer := "^\d+$"
            static percentage := "^(\-?\d+(?:\.\d*)?)%$"
            static positive := "^\d+(\.\d*)?$"

            if IsObject(style1){
               _a  := (style1.a != "")  ? style1.a  : style1.anchor
               _x  := (style1.x != "")  ? style1.x  : style1.left
               _y  := (style1.y != "")  ? style1.y  : style1.top
               _w  := (style1.w != "")  ? style1.w  : style1.width
               _h  := (style1.h != "")  ? style1.h  : style1.height
               _r  := (style1.r != "")  ? style1.r  : style1.radius
               _c  := (style1.c != "")  ? style1.c  : style1.color
               _m  := (style1.m != "")  ? style1.m  : style1.margin
               _p  := (style1.p != "")  ? style1.p  : style1.padding
               _q  := (style1.q != "")  ? style1.q  : (style1.quality) ? style1.quality : style1.SmoothingMode
            } else {
               _a  := ((___ := RegExReplace(style1, q1    "(a(nchor)?)"            q2, "${value}")) != style1) ? ___ : ""
               _x  := ((___ := RegExReplace(style1, q1    "(x|left)"               q2, "${value}")) != style1) ? ___ : ""
               _y  := ((___ := RegExReplace(style1, q1    "(y|top)"                q2, "${value}")) != style1) ? ___ : ""
               _w  := ((___ := RegExReplace(style1, q1    "(w(idth)?)"             q2, "${value}")) != style1) ? ___ : ""
               _h  := ((___ := RegExReplace(style1, q1    "(h(eight)?)"            q2, "${value}")) != style1) ? ___ : ""
               _r  := ((___ := RegExReplace(style1, q1    "(r(adius)?)"            q2, "${value}")) != style1) ? ___ : ""
               _c  := ((___ := RegExReplace(style1, q1    "(c(olor)?)"             q2, "${value}")) != style1) ? ___ : ""
               _m  := ((___ := RegExReplace(style1, q1    "(m(argin)?)"            q2, "${value}")) != style1) ? ___ : ""
               _p  := ((___ := RegExReplace(style1, q1    "(p(adding)?)"           q2, "${value}")) != style1) ? ___ : ""
               _q  := ((___ := RegExReplace(style1, q1    "(q(uality)?)"           q2, "${value}")) != style1) ? ___ : ""
            }

            if IsObject(style2){
               a  := (style2.a != "")  ? style2.a  : style2.anchor
               x  := (style2.x != "")  ? style2.x  : style2.left
               y  := (style2.y != "")  ? style2.y  : style2.top
               w  := (style2.w != "")  ? style2.w  : style2.width
               h  := (style2.h != "")  ? style2.h  : style2.height
               m  := (style2.m != "")  ? style2.m  : style2.margin
               f  := (style2.f != "")  ? style2.f  : style2.font
               s  := (style2.s != "")  ? style2.s  : style2.size
               c  := (style2.c != "")  ? style2.c  : style2.color
               b  := (style2.b != "")  ? style2.b  : style2.bold
               i  := (style2.i != "")  ? style2.i  : style2.italic
               u  := (style2.u != "")  ? style2.u  : style2.underline
               j  := (style2.j != "")  ? style2.j  : style2.justify
               n  := (style2.n != "")  ? style2.n  : style2.noWrap
               z  := (style2.z != "")  ? style2.z  : style2.condensed
               d  := (style2.d != "")  ? style2.d  : style2.dropShadow
               o  := (style2.o != "")  ? style2.o  : style2.outline
               q  := (style2.q != "")  ? style2.q  : (style2.quality) ? style2.quality : style2.TextRenderingHint
            } else {
               a  := ((___ := RegExReplace(style2, q1    "(a(nchor)?)"            q2, "${value}")) != style2) ? ___ : ""
               x  := ((___ := RegExReplace(style2, q1    "(x|left)"               q2, "${value}")) != style2) ? ___ : ""
               y  := ((___ := RegExReplace(style2, q1    "(y|top)"                q2, "${value}")) != style2) ? ___ : ""
               w  := ((___ := RegExReplace(style2, q1    "(w(idth)?)"             q2, "${value}")) != style2) ? ___ : ""
               h  := ((___ := RegExReplace(style2, q1    "(h(eight)?)"            q2, "${value}")) != style2) ? ___ : ""
               m  := ((___ := RegExReplace(style2, q1    "(m(argin)?)"            q2, "${value}")) != style2) ? ___ : ""
               f  := ((___ := RegExReplace(style2, q1    "(f(ont)?)"              q2, "${value}")) != style2) ? ___ : ""
               s  := ((___ := RegExReplace(style2, q1    "(s(ize)?)"              q2, "${value}")) != style2) ? ___ : ""
               c  := ((___ := RegExReplace(style2, q1    "(c(olor)?)"             q2, "${value}")) != style2) ? ___ : ""
               b  := ((___ := RegExReplace(style2, q1    "(b(old)?)"              q2, "${value}")) != style2) ? ___ : ""
               i  := ((___ := RegExReplace(style2, q1    "(i(talic)?)"            q2, "${value}")) != style2) ? ___ : ""
               u  := ((___ := RegExReplace(style2, q1    "(u(nderline)?)"         q2, "${value}")) != style2) ? ___ : ""
               j  := ((___ := RegExReplace(style2, q1    "(j(ustify)?)"           q2, "${value}")) != style2) ? ___ : ""
               n  := ((___ := RegExReplace(style2, q1    "(n(oWrap)?)"            q2, "${value}")) != style2) ? ___ : ""
               z  := ((___ := RegExReplace(style2, q1    "(z|condensed?)"         q2, "${value}")) != style2) ? ___ : ""
               d  := ((___ := RegExReplace(style2, q1    "(d(ropShadow)?)"        q2, "${value}")) != style2) ? ___ : ""
               o  := ((___ := RegExReplace(style2, q1    "(o(utline)?)"           q2, "${value}")) != style2) ? ___ : ""
               q  := ((___ := RegExReplace(style2, q1    "(q(uality)?)"           q2, "${value}")) != style2) ? ___ : ""
            }

            ; Step 1 - Simulate string width and height, setting only the variables we need to determine it.
            style += (b) ? 1 : 0      ; bold
            style += (i) ? 2 : 0      ; italic
            style += (u) ? 4 : 0      ; underline
            style += (strike) ? 8 : 0 ; strikeout, not implemented.
            s  := (s ~= percentage) ? A_ScreenHeight * SubStr(s, 1, -1)  / 100 :  s
            s  := (s ~= positive) ? s : 36
            q  := (q >= 0 && q <= 5) ? q : 4
            n  := (n) ? 0x4000 | 0x1000 : 0x4000
            j  := (j ~= "i)cent(er|re)") ? 1 : (j ~= "i)(far|right)") ? 2 : 0
            _q := (_q >= 0 && _q <= 4) ? _q : 4

            Gdip_SetSmoothingMode(pGraphics, _q)
            Gdip_SetTextRenderingHint(pGraphics, q) ; 4 = Anti-Alias, 5 = Cleartype
            hFamily := (___ := Gdip_FontFamilyCreate(f)) ? ___ : Gdip_FontFamilyCreate("Arial")
            hFont := Gdip_FontCreate(hFamily, s, style)
            hFormat := Gdip_StringFormatCreate(n)
            Gdip_SetStringFormatAlign(hFormat, j)

            CreateRectF(RC, 0, 0, 0, 0)
            ReturnRC := Gdip_MeasureString(pGraphics, Text, hFont, hFormat, RC)
            ReturnRC := StrSplit(ReturnRC, "|")

            ; Step 2 - Define margins and padding.
            _m := this.margin(_m)
            _p := this.margin(_p)
             m := this.margin( m)
             p := this.margin( p)

            ; Bonus - Condense Text using a Condensed Font if simulated text width exceeds screen width.
            if (___ := Gdip_FontFamilyCreate(z)) {
               ExtraMargin := (_m.2 + _m.4 + _p.2 + _p.4)
               if (ReturnRC[3] + ExtraMargin > A_ScreenWidth){
                  hFamily := Gdip_FontFamilyCreate(z)
                  hFont := Gdip_FontCreate(hFamily, s, style)
                  ReturnRC := Gdip_MeasureString(pGraphics, Text, hFont, hFormat, RC)
                  ReturnRC := StrSplit(ReturnRC, "|")
                  _w  := ReturnRC[3]
               }
            }

            ; Step 3 - Define _width and _height. Do not modify with margin and padding.
            _w  := (_w  ~= percentage) ? A_ScreenWidth  * SubStr(_w, 1, -1)  / 100 : _w
            _h  := (_h  ~= percentage) ? A_ScreenHeight * SubStr(_h, 1, -1)  / 100 : _h
            _w  := (_w  ~= positive) ? _w  : ReturnRC[3]
            _h  := (_h  ~= positive) ? _h  : ReturnRC[4]

            ; Step 4 - Define _anchor with a default value of 1.
            _a  := (_a = "top") ? 2 : (_a = "left") ? 4 : (_a = "right") ? 6 : (_a = "bottom") ? 8
                  : (_a ~= "i)top" && _a ~= "i)left") ? 1 : (_a ~= "i)top" && _a ~= "i)cent(er|re)") ? 2
                  : (_a ~= "i)top" && _a ~= "i)bottom") ? 3 : (_a ~= "i)cent(er|re)" && _a ~= "i)left") ? 4
                  : (_a ~= "i)cent(er|re)") ? 5 : (_a ~= "i)cent(er|re)" && _a ~= "i)bottom") ? 6
                  : (_a ~= "i)bottom" && _a ~= "i)left") ? 7 : (_a ~= "i)bottom" && _a ~= "i)cent(er|re)") ? 8
                  : (_a ~= "i)bottom" && _a ~= "i)right") ? 9 : (_a ~= "^[1-9]$") ? _a : 1 ; default

            ; Step 5 - Modify _anchor with _x and _y.
            _a  := (_x  = "left") ? 1+(((_a-1)//3)*3) : (_x ~= "i)cent(er|re)") ? 2+(((_a-1)//3)*3) : (_x = "right") ? 3+(((_a-1)//3)*3) : _a
            _a  := (_y  = "top") ? 1+(mod(_a-1,3)) : (_y ~= "i)cent(er|re)") ? 4+(mod(_a-1,3)) : (_y = "bottom") ? 7+(mod(_a-1,3)) : _a

            ; Step 6 - Define _x and _y with respect to _anchor.
            _x  := (_x  = "left") ? 0 : (_x ~= "i)cent(er|re)") ? 0.5*A_ScreenWidth : (_x = "right") ? A_ScreenWidth : _x
            _y  := (_y  = "top") ? 0 : (_y ~= "i)cent(er|re)") ? 0.5*A_ScreenHeight : (_y = "bottom") ? A_ScreenHeight : _y
            _x  := (_x  ~= percentage) ? A_ScreenWidth  * SubStr(_x, 1, -1)  / 100 : _x
            _y  := (_y  ~= percentage) ? A_ScreenHeight * SubStr(_y, 1, -1)  / 100 : _y
            _x  := (_x  ~= decimal) ? _x  : 0
            _y  := (_y  ~= decimal) ? _y  : 0
            _x  -= (mod(_a-1,3) == 0) ? 0 : (mod(_a-1,3) == 1) ? _w/2 : (mod(_a-1,3) == 2) ? _w : 0
            _y  -= (((_a-1)//3) == 0) ? 0 : (((_a-1)//3) == 1) ? _h/2 : (((_a-1)//3) == 2) ? _h : 0
            ; Fractional y values might cause gdi+ slowdown.


            ; Round 1 - Define width and height.
            w  := ( w  ~= percentage) ? _w * RegExReplace( w, percentage, "$1")  / 100 : w
            h  := ( h  ~= percentage) ? _h * RegExReplace( h, percentage, "$1")  / 100 : h
            w  := ( w  ~= positive) ?  w  : (_w) ? _w : ReturnRC[3] ;if _w = 0
            h  := ( h  ~= positive) ?  h  : (_h) ? _h : ReturnRC[4]

            ; Round 2 - Define anchor.
            a  := (a = "top") ? 2 : (a = "left") ? 4 : (a = "right") ? 6 : (a = "bottom") ? 8
                  : (a ~= "i)top" && a ~= "i)left") ? 1 : (a ~= "i)top" && a ~= "i)cent(er|re)") ? 2
                  : (a ~= "i)top" && a ~= "i)bottom") ? 3 : (a ~= "i)cent(er|re)" && a ~= "i)left") ? 4
                  : (a ~= "i)cent(er|re)") ? 5 : (_a ~= "i)cent(er|re)" && a ~= "i)bottom") ? 6
                  : (a ~= "i)bottom" && a ~= "i)left") ? 7 : (a ~= "i)bottom" && a ~= "i)cent(er|re)") ? 8
                  : (a ~= "i)bottom" && a ~= "i)right") ? 9 : (a ~= "^[1-9]$") ? a : 1 ; default

            a  := ( x  = "left") ? 1+((( a-1)//3)*3) : ( x ~= "i)cent(er|re)") ? 2+((( a-1)//3)*3) : ( x = "right") ? 3+((( a-1)//3)*3) :  a
            a  := ( y  = "top") ? 1+(mod( a-1,3)) : ( y ~= "i)cent(er|re)") ? 4+(mod( a-1,3)) : ( y = "bottom") ? 7+(mod( a-1,3)) :  a

            ; Round 3 - Define x and y with respect to anchor.
            x  := ( x  = "left") ? _x : (x ~= "i)cent(er|re)") ? _x + 0.5*_w : (x = "right") ? _x + _w : x
            y  := ( y  = "top") ? _y : (y ~= "i)cent(er|re)") ? _y + 0.5*_h : (y = "bottom") ? _y + _h : y
            x  := ( x  ~= percentage) ? _x + (_w * RegExReplace( x, percentage, "$1")  / 100) : x
            y  := ( y  ~= percentage) ? _y + (_h * RegExReplace( y, percentage, "$1")  / 100) : y
            x  := ( x  ~= decimal) ? x  : _x
            y  := ( y  ~= decimal) ? y  : _y
            x  -= (mod(a-1,3) == 0) ? 0 : (mod(a-1,3) == 1) ? ReturnRC[3]/2 : (mod(a-1,3) == 2) ? ReturnRC[3] : 0
            y  -= (((a-1)//3) == 0) ? 0 : (((a-1)//3) == 1) ? ReturnRC[4]/2 : (((a-1)//3) == 2) ? ReturnRC[4] : 0

            ; Round 4 - Modify _x, _y, _w, _h with margin and padding.
            if (_w && _h) {
               _w  += (_m.2 + _m.4 + _p.2 + _p.4) + (m.2 + m.4 + p.2 + p.4)
               _h  += (_m.1 + _m.3 + _p.1 + _p.3) + (m.1 + m.3 + p.1 + p.3)
               _x  -= (_m.1 + _p.1)
               _y  -= (_m.4 + _p.4)
            }

            ; Round 5 - Modify x, y with margin and padding.
            x  += (m.1 + p.1)
            y  += (m.4 + p.4)

            ; Round 6 - Define radius of rounded corners.
            _smaller := (_w > _h) ? _h : _w
            _r  := (_r  ~= percentage) ? _smaller * RegExReplace(_r, percentage, "$1")  / 100 : _r
            _r  := (_r  <= _smaller / 2 && _r ~= positive) ? _r : 0

            ; Round 7 - Define color.
            _c := this.color(_c, 0xDD424242)
             c := this.color( c, 0xFFFFFFFF)

            ; Round 8 - Define outline and dropShadow.
            o := this.outline(o)
            d := this.dropShadow(d)

            ; Round 9 - Define Text
            if (!A_IsUnicode){
               nSize := DllCall("MultiByteToWideChar", "uint",0, "uint",0, "ptr",&text, "int",-1, "ptr",0, "int",0)
               VarSetCapacity(wtext, nSize*2)
               DllCall("MultiByteToWideChar", "uint",0, "uint",0, "ptr",&text, "int",-1, "ptr",&wtext, "int",nSize)
            }


            ; Draw 1 - Background
            if (_w && _h && _c && (_c & 0xFF000000)) {
               pBrushBackground := Gdip_BrushCreateSolid(_c)
               Gdip_FillRoundedRectangle(pGraphics, pBrushBackground, _x, _y, _w, _h, _r)
               Gdip_DeleteBrush(pBrushBackground)
            }

            ; Draw 2 - DropShadow
            if (!d.void) {
               delta := 2*d.3 + 2*o.1
               offset := d.3 + o.1

               if (d.3) {
                  pBitmap := Gdip_CreateBitmap(w + delta, h + delta)
                  pGraphicsDropShadow := Gdip_GraphicsFromImage(pBitmap)
                  Gdip_SetSmoothingMode(pGraphicsDropShadow, _q)
                  Gdip_SetTextRenderingHint(pGraphicsDropShadow, q)
                  CreateRectF(RC, offset, offset, w + delta, h + delta)
               } else {
                  CreateRectF(RC, x + d.1, y + d.2, w, h)
                  pGraphicsDropShadow := pGraphics
               }

               if (!o.void)
               {
                  DllCall("gdiplus\GdipCreatePath", "int",1, "uptr*",pPath)
                  DllCall("gdiplus\GdipAddPathString", "ptr",pPath, "ptr", A_IsUnicode ? &text : &wtext, "int",-1
                                                     , "ptr",hFamily, "int",style, "float",s, "ptr",&RC, "ptr",hFormat)
                  pPen := Gdip_CreatePen(d.4, o.1)
                  DllCall("gdiplus\GdipSetPenLineJoin", "ptr",pPen, "uInt",2)
                  DllCall("gdiplus\GdipDrawPath", "ptr",pGraphicsDropShadow, "ptr",pPen, "ptr",pPath)
                  Gdip_DeletePen(pPen)
                  pBrush := Gdip_BrushCreateSolid(d.4)
                  Gdip_SetCompositingMode(pGraphicsDropShadow, 1) ; Turn off alpha blending
                  Gdip_SetSmoothingMode(pGraphicsDropShadow, 3)   ; Turn off anti-aliasing
                  Gdip_FillPath(pGraphicsDropShadow, pBrush, pPath)
                  Gdip_DeleteBrush(pBrush)
                  Gdip_DeletePath(pPath)
                  Gdip_SetCompositingMode(pGraphicsDropShadow, 0)
                  Gdip_SetSmoothingMode(pGraphicsDropShadow, _q)
               }
               else
               {
                  pBrush := Gdip_BrushCreateSolid(d.4)
                  Gdip_DrawString(pGraphicsDropShadow, Text, hFont, hFormat, pBrush, RC)
                  Gdip_DeleteBrush(pBrush)
               }

               if (d.3) {
                  Gdip_DeleteGraphics(pGraphicsDropShadow)
                  pBlur := Gdip_BlurBitmap(pBitmap, d.3)
                  Gdip_DisposeImage(pBitmap)
                  Gdip_DrawImage(pGraphics, pBlur, x + d.1 - offset, y + d.2 - offset, w + delta, h + delta)
                  Gdip_DisposeImage(pBlur)
               }
            }

            ; Draw 3 - Text Outline
            if (!o.void) {
               ; Convert our text to a path.
               CreateRectF(RC, x, y, w, h)
               DllCall("gdiplus\GdipCreatePath", "int",1, "uptr*",pPath)
               DllCall("gdiplus\GdipAddPathString", "ptr",pPath, "ptr", A_IsUnicode ? &text : &wtext, "int",-1
                                                  , "ptr",hFamily, "int",style, "float",s, "ptr",&RC, "ptr",hFormat)

               ; Create a pen.
               pPen := Gdip_CreatePen(o.2, o.1)
               DllCall("gdiplus\GdipSetPenLineJoin", "ptr",pPen, "uint",2)

               ; Create a glow effect around the edges.
               if (o.3) {
                  DllCall("gdiplus\GdipClonePath", "ptr",pPath, "uptr*",pPathGlow)
                  DllCall("gdiplus\GdipWidenPath", "ptr",pPathGlow, "ptr",pPen, "ptr",0, "float",1)

                  ; Set color to glowColor or use the previous color.
                  color := (o.4) ? o.4 : o.2

                  loop % o.3
                  {
                     ARGB := Format("0x{:02X}",((color & 0xFF000000) >> 24)/o.3) . Format("{:06X}",(color & 0x00FFFFFF))
                     pPenGlow := Gdip_CreatePen(ARGB, A_Index)
                     DllCall("gdiplus\GdipSetPenLineJoin", "ptr",pPenGlow, "uInt",2)
                     DllCall("gdiplus\GdipDrawPath", "ptr",pGraphics, "ptr",pPenGlow, "ptr",pPathGlow)
                     Gdip_DeletePen(pPenGlow)
                  }
                  Gdip_DeletePath(pPathGlow)
               }

               ; Draw outline text.
               if (o.1)
                  DllCall("gdiplus\GdipDrawPath", "ptr",pGraphics, "ptr",pPen, "ptr",pPath)

               ; Fill outline text.
               if (c && (c & 0xFF000000)) {
                  pBrush := Gdip_BrushCreateSolid(c)
                  Gdip_FillPath(pGraphics, pBrush, pPath)
                  Gdip_DeleteBrush(pBrush)
               }
               Gdip_DeletePen(pPen)
               Gdip_DeletePath(pPath)
            }

            ; Draw Text
            if (text != "" && d.void && o.void) {
               CreateRectF(RC, x, y, w, h)
               pBrushText := Gdip_BrushCreateSolid(c)
               Gdip_DrawString(pGraphics, text, hFont, hFormat, pBrushText, RC)
               Gdip_DeleteBrush(pBrushText)
            }

            ; Complete
            Gdip_DeleteStringFormat(hFormat)
            Gdip_DeleteFont(hFont)
            Gdip_DeleteFontFamily(hFamily)

            ; Correct Offsets
            _w := (_w == 0) ? (ReturnRC[3] + d.1 + 2*d.3 + 2*o.1 + 2*o.3) : _w
            _h := (_h == 0) ? (ReturnRC[4] + d.2 + 2*d.3 + 2*o.1 + 2*o.3) : _h

            this.x  := (this.x  = "" || _x < this.x) ? _x : this.x
            this.y  := (this.y  = "" || _y < this.y) ? _y : this.y
            this.xx := (this.xx = "" || _x + _w > this.xx) ? _x + _w : this.xx
            this.yy := (this.yy = "" || _y + _h > this.yy) ? _y + _h : this.yy
            return
         }

         Render(text := "", style1 := "", style2 := "", update := 1){
            if (this.hWnd){
               Critical On
               this.DetectScreenResolutionChange()
               this.Draw(text, style1, style2)
               if (update)
                  UpdateLayeredWindow(this.hwnd, this.hdc, 0, 0, A_ScreenWidth, A_ScreenHeight)
               this.rendered := true
               Critical Off
               return this
            }
            else {
               parent := ((___ := RegExReplace(A_ThisFunc, "^(.*)\..*\..*$", "$1")) != A_ThisFunc) ? ___ : ""
               Loop, Parse, parent, .
                  parent := (A_Index=1) ? %A_LoopField% : parent[A_LoopField]
               _subtitle := (parent) ? new parent.Subtitle() : new Subtitle()
               return _subtitle.Render(text, style1, style2, update)
            }
         }

         Bitmap(x:=0, y:=0, w:=0, h:=0){
            pBitmap := Gdip_CreateBitmap(A_ScreenWidth, A_ScreenHeight)
            pGraphics := Gdip_GraphicsFromImage(pBitmap)
            loop % this.layers.MaxIndex()
               this.Draw(this.layers[A_Index].1, this.layers[A_Index].2, this.layers[A_Index].3, pGraphics)
            Gdip_DeleteGraphics(pGraphics)

            if (x || y || w || h) {
               w := (w = 0) ? A_ScreenWidth, h := (h = 0) ? A_ScreenHeight
               pBitmap2 := Gdip_CloneBitmapArea(pBitmap, x, y, w, h)
               Gdip_DisposeImage(pBitmap)
               pBitmap := pBitmap2
            }
            return pBitmap ; Please dispose of this image responsibly.
         }

         Save(filename := "", quality := 92, fullscreen := 0){
            filename := (filename ~= "i)\.(bmp|dib|rle|jpg|jpeg|jpe|jfif|gif|tif|tiff|png)$") ? filename
                      : (filename != "") ? filename ".png" : this.name ".png"
            pBitmap := (fullscreen) ? this.Bitmap() : this.Bitmap(this.x, this.y, this.xx - this.x, this.yy - this.y)
            Gdip_SaveBitmapToFile(pBitmap, filename, quality)
            Gdip_DisposeImage(pBitmap)
         }

         SaveFullScreen(filename := "", quality := ""){
            return this.Save(filename, quality, 1)
         }

         hBitmap(alpha := 0xFFFFFFFF){
            ; hBitmap converts alpha channel to specified alpha color.
            ; Add 1 pixel because Anti-Alias (SmoothingMode = 4)
            ; Should it be crop 1 pixel instead?
            pBitmap := this.Bitmap(this.x, this.y, this.xx - this.x, this.yy - this.y)
            hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap, alpha)
            Gdip_DisposeImage(pBitmap)
            return hBitmap
         }

         RenderToHBitmap(text := "", style1 := "", style2 := ""){
            if (this.hWnd){
               this.Render(text, style1, style2, 0)
               return this.hBitmap()
            }
            else {
               parent := ((___ := RegExReplace(A_ThisFunc, "^(.*)\..*\..*$", "$1")) != A_ThisFunc) ? ___ : ""
               Loop, Parse, parent, .
                  parent := (A_Index=1) ? %A_LoopField% : parent[A_LoopField]
               _subtitle := (parent) ? new parent.Subtitle() : new Subtitle()
               _subtitle.Render(text, style1, style2, 0)
               return _subtitle.hBitmap() ; Does not return a subtitle object.
            }
         }

         hIcon(){
            pBitmap := this.Bitmap(this.x, this.y, this.xx - this.x, this.yy - this.y)
            hIcon := Gdip_CreateHICONFromBitmap(pBitmap)
            Gdip_DisposeImage(pBitmap)
            return hIcon
         }

         color(c, default := 0xDD424242){
            static colorRGB  := "^0x([0-9A-Fa-f]{6})$"
            static colorARGB := "^0x([0-9A-Fa-f]{8})$"
            static hex6      :=   "^([0-9A-Fa-f]{6})$"
            static hex8      :=   "^([0-9A-Fa-f]{8})$"

            if ObjGetCapacity([c], 1){
               c  := (c ~= "^#") ? SubStr(c, 2) : c
               c  := ((___ := this.colorMap[c]) != "") ? ___ : c
               c  := (c ~= colorRGB) ? "0xFF" RegExReplace(c, colorRGB, "$1") : (c ~= hex8) ? "0x" c : (c ~= hex6) ? "0xFF" c : c
               c  := (c ~= colorARGB) ? c : default
            }
            return (c != "") ? c : default
         }

         margin(m, default := 0){
            static percentage := "^(\-?\d+(?:\.\d*)?)%$"
            static positive := "^\d+(\.\d*)?$"

            if IsObject(m){
               m.1 := (m.y  != "") ? m.y  : m.top
               m.2 := (m.x2 != "") ? m.x2 : m.right
               m.3 := (m.y2 != "") ? m.y2 : m.bottom
               m.4 := (m.x  != "") ? m.x  : m.left
            }
            else if (m) {
               m   := StrSplit(m, " ")
               if (m.length() == 3)
                  m.4 := m.2
               else if (m.length() == 2)
                  m.4 := m.2, m.3 := m.1
               else if (m.length() == 1)
                  m.4 := m.3 := m.2 := m.1, exception := true
               else
                  m.Delete(5, m.MaxIndex())
            }
            else
               return {1:default, 2:default, 3:default, 4:default}

            m.1 := (m.1 ~= percentage) ? A_ScreenHeight * SubStr(m.1, 1, -1)  / 100 : m.1
            m.2 := (m.2 ~= percentage) ? (exception ? A_ScreenHeight : A_ScreenWidth) * SubStr(m.2, 1, -1)  / 100 : m.2
            m.3 := (m.3 ~= percentage) ? A_ScreenHeight * SubStr(m.3, 1, -1)  / 100 : m.3
            m.4 := (m.4 ~= percentage) ? (exception ? A_ScreenHeight : A_ScreenWidth) * SubStr(m.4, 1, -1)  / 100 : m.4

            m.1 := (m.1 ~= positive) ? m.1 : default
            m.2 := (m.2 ~= positive) ? m.2 : default
            m.3 := (m.3 ~= positive) ? m.3 : default
            m.4 := (m.4 ~= positive) ? m.4 : default

            return m
         }

         outline(o){
            static percentage := "^(\-?\d+(?:\.\d*)?)%$"
            static positive := "^\d+(\.\d*)?$"

            if IsObject(o){
               o.1 := (o.w  != "") ? o.w  : o.width
               o.2 := (o.c  != "") ? o.c  : o.color
               o.3 := (o.g  != "") ? o.g  : o.glow
               o.4 := (o.c2 != "") ? o.c2 : o.glowColor
            } else if (o)
               o   := StrSplit(o, " ")
            else
               return {"void":true, 1:0, 2:0, 3:0, 4:0}

            o.1 := (o.1 ~= "px$") ? SubStr(o.1, 1, -2) : o.1
            o.1 := (o.1 ~= percentage) ?  s * RegExReplace(o.1, percentage, "$1")  // 100 : o.1
            o.1 := (o.1 ~= positive) ? o.1 : 1

            o.2 := this.color(o.2, 0xFF000000)

            o.3 := (o.3 ~= "px$") ? SubStr(o.3, 1, -2) : o.3
            o.3 := (o.3 ~= percentage) ?  s * RegExReplace(o.3, percentage, "$1")  // 100 : o.3
            o.3 := (o.3 ~= positive) ? o.3 : 0

            o.4 := this.color(o.4, 0x00000000)
            return o
         }

         dropShadow(d){
            static decimal := "^(\-?\d+(\.\d*)?)$"
            static percentage := "^(\-?\d+(?:\.\d*)?)%$"
            static positive := "^\d+(\.\d*)?$"

            if IsObject(d){
               d.1 := (d.h != "") ? d.h : d.horizontal
               d.2 := (d.v != "") ? d.v : d.vertical
               d.3 := (d.b != "") ? d.b : d.blur
               d.4 := (d.c != "") ? d.c : d.color
               d.5 := (d.s != "") ? d.s : d.strength
            } else if (d)
               d   := StrSplit(d, " ")
            else
               return {"void":true, 1:0, 2:0, 3:0, 4:0, 5:0}

            d.1 := (d.1 ~= "px$") ? SubStr(d.1, 1, -2) : d.1
            d.1 := (d.1 ~= percentage) ? ReturnRC[3] * RegExReplace(d.1, percentage, "$1")  / 100 : d.1
            d.1 := (d.1 ~= decimal) ? d.1 : 0

            d.2 := (d.2 ~= "px$") ? SubStr(d.2, 1, -2) : d.2
            d.2 := (d.2 ~= percentage) ? ReturnRC[4] * RegExReplace(d.2, percentage, "$1")  / 100 : d.2
            d.2 := (d.2 ~= decimal) ? d.2 : 0

            d.3 := (d.3 ~= "px$") ? SubStr(d.3, 1, -2) : d.3
            d.3 := (d.3 ~= percentage) ? s * RegExReplace(d.3, percentage, "$1")  / 100 : d.3
            d.3 := (d.3 ~= positive) ? d.3 : 1

            d.4 := this.color(d.4, 0xFF000000)

            d.5 := (d.5 ~= percentage) ? s * RegExReplace(d.5, percentage, "$1")  / 100 : d.5
            d.5 := (d.5 ~= positive) ? d.5 : 1
            return d
         }

         colorMap(){
            color := [] ; 73 LINES MAX
            color["Clear"] := color["Off"] := color["None"] := color["Transparent"] := "0x00000000"

               color["AliceBlue"]             := "0xFFF0F8FF"
             , color["AntiqueWhite"]          := "0xFFFAEBD7"
             , color["Aqua"]                  := "0xFF00FFFF"
             , color["Aquamarine"]            := "0xFF7FFFD4"
             , color["Azure"]                 := "0xFFF0FFFF"
             , color["Beige"]                 := "0xFFF5F5DC"
             , color["Bisque"]                := "0xFFFFE4C4"
             , color["Black"]                 := "0xFF000000"
             , color["BlanchedAlmond"]        := "0xFFFFEBCD"
             , color["Blue"]                  := "0xFF0000FF"
             , color["BlueViolet"]            := "0xFF8A2BE2"
             , color["Brown"]                 := "0xFFA52A2A"
             , color["BurlyWood"]             := "0xFFDEB887"
             , color["CadetBlue"]             := "0xFF5F9EA0"
             , color["Chartreuse"]            := "0xFF7FFF00"
             , color["Chocolate"]             := "0xFFD2691E"
             , color["Coral"]                 := "0xFFFF7F50"
             , color["CornflowerBlue"]        := "0xFF6495ED"
             , color["Cornsilk"]              := "0xFFFFF8DC"
             , color["Crimson"]               := "0xFFDC143C"
             , color["Cyan"]                  := "0xFF00FFFF"
             , color["DarkBlue"]              := "0xFF00008B"
             , color["DarkCyan"]              := "0xFF008B8B"
             , color["DarkGoldenRod"]         := "0xFFB8860B"
             , color["DarkGray"]              := "0xFFA9A9A9"
             , color["DarkGrey"]              := "0xFFA9A9A9"
             , color["DarkGreen"]             := "0xFF006400"
             , color["DarkKhaki"]             := "0xFFBDB76B"
             , color["DarkMagenta"]           := "0xFF8B008B"
             , color["DarkOliveGreen"]        := "0xFF556B2F"
             , color["DarkOrange"]            := "0xFFFF8C00"
             , color["DarkOrchid"]            := "0xFF9932CC"
             , color["DarkRed"]               := "0xFF8B0000"
             , color["DarkSalmon"]            := "0xFFE9967A"
             , color["DarkSeaGreen"]          := "0xFF8FBC8F"
             , color["DarkSlateBlue"]         := "0xFF483D8B"
             , color["DarkSlateGray"]         := "0xFF2F4F4F"
             , color["DarkSlateGrey"]         := "0xFF2F4F4F"
             , color["DarkTurquoise"]         := "0xFF00CED1"
             , color["DarkViolet"]            := "0xFF9400D3"
             , color["DeepPink"]              := "0xFFFF1493"
             , color["DeepSkyBlue"]           := "0xFF00BFFF"
             , color["DimGray"]               := "0xFF696969"
             , color["DimGrey"]               := "0xFF696969"
             , color["DodgerBlue"]            := "0xFF1E90FF"
             , color["FireBrick"]             := "0xFFB22222"
             , color["FloralWhite"]           := "0xFFFFFAF0"
             , color["ForestGreen"]           := "0xFF228B22"
             , color["Fuchsia"]               := "0xFFFF00FF"
             , color["Gainsboro"]             := "0xFFDCDCDC"
             , color["GhostWhite"]            := "0xFFF8F8FF"
             , color["Gold"]                  := "0xFFFFD700"
             , color["GoldenRod"]             := "0xFFDAA520"
             , color["Gray"]                  := "0xFF808080"
             , color["Grey"]                  := "0xFF808080"
             , color["Green"]                 := "0xFF008000"
             , color["GreenYellow"]           := "0xFFADFF2F"
             , color["HoneyDew"]              := "0xFFF0FFF0"
             , color["HotPink"]               := "0xFFFF69B4"
             , color["IndianRed"]             := "0xFFCD5C5C"
             , color["Indigo"]                := "0xFF4B0082"
             , color["Ivory"]                 := "0xFFFFFFF0"
             , color["Khaki"]                 := "0xFFF0E68C"
             , color["Lavender"]              := "0xFFE6E6FA"
             , color["LavenderBlush"]         := "0xFFFFF0F5"
             , color["LawnGreen"]             := "0xFF7CFC00"
             , color["LemonChiffon"]          := "0xFFFFFACD"
             , color["LightBlue"]             := "0xFFADD8E6"
             , color["LightCoral"]            := "0xFFF08080"
             , color["LightCyan"]             := "0xFFE0FFFF"
             , color["LightGoldenRodYellow"]  := "0xFFFAFAD2"
             , color["LightGray"]             := "0xFFD3D3D3"
             , color["LightGrey"]             := "0xFFD3D3D3"
               color["LightGreen"]            := "0xFF90EE90"
             , color["LightPink"]             := "0xFFFFB6C1"
             , color["LightSalmon"]           := "0xFFFFA07A"
             , color["LightSeaGreen"]         := "0xFF20B2AA"
             , color["LightSkyBlue"]          := "0xFF87CEFA"
             , color["LightSlateGray"]        := "0xFF778899"
             , color["LightSlateGrey"]        := "0xFF778899"
             , color["LightSteelBlue"]        := "0xFFB0C4DE"
             , color["LightYellow"]           := "0xFFFFFFE0"
             , color["Lime"]                  := "0xFF00FF00"
             , color["LimeGreen"]             := "0xFF32CD32"
             , color["Linen"]                 := "0xFFFAF0E6"
             , color["Magenta"]               := "0xFFFF00FF"
             , color["Maroon"]                := "0xFF800000"
             , color["MediumAquaMarine"]      := "0xFF66CDAA"
             , color["MediumBlue"]            := "0xFF0000CD"
             , color["MediumOrchid"]          := "0xFFBA55D3"
             , color["MediumPurple"]          := "0xFF9370DB"
             , color["MediumSeaGreen"]        := "0xFF3CB371"
             , color["MediumSlateBlue"]       := "0xFF7B68EE"
             , color["MediumSpringGreen"]     := "0xFF00FA9A"
             , color["MediumTurquoise"]       := "0xFF48D1CC"
             , color["MediumVioletRed"]       := "0xFFC71585"
             , color["MidnightBlue"]          := "0xFF191970"
             , color["MintCream"]             := "0xFFF5FFFA"
             , color["MistyRose"]             := "0xFFFFE4E1"
             , color["Moccasin"]              := "0xFFFFE4B5"
             , color["NavajoWhite"]           := "0xFFFFDEAD"
             , color["Navy"]                  := "0xFF000080"
             , color["OldLace"]               := "0xFFFDF5E6"
             , color["Olive"]                 := "0xFF808000"
             , color["OliveDrab"]             := "0xFF6B8E23"
             , color["Orange"]                := "0xFFFFA500"
             , color["OrangeRed"]             := "0xFFFF4500"
             , color["Orchid"]                := "0xFFDA70D6"
             , color["PaleGoldenRod"]         := "0xFFEEE8AA"
             , color["PaleGreen"]             := "0xFF98FB98"
             , color["PaleTurquoise"]         := "0xFFAFEEEE"
             , color["PaleVioletRed"]         := "0xFFDB7093"
             , color["PapayaWhip"]            := "0xFFFFEFD5"
             , color["PeachPuff"]             := "0xFFFFDAB9"
             , color["Peru"]                  := "0xFFCD853F"
             , color["Pink"]                  := "0xFFFFC0CB"
             , color["Plum"]                  := "0xFFDDA0DD"
             , color["PowderBlue"]            := "0xFFB0E0E6"
             , color["Purple"]                := "0xFF800080"
             , color["RebeccaPurple"]         := "0xFF663399"
             , color["Red"]                   := "0xFFFF0000"
             , color["RosyBrown"]             := "0xFFBC8F8F"
             , color["RoyalBlue"]             := "0xFF4169E1"
             , color["SaddleBrown"]           := "0xFF8B4513"
             , color["Salmon"]                := "0xFFFA8072"
             , color["SandyBrown"]            := "0xFFF4A460"
             , color["SeaGreen"]              := "0xFF2E8B57"
             , color["SeaShell"]              := "0xFFFFF5EE"
             , color["Sienna"]                := "0xFFA0522D"
             , color["Silver"]                := "0xFFC0C0C0"
             , color["SkyBlue"]               := "0xFF87CEEB"
             , color["SlateBlue"]             := "0xFF6A5ACD"
             , color["SlateGray"]             := "0xFF708090"
             , color["SlateGrey"]             := "0xFF708090"
             , color["Snow"]                  := "0xFFFFFAFA"
             , color["SpringGreen"]           := "0xFF00FF7F"
             , color["SteelBlue"]             := "0xFF4682B4"
             , color["Tan"]                   := "0xFFD2B48C"
             , color["Teal"]                  := "0xFF008080"
             , color["Thistle"]               := "0xFFD8BFD8"
             , color["Tomato"]                := "0xFFFF6347"
             , color["Turquoise"]             := "0xFF40E0D0"
             , color["Violet"]                := "0xFFEE82EE"
             , color["Wheat"]                 := "0xFFF5DEB3"
             , color["White"]                 := "0xFFFFFFFF"
             , color["WhiteSmoke"]            := "0xFFF5F5F5"
               color["Yellow"]                := "0xFFFFFF00"
             , color["YellowGreen"]           := "0xFF9ACD32"
            return color
         }

         x1(){
            return this.x
         }

         y1(){
            return this.y
         }

         x2(){
            return this.xx
         }

         y2(){
            return this.yy
         }

         width(){
            return this.xx - this.x
         }

         height(){
            return this.yy - this.y
         }
      }
   }

   class provider {

      class GoogleCloudVision {

         static ext := "jpg"
         static jpegQuality := "75"

         base64 := true

         ; Cloud Platform Console Help - Setting up API keys
         ; Step 1: https://support.google.com/cloud/answer/6158862?hl=en
         ; Step 2: https://cloud.google.com/vision/docs/before-you-begin

         ; You must enter billing information to use the Cloud Vision API.
         ; https://cloud.google.com/vision/pricing
         ; First 1000 LABEL_DETECTION per month is free.

         ; Please enter your api_key for Google Cloud Vision API.
         static api_key := "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
         ; FOR SAFETY REASONS, DO NOT PASTE YOUR API KEY HERE.
         ; Instead, keep your api_key in a separate file, "Vis2_API.txt"

         getCredentials(error:=""){
            if (error != "") {
               (Vis2.obj) ? Vis2.core.ux.suspend() : ""
               InputBox, api_key, Vis2.GoogleCloudVision.ImageIdentify, Enter your api_key for GoogleCloudVision.
               (Vis2.obj) ? Vis2.core.ux.resume() : ""
               FileAppend, GoogleCloudVision=%api_key%, Vis2_API.txt
               return api_key
            }

            if (this.api_key ~= "^X{39}$") {
               if FileExist("Vis2_API.txt") {
                  file := FileOpen("Vis2_API.txt", "r")
                  keys := file.Read()
                  api_key := ((___ := RegExReplace(keys, "s)^.*?GoogleCloudVision(?:\s*)=(?:\s*)([A-Za-z0-9\-]+).*$", "$1")) != keys) ? ___ : ""
                  file.close()

                  if (api_key != "")
                     return api_key
               }
            }
            else
               return this.api_key
         }

         ; https://cloud.google.com/vision/docs/supported-files
         ; Supported Image Formats
         ; JPEG, PNG8, PNG24, GIF, Animated GIF (first frame only)
         ; BMP, WEBP, RAW, ICO
         ; Maximum Image Size - 4 MB
         ; Maximum Size per Request - 8 MB
         ; Compression to 640 x 480 - LABEL_DETECTION

         ImageIdentify(image, search:="", options:=""){
            base64 := Vis2.stdlib.toBase64(image, "png", this.jpegQuality, options)
            reply := this.convert(base64)
            return this.getText()
         }

         convert(in:=""){
            in := (in) ? in : this.base64
            req := {}
            req.requests := {}
            req.requests[1] := {"image":{}, "features":{}}
            req.requests[1].image.content := in
            req.requests[1].features[1] := {"type":"LABEL_DETECTION"}
            body := JSON.Dump(req)

            whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
            if (api_key := this.getCredentials())
               whr.Open("POST", "https://vision.googleapis.com/v1/images:annotate?key=" api_key, true)
            else
               whr.Open("POST", "https://cxl-services.appspot.com/proxy?url=https%3A%2F%2Fvision.googleapis.com%2Fv1%2Fimages%3Aannotate", true)
            whr.SetRequestHeader("Accept", "*/*")
            whr.SetRequestHeader("Origin", "https://cloud.google.com")
            whr.SetRequestHeader("Content-Type", "text/plain;charset=UTF-8")
            whr.SetRequestHeader("Referer", "https://cloud.google.com/vision/")
            whr.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36")

            whr.Send(body)
            whr.WaitForResponse()

            try reply := JSON.Load(whr.ResponseText)
            catch
               this.getCredentials(whr.ResponseText)
            i := 1
            while (i <= reply.responses[1].labelAnnotations.length()) {
               sentence  .= (i == 1) ? "" : ", "
               sentence2 .= (i == 1) ? "" : ", "
               sentence  .= reply.responses[1].labelAnnotations[i].description
               sentence2 .= reply.responses[1].labelAnnotations[i].description " (" Format("{:i}",  100*reply.responses[1].labelAnnotations[i].score) "%)"
               i++
            }

            this.text := sentence2
            return reply
         }

         getText(){
            return this.text
         }
      }

      class Tesseract {

         static leptonica := A_ScriptDir "\bin\leptonica_util\leptonica_util.exe"
         static tesseract := A_ScriptDir "\bin\tesseract\tesseract.exe"
         static tessdata_best := A_ScriptDir "\bin\tesseract\tessdata_best"
         static tessdata_fast := A_ScriptDir "\bin\tesseract\tessdata_fast"

         uuid := Vis2.stdlib.CreateUUID()
         file := A_Temp "\Vis2_screenshot" this.uuid ".bmp"
         fileProcessedImage := A_Temp "\Vis2_preprocess" this.uuid ".tif"
         fileConvertedText := A_Temp "\Vis2_text" this.uuid ".txt"

         ; public OCR()
         ; public preprocess()
         ; public convert()
         ; public cleanup()
         ; public getPreprocessImage()
         ; public getText()
         ; private convert_best()
         ; private convert_fast()
         ; private getTextLines()

         __New(language:=""){
            this.language := language
         }

         OCR(image, language:="", options:=""){
            this.language := language
            try {
               screenshot := Vis2.stdlib.toFile(image, this.file, options)
               this.preprocess(screenshot, this.fileProcessedImage)
               this.convert_best(this.fileProcessedImage, this.fileConvertedText)
               text := this.getText(this.fileConvertedText)
            } catch e {
               MsgBox, 16,, % "Exception thrown!`n`nwhat: " e.what "`nfile: " e.file
                  . "`nline: " e.line "`nmessage: " e.message "`nextra: " e.extra
            }
            finally {
               this.cleanup()
               text.base.google := ObjBindMethod(Vis2.Text, "google")
               text.base.clipboard := ObjBindMethod(Vis2.Text, "clipboard")
            }
            return text
         }

         cleanup(){
            FileDelete, % this.file
            FileDelete, % this.fileProcessedImage
            FileDelete, % this.fileConvertedText
         }

         convert(in:="", out:="", fast:=1){
            in := (in) ? in : this.fileProcessedImage
            out := (out) ? out : this.fileConvertedText
            fast := (fast) ? this.tessdata_fast : this.tessdata_best

            if !(FileExist(in))
               throw Exception("Input image for conversion not found.",, in)

            if !(FileExist(this.tesseract))
               throw Exception("Tesseract not found",, this.tesseract)

            static q := Chr(0x22)
            _cmd .= q this.tesseract q " --tessdata-dir " q fast q " " q in q " " q SubStr(out, 1, -4) q
            _cmd .= (this.language) ? " -l " q this.language q : ""
            _cmd := ComSpec " /C " q _cmd q
            RunWait % _cmd,, Hide

            if !(FileExist(out))
               throw Exception("Tesseract failed.",, _cmd)

            return out
         }

         convert_best(in:="", out:=""){
            return this.convert(in, out, 0)
         }

         convert_fast(in:="", out:=""){
            return this.convert(in, out, 1)
         }

         getPreprocessImage(){
            return this.fileProcessedImage
         }

         getText(in:="", lines:=""){
            in := (in) ? in : this.fileConvertedText

            if !(database := FileOpen(in, "r`n", "UTF-8"))
               throw Exception("Text file could not be found or opened.",, in)

            if (lines == "") {
               text := RegExReplace(database.Read(), "^\s*(.*?)\s*$", "$1")
               text := RegExReplace(text, "(?<!\r)\n", "`r`n")
            } else {
               while (lines > 0) {
                  data := database.ReadLine()
                  data := RegExReplace(data, "^\s*(.*?)\s*$", "$1")
                  if (data != "") {
                     text .= (text) ? ("`n" . data) : data
                     lines--
                  }
                  if (!database || database.AtEOF)
                     break
               }
            }
            database.Close()
            return text
         }

         getTextLines(lines){
            return this.read(, lines)
         }

         preprocess(in:="", out:=""){
            static ocrPreProcessing := 1
            static negateArg := 2
            static performScaleArg := 1
            static scaleFactor := 3.5

            in := (in != "") ? in : this.file
            out := (out != "") ? out : this.fileProcessedImage

            if !(FileExist(in))
               throw Exception("Input image for preprocessing not found.",, in)

            if !(FileExist(this.leptonica))
               throw Exception("Leptonica not found",, this.leptonica)

            static q := Chr(0x22)
            _cmd .= q this.leptonica q " " q in q " " q out q
            _cmd .= " " negateArg " 0.5 " performScaleArg " " scaleFactor " " ocrPreProcessing " 5 2.5 " ocrPreProcessing  " 2000 2000 0 0 0.0"
            _cmd := ComSpec " /C " q _cmd q
            RunWait, % _cmd,, Hide

            if !(FileExist(out))
               throw Exception("Preprocessing failed.",, _cmd)

            return out
         }
      }
   }

   class stdlib {

      isBinaryImageFormat(data){
         Loop 12
            bytes .= Chr(NumGet(data, A_Index-1, "uchar"))

         ; Null bytes are not passed, so they have been omitted below

         if (bytes ~= "^BM")
            return "bmp"
         if (bytes ~= "^(GIF87a|GIF89a)")
            return "gif"
         if (bytes ~= "^ÿØÿÛ")
            return "jpg"
         if (bytes ~= "s)^ÿØÿà..\x4A\x46\x49\x46") ;\x00\x01
            return "jfif"
         if (bytes ~= "^\x89\x50\x4E\x47\x0D\x0A\x1A\x0A")
            return "png"
         if (bytes ~= "^(\x49\x49\x2A|\x4D\x4D\x2A)") ; 49 49 2A 00, 4D 4D 00 2A
            return "tif"
         return
      }

      isURL(url){
         regex .= "((https?|ftp)\:\/\/)" ; SCHEME
         regex .= "([a-z0-9+!*(),;?&=\$_.-]+(\:[a-z0-9+!*(),;?&=\$_.-]+)?@)?" ; User and Pass
         regex .= "([a-z0-9-.]*)\.([a-z]{2,3})" ; Host or IP
         regex .= "(\:[0-9]{2,5})?" ; Port
         regex .= "(\/([a-z0-9+\$_-]\.?)+)*\/?" ; Path
         regex .= "(\?[a-z+&\$_.-][a-z0-9;:@&%=+\/\$_.-]*)?" ; GET Query
         regex .= "(#[a-z_.-][a-z0-9+\$_.-]*)?" ; Anchor

         return (url ~= "i)" regex) ? true : false
      }

      b64Encode( ByRef buf, bufLen:="" ) {
         bufLen := (bufLen) ? bufLen : StrLen(buf) << !!A_IsUnicode
         DllCall( "crypt32\CryptBinaryToStringA", "ptr", &buf, "UInt", bufLen, "Uint", 1 | 0x40000000, "Ptr", 0, "UInt*", outLen )
         VarSetCapacity( outBuf, outLen, 0 )
         DllCall( "crypt32\CryptBinaryToStringA", "ptr", &buf, "UInt", bufLen, "Uint", 1 | 0x40000000, "Ptr", &outBuf, "UInt*", outLen )
         return strget( &outBuf, outLen, "CP0" )
      }

      b64Decode( b64str, ByRef outBuf ) {
         static CryptStringToBinary := "crypt32\CryptStringToBinary" (A_IsUnicode ? "W" : "A")

         DllCall( CryptStringToBinary, "ptr", &b64str, "UInt", 0, "Uint", 1, "Ptr", 0, "UInt*", outLen, "ptr", 0, "ptr", 0 )
         VarSetCapacity( outBuf, outLen, 0 )
         DllCall( CryptStringToBinary, "ptr", &b64str, "UInt", 0, "Uint", 1, "Ptr", &outBuf, "UInt*", outLen, "ptr", 0, "ptr", 0 )

         return outLen
      }

      CreateUUID() {
         VarSetCapacity(puuid, 16, 0)
         if !(DllCall("rpcrt4.dll\UuidCreate", "ptr", &puuid))
            if !(DllCall("rpcrt4.dll\UuidToString", "ptr", &puuid, "uint*", suuid))
               return StrGet(suuid), DllCall("rpcrt4.dll\RpcStringFree", "uint*", suuid)
         return ""
      }

      Gdip_EncodeBitmapTo64string(pBitmap, ext, Quality=75) {

         if Ext not in BMP,DIB,RLE,JPG,JPEG,JPE,JFIF,GIF,TIF,TIFF,PNG
               return -1
         Extension := "." Ext

         DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", nCount, "uint*", nSize)
         VarSetCapacity(ci, nSize)
         DllCall("gdiplus\GdipGetImageEncoders", "uint", nCount, "uint", nSize, Ptr, &ci)
         if !(nCount && nSize)
            return -2



            Loop, %nCount%
            {
                  sString := StrGet(NumGet(ci, (idx := (48+7*A_PtrSize)*(A_Index-1))+32+3*A_PtrSize), "UTF-16")
                  if !InStr(sString, "*" Extension)
                     continue

                  pCodec := &ci+idx
                  break
            }


         if !pCodec
               return -3

         if (Quality != 75)
         {
               Quality := (Quality < 0) ? 0 : (Quality > 100) ? 100 : Quality
               if Extension in .JPG,.JPEG,.JPE,.JFIF
               {
                     DllCall("gdiplus\GdipGetEncoderParameterListSize", Ptr, pBitmap, Ptr, pCodec, "uint*", nSize)
                     VarSetCapacity(EncoderParameters, nSize, 0)
                     DllCall("gdiplus\GdipGetEncoderParameterList", Ptr, pBitmap, Ptr, pCodec, "uint", nSize, Ptr, &EncoderParameters)
                     Loop, % NumGet(EncoderParameters, "UInt")
                     {
                        elem := (24+(A_PtrSize ? A_PtrSize : 4))*(A_Index-1) + 4 + (pad := A_PtrSize = 8 ? 4 : 0)
                        if (NumGet(EncoderParameters, elem+16, "UInt") = 1) && (NumGet(EncoderParameters, elem+20, "UInt") = 6)
                        {
                              p := elem+&EncoderParameters-pad-4
                              NumPut(Quality, NumGet(NumPut(4, NumPut(1, p+0)+20, "UInt")), "UInt")
                              break
                        }
                     }
               }
         }

         DllCall("ole32\CreateStreamOnHGlobal", "ptr",0, "int",true, "ptr*",pStream)
         DllCall("gdiplus\GdipSaveImageToStream", "ptr",pBitmap, "ptr",pStream, "ptr",pCodec, "uint",p ? p : 0)

         DllCall("ole32\GetHGlobalFromStream", "ptr",pStream, "uint*",hData)
         pData := DllCall("GlobalLock", "ptr",hData, "uptr")
         nSize := DllCall("GlobalSize", "uint",pData)

         VarSetCapacity(Bin, nSize, 0)
         DllCall("RtlMoveMemory", "ptr",&Bin , "ptr",pData , "uint",nSize)
         DllCall("GlobalUnlock", "ptr",hData)
         DllCall(NumGet(NumGet(pStream + 0, 0, "uptr") + (A_PtrSize * 2), 0, "uptr"), "ptr",pStream)
         DllCall("GlobalFree", "ptr",hData)
         
         DllCall("Crypt32.dll\CryptBinaryToString", "ptr",&Bin, "uint",nSize, "uint",0x01, "ptr",0, "uint*",base64Length)
         VarSetCapacity(base64, base64Length*2, 0)
         DllCall("Crypt32.dll\CryptBinaryToString", "ptr",&Bin, "uint",nSize, "uint",0x01, "ptr",&base64, "uint*",base64Length)
         Bin := ""
         VarSetCapacity(Bin, 0)
         VarSetCapacity(base64, -1)

         return base64
      }

      Gdip_BitmapFromClientHWND(hwnd) {
         VarSetCapacity(rc, 16)
         DllCall("GetClientRect", "ptr", hwnd, "ptr", &rc)
      	hbm := CreateDIBSection(NumGet(rc, 8, "int"), NumGet(rc, 12, "int"))
         VarSetCapacity(rc, 0)
         hdc := CreateCompatibleDC()
         obm := SelectObject(hdc, hbm)
      	PrintWindow(hwnd, hdc, 1)
      	pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
      	SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
      	return pBitmap
      }

      Gdip_CropBitmap(ByRef pBitmap, c, preserveOriginal:=false){
         w := Gdip_GetImageWidth(pBitmap), h := Gdip_GetImageHeight(pBitmap)
         pBitmap2 := Gdip_CloneBitmapArea(pBitmap, c.1, c.2, (c.1 + c.3 > w) ? w - c.1 : c.3 , (c.2 + c.4 > h) ? h - c.2 : c.4)
         (preserveOriginal) ? "" : Gdip_DisposeImage(pBitmap)
         pBitmap := pBitmap2
      }

      Gdip_isBitmapEqual(pBitmap1, pBitmap2, width:="", height:="") {
         ; Check if pointers are identical.
         if (pBitmap1 == pBitmap2)
            return true

         ; Assume both Bitmaps are equal in width and height.
         width := (width) ? width : Gdip_GetImageWidth(pBitmap1)
         height := (height) ? height : Gdip_GetImageHeight(pBitmap1)
         E1 := Gdip_LockBits(pBitmap1, 0, 0, width, height, Stride1, Scan01, BitmapData1)
         E2 := Gdip_LockBits(pBitmap2, 0, 0, width, height, Stride2, Scan02, BitmapData2)

         ; RtlCompareMemory preforms an unsafe comparison stopping at the first different byte.
         length := width * height * 4  ; ARGB = 4 bytes
         bytes := DllCall("RtlCompareMemory", "ptr", Scan01+0, "ptr", Scan02+0, "uint", length)

         Gdip_UnlockBits(pBitmap1, BitmapData1)
         Gdip_UnlockBits(pBitmap2, BitmapData2)
         return (bytes == length) ? true : false
      }

      RPath_Absolute(AbsolutPath, RelativePath, s="\") {

         len := InStr(AbsolutPath, s, "", InStr(AbsolutPath, s . s) + 2) - 1   ;get server or drive string length
         pr := SubStr(AbsolutPath, 1, len)                                     ;get server or drive name
         AbsolutPath := SubStr(AbsolutPath, len + 1)                           ;remove server or drive from AbsolutPath
         If InStr(AbsolutPath, s, "", 0) = StrLen(AbsolutPath)                 ;remove last \ from AbsolutPath if any
            StringTrimRight, AbsolutPath, AbsolutPath, 1

         If InStr(RelativePath, s) = 1                                         ;when first char is \ go to AbsolutPath of server or drive
            AbsolutPath := "", RelativePath := SubStr(RelativePath, 2)        ;set AbsolutPath to nothing and remove one char from RelativePath
         Else If InStr(RelativePath,"." s) = 1                                 ;when first two chars are .\ add to current AbsolutPath directory
            RelativePath := SubStr(RelativePath, 3)                           ;remove two chars from RelativePath
         Else If InStr(RelativePath,".." s) = 1 {                              ;otherwise when first 3 char are ..\
            StringReplace, RelativePath, RelativePath, ..%s%, , UseErrorLevel     ;remove all ..\ from RelativePath
            Loop, %ErrorLevel%                                                    ;for all ..\
               AbsolutPath := SubStr(AbsolutPath, 1, InStr(AbsolutPath, s, "", 0) - 1)  ;remove one folder from AbsolutPath
         } Else                                                                ;relative path does not need any substitution
            pr := "", AbsolutPath := "", s := ""                              ;clear all variables to just return RelativePath

         Return, pr . AbsolutPath . s . RelativePath                           ;concatenate server + AbsolutPath + separator + RelativePath
      }

      setSystemCursor(CursorID = "", cx = 0, cy = 0 ) { ; Thanks to Serenity - https://autohotkey.com/board/topic/32608-changing-the-system-cursor/
         static SystemCursors := "32512,32513,32514,32515,32516,32640,32641,32642,32643,32644,32645,32646,32648,32649,32650,32651"

         Loop, Parse, SystemCursors, `,
         {
               Type := "SystemCursor"
               CursorHandle := DllCall( "LoadCursor", "uInt",0, "Int",CursorID )
               %Type%%A_Index% := DllCall( "CopyImage", "uInt",CursorHandle, "uInt",0x2, "Int",cx, "Int",cy, "uInt",0 )
               CursorHandle := DllCall( "CopyImage", "uInt",%Type%%A_Index%, "uInt",0x2, "Int",0, "Int",0, "Int",0 )
               DllCall( "SetSystemCursor", "uInt",CursorHandle, "Int",A_Loopfield)
         }
      }

      ; toBase64() - Converts the input to a Base 64 string.
      ; Types of input accepted
      ; Objects: Rectangle Array (Screenshot)
      ; Strings: File, URL, Window Title (ahk_class...) OR hwnd (hex)
      ; Numbers: GDI Bitmap, GDI HBitmap
      ; Rawfile: Binary, base64
      toBase64(image, extension:="png", quality:="", crop:="", crop2:=""){
         Vis2.Graphics.Startup()

         ; Check if image is an array of 4 numbers
         if (image.1 ~= "^\d+$" && image.2 ~= "^\d+$" && image.3 ~= "^\d+$" && image.4 ~= "^\d+$") {
            pBitmap := Gdip_BitmapFromScreen(image.1 "|" image.2 "|" image.3 "|" image.4)
            base64 := Vis2.stdlib.Gdip_EncodeBitmapTo64string(pBitmap, extension, quality)
            Gdip_DisposeImage(pBitmap)
         }
         ; Check if image points to a valid file
         else if FileExist(image) {
            if !(crop) {
               file := FileOpen(image, "r")
               file.RawRead(data, file.length)
               base64 := Vis2.stdlib.b64Encode(data, file.length)
               file.Close()
            } else {
               pBitmap := Gdip_CreateBitmapFromFile(image)
               (crop) ? Vis2.stdlib.Gdip_CropBitmap(pBitmap, crop) : ""
               base64 := Vis2.stdlib.Gdip_EncodeBitmapTo64string(pBitmap, extension, quality)
               Gdip_DisposeImage(pBitmap)
            }
         }
         ; Check if image points to a valid URL
         else if Vis2.stdlib.isURL(image) {
            static req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
            req.Open("GET",image)
            req.Send()

            pStream := ComObjQuery(req.ResponseStream, "{0000000C-0000-0000-C000-000000000046}")
            if !(crop) {
               DllCall("ole32\GetHGlobalFromStream", "ptr",pStream, "uint*",hData)
               pData := DllCall("GlobalLock", "ptr",hData, "uptr")
               nSize := DllCall("GlobalSize", "uint",pData)

               VarSetCapacity(Bin, nSize, 0)
               DllCall("RtlMoveMemory", "ptr",&Bin , "ptr",pData , "uint",nSize)
               DllCall("GlobalUnlock", "ptr",hData)
               DllCall(NumGet(NumGet(pStream + 0, 0, "uptr") + (A_PtrSize * 2), 0, "uptr"), "ptr",pStream)
               DllCall("GlobalFree", "ptr",hData)

               DllCall("Crypt32.dll\CryptBinaryToString", "ptr",&Bin, "uint",nSize, "uint",0x01, "ptr",0, "uint*",base64Length)
               VarSetCapacity(base64, base64Length*2, 0)
               DllCall("Crypt32.dll\CryptBinaryToString", "ptr",&Bin, "uint",nSize, "uint",0x01, "ptr",&base64, "uint*",base64Length)
               Bin := ""
               VarSetCapacity(Bin, 0)
               VarSetCapacity(base64, -1)
            } else {
               DllCall("gdiplus\GdipCreateBitmapFromStream", "ptr",pStream, "uptr*",pBitmap)
               ObjRelease(pStream)
               (crop) ? Vis2.stdlib.Gdip_CropBitmap(pBitmap, crop) : ""
               base64 := Vis2.stdlib.Gdip_EncodeBitmapTo64string(pBitmap, extension, quality)
               Gdip_DisposeImage(pBitmap)
            }
         }
         ; Check if image matches a window title OR is a valid handle to a window
         else if (DllCall("IsWindow", "ptr",image) || (hwnd := WinExist(image))) {
            hwnd := (DllCall("IsWindow", "ptr",image)) ? image : hwnd
            pBitmap := Vis2.stdlib.Gdip_BitmapFromClientHWND(hwnd)
            (crop) ? Vis2.stdlib.Gdip_CropBitmap(pBitmap, crop) : ""
            base64 := Vis2.stdlib.Gdip_EncodeBitmapTo64string(pBitmap, extension, quality)
            Gdip_DisposeImage(pBitmap)
         }
         ; Check if image is a valid GDI Bitmap
         else if DeleteObject(Gdip_CreateHBITMAPFromBitmap(image)) {
            (crop) ? Vis2.stdlib.Gdip_CropBitmap(image, crop, true) : ""
            base64 := Vis2.stdlib.Gdip_EncodeBitmapTo64string(image, extension, quality)
            (crop) ? Gdip_DisposeImage(image) : ""
         }
         ; Check if image is a valid handle to a GDI Bitmap
         else if (DllCall("GetObjectType", "ptr",image) == 7) {
            pBitmap := Gdip_CreateBitmapFromHBITMAP(image)
            (crop) ? Vis2.stdlib.Gdip_CropBitmap(pBitmap, crop) : ""
            base64 := Vis2.stdlib.Gdip_EncodeBitmapTo64string(pBitmap, extension, quality)
            Gdip_DisposeImage(pBitmap)
         }
         ; Check if image is a base64 string
         else if (image ~= "^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{4}|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)$") {
            base64 := image
         }
         Vis2.Graphics.Shutdown()
         return base64
      }

      ; toFile() - Saves the image as a temporary file.
      toFile(image, outputFile:="", crop:=""){
         Vis2.Graphics.Startup()
         ; Check if image is an array of 4 numbers
         if (image.1 ~= "^\d+$" && image.2 ~= "^\d+$" && image.3 ~= "^\d+$" && image.4 ~= "^\d+$") {
            pBitmap := Gdip_BitmapFromScreen(image.1 "|" image.2 "|" image.3 "|" image.4)
            Gdip_SaveBitmapToFile(pBitmap, outputFile)
            Gdip_DisposeImage(pBitmap)
         }
         ; Check if image points to a valid file
         else if FileExist(image) {
            Loop, Files, % image
            {
               if (A_LoopFileExt != "bmp" || IsObject(crop)) {
                  pBitmap := Gdip_CreateBitmapFromFile(A_LoopFileLongPath)
                  (crop) ? Vis2.stdlib.Gdip_CropBitmap(pBitmap, crop) : ""
                  Gdip_SaveBitmapToFile(pBitmap, outputFile)
                  Gdip_DisposeImage(pBitmap)
               }
               else outputFile := A_LoopFileLongPath
            }
         }
         ; Check if image points to a valid URL
         else if Vis2.stdlib.isURL(image) {
            static req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
            req.Open("GET",image)
            req.Send()

            pStream := ComObjQuery(req.ResponseStream, "{0000000C-0000-0000-C000-000000000046}")
            DllCall("gdiplus\GdipCreateBitmapFromStream", "ptr",pStream, "uptr*",pBitmap)
            (crop) ? Vis2.stdlib.Gdip_CropBitmap(pBitmap, crop) : ""
            Gdip_SaveBitmapToFile(pBitmap, outputFile, 92)
            ObjRelease(pStream)
            Gdip_DisposeImage(pBitmap)
         }
         ; Check if image matches a window title OR is a valid handle to a window
         else if (DllCall("IsWindow", "ptr",image) || (hwnd := WinExist(image))) {
            hwnd := (DllCall("IsWindow", "ptr",image)) ? image : hwnd
            pBitmap := Vis2.stdlib.Gdip_BitmapFromClientHWND(hwnd)
            (crop) ? Vis2.stdlib.Gdip_CropBitmap(pBitmap, crop) : ""
            Gdip_SaveBitmapToFile(pBitmap, outputFile)
            Gdip_DisposeImage(pBitmap)
         }
         ; Check if image is a valid GDI Bitmap
         else if DeleteObject(Gdip_CreateHBITMAPFromBitmap(image)) {
            (crop) ? Vis2.stdlib.Gdip_CropBitmap(image, crop, true) : ""
            Gdip_SaveBitmapToFile(image, outputFile)
         }
         ; Check if image is a valid handle to a GDI Bitmap
         else if (DllCall("GetObjectType", "ptr",image) == 7) {
            pBitmap := Gdip_CreateBitmapFromHBITMAP(image)
            (crop) ? Vis2.stdlib.Gdip_CropBitmap(pBitmap, crop) : ""
            Gdip_SaveBitmapToFile(pBitmap, outputFile)
            Gdip_DisposeImage(pBitmap)
         }
         ; Check if image is a base64 string
         else if (image ~= "^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{4}|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)$") {
            nSize := Vis2.stdlib.b64Decode(image, bin)
            hData := DllCall("GlobalAlloc", "uint",0x2, "ptr",nSize)
            pData := DllCall("GlobalLock", "ptr",hData)
            DllCall("RtlMoveMemory", "ptr",pData, "ptr",&bin, "ptr",nSize)
            DllCall("GlobalUnlock", "ptr",hData)
            DllCall("ole32\CreateStreamOnHGlobal", "ptr",hData, "int",1, "uptr*",pStream)
            DllCall("gdiplus\GdipCreateBitmapFromStream", "ptr",pStream, "uptr*",pBitmap)
            (crop) ? Vis2.stdlib.Gdip_CropBitmap(pBitmap, crop) : ""
            Gdip_SaveBitmapToFile(pBitmap, outputFile, 92)
            DllCall(NumGet(NumGet(pStream + 0, 0, "uptr") + (A_PtrSize * 2), 0, "uptr"), "ptr",pStream)
            DllCall("GlobalFree", "ptr",hData)
            ObjRelease(pStream)
            Gdip_DisposeImage(pBitmap)
         }

         if !(FileExist(outputFile))
            throw Exception("Could not find source image.")

         Vis2.Graphics.Shutdown()
         return outputFile
      }
   }

   class Text {

      copy() {
         AutoTrim Off
         c := ClipboardAll
         Clipboard := ""             ; Must start off blank for detection to work.
         Send, ^c
         ClipWait 0.5
         if ErrorLevel
            return
         t := Clipboard
         Clipboard := c
         VarSetCapacity(c, 0)
         return t
      }

      paste(t) {
         c := ClipboardAll
         Clipboard := t
         Send, ^v
         Sleep 50                    ; Don't change clipboard while it is pasted! (Sleep > 0)
         Clipboard := c
         VarSetCapacity(c, 0)        ; Free memory
         AutoTrim On
      }

      restore() {
         AutoTrim On
      }

      ; Based on this paper: http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.81.8901
      rmgarbage(data := ""){
         ; If the input value is blank, send ^c to capture highlighted text.
         text := (data == "") ? Vis2.Text.copy() : data

         ; Split our text into strings, creating an array of words.
         strings := [], whitespaces := [], pos := 1
         while RegexMatch(text, "O)([^\s]+)", string, pos) {
            strings.push(string.value())
            pos := string.pos() + string.len()
            RegexMatch(text, "O)([\s]+)", whitespace, pos)
            whitespaces.push(whitespace.value)
         }

         for i in strings {
            ; (L) If a string is longer than 40 characters...
            ;strings[i] := RegExReplace(strings[i], "[^\s]{40,}", "")
            ; (A) If a string’s ratio of alphanumeric characters to total characters is less than 50%...
            alnum_thresholds := {1: 0     ; single chars can be non-alphanumeric
                    ,2: 0     ; so can doublets
                    ,3: 0.32  ; at least one of three should be alnum
                    ,4: 0.24  ; at least one of four should be alnum
                    ,5: 0.39}  ; at least two of five should be alnum
            strings[i] := (StrLen(RegExReplace(strings[i], "\W")) / StrLen(strings[i]) < 0.5) ? "" : strings[i]
            ; (R) If a string has 4 identical characters in a row...
            ;strings[i] := (strings[i] ~= "([^\s])\1\1\1") ? "" : strings[i]
            ; (V) If a string has nothing but alphabetic characters, look at the number of consonants and vowels.
            ;     If the number of one is less than 10% of the number of the other...
            ;     This includes a length threshold.

            /*
            def bad_consonant_vowel_ratio(self, string):
             """
             Rule V
             ======
             if a string has nothing but alphabetic characters, look at the
             number of consonants and vowels. If the number of one is less than 10%
             of the number of the other, then the string is garbage.
             This includes a length threshold.
             :param string: string to be tested
             :returns: either True or False
             """
             alpha_string = filter(str.isalpha, string)
             vowel_count = sum(1 for char in alpha_string if char in 'aeiouAEIOU')
             consonant_count = len(alpha_string) - vowel_count

             if (consonant_count > 0 and vowel_count > 0):
                 ratio = float(vowel_count)/consonant_count
                 if (ratio < 0.1 or ratio > 10):
                     return True
             elif (vowel_count == 0 and consonant_count > len('rhythms')):
                 return True
             elif (consonant_count == 0 and vowel_count > len('IEEE')):
                 return True

             return False
             */
            ;strings[i] := (strings[i] ~= "^(\w(?<=\D))+$") ? () : strings[i]
            ; (P) Strip off the first and last characters of a string. If there are two distinct
            ;     punctuation characters in the result...

            ; (C) If a string begins and ends with a lowercase letter, then if the string
            ;     contains an uppercase letter anywhere in between...
         }

         ; Reassemble the text
         text := ""
         for i, string in strings {
            text .= string . whitespaces[i]
         }

         return (data == "") ? Vis2.Text.paste(text) : text
      }

      clipboard(data := ""){
         text := (data == "") ? Vis2.Text.copy() : data
         clipboard := text
         return (data == "") ? Vis2.Text.restore() : text
      }

      google(data := "") {
         text := data
         if not RegExMatch(text, "^(http|ftp|telnet)")
            text := "https://www.google.com/search?&q=" . RegExReplace(text, "\s", "+")
         if (data)
            Run % text
         return data
      }
   }
}
