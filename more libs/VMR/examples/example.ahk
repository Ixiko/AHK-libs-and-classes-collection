#Include, VMR.ahk

voicemeeter := new VMR()
voicemeeter.login()
voicemeeter.bus[1].gain_limit:=0

for i, bus in voicemeeter.bus {
    bus.gain:=0 ; set gain to 0 for all busses at startup
}

Volume_Up::voicemeeter.bus[1].gain++ ;bind volume up key to increase bus[1] gain
Volume_Down::voicemeeter.bus[1].gain--

^M::voicemeeter.bus[1].mute:= -1 ; bind ctrl+M to toggle mute bus[1]

^Volume_Up::ToolTip, % ++voicemeeter.strip[5].gain
^Volume_Down::ToolTip, % --voicemeeter.strip[5].gain

F6::voicemeeter.bus[1].device:= "LG" ; set bus[1] to the first device with "LG" in its name using wdm driver
F7::voicemeeter.strip[2].device["mme"]:= "amazonbasics"

^G::
MsgBox, % "bus[1] gain:" . voicemeeter.bus[1].gain . " dB"
MsgBox, % "bus[1] gain percentage:" . voicemeeter.bus[1].getGainPercentage() . "%"
MsgBox, % "bus[1] " . (voicemeeter.bus[1].mute ? "Muted" : "Unmuted")
return

^Y::voicemeeter.command.show()

^K::voicemeeter.bus[1].setParameter("FadeTo", "(6.0, 2000)") ;set specific parameter for a bus/strip

^T::MsgBox, % "Bus[1] Level: " . Max(voicemeeter.bus[1].level*) 

!r::
voicemeeter.recorder.ArmStrip(4,1)
voicemeeter.recorder["mode.Loop"]:=1
voicemeeter.recorder.record:=1
return

!s::
voicemeeter.recorder.stop:=1
voicemeeter.command.eject(1)
return
