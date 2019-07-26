#SingleInstance force
#Persistent

; Load the HotVoice Library
#include Lib\HotVoice.ahk

; Create a new HotVoice class
hv := new HotVoice()
recognizers := hv.GetRecognizerList()

Gui, Add, Text, xm w600 Center, Available Recognizers
Gui, Add, ListView, xm w600 r5, ID|Name
Loop % recognizers.Length(){
	rec := recognizers[A_index]
	LV_Add(, rec.Id, rec.Name)
}
Gui, Add, Text, xm w600 Center, Available Commands
Gui, Add, ListView, xm w600 r10, Name|Grammar
Gui, Add, Text, xm Center w600, Mic Volume
Gui, Add, Slider, xm w600 hwndhSlider
Gui, Add, Text, xm Center w600, Output
Gui, Add, Edit, hwndhOutput w600 r5
LV_ModifyCol(1, 80)


; Initialize HotVoice and tell it what ID Recognizer to use
hv.Initialize(0)

; -------- Volume Command ------------
volumeGrammar := hv.NewGrammar()
volumeGrammar.AppendString("Volume")

percentPhrase := hv.NewGrammar()
percentChoices := hv.GetChoices("Percent")
percentPhrase.AppendChoices(percentChoices)
percentPhrase.AppendString("percent")

fractionPhrase := hv.NewGrammar()
fractionChoices := hv.NewChoices("quarter, half, three-quarters, full")
fractionPhrase.AppendChoices(fractionChoices)

volumeGrammar.AppendGrammars(fractionPhrase, percentPhrase)

LV_Add(, "Volume", hv.LoadGrammar(volumeGrammar, "Volume", Func("Volume")))

; -------- Call Contact Command -------------
contactGrammar := hv.NewGrammar()
contactGrammar.AppendString("Call")

femaleGrammar := hv.NewGrammar()
femaleChoices := hv.NewChoices("Anne, Mary")
femaleGrammar.AppendChoices(femaleChoices)
femaleGrammar.AppendString("on-her")

maleGrammar := hv.NewGrammar()
maleChoices := hv.NewChoices("James, Sam")
maleGrammar.AppendChoices(maleChoices)
maleGrammar.AppendString("on-his")

contactGrammar.AppendGrammars(maleGrammar, femaleGrammar)

phoneChoices := hv.NewChoices("cell, home, work")
contactGrammar.AppendChoices(phoneChoices)
contactGrammar.AppendString("phone")

LV_Add(, "CallContact", hv.LoadGrammar(contactGrammar, "CallContact", Func("CallContact")))
Gui, Show, , HotVoice Demo

; Monitor the volume
hv.SubscribeVolume(Func("OnMicVolumeChange"))

hv.StartRecognizer()

return

OnMicVolumeChange(state){
	global hSlider
	GuiControl, , % hSlider, % state
}

Volume(grammarName, words){
	static fractionToPercent := {"quarter": 25, "half": 50, "three-quarters": 75, "full": 100}
	if (words[3] = "percent"){
		vol := words[2]
	} else {
		vol := fractionToPercent[words[2]]
	}
	UpdateOutput(grammarName ": " words[2] " " words[3] " -- SETTING VOLUME TO " vol)
	SoundSet, % vol
}

CallContact(grammarName, words){
	max := words.Length()
	Loop % max {
		wordStr .= words[A_Index]
		if (A_Index != max){
			wordStr .= " "
		}
	}
	UpdateOutput(grammarName ": " wordStr)
}

UpdateOutput(text){
	global hOutput
	static WM_VSCROLL = 0x115
	static SB_BOTTOM = 7
	Gui, +HwndhGui
	; Get old text
	GuiControlGet, t, , % hOutput
	;~ t .= text " @ " A_Now "`n"
	t .= text "`n"
	GuiControl, , % houtput, % t
	; Scroll box to end
	PostMessage, WM_VSCROLL, SB_BOTTOM, 0, Edit1, ahk_id %hGui%
}

^Esc::
GuiClose:
	ExitApp