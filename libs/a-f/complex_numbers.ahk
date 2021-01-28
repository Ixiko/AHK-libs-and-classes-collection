; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=35809
; Author:	jeeswg
; Date:   	14.08.2017
; for:     	AHK_L

/*

	;note: this script puts a list of complex numbers onto the clipboard
	;note: the comments (algebra) can be pasted into (used with) wolframalpha.com
	;note: complex exponentiation is multi-valued (JEE_CPow only returns a single value)

	vPi := 3.141592653589793
	MsgBox, % JEE_CDisp(JEE_CAdd([1,2],[3,4])) ;(1+2i)+(3+4i)
	MsgBox, % JEE_CDisp(JEE_CSub([1,2],[3,4])) ;(1+2i)-(3+4i)
	MsgBox, % JEE_CDisp(JEE_CMul([1,2],[3,4])) ;(1+2i)*(3+4i)
	MsgBox, % JEE_CDisp(JEE_CDiv([1,2],[3,4])) ;(1+2i)/(3+4i)
	MsgBox, % JEE_CDisp(JEE_CPow([1,2],[3,4])) ;(1+2i)^(3+4i)
	MsgBox, % JEE_CDisp(JEE_CPow([Exp(1),0],[0,vPi])) ;e^((pi)i)
	MsgBox, % JEE_CDisp(JEE_CPow([0,1],[0,1])) ;i^i

	MsgBox, % JEE_CDisp(JEE_CConj([1,2])) ;conj(1+2i)
	MsgBox, % JEE_CDisp(JEE_CConj([3,4])) ;conj(3+4i)
	MsgBox, % JEE_CAbs([1,2]) " " JEE_CAbs([3,4]) ;abs(1+2i) abs(3+4i)
	MsgBox, % JEE_CArg([1,2]) " " JEE_CArg([3,4]) ;arg(1+2i) arg(3+4i)

	;test the JEE_CDisp function:
	vR := -5
	Loop, 21
	{
		vI := -5
		Loop, 21
		{
			vOutput .= JEE_CDisp([vR,vI]) "`r`n"
			vI += 0.5
		}
		vR += 0.5

	}
	Clipboard := vOutput
	MsgBox, % vOutput

*/

;==================================================

;key possibilities for JEE_CDisp to consider:
;if real part is 0/nonzero (e.g. real part: 3 or 0)
;if imag part is positive/negative/1/-1 (e.g. imag part: 3 or 1 or -3 or -1)
;[3]+[3]i	[3]i
;[3]+[]i	[]i
;[3][-3]i	[-3]i
;[3][-]i	[-]i

JEE_CDisp(obj2)
{
	local obj := obj2.Clone()
	;crop trailing zeros after decimal point (remove decimal point if required)
	if InStr(obj.1, ".")
		obj.1 := RegExReplace(obj.1, "\.0+$|\..*?\K0+$")
	if InStr(obj.2, ".")
		obj.2 := RegExReplace(obj.2, "\.0+$|\..*?\K0+$")

	if !obj.1 && !obj.2
		return 0
	else if !obj.2
		return obj.1
	else if !obj.1
		obj.1 := ""
	else if (obj.2 > 0)
		obj.1 .= "+"

	if (obj.2 = 1)
		return obj.1 "i"
	else if (obj.2 = -1)
		return obj.1 "-i"
	else
		return obj.1 obj.2 "i"
}

;==================================================

JEE_CAdd(obj1, obj2)
{
	return [obj1.1+obj2.1, obj1.2+obj2.2]
}

;==================================================

JEE_CSub(obj1, obj2)
{
	return [obj1.1-obj2.1, obj1.2-obj2.2]
}

;==================================================

JEE_CMul(obj1, obj2)
{
	;(a+bi)(c+di) = (ac-bd) + i(ad+bc)
	return [(obj1.1*obj2.1)-(obj1.2*obj2.2), (obj1.1*obj2.2)+(obj1.2*obj2.1)]
}

;==================================================

;Complex Division -- from Wolfram MathWorld
;http://mathworld.wolfram.com/ComplexDivision.html

JEE_CDiv(obj1, obj2)
{
	;real part: (ac+bd) / (c^2+d^2)
	;imag part: (-ad+bc) / (c^2+d^2)
	return [((obj1.1*obj2.1)+(obj1.2*obj2.2))/(obj2.1**2+obj2.2**2), ((-obj1.1*obj2.2)+(obj1.2*obj2.1))/(obj2.1**2+obj2.2**2)]
}

;==================================================

;Complex Exponentiation -- from Wolfram MathWorld
;http://mathworld.wolfram.com/ComplexExponentiation.html
;Complex number - Wikipedia
;https://en.wikipedia.org/wiki/Complex_number#Exponentiation

;note: complex exponentiation is multi-valued (JEE_CPow only returns a single value)
JEE_CPow(obj1, obj2)
{
	local a := obj1.1, b := obj1.2, c := obj2.1, d := obj2.2, vTemp, vR, vI
	vTemp := ((a**2+b**2)**(c/2))*Exp(-d*JEE_CArg(obj1))
	vR := vTemp * Cos(c*JEE_CArg(obj1)+0.5*d*Ln(a**2+b**2))
	vI := vTemp * Sin(c*JEE_CArg(obj1)+0.5*d*Ln(a**2+b**2))
	return [vR,vI]
}

;==================================================

;Complex Modulus -- from Wolfram MathWorld
;http://mathworld.wolfram.com/ComplexModulus.html

JEE_CAbs(obj)
{
	return Sqrt(obj.1**2+obj.2**2)
}

;==================================================

;Complex Argument -- from Wolfram MathWorld
;http://mathworld.wolfram.com/ComplexArgument.html

JEE_CArg(obj)
{
	return DllCall("msvcrt\atan2", "Double",obj.2, "Double",obj.1, "Cdecl Double")
}

;==================================================

;Complex Conjugate -- from Wolfram MathWorld
;http://mathworld.wolfram.com/ComplexConjugate.html

JEE_CConj(obj)
{
	return [obj.1,-obj.2]
}

;==================================================