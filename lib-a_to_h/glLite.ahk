glShadeModel(mode="smooth")
{
  static _mode := {flat:0x1D00, smooth:0x1D01}
  DllCall("opengl32\glShadeModel", "uint", _mode[mode])
}

glClearColor(r, g, b, a=1)
{
  DllCall("opengl32\glClearColor", "float", r, "float", g, "float", b, "float", a)
}

glClear(bits*)
{
  _bits := {depth:0x0100, color:0x4000}
  flags := 0
  for i, b in bits
    flags |= (_bits[b]) ? _bits[b] : 0
  DllCall("opengl32\glClear", "uint", flags)
}

glBegin(mode=9)
{
  static _mode := {points:0, lines:1, "line-loop":2, "line-strip":3, triangles:4, "triangle-strip":5, "triangle-fan":6, quads:7, "quad-strip":8, polygon:9}
  DllCall("opengl32\glBegin", "uint", _mode[mode])
}

glEnd()
{
  DllCall("opengl32\glEnd")
}

glVertex(x=0, y=0, z=0)
{
  DllCall("opengl32\glVertex3f", "float", x, "float", y, "float", z)
}

glColor(r, g, b, a=1)
{
  DllCall("opengl32\glColor4f", "float", r, "float", g, "float", b, "float", a)
}

glTexCoord(s, t, r=0, q=1)
{
  DllCall("opengl32\glTexCoord4f", "float", s, "float", t, "float", r, "float", q)
}

glLoadIdentity()
{
  DllCall("opengl32\glLoadIdentity")
}

glTranslate(x=0, y=0, z=0)
{
  DllCall("opengl32\glTranslatef", "float", x, "float", y, "float", z)
}

glRotate(angle, x=0, y=0, z=0)
{
  DllCall("opengl32\glRotatef", "float", angle, "float", x, "float", y, "float", z)
}

glScale(x=1, y=1, z=1)
{
  DllCall("opengl32\glScalef", "float", x, "float", y, "float", z)
}

glLoadTexture(texid, filename, bgR=0, bgG=0, bgB=0, bgA=1)
{
  if (!fileexist(filename) || !texid)
    return 0
  DllCall("LoadLibrary", "str", "gdiplus")
  VarSetCapacity(bGdipStartInput, 12+A_PtrSize, 0)
  NumPut(1, bGdipStartInput, 0, "uint")
  DllCall("gdiplus\GdiplusStartup", "ptr*", GdipToken, "ptr", &bGdipStartInput, "ptr", 0)
  if (DllCall("gdiplus\GdipCreateBitmapFromFile", "wstr", filename, "ptr*", pBitmap)!=0)
  {
    DllCall("gdiplus\GdiplusShutdown", "ptr", GdipToken)
    return 0
  }
  DllCall("gdiplus\GdipGetImageWidth", "ptr", pBitmap, "uint*", w)
  DllCall("gdiplus\GdipGetImageHeight", "ptr", pBitmap, "uint*", h)
  DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "ptr", pBitmap, "ptr*", hBitmap, "uint", ((bgB*256)&0xFF) | (((bgG*256)&0xFF)<<8) | (((bgR*256)&0xFF)<<16) | (((bgA*256)&0xFF)<<24))
  DllCall("gdiplus\GdipDisposeImage", "ptr", pBitmap)
  DllCall("gdiplus\GdiplusShutdown", "ptr", GdipToken)
  if (!hBitmap)
    return 0
  
  hDC := DllCall("GetDC", "ptr", 0, "ptr")
  VarSetCapacity(data, w*h*4, 0)
  VarSetCapacity(bminfo, 40, 0)
  NumPut(40, bminfo, 0, "uint")
  DllCall("GetDIBits", "ptr", hDC, "ptr", hBitmap, "uint", 0, "uint", h, "ptr", 0, "ptr", &bminfo, "uint", 0)
  result := DllCall("GetDIBits", "ptr", hDC, "ptr", hBitmap, "uint", 0, "uint", h, "ptr", &data, "ptr", &bminfo, "uint", 0)
  DllCall("ReleaseDC", "ptr", 0, "ptr", hDC)
  DllCall("DeleteObject", "ptr", hBitmap)
  if (result=0)
    return 0
  
  DllCall("opengl32\glBindTexture", "uint", 0x0DE1, "uint", texid)
  DllCall("opengl32\glTexParameteri", "uint", 0x0DE1, "uint", 0x2801, "uint", 0x2601)
  DllCall("opengl32\glTexParameteri", "uint", 0x0DE1, "uint", 0x2800, "uint", 0x2601)
  DllCall("opengl32\glTexImage2D", "uint", 0x0DE1, "int", 0, "int", 4, "int", w, "int", h, "int", 0, "uint", 0x80E1, "uint", 0x1401, "ptr", &data)
  return texid
}

glBindTexture(texid)
{
  DllCall("opengl32\glBindTexture", "uint", 0x0DE1, "uint", texid)
}

glNewList(listid, mode="compile")
{
  static _mode := {compile:0x1300, "compile-and-execute":0x1301}
  DllCall("opengl32\glNewList", "uint", listid, "uint", _mode[mode])
}

glEndList()
{
  DllCall("opengl32\glEndList")
}

glCallList(listid)
{
  DllCall("opengl32\glCallList", "uint", listid)
}

glEnable(cap, enable=true)
{
  static _cap := {texture:0x0DE1, blend:0x0BE2}
  if (enable)
    DllCall("opengl32\glEnable", "uint", _cap[cap])
  else
    DllCall("opengl32\glDisable", "uint", _cap[cap])
}

glDisable(cap, disable=true)
{
  glEnable(cap, !disable)
}

glBlendFunc(src, dst)
{
  static _dst := {zero:0, one:1, "src-color":0x0300, "one-minus-src-color":0x0301, "src-alpha":0x0302, "one-minus-src-alpha":0x0303, "dst-alpha":0x0304, "one-minus-dst-alpha":0x0305}
  static _src := {zero:0, one:1, "dst-color":0x0306, "one-minus-dst-color":0x0307, "alpha-saturate":0x0308, "src-alpha":0x0302, "one-minus-src-alpha":0x0303, "dst-alpha":0x0304, "one-minus-dst-alpha":0x0305}
  DllCall("opengl32\glBlendFunc", "uint", _src[src], "uint", _dst[dst])
}

glLineWidth(width)
{
  DllCall("opengl32\glLineWidth", "float", width)
}