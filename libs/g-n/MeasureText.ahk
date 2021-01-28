MsgBox % MeasureText(0,"	   ******** Listbox functions ******","Consolas",14, "italic") 


MeasureText(hwnd,text,Font,size, layout){ 
    
   If !pToken := Gdip_Startup() 
   { 
   MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system 
   ExitApp 
   } 
    
   HDC := GetDC(hwnd) 
   G := Gdip_GraphicsFromHDC(hdc) 

   If !hFamily := Gdip_FontFamilyCreate(Font) 
   { 
      MsgBox, 48, Font error!, The font you have specified does not exist on the system 
      ExitApp 
   } 

   hFont := Gdip_FontCreate(hFamily, size, layout) 
   hFormat := Gdip_StringFormatCreate(0x4000) 
    
   CreateRectF(RectF, 0, 0, 0, 0) 
   RECTF_STR := Gdip_MeasureString(G, text, hFont, hFormat, RectF) 
   StringSplit,RCI,RECTF_STR, | 
   Width := RCI3 
    
   Gdip_DeleteFont(hFont),Gdip_DeleteStringFormat(hFormat) 
   DeleteDC(hdc), Gdip_DeleteGraphics(G) 
    
   Gdip_Shutdown(pToken) 
   Return, Width 
} 