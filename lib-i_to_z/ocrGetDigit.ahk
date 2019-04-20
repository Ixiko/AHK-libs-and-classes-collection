;try to recognize recBmp pattern compare to 0..9 given patterns 
ocrGetDigit(recBmp, color, varia)
{ static digBmp:= object(0,"", 1,"", 2,"", 3,"", 4,"", 5,"", 6,"", 7,"", 8,"", 9,"")
  static digIni ;static init bmps from file not work
  if !digIni     ;load bmps once till script exit
  { Loop 10
      digBmp[A_Index-1]:= Gdip_CreateBitmapFromFile(A_ScriptDir "\ocr\" A_Index-1 ".bmp")
    digIni:=1  
  }    
  Loop 10
    if ocrBWCompare(recBmp, digBmp[A_Index-1], color, varia), return A_Index-1
  return "" ;fail
} ;===============================================