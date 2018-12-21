; Classic "spam" example.
; Hotkey a and b sends a and b using quickTimer.
; Hotkey c and d sends c and d using regular timers.
#include timer.ahk
SendMode "Event"	; Do not change this.
SetKeyDelay -1, -1

aTimer := new quickTimer( () => send("a") )
bTimer := new quickTimer( () => send("b") )


a::aTimer.start()
b::bTimer.start()
a up::aTimer.stop()
b up::bTimer.stop()

c::
	if cIsOn
		return
	cIsOn := true
	setTimer c() => send("c"), 0
return
d::
	if dIsOn
		return
	dIsOn := true
	setTimer d() => send("d"), 0
return
c up::
	settimer "c", "off" 
	cIsOn := false
return
d up::
	settimer "d", "off" 
	dIsOn := false
return

esc::exitapp


