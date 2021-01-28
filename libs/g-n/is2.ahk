#include %A_ScriptDir%\..\lib-a_to_h\encodebin.ahk

OffscreenSnap(wid) {
  global snappixbuf, snapwidth, snapheight
  WinGetPos, , , snapwidth, snapheight, ahk_id %wid%
  bpp := 24
  bufsize := AllocateDIBBuf(snappixbuf, snapwidth, snapheight, bpp) ; our output bufer we want to fill
  MakeBitmapInfoHeader(bmi, snapwidth, snapheight, bpp) ; bmi encodes the desired (24bpp) format for our output buffer
  
  sdc := GetDC(wid)
  dc2 := CreateCompatibleDC(sdc)
  hbmp := CreateCompatibleBitmap(sdc, snapwidth, snapheight)
  oldobj := SelectObject(dc2, hbmp)
  ReleaseDC(wid, sdc)
  
  PrintWindow(wid, dc2) ; tell the window to paint itself into dc2
  GetDIBits(dc2, hbmp, 0, snapheight, &snappixbuf, bmi) ; suck the pixels out of the bitmap dc2
  
  SelectObject(dc2, oldobj) ; remove the bitmap from the device context
  DeleteObject(hbmp) ; delete the bitmap
  DeleteDC(dc2)  ; delete the device context
}

BlitSnap(wid) {
  global snappixbuf, snapwidth, snapheight
  bpp := 24
  WinGetPos, winx, winy, snapwidth, snapheight, ahk_id %wid%
  bufsize := AllocateDIBBuf(snappixbuf, snapwidth, snapheight, bpp)
  MakeBitmapInfoHeader(bmi, snapwidth, snapheight, bpp) ; bmi encodes the desired (24bpp) format for our output buffer
  
  sdc := GetDC(0)
  dc2 := CreateCompatibleDC(sdc)
  hbmp := CreateCompatibleBitmap(sdc, snapwidth, snapheight)
;  hbmp := CreateDIBSection(dc2, snapwidth, snapheight, 32)
  oldobj := SelectObject(dc2, hbmp)
  
  BitBlt(dc2, 0, 0, snapwidth, snapheight, sdc, winx, winy) ; use default operation
  ReleaseDC(0, sdc)

  GetDIBits(dc2, hbmp, 0, snapheight, &snappixbuf, bmi) ; suck the pixels out of the bitmap dc2
  
  SelectObject(dc2, oldobj)
  DeleteDC(dc2)
  DeleteObject(hbmp)
}

DIBGetPixel(ByRef dibbuf, dibwidth, dibheight, dibbpp, x, y, ByRef r, ByRef g, ByRef b) {
  bytesperpix := dibbpp//8
  linebytes := (dibwidth*bytesperpix + 3)//4 * 4 ; round up to the next multiple of 4 bytes
  b := NumGet(dibbuf, (dibheight-1-y)*linebytes+x*bytesperpix, "UChar")
  g := NumGet(dibbuf, (dibheight-1-y)*linebytes+x*bytesperpix+1, "UChar")
  r := NumGet(dibbuf, (dibheight-1-y)*linebytes+x*bytesperpix+2, "UChar")
}

LastSnapGetPixel(x, y, ByRef r, ByRef g, ByRef b) {
  global snappixbuf, snapwidth, snapheight
  DIBGetPixel(snappixbuf, snapwidth, snapheight, 24, x, y, r, g, b)
}

BoundsRelative(value, min, lim) { ; limit should be one greater than maximum legal value
  return value < 0 ? lim+value : min+value
}

SearchLastSnap(ByRef foundx, ByRef foundy, x1, y1, x2, y2, templaddr) {
  global snappixbuf, snapwidth, snapheight  
  static isearch24, first:=1
  if (first) {
    first := 0
    Base64Decode(isearch24, "i1QkIIPsJIA6AXQLuAIAAACDxCTCKAAPt0IDD7ZKAlOJRCQYVVZXi3wkSIvHK8"
    . "GLTCRQjVwIAQ+2QgGLTCREi/Er8ItEJEyNRAYBiUQkLItEJDyNdEADD7ZCBYhEJEwPtkIGiEQkPA"
    . "+2QgeIRCQSD7ZCCMHuAgP2iEQkUA+2QgkD9olcJDCIRCRIO/sPg48BAACLbCQ46wiNpCQAAAAAkI"
    . "lMJBg7TCQsD4NqAQAAD7ZEJEiLXCRAK9gPtkQkUCvfSw+v3gPBjQxAA92NRBkBiUQkKIpMJEw6SA"
    . "EPhRIBAACKTCQ8OggPhQYBAACKTCQSOkj/D4X5AAAAM8C5AQAAAIlMJCDHRCQcAAAAAGY7RCQkci"
    . "GLRCQYi1QkWItMJFyJAok5X15dM8Bbg8QkwigAkItUJFSFyQ+EtgAAAA+3RCQcjQRAilxCB40EQg"
    . "+2UAWIVCQWD7ZQBohUJBUPtlAIiFQkFA+2UAmKQAqIVCQTMtKIRCQXhMB2WoXJdFYPtkwkE4tEJE"
    . "ArwQ+2TCQUK8dID6/GD7bqA2wkGAPNi2wkOI0MSQPIOBwpjQQpdRKKTCQVOEgBdQmKTCQWOEgCdA"
    . "gzyYlMJCDrBItMJCD+wjpUJBdypotEJBxAiUQkHGY7RCQkD4JK////hckPhSX///+LVCRUi0wkGI"
    . "tEJChBg8ADiUwkGIlEJCg7TCQsD4LD/v//i0wkRItcJDBHO/sPgn/+//9fXl24AQAAAFuDxCTCKAA=")
  }
  
  x1 := BoundsRelative(x1, 0, snapwidth)
  y1 := BoundsRelative(y1, 0, snapheight)
  x2 := BoundsRelative(x2, 0, snapwidth)
  y2 := BoundsRelative(y2, 0, snapheight)
  searchwidth := x2-x1+1
  searchheight := y2-y1+1
  if (searchwidth < 0 || searchheight < 0) {
    MsgBox, search width: %searchwidth% `nsearch height: %searchheight% `nsnap width: %snapwidth% `nsnap height: %snapheight%`nx1 y1 x2 y2: %x1% %y1% %x2% %y2%
    return 0
  }
  rc := DllCall(&isearch24, "UInt", &snappixbuf, "UInt", snapwidth, "UInt", snapheight, "UInt", x1, "UInt", y1
  , "UInt", searchwidth, "UInt", searchheight, "UInt", templaddr, "UInt*", foundx, "UInt*", foundy)
  return rc
}

SaveLastSnap(filename) {
  global snappixbuf, snapwidth, snapheight
  
  bpp := 24
  hFile:=	DllCall("CreateFile", "UInt", &filename, "Uint", 0x40000000, "Uint", 0, "Uint", 0, "Uint", 2, "Uint", 0, "Uint", 0)
  
  ; need to calculate file size for bmp
  linebytes := (snapwidth*bpp + 7)//8 ; true for any bit depth, not just 24 and 32
  linebytes := (linebytes + 3)//4 * 4 ; round up to the next multiple of 4 bytes
  bufsize := linebytes*snapheight
  VarSetCapacity(head, 14)
  NumPut(0x4D42, head, 0, "UShort")   ; magic number
  NumPut(54+bufsize, head, 2, "UInt") ; file size
  NumPut(54, head, 10, "UInt")        ; offset to image bytes
  WriteFile(hfile, head, 14)

  MakeBitmapInfoHeader(bmi, snapwidth, snapheight, bpp)
  WriteFile(hfile, bmi, 40)
  
  WriteFile(hfile, snappixbuf, bufsize)
  DllCall("CloseHandle", "Uint", hFile)
}


; =========================  wrappers to make assembling them much simpler =========


; typical order of operations is something like this:
/*
wid := WinExist("YoVille on Facebook")
WinGetPos, , , winwidth, winheight, ahk_id %wid%
sdc := GetDC(wid)
dc2 := CreateCompatibleDC(sdc)
hbmp := CreateCompatibleBitmap(sdc, winwidth, winheight)
oldobj := SelectObject(dc2, hbmp)
VarSetCapacity(pixelbuf, 4*winwidth*winheight, 0)
PrintWindow(wid, dc2)
MakeBitmapInfoHeader(bmi, winwidth, -winheight)
GetDIBits(sdc, hbmp, 0, winheight, &pixelbuf, bmi)
SelectObject(dc2, oldobj)
DeleteObject(hbmp)
DeleteDC(dc2)
ReleaseDC(wid, sdc)
*/

GetDC(wid) {
  if (hdc := DllCall("GetDC", "UInt", wid)) {
    return hdc
  }
  MsgBox, GetDC: failed to get device context for window handle %wid%
  return hdc
}

CreateCompatibleDC(hdc1) {
  if (hdc2 := DllCall("CreateCompatibleDC", "UInt", hdc1)) {
    return hdc2
  }
  MsgBox, CreateCompatibleDC: failed to create compatible device context for dc %hdc1%
  return hdc
}

CreateCompatibleBitmap(hdc, width, height) {
  if (hbmp := DllCall("CreateCompatibleBitmap", "UInt", hdc, "Int", width, "Int", height)) {
    return hbmp
  }
  MsgBox, CreateCompatibleBitmap: failed to create compatible bitmap
  return hbmp
}

MakeBitmapInfoHeader(ByRef bi, width, height, bpp) {
  VarSetCapacity(bi, 40, 0)
  NumPut(40, bi)     ; size of the structure
  NumPut(width, bi, 4)  ; image width
  NumPut(height, bi, 8)  ; image height, positive means lines go bottom to top
  NumPut(1, bi, 12, "UShort")   ; planes, has to be 1
  NumPut(bpp, bi, 14, "UShort") ; bits per pixel
  NumPut(0, bi, 16)  ; zero means compression is BI_RGB, or uncompressed
}

AllocateDIBBuf(ByRef buf, width, height, bpp) {
  linebytes := (width*bpp + 7)//8 ; true for any bit depth, not just 24 and 32
  linebytes := (linebytes + 3)//4 * 4 ; round up to the next multiple of 4 bytes
  VarSetCapacity(buf, linebytes*height)
  return linebytes*height
}

CreateDIBSection(hDC, nW, nH, bpp, valuesptr="") {
  MakeBitmapInfoHeader(bi, nW, nH, bpp)
  if (hdib := DllCall("CreateDIBSection", "UInt", hDC, "UInt", &bi, "UInt", 0, "UIntP", valuesptr, "UInt", 0, "UInt", 0)) {
    return hdib
  }
  MsgBox, failed to create dib section for device context %hDC% with width and height %nW%x%nH%, ErrorLevel is %ErrorLevel%
  return hdib
}

SelectObject(hdc, hbmp) {
  if (oldobj := DllCall("SelectObject", "UInt", hdc, "UInt", hbmp)) {
    return oldobj
  }
  MsgBox, SelectObject: failed to select bitmap into device context %hdc%
  return oldobj
}

BitBlt(destDC, destx1, desty1, width, height, srcDC, srcx1, srcy1, operation=0x40CC0020) {
  return DllCall("BitBlt", "UInt", destDC, "Int", destx1, "Int", desty1, "Int", width, "Int", height, "UInt", srcDC, "Int", srcx1, "Int", srcy1, "Uint", operation)
}

PrintWindow(hwnd, hdc, flags=0) {
  return DllCall("PrintWindow", "UInt", hwnd, "UInt", hdc, "UInt", flags)
}

GetDIBits(hdc, hbmp, startline, numlines, dataptr, ByRef bmi) {
  if (lines := DllCall("GetDIBits", "UInt", hdc, "UInt", hbmp, "UInt", startline, "UInt", numlines, "UInt", dataptr, "UInt", &bmi, "UInt", 0)) {
    return lines
  }
  le := GetLastError()
  MsgBox, GetDIBits: failed to copy data to dataptr %dataptr%, lasterror is %le%
  return 0
}

DeleteObject(hobj) {
  return DllCall("DeleteObject", "UInt", hobj)
}

DeleteDC(hdc) {
  return DllCall("DeleteDC", "UInt", hdc)
}

ReleaseDC(hwnd, hdc) {
  return DllCall("ReleaseDC", "UInt", hwnd, "UInt", hdc)
}

WriteFile(hfile, ByRef data, nbytes) {
  nwritten := "abcd"
  if (DllCall("WriteFile", "UInt", hfile, "UInt", &data, "UInt", nbytes, "UInt*", nwritten, "UInt", 0)) {
    return nwritten
  }
  return 0
}

GetLastError() {
  return DllCall("GetLastError")
}