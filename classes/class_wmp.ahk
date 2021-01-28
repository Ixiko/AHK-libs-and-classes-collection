; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=85674
; Author:	watagan
; Date:
; for:     	AHK_L

/*

	Credit to AHKStudent and BoBo
	https://www.autohotkey.com/boards/viewtopic.php?p=376078

	I needed to play part of an audio file. Here is a simple class to get it done without using external players.

	Note:
	-This class can be improved by adding other WMP functionalities found here:
	https://docs.microsoft.com/en-us/windows/win32/wmp/controls-currentpositiontimecode
	-MP3 content time stamp gets messed up when appending audio to the file. Same goes for any player. I guess it's an MP3 format thing. No such issue with WAV.

	Demo usage:
	-Download attached wav file
	-Hotkeys: 1 = play the whole file, 2-9 = play a part, 0 = toggle play/pause


*/

/*

	#noEnv
	#persistent
	#singleInstance force
	setWorkingDir %a_scriptDir%

	file := a_scriptDir "\test.wav"
	wmp1 := new wmp(file)
	list=
	(c lTrim rTrim
		1 | <all>         | 00:00:01   | 00:00:40
		2 | umami         | 00:00:04.4 | 00:00:05.4
		3 | killo         | 00:00:07   | 00:00:08
		4 | release       | 00:00:09.7 | 00:00:11
		5 | downwind      | 00:00:12.3 | 00:00:13
		6 | colony        | 00:00:17   | 00:00:20
		7 | specialty     | 00:00:19.5 | 00:00:20.2
		8 | chronological | 00:00:20.8 | 00:00:21.7
		9 | plentiful     | 00:00:22.6 | 00:00:40
	)
	arr := []
	loop, parse, list, `n
	{
		s := strSplit(a_loopfield, "|")
		loop 4
			s[a_index] := regexReplace(s[a_index], "^\s+|\s+$")
		Hotkey, % s[1], Label, Options]
		arr[a_index, "label"] := s[2]
		arr[a_index, "sTime"] := s[3]
		arr[a_index, "eTime"] := s[4]
	}
	return

	Label:
		tooltip, % arr[a_thisHotKey, "label"]
		wmp1.play(arr[a_thisHotKey, "sTime"], arr[a_thisHotKey, "eTime"])
		sleep 1000
		tooltip
	return

	0::wmp1.toggle()

*/

class wmp
{
	; https://docs.microsoft.com/en-us/windows/win32/wmp/controls-currentpositiontimecode
	static interval := 10
	__New(file){
		this.file := file
		this.wmp  := ComObjCreate("WMPlayer.OCX")
	}
	play(start := 0, end := "") {

		s := strSplit(start, ":")
		e := strSplit(end  , ":")
		start := (s[1] * 60 * 60) + (s[2] * 60) + s[3]
		start := start = "" ? 0 : start
		end   := (e[1] * 60 * 60) + (e[2] * 60) + e[3]
		end   := end = "" ? 9999999999999999 : end
		if (end != "") && (end <= start)
			return
		if this.timer
			this.timerStop()
		this.close()
		this.wmp.controls.currentPosition := start
		this.wmp.url := this.file
		this.playing := 1
		this.timeElapsed := 0
		if !(end = "") {
			this.duration    := (end - start) * 1000
			this.timer       := objBindMethod(this, "timerTick")
			this.timerStart()
		}
	}
    toggle() {
		if this.paused
			this.resume()
		else this.pause()
	}
    stop() {
		this.paused  := 0
		this.wmp.controls.stop
	}
    pause() {
		this.paused := 1
		this.wmp.controls.pause
	}
    resume() {
		if !this.playing
			return
		this.paused := 0
		this.wmp.controls.play
	}
    timerStart() {
        timer := this.timer
        SetTimer % timer, % this.interval
    }
    timerStop() {
		timer := this.timer
		SetTimer % timer, delete
    }
	timerTick() {
		if this.paused
			return
		this.timeElapsed += this.interval
		if (this.timeElapsed >= this.duration) {
			this.close()
			this.timerStop()
		}
	}
	close() {
		this.playing := 0
		this.paused  := 0
		this.wmp.close
	}
	__Delete() { ; not sure whether this works/needed
		this.close()
	}
}