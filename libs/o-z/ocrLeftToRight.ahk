val:=1000000000, buyItemPrice:= 0
      mis:=10 
      loop 10
      { bmp:= Gdip_BitmapFromScreen(mX "|" mY "|5|7") ;get pattern 
        d:= ocrGetDigit(bmp, 0xFFFF00, 50)            ;recognize YELOW digit
        Gdip_DisposeImage(bmp)
        if d != "", buyItemPrice += d*val             ;value := digit * order
        else mis--                                    ;else count miss
        val //= 10                                    ;integer division
        mX += (mod(A_Index, 3) == 1)? 9: 6            ;if "," +9 else +6  
      }
      len:= StrLen(buyItemPrice)