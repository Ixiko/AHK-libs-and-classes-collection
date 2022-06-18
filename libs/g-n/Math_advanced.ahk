; Title:   	(Advanced Math) How to calculate formula automaticly
; Link:   	autohotkey.com/boards/viewtopic.php?f=76&t=92178&sid=5586196d107f7122c5af0022cd3b8386
; Author:	swagfag
; Date:   	03.07.2021
; for:     	AHK_L

/*

	#Requires AutoHotkey v1.1.33.09

	#NoEnv
	#SingleInstance Force
	#Warn ClassOverwrite
	SetBatchLines -1

	; ve numbers with positive effects (5)(7)(2) with negativ effects (6) they equal number 13
	; Positive effects can be (+) (x)
	; Negative effects can be (-) (÷)
	; Answer is: 7x2+5-6=13

	Five := new PositiveTerm(5)
	Seven := new PositiveTerm(7)
	Two := new PositiveTerm(2)

	Six := new NegativeTerm(6)

	Terms := [Five, Seven, Two, Six] ; any initial arrangement will do

	expectedAnswer := 13

	output := "formulas for ???=" expectedAnswer "`n`n"
	for each, Formula in getFormulasFor(Terms, expectedAnswer)
		output .= Formula.equation "=" Formula.result "`n"
	MsgBox % output

*/


; (Array<Term>, Number, Float) -> Array<Object>
getFormulasFor(Terms, expectedAnswer, epsilon := 0.000001) {
	Formulas := []

	fn := Func("evaluateEquations").Bind(Formulas, expectedAnswer, epsilon)

	heapsAlgorithm(Terms.Count(), Terms, fn)

	return Formulas
}

; (Array<Object>, Number, Float, Array<Term>) -> void
evaluateEquations(Formulas, expectedAnswer, epsilon, PermutedTerms) {
	for each, equation in generateEquations(PermutedTerms)
	{
		result := eval(equation)

		; for float comparisons(not perfect though)
		if (Abs(result - expectedAnswer) < epsilon)
			Formulas.Push({equation: equation, result: result})
	}
}

; (Array<Term>) -> Array<String>
generateEquations(Terms) {
	ByRefEquations := []

	processTerm(ByRefEquations, Terms, startIndex := 1)

	return ByRefEquations
}

; (&Array<String>, Array<Term>, Integer) -> void
processTerm(ByRef Equations, Terms, i) {
	if (i > Terms.Count()) ; if all terms processed
		return

	CurrentTerm := Terms[i]

	if (i = 1) ; the first term cannot be a binary operator
		NextEquations := CurrentTerm.getUnaryRepresentations("") ; empty string because there is no leftOperand
	else ; the 2nd, 3rd, ..., Nth can be either
	{
		NextEquations := []

		for each, partialEquation in Equations
			NextEquations.Push(CurrentTerm.getBothRepresentations(partialEquation)*)
	}

	Equations := NextEquations ; needed to assign back to the very first original array that was passed in
	processTerm(Equations, Terms, i + 1)
}

class Term {
	__New(value) {
		this.value := value
	}

	; (String) -> Array<String>
	getUnaryRepresentations(leftOperand) {
		return this.getRepresentations(this.UnaryOperators, leftOperand)
	}

	; (String) -> Array<String>
	getBinaryRepresentations(leftOperand) {
		return this.getRepresentations(this.BinaryOperators, leftOperand)
	}

	; (String) -> Array<String>
	getBothRepresentations(leftOperand) {
		Unary := this.getUnaryRepresentations(leftOperand)
		Binary := this.getBinaryRepresentations(leftOperand)
		Unary.Push(Binary*)

		return Unary
	}

	; (Array<String>, String) -> Array<String>
	getRepresentations(OperatorFormats, leftOperand) {
		StringRepresentations := []

		for each, operatorFormat in OperatorFormats
			StringRepresentations.Push(Format(operatorFormat, leftOperand, this.value)) ; eg "{leftOperand}*{this.value}""

		return StringRepresentations
	}
}

class PositiveTerm extends Term {
	; expressed as an ahk Format() string
	UnaryOperators := ["{}+{}"]
	BinaryOperators := ["{}*{}", "Math.pow({}, {})"]
}

class NegativeTerm extends Term {
	UnaryOperators := ["{}-{}"]
	BinaryOperators := ["{}/{}", "{}%{}"]
}

; 1-based
; (Integer, Array<Any>, Func) -> void
heapsAlgorithm(k, A, fn) {
	if (k = 1)
		%fn%(A)
	else
	{
		heapsAlgorithm(k - 1, A, fn)

		Loop % k - 1
		{
			if !(k & 1) ; is even
				swap(A, A_Index, k)
			else
				swap(A, 1, k)

			heapsAlgorithm(k - 1, A, fn)
		}
	}
}

; (Array<Any>, Integer, Integer) -> void
swap(A, i, j) {
	temp := A[i]
	A[i] := A[j]
	A[j] := temp
}

; by teadrinker
; (String) -> String
eval(str) {
	static JS := GetJScriptObject()
	return JS.eval(str)
}

; () -> JScriptTypeInfo
GetJScriptObject() {
	static doc
	doc := ComObjCreate("htmlfile")
	doc.write("<meta http-equiv=""X-UA-Compatible"" content=""IE=9"">")
	JS := doc.parentWindow
	Return JS
}