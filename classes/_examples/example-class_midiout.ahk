#include, midi.ahk

midi := new MidiOut(0)
midi.volume := 100
n := []
n.insert("")


n.insert(["E4", "F#3", "D2"])
n.insert(["E4", "F3", "D2"])
n.insert("")
n.insert(["E4", "F3", "D2"])

n.insert("")
n.insert(["C4", "F#3", "D2"])
n.insert(["E4", "F3", "D2"])
n.insert("")

n.insert(["G4", "B3", "G3"])
n.insert("")
n.insert("")
n.insert("")

n.insert(["G3", "G2"])
n.insert("")
n.insert("")
n.insert("")

l0()
l0()
{
global
Loop, 2
{
n.insert(["C4", "E3", "G2"])
n.insert("")
n.insert("")
n.insert(["G3", "C3", "E2"])

n.insert("")
n.insert("")
n.insert(["E3", "G2", "C2"])
n.insert("")

n.insert("")
n.insert(["A3", "C3", "F2"])
n.insert("")
n.insert(["B3", "D3", "G2"])

n.insert("")
n.insert(["A#3", "C#3", "F#2"])
n.insert(["A3", "C3", "F2"])
n.insert("")

n.insert(["G3", "C3", "E2", "sleep1.3"])
n.insert(["E4", "G3", "C3", "sleep1.3"])
n.insert(["G4", "B3", "E3", "sleep1.3"])

n.insert(["A4", "E4", "F3"])
n.insert("")
n.insert(["F4", "A3", "D3"])
n.insert(["G4", "B3", "E3"])

n.insert("")
n.insert(["E4", "F3", "C3"])
n.insert("")
n.insert(["C4", "E3", "A2"])

n.insert(["D4", "F3", "B2"])
n.insert(["B3", "D3", "G2"])
n.insert("")
n.insert("")
}
}

l1()
l1()
{
global
n.insert(["C2"])
n.insert("")
n.insert(["G4", "E4"])
n.insert(["F#4", "C#4", "E2"])

n.insert(["F4", "D4"])
n.insert(["D#4", "B3"])
n.insert(["C3"])
n.insert(["E4", "C4"])

n.insert(["F2"])
n.insert(["G#3", "E3"])
n.insert(["A3", "F3"])
n.insert(["C4", "G3", "C3"])

n.insert(["C3"])
n.insert(["A3", "C3"])
n.insert(["C4", "E3", "F2"])
n.insert(["D4", "F3"])
}

l2()
l2()
{
global
n.insert(["C2"])
n.insert("")
n.insert(["G4", "E4"])
n.insert(["F#4", "C#4", "E2"])

n.insert(["F4", "D4"])
n.insert(["D#4", "B3"])
n.insert(["G2"])
n.insert(["E4", "C4", "C3"])

n.insert("")
n.insert(["D5", "G4", "F4"])
n.insert("")
n.insert(["D5", "G4", "F4"])

n.insert(["D5", "G4", "F4"])
n.insert("")
n.insert(["G2"])
n.insert("")
}

l1()

l3()
l3()
{
global
n.insert(["C2"])
n.insert("")
n.insert(["D#4", "G#3", "G#2"])
n.insert("")

n.insert("")
n.insert(["D4", "F3", "A#2"])
n.insert("")
n.insert("")

n.insert(["C4", "E3", "C3"])
n.insert("")
n.insert("")
n.insert(["G2"])

n.insert(["G2"])
n.insert("")
n.insert(["C2"])
n.insert("")
}

l1()
l2()
l1()
l3()

l4()
{
global
n.insert(["C4", "G#3", "G#1"])
n.insert(["C4", "A3"])
n.insert("")
n.insert(["C4", "A3", "D#2"])

n.insert("")
n.insert(["C4", "G#3"])
n.insert(["E4", "A#3", "G#2"])
n.insert("")

n.insert(["E4", "G3", "G2"])
n.insert(["C4", "E3"])
n.insert("")
n.insert(["A3", "E3", "C2"])

n.insert(["G3", "C3"])
n.insert("")
n.insert(["G1"])
n.insert("")
}

l6()
l6()
{
global
l4()
n.insert(["C4", "G#3", "G#1"])
n.insert(["C4", "A3"])
n.insert("")
n.insert(["C4", "A3", "D#2"])

n.insert("")
n.insert(["C4", "G#3"])
n.insert(["E4", "A#3", "G#2"])
n.insert(["E4", "G3"])

n.insert(["G2"])
n.insert("")
n.insert("")
n.insert(["C2"])

n.insert("")
n.insert("")
n.insert(["G1"])
n.insert("")

l4()

n.insert(["E4", "F#3", "D2"])
n.insert(["E4", "F3", "D2"])
n.insert("")
n.insert(["E4", "F3", "D2"])

n.insert("")
n.insert(["C4", "F#3", "D2"])
n.insert(["E4", "F3", "D2"])
n.insert("")

n.insert(["G4", "B3", "G3"])
n.insert("")
n.insert("")
n.insert("")

n.insert(["G3", "G2"])
n.insert("")
n.insert("")
n.insert("")
}
l0()

l5()
{
global
n.insert(["E4", "C4", "C2"])
n.insert(["C4", "A3"])
n.insert("")
n.insert(["G3", "E3", "F#2"])

n.insert(["G2"])
n.insert("")
n.insert(["G#3", "E3", "C3"])
n.insert("")

n.insert(["A3", "F3", "F2"])
n.insert(["F4", "C4"])
n.insert(["F2"])
n.insert(["F4", "C4"])

n.insert(["A3", "F3", "C3"])
n.insert(["C3"])
n.insert(["F2"])
n.insert("")
}

l7()
l7()
{
global
l5()
n.insert(["B3", "G3", "D2"])
n.insert(["releaseD2", "sleep0.3"])
n.insert(["A4", "F4", "sleep1.3"])
n.insert(["A4", "F4", "sleep0.3"])
n.insert(["hold", "F2"])

n.insert(["A4", "F4", "G2"])
n.insert(["releaseG2", "sleep0.3"])
n.insert(["G4", "E4", "sleep0.6"])
n.insert(["hold", "B2", "sleep0.3"])
n.insert(["hold", "F4", "D4", "sleep0.6"])
n.insert(["releaseB2"])

n.insert(["E4", "C4", "G2"])
n.insert(["C4", "A3"])
n.insert(["G2"])
n.insert(["A3", "F3"])

n.insert(["G3", "E3", "C3"])
n.insert(["C3"])
n.insert(["G2"])
n.insert("")

l5()

n.insert(["D4", "B3", "G2"])
n.insert(["F4", "D4"])
n.insert("")
n.insert(["F4", "D4", "G2"])

n.insert(["F4", "D4", "G2", "sleep1.3"])
n.insert(["E4", "C4", "A2", "sleep1.3"])
n.insert(["D4", "B4", "B2", "sleep1.3"])

n.insert(["C4", "G3", "C3"])
n.insert(["E3"])
n.insert(["G2"])
n.insert(["E3"])

n.insert(["C3", "C2"])
n.insert("")
n.insert("")
n.insert("")
}

l6()
l7()

ch := midi.channel[1]
ch.selectInstrument(1)
timer := 150
for k,v in n
{
  sleepMult := 1
	release := 1
	for i,s in v
	{
	  if (s="hold")
		  release := 0
		else if (regexmatch(s, "release(.+)", m))
		{
		  release := 0
			ch.noteOff(m1)
		}
	}
	if (release)
	  ch.noteOff()
	for i,s in v
	{
		if (regexmatch(s, "sleep(.+)", m))
	    sleepMult := m1
		else
			ch.noteOn(s)
	}
	sleep, % timer * sleepMult
}
pause