; SGDIPrint-library
; Simple GDI-Printing library for AHK_L (32bit & 64bit compatible)
; by Zed_Gecko
; thanks to: engunneer, Lexikos, closed, controlfreak, just me, fincs, tic
; Requires tics GDI+ Library unless you use bare GDI printing (means printing directly on the printer-DC)
; http://www.autohotkey.com/forum/viewtopic.php?t=32238
; with GDI+ you can either draw directly on the printer (SGDIPrint_printerfriendlyGraphicsFromHDC) or
; draw on a matching bitmap first (SGDIPrint_GetMatchingBitmap) which you copy later to the printer,
; 	which allows to  preview the print and to save it to file 
; 	but it uses more resources & time, and the printing result may differ from "direct"-printing
;---------------------------------------------------------------
; Functions:
; SGDIPrint_GDIPStartup()						Start GDI+
; SGDIPrint_EnumPrinters()						Get List of Printer Names
; SGDIPrint_GetDefaultPrinter()					Get default-Printer Name
; SGDIPrint_GetHDCfromPrinterName()				Get GDI DC from Printer Name
; SGDIPrint_GetHDCfromPrintDlg()				Get GDI DC from user-dialog
; SGDIPrint_GetMatchingBitmap()					Get a GDI+ Bitmap matching to print-out size
; SGDIPrint_DeleteBitmap()						deletes a GDI+ Bitmap
; SGDIPrint_BeginDocument() 					starts the GDI-print-session
; SGDIPrint_printerfriendlyGraphicsFromBitmap()	creates GDI+ graphic 
; SGDIPrint_CopyBitmapToPrinterHDC()			copies a GDI+ Bitmap to a matching printer GDI DC
; SGDIPrint_printerfriendlyGraphicsFromHDC() 	creates GDI+ graphic 
; SGDIPrint_TextFillUpRect()					fills up a rectangle on a GDI+ graphic with text
; SGDIPrint_DeleteGraphics()					deletes GDI+ graphic 
; SGDIPrint_NextPage()							starts new page in the GDI-print-session
; SGDIPrint_EndDocument()						ends the GDI-print-session
; SGDIPrint_AbortDocument()						aborts the GDI-print-session
;
; SGDIPrint_GDIPShutdown()						End GDI+
;-----------
; Global Vars
; SGDIPrint_GetHDCfromPrinterName() and SGDIPrint_GetHDCfromPrintDlg() create the folowing global vars:
; 	SGDIPrint_HDC_Orientation	Page Orientation:  PORTRAIT = 1  LANDSCAPE = 2
; 	SGDIPrint_HDC_Color			Color-Printing.Mode:  B/W = 1  COLOR = 2
; 	SGDIPrint_HDC_Copies		the number of copies you or user selected [integer]
; 	SGDIPrint_HDC_Width 		Width in pixel
; 	SGDIPrint_HDC_Height		Height in pixel
; 	SGDIPrint_HDC_xdpi			X resolution in DPI
; 	SGDIPrint_HDC_ydpi			Y resolution in DPI

;---------------------------------------------------------------
; Uncomment if Gdip.ahk is not in your standard library
#Include, Gdip.ahk




; SGDIPrint_GDIPStartup inits GDI+ or terminates the script when GDI+ is not availiable
; you can call Gdip_Startup directly if you prefer.
SGDIPrint_GDIPStartup()
{
	If !pToken := Gdip_Startup()
	{
		MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
		ExitApp
	}
	return %pToken%
}



; SGDIPrint_EnumPrinters retrieves a LineFeed-delimited List of NAMES of available printers 
; use this or SGDIPrint_GetDefaultPrinter() to get a valid printer-name for SGDIPrint_GetHDCfromPrinterName()
SGDIPrint_EnumPrinters()
{
PRINTER_ENUM_NAME := 0x8
NULL := ""
Level := 4
pcbNeeded := 0
pcReturned := 0
out := DllCall("Winspool.drv\EnumPrinters", "UInt", PRINTER_ENUM_NAME, "Str", NULL, "UInt", Level, "Ptr", 0, "UInt", 0, "UIntP", pcbNeeded, "UIntP", pcReturned)
pcbGranted := VarSetCapacity(pPrinterEnum , pcbNeeded)

out := DllCall("Winspool.drv\EnumPrinters", "UInt", PRINTER_ENUM_NAME, "Str", NULL, "UInt", Level, "Ptr", &pPrinterEnum, "UInt", pcbGranted, "UIntP", pcbNeeded, "UIntP", pcReturned)
loop, %pcReturned%
{
	Offset := (A_Index - 1) * (A_PtrSize * 3)
	pName := StrGet(Numget(pPrinterEnum, 0 + Offset))
	Namelist .= ((A_Index = 1)? "" : "`n") . pName
}
VarSetCapacity(pPrinterEnum, 0)
return %Namelist%
}



; SGDIPrint_GetDefaultPrinter retrieves the NAME of the default printer
; use this or SGDIPrint_EnumPrinters() to get a valid printer-name for SGDIPrint_GetHDCfromPrinterName()
SGDIPrint_GetDefaultPrinter()
{
	Null := ""
	DllCall("winspool.drv\GetDefaultPrinter", "Ptr", NULL, "UintP", nSize)
	if A_IsUnicode
		nSize := VarSetCapacity(gPrinter, nSize*2)
	else
		nSize := VarSetCapacity(gPrinter, nSize)
	DllCall("winspool.drv\GetDefaultPrinter", "Str", gPrinter, "UintP", nSize)
	Defaultprinter := gPrinter
	Return %Defaultprinter%
}



; SGDIPrint_GetHDCfromPrinterName returns a GDI DC-Handle for the printer specified by NAME
;  and sets global Vars SGDIPrint_HDC_Orientation , SGDIPrint_HDC_Color , SGDIPrint_HDC_Copies
;  SGDIPrint_HDC_Width , SGDIPrint_HDC_Height (both in pixel) , SGDIPrint_HDC_xdpi , SGDIPrint_HDC_ydpi (both resolution in DPI)
;  with the optional parameters dmOrientation , dmColor , dmCopies you can change the default values used by the printer:
;	Orientation: PORTRAIT = 1  LANDSCAPE = 2
;	Color: B/W = 1  COLOR = 2
;	Copies: any number of copies you want [integer]
SGDIPrint_GetHDCfromPrinterName(pPrinterName, dmOrientation = 0, dmColor = 0, dmCopies = 0)
{
	global SGDIPrint_HDC_Orientation
	global SGDIPrint_HDC_Color
	global SGDIPrint_HDC_Copies
	global SGDIPrint_HDC_Width 
	global SGDIPrint_HDC_Height
	global SGDIPrint_HDC_xdpi
	global SGDIPrint_HDC_ydpi
	

	MainhWnd := A_ScriptHwnd
	
	NULL := ""
	
	VarSetCapacity(pPrinter , A_PtrSize, 0)
	out := DllCall("Winspool.drv\OpenPrinter", "Ptr", &pPrinterName, "PtrP", pPrinter, "UInt", NULL, "Ptr")

	sizeDevMode := DllCall("Winspool.drv\DocumentProperties", "Ptr", MainhWnd, "Ptr", pPrinter, "Ptr", &pPrinterName, "Ptr", 0, "Ptr", 0, "UInt", 0, "Int")

	VarSetCapacity(pDevModeOutput , sizeDevMode, 0)
	out2 := DllCall("Winspool.drv\DocumentProperties", "Ptr", MainhWnd, "Ptr", pPrinter, "Ptr", &pPrinterName, "Ptr", &pDevModeOutput, "Ptr", 0, "UInt", 2, "Int")
     
	if ((dmOrientation = 1)||(dmOrientation = 2))
		NumPut(dmOrientation, pDevModeOutput, 44, "Short")
	if dmCopies is integer
	{   
		if (dmCopies > 0)
			NumPut(dmCopies, pDevModeOutput, 54, "Short")
	}
	if ((dmColor = 1)||(dmColor = 2))
		NumPut(dmColor, pDevModeOutput, 60, "Short")

	out3 := DllCall("Winspool.drv\DocumentProperties", "Ptr", MainhWnd, "Ptr", pPrinter, "Ptr", &pPrinterName, "Ptr", &pDevModeOutput, "Ptr", &pDevModeOutput, "UInt", 10, "Int")	
	
	dmOrientation := NumGet(pDevModeOutput, 44, "Short")
	dmCopies := NumGet(pDevModeOutput, 54, "Short")
	dmColor := NumGet(pDevModeOutput, 60, "Short")

	DllCall("ClosePrinter", "Ptr", pPrinter)
	
	hDc :=  DllCall("Gdi32.dll\CreateDC", "Str", NULL, "Ptr", &pPrinterName, "Str", NULL, "Ptr", &pDevModeOutput, "Ptr")
	
	SGDIPrint_HDC_Orientation := dmOrientation
	SGDIPrint_HDC_Color := dmColor
	SGDIPrint_HDC_Copies := dmCopies
	
	VarSetCapacity(pDevModeOutput , 0)
	VarSetCapacity(pPrinter , 0)
	
	; Determine the size of the printable area in pixels:
	SGDIPrint_HDC_Width := DllCall("Gdi32.dll\GetDeviceCaps","Ptr",hDC,"int",8)
	SGDIPrint_HDC_Height := DllCall("Gdi32.dll\GetDeviceCaps","Ptr",hDC,"int",10)

	; Determine the resolution of the printer in pixels per inch:
	SGDIPrint_HDC_xdpi := DllCall("Gdi32.dll\GetDeviceCaps","Ptr",hDC,"int",0x58)
	SGDIPrint_HDC_ydpi := DllCall("Gdi32.dll\GetDeviceCaps","Ptr",hDC,"int",0x5A)
	
	return %hDc%
}
	

; SGDIPrint_GetHDCfromPrintDlg returns a GDI DC-Handle for the printer selected by the user  in a dialog-window
;  and sets global Vars SGDIPrint_HDC_Orientation , SGDIPrint_HDC_Color , SGDIPrint_HDC_Copies
;  SGDIPrint_HDC_Width , SGDIPrint_HDC_Height (both in pixel) , SGDIPrint_HDC_xdpi , SGDIPrint_HDC_ydpi (both resolution in DPI)
SGDIPrint_GetHDCfromPrintDlg()
{
	global SGDIPrint_HDC_Orientation
	global SGDIPrint_HDC_Color
	global SGDIPrint_HDC_Copies
	global SGDIPrint_HDC_Width 
	global SGDIPrint_HDC_Height
	global SGDIPrint_HDC_xdpi
	global SGDIPrint_HDC_ydpi

	DllCall("LoadLibrary","str","comdlg32.dll")

	pdstructsize :=  (A_PtrSize = 4) ? 66 : 120
	VarSetCapacity(PRINTDIALOG_STRUCT,pdstructsize,0)
	NumPut(pdstructsize,PRINTDIALOG_STRUCT, "UInt")

	PD_HIDEPRINTTOFILE := 0x00100000 
	PD_NOPAGENUMS := 0x00000002 
	PD_NOSELECTION := 0x00000004 
	PD_RETURNDC :=0x100
	PD_USEDEVMODECOPIESANDCOLLATE := 0x40000
	PD_Flags := PD_NOPAGENUMS + PD_NOSELECTION + PD_RETURNDC + PD_HIDEPRINTTOFILE + PD_USEDEVMODECOPIESANDCOLLATE
	NumPut(PD_Flags,PRINTDIALOG_STRUCT, A_PtrSize * 5)

	if !DllCall("comdlg32\PrintDlg","Ptr",&PRINTDIALOG_STRUCT)
		return

	if (hDevNames := NumGet(PRINTDIALOG_STRUCT,A_PtrSize * 3))
		DllCall("GlobalFree","Ptr",hDevNames)
  
	if (hDevModeOutput := NumGet(PRINTDIALOG_STRUCT, A_PtrSize * 2))
	{ 
		pDevModeOutput := DllCall("GlobalLock", "Ptr", hDevModeOutput)
		dmOrientation := NumGet(pDevModeOutput + 0, 44, "Short")
		dmCopies := NumGet(pDevModeOutput + 0, 54, "Short")
		dmColor := NumGet(pDevModeOutput + 0, 60, "Short")
		DllCall("GlobalFree","Ptr",hDevModeOutput)
	}

   ; Get the newly created printer device context.
   if !(hDC := NumGet(PRINTDIALOG_STRUCT,A_PtrSize * 4))
      return

	SGDIPrint_HDC_Orientation := dmOrientation
	SGDIPrint_HDC_Color := dmColor
	SGDIPrint_HDC_Copies := dmCopies
	VarSetCapacity(PRINTDIALOG_STRUCT , 0)
	
	; Determine the size of the printable area in pixels:
	SGDIPrint_HDC_Width := DllCall("Gdi32.dll\GetDeviceCaps","Ptr",hDC,"int",8)
	SGDIPrint_HDC_Height := DllCall("Gdi32.dll\GetDeviceCaps","Ptr",hDC,"int",10)

	; Determine the resolution of the printer in pixels per inch:
	SGDIPrint_HDC_xdpi := DllCall("Gdi32.dll\GetDeviceCaps","Ptr",hDC,"int",0x58)
	SGDIPrint_HDC_ydpi := DllCall("Gdi32.dll\GetDeviceCaps","Ptr",hDC,"int",0x5A)
	
	return %hDC%
}


; SGDIPrint_GetMatchingBitmap returns a GDI+ Bitmap matching the current printers page-size with white background
; you need to call SGDIPrint_GetHDCfromPrintDlg or SGDIPrint_GetHDCfromPrinterName first to
; init the global width&height vars
SGDIPrint_GetMatchingBitmap(width = "g", height = "g", color = 0xFFFFFF)
{
	global SGDIPrint_HDC_Width 
	global SGDIPrint_HDC_Height
	if (width = "g")
		width := SGDIPrint_HDC_Width
	if (height = "g")
		height := SGDIPrint_HDC_Height

	pBitmap := Gdip_CreateBitmap(width, height)
;	set background-color (default is white)
	G := Gdip_GraphicsFromImage(pBitmap)
	DllCall("gdiplus.dll\GdipSetPageUnit","Ptr",G,"int",2)
	Gdip_SetSmoothingMode(G, 4)	
	pBrush := Gdip_BrushCreateSolid(0xffffffff)
	Gdip_FillRectangle(G, pBrush, 0, 0, width, height) 
	Gdip_DeleteBrush(pBrush)	
	Gdip_DeleteGraphics(G)
	return %pBitmap%
}



; SGDIPrint_DeleteBitmap deletes a GDI+ Bitmap
SGDIPrint_DeleteBitmap(pBitmap)
{
	Gdip_DisposeImage(pBitmap)
	return
}



; SGDIPrint_BeginDocument starts the GDI-print-session and the first page
;  returns a value > 0 on success
SGDIPrint_BeginDocument(hDC, Document_Name)
{
	VarSetCapacity(DOCUMENTINFO_STRUCT,(A_PtrSize * 4) + 4,0), 
	NumPut((A_PtrSize * 4) + 4, DOCUMENTINFO_STRUCT) 
	NumPut(&Document_Name,DOCUMENTINFO_STRUCT,A_PtrSize)

	if DllCall("Gdi32.dll\StartDoc","Ptr",hDC,"Ptr",&DOCUMENTINFO_STRUCT,"int") > 0
    	out := DllCall("Gdi32.dll\StartPage","Ptr",hDC,"int")
    return %out%
}


; SGDIPrint_printerfriendlyGraphicsFromBitmap returns a GDI+ graphic object with printerfriendly preformatting
SGDIPrint_printerfriendlyGraphicsFromBitmap(pBitmap)
{
	G := Gdip_GraphicsFromImage(pBitmap)
	DllCall("gdiplus.dll\GdipSetPageUnit","Ptr",G,"int",2)
	Gdip_SetSmoothingMode(G, 4)	
	Gdip_SetInterpolationMode(G, 7)
	return %G%
}


; SGDIPrint_CopyBitmapToPrinterHDC copies a GDI+ Bitmap on a matching Printer HDC
SGDIPrint_CopyBitmapToPrinterHDC(pBitmap, hDC)
{
	global SGDIPrint_HDC_Width 
	global SGDIPrint_HDC_Height
	PG := SGDIPrint_printerfriendlyGraphicsFromHDC(hDC)
	Gdip_DrawImage(PG, pBitmap, 0, 0, SGDIPrint_HDC_Width, SGDIPrint_HDC_Height)
	SGDIPrint_DeleteGraphics(PG)
	return
}



; SGDIPrint_printerfriendlyGraphicsFromHDC returns a GDI+ graphic object with printerfriendly preformatting
SGDIPrint_printerfriendlyGraphicsFromHDC(hDC)
{      
	G := Gdip_GraphicsFromHDC(hDC)
	; The default unit of measurement in this case appears to be UnitDisplay.
	; Change it to UnitPixel, or our drawing will be off.
	DllCall("gdiplus.dll\GdipSetPageUnit","Ptr",G,"int",2)
	; Set the smoothing mode to antialias = 4 to make shapes appear smother (only used for vector drawing and filling)
	Gdip_SetSmoothingMode(G, 4)
	; Interpolation mode has been set to HighQualityBicubic = 7
	Gdip_SetInterpolationMode(G, 7)
	return %G%
}



;SGDIPrint_TextFillUpRect(G, Text, xpos, ypos, Width, Height, Font, Style, Align, sizeinpoints, Color, tabstoplist)
;SGDIPrint_TextFillUpRect fills up a rectangle (on GDI+ graphic) with text and returns the part of the text that did not fit.
;supports (configurable) tab-stops and word/page-wraps only on word boundaries
;--parameters--- 
; G = GDI+ Graphic Handle
; Text = text to print
; xpos, ypos, Width, Height = position and size of the rectangle to be filled. default is the whole page
; Font = the name of an existing font. default is Arial
; Style = a number (0-15) defining the font-style. default is regular = 0. add up:
;         Bold := 1 , Italic := 2 , Underline := 4 , Strikeout := 8
; Align = a number (0-2) defining text-alignment. default is left = 0. choose one:
;         Left/Near := 0 , Center := 1 , Right/Far := 2
; sizeinpoints = font size in points(1 Point = ydpi / 72), like your Wordprocessor. default is 12
; Color = color of text in ARGB. default is black = 0xff000000
; tabstoplist = a variable list(delimiter = |) with  tab-stop-offsets in parts-per-hundred (%) of the rect-width
;         Each tab-stop offset, except the first one, is relative to the previous one. 
;         The first tab-stop offset is relative to the rect-boarder
;         default is "10|10|10|10|10|10|10|10|10", 9 TabStops at 10%,20%,...,80%,90% of the rect-width
;---------------------
SGDIPrint_TextFillUpRect(G, Text, xpos = 0, ypos = 0, Width = "full", Height = "full", Font = "Arial", Style = 0, Align = 0, sizeinpoints = 12, Color = 0xff000000, tabstoplist = "10|10|10|10|10|10|10|10|10")
{
	global SGDIPrint_HDC_Width 
	global SGDIPrint_HDC_Height
	global SGDIPrint_HDC_ydpi
	size := Round((SGDIPrint_HDC_ydpi / 72) * sizeinpoints)
	SingleBitPerPixelGridFit := 1
	Rendering := 3

	if !((Style >= 0) && (Style <= 15))
		Style := 0
	if !((Align >= 0) && (Align <= 2))
		Align := 0
	if Color is not number
		Color := 0xff000000
	if xpos is not number
		xpos := 0
	if ypos is not number
		ypos := 0
	if Width is not number
		Width := SGDIPrint_HDC_Width
	if Height is not number
		Height := SGDIPrint_HDC_Height
	if sizeinpoints is not number
		sizeinpoints := 12
		
	Loop, parse, tabstoplist, |
	{
		if (A_Index > 1)
			sanetabstoplist.= "|"
		if !((A_Loopfield > 0) && (A_Loopfield < 100))
			sanetabstoplist.= 10
		else
			sanetabstoplist.= A_Loopfield
		tabstopcount := A_Index
	}
	tabstoplist := sanetabstoplist
		
		
	hFamily := Gdip_FontFamilyCreate(Font)
	hFont := Gdip_FontCreate(hFamily, Size, Style)
	FormatStyle := 0x4000
	hFormat := Gdip_StringFormatCreate(FormatStyle)
	pBrush := Gdip_BrushCreateSolid(Color)
	 
	CreateRectF(RC, xpos, ypos, Width, Height)
	Gdip_SetStringFormatAlign(hFormat, Align)
	Gdip_SetTextRenderingHint(G, Rendering)
	
	
; possible 64bit problem, size of real-number = ptr-size?
	VarSetCapacity(tabstops, tabstopcount * 4)
	Loop, parse, tabstoplist, |
	{
		Sized_Loopfield := A_Loopfield * Width / 100
		NumPut(Sized_Loopfield, tabstops , (A_Index - 1) * 4, "float")		
	}	
	firstTabOffset := 0	
	a := DllCall("gdiplus\GdipSetStringFormatTabStops", "ptr", hFormat, "float", firstTabOffset, "int", tabstopcount, "ptr", &tabstops)
	
	
	VarSetCapacity(RC2, 16)
	DllCall("gdiplus\GdipMeasureString", "ptr", G
		, "wstr", Text, "int", -1, "ptr", hFont, "ptr", &RC, "ptr", hFormat, "ptr", &RC2, "uint*", Chars, "uint*", Lines)

	if (StrLen(Text) > Chars)
	{
		loop
		{
			NewStop := Chars + 2 - A_Index
			if (NewStop <= 0)
				break
			breakchar := SubStr(Text, Newstop , 1)
			if breakchar in %A_Space%,%A_Tab%,`n,`r
				break
		}
	}
	else
		NewStop := Chars
	StringLeft, NewText, Text, NewStop
	StringTrimLeft, Text, Text, NewStop


	E := Gdip_DrawString(G, NewText, hFont, hFormat, pBrush, RC)
	
	
	Gdip_DeleteBrush(pBrush)
	Gdip_DeleteStringFormat(hFormat)   
	Gdip_DeleteFont(hFont)
	Gdip_DeleteFontFamily(hFamily)

	
	return %Text% 
}	




; SGDIPrint_DeleteGraphics deletes the GDI+ graphic object
SGDIPrint_DeleteGraphics(G)
{
	Gdip_DeleteGraphics(G)
	return
}



; SGDIPrint_NextPage creates a new page in the current printer document
SGDIPrint_NextPage(hDC)
{
	DllCall("Gdi32.dll\EndPage","Ptr",hDC,"int")
	DllCall("Gdi32.dll\StartPage","Ptr",hDC,"int")
	return
}  



; SGDIPrint_EndDocument ends the printing session and deletes the DC
SGDIPrint_EndDocument(hDC)
{
	DllCall("Gdi32.dll\EndPage","Ptr",hDC,"int")
	DllCall("Gdi32.dll\EndDoc","Ptr",hDC)
	DeleteDC(hDC)
	return
}


; SGDIPrint_AbortDocument aborts the printing session and deletes the DC
SGDIPrint_AbortDocument(hDC)
{
	DllCall("Gdi32.dll\AbortDoc","Ptr",hDC)
	DeleteDC(hDC)
	return
}



; SGDIPrint_GDIPShutdown ends GDI+
; you can call Gdip_Shutdown directly if you prefer.
SGDIPrint_GDIPShutdown(pToken)
{
	Gdip_Shutdown(pToken)
	return
}

