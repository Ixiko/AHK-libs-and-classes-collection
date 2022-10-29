Pens := [], Brushes := [], Fonts := []
GuiSize := 600
Gui, +hWndhWnd -Caption
hDC := DllCall("GetDC", "UPtr", hWnd, "UPtr")
hMemDC := DllCall("CreateCompatibleDC", "UPtr", hDC, "UPtr")
hBitmap := DllCall("CreateCompatibleBitmap", "UPtr", hDC, "Int", GuiSize, "Int", GuiSize, "UPtr")
hOriginalBitmap := DllCall("SelectObject", "UPtr", hMemDC, "UPtr", hBitmap)
OnExit, ExitSub
OnMessage(0xF, "WM_PAINT")
Gui, Color, Black
Gui, Show, w%GuiSize% h%GuiSize%

Data =
(
20:Graph of I over V through a resistor:Voltage (V):Current (mA)
0.000:0.000
0.198:0.387
0.400:0.781
0.600:1.172
0.802:1.566
1.003:1.962
1.200:2.349
1.402:2.735
1.597:3.122
1.798:3.505
2.002:3.918
2.202:4.314
2.399:4.681
2.603:5.074
2.800:5.485
2.997:5.864
3.198:6.256
3.400:6.631
3.597:7.017
3.801:7.435
)

Data := StrSplit(Data, StrSplit("`r`n"), "`r`n")
Labels := StrSplit(Data.Remove(1), ":")
for Index, Point in Data
	Data[Index] := StrSplit(Point, ":")

SumX := 0, SumY := 0
for each, Point in Data
	SumX += Point[1], SumY += Point[2]

SetLine(hMemDC, 0, GuiSize, GuiSize, GuiSize - (SumY/SumX*GuiSize), 0xFF)

for each, Point in Data
	SetRectangle(hMemDC, Point[1]*50-1, GuiSize - (Point[2]*50-1), 3, 3, 0xFFFFFF)


SetText(hMemDC, GuiSize/2, 0, Labels[2], 0xFF00FF, "Verdana", 20, "CT") ; Title
SetText(hMemDC, GuiSize/2, GuiSize, Labels[3], 0xFF00FF, "Verdana", 20, "CB") ; X Axis
SetText(hMemDC, 0, GuiSize/2-10, Labels[4], 0xFF00FF, "Verdana", 20) ; Y Axis
BitBlt(hDC, 0, 0, GuiSize, GuiSize, hMemDC)
return

GuiEscape:
GuiClose:
ExitApp
return

ExitSub:
DeleteObjects(Pens), DeleteObjects(Brushes), DeleteObjects(Fonts)
DllCall("SelectObject", "UPtr", hMemDC, "UPtr", hOriginalBitmap)
DllCall("DeleteObject", "UPtr", hBitmap)
DllCall("DeleteObject", "UPtr", hMemDC)
DllCall("ReleaseDC", "UPtr", hWnd, "UPtr", hDC)
ExitApp
return

GetBrush(Color)
{
	global Brushes
	if !Brushes.HasKey(Color)
		Brushes[Color] := DllCall("CreateSolidBrush", "UInt", Color, "UPtr")
	return Brushes[Color]
}

GetPen(Color)
{
	global Pens
	if !Pens.HasKey(Color)
		Pens[Color] := DllCall("CreatePen", "Int", 0, "Int", 0, "UInt", Color, "UPtr") ;PS_SOLID
	return Pens[Color]
}

WM_PAINT(wParam, lParam, Msg, hWnd)
{
	global hDC, GuiSize, hMemDC
	
	BitBlt(hDC, 0, 0, GuiSize, GuiSize, hMemDC)
}

SetPixel(hDC, x, y, Color)
{
	DllCall("SetPixelV", "UPtr", hDC, "Int", x, "Int", y, "UInt", Color)
}

SetRectangle(hDC, x, y, w, h, Color)
{
	if (w == 1 && h == 1)
		return SetPixel(hDC, x, y, Color)
	
	hPen := GetPen(Color)
	hBrush := GetBrush(Color)
	
	; Replace the original pen and brush with our own
	hOriginalPen := DllCall("SelectObject", "UPtr", hDC, "UPtr", hPen, "UPtr")
	hOriginalBrush := DllCall("SelectObject", "UPtr", hDC, "UPtr", hBrush, "UPtr")
	
	DllCall("Rectangle", "UPtr", hDC, "Int", x, "Int", y, "Int", x+w, "Int", y+h)
	
	; Reselect the original pen and brush
	DllCall("SelectObject", "UPtr", hDC, "UPtr", hOriginalPen, "UPtr")
	DllCall("SelectObject", "UPtr", hDC, "UPtr", hOriginalBrush, "UPtr")
}

BitBlt(hDC, x, y, w, h, hSrcDC)
{
	DllCall("BitBlt", "UPtr", hDC, "Int", x, "Int", y, "Int", w, "Int", h, "UPtr", hSrcDC, "Int", 0, "Int", 0, "UInt", 0xCC0020) ;SRCCOPY
}

SetLine(hDC, x, y, x2, y2, Color)
{
	hPen := GetPen(Color)
	DllCall("MoveToEx", "UPtr", hDC, "Int", x, "Int", y, "UPtr", 0)
	hOriginalPen := DllCall("SelectObject", "UPtr", hDC, "UPtr", hPen, "UPtr")
	DllCall("LineTo", "UPtr", hDC, "Int", x2, "Int", y2)
	DllCall("SelectObject", "UPtr", hDC, "UPtr", hOriginalPen, "UPtr")
}

SetText(hDC, x, y, Text, Color, Typeface, Height, Align="LC", Weight=500, Style=0)
{
	AlignV := {"C": 24, "B": 8, "T": 0} ; TA_BASELINE, TA_BOTTOM, TA_TOP
	AlignH := {"L": 0, "C": 6, "R": 2} ; TA_LEFT, TA_CENTER, TA_RIGHT
	Align := StrSplit(Align)
	DllCall("SetTextAlign", "UPtr", hDC, "UInt", AlignH[Align[1]] | AlignV[Align[2]])
	
	TA_BASELINE=24
	TA_BOTTOM=8
	TA_CENTER=6
	TA_LEFT=0
	TA_MASK=(TA_BASELINE + TA_CENTER + TA_UPDATECP)
	TA_NOUPDATECP=0
	TA_RIGHT=2
	TA_RTLREADING=256
	TA_TOP=0
	TA_UPDATECP=1
	
	hFont := GetFont(Typeface, Height, Weight, Style)
	
	DllCall("SetTextColor", "UPtr", hDC, "UInt", Color)
	hOriginalFont := DllCall("SelectObject", "UPtr", hDC, "UPtr", hFont, "UPtr")
	
	DllCall("TextOut", "UPtr", hDC, "Int", x, "Int", y, "Str", Text, "Int", StrLen(Text))
	
	DllCall("SelectObject", "UPtr", hDC, "UPtr", hOriginalFont, "UPtr")
}

DeleteObjects(Objects)
{
	for each, hObject in Objects
		DllCall("DeleteObject", "UPtr", hObject)
	Objects := []
}

GetFont(Typeface, Height, Weight, Style=0)
{
	global Fonts
	if !Fonts[Typeface, Height, Weight, Style]
		Fonts[Typeface, Height, Weight, Style] := DllCall("CreateFont"
	,"Int", Height ;height
	,"Int", 0 ;width
	,"Int", 0 ;angle of string (0.1 degrees)
	,"Int", 0 ;angle of each character (0.1 degrees)
	,"Int", Weight ;font weight
	,"UInt", Style&1 ;font italic
	,"UInt", Style&2 ;font underline
	,"UInt", Style&4 ;font strikeout
	,"UInt", 1 ;DEFAULT_CHARSET: character set
	,"UInt", 0 ;OUT_DEFAULT_PRECIS: output precision
	,"UInt", 0 ;CLIP_DEFAULT_PRECIS: clipping precision
	,"UInt", 4 ;ANTIALIASED_QUALITY: output quality
	,"UInt", 0 ;DEFAULT_PITCH | (FF_DONTCARE << 16): font pitch and family
	,"Str", Typeface ;typeface name
	,"UPtr")
	return Fonts[Typeface, Height, Weight, Style]
}