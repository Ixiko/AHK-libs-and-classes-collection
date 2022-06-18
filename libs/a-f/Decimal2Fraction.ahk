;{[Function] Decimal2Fraction and Fraction2Decimal
; Fanatic Guru
; 2013 12 21
; Version 1.9
;
; Function to Convert a Decimal Number to a Fraction String
;
;------------------------------------------------
;
; Method:
;   Decimal2Fraction(Decimal, Options)
;
;   Parameters:
;   1) {Decimal}         A decimal number to be converted to a fraction string
;   2) {Options ~= {Number}}    Round to this fractional Percision ie. 32 would round to the closest 1/32nd
;    {Options ~= {D}{Number}}  Round fractional to a {Number} limit of digits ie. D5 limits fraction to 5 digits
;    {Options ~= "I"}      Return Improper Fraction
;    {Options ~= "AA"}      Return in Architectural format with feet and inches
;    {Options ~= "A"}      Return in Architectural format with inches only
;       Optional
;
;
; Example:
;  MsgBox % Decimal2Fraction(1.2345)
;  MsgBox % Decimal2Fraction(1.2345,"I")
;  MsgBox % Decimal2Fraction(1.2345,"A")      ; Convert Decminal Inches to Inches Fraction/Inches"
;  MsgBox % Decimal2Fraction(1.2345,"AI")      ; Convert Decminal Inches to Fraction/Inches"
;  MsgBox % Decimal2Fraction(1.2345,"AA16")     ; Convert Decimal Feet to Feet'-Inches Fraction/16th Inches"
;  MsgBox % Decimal2Fraction(14.28571428571429,"D5")  ; Convert with round to a limit of 5 digit fraction
;  MsgBox % Decimal2Fraction(.28571428571429,"AAD5")  ; Convert Decimal Feet to Feet'-Inches Fraction/Inches" with round to a limit of 5 digit fraction

Decimal2Fraction(Decimal, Options := "" )
{
	FormatFloat := A_FormatFloat
	SetFormat, FloatFast, 0.15
	Whole := 0
	if (Options ~= "i)D")
		Digits := RegExReplace(Options,"\D*(\d*)\D*","$1"), (Digits > 15 ? Digits := 15 : )
	else
		Precision := RegExReplace(Options,"\D*(\d*)\D*","$1")
	if (Options ~= "i)AA")
		Feet := Floor(Decimal), Decimal -= Feet, Inches := Floor(Decimal* 12), Decimal := Decimal* 12 - Inches
	if !(Options ~= "i)I")
		Whole := Floor(Decimal), Decimal -= Whole
	RegExMatch(Decimal,"^(\d*)\.?(\d*?)0*$",Match), N := Match1 Match2
	D := 10** StrLen(Match2)
	if Precision
		N := Round(N / D* Precision), D := Precision
	Repeat_Digits:
	Original_N := N, Original_D := D 
	Repeat_Reduce:
	X := 0, Temp_D := D 
	while X != 1
		X := GCD(N,D), N := N / X, D := D / X
	if Digits
	{
		if (Temp_D = D and D > 1)
		{
			if Direction
				((N/ D < Decimal) ? N+= 1 : D += 1)
			else
				((N/ D > Decimal) ? N-= 1 : D -= 1)
			goto Repeat_Reduce
		}
		if !Direction
		{
			N_Minus := Floor(N), D_Minus := Floor(D), N := Original_N, D := Original_D, Direction := !Direction
			goto Repeat_Reduce
		}
		N_Plus := Floor(N), D_Plus := Floor(D)
		if (StrLen(D_Plus) <= Digits and StrLen(D_Minus) > Digits)
			N := N_Plus, D := D_Plus
		else if (StrLen(D_Minus) <= Digits and StrLen(D_Plus) > Digits)
			N := N_Minus, D := D_Minus
		else
			if (Abs(Decimal - (N_Plus / D_Plus)) < Abs(Decimal - (N_Minus / D_Minus)))
				N := N_Plus, D := D_Plus
			else
				N := N_Minus, D := D_Minus
		if (StrLen(D) > Digits)
		{
			Direction := 0
			goto Repeat_Digits
		}
	}
	if (D = 1 and !(Options ~= "i)Inches"))
	{
		if (Options ~= "i)AA")
		{
			Inches += N
			if (Inches = 12)
				Feet ++=, Inches := 0
		}
		else
			Whole += N
		N := 0
	}
	N := Floor(N)
	D := Floor(D)
	if (Options ~= "i)AA")
		Output := Feet "'-" Inches (N and D ? " " N "/" D:"")"""" 
	else
		Output := (Whole ? Whole " ":"") (N and D ? N "/" D:"")((Options ~= "i)A") ? """":"")
	SetFormat, FloatFast, %FormatFloat%
	return (Whole + N ? Trim(Output) : 0)
}

;{[Function] Fraction2Decimal
; Fanatic Guru
; 2013 12 18
; Version 1.6
;
; Function to Fraction String to a Decimal Number
;   Tries to account for any phrasing of feet and inches 
;------------------------------------------------
;
; Method:
;   Fraction2Decimal(Fraction, Unit)
;
;   Parameters:
;   1) {Fraction}     A string representing a fraction to be converted to a decimal number
;   2) {Unit} = true  Include feet or inch symbol in return
;    {Unit} = false   Do not include feet or inch symbol in return
;       Optional - Default to false
;
; Example:
;   MsgBox % Fraction2Decimal("7/8")
;   MsgBox % Fraction2Decimal("1 7/8")
;   MsgBox % Fraction2Decimal("1-7/8""") ; "" required to escape a literal " for testing
;   MsgBox % Fraction2Decimal("2'1-7/8""") ; "" required to escape a literal " for testing
;   MsgBox % Fraction2Decimal("2'-1 7/8""") ; "" required to escape a literal " for testing
;   MsgBox % Fraction2Decimal("2' 1"" 7/8") ; "" required to escape a literal " for testing
;

Fraction2Decimal(Fraction, Unit := false)
{
		FormatFloat := A_FormatFloat
	SetFormat, FloatFast, 0.15
		Num := {}
		N := 0
		D := 1
		if RegExMatch(Fraction, "^\s*-")
			Has_Neg := true
		if RegExMatch(Fraction, "i)feet|foot|ft|'")
			Has_Feet := true
		if RegExMatch(Fraction, "i)inch|in|""")
			Has_Inches := true
		if RegExMatch(Fraction, "i)/|of|div")
			Has_Fraction := true
		Output := Trim(Fraction,"""'")
		if Output is number
		{
			SetFormat, FloatFast, %FormatFloat%
			return Output (Unit ? (Has_Feet ? "'":(Has_Inches ? """":"")) : "")
		}
		RegExMatch(Fraction,"^[^\d\.]*([\d\.]*)[^\d\.]*([\d\.]*)[^\d\.]*([\d\.]*)[^\d\.]*([\d\.]*)",Match)
		Loop 4
			if !(Match%A_Index% = "")
				Num.Insert(Match%A_Index%)
		if Has_Fraction
		{
			N := Num[Num.MaxIndex()-1]
			D := Num[Num.MaxIndex()]
		}
		Output := (Num.MaxIndex() = 2 ? N / D : (Num[1]) + N / D)
		if (Has_Feet &  Has_Inches)
			if (Num.MaxIndex() = 2)
				Output := Num[1] + Num[2] /12
			else
				Output := Num[1] + ((Num.MaxIndex() = 3 ? 0:Num[2]) + N / D) / 12
		Output := (Has_Neg ? "-":"") (Output ~= "." ? RTrim(RTrim(Output,"0"),".") : Output) (Unit ? (Has_Feet ? "'":(Has_Inches ? """":"")) : "")
		SetFormat, FloatFast, %FormatFloat%
		return Output
}


GCD(A, B) 
{
	while B 
	B := Mod(A|0x0, A:=B)
	return A
}
