#include timer.ahk
; Example - speed test vs regular timers.
; To try, hit x note the result, then hit z and note the result.
; hotkeys 1,2,3,4 can be change the speed of the speedTimer. -1 is default, fastest
global t := 1
timersExist := false
global ctra := 0, ctrb := 0, ctrc := 0
global testTime := 500
; Speed settings
1::quickTimer.speed := -1
2::quickTimer.speed := 0
3::quickTimer.speed := 1
4::quickTimer.speed := 2

#if t
x::	; timer class
	t := 0
	ctra := ctrb := ctrc := 0
	if !timersExist {
		new quickTimer("a")
		new quickTimer("b")
		new quickTimer("c")
		timersExist := true
	}
	quickTimer.startAll()
	settimer "d", -abs(testTime)
return
z::	; regular timer
	t := 0
	ctra := ctrb := ctrc := 0
	settimer "a", 0
	settimer "b", 0
	settimer "c", 0
	settimer "e", -abs(testTime)
return
#if
esc::exitapp
#if false	; set to true if disabling timers for "d" and "e" in x and z hotkeys.
x up::d()
z up::e()


d(){
	quickTimer.stopAll()
	msgbox "class timers stopped, callbacks fired:`n`na: " ctra "`nb: " ctrb "`nc: " ctrc "`n`nTest duration: " testTime " ms." 
	t := 1
	return
}
e(){
	settimer "a", "off"
	settimer "b", "off"
	settimer "c", "off"
	msgbox "regular timers stopped, callbacks fired:`n`na: " ctra "`nb: " ctrb "`nc: " ctrc "`n`nTest duration: " testTime " ms."	
	t := 1
	return
}

a(){
	ctra++
}
b(){
	ctrb++
}
c(){
	ctrc++
}

