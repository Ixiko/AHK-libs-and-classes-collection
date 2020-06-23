#include ImagePut.ahk

ImageEqual(images*) {
   return ImageEqual.call(images*)
}

class ImageEqual extends ImagePut {

   call(images*) {
      if (images.Count() == 0)
         return false

      if (images.Count() == 1)
         return true

      this.gdiplusStartup()

      ; Convert the images to pBitmaps (byte arrays).
      for i, image in images {
         try type := this.DontVerifyImageType(image)
         catch
            try type := this.ImageType(image)
            catch { ; Not a valid image.
               result := false
               break
            }

         if (A_Index == 1) {
            pBitmap1 := this.toBitmap(type, image)
         } else {
            pBitmap2 := this.toBitmap(type, image)
            result := this.isBitmapEqual(pBitmap1, pBitmap2)
            DllCall("gdiplus\GdipDisposeImage", "ptr", pBitmap2)
            if (result)
               continue
            else {
               result := false
               break
            }
         }
      }

      DllCall("gdiplus\GdipDisposeImage", "ptr", pBitmap1)

      this.gdiplusShutdown()

      return result
   }

   isBitmapEqual(ByRef pBitmap1, ByRef pBitmap2, Format := 0x26200A) {
      ; Make sure both bitmaps are valid pointers.
      if !(pBitmap1 && pBitmap2)
         return false

      ; Check if pointers are identical.
      if (pBitmap1 == pBitmap2)
         return true

      ; The two bitmaps must be the same size.
      DllCall("gdiplus\GdipGetImageWidth", "ptr", pBitmap1, "uint*", Width1)
      DllCall("gdiplus\GdipGetImageWidth", "ptr", pBitmap2, "uint*", Width2)
      DllCall("gdiplus\GdipGetImageHeight", "ptr", pBitmap1, "uint*", Height1)
      DllCall("gdiplus\GdipGetImageHeight", "ptr", pBitmap2, "uint*", Height2)

      ; Match bitmap dimensions.
      if (Width1 != Width2 || Height1 != Height2)
         return false

      ; Create a RECT with the width and height and two empty BitmapData.
      VarSetCapacity(Rect, 16, 0)                    ; sizeof(Rect) = 16
         , NumPut(  Width1, Rect,  8,   "uint")      ; Width
         , NumPut( Height1, Rect, 12,   "uint")      ; Height

      ; Do this twice.
      while ((i++:=i?i:0) < 2) { ; for(int i = 0; i < 2; i++)

         ; Create a BitmapData structure.
         VarSetCapacity(BitmapData%i%, 16+2*A_PtrSize, 0) ; sizeof(BitmapData) = 24, 32

         ; Transfer the pixels to a read-only buffer. Avoid using a different PixelFormat.
         DllCall("gdiplus\GdipBitmapLockBits"
                  ,    "ptr", pBitmap%i%
                  ,    "ptr", &Rect
                  ,   "uint", 1            ; ImageLockMode.ReadOnly
                  ,    "int", Format       ; Format32bppArgb is fast.
                  ,    "ptr", &BitmapData%i%)

         ; Get Stride (number of bytes per horizontal line).
         Stride%i% := NumGet(BitmapData%i%,  8, "int")

         ; If the Stride is negative, clone the image to make it top-down; redo the loop.
         if (Stride%i% < 0) {
            DllCall("gdiplus\GdipCloneImage", "ptr", pBitmap%i%, "ptr*", pBitmapClone)
            DllCall("gdiplus\GdipDisposeImage", "ptr", pBitmap%i%) ; Permanently deletes.
            pBitmap%i% := pBitmapClone
            i-- ; "Let's go around again! Ha!" https://bit.ly/2AWWcM3
         }

         ; Get Scan0 (top-left first pixel).
         Scan0%i%  := NumGet(BitmapData%i%, 16, "ptr")
      }

      ; RtlCompareMemory preforms an unsafe comparison stopping at the first different byte.
      size := Stride1 * Height1
      byte := DllCall("ntdll\RtlCompareMemory", "ptr", Scan01+0, "ptr", Scan02+0, "uptr", size, "uptr")

      ; Unlock Bitmaps. Since they were marked as read only there is no copy back.
      DllCall("gdiplus\GdipBitmapUnlockBits", "ptr", pBitmap1, "ptr", &BitmapData1)
      DllCall("gdiplus\GdipBitmapUnlockBits", "ptr", pBitmap2, "ptr", &BitmapData2)

      ; Compare stopped byte.
      return (byte == size) ? true : false
   }
} ; End of ImageEqual class.
