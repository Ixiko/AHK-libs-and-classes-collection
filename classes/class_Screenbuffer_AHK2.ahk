; Title:   	ScreenBuffer - DirectX screen capture
; Link:   	autohotkey.com/boards/viewtopic.php?f=83&t=92622&sid=d9f7a369ff21f757b8d56b84bc28e61e
; Author:	iseahound
; Date:
; for:     	AHK_V2

/*
;#include ScreenBuffer.ahk

sb1 := ScreenBuffer.GDI()
sb2 := ScreenBuffer.DIRECTX9()
sb3 := ScreenBuffer.DIRECTX11()

MsgBox "Please watch a 60fps video or play a game during testing.`nPress OK to begin."
Sleep 2000 ; Minimize variance on start.

f := 60
DllCall("QueryPerformanceFrequency", "int64*", &frequency:=0)
DllCall("QueryPerformanceCounter", "int64*", &start:=0)
loop f
   sb1()
DllCall("QueryPerformanceCounter", "int64*", &end:=0)
a := f / ((end - start) / frequency)

DllCall("QueryPerformanceCounter", "int64*", &start:=0)
loop f
   sb2()
DllCall("QueryPerformanceCounter", "int64*", &end:=0)
b := f / ((end - start) / frequency)

DllCall("QueryPerformanceCounter", "int64*", &start:=0)
loop f
   sb3()
DllCall("QueryPerformanceCounter", "int64*", &end:=0)
c := f / ((end - start) / frequency)

DllCall("QueryPerformanceCounter", "int64*", &start:=0)
loop f
   sb3(0)
DllCall("QueryPerformanceCounter", "int64*", &end:=0)
d := f / ((end - start) / frequency)

MsgBox "GDI:`t"    Round(a, 2)   " fps"
   . "`nDX9:`t"    Round(b, 2)   " fps"
   . "`nDX11:`t"   Round(c, 2)   " fps"
   . "`nDX11 (uncapped):`t"   Round(d, 2)   " fps"
   . "`n`nTotal number of frames per test: " f

*/

class ScreenBuffer {

   static GDI() => this(1)
   static DIRECTX9() => this(9)
   static DIRECTX11() => this(11)

   __New(engine := 1) {
      this.engine := engine

      ; Get true virtual screen coordinates.
      dpi := DllCall("SetThreadDpiAwarenessContext", "ptr", -4, "ptr")
      sx := DllCall("GetSystemMetrics", "int", 76, "int")
      sy := DllCall("GetSystemMetrics", "int", 77, "int")
      sw := DllCall("GetSystemMetrics", "int", 78, "int")
      sh := DllCall("GetSystemMetrics", "int", 79, "int")
      DllCall("SetThreadDpiAwarenessContext", "ptr", dpi, "ptr")

      this.sx := sx
      this.sy := sy
      this.sw := sw
      this.sh := sh

      if (engine = 1)
         this.Init_GDI(sw, sh)

      if (engine = 9)
         this.Init_DIRECTX9()

      if (engine = 11)
         this.Init_DIRECTX11()

      ; Allocate a buffer and set the pointer and size.
      this.Update()

      ; Startup gdiplus.
      DllCall("LoadLibrary", "str", "gdiplus")
      si := Buffer(A_PtrSize = 4 ? 16:24, 0) ; sizeof(GdiplusStartupInput) = 16, 24
         NumPut("uint", 0x1, si)
      DllCall("gdiplus\GdiplusStartup", "ptr*", &pToken:=0, "ptr", si, "ptr", 0)

      ; Create a Bitmap with 32-bit pre-multiplied ARGB. (Owned by this object!)
      DllCall("gdiplus\GdipCreateBitmapFromScan0", "int", sw, "int", sh, "uint", 4 * sw, "uint", 0xE200B, "ptr", this.ptr, "ptr*", &pBitmap:=0)
      DllCall("gdiplus\GdipGetImageGraphicsContext", "ptr", pBitmap, "ptr*", &Graphics:=0)
      DllCall("gdiplus\GdipTranslateWorldTransform", "ptr", Graphics, "float", -sx, "float", -sy, "int", 0)

      this.pToken := pToken
      this.pBitmap := pBitmap
      this.Graphics := Graphics

      return this
   }

   __Delete() {
      DllCall("gdiplus\GdipDeleteGraphics", "ptr", this.Graphics)
      DllCall("gdiplus\GdipDisposeImage", "ptr", this.pBitmap)
      DllCall("gdiplus\GdiplusShutdown", "ptr", this.pToken)
      DllCall("FreeLibrary", "ptr", DllCall("GetModuleHandle", "str", "gdiplus", "ptr"))

      this.Cleanup()
   }

   __Item[x, y] {
      get => Format("0x{:X}", NumGet(this.ptr + 4*(y*this.sw + x), "uint"))
   }

   Call(p*) => this.Update(p*)

   Init_GDI(sw, sh) {
      ; struct BITMAPINFOHEADER - https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfoheader
      hdc := DllCall("CreateCompatibleDC", "ptr", 0, "ptr")
      bi := Buffer(40, 0)                    ; sizeof(bi) = 40
         NumPut(  "uint",        40, bi,  0) ; Size
         NumPut(   "int",        sw, bi,  4) ; Width
         NumPut(   "int",       -sh, bi,  8) ; Height - Negative so (0, 0) is top-left.
         NumPut("ushort",         1, bi, 12) ; Planes
         NumPut("ushort",        32, bi, 14) ; BitCount / BitsPerPixel
      hbm := DllCall("CreateDIBSection", "ptr", hdc, "ptr", bi, "uint", 0, "ptr*", &pBits:=0, "ptr", 0, "uint", 0, "ptr")
      obm := DllCall("SelectObject", "ptr", hdc, "ptr", hbm, "ptr")

      this.ptr := pBits
      this.size := 4 * sw * sh

      Update() {
         ; Retrieve a shared device context for the screen.
         static sdc := DllCall("GetDC", "ptr", 0, "ptr")

         ; Copies a portion of the screen to a new device context.
         DllCall("gdi32\BitBlt"
                  , "ptr", hdc, "int", 0, "int", 0, "int", sw, "int", sh
                  , "ptr", sdc, "int", 0, "int", 0, "uint", 0x00CC0020 | 0x40000000) ; SRCCOPY | CAPTUREBLT

         ; Remember to enable method chaining.
         return this
      }

      Cleanup() {
         DllCall("SelectObject", "ptr", hdc, "ptr", obm)
         DllCall("DeleteObject", "ptr", hbm)
         DllCall("DeleteDC",     "ptr", hdc)
      }

      this.Update := (*) => Update()
      this.Cleanup := (*) => Cleanup()
   }

   Init_DIRECTX9() {

      assert d3d := Direct3DCreate9(D3D_SDK_VERSION := 32), "Direct3DCreate9 failed."

      ComCall(IDirect3D9_GetAdapterDisplayMode := 8, d3d, "uint", D3DADAPTER_DEFAULT := 0, "ptr", D3DDISPLAYMODE := Buffer(16, 0))
      Windowed := true
      BackBufferCount := 1
      BackBufferHeight := NumGet(D3DDISPLAYMODE, 4, "uint")
      BackBufferWidth := NumGet(D3DDISPLAYMODE, 0, "uint")
      SwapEffect := 1 ; D3DSWAPEFFECT_DISCARD
      hDeviceWindow := WinExist("A")

      ; create device & capture surface
      D3DPRESENT_PARAMETERS := Buffer(48+2*A_PtrSize, 0)
         NumPut("uint",  BackBufferWidth, D3DPRESENT_PARAMETERS, 0)
         NumPut("uint", BackBufferHeight, D3DPRESENT_PARAMETERS, 4)
         NumPut("uint",  BackBufferCount, D3DPRESENT_PARAMETERS, 12)
         NumPut("uint",       SwapEffect, D3DPRESENT_PARAMETERS, 24)
         NumPut( "ptr",    hDeviceWindow, D3DPRESENT_PARAMETERS, 24+A_PtrSize)
         NumPut( "int",         Windowed, D3DPRESENT_PARAMETERS, 24+2*A_PtrSize)
      ComCall(IDirect3D9_CreateDevice := 16, d3d
               ,   "uint", D3DADAPTER_DEFAULT := 0
               ,   "uint", D3DDEVTYPE_HAL := 1
               ,    "ptr", 0 ; hFocusWindow
               ,   "uint", D3DCREATE_SOFTWARE_VERTEXPROCESSING := 0x00000020
               ,    "ptr", D3DPRESENT_PARAMETERS
               ,   "ptr*", &device:=0)
      ComCall(IDirect3DDevice9_CreateOffscreenPlainSurface := 36, device
               ,   "uint", BackBufferWidth
               ,   "uint", BackBufferHeight
               ,   "uint", D3DFMT_A8R8G8B8 := 21
               ,   "uint", D3DPOOL_SYSTEMMEM := 2
               ,   "ptr*", &surface:=0
               ,    "ptr", 0)

      Update(this) {
         ; get the data
         ComCall(IDirect3DDevice9_GetFrontBufferData := 33, device, "uint", 0, "ptr", surface)

         ; copy it into our buffers
         ComCall(IDirect3DSurface9_LockRect := 13, surface, "ptr", D3DLOCKED_RECT := Buffer(A_PtrSize*2), "ptr", 0, "uint", 0)
         pitch := NumGet(D3DLOCKED_RECT, 0, "int")
         pBits := NumGet(D3DLOCKED_RECT, A_PtrSize, "ptr")
         ComCall(IDirect3DSurface9_UnlockRect := 14, surface)

         this.ptr := pBits
         this.size := pitch * BackBufferHeight
      }

      Cleanup(this) {
         ObjRelease(surface)
         ObjRelease(device)
         ObjRelease(d3d)
      }

      Direct3DCreate9(SDKVersion) {
         if !DllCall("GetModuleHandle","str","d3d9")
            DllCall("LoadLibrary","str","d3d9")
         return DllCall("d3d9\Direct3DCreate9", "uint", SDKVersion, "ptr")
      }

      assert(statement, message) {
         if !statement
            throw ValueError(message, -1, statement)
      }

      this.Update := Update
      this.Cleanup := Cleanup
   }

   Init_DIRECTX11() {

      assert IDXGIFactory := CreateDXGIFactory(), "Create IDXGIFactory failed."

      loop {
         ComCall(IDXGIFactory_EnumAdapters := 7, IDXGIFactory, "uint", A_Index-1, "ptr*", &IDXGIAdapter:=0)

         loop {
            try ComCall(IDXGIAdapter_EnumOutputs := 7, IDXGIAdapter, "uint", A_Index-1, "ptr*", &IDXGIOutput:=0)
            catch OSError as e
               if e.number = 0x887A0002 ; DXGI_ERROR_NOT_FOUND
                  break
               else throw

            ComCall(IDXGIOutput_GetDesc := 7, IDXGIOutput, "ptr", DXGI_OUTPUT_DESC := Buffer(88+A_PtrSize, 0))
            Width             := NumGet(DXGI_OUTPUT_DESC, 72, "int")
            Height            := NumGet(DXGI_OUTPUT_DESC, 76, "int")
            AttachedToDesktop := NumGet(DXGI_OUTPUT_DESC, 80, "int")
            if (AttachedToDesktop = 1)
               break 2
         }
      }

      assert AttachedToDesktop, "No adapter attached to desktop."

      DllCall("D3D11\D3D11CreateDevice"
               ,    "ptr", IDXGIAdapter                 ; pAdapter
               ,    "int", D3D_DRIVER_TYPE_UNKNOWN := 0 ; DriverType
               ,    "ptr", 0                            ; Software
               ,   "uint", 0                            ; Flags
               ,    "ptr", 0                            ; pFeatureLevels
               ,   "uint", 0                            ; FeatureLevels
               ,   "uint", D3D11_SDK_VERSION := 7       ; SDKVersion
               ,   "ptr*", &d3d_device:=0               ; ppDevice
               ,   "ptr*", 0                            ; pFeatureLevel
               ,   "ptr*", &d3d_context:=0              ; ppImmediateContext
               ,"HRESULT")

      IDXGIOutput1 := ComObjQuery(IDXGIOutput, "{00cddea8-939b-4b83-a340-a685226666cc}")
      ComCall(IDXGIOutput1_DuplicateOutput := 22, IDXGIOutput1, "ptr", d3d_device, "ptr*", &Duplication:=0)
      ComCall(IDXGIOutputDuplication_GetDesc := 7, Duplication, "ptr", DXGI_OUTDUPL_DESC := Buffer(36, 0))
      DesktopImageInSystemMemory := NumGet(DXGI_OUTDUPL_DESC, 32, "uint")
      Sleep 50   ; As I understand - need some sleep for successful connecting to IDXGIOutputDuplication interface

      D3D11_TEXTURE2D_DESC := Buffer(44, 0)
         NumPut("uint",                            width, D3D11_TEXTURE2D_DESC,  0)   ; Width
         NumPut("uint",                           height, D3D11_TEXTURE2D_DESC,  4)   ; Height
         NumPut("uint",                                1, D3D11_TEXTURE2D_DESC,  8)   ; MipLevels
         NumPut("uint",                                1, D3D11_TEXTURE2D_DESC, 12)   ; ArraySize
         NumPut("uint", DXGI_FORMAT_B8G8R8A8_UNORM := 87, D3D11_TEXTURE2D_DESC, 16)   ; Format
         NumPut("uint",                                1, D3D11_TEXTURE2D_DESC, 20)   ; SampleDescCount
         NumPut("uint",                                0, D3D11_TEXTURE2D_DESC, 24)   ; SampleDescQuality
         NumPut("uint",         D3D11_USAGE_STAGING := 3, D3D11_TEXTURE2D_DESC, 28)   ; Usage
         NumPut("uint",                                0, D3D11_TEXTURE2D_DESC, 32)   ; BindFlags
         NumPut("uint", D3D11_CPU_ACCESS_READ := 0x20000, D3D11_TEXTURE2D_DESC, 36)   ; CPUAccessFlags
         NumPut("uint",                                0, D3D11_TEXTURE2D_DESC, 40)   ; MiscFlags
      ComCall(ID3D11Device_CreateTexture2D := 5, d3d_device, "ptr", D3D11_TEXTURE2D_DESC, "ptr", 0, "ptr*", &staging_tex:=0)


      ; Persist the concept of a desktop_resource as a closure???
      local desktop_resource

      Update(this, timeout := unset) {
         ; Unbind resources.
         Unbind()

         ; Allocate a shared buffer for all calls of AcquireNextFrame.
         static DXGI_OUTDUPL_FRAME_INFO := Buffer(48, 0)

         if !IsSet(timeout) {
            ; The following loop structure repeatedly checks for a new frame.
            loop {
               ; Ask if there is a new frame available immediately.
               try ComCall(IDXGIOutputDuplication_AcquireNextFrame := 8, Duplication, "uint", 0, "ptr", DXGI_OUTDUPL_FRAME_INFO, "ptr*", &desktop_resource:=0)
               catch OSError as e
                  if e.number = 0x887A0027 ; DXGI_ERROR_WAIT_TIMEOUT
                     continue
                  else throw

               ; Exclude mouse movement events by ensuring LastPresentTime is greater than zero.
               if NumGet(DXGI_OUTDUPL_FRAME_INFO, 0, "int64") > 0
                  break

               ; Continue the loop by releasing resources.
               ObjRelease(desktop_resource)
               ComCall(IDXGIOutputDuplication_ReleaseFrame := 14, Duplication)
            }
         } else {
            try ComCall(IDXGIOutputDuplication_AcquireNextFrame := 8, Duplication, "uint", timeout, "ptr", DXGI_OUTDUPL_FRAME_INFO, "ptr*", &desktop_resource:=0)
            catch OSError as e
               if e.number = 0x887A0027 ; DXGI_ERROR_WAIT_TIMEOUT
                  return
               else throw

            if NumGet(DXGI_OUTDUPL_FRAME_INFO, 0, "int64") = 0
               return
         }

         ; map new resources.
         if (DesktopImageInSystemMemory = 1) {
            static DXGI_MAPPED_RECT := Buffer(A_PtrSize*2, 0)
            ComCall(IDXGIOutputDuplication_MapDesktopSurface := 12, Duplication, "ptr", DXGI_MAPPED_RECT)
            pitch := NumGet(DXGI_MAPPED_RECT, 0, "int")
            pBits := NumGet(DXGI_MAPPED_RECT, A_PtrSize, "ptr")
         }
         else {
            tex := ComObjQuery(desktop_resource, "{6f15aaf2-d208-4e89-9ab4-489535d34f9c}") ; ID3D11Texture2D
            ComCall(ID3D11DeviceContext_CopyResource := 47, d3d_context, "ptr", staging_tex, "ptr", tex)
            static D3D11_MAPPED_SUBRESOURCE := Buffer(8+A_PtrSize, 0)
            ComCall(ID3D11DeviceContext_Map := 14, d3d_context, "ptr", staging_tex, "uint", 0, "uint", D3D11_MAP_READ := 1, "uint", 0, "ptr", D3D11_MAPPED_SUBRESOURCE)
            pBits := NumGet(D3D11_MAPPED_SUBRESOURCE, 0, "ptr")
            pitch := NumGet(D3D11_MAPPED_SUBRESOURCE, A_PtrSize, "uint")
         }

         this.ptr := pBits
         this.size := pitch * height

         ; Remember to enable method chaining.
         return this
      }

      Unbind() {
         if IsSet(desktop_resource) && desktop_resource != 0 {
            if (DesktopImageInSystemMemory = 1)
               ComCall(IDXGIOutputDuplication_UnMapDesktopSurface := 13, Duplication)
            else
               ComCall(ID3D11DeviceContext_Unmap := 15, d3d_context, "ptr", staging_tex, "uint", 0)

            ObjRelease(desktop_resource)
            ComCall(IDXGIOutputDuplication_ReleaseFrame := 14, Duplication)
         }
      }

      Cleanup(this) {
         Unbind()
         ObjRelease(staging_tex)
         ObjRelease(duplication)
         ObjRelease(d3d_context)
         ObjRelease(d3d_device)
         IDXGIOutput1 := ""
         ObjRelease(IDXGIOutput)
         ObjRelease(IDXGIAdapter)
         ObjRelease(IDXGIFactory)
      }

      CreateDXGIFactory() {
         if !DllCall("GetModuleHandle", "str", "DXGI")
            DllCall("LoadLibrary", "str", "DXGI")
         if !DllCall("GetModuleHandle", "str", "D3D11")
            DllCall("LoadLibrary", "str", "D3D11")
         DllCall("ole32\CLSIDFromString", "wstr", "{7b7166ec-21c7-44ae-b21a-c9ae321ae369}", "ptr", riid := Buffer(16, 0), "HRESULT")
         DllCall("DXGI\CreateDXGIFactory1", "ptr", riid, "ptr*", &ppFactory:=0, "HRESULT")
         return ppFactory
      }

      assert(statement, message) {
         if !statement
            throw ValueError(message, -1, statement)
      }

      this.Update := Update
      this.Cleanup := Cleanup
   }

   Save(filepath) {
      return this.put_file(this.pBitmap, filepath)
   }

   Search() {
   }

   ; ScreenCoordinates(ByRef sx, ByRef sy, ByRef sw, ByRef sh) {
   put_file(pBitmap, filepath := "", quality := "") {
      ; Thanks tic - https://www.autohotkey.com/boards/viewtopic.php?t=6517

      ; Remove whitespace. Seperate the filepath. Adjust for directories.
      filepath := Trim(filepath)
      SplitPath filepath,, &directory, &extension, &filename
      if DirExist(filepath)
         directory .= "\" filename, filename := ""
      if (directory != "" && !DirExist(directory))
         DirCreate(directory)
      directory := (directory != "") ? directory : "."

      ; Validate filepath, defaulting to PNG. https://stackoverflow.com/a/6804755
      if !(extension ~= "^(?i:bmp|dib|rle|jpg|jpeg|jpe|jfif|gif|tif|tiff|png)$") {
         if (extension != "")
            filename .= "." extension
         extension := "png"
      }
      filename := RegExReplace(filename, "S)(?i:^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])$|[<>:|?*\x00-\x1F\x22\/\\])")
      if (filename == "")
         filename := FormatTime(, "yyyy-MM-dd HH꞉mm꞉ss")
      filepath := directory "\" filename "." extension

      ; Fill a buffer with the available encoders.
      DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", &count:=0, "uint*", &size:=0)
      ci := Buffer(size)
      DllCall("gdiplus\GdipGetImageEncoders", "uint", count, "uint", size, "ptr", ci)
      if !(count && size)
         throw Error("Could not get a list of image codec encoders on this system.")

      ; Search for an encoder with a matching extension.
      Loop count
         EncoderExtensions := StrGet(NumGet(ci, (idx:=(48+7*A_PtrSize)*(A_Index-1))+32+3*A_PtrSize, "uptr"), "UTF-16")
      until InStr(EncoderExtensions, "*." extension)

      ; Get the pointer to the index/offset of the matching encoder.
      if !(pCodec := ci.ptr + idx)
         throw Error("Could not find a matching encoder for the specified file format.")

      ; JPEG is a lossy image format that requires a quality value from 0-100. Default quality is 75.
      if (extension ~= "^(?i:jpg|jpeg|jpe|jfif)$"
      && IsInteger(quality) && 0 <= quality && quality <= 100 && quality != 75) {
         DllCall("gdiplus\GdipGetEncoderParameterListSize", "ptr", pBitmap, "ptr", pCodec, "uint*", &size:=0)
         EncoderParameters := Buffer(size, 0)
         DllCall("gdiplus\GdipGetEncoderParameterList", "ptr", pBitmap, "ptr", pCodec, "uint", size, "ptr", EncoderParameters)

         ; Search for an encoder parameter with 1 value of type 6.
         Loop NumGet(EncoderParameters, "uint")
            elem := (24+A_PtrSize)*(A_Index-1) + A_PtrSize
         until (NumGet(EncoderParameters, elem+16, "uint") = 1) && (NumGet(EncoderParameters, elem+20, "uint") = 6)

         ; struct EncoderParameter - http://www.jose.it-berater.org/gdiplus/reference/structures/encoderparameter.htm
         ep := EncoderParameters.ptr + elem - A_PtrSize                ; sizeof(EncoderParameter) = 28, 32
            NumPut(  "uptr",       1, ep)                              ; Must be 1.
            NumPut(  "uint",       4, ep, 20+A_PtrSize)                ; Type
            NumPut(  "uint", quality, NumGet(ep+24+A_PtrSize, "uptr")) ; Value (pointer)
      }

      ; Write the file to disk using the specified encoder and encoding parameters.
      Loop 6 ; Try this 6 times.
         if (A_Index > 1)
            Sleep (2**(A_Index-2) * 30)
      until (result := !DllCall("gdiplus\GdipSaveImageToFile", "ptr", pBitmap, "wstr", filepath, "ptr", pCodec, "uint", IsSet(ep) ? ep : 0))
      if !(result)
         throw Error("Could not save file to disk.")

      return filepath
   }
}