;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; Evaluates expression and returns the result.
DynaExpr_EvalToVar(sExpr)
{
	sTmpFile := A_Temp "\temp.ahk"

	sScript:="
	(
		#NoTrayIcon
		FileDelete " sTmpFile "

		val := " sExpr "
		FileAppend %val%, " sTmpFile "
	)"

	PID:=DynaRun(sScript)

	Process,WaitClose,%PID%
	FileRead sResult, %sTmpFile%

	return sResult
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; Simply executes sExpr
DynaExpr_Eval(sExpr)
{
	sTmpFile := A_Temp "\temp.ahk"

	sScript:="
	(
		#NoTrayIcon
		FileDelete " sTmpFile "

		" sExpr "
	)"

	PID:=DynaRun(sScript)

	Process, WaitClose, %PID%
	FileRead sResult, %sTmpFile%

	return sResult
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; Dynamically call a function from a string.
DynaExpr_FuncCall(sFunc, ByRef rbRet=0)
{
	; Determine if this is a function or not.
	bCouldBeFunction := InStr(sFunc, "(")
	sPossibleFunc := SubStr(sFunc, 1, InStr(sFunc, "(")-1)
	; Is this Cmd actually a function?
	if (bCouldBeFunction && IsFunc(sPossibleFunc))
	{
		fn := Func(sPossibleFunc)

		; Extract parameters.
		iPosOfFirstParm := InStr(sFunc, "(")+1,
		sParms := SubStr(sFunc, iPosOfFirstParm, StrLen(sFunc)-iPosOfFirstParm)

		; Put parameters into an array (Best method I could find for passing any more than 1 variable was from this document):
		; http://www.autohotkey.com/board/topic/84950-dynamic-function-calls-an-unknown-number-of-parameters/)
		; and this: http://l.autohotkey.net/docs/Functions.htm#Variadic
		asParms := []
		Loop, Parse, sParms, `,
			asParms.Insert(Trim(A_LoopField, A_Space))

		; Call the function
		rbRet := fn.(asParms*)
		return true
	}

	return false
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; Dynamically set a class member variable.
DynaExpr_SetMemVar(ByRef this, sVarName, vVal)
{
	; TODO: Make this work.
	sSetExpr = % Object("this."sVarName)
	%sSetExpr% := vVal
	return
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
