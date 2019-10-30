

range(start, stop:="", step:=1) {
	static range := { _NewEnum: Func("_RangeNewEnum") }
	if !step {
		throw "range(): Parameter 'step' must not be 0 or blank"
	}
	if (stop == "") {
		stop := start, start := 0
	}
	; Formula: r[i] := start + step*i ; r = range object, i = 0-based index
	; For a postive 'step', the constraints are i >= 0 and r[i] < stop
	; For a negative 'step', the constraints are i >= 0 and r[i] > stop
	; No result is returned if r[0] does not meet the value constraint

	if (step > 0 ? start < stop : start > stop) {
		;// start == start + step*0
		return { base: range, start: start, stop: stop, step: step }
	}
}

_RangeNewEnum(r) {
	static enum := { "Next": Func("_RangeEnumNext") }
	return { base: enum, r: r, i: 0 }
}

_RangeEnumNext(enum, ByRef k, ByRef v:="") {
	stop := enum.r.stop+1, step := enum.r.step
	, k := enum.r.start + step*enum.i
	if (ret := step > 0 ? k < stop : k > stop) {
		enum.i += 1
	}
	return ret
}


; ;// Simple usage
; len := (10-0)//1 ; (stop-start)//step
; out := "["
; for i in range(10) {
; 	out .= i . (A_Index < len ? ", " : "]")
; }
; MsgBox %out%

; ;// step = 5
; len := (50-0)//5 ; (stop-start)//step
; out := "["
; for i in range(0, 50, 5) {
; 	out .= i . (A_Index < len ? ", " : "]")
; }
; MsgBox %out%

; ;// Negative numbers
; len := (-10-0)//-1 ; (stop-start)//step
; out := "["
; for i in range(0, -10, -1) {
; 	out .= i . (A_Index < len ? ", " : "]")
; }
; MsgBox %out%