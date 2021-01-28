;###################################
; BC39_2PDF - function - by AHK_fan
;-----------------------------------
;===Description=========================================================================
;[function]  BC29_2PDF
;Author:		AHK_fan
;Contact:	
;Version:	1.0
;Link:		https://www.autohotkey.com/boards/viewtopic.php?f=10&t=60096

;====== License ======
;You can non-commercialy use and redistribute BC39_2PDF if put 2 things in your product's documentation or "About MsgBox": 
;			1) credit to the author, 
;			2) link to BC39_2PDF's AutoHotkey forum post. 
;	Author is not responsible for any damages arising from use or redistribution of his work. If redistributed in source form, 
;	you are not allowed to remove comments from this file. If you are interested in commercial usage, contact the author to get permission for it.

; v1	2018-12-12
; 
;-----------------------------------
;	Function based on 	https://www.pdflabs.com/tools/gnu-barcode-plus-pdf/
;		
;	BCText		= your Barcode Numbers or text
;	BCHeight 	= heigth of Barcode stripes
;	KordXBC 	= distance in [mm] from left side (PDF has ZeroPoint on left/upper side)
;	KordYBC		= distance in [mm] from upper side
;	PathNamePDF	= destination path without \
;	FileNamePDF	= destination Filename with extension .PDF
;	TextString	= optionally a text
;	KordXText	= distance in [mm] from left side (PDF has ZeroPoint on left/upper side)
;	KordYText	= distance in [mm] from upper side
;	TextHeight	= heigth in points
;	TextWidth	= width in points
;	Xmodul		= Modulo () https://de.wikipedia.org/wiki/Code_39
;	NRatio		= Ratio () https://de.wikipedia.org/wiki/Code_39
;	Orientation	= 1 = Portrait / 2 = Landscape
;	PageSize	= 1 = DIN A4 / 2 = DIN A3
;	WriteFile	= 1 = write
;	Overwrite	= 1 = overwrite if file exiist
;	OpenMyFile	= open after write with standard pdf viewer
;	StampPDFTK	= 1 = stamp (create a stamp on existing pdf file)
;	Path2ndPDF	= path to PDF file to stamp
;	PathPDFTK	= path to pdftk.exe (https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/)
;
;	barcode := BC39_2PDF(BCText, BCHeight, KordXBC, KordYBC, PathNamePDF, FileNamePDF, TextString, KordXText, KordYText, TextHeight, TextWidth, Xmodul, NRatio, Orientation, PageSize, WriteFile, Overwrite, OpenMyFile, StampPDFTK, Path2ndPDF, PathPDFTK)
;###################################
BC39_2PDF(BCText, BCHeight, AbstandXStart, AbstandYBC, PathNamePDF, FileNamePDF, TextString, KordXText, KordYText, TextHeight:=8, TextWidth:=8, Xmodul:=0.5, NRatio:=3.6, Ausr1:=1, PageSize:=1, WriteFile:=1, Overwrite:=0, OpenMyFile:=0, StampPDFTK:=1, Path2ndPDF:="", PathPDFTK:="pdftk.exe"){
Var01 :=	"000110100"
Var11 := 	"100100001"
Var21 :=	"001100001"
Var31 :=	"101100000"
Var41 :=	"000110001"
Var51 :=	"100110000"
Var61 :=	"001110000"
Var71 :=	"000100101"
Var81 :=	"100100100"
Var91 :=	"001100100"
VarA1 :=	"100001001"
VarB1 :=	"001001001"
VarC1 :=	"101001000"
VarD1 :=	"000011001"
VarE1 :=	"100011000"
VarF1 :=	"001011000"
VarG1 :=	"000001101"
VarH1 :=	"100001100"
VarI1 :=	"001001100"
VarJ1 :=	"000011100"
VarK1 :=	"100000011"
VarL1 :=	"001000011"
VarM1 :=	"101000010"
VarN1 :=	"000010011"
VarO1 :=	"100010010"
VarP1 :=	"001010010"
VarQ1 :=	"000000111"
VarR1 :=	"100000110"
VarS1 :=	"001000110"
VarT1 :=	"000010110"
VarU1 :=	"110000001"
VarV1 :=	"011000001"
VarW1 :=	"111000000"
VarX1 :=	"010010001"
VarY1 :=	"110010000"
VarZ1 :=	"011010000"
VarMinus1 	:=	"010000101"
VarDot1 	:=	"110000100"
VarSpace1 	:=	"011000100"
VarStar1 	:=	"010010100"
VarDollar1 	:=	"010101000"
VarSlash1 	:=	"010100010"
VarPlus1 	:=	"010001010"
VarProcent1 :=	"000101010"

if PageSize > 2
	PageSize = 2
if PageSize = 1			; A4
{
	if Ausr1 = 1			; portrait
	{
		Orientation := "[ 0 0 595 842 ]"
		YPageSize := 842
	}
	else					; landscape
	{
		Orientation := "[ 0 0 842 595 ]"
		YPageSize := 595	
	}
}
if PageSize = 2
{
	if Ausr1 = 1			; portrait
	{
		Orientation := "[ 0 0 842 1684 ]"
		YPageSize := 1684
	}
	else					; landscape
	{
		Orientation := "[ 0 0 1684 842 ]"
		YPageSize := 842
	}
}


pdfstart =
(
`%PDF-1.5
`%âãÏÓ
1 0 obj
<<
/Type /Font
/Subtype /Type1
/BaseFont /Courier
/Encoding /WinAnsiEncoding
/FirstChar 32
/LastChar 255
/FontDescriptor 2 0 R
/Widths [600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600]
>>
endobj
2 0 obj
<<
/Type /FontDescriptor
/FontName /Courier
/FontFamily (Courier)
/FontStretch /Normal
/FontWeight 400
/StemH 51
/StemV 51
/Ascent 629
/Descent -157
/Flags 35
/XHeight 426
/ItalicAngle 0
/FontBBox [-23 -250 715 805]
/CapHeight 562
>>
endobj
3 0 obj
<<
/ProcSet [/PDF /Text]
/ExtGState 
<<
/GS1
<<
/Type /ExtGState
/SA false
/SM 0.02
/OPM 1
/OP false
/op false
>>
>>
/Font
<<
/Courier 1 0 R
>>
>>
endobj
4 0 obj
<< >>
stream
q
0 g

)
;############################
pdfende =
(
endstream
endobj
5 0 obj
<< /Type /Page /Parent 6 0 R /MediaBox %Orientation% /Contents 4 0 R /Resources 3 0 R >>
endobj
6 0 obj
<< /Type /Pages /Count 1 /Kids [ 5 0 R ] >>
endobj
7 0 obj
<< /Type /Catalog /Pages 6 0 R >>
endobj
xref
0 8
0000000000 65535 f 
0000000015 00000 n 
0000001066 00000 n 
0000001315 00000 n 
0000001477 00000 n 
0000001650 00000 n 
0000001756 00000 n 
0000001815 00000 n 
trailer
<< /Root 7 0 R /Size 8 >>
startxref
1864
`%`%EOF
)
textstart =
(

/Courier %TextHeight% Tf
)
textende =
(
ET
Q
`% End barcode for "%TextString%"
)
if StampPDFTK = 1
{
	If !FileExist(PathPDFTK)
	{
		msgbox, 16, BarcodeCreator, PDFTK not found
		return
	}
	else
	{
		PathNamePDFSave := PathNamePDF
		PathNamePDF := A_ScriptDir
		FileNamePDFSave := FileNamePDF
		FileNamePDF := "temp.pdf"
		If FileExist(PathNamePDF "\" FileNamePDF)
			FileDelete, %PathNamePDF%\%FileNamePDF%
	}
}	

if Overwrite = 0
{
	If FileExist(PathNamePDF "\" FileNamePDF)
	{
		msgbox, 16, BarcodeCreator, File exist! Overwrite not allowed
		return
	}
}
else
{
	FileDelete, %PathNamePDF%\%FileNamePDF%
	If WriteFile = 1
		FileAppend, %pdfstart%, %PathNamePDF%\%FileNamePDF%
}


; Text
StringUpper, BCText, BCText
Schmall := Xmodul
Breit := Xmodul * Nratio
LTrennl := Xmodul
AbstandX := Round(AbstandXStart * 2.83333333333)
AbstandYBC := YPageSize - (Round(AbstandYBC * 2.83333333333))
BCText := "*" . BCText . "*"
ergebnis :=
laenge := strlen(BCText)
	loop, %laenge%
	{
		NewStr := SubStr(BCText, A_Index , 1)
		IfInString, NewStr, -
			NewStr := "Minus"
		IfInString, NewStr, .
			NewStr := "Dot"
		IfInString, NewStr, A_Space
			NewStr := "Space"
		IfInString, NewStr, *
			NewStr := "Star"
		IfInString, NewStr, $
			NewStr := "Dollar"			
		IfInString, NewStr, /
			NewStr := "Slash"
		IfInString, NewStr, +
			NewStr := "Plus"
		IfInString, NewStr, `%
			NewStr := "Procent"
		VarNeu = Var%NewStr%1
		Transform, VarNeuN, deref, %VarNeu%
		VarNeuNeu = % %VarNeuN%
		loop, 9
		{
			NewStr2 := SubStr(VarNeuNeu, A_Index , 1)
			If Mod(A_Index, 2)
				UnGerade := 1
			Else
				UnGerade := 2
			;UnGerade := OddEven(A_index)
			If UnGerade = 1
			{
				;schwarze linien
				if NewStr2 = 1
				{
					; dicke schwarze linie
					ergebnis .= (AbstandX) . " " . AbstandYBC . " " . Breit . " " . BCHeight . " re" . Chr(13) . Chr(10)
					AbstandX := AbstandX + Breit
				}	
				else
				{
					; dünne schwarze linie
					ergebnis .= (AbstandX) . " " . AbstandYBC . " " . Schmall . " " . BCHeight . " re" . Chr(13) . Chr(10)
					AbstandX := AbstandX + Schmall
				}
			}
			else
			{
				;weisse Linie
				if NewStr2 = 1
				{
					; dicke weisse linie
					AbstandX := AbstandX + Breit
				}
				else
				{
					; dünne weisse linie
					AbstandX := AbstandX + Schmall

				}
			}
		}
	AbstandX := AbstandX + LTrennl
	}

	ergebnis := ergebnis . "f" . Chr(13) . Chr(10) . "BT" . Chr(13) . Chr(10)
If WriteFile = 1
	FileAppend, %ergebnis%`r`n, %PathNamePDF%\%FileNamePDF%
textvariable := 
If TextString <>
{
	
	KordXText := Round(KordXText * 2.83333333333)
	KordYText := YPageSize - (Round(KordYText * 2.83333333333))
	If WriteFile = 1
		FileAppend, %textstart%`r`n, %PathNamePDF%\%FileNamePDF%
	laenge2 := strlen(TextString)
	loop, %laenge2%
	{
		NewStr2 := SubStr(TextString, A_Index , 1)
		textvariable .= " 1 0 0 1 " . KordXText . " " . KordYText . " Tm (" . NewStr2 . ") Tj" . Chr(13) . Chr(10)
		KordXText := KordXText + TextWidth
	}
	If WriteFile = 1
	{	
		FileAppend, %textvariable%, %PathNamePDF%\%FileNamePDF%
		FileAppend, %textende%`r`n, %PathNamePDF%\%FileNamePDF%
	}
}
If WriteFile = 1
	FileAppend, %pdfende%`r`n, %PathNamePDF%\%FileNamePDF%
ErgebnisAlles := pdfstart . ergebnis .textstart . textvariable . textende . pdfende
if StampPDFTK = 1
{
;msgbox, hier:%PathPDFTK%/%Path2ndPDF%/pfad:%PathNamePDF% Datei:%FileNamePDF% outpu %PathNamePDFSave%\%FileNamePDFSave%
;clipboard = %PathPDFTK% %Path2ndPDF% stamp %PathNamePDF%\%FileNamePDF% output %PathNamePDFSave%\%FileNamePDFSave%
	RunWait, %comspec% /c ""%PathPDFTK%" "%Path2ndPDF%" "stamp" "%PathNamePDF%\%FileNamePDF%" "output" "%PathNamePDFSave%\%FileNamePDFSave%" "dont_ask"" , , hide
	While ! FileExist(PathNamePDFSave "\" FileNamePDFSave)
	{
		Sleep 300
		i := i + 1
		if i = 15
		{
			MsgBox, 16, BarcodeCreator, No Resultfile %FileNamePDFSave% found
			return
		}
	}
	PathNamePDF := PathNamePDFSave
	FileNamePDF := FileNamePDFSave
}
If FileExist(A_ScriptDir "\temp.pdf")
	FileDelete, %A_ScriptDir%\temp.pdf
If OpenMyFile = 1
	run, %PathNamePDF%\%FileNamePDF%
return ergebnis
}