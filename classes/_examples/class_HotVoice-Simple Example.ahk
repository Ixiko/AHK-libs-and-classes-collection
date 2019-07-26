; This script demonstrates a single initial word ("Test")

#SingleInstance force
#Persistent ; You will need this if your script creates no hotkeys or has no GUI

; Load the HotVoice Library
#include Lib\HotVoice.ahk

; Create a new HotVoice class
hv := new HotVoice()

; Initialize HotVoice and tell it what ID Recognizer to use
hv.Initialize(0)

; Create a new Grammar
testGrammar := hv.NewGrammar()

; Add the word "Test" to it
testGrammar.AppendString("Test")

; Load the Grammar
hv.LoadGrammar(testGrammar, "Test", Func("MyFunc"))

hv.StartRecognizer()

return

MyFunc(grammarName, words){
	ToolTip % "Command: " grammarName " was triggered @ " A_TickCount " with " words.Length() " words"
}
