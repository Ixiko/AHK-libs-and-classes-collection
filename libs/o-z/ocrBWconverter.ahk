ocrBWConvert(ByRef bmp, color, varia:=0) ;convert bmp pattern to Black / White pattern 
{ Gdip_GetImageDimensions(bmp, w, h)
  Loop h 
  { y:=A_Index-1
    Loop w
    { x:= A_Index-1
      Gdip_SetPixel(bmp, x, y, PixelCompare(Gdip_GetPixel(bmp, x, y), color, varia)? 0xFFFFFFFF: 0xFF000000)
  } }
  return bmp 
} ;===============================================