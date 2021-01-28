/*
#NoEnv
ScriptName := RegExReplace(A_ScriptName, ".ahk")
SoundGet, VolumeLevel          ; Remember the volume level of the speakers
SoundGet, MuteStatus, , MUTE   ; Remember the mute status of the speakers
SoundSet, 0, , Mute            ; Unmute the speakers
SoundSet, 50                   ; Set the master volume to 50%
AnnaVoice := TTS_CreateVoice("Microsoft Anna", -3, 100, -3)
Operation := "three hundred and thirty-three times four"
Loop
{
   InputBox, Operation, %ScriptName%, Please enter the word operation:, , 305, 125, , , , , %Operation%
   if ErrorLevel
      Break
   String1  := RegExReplace(Operation, "i) (plus|minus|times|divided by).*")
   Operator := RegExReplace(Operation, "i).*(plus|minus|times|divided by).*", "$1")
   String2  := RegExReplace(Operation, "i).*(plus|minus|times|divided by) ")
   Number1 := Name2Number(String1)
   if (ErrorLevel = 1)
      MsgBox, 48, , % "There is a TYPO or an ILLEGAL WORD in the string:`n`n""" String1 """`n`nPlease correct it and try again."
   else if (ErrorLevel = 2)
      MsgBox, 48, , % "There is a SYNTAX ERROR in the string:`n`n""" String1 """`n`nPlease correct it and try again."
   if ErrorLevel
      Continue
   Number2 := Name2Number(String2)
   if (ErrorLevel = 1)
      MsgBox, 48, , % "There is a TYPO or an ILLEGAL WORD in the string:`n`n""" String2 """`n`nPlease correct it and try again."
   else if (ErrorLevel = 2)
      MsgBox, 48, , % "There is a SYNTAX ERROR in the string:`n`n""" String2 """`n`nPlease correct it and try again."
   if ErrorLevel
      Continue
   Equals := "`nequals`n"
   if (Operator = "plus")
      Result := Number1+Number2
   else if (Operator = "minus")
      Result := Number1-Number2
   else if (Operator = "times")
      Result := Number1*Number2
   else if (Operator = "divided by")
   {
      Result := Round(Number1/Number2)
      if (Result - Number1/Number2)
         Equals := "`nis approximately`n"
   }
   Output := Operation Equals Number2Name(Result)
   SetTimer, SpeaknShowButton, -250      ; Wait long enough for the button to go completely gray
   SetTimer, HideButton, -1
   MsgBox, , %ScriptName%, %Output%
}
SoundSet, (MuteStatus = "ON" ? 1 : 0), , MUTE   ; Reset the mute status of the speakers
SoundSet, VolumeLevel                           ; Reset the volume level of the speakers
ExitApp

SpeaknShowButton:
TTS(AnnaVoice, "SpeakWait", Output)
Control, Enable, , Button1, %ScriptName%
ControlFocus, Button1, %ScriptName%
Return

HideButton:
Control, Disable,, Button1, %ScriptName%
Return
*/


;
; AutoHotkey: v1.1.11+
; Language:   English
; Platform:   Win7
; Author:     iPhilip
;
; Converts a number into the name of the number
;
; The function Number2Name(Number) converts an integer from 1 to 999,999,999,999 into the name of the number.
; For example, the number 264358 converts to "two hundred sixty-four thousand three hundred and fifty eight".
; See http://en.wikipedia.org/wiki/List_of_numbers#Cardinal_numbers for reference. Comma separators in the
; number are allowed, e.g. 264,358.
;
; The function sets ErrorLevel to one of the following values:
;
;    0 - If the conversion was successful
;    1 - If the number contains any non-digit characters other than commas ("123.4")
;    2 - If the number is larger than the maximum (10**12-1)
;
; ------------------------------------------------------------------------------------------

Number2Name(Number) {
   static OnesArray := ["one","two","three","four","five","six","seven","eight","nine"]
   static TeensArray := ["ten","eleven","twelve","thirteen","fourteen","fifteen","sixteen","seventeen","eighteen","nineteen"]
   static TensArray  := ["twenty","thirty","forty","fifty","sixty","seventy","eighty","ninety"]
   static ThousandsArray := ["thousand","million","billion"]

   StringReplace, Number, Number, `,, , All          ; Remove any comma separators from the input string
   ErrorLevel := 0                                   ; Initialize the error code to the default value
   if Number is not digit                            ; If the string contains anything other than digits
      ErrorLevel := 1                                ; Set the corresponding error code
   else if (Number > 10**12-1)                       ; Otherwise, if the number is larger than the maximum ...
      ErrorLevel := 2                                ; Set the corresponding error code
   if ErrorLevel                                     ; If the error code is non-zero
      Return                                         ; Return
   String =                                          ; Initialize the output string
   NumPeriods := Ceil(StrLen(Number)/3)              ; Calculate the number of periods in the number
   Loop %NumPeriods%                                 ; Loop through for each period
   {                                                 ; A period is a grouping of three digits, e.g. 46,322 has two periods
      Multiplier := 10**(3*(NumPeriods-A_Index))     ; Calculate the multiplier corresponding to the current period
      Period := Floor(Number/Multiplier)             ; Extract the current period
      Hundreds := Floor(Period/100)                  ; Calculate the hundreds digit for the period
      Tens := Floor((Period-Hundreds*100)/10)        ; Calculate the tens digit for the period
      Ones := Period-Hundreds*100-Tens*10            ; Calculate the ones digit for the period
      if Hundreds                                    ; If the period has a non-zero hundreds digit ...
         String .= OnesArray[Hundreds] A_Space "hundred" A_Space   ; Append the name for the ones digit and the word "hundred" to the string, e.g. "two hundred"
      if (Tens > 1)                                  ; If the tens digit is greater than one, e.g. twenty-two
      {
         if (NumPeriods = 1 AND Hundreds OR NumPeriods > 1 AND A_Index > 1)
         ; If there are fewer than 3 digits and the number is > 99 or there are multiple periods and it's not the first period ...
            String .= "and" A_Space                  ; Append an "and " to the string
         String .= TensArray[Tens-1]                 ; Append the name for the tens digit to the string
         if Ones                                     ; If the period has a non-zero ones digit, e.g. 37
            String .=  "-" OnesArray[Ones] A_Space   ; Append a dash and the name of the ones digit to the string
      }
      else if Tens                                   ; Otherwise, if the tens digit is one, e.g. 214
      {
         if (NumPeriods = 1 AND Hundreds OR NumPeriods > 1 AND A_Index > 1)
         ; If there are fewer than 3 digits and the number is > 99 or there are multiple periods and it's not the first period ...
            String .= "and" A_Space                  ; Append an "and " to the string
         String .= TeensArray[Period-Hundreds*100-9] A_Space   ; Append the name of the of the "teens" digit to the string
      }
      else if Ones                                   ; Otherwise, if the tens digit is zero and the ones digit is non-zero ...
      {
         if (NumPeriods = 1 AND Hundreds OR NumPeriods > 1 AND A_Index > 1)
         ; If there are fewer than 3 digits and the number is > 99 or there are multiple periods and it's not the first period ...
            String .= "and" A_Space                  ; Append an "and " to the string
         String .= OnesArray[Ones] A_Space           ; Append the name of the ones digit to the string
      }
      if (Period AND A_Index < NumPeriods)           ; If the period is non-zero and it's not the last period
         String .= ThousandsArray[NumPeriods-A_Index] A_Space   ; Append the name of the "thousands" digit to the string
      Number -= Period*Multiplier                    ; Reduce the number by the current period
   }
   String = %String%                                 ; Trim the space at the end of the string
   Return String                                     ; Return the value of the string
}

; AutoHotkey: v1.1.11+
; Language:   English
; Platform:   Win7
; Author:     iPhilip
;
; Convert the name of a number into the number
;
; The function Name2Number(String) converts the name of a number into a number from 1 to 999,999,999,999.
; For example, the string "two hundred sixty-four thousand three hundred and fifty eight" converts to 264358.
; See http://en.wikipedia.org/wiki/List_of_numbers#Cardinal_numbers for a reference to the names of numbers.
; Numbers such as "eleven hundred" are not allowed. Use "one thousand one hundred" instead.
; Spaces and tabs are allowed at the start and end of the string and in between words.
; Hyphenated ("twenty-one") and non-hyphenated names ("twenty one") are allowed.
; The word "and" can be used inside the string but only after the words hundred, thousand, million, or billion.
;
; The function sets ErrorLevel to one of the following values:
;
;    0 - If the conversion was successful
;    1 - If there are typos ("elevn") or spaces inside hyphenated ("twenty- one") or regular ("seven teen") words
;    2 - If there are syntax errors in the string ("two hundred thirty ten" or "one-thirty")
;
; ------------------------------------------------------------------------------------------

Name2Number(Name) {
   static Ones  := {one:1,two:2,three:3,four:4,five:5,six:6,seven:7,eight:8,nine:9}
   static Teens := {one:1,two:2,three:3,four:4,five:5,six:6,seven:7,eight:8,nine:9,ten:10,eleven:11,twelve:12,thirteen:13,fourteen:14,fifteen:15,sixteen:16,seventeen:17,eighteen:18,nineteen:19}
   static Tens  := {twenty:20,thirty:30,forty:40,fifty:50,sixty:60,seventy:70,eighty:80,ninety:90}
   static Thousands := {thousand:10**3,million:10**6,billion:10**9}
   static Dictionary := "and,one,two,three,four,five,six,seven,eight,nine,ten,eleven,twelve,thirteen,fourteen,fifteen,sixteen,seventeen,eighteen,nineteen,twenty,thirty,forty,fifty,sixty,seventy,eighty,ninety,hundred,thousand,million,billion"
;
; Strip extra spaces from the start and end of the string, as well as in between words
; Perform syntax checking and strip the hyphen from hyphenated words
; Spell check each word and assemble them into a temporary array
;
   String =                                               ; Initialize the temporary string
   ErrorLevel := 0                                        ; Initialize the error code
   Loop, Parse, Name, %A_Space%%A_Tab%                    ; Parse the name using spaces and tabs as delimeters
   {
      if A_LoopField =                                    ; Skip the blanks between multiple spaces
         Continue
      if (Hyphen := Instr(A_LoopField, "-"))              ; If there is a hyphen in the word ...
      {
         LeftSide := Substr(A_LoopField, 1, Hyphen - 1)   ; Extract the left side of the hyphenated word
         RightSide := Substr(A_LoopField, Hyphen + 1)     ; Extract the right side of the hyphenated word
         if not (Tens.HasKey(LeftSide) AND Ones.HasKey(RightSide))   ; If the left side is not in the Tens array and the right side is not in the Ones array ...
            ErrorLevel := 2                               ; Set the error code corresponding to a syntax error
         if LeftSide not in %Dictionary%                  ; If the left part of the word is not in the Dictionary ...
            ErrorLevel := 1                               ; Set the the error code corresponding to a typo or an illegal word
         if RightSide not in %Dictionary%                 ; If the right part of the word is not in the Dictionary ...
            ErrorLevel := 1                               ; Set the the error code corresponding to a typo or an illegal word
         if ErrorLevel                                    ; If the error code is non-zero ...
            Return                                        ; Return with a null result
         String .= LeftSide A_Space RightSide A_Space     ; Store the two parts of the hyphenated word in the temporary string
         Continue                                         ; Skip the rest of the loop
      }
      if A_LoopField not in %Dictionary%                  ; If the word is not in the Dictionary ...
      {
         ErrorLevel := 1                                  ; Set the the error code corresponding to a typo or an illegal word
         Return                                           ; Return with a null result
      }
      String .= A_LoopField A_Space                       ; Store the word in the temporary string
   }
   String = %String%                                      ; Remove the trailing space at the end of the string (assumes the default AutoTrim, On)
   StringSplit, Array, String, %A_Space%                  ; Put all the words into a temporary array
;
; Perform syntax checking on "and" words (see above) and remove them
; Put the remaining words in the string into an array
; Count the number of "word periods", i.e. the blocks of words that represent 3 digits (left to right)
; For example, the number "two million seventy-three thousand four hundred fifty one" (2,073,451)
; has 3 word periods: "two million", "seventy-three thousand", and "four hundred fifty-eight"
;
   NumPeriods := NumWords := 0                            ; Initialize the parameters
   Loop %Array0%                                          ; Loop through each word
      if (Array%A_Index% = "and")                         ; If the word is "and" ...
      {
         Prev := A_Index - 1                              ; Setup a variable for pointing to the previous word
         if (A_Index = 1 OR A_Index = Array0 OR not (Array%Prev% = "hundred" OR Thousands.HasKey(Array%Prev%)))
         {  ; If the "and" is at the start or at the end of the string or it doesn't immediately follow the words hundred, thousad, million, or billion ...
            ErrorLevel := 2                               ; Set the error code corresponding to a syntax error
            Return                                        ; Return with a null result
         }
      }
      else                                                ; If the word is not "and" ...
      {
         NumWords++                                       ; Increment the number of words in the string
         Word%NumWords% := Array%A_Index%                 ; Assign the current word to the word array
         if Thousands.HasKey(Array%A_Index%)              ; If the word is part of the Thousands array ...
            NumPeriods++                                  ; Increment the number of word blocks
      }
   if not Thousands.HasKey(Word%NumWords%)                ; If the last word is not part of the Thousands array, e.g. "two thousand *twelve*", ...
      NumPeriods++                                        ; Increment the number of blocks by one to include the ones block
;
; Convert the word array into a number
;
   Total := 0                             ; Initialize the running total for the result
   Index := 1                             ; Initialize the index that refers to the word that is being analyzed
   ErrorLevel := 0                        ; Initialize the error code
   Thou := Thousands.Clone()              ; Make a copy of the Thousands array as it gets "consumed" in the loop below
   Loop %NumPeriods%                      ; Iterate the loop below for each word block
   {
      Sum := 0                            ; Initialize the sum for each word block
      if Ones.HasKey(Word%Index%)         ; If first word is a number from 1-9, e.g. "*seven* hundred thousand four hundred", ...
      {
         Sum := Ones[Word%Index%]         ; Convert the word into a number
         if (++Index > NumWords)          ; If that's the last word in the string, e.g. "one thousand *four*", ...
            Return Total + Sum            ; Return the result
         if (Word%Index% = "hundred")     ; If the next word is "hundred", e.g. "seven *hundred* thousand", ...
         {
            Sum *= 100                    ; Multiply the number associated with the first word by 100
            if (++Index > NumWords)       ; If that's the last word in the string, e.g. "one thousand two *hundred*", ...
               Return Total + Sum         ; Return the result
         }
         else                             ; If the next word is not "hundred" ...
         {
            Sum := 0                      ; Reset the sum of the current word block
            Index--                       ; Reset the index to the start of the word block
         }                                ; The original condition "if Ones.HasKey(Word%Index%)" will be detected again with "if Teens.HasKey(Word%Index%)" below
      }                                   ; Note that without the above "else" block, the string "one two" would be allowed
      if Tens.HasKey(Word%Index%)         ; If the next word is a number in the Tens array, e.g. "two hundred *sixty* four million", ...
      {
         Sum += Tens[Word%Index%]         ; Add that number to the word block sum
         if (++Index > NumWords)          ; If that's the last word in the string, e.g. "two hundred *sixty*", ...
            Return Total + Sum            ; Return the result
         if Ones.HasKey(Word%Index%)      ; If the next word is a number from 1-9, e.g. "two hundred sixty *four* million", ...
         {
            Sum += Ones[Word%Index%]      ; Add that number to the word block sum
            if (++Index > NumWords)       ; If that's the last word in the string, e.g. "two hundred sixty *four*", ...
               Return Total + Sum         ; Return the result
         }
      }
      else if Teens.HasKey(Word%Index%)   ; If the next word is a number from 1-19, e.g. "two hundred *eighteen* million", ...
      {
         Sum += Teens[Word%Index%]        ; Add that number to the word block sum
         if (++Index > NumWords)          ; If that's the last word in the string, e.g. "two hundred *eighteen*", ...
            Return Total + Sum            ; Return the result
      }
      if Thou.HasKey(Word%Index%)         ; If the next word is a member of the Thousands array, e.g. "two hundred sixty four *million*", ...
      {
         ThouValue := Thou[Word%Index%]   ; Copy the value associated with the current word into a temporary variable
         Sum *= ThouValue                 ; Multiply the word block sum by that number
         if (Sum = 0)                     ; If the word block sum is zero ...
            Break                         ; Break out of the loop as it means that the string has a syntax error, e.g. "two thousand *thousand*"
         Array := Thou.Clone()            ; Copy the Thou array into a temporary array
         for Key, Value in Array          ; For each (Key,Value) pair in the temporary array ...
            if (Value >= ThouValue)       ; If the Value is larger than or equal than the value associated with the current word ...
               Thou.Remove(Key)           ; Remove the pair as a way to detect syntax errors, e.g. "two thousand one thousand"
         if (++Index > NumWords)          ; If that's the last word in the string, e.g. "two hundred sixty four *million*", ...
            Return Total + Sum            ; Return the result
      }
      else                                ; If the next word is not a member of the Thousands array ...
         Break                            ; Break out of the loop as it means that the string has a syntax error, e.g. "one one million"
      Total += Sum                        ; Add the word block sum to the running total
   }
   ErrorLevel := 2                        ; If the end of string is not detected because there is a syntax error, e.g. "four three", set the corresponding error code
   Return                                 ; Return with a null result
}

; Reference: http://www.autohotkey.com/board/topic/53429-function-easy-text-to-speech/

TTS(oVoice, command, param1="", param2="") {		; by Learning one. For AHK_L. Thanks: jballi, Sean, Frankie.
	; AHK forum location:	www.autohotkey.com/forum/topic57773.html
	; Read more:			msdn.microsoft.com/en-us/library/ms723602(v=VS.85).aspx, www.autohotkey.com/forum/topic45471.html, www.autohotkey.com/forum/topic83162.html
	static CommandList := "ToggleSpeak,Speak,SpeakWait,Pause,Stop,SetRate,SetVolume,SetPitch,SetVoice,GetVoices,GetStatus,GetCount,SpeakToFile"
	if command not in %CommandList%
	{
		MsgBox, 16, TTS() error, "%command%" is not valid command.
		return
	}
	if command = ToggleSpeak	; speak or stop speaking
	{
		Status := oVoice.Status.RunningState
		if Status = 1	; finished
		oVoice.Speak(param1,0x1)	; speak asynchronously
		Else if Status = 0	; paused
		{
			oVoice.Resume
			oVoice.Speak("",0x1|0x2)	; stop
			oVoice.Speak(param1,0x1)	; speak asynchronously
		}
		Else if Status = 2	; reading
		oVoice.Speak("",0x1|0x2)	; stop
	}
	Else if command = Speak		; speak asynchronously
	{
		Status := oVoice.Status.RunningState
		if Status = 0	; paused
		oVoice.Resume
		oVoice.Speak("",0x1|0x2)	; stop
		oVoice.Speak(param1,0x1)	; speak asynchronously
	}
	Else if command = SpeakWait		; speak synchronously
	{
		Status := oVoice.Status.RunningState
		if Status = 0	; paused
		oVoice.Resume
		oVoice.Speak("",0x1|0x2)	; stop
		oVoice.Speak(param1,0x0)	; speak synchronously
	}
	Else if command = Pause	; Pause toggle
	{
		Status := oVoice.Status.RunningState
		if Status = 0	; paused
		oVoice.Resume
		else if Status = 2	; reading
		oVoice.Pause
	}
	Else if command = Stop
	{
		Status := oVoice.Status.RunningState
		if Status = 0	; paused
		oVoice.Resume
		oVoice.Speak("",0x1|0x2)	; stop
	}
	Else if command = SetRate
		oVoice.Rate := param1		; rate (reading speed): param1 from -10 to 10. 0 is default.
	Else if command = SetVolume
		oVoice.Volume := param1		; volume (reading loudness): param1 from 0 to 100. 100 is default
	Else if command = SetPitch				; http://msdn.microsoft.com/en-us/library/ms717077(v=vs.85).aspx
		oVoice.Speak("<pitch absmiddle = '" param1 "'/>",0x20)	; pitch : param1 from -10 to 10. 0 is default.
	Else if command = SetVoice
	{
		Loop, % oVoice.GetVoices.Count
		{
			Name := oVoice.GetVoices.Item(A_Index-1).GetAttribute("Name")	; 0 based
			If (Name = param1)
			{
				DoesVoiceExist := 1
				break
			}
		}
		if !DoesVoiceExist
		{
			MsgBox,64,, Voice "%param1%" does not exist.
			return
		}
		While !(oVoice.Status.RunningState = 1)
		Sleep, 20
		oVoice.Voice := oVoice.GetVoices("Name=" param1).Item(0) ; set voice to param1
	}
	Else if command = GetVoices
	{
		param1 := (param1 = "") ? "`n" : param1		; param1 as delimiter
		VoiceList =   ; Added by iPhilip to prevent warnings from #Warn
		Loop, % oVoice.GetVoices.Count
		{
			Name := oVoice.GetVoices.Item(A_Index-1).GetAttribute("Name")	; 0 based
			VoiceList .= Name param1
		}
		Return RTrim(VoiceList,param1)
	}
	Else if command = GetStatus
	{
		Status := oVoice.Status.RunningState
		if Status = 0 ; paused
		Return "paused"
		Else if Status = 1 ; finished
		Return "finished"
		Else if Status = 2 ; reading
		Return "reading"
	}
	Else if command = GetCount
		return oVoice.GetVoices.Count
	Else if command = SpeakToFile	; param1 = TextToSpeak,    param2 = OutputFilePath
	{
		oldAOS := oVoice.AudioOutputStream
		oldAAOFCONS := oVoice.AllowAudioOutputFormatChangesOnNextSet
		oVoice.AllowAudioOutputFormatChangesOnNextSet := 1

		SpStream := ComObjCreate("SAPI.SpFileStream")
		FileDelete, % param2	; OutputFilePath
		SpStream.Open(param2, 3)
		oVoice.AudioOutputStream := SpStream
		TTS(oVoice, "SpeakWait", param1)
		SpStream.Close()
		oVoice.AudioOutputStream := oldAOS
		oVoice.AllowAudioOutputFormatChangesOnNextSet := oldAAOFCONS
	}
}
 TTS_CreateVoice(VoiceName="", VoiceRate="", VoiceVolume="", VoicePitch="") {		; by Learning one. For AHK_L.
	oVoice := ComObjCreate("SAPI.SpVoice")
	if !(VoiceName = "")
		TTS(oVoice, "SetVoice", VoiceName)
	if VoiceRate between -10 and 10
		oVoice.Rate := VoiceRate		; rate (reading speed): from -10 to 10. 0 is default.
	if VoiceVolume between 0 and 100
		oVoice.Volume := VoiceVolume	; volume (reading loudness): from 0 to 100. 100 is default
	if VoicePitch between -10 and 10
		TTS(oVoice, "SetPitch", VoicePitch)	; pitch: from -10 to 10. 0 is default.
	return oVoice
}