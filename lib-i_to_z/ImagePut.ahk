; Script:    ImagePut.ahk
; Author:    iseahound
; License:   MIT License
; Version:   2020-05-22
; Release:   2020-05-26

; ImagePut - Puts an image from anywhere to anywhere.
; This is a simple functor designed to be intuitive.
; I hope people find this reference library useful.


; Puts the image into a file format and returns a base64 encoded string.
;   extension  -  File Encoding           |  string   ->   bmp, gif, jpg, png, tiff
;   quality    -  JPEG Quality Level      |  integer  ->   0 - 100
ImagePutBase64(ByRef image, extension := "", quality := "") {
   return ImagePut("base64", image,,, extension, quality)
}

; Puts the image into a GDI+ Bitmap and returns a pointer.
ImagePutBitmap(ByRef image) {
   return ImagePut("bitmap", image)
}

; Puts the image into a GDI+ Bitmap and returns a buffer object with GDI+ scope.
ImagePutBuffer(ByRef image) {
   return ImagePut("buffer", image)
}

; Puts the image onto the clipboard and returns an empty string.
ImagePutClipboard(ByRef image) {
   return ImagePut("clipboard", image)
}

; Puts the image as the cursor and returns the string "A_Cursor".
;   xHotspot   -  X Click Point           |  pixel    ->   0 - width
;   yHotspot   -  Y Click Point           |  pixel    ->   0 - height
ImagePutCursor(ByRef image, xHotspot := "", yHotspot := "") {
   return ImagePut("cursor", image,,, xHotspot, yHotspot)
}

; Puts the image behind the desktop icons and returns the string "desktop".
;   scale      -  Scale Factor            |  real     ->   A_ScreenHeight / height.
ImagePutDesktop(ByRef image, scale := 1) {
   return ImagePut("desktop", image,, scale)
}

; Puts the image into a file and returns the file name. 
;   filename   -  File Extension          |  string   ->   *.bmp, *.gif, *.jpg, *.png, *.tiff
;   quality    -  JPEG Quality Level      |  integer  ->   0 - 100
ImagePutFile(ByRef image, filename := "", quality := "") {
   return ImagePut("file", image,,, filename, quality)
}

; Puts the image into a device independent bitmap and returns a handle.
;   quality    -  JPEG Quality Level      |  integer  ->   0 - 100
;   alpha      -  Alpha Replacement Color |  RGB      ->   0xFFFFFF
ImagePutHBitmap(ByRef image, alpha := "") {
   return ImagePut("hBitmap", image,,, alpha)
}

; Puts the image on the shared screen device context and returns an array of coordinates.
;   screenshot -  Screen Coordinates      |  array    ->   [x,y,w,h] or [0,0]
;   alpha      -  Alpha Replacement Color |  RGB      ->   0xFFFFFF
ImagePutScreenshot(ByRef image, screenshot := "", alpha := "") {
   return ImagePut("screenshot", image,,, screenshot, alpha)
}

; Puts the image as the desktop wallpaper and returns the string "wallpaper".
ImagePutWallpaper(ByRef image) {
   return ImagePut("wallpaper", image)
}


; ImagePut() - Puts an image from anywhere to anywhere.
;   cotype     -  Output Type             |  string   ->   Case Insensitive. Read documentation.
;   image      -  Input Image             |  image    ->   Anything. Refer to ImageType().
;   crop       -  Crop Coordinates        |  array    ->   [x,y,w,h] could be negative or percent.
;   scale      -  Scale Factor            |  real     ->   2.0
;   terms*     -  Additional Parameters   |  variadic ->   Extra parameters found in toCotype(). 
ImagePut(cotype, ByRef image, crop := "", scale := "", terms*) {
   return ImagePut.call(cotype, image, crop, scale, terms*)
}

class ImagePut {

   call(cotype, ByRef image, crop := "", scale := "", terms*) {

      this.gdiplusStartup()

      ; Take a guess as to what the image might be. (>90% accuracy!)
      try type := this.DontVerifyImageType(image)
      catch
         type := this.ImageType(image)

      ; Qualify additional parameters for correctness.
      _crop := crop.1 ~= "^-?\d+(\.\d*)?%?$" && crop.2 ~= "^-?\d+(\.\d*)?%?$"
            && crop.3 ~= "^-?\d+(\.\d*)?%?$" && crop.4 ~= "^-?\d+(\.\d*)?%?$"
      _scale := scale != 1 && scale ~= "^\d+(\.\d+)?$"

      ; Make a copy of the image as a pBitmap.
      pBitmap := this.toBitmap(type, image)

      ; Crop the image.
      if (_crop) {
         pBitmap2 := this.BitmapCrop(pBitmap, crop)
         DllCall("gdiplus\GdipDisposeImage", "ptr", pBitmap)
         pBitmap := pBitmap2
      }

      ; Scale the image.
      if (_scale) {
         pBitmap2 := this.BitmapScale(pBitmap, scale)
         DllCall("gdiplus\GdipDisposeImage", "ptr", pBitmap)
         pBitmap := pBitmap2
      }

      ; Put the pBitmap to wherever the cotype specifies.
      coimage := this.toCotype(cotype, pBitmap, terms*)

      ; Clean up the pBitmap copy. Export raw pointers if requested.
      if !(cotype = "bitmap" || cotype = "buffer")
         DllCall("gdiplus\GdipDisposeImage", "ptr", pBitmap)

      this.gdiplusShutdown(cotype)

      return coimage
   }

   ; Types       | Example         | Explicit    | Inferred  | Input    | Output   |
   ;             |                 | Don'tVerify | ImageType | toBitmap | toCotype |
   ; clipboard   | ClipboardAll    |     yes     |    yes    |    yes   |    yes   | - no transparency
   ; object      | object.Bitmap() |     yes     |    yes    |    yes   |          |
   ; buffer      | bitmap.pBitmap  |     yes     |    yes    |    yes   |    yes   |
   ; screenshot  | [x,y,w,h]       |     yes     |    yes    |    yes   |          |
   ; desktop     | "desktop"       |     yes     |    yes    |    no    |    yes   |
   ; wallpaper   | "wallpaper"     |     yes     |    yes    |    yes   |    yes   |
   ; cursor      | A_Cursor        |     yes     |    yes    |    yes   |    yes   |
   ; url         | https://        |     yes     |    yes    |    yes   |          |
   ; file        | picture.bmp     |     yes     |    yes    |    yes   |    yes   |
   ; bitmap      | some number     |     yes     |    yes    |    yes   |    yes   |
   ; hBitmap     | some number     |     yes     |    yes    |    yes   |    yes   |
   ; monitor     | 0 or # < 10     |     yes     |    yes    |          |          |
   ; hwnd        | 0x              |     yes     |    yes    |    yes   |          |
   ; window      | A               |     yes     |    yes    |    yes   |          |
   ; base64      | base64 data     |     yes     |    yes    |    yes   |    yes   |
   ; sprite      | file or url     |     yes     |    no     |    yes   |    no    |
   ; icon        |                 |             |           |          |          |
   ; printer     |                 |             |           |          |          |
   ; findtext    |                 |             |           |          |          |
   ; thumbnail   |                 |       ?     |           |          |          | DwmRegisterThumbnail
   ; video       |                 |             |           |          |          |
   ; formdata    |                 |             |           |          |          |
   ; stream      |                 |             |           |          |          |
   ; randomaccessstream | pointer  |             |           |          |          |


   DontVerifyImageType(ByRef image) {

      if !IsObject(image)
         throw Exception("Must be an object.")

      ; Check for image type declarations.
      ; Assumes that the user is telling the truth.

      if ObjHasKey(image, "clipboard") {
         image := image.clipboard
         return "clipboard"
      }

      if ObjHasKey(image, "object") {
         image := image.object
         return "object"
      }

      if ObjHasKey(image, "buffer") {
         image := image.buffer
         return "buffer"
      }

      if ObjHasKey(image, "screenshot") {
         image := image.screenshot
         return "screenshot"
      }

      if ObjHasKey(image, "desktop") {
         image := image.desktop
         return "desktop"
      }

      if ObjHasKey(image, "wallpaper") {
         image := image.wallpaper
         return "wallpaper"
      }

      if ObjHasKey(image, "cursor") {
         image := image.cursor
         return "cursor"
      }

      if ObjHasKey(image, "url") {
         image := image.url
         return "url"
      }

      if ObjHasKey(image, "file") {
         image := image.file
         return "file"
      }

      if ObjHasKey(image, "bitmap") {
         image := image.bitmap
         return "bitmap"
      }

      if ObjHasKey(image, "hBitmap") {
         image := image.hBitmap
         return "hBitmap"
      }

      if ObjHasKey(image, "monitor") {
         image := image.monitor
         return "monitor"
      }

      if ObjHasKey(image, "hwnd") {
         image := image.hwnd
         return "hwnd"
      }

      if ObjHasKey(image, "window") {
         image := image.window
         return "window"
      }

      if ObjHasKey(image, "base64") {
         image := image.base64
         return "base64"
      }

      if ObjHasKey(image, "sprite") {
         image := image.sprite
         return "sprite"
      }

      throw Exception("Invalid type.")
   }

   ImageType(ByRef image) {
         ; Must be first as ClipboardAll is just an empty string when passed through functions.
         if this.is_clipboard(image)
            return "clipboard"

         ; Throw if the image is an empty string.
         if (image == "")
            throw Exception("Image data is an empty string."
            . "`nIf you passed ClipboardAll it does not contain compatible image data.")

      if IsObject(image) {
         ; An "object" is an object that implements a Bitmap() method returning a pointer to a GDI+ bitmap.
         if IsFunc(image.Bitmap)
            return "object"

         ; A "buffer" is an AutoHotkey v2 buffer object.
         if ObjHasKey(image, "pBitmap")
            return "buffer"

         ; A "screenshot" is an array of 4 numbers.
         if (image.1 ~= "^-?\d+$" && image.2 ~= "^-?\d+$" && image.3 ~= "^-?\d+$" && image.4 ~= "^-?\d+$")
            return "screenshot"
      }
         ; A "desktop" is a hidden window behind the desktop icons created by ImagePutDesktop.
         if (image = "desktop")
            return "desktop"

         ; A "wallpaper" is the desktop wallpaper.
         if (image = "wallpaper")
            return "wallpaper"

         ; A "cursor" is the name of a known cursor name.
         if (image ~= "(?i)^(IDC|OCR)?_?(A_Cursor|AppStarting|Arrow|Cross|Help|IBeam|"
         . "Icon|No|Size|SizeAll|SizeNESW|SizeNS|SizeNWSE|SizeWE|UpArrow|Wait|Unknown)$")
            return "cursor"

         ; A "url" satisfies the url format.
         if this.is_url(image)
            return "url"

         ; A "file" must exist.
         if FileExist(image)
            return "file"

         ; A "bitmap" is a pointer to a GDI+ Bitmap.
         if (DllCall("gdiplus\GdipGetImageType", "ptr", image, "ptr*", ErrorLevel) == 0)
            return "bitmap"

         ; A "hBitmap" is a handle to a GDI Bitmap.
         if (DllCall("GetObjectType", "ptr", image) == 7)
            return "hBitmap"

         ; A "monitor" is a number like 0 and 1.
         if (image = 0) ;if (image ~= "^\d+$" && image <= GetMonitorCount())
            return "monitor"

         ; A "hwnd" is a handle to a window and more commonly known as ahk_id.
         if DllCall("IsWindow", "ptr", image)
            return "hwnd"

         ; A "window" is anything considered a Window Title including ahk_class and "A".
         if WinExist(image)
            return "window"

         ; A "base64" string is binary image data encoded into text using only 64 characters.
         if (image ~= "^\s*(?:data:image\/[a-z]+;base64,)?"
         . "(?:[A-Za-z0-9+\/]{4})*+(?:[A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{2}==)?\s*$")
            return "base64"

      throw Exception("Image type could not be identified.")
   }

   toBitmap(type, ByRef image) {

      if (type = "clipboard")
         return this.from_clipboard()

      if (type = "object")
         return image.Bitmap()

      if (type = "buffer") {
         DllCall("gdiplus\GdipCloneImage", "ptr", image.pBitmap, "ptr*", pBitmap)
         return pBitmap
      }

      if (type = "screenshot")
         return this.from_screenshot(image)

      if (type = "desktop")
         return this.from_desktop()

      if (type = "wallpaper")
         return this.from_wallpaper()

      if (type = "cursor")
         return this.from_cursor()

      if (type = "url")
         return this.from_url(image)

      if (type = "file") {
         DllCall("gdiplus\GdipCreateBitmapFromFile", "wstr", image, "ptr*", pBitmap)
         return pBitmap
      }

      if (type = "bitmap") {
         DllCall("gdiplus\GdipCloneImage", "ptr", image, "ptr*", pBitmap)
         return pBitmap
      }

      if (type = "hBitmap")
         return this.from_hBitmap(image)

      if (type = "monitor")
         return this.from_monitor(image)

      if (type = "hwnd" || type = "window") {
         image := (type = "window") ? WinExist(image) : image
         return this.from_hwnd(image)
      }

      if (type = "base64")
         return this.from_base64(image)

      if (type = "sprite")
         return this.from_sprite(image)

      throw Exception("Conversion from this type is not supported.")
   }

   toCotype(cotype, ByRef pBitmap, terms*) {
      ; toCotype("clipboard", pBitmap)
      if (cotype = "clipboard")
         return this.put_clipboard(pBitmap)

      ; toCotype("buffer", pBitmap)
      if (cotype = "buffer") {
         buffer := {__New: ObjBindMethod(this, "gdiplusStartup") ; Increment GDI+ reference count
               , __Delete: ObjBindMethod(this, "gdiplusShutdown", "smart_pointer", pBitmap)}
         buffer := new buffer      ; On deletion the buffer object will dispose of the bitmap.
         buffer.pBitmap := pBitmap ; And it will decrement this.gdiplus.
         return buffer
      }

      ; toCotype("screenshot", pBitmap, screenshot, alpha)
      if (cotype = "screenshot")
         return this.put_screenshot(pBitmap, terms.1, terms.2)

      ; toCotype("desktop", pBitmap)
      if (cotype = "desktop")
         return this.put_desktop(pBitmap)

      ; toCotype("wallpaper", pBitmap)
      if (cotype = "wallpaper")
         return this.put_wallpaper(pBitmap)

      ; toCotype("cursor", pBitmap, xHotspot, yHotspot)
      if (cotype = "cursor")
         return this.put_cursor(pBitmap, terms.1, terms.2)

      ; toCotype("url", ????????????????????????
      if (cotype = "url") {
         ; put a url
      }

      ; toCotype("file", pBitmap, filename, quality)
      if (cotype = "file")
         return this.put_file(pBitmap, terms.1, terms.2)

      ; toCotype("window", pBitmap)
      if (cotype = "window")
         return "ahk_id " . this.Render({"bitmap":pBitmap}).AlwaysOnTop().ToolWindow().Caption().hwnd

      ; toCotype("hwnd", pBitmap)
      if (cotype = "hwnd")
         return this.Render({"bitmap":pBitmap}).hwnd

      ; toCotype("bitmap", pBitmap)
      if (cotype = "bitmap")
         return pBitmap

      ; toCotype("hBitmap", pBitmap, alpha)
      if (cotype = "hBitmap")
         return this.put_hBitmap(pBitmap, terms.1)

      ; toCotype("base64", pBitmap, extension, quality)
      if (cotype = "base64") ; Thanks to noname.
         return this.put_base64(pBitmap, terms.1, terms.2)

      throw Exception("Conversion to this type is not supported.")
   }

   DisposeImage(ByRef pBitmap) {
      return DllCall("gdiplus\GdipDisposeImage", "ptr", pBitmap)
   }

   BitmapCrop(ByRef pBitmap, crop) {
      ; Get Bitmap width and height and format.
      DllCall("gdiplus\GdipGetImageWidth", "ptr", pBitmap, "uint*", width)
      DllCall("gdiplus\GdipGetImageHeight", "ptr", pBitmap, "uint*", height)
      DllCall("gdiplus\GdipGetImagePixelFormat", "ptr", pBitmap, "ptr*", format)

      ; Are the numbers percentages?
      crop.3 := (crop.3 ~= "%$") ? SubStr(crop.3, 1, -1) * 0.01 * width : crop.3
      crop.4 := (crop.4 ~= "%$") ? SubStr(crop.4, 1, -1) * 0.01 * height : crop.4
      crop.1 := (crop.1 ~= "%$") ? SubStr(crop.1, 1, -1) * 0.01 * width : crop.1
      crop.2 := (crop.2 ~= "%$") ? SubStr(crop.2, 1, -1) * 0.01 * height : crop.2

      ; If numbers are negative, subtract the values from the edge.
      crop.3 := (crop.3 < 0) ?  width - Abs(crop.3) - Abs(crop.1) : crop.3
      crop.4 := (crop.4 < 0) ? height - Abs(crop.4) - Abs(crop.2) : crop.4
      crop.1 := Abs(crop.1)
      crop.2 := Abs(crop.2)

      ; Round to the nearest integer.
      crop.3 := Round(crop.1 + crop.3) - Round(crop.1) ; A reminder that width and height
      crop.4 := Round(crop.2 + crop.4) - Round(crop.2) ; are distances, not coordinates.
      crop.1 := Round(crop.1) ; so the abstract concept of a distance must be resolved
      crop.2 := Round(crop.2) ; into coordinates and then rounded and added up again.

      ; Variance Shift. Now place x,y before w,h because we are building abstracts from reals now.
      ; Before we were resolving abstracts into real coordinates, now it's the opposite.

      ; Ensure that coordinates can never exceed the expected Bitmap area.
      safe_x := (crop.1 > width) ? 0 : crop.1                         ; Zero x if bigger.
      safe_y := (crop.2 > height) ? 0 : crop.2                        ; Zero y if bigger.
      safe_w := (crop.1 + crop.3 > width) ? width - safe_x : crop.3   ; Max w if bigger.
      safe_h := (crop.2 + crop.4 > height) ? height - safe_y : crop.4 ; Max h if bigger.

      ; Clone
      DllCall("gdiplus\GdipCloneBitmapAreaI"
               ,    "int", safe_x
               ,    "int", safe_y
               ,    "int", safe_w
               ,    "int", safe_h
               ,    "int", format
               ,    "ptr", pBitmap
               ,   "ptr*", pBitmapCrop)

      return pBitmapCrop
   }

   BitmapScale(ByRef pBitmap, scale) {
      ; Get Bitmap width and height and format.
      DllCall("gdiplus\GdipGetImageWidth", "ptr", pBitmap, "uint*", width)
      DllCall("gdiplus\GdipGetImageHeight", "ptr", pBitmap, "uint*", height)
      DllCall("gdiplus\GdipGetImagePixelFormat", "ptr", pBitmap, "ptr*", format)

      safe_w := Ceil(width * scale)
      safe_h := Ceil(height * scale)

      ; Create a new bitmap and get the graphics context.
      DllCall("gdiplus\GdipCreateBitmapFromScan0"
               , "int", safe_w, "int", safe_h, "int", 0, "int", format, "ptr", 0, "ptr*", pBitmapScale)
      DllCall("gdiplus\GdipGetImageGraphicsContext", "ptr", pBitmapScale, "ptr*", pGraphics)

      ; Set settings in graphics context.
      DllCall("gdiplus\GdipSetPixelOffsetMode",    "ptr", pGraphics, "int", 2) ; Half pixel offset.
      DllCall("gdiplus\GdipSetCompositingMode",    "ptr", pGraphics, "int", 1) ; Overwrite/SourceCopy.
      DllCall("gdiplus\GdipSetInterpolationMode",  "ptr", pGraphics, "int", 7) ; HighQualityBicubic

      ; Draw Image. Not sure why the integer variant fails below.
      DllCall("gdiplus\GdipCreateImageAttributes", "ptr*", ImageAttr)
      DllCall("gdiplus\GdipSetImageAttributesWrapMode", "ptr", ImageAttr, "int", 3) ; WrapModeTileFlipXY
      DllCall("gdiplus\GdipDrawImageRectRectI"
               ,    "ptr", pGraphics
               ,    "ptr", pBitmap
               ,    "int", 0, "int", 0, "int", safe_w, "int", safe_h ; destination rectangle
               ,    "int", 0, "int", 0, "int",  width, "int", height ; source rectangle
               ,    "int", 2
               ,    "ptr", ImageAttr
               ,    "ptr", 0
               ,    "ptr", 0)
      DllCall("gdiplus\GdipDisposeImageAttributes", "ptr", ImageAttr)

      ; Clean up the graphics context.
      DllCall("gdiplus\GdipDeleteGraphics", "ptr", pGraphics)
      return pBitmapScale
   }

   is_clipboard(c) {
      ; ClipboardAll is always an empty string when passed into a function.
      if (c != "") ; Must be an empty string.
         return false

      ; Look through the clipboard for a memory object containing a BITMAPINFO structure followed by the bitmap bits.
      if DllCall("OpenClipboard", "ptr", 0) {
         _answer := DllCall("IsClipboardFormatAvailable", "uint", 8) ; CF_DIB
         DllCall("CloseClipboard")
         if (_answer)
            return true
      }

      ; Error messages are inaccurate and it can't be helped.
      return false
   }

   is_url(url) {
      ; Thanks splattermania - https://www.php.net/manual/en/function.preg-match.php#93824

      regex := "^(?i)"
         . "((https?|ftp)\:\/\/)" ; SCHEME
         . "([a-z0-9+!*(),;?&=\$_.-]+(\:[a-z0-9+!*(),;?&=\$_.-]+)?@)?" ; User and Pass
         . "([a-z0-9-.]*)\.([a-z]{2,3})" ; Host or IP
         . "(\:[0-9]{2,5})?" ; Port
         . "(\/(?:[a-z0-9-_~!$&'()*+,;=:@]\.?)+)*\/?" ; Path
         . "(\?[a-z+&\$_.-][a-z0-9;:@&%=+\/\$_.-]*)?" ; GET Query
         . "(#[a-z_.-][a-z0-9+\$_.-]*)?$" ; Anchor
      return (url ~= regex)
   }

   from_clipboard() {
      ; Thanks tic - https://www.autohotkey.com/boards/viewtopic.php?t=6517

      if DllCall("OpenClipboard", "ptr", 0) {
         hBitmap := DllCall("GetClipboardData", "uint", 2, "ptr")
         DllCall("CloseClipboard")
         DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "ptr", hBitmap, "ptr", 0, "ptr*", pBitmap)
         DllCall("DeleteObject", "ptr", hBitmap)
      }
      return pBitmap
   }

   from_screenshot(ByRef image) {
      ; Thanks tic - https://www.autohotkey.com/boards/viewtopic.php?t=6517

      ; struct BITMAPINFOHEADER - https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfoheader
      hdc := DllCall("CreateCompatibleDC", "ptr", 0, "ptr")
      VarSetCapacity(bi, 40, 0)               ; sizeof(bi) = 40
         , NumPut(      40, bi,  0,   "uint") ; Size
         , NumPut( image.3, bi,  4,   "uint") ; Width
         , NumPut(-image.4, bi,  8,    "int") ; Height - Negative so (0, 0) is top-left.
         , NumPut(       1, bi, 12, "ushort") ; Planes
         , NumPut(      32, bi, 14, "ushort") ; BitCount / BitsPerPixel
      hbm := DllCall("CreateDIBSection", "ptr", hdc, "ptr", &bi, "uint", 0, "ptr*", pBits, "ptr", 0, "uint", 0, "ptr")
      obm := DllCall("SelectObject", "ptr", hdc, "ptr", hbm, "ptr")

      ; Retrieve the device context for the screen.
      sdc := DllCall("GetDC", "ptr", 0, "ptr")

      ; Copies a portion of the screen to a new device context.
      DllCall("gdi32\BitBlt"
               , "ptr", hdc, "int", 0, "int", 0, "int", image.3, "int", image.4
               , "ptr", sdc, "int", image.1, "int", image.2, "uint", 0x00CC0020) ; SRCCOPY

      ; Release the device context to the screen.
      DllCall("ReleaseDC", "ptr", 0, "ptr", sdc)

      ; Convert the hBitmap to a Bitmap using a built in function as there is no transparency.
      DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "ptr", hbm, "ptr", 0, "ptr*", pBitmap)

      ; Cleanup the hBitmap and device contexts.
      DllCall("SelectObject", "ptr", hdc, "ptr", obm)
      DllCall("DeleteObject", "ptr", hbm)
      DllCall("DeleteDC",     "ptr", hdc)

      return pBitmap
   }

   from_wallpaper() {
      ; Get the width and height of all monitors.
      width  := DllCall("GetSystemMetrics", "int", 78)
      height := DllCall("GetSystemMetrics", "int", 79)

      ; struct BITMAPINFOHEADER - https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfoheader
      hdc := DllCall("CreateCompatibleDC", "ptr", 0, "ptr")
      VarSetCapacity(bi, 40, 0)               ; sizeof(bi) = 40
         , NumPut(      40, bi,  0,   "uint") ; Size
         , NumPut(   width, bi,  4,   "uint") ; Width
         , NumPut( -height, bi,  8,    "int") ; Height - Negative so (0, 0) is top-left.
         , NumPut(       1, bi, 12, "ushort") ; Planes
         , NumPut(      32, bi, 14, "ushort") ; BitCount / BitsPerPixel
      hbm := DllCall("CreateDIBSection", "ptr", hdc, "ptr", &bi, "uint", 0, "ptr*", pBits, "ptr", 0, "uint", 0, "ptr")
      obm := DllCall("SelectObject", "ptr", hdc, "ptr", hbm, "ptr")

      ; Paints the desktop.
      DllCall("PaintDesktop", "ptr", hdc)

      ; Convert the hBitmap to a Bitmap using a built in function as there is no transparency.
      DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "ptr", hbm, "ptr", 0, "ptr*", pBitmap)

      ; Cleanup the hBitmap and device contexts.
      DllCall("SelectObject", "ptr", hdc, "ptr", obm)
      DllCall("DeleteObject", "ptr", hbm)
      DllCall("DeleteDC",     "ptr", hdc)

      return pBitmap
   }

   from_cursor() {
      ; Thanks 23W - https://stackoverflow.com/a/13295280

      ; struct CURSORINFO - https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-cursorinfo
      NumPut(VarSetCapacity(ci, 16+A_PtrSize, 0), ci, "int") ; sizeof(CURSORINFO) = 20, 24
      DllCall("GetCursorInfo", "ptr", &ci)
         ; cShow   := NumGet(ci,  4, "int")                  ; 0x1 = CURSOR_SHOWING, 0x2 = CURSOR_SUPPRESSED
         , hCursor := NumGet(ci,  8, "ptr")
         ; xCursor := NumGet(ci,  8+A_PtrSize, "int")
         ; yCursor := NumGet(ci, 12+A_PtrSize, "int")

      ; struct ICONINFO - https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-iconinfo
      VarSetCapacity(ii, 8+3*A_PtrSize, 0)               ; sizeof(ICONINFO) = 20, 32
      DllCall("GetIconInfo", "ptr", hCursor, "ptr", &ii)
         ; xHotspot := NumGet(ii, 4, "uint")
         ; yHotspot := NumGet(ii, 8, "uint")
         , hbmMask  := NumGet(ii, 8+A_PtrSize, "ptr")    ; x86:12, x64:16
         , hbmColor := NumGet(ii, 8+2*A_PtrSize, "ptr")  ; x86:16, x64:24

      ; struct BITMAP - https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmap
      DllCall("GetObject"
               ,    "ptr", hbmMask
               ,    "int", VarSetCapacity(bm, 16+2*A_PtrSize)   ; sizeof(BITMAP) = 24, 32
               ,    "ptr", &bm)
         , width  := NumGet(bm, 4, "uint")
         , height := NumGet(bm, 8, "uint") / (hbmColor ? 1 : 2) ; Black and White cursors have doubled height.

      ; Clean up these hBitmaps.
      DllCall("DeleteObject", "ptr", hbmMask)
      DllCall("DeleteObject", "ptr", hbmColor)

      ; struct BITMAPINFOHEADER - https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfoheader
      hdc := DllCall("CreateCompatibleDC", "ptr", 0, "ptr")
      VarSetCapacity(bi, 40, 0)               ; sizeof(bi) = 40
         , NumPut(      40, bi,  0,   "uint") ; Size
         , NumPut(   width, bi,  4,   "uint") ; Width
         , NumPut( -height, bi,  8,    "int") ; Height - Negative so (0, 0) is top-left.
         , NumPut(       1, bi, 12, "ushort") ; Planes
         , NumPut(      32, bi, 14, "ushort") ; BitCount / BitsPerPixel
      hbm := DllCall("CreateDIBSection", "ptr", hdc, "ptr", &bi, "uint", 0, "ptr*", pBits, "ptr", 0, "uint", 0, "ptr")
      obm := DllCall("SelectObject", "ptr", hdc, "ptr", hbm, "ptr")

      ; This is the 32-bit ARGB pBitmap (different from an hBitmap) that will receive the final converted pixels.
      DllCall("gdiplus\GdipCreateBitmapFromScan0"
               , "int", width, "int", height, "int", 0, "int", 0x26200A, "ptr", 0, "ptr*", pBitmap)

      ; Create a Scan0 buffer pointing to pBits. The buffer has pixel format pARGB.
      VarSetCapacity(Rect, 16, 0)              ; sizeof(Rect) = 16
         , NumPut(  width, Rect,  8,   "uint") ; Width
         , NumPut( height, Rect, 12,   "uint") ; Height
      VarSetCapacity(BitmapData, 16+2*A_PtrSize, 0)     ; sizeof(BitmapData) = 24, 32
         , NumPut(     width, BitmapData,  0,   "uint") ; Width
         , NumPut(    height, BitmapData,  4,   "uint") ; Height
         , NumPut( 4 * width, BitmapData,  8,    "int") ; Stride
         , NumPut(   0xE200B, BitmapData, 12,    "int") ; PixelFormat
         , NumPut(     pBits, BitmapData, 16,    "ptr") ; Scan0

      ; Use LockBits to create a writable buffer that converts pARGB to ARGB.
      DllCall("gdiplus\GdipBitmapLockBits"
               ,    "ptr", pBitmap
               ,    "ptr", &Rect
               ,   "uint", 6            ; ImageLockMode.UserInputBuffer | ImageLockMode.WriteOnly
               ,    "int", 0xE200B      ; Format32bppPArgb
               ,    "ptr", &BitmapData) ; Contains the pointer (pBits) to the hbm.

      ; Don't use DI_DEFAULTSIZE to draw the icon like DrawIcon does as it will resize to 32 x 32.
      DllCall("DrawIconEx"
               , "ptr", hdc,     "int", 0, "int", 0
               , "ptr", hCursor, "int", 0, "int", 0
               , "uint", 0, "ptr", 0, "uint", 0x1 | 0x2 | 0x4) ; DI_MASK | DI_IMAGE | DI_COMPAT

      ; Convert the pARGB pixels copied into the device independent bitmap (hbm) to ARGB.
      DllCall("gdiplus\GdipBitmapUnlockBits", "ptr", pBitmap, "ptr", &BitmapData)

      ; Clean up the icon and device context.
      DllCall("DestroyIcon",  "ptr", hCursor)
      DllCall("SelectObject", "ptr", hdc, "ptr", obm)
      DllCall("DeleteObject", "ptr", hbm)
      DllCall("DeleteDC",     "ptr", hdc)

      return pBitmap
   }

   from_url(ByRef image) {
      req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
      req.Open("GET", image)
      req.Send()
      pStream := ComObjQuery(req.ResponseStream, "{0000000C-0000-0000-C000-000000000046}")
      DllCall("gdiplus\GdipCreateBitmapFromStream", "ptr", pStream, "ptr*", pBitmap)
      ObjRelease(pStream)
      return pBitmap
   }

   from_hBitmap(ByRef image) {
      ; struct BITMAP - https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmap
      DllCall("GetObject"
               ,    "ptr", image
               ,    "int", VarSetCapacity(dib, 76+2*(A_PtrSize=8?4:0)+2*A_PtrSize)
               ,    "ptr", &dib) ; sizeof(DIBSECTION) = 84, 104
         , width  := NumGet(dib, 4, "uint")
         , height := NumGet(dib, 8, "uint")
         , bpp    := NumGet(dib, 18, "ushort")

      ; Fallback to built-in method if pixels are not 32-bit ARGB.
      if (bpp != 32) { ; This built-in version is 120% faster but ignores transparency.
         DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "ptr", image, "ptr", 0, "ptr*", pBitmap)
         return pBitmap
      }

      ; Create a handle to a device context and associate the image.
      hdc := DllCall("CreateCompatibleDC", "ptr", 0, "ptr")           ; Creates a memory DC compatible with the current screen.
      obm := DllCall("SelectObject", "ptr", hdc, "ptr", image, "ptr") ; Put the (hBitmap) image onto the device context.

      ; Create a device independent bitmap with negative height. All DIBs use the screen pixel format (pARGB).
      ; Use hbm to buffer the image such that top-down and bottom-up images are mapped to this top-down buffer.
      cdc := DllCall("CreateCompatibleDC", "ptr", hdc, "ptr")
      VarSetCapacity(bi, 40, 0)               ; sizeof(bi) = 40
         , NumPut(      40, bi,  0,   "uint") ; Size
         , NumPut(   width, bi,  4,   "uint") ; Width
         , NumPut( -height, bi,  8,    "int") ; Height - Negative so (0, 0) is top-left.
         , NumPut(       1, bi, 12, "ushort") ; Planes
         , NumPut(      32, bi, 14, "ushort") ; BitCount / BitsPerPixel
      hbm := DllCall("CreateDIBSection", "ptr", cdc, "ptr", &bi, "uint", 0
               , "ptr*", pBits  ; pBits is the pointer to (top-down) pixel values.
               , "ptr", 0, "uint", 0, "ptr")
      ob2 := DllCall("SelectObject", "ptr", cdc, "ptr", hbm, "ptr")

      ; This is the 32-bit ARGB pBitmap (different from an hBitmap) that will receive the final converted pixels.
      DllCall("gdiplus\GdipCreateBitmapFromScan0"
               , "int", width, "int", height, "int", 0, "int", 0x26200A, "ptr", 0, "ptr*", pBitmap)

      ; Create a Scan0 buffer pointing to pBits. The buffer has pixel format pARGB.
      VarSetCapacity(Rect, 16, 0)              ; sizeof(Rect) = 16
         , NumPut(  width, Rect,  8,   "uint") ; Width
         , NumPut( height, Rect, 12,   "uint") ; Height
      VarSetCapacity(BitmapData, 16+2*A_PtrSize, 0)     ; sizeof(BitmapData) = 24, 32
         , NumPut(     width, BitmapData,  0,   "uint") ; Width
         , NumPut(    height, BitmapData,  4,   "uint") ; Height
         , NumPut( 4 * width, BitmapData,  8,    "int") ; Stride
         , NumPut(   0xE200B, BitmapData, 12,    "int") ; PixelFormat
         , NumPut(     pBits, BitmapData, 16,    "ptr") ; Scan0

      ; Use LockBits to create a writable buffer that converts pARGB to ARGB.
      DllCall("gdiplus\GdipBitmapLockBits"
               ,    "ptr", pBitmap
               ,    "ptr", &Rect
               ,   "uint", 6            ; ImageLockMode.UserInputBuffer | ImageLockMode.WriteOnly
               ,    "int", 0xE200B      ; Format32bppPArgb
               ,    "ptr", &BitmapData) ; Contains the pointer (pBits) to the hbm.

      ; Copies the image (hBitmap) to a top-down bitmap. Removes bottom-up-ness if present.
      DllCall("gdi32\BitBlt"
               , "ptr", cdc, "int", 0, "int", 0, "int", width, "int", height
               , "ptr", hdc, "int", 0, "int", 0, "uint", 0x00CC0020) ; SRCCOPY

      ; Convert the pARGB pixels copied into the device independent bitmap (hbm) to ARGB.
      DllCall("gdiplus\GdipBitmapUnlockBits", "ptr", pBitmap, "ptr", &BitmapData)

      ; Cleanup the buffer and device contexts.
      DllCall("SelectObject", "ptr", cdc, "ptr", ob2)
      DllCall("DeleteObject", "ptr", hbm)
      DllCall("DeleteDC",     "ptr", cdc)
      DllCall("SelectObject", "ptr", hdc, "ptr", obm)
      DllCall("DeleteDC",     "ptr", hdc)

      return pBitmap
   }

   from_monitor(ByRef image) {
      if (image > 0) {
      ;   M := GetMonitorInfo(image)
         x := M.Left
         y := M.Top
         w := M.Right - M.Left
         h := M.Bottom - M.Top
      } else {
         x := DllCall("GetSystemMetrics", "int", 76)
         y := DllCall("GetSystemMetrics", "int", 77)
         w := DllCall("GetSystemMetrics", "int", 78)
         h := DllCall("GetSystemMetrics", "int", 79)
      }
      return this.from_screenshot([x,y,w,h])
   }

   from_hwnd(ByRef image) {
      ; Thanks tic - https://www.autohotkey.com/boards/viewtopic.php?t=6517

      ; Restore the window if minimized! Must be visible for capture.
      if DllCall("IsIconic", "ptr", image)
         DllCall("ShowWindow", "ptr", image, "int", 4)

      ; Get the width and height of the client window.
      VarSetCapacity(rect, 16) ; sizeof(RECT) = 16
      DllCall("GetClientRect", "ptr", image, "ptr", &rect)
         , width  := NumGet(rect, 8, "int")
         , height := NumGet(rect, 12, "int")

      ; struct BITMAPINFOHEADER - https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfoheader
      hdc := DllCall("CreateCompatibleDC", "ptr", 0, "ptr")
      VarSetCapacity(bi, 40, 0)               ; sizeof(bi) = 40
         , NumPut(      40, bi,  0,   "uint") ; Size
         , NumPut(   width, bi,  4,   "uint") ; Width
         , NumPut( -height, bi,  8,    "int") ; Height - Negative so (0, 0) is top-left.
         , NumPut(       1, bi, 12, "ushort") ; Planes
         , NumPut(      32, bi, 14, "ushort") ; BitCount / BitsPerPixel
      hbm := DllCall("CreateDIBSection", "ptr", hdc, "ptr", &bi, "uint", 0, "ptr*", pBits, "ptr", 0, "uint", 0, "ptr")
      obm := DllCall("SelectObject", "ptr", hdc, "ptr", hbm, "ptr")

      ; Print the window onto the hBitmap using an undocumented flag. https://stackoverflow.com/a/40042587
      DllCall("PrintWindow", "ptr", image, "ptr", hdc, "uint", 0x3) ; PW_CLIENTONLY | PW_RENDERFULLCONTENT
      ; Additional info on how this is implemented: https://www.reddit.com/r/windows/comments/8ffr56/altprintscreen/

      ; Convert the hBitmap to a Bitmap using a built in function as there is no transparency.
      DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "ptr", hbm, "ptr", 0, "ptr*", pBitmap)

      ; Cleanup the hBitmap and device contexts.
      DllCall("SelectObject", "ptr", hdc, "ptr", obm)
      DllCall("DeleteObject", "ptr", hbm)
      DllCall("DeleteDC",     "ptr", hdc)

      return pBitmap
   }

   from_base64(ByRef image) {
      ; Trim whitespace and remove header.
      image := Trim(image)
      image := RegExReplace(image, "^data:image\/[a-z]+;base64,")

      ; Converts the image to binary data by first asking for the size.
      DllCall("crypt32\CryptStringToBinary", "ptr",&image, "uint",0, "uint",0x1, "ptr",   0, "uint*",size, "ptr",0, "ptr",0)
      VarSetCapacity(bin, size, 0)
      DllCall("crypt32\CryptStringToBinary", "ptr",&image, "uint",0, "uint",0x1, "ptr",&bin, "uint*",size, "ptr",0, "ptr",0)

      ; Makes a stream for conversion into a pBitmap.
      pStream := DllCall("shlwapi\SHCreateMemStream", "ptr", &bin, "uint", size, "ptr")
      DllCall("gdiplus\GdipCreateBitmapFromStream", "ptr", pStream, "ptr*", pBitmap)
      ObjRelease(pStream)

      return pBitmap
   }

   from_sprite(ByRef image) {
      ; Create a source pBitmap and extract the width and height.
      if DllCall("gdiplus\GdipCreateBitmapFromFile", "wstr", image, "ptr*", sBitmap)
         if !(sBitmap := this.from_url(image))
            throw Exception("Could not be loaded from a valid file path or URL.")

      ; Get Bitmap width and height.
      DllCall("gdiplus\GdipGetImageWidth", "ptr", sBitmap, "uint*", width)
      DllCall("gdiplus\GdipGetImageHeight", "ptr", sBitmap, "uint*", height)

      ; Create a destination pBitmap in 32-bit ARGB and get its device context though GDI+.
      ; Note that a device context from a graphics context can only be drawn on, not read.
      ; Also note that using a graphics context and blitting does not create a pixel perfect image.
      ; Using a DIB and LockBits is about 5% faster.
      DllCall("gdiplus\GdipCreateBitmapFromScan0"
               , "int", width, "int", height, "int", 0, "int", 0x26200A, "ptr", 0, "ptr*", dBitmap)
      DllCall("gdiplus\GdipGetImageGraphicsContext", "ptr", dBitmap, "ptr*", dGraphics)
      DllCall("gdiplus\GdipGetDC", "ptr", dGraphics, "ptr*", ddc)

      ; Keep any existing transparency for whatever reason.
      hBitmap := this.put_hBitmap(sBitmap) ; Could copy this code here for even more speed.

      ; Create a source device context and associate the source hBitmap.
      sdc := DllCall("CreateCompatibleDC", "ptr", ddc, "ptr")
      obm := DllCall("SelectObject", "ptr", sdc, "ptr", hBitmap, "ptr")

      ; Copy the image making the top-left pixel the color key.
      DllCall("msimg32\TransparentBlt"
               , "ptr", ddc, "int", 0, "int", 0, "int", width, "int", height  ; destination
               , "ptr", sdc, "int", 0, "int", 0, "int", width, "int", height  ; source
               , "uint", DllCall("GetPixel", "ptr", sdc, "int", 0, "int", 0)) ; RGB pixel.

      ; Cleanup the hBitmap and device contexts.
      DllCall("SelectObject", "ptr", sdc, "ptr", obm)
      DllCall("DeleteObject", "ptr", hBitmap)
      DllCall("DeleteDC",     "ptr", sdc)

      ; Release the graphics context and delete.
      DllCall("gdiplus\GdipReleaseDC", "ptr", dGraphics, "ptr", ddc)
      DllCall("gdiplus\GdipDeleteGraphics", "ptr", dGraphics)

      return dBitmap
   }

   put_clipboard(ByRef pBitmap) {
      ; Thanks tic - https://www.autohotkey.com/boards/viewtopic.php?t=6517

      off1 := A_PtrSize = 8 ? 52 : 44, off2 := A_PtrSize = 8 ? 32 : 24
      DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "ptr", pBitmap, "ptr*", hBitmap, "uint", 0xFFFFFFFF)
      DllCall("GetObject", "ptr", hBitmap, "int", VarSetCapacity(oi, A_PtrSize = 8 ? 104 : 84, 0), "ptr", &oi)
      hdib := DllCall("GlobalAlloc", "uint", 2, "ptr", 40+NumGet(oi, off1, "uint"), "ptr")
      pdib := DllCall("GlobalLock", "ptr", hdib, "ptr")
      DllCall("RtlMoveMemory", "ptr", pdib, "ptr", &oi+off2, "uptr", 40)
      DllCall("RtlMoveMemory", "ptr", pdib+40, "ptr", NumGet(oi, off2 - (A_PtrSize ? A_PtrSize : 4), "ptr"), "uptr", NumGet(oi, off1, "uint"))
      DllCall("GlobalUnlock", "ptr", hdib)
      DllCall("DeleteObject", "ptr", hBitmap)

      DllCall("OpenClipboard", "ptr", 0)
      DllCall("EmptyClipboard")
      DllCall("SetClipboardData", "uint", 8, "ptr", hdib)
      DllCall("CloseClipboard")

      ; Returns an empty string as ClipboardAll would also be an empty string.
      return ""
   }

   put_screenshot(ByRef pBitmap, screenshot := "", alpha := "") {
      ; Get Bitmap width and height.
      DllCall("gdiplus\GdipGetImageWidth", "ptr", pBitmap, "uint*", width)
      DllCall("gdiplus\GdipGetImageHeight", "ptr", pBitmap, "uint*", height)

      x := (screenshot.1 != "") ? screenshot.1 : Round((A_ScreenWidth - width) / 2)
      y := (screenshot.2 != "") ? screenshot.2 : Round((A_ScreenHeight - height) / 2)
      w := (screenshot.3 != "") ? screenshot.3 : width
      h := (screenshot.4 != "") ? screenshot.4 : height

      ; Convert the Bitmap to a hBitmap and associate a device context for blitting.
      hdc := DllCall("CreateCompatibleDC", "ptr", 0, "ptr")
      hbm := this.put_hBitmap(pBitmap, alpha)
      obm := DllCall("SelectObject", "ptr", hdc, "ptr", hbm, "ptr")

      ; Get device context of spawned window.
      ddc := DllCall("GetDC", "ptr", 0, "ptr")

      ; Copies a portion of the screen to a new device context.
      DllCall("gdi32\StretchBlt"
               , "ptr", ddc, "int", x, "int", y, "int", w,     "int", h
               , "ptr", hdc, "int", 0, "int", 0, "int", width, "int", height
               , "uint", 0x00CC0020) ; SRCCOPY

      ; Release device context of spawned window.
      DllCall("ReleaseDC", "ptr", 0, "ptr", ddc)

      ; Cleanup the hBitmap and device contexts.
      DllCall("SelectObject", "ptr", hdc, "ptr", obm)
      DllCall("DeleteObject", "ptr", hbm)
      DllCall("DeleteDC",     "ptr", hdc)

      return [x,y,w,h]
   }

   put_desktop(ByRef pBitmap) {
      ; Thanks Gerald Degeneve - https://www.codeproject.com/Articles/856020/Draw-Behind-Desktop-Icons-in-Windows-plus

      ; Get Bitmap width and height.
      DllCall("gdiplus\GdipGetImageWidth", "ptr", pBitmap, "uint*", width)
      DllCall("gdiplus\GdipGetImageHeight", "ptr", pBitmap, "uint*", height)

      ; Convert the Bitmap to a hBitmap and associate a device context for blitting.
      hdc := DllCall("CreateCompatibleDC", "ptr", 0, "ptr")
      hbm := this.put_hBitmap(pBitmap)
      obm := DllCall("SelectObject", "ptr", hdc, "ptr", hbm, "ptr")

      ; Post-Creator's Update Windows 10. WM_SPAWN_WORKER = 0x052C
      DllCall("SendMessage", "ptr", WinExist("ahk_class Progman"), "uint", 0x052C, "ptr", 0x0000000D, "ptr", 0)
      DllCall("SendMessage", "ptr", WinExist("ahk_class Progman"), "uint", 0x052C, "ptr", 0x0000000D, "ptr", 1)

      ; Find the child window.
      WinGet windows, List, ahk_class WorkerW
      Loop % windows
         hwnd := windows%A_Index%
      until DllCall("FindWindowEx", "ptr", hwnd, "ptr", 0, "str", "SHELLDLL_DefView", "ptr", 0)
      WorkerW := DllCall("FindWindowEx", "ptr", 0, "ptr", hwnd, "str", "WorkerW", "ptr", 0, "ptr")

      ; Maybe this hack gets patched. Tough luck!
      if (!WorkerW)
         throw Exception("Could not draw on the desktop.")

      ; Position the image in the center. This line can be removed.
      DllCall("SetWindowPos", "ptr", WorkerW, "ptr", 1
               , "int", Round((A_ScreenWidth - width) / 2)   ; x coordinate
               , "int", Round((A_ScreenHeight - height) / 2) ; y coordinate
               , "int", width, "int", height, "uint", 0)

      ; Get device context of spawned window.
      ddc := DllCall("GetDCEx", "ptr", WorkerW, "ptr", 0, "int", 0x403, "ptr")

      ; Copies a portion of the screen to a new device context.
      DllCall("gdi32\BitBlt"
               , "ptr", ddc, "int", 0, "int", 0, "int", width, "int", height
               , "ptr", hdc, "int", 0, "int", 0, "uint", 0x00CC0020) ; SRCCOPY

      ; Release device context of spawned window.
      DllCall("ReleaseDC", "ptr", 0, "ptr", ddc)

      ; Cleanup the hBitmap and device contexts.
      DllCall("SelectObject", "ptr", hdc, "ptr", obm)
      DllCall("DeleteObject", "ptr", hbm)
      DllCall("DeleteDC",     "ptr", hdc)

      return "desktop"
   }

   put_wallpaper(ByRef pBitmap) {
      path := this.put_file(pBitmap, "temp.png")
      cc := DllCall("GetFullPathName", "str", path, "uint", 0, "ptr", 0, "ptr", 0, "uint")
      VarSetCapacity(buf, cc*(A_IsUnicode?2:1))
      DllCall("GetFullPathName", "str", path, "uint", cc, "str", buf, "ptr", 0, "uint")
      DllCall("SystemParametersInfo", "uint", 20, "uint", 0, "str", buf, "uint", 2)
      Sleep 1 ; Needed as there is some lag.
      FileDelete % path
      return "wallpaper"
   }

   put_cursor(ByRef pBitmap, xHotspot := "", yHotspot := "") {
      ; Thanks Nick - https://stackoverflow.com/a/550965

      ; Creates an icon that can be used as a cursor.
      DllCall("gdiplus\GdipCreateHICONFromBitmap", "ptr", pBitmap, "ptr*", hIcon)

      ; Sets the hotspot of the cursor by changing the icon into a cursor.
      if (xHotspot != "" || yHotspot != "") {
         ; struct ICONINFO - https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-iconinfo
         VarSetCapacity(ii, 8+3*A_PtrSize, 0)                      ; sizeof(ICONINFO) = 20, 32
         DllCall("GetIconInfo", "ptr", hIcon, "ptr", &ii)          ; Fill the ICONINFO structure.
         DllCall("DestroyIcon", "ptr", hIcon)                      ; Destroy the icon after getting the ICONINFO structure.
         NumPut(false, ii, 0, "uint")                              ; true/false are icon/cursor respectively.
         (xHotspot != "") ? NumPut(xHotspot, ii, 4, "uint") : ""   ; Set the xHotspot value. (Default: center point)
         (yHotspot != "") ? NumPut(yHotspot, ii, 8, "uint") : ""   ; Set the yHotspot value. (Default: center point)
         hIcon := DllCall("CreateIconIndirect", "ptr", &ii, "ptr") ; Create a new cursor using ICONINFO.

         ; Clean up hbmMask and hbmColor created as a result of GetIconInfo.
         DllCall("DeleteObject", "ptr", NumGet(ii, 8+A_PtrSize, "ptr"))   ; hbmMask
         DllCall("DeleteObject", "ptr", NumGet(ii, 8+2*A_PtrSize, "ptr")) ; hbmColor
      }

      ; Loop over all 16 system cursors and change them all to the new cursor.
      SystemCursors := "32512IDC_ARROW,32513IDC_IBEAM,32514IDC_WAIT,32515IDC_CROSS,32516IDC_UPARROW"
      . ",32640IDC_SIZE,32641IDC_ICON,32642IDC_SIZENWSE,32643IDC_SIZENESW,32644IDC_SIZEWE"
      . ",32645IDC_SIZENS,32646IDC_SIZEALL,32648IDC_NO,32649IDC_HAND,32650IDC_APPSTARTING,32651IDC_HELP"
      Loop Parse, SystemCursors, % ","
      { ; Must copy the handle 16 times as SetSystemCursor deletes the handle 16 times.
         hCursor := DllCall("CopyImage", "ptr", hIcon, "uint", 2, "int", 0, "int", 0, "uint", 0, "ptr")
         DllCall("SetSystemCursor", "ptr", hCursor, "int", SubStr(A_LoopField, 1, 5)) ; calls DestroyCursor
      }

      ; Destroy the original hIcon. DestroyCursor and DestroyIcon are the same function in C.
      DllCall("DestroyCursor", "ptr", hIcon)

      ; Returns the word A_Cursor so that it doesn't evaluate immediately.
      return "A_Cursor"
   }

   put_file(ByRef pBitmap, sOutput, Quality:=75) {
      ; Thanks tic - https://www.autohotkey.com/boards/viewtopic.php?t=6517
      _p := 0

      SplitPath sOutput,,_path, Extension, _filename
      Extension := (Extension ~= "^(?i:bmp|dib|rle|jpg|jpeg|jpe|jfif|gif|tif|tiff|png)$") ? Extension : "png"
      Extension := "." Extension
      sOutput := _path . _filename . Extension

      DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", nCount, "uint*", nSize)
      VarSetCapacity(ci, nSize)
      DllCall("gdiplus\GdipGetImageEncoders", "uint", nCount, "uint", nSize, "ptr", &ci)

      If (A_IsUnicode){
         StrGet_Name := "StrGet"

         Loop % nCount
         {
            sString := %StrGet_Name%(NumGet(ci, (idx := (48+7*A_PtrSize)*(A_Index-1))+32+3*A_PtrSize), "UTF-16")
            if !InStr(sString, "*" Extension)
               continue

            pCodec := &ci+idx
            break
         }
      } else {
         Loop % nCount
         {
            Location := NumGet(ci, 76*(A_Index-1)+44)
            nSize := DllCall("WideCharToMultiByte", "uint", 0, "uint", 0, "uint", Location, "int", -1, "uint", 0, "int",  0, "uint", 0, "uint", 0)
            VarSetCapacity(sString, nSize)
            DllCall("WideCharToMultiByte", "uint", 0, "uint", 0, "uint", Location, "int", -1, "str", sString, "int", nSize, "uint", 0, "uint", 0)

            if !InStr(sString, "*" Extension)
               continue

            pCodec := &ci+76*(A_Index-1)
            break
         }
      }

      if !pCodec
         return -3

      if (Quality != 75)
      {
         Quality := (Quality < 0) ? 0 : (Quality > 100) ? 100 : Quality
         if RegExMatch(Extension, "^\.(?i:JPG|JPEG|JPE|JFIF)$")
         {
            DllCall("gdiplus\GdipGetEncoderParameterListSize", Ptr, pBitmap, Ptr, pCodec, "uint*", nSize)
            VarSetCapacity(EncoderParameters, nSize, 0)
            DllCall("gdiplus\GdipGetEncoderParameterList", Ptr, pBitmap, Ptr, pCodec, "uint", nSize, Ptr, &EncoderParameters)
            nCount := NumGet(EncoderParameters, "UInt")
            N := (A_AhkVersion < 2) ? nCount : "nCount"
            Loop %N%
            {
               elem := (24+(A_PtrSize ? A_PtrSize : 4))*(A_Index-1) + 4 + (pad := A_PtrSize = 8 ? 4 : 0)
               if (NumGet(EncoderParameters, elem+16, "UInt") = 1) && (NumGet(EncoderParameters, elem+20, "UInt") = 6)
               {
                  _p := elem+&EncoderParameters-pad-4
                  NumPut(Quality, NumGet(NumPut(4, NumPut(1, _p+0)+20, "UInt")), "UInt")
                  break
               }
            }
         }
      }

      _E := DllCall("gdiplus\GdipSaveImageToFile", "ptr", pBitmap, "wstr", sOutput, "ptr", pCodec, "uint", _p ? _p : 0)
      return sOutput
   }

   put_hBitmap(ByRef pBitmap, alpha := "") {
      ; Revert to built in functionality if a replacement color is declared.
      if (alpha != "") { ; This built-in version is about 25% slower.
         DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "ptr", pBitmap, "ptr*", hBitmap, "uint", alpha)
         return hBitmap
      }

      ; Get Bitmap width and height.
      DllCall("gdiplus\GdipGetImageWidth", "ptr", pBitmap, "uint*", width)
      DllCall("gdiplus\GdipGetImageHeight", "ptr", pBitmap, "uint*", height)

      ; Convert the source pBitmap into a hBitmap manually.
      ; struct BITMAPINFOHEADER - https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfoheader
      hdc := DllCall("CreateCompatibleDC", "ptr", 0, "ptr")
      VarSetCapacity(bi, 40, 0)               ; sizeof(bi) = 40
         , NumPut(      40, bi,  0,   "uint") ; Size
         , NumPut(   width, bi,  4,   "uint") ; Width
         , NumPut( -height, bi,  8,    "int") ; Height - Negative so (0, 0) is top-left.
         , NumPut(       1, bi, 12, "ushort") ; Planes
         , NumPut(      32, bi, 14, "ushort") ; BitCount / BitsPerPixel
      hbm := DllCall("CreateDIBSection", "ptr", hdc, "ptr", &bi, "uint", 0, "ptr*", pBits, "ptr", 0, "uint", 0, "ptr")
      obm := DllCall("SelectObject", "ptr", hdc, "ptr", hbm, "ptr")

      ; Transfer data from source pBitmap to an hBitmap manually.
      VarSetCapacity(Rect, 16, 0)              ; sizeof(Rect) = 16
         , NumPut(  width, Rect,  8,   "uint") ; Width
         , NumPut( height, Rect, 12,   "uint") ; Height
      VarSetCapacity(BitmapData, 16+2*A_PtrSize, 0)     ; sizeof(BitmapData) = 24, 32
         , NumPut(     width, BitmapData,  0,   "uint") ; Width
         , NumPut(    height, BitmapData,  4,   "uint") ; Height
         , NumPut( 4 * width, BitmapData,  8,    "int") ; Stride
         , NumPut(   0xE200B, BitmapData, 12,    "int") ; PixelFormat
         , NumPut(     pBits, BitmapData, 16,    "ptr") ; Scan0
      DllCall("gdiplus\GdipBitmapLockBits"
               ,    "ptr", pBitmap
               ,    "ptr", &Rect
               ,   "uint", 5            ; ImageLockMode.UserInputBuffer | ImageLockMode.ReadOnly
               ,    "int", 0xE200B      ; Format32bppPArgb
               ,    "ptr", &BitmapData) ; Contains the pointer (pBits) to the hbm.
      DllCall("gdiplus\GdipBitmapUnlockBits", "ptr", pBitmap, "ptr", &BitmapData)

      ; Cleanup the hBitmap and device contexts.
      DllCall("SelectObject", "ptr", hdc, "ptr", obm)
      DllCall("DeleteDC",     "ptr", hdc)

      return hbm
   }

   put_base64(ByRef pBitmap, file := "", Quality := "") {
      ; Thanks noname - https://www.autohotkey.com/boards/viewtopic.php?style=7&p=144247#p144247

      if !(file ~= "(?i)bmp|dib|rle|jpg|jpeg|jpe|jfif|gif|tif|tiff|png")
         file := "png"
      Extension := "." file

      DllCall("gdiplus\GdipGetImageEncodersSize", "uint*",nCount, "uint*",nSize)
      VarSetCapacity(ci, nSize)
      DllCall("gdiplus\GdipGetImageEncoders", "uint",nCount, "uint",nSize, "ptr",&ci)
      if !(nCount && nSize)
         throw Exception("Could not get a list of image codec encoders on this system.")

      _nCount := (A_AhkVersion < 2) ? nCount : "nCount"
      Loop %_nCount%
      {
         sString := StrGet(NumGet(ci, (idx := (48+7*A_PtrSize)*(A_Index-1))+32+3*A_PtrSize), "UTF-16")
         if InStr(sString, "*" Extension)
            break
      }

      if !(pCodec := &ci+idx)
         throw Exception("Could not find matching encoder for specified file format.")

      if RegExMatch(Extension, "^\.(?i:JPG|JPEG|JPE|JFIF)$")
      {
         Quality := (Quality < 0) ? 0 : (Quality > 100) ? 90 : Quality ; Default JPEG is 90.
         DllCall("gdiplus\GdipGetEncoderParameterListSize", "ptr",pBitmap, "ptr",pCodec, "uint*",nSize)
         VarSetCapacity(EncoderParameters, nSize, 0)
         DllCall("gdiplus\GdipGetEncoderParameterList", "ptr",pBitmap, "ptr",pCodec, "uint",nSize, "ptr",&EncoderParameters)
         nCount := NumGet(EncoderParameters, "uint")
         N := (A_AhkVersion < 2) ? nCount : "nCount"
         Loop %N%
         {
            elem := (24+A_PtrSize)*(A_Index-1) + 4 + (pad := A_PtrSize = 8 ? 4 : 0)
            if (NumGet(EncoderParameters, elem+16, "uint") = 1) && (NumGet(EncoderParameters, elem+20, "uint") = 6)
            {
               p := elem+&EncoderParameters-pad-4
               NumPut(Quality, NumGet(NumPut(4, NumPut(1, p+0)+20, "uint")), "uint")
               break
            }
         }
      }

      DllCall("ole32\CreateStreamOnHGlobal", "ptr",0, "int",true, "ptr*",pStream)
      DllCall("gdiplus\GdipSaveImageToStream", "ptr",pBitmap, "ptr",pStream, "ptr",pCodec, "uint",p ? p : 0)
      DllCall("ole32\GetHGlobalFromStream", "ptr",pStream, "uint*",hData)
      pData := DllCall("GlobalLock", "ptr",hData, "ptr")
      nSize := DllCall("GlobalSize", "uint",pData)

      VarSetCapacity(bin, nSize, 0)
      DllCall("RtlMoveMemory", "ptr",&bin, "ptr",pData, "uptr",nSize)
      DllCall("GlobalUnlock", "ptr",hData)
      ObjRelease(pStream)
      DllCall("GlobalFree", "ptr",hData)

      ; Using CryptBinaryToStringA saves about 2MB in memory.
      DllCall("Crypt32.dll\CryptBinaryToStringA", "ptr",&bin, "uint",nSize, "uint",0x40000001, "ptr",0, "uint*",base64Length)
      VarSetCapacity(base64, base64Length, 0)
      DllCall("Crypt32.dll\CryptBinaryToStringA", "ptr",&bin, "uint",nSize, "uint",0x40000001, "ptr",&base64, "uint*",base64Length)
      VarSetCapacity(bin, 0)

      return StrGet(&base64, base64Length, "CP0")
   }

   gdiplusStartup() {
      this.gdiplus := (this.gdiplus == "") ? 1 : this.gdiplus + 1

      ; Startup gdiplus when counter goes from 0 -> 1 or "" -> 1.
      if (this.gdiplus == 1) {
         DllCall("LoadLibrary", "str", "gdiplus")
         VarSetCapacity(si, A_PtrSize = 8 ? 24 : 16, 0), si := Chr(1)
         DllCall("gdiplus\GdiplusStartup", "ptr*", pToken, "ptr", &si, "ptr", 0)
         this.pToken := pToken
      }
   }

   gdiplusShutdown(cotype := "", ByRef pBitmap := "") {
      this.gdiplus := this.gdiplus - 1

      ; When a buffer object is deleted a bitmap is sent here for disposal.
      if (cotype == "smart_pointer")
         if DllCall("gdiplus\GdipDisposeImage", "ptr", pBitmap)
            throw Exception("The bitmap of this buffer object has already been deleted.")

      ; Shutdown gdiplus if pToken is owned and when counter goes from 1 -> 0.
      if (this.gdiplus == 0) {
         DllCall("gdiplus\GdiplusShutdown", "ptr", this.pToken)
         DllCall("FreeLibrary", "ptr", DllCall("GetModuleHandle", "str", "gdiplus", "ptr"))

         ; Exit if GDI+ is still loaded. GdiplusNotInitialized = 18
         if (18 != DllCall("gdiplus\GdipCreateImageAttributes", "ptr*", ImageAttr)) {
            DllCall("gdiplus\GdipDisposeImageAttributes", "ptr", ImageAttr)
            return
         }

         ; Otherwise GDI+ has been truly unloaded from the script and objects are out of scope.
         if (cotype = "bitmap")
            throw Exception("Out of scope error. `n`nIf you wish to handle raw pointers to GDI+ bitmaps, add the line"
               . "`n`n`t`t" this.__class ".gdiplusStartup()`n`nor 'pToken := Gdip_Startup()' to the top of your script."
               . "`nYou can copy this message by pressing Ctrl + C.")
      }
   }
} ; End of ImagePut class.
