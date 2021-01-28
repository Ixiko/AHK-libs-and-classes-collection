
/*
Speech Recognition
==================
A class providing access to Microsoft's SAPI. Requires the SAPI SDK.
 
Reference
---------
### Recognizer := new SpeechRecognizer
 
Creates a new speech recognizer instance.
 
The instance starts off listening to any phrases.
 
### Recognizer.Recognize(Values = True)
 
Set the values that can be recognized by the recognizer.
 
If `Values` is an array of strings, the array is interpreted as a list of possibile phrases to recognize. Phrases not in the array will not be recognized. This provides a relatively high degree of recognition accuracy compared to dictation mode.
 
If `Values` is otherwise truthy, dictation mode is enabled, which means that the speech recognizer will attempt to recognize any phrases spoken.
 
If `Values` is falsy, the speech recognizer will be disabled and will stop listening if currently doing so.
 
Returns the speech recognizer instance.
 
### Recognizer.Listen(State = True)
 
Set the state of the recognizer.
 
If `State` is truthy, then the recognizer will start listening if not already doing so.
 
If `State` is falsy, then the recognizer will stop listening if currently doing so.
 
Returns the speech recognizer instance.
 
### Text := Recognizer.Prompt(Timeout = -1)
 
Obtains the next phrase spoken as plain text.
 
If `Timeout` is a positive number, the function will stop and return a blank string after this amount of time, if the user has not said anything in this interval.
 
If `Timeout` is a negative number, the function will wait indefinitely for the user to speak a phrase.
 
Returns the text spoken.
 
### Recognizer.OnRecognize(Text)
 
A callback invoked immediately upon any phrases being recognized.
 
The `Text` parameter received the phrase spoken.
 
This function is meant to be overridden in subclasses. By default, it does nothing.
 
The return value is discarded.
*/
 
/* Example: recognizing a specific list of phrases
TrayTip, Speech Recognition, Say a number between 0 and 9 inclusive
 
s := new SpeechRecognizer
s.Recognize(["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"])
Text := s.Prompt()
 
TrayTip, Speech Recognition, You said: %Text%
Sleep, 3000
ExitApp
*/
 
/* Example: recognizing any phrase
TrayTip, Speech Recognition, Say something
 
s := new SpeechRecognizer
s.Recognize(True)
Text := s.Prompt()
 
TrayTip, Speech Recognition, You said: %Text%
Sleep, 3000
ExitApp
*/
 
/* Example: custom behaviour upon phrase recognition
TrayTip, Speech Recognition, Say something (press Escape to close)
 
s := new CustomSpeech ;create the custom speech recognizer
s.Recognize(True)
 
Esc::ExitApp
 
class CustomSpeech extends SpeechRecognizer
{
OnRecognize(Text)
{
static cSpeaker := ComObjCreate("SAPI.SpVoice")
TrayTip, Speech Recognition, You said: %Text%
cSpeaker.Speak("You said: " . Text)
}
}
*/
 
class SpeechRecognizer{ ;speech recognition class by Uberi
	static Contexts := {}
	 
	__New(){
		try{
			this.cListener := ComObjCreate("SAPI.SpInprocRecognizer") ;obtain speech recognizer (ISpeechRecognizer object)
			cAudioInputs := this.cListener.GetAudioInputs() ;obtain list of audio inputs (ISpeechObjectTokens object)
			this.cListener.AudioInput := cAudioInputs.Item(0) ;set audio device to first input
		}
		catch e
			throw Exception("Could not create recognizer: " . e.Message)
		 
		try this.cContext := this.cListener.CreateRecoContext() ;obtain speech recognition context (ISpeechRecoContext object)
		catch e
			throw Exception("Could not create recognition context: " . e.Message)
		try this.cGrammar := this.cContext.CreateGrammar() ;obtain phrase manager (ISpeechRecoGrammar object)
		catch e
			throw Exception("Could not create recognition grammar: " . e.Message)
		 
		;create rule to use when dictation mode is off
		try{
			this.cRules := this.cGrammar.Rules() ;obtain list of grammar rules (ISpeechGrammarRules object)
			this.cRule := this.cRules.Add("WordsRule",0x1 | 0x20) ;add a new grammar rule (SRATopLevel | SRADynamic)
		}
		catch e
			throw Exception("Could not create speech recognition grammar rules: " . e.Message)
		 
		this.Phrases(["hello", "hi", "greetings", "salutations"])
		this.Dictate(True)
		 
		SpeechRecognizer.Contexts[&this.cContext] := &this ;store a weak reference to the instance so event callbacks can obtain this instance
		this.Prompting := False ;prompting defaults to inactive
		 
		ComObjConnect(this.cContext, "SpeechRecognizer_") ;connect the recognition context events to functions
	}
		 
	Recognize(Values = True){
		If Values ;enable speech recognition
		{
			this.Listen(True)
			If IsObject(Values) ;list of phrases to use
				this.Phrases(Values)
			Else ;recognize any phrase
				this.Dictate(True)
		}
		Else ;disable speech recognition
			this.Listen(False)
		Return, this
	}
	
	Listen(State = True){
		try{
			If State
				this.cListener.State := 1 ;SRSActive
			Else
				this.cListener.State := 0 ;SRSInactive
		}
		catch e
			throw Exception("Could not set listener state: " . e.Message)
		Return, this
	}
	 
	Prompt(Timeout = -1){
		this.Prompting := True
		this.SpokenText := ""
		
		If Timeout < 0 ;no timeout
		{
			While, this.Prompting
			Sleep, 50
		}
		Else{
			StartTime := A_TickCount
			While, this.Prompting && (A_TickCount - StartTime) > Timeout
			Sleep, 50
		}
		Return, this.SpokenText
	}
	 
	Phrases(PhraseList){
		try this.cRule.Clear() ;reset rule to initial state
		catch e
			throw Exception("Could not reset rule: " . e.Message)
		 
		try cState := this.cRule.InitialState() ;obtain rule initial state (ISpeechGrammarRuleState object)
		catch e
			throw Exception("Could not obtain rule initial state: " . e.Message)
		 
		;add rules to recognize
		cNull := ComObjParameter(13,0) ;null IUnknown pointer
		For Index, Phrase In PhraseList {
			try cState.AddWordTransition(cNull, Phrase) ;add a no-op rule state transition triggered by a phrase
			catch e
				throw Exception("Could not add rule """ . Phrase . """: " . e.Message)
		}
		 
		try this.cRules.Commit() ;compile all rules in the rule collection
		catch e
			throw Exception("Could not update rule: " . e.Message)
		 
		this.Dictate(False) ;disable dictation mode
		Return, this
	}
	 
	Dictate(Enable = True)
	{
		try{
			If Enable ;enable dictation mode
			{
				this.cGrammar.DictationSetState(1) ;enable dictation mode (SGDSActive)
				this.cGrammar.CmdSetRuleState("WordsRule", 0) ;disable the rule (SGDSInactive)
			}
			Else ;disable dictation mode
			{
				this.cGrammar.DictationSetState(0) ;disable dictation mode (SGDSInactive)
				this.cGrammar.CmdSetRuleState("WordsRule", 1) ;enable the rule (SGDSActive)
			}
		}
		catch e
			throw Exception("Could not set grammar dictation state: " . e.Message)
		Return, this
	}
	 
	OnRecognize(Text)
	{
		;placeholder function meant to be overridden in subclasses
	}
		 
	__Delete()
	{
		;remove weak reference to the instance
		this.base.Contexts.Remove(&this.cContext, "")
	}
}
	 
SpeechRecognizer_Recognition(StreamNumber, StreamPosition, RecognitionType, cResult, cContext) ;speech recognition engine produced a recognition
{
	try
	{
		pPhrase := cResult.PhraseInfo() ;obtain detailed information about recognized phrase (ISpeechPhraseInfo object from ISpeechRecoResult object)
		Text := pPhrase.GetText() ;obtain the spoken text
	}
	catch e
		throw Exception("Could not obtain recognition result text: " . e.Message)
	 
	Instance := Object(SpeechRecognizer.Contexts[&cContext]) ;obtain reference to the recognizer
	 
	;handle prompting mode
	If Instance.Prompting
	{
		Instance.SpokenText := Text
		Instance.Prompting := False
	}
	 
	Instance.OnRecognize(Text) ;invoke callback in recognizer
}