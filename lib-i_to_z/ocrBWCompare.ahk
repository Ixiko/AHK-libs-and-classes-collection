ocrBWCompare(recog, given, color, varia:=0) ;compare bmp patterns reduce collors to Black / White
{ Gdip_GetImageDimensions(given, w, h) 
  Loop h 
  { y:= A_Index-1
    Loop w
    { x:= A_Index-1
      if (Gdip_GetPixel(given, x, y) & 0xFFFFFF) != (PixelCompare(Gdip_GetPixel(recog, x, y), color, varia)? 0xFFFFFF: 0x000000)
        return 0 ;fail  
  } }
  return 1 ;success
} ;===============================================