;============================================================================
; multi click detect / copy-paste as-is / read instructions!!!
;============================================================================

; How to use this:

;    var := MultiClickDetect(ThisKey,delay=300,CycleLimit=0)
;
; Returns the number of consecutive clicks (or keystrokes) for the specified key that occurred with the specified
; delay (milliseconds) between each click (or keystroke).  So you can define a triple, quadruple, quintuple,
; etc... click.  Pretty much as high of a click count context as you want, as long as there are not other side
; effects from any other running software programs.
;
; If the delay between clicks is greater than specified, the returned click count resets to 1.
;
; Default delay is 300 milliseconds.
;
; "CycleLimit" can be used to return multiple multi-click events in succession without a delay.  For example, if 
; you set CycleLimit=2 for LButton, and keep clicking as fast as you can for an extended duration, assuming you
; click within the specified delay, you would get a double-click on every even numbered click, even if you don't
; stop clicking.
;
; ThisKey can be any key recognized by AutoHotkey.  ThisKey is in fact just an arbirary string, so depending on
; how you handle the capture event, this string can be anything, and as long as you capture the click/keystroke
; event properly, it will work.

; =======================================
; =======================================

class MultiClick {
	Static Count := "", Key := "", TicksPrev := ""
	
	Static Detect(ThisKey, delay:=300, CycleLimit:=0) {	; ThisKey = A_ThisHotKey, or whatever value you pass
		ct := this.TickDiff()
		
		this.Count := (this.Count = "") ? 0 : this.Count
		If ((ct > delay And ct != "" And ct != 0) Or (ThisKey != this.Key And this.Key != ""))
			this.Count := 0
		Else If (this.Count >= CycleLimit And CycleLimit > 0) ; resets MultiClickCount to 1 on CycleLimit+1
			this.Count := 0 ; useful for firing multiple double/triple/etc clicks without a pause between.
		
		this.Key := ThisKey, this.Count++
		return this.Count
	}
	Static TickDiff() { ; returns the number of ticks (ms) since the last button event (any button)
		CurTicks := A_TickCount
		
		If (this.TicksPrev = "")
			diff := 0, this.TicksPrev := A_TickCount
		Else
			diff := A_TickCount - this.TicksPrev, this.TicksPrev := A_TickCount
		
		return diff
	}
}