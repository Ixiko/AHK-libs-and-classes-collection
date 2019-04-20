;-------------------------------------------------------------------------------
; Text-to-speech function by jballi
; http://www.autohotkey.com/board/topic/41870-text-to-speech-via-com-examples/
;
;
; This script is included in all of the example scripts.  It contains constants
; that are used by various SpVoice methods.
;
;-------------------------------------------------------------------------------


;*******************
;*                 *
;*    Constants    *
;*                 *
;*******************
;[============]
;[  Priority  ]
;[============]
SVPNormal:=0
    ;-- Normal voice. Text streams spoken by a normal voice are added to the end
    ;   of the voice queue. A voice with SVPNormal priority cannot interrupt
    ;   another voice.

SVPAlert:=1
    ;-- Alert voice. Text streams spoken by an alert voice are inserted into the
    ;   voice queue ahead of normal voice streams.  An alert voice will
    ;   interrupt a normal voice, which will resume speaking when the alert
    ;   voice has finished speaking.

SVPOver:=2
    ;-- Over voice. Text streams spoken by an over voice go into the voice queue
    ;   ahead of normal and alert streams.  An over voice will not interrupt,
    ;   but speaks over (mixes with) the voices of lower priorities.


;[===============]
;[  Speak Flags  ]
;[===============]
SVSFDefault:=0x0
    ;-- Specifies that the default settings should be used. The defaults are:
    ;
    ;     - To speak the given text string synchronously (override with
    ;       SVSFlagsAsync),
    ;
    ;     - Not to purge pending speak requests (override with
    ;       SVSFPurgeBeforeSpeak),
    ;
    ;     - To parse the text as XML only if the first character is a
    ;       left-angle-bracket (override with SVSFIsXML or SVSFIsNotXML),
    ;
    ;     - Not to persist global XML state changes across speak calls (override
    ;       with SVSFPersistXML), and
    ;
    ;     - Not to expand punctuation characters into words (override with
    ;       SVSFNLPSpeakPunc).

SVSFlagsAsync:=0x1
    ;-- Specifies that the Speak call should be asynchronous. That is, it will
    ;   return immediately after the speak request is queued.

SVSFPurgeBeforeSpeak:=0x2
    ;-- Purges all pending speak requests prior to this speak call.

SVSFIsFilename:=0x4
    ;-- The string passed to the Speak method is a file name rather than text.
    ;   As a result, the string itself is not spoken but rather the file the
    ;   path that points to is spoken.

SVSFIsXML:=0x8
    ;-- The input text will be parsed for XML markup.

SVSFIsNotXML:=0x10  ;-- (16)
    ;-- The input text will not be parsed for XML markup.

SVSFPersistXML:=0x20  ;-- (32)
    ;-- Global state changes in the XML markup will persist across speak calls.

SVSFNLPSpeakPunc:=0x40  ;-- (64)
    ;-- Punctuation characters should be expanded into words (e.g. "This is it."
    ;   would become "This is it period").


;[=====================]
;[  SpeechVoiceEvents  ]
;[=====================]
SVEStartInputStream:=2
    ;-- Represents the StartStream event, which occurs when the engine begins
    ;   speaking a stream.

SVEEndInputStream:=4
    ;-- Represents the EndStream event, which occurs when the engine encounters
    ;   the end of a stream while speaking.

SVEVoiceChange:=8
    ;-- Represents the VoiceChange event, which occurs when the engine
    ;   encounters a change of Voice while speaking.

SVEBookmark:=16
    ;-- Represents the Bookmark event, which occurs when the engine encounters a
    ;   bookmark while speaking.

SVEWordBoundary:=32
    ;-- Represents the WordBoundary event, which occurs when the engine
    ;   completes a word while speaking.

SVEPhoneme:=64
    ;-- Represents the Phoneme event, which occurs when the engine completes a
    ;   phoneme while speaking.

SVESentenceBoundary:=128
    ;-- Represents the SentenceBoundary event, which occurs when the engine
    ;   completes a sentence while speaking.

SVEViseme:=256
    ;-- Represents the Viseme event, which occurs when the engine completes a
    ;   viseme while speaking.

SVEAudioLevel:=512
    ;-- Represents the AudioLevel event, which occurs when the engine has
    ;   completed an audio level change while speaking.

SVEPrivate:=32768
    ;-- Represents a private engine event.

SVEAllEvents:=33790
    ;-- Represents all speech voice events.


;[=======================]
;[  Status.RunningState  ]
;[=======================]
SRSEWaitingToSpeak:=0x0 
    ;-- Active but not speaking.  This status can occur under the following
    ;   conditions:
    ;
    ;     - Before the voice has begun speaking
    ;     - The voice has been paused
    ;     - The voice has been interrupted by an Alert voice
    ;
    ;   Note: There is no documented constant name for this status

SRSEDone:=0x1
    ;-- The voice has finished rendering all queued phrases.

SRSEIsSpeaking:=0x2
    ;-- The SpVoice currently claims the audio queue.

SRSETBD2:=0x3
    ;-- Undocumented.  Haven't figured out what this value represents


;[=========================]
;[  SpeechAudioFormatType  ]
;[=========================]
SAFTDefault            :=-1
SAFTNoAssignedFormat   :=0
SAFTText               :=1
SAFTNonStandardFormat  :=2
    ;-- A non-SAPI 5 standard format without a WAVEFORMATEX description.

SAFTExtendedAudioFormat:=3
    ;-- A non-SAPI 5 standard format but has WAVEFORMATEX description.

;-- Standard PCM wave formats
SAFT8kHz8BitMono    :=4
SAFT8kHz8BitStereo  :=5
SAFT8kHz16BitMono   :=6
SAFT8kHz16BitStereo :=7
SAFT11kHz8BitMono   :=8
SAFT11kHz8BitStereo :=9
SAFT11kHz16BitMono  :=10
SAFT11kHz16BitStereo:=11
SAFT12kHz8BitMono   :=12
SAFT12kHz8BitStereo :=13
SAFT12kHz16BitMono  :=14
SAFT12kHz16BitStereo:=15
SAFT16kHz8BitMono   :=16
SAFT16kHz8BitStereo :=17
SAFT16kHz16BitMono  :=18
SAFT16kHz16BitStereo:=19
SAFT22kHz8BitMono   :=20
SAFT22kHz8BitStereo :=21
SAFT22kHz16BitMono  :=22
SAFT22kHz16BitStereo:=23
SAFT24kHz8BitMono   :=24
SAFT24kHz8BitStereo :=25
SAFT24kHz16BitMono  :=26
SAFT24kHz16BitStereo:=27
SAFT32kHz8BitMono   :=28
SAFT32kHz8BitStereo :=29
SAFT32kHz16BitMono  :=30
SAFT32kHz16BitStereo:=31
SAFT44kHz8BitMono   :=32
SAFT44kHz8BitStereo :=33
SAFT44kHz16BitMono  :=34
SAFT44kHz16BitStereo:=35
SAFT48kHz8BitMono   :=36
SAFT48kHz8BitStereo :=37
SAFT48kHz16BitMono  :=38
SAFT48kHz16BitStereo:=39

;-- TrueSpeech format
SAFTTrueSpeech_8kHz1BitMono:=40

;-- A-Law formats
SAFTCCITT_ALaw_8kHzMono   :=41
SAFTCCITT_ALaw_8kHzStereo :=42
SAFTCCITT_ALaw_11kHzMono  :=43
SAFTCCITT_ALaw_11kHzStereo:=4
    ;-- Same value as SAFT8kHz8BitMono.  Not sure if this is correct.

SAFTCCITT_ALaw_22kHzMono  :=44
SAFTCCITT_ALaw_22kHzStereo:=45
SAFTCCITT_ALaw_44kHzMono  :=46
SAFTCCITT_ALaw_44kHzStereo:=47

;-- u-Law formats
SAFTCCITT_uLaw_8kHzMono   :=48
SAFTCCITT_uLaw_8kHzStereo :=49
SAFTCCITT_uLaw_11kHzMono  :=50
SAFTCCITT_uLaw_11kHzStereo:=51
SAFTCCITT_uLaw_22kHzMono  :=52
SAFTCCITT_uLaw_22kHzStereo:=53
SAFTCCITT_uLaw_44kHzMono  :=54
SAFTCCITT_uLaw_44kHzStereo:=55
SAFTADPCM_8kHzMono        :=56
SAFTADPCM_8kHzStereo      :=57
SAFTADPCM_11kHzMono       :=58
SAFTADPCM_11kHzStereo     :=59
SAFTADPCM_22kHzMono       :=60
SAFTADPCM_22kHzStereo     :=61
SAFTADPCM_44kHzMono       :=62
SAFTADPCM_44kHzStereo     :=63

;-- GSM 6.10 formats
SAFTGSM610_8kHzMono :=64
SAFTGSM610_11kHzMono:=65
SAFTGSM610_22kHzMono:=66
SAFTGSM610_44kHzMono:=67

;-- Other formats
SAFTNUM_FORMATS:=68

;-- Stream Format Type Description List (Standard PCM wave formats)
AudioOutputStreamFormatTypeDescriptionList=
   (ltrim join|
    8kHz 8 Bit Mono
    8kHz 8 Bit Stereo
    8kHz 16 Bit Mono
    8kHz 16 Bit Stereo   
    11kHz 8 Bit Mono
    11kHz 8 Bit Stereo   
    11kHz 16 Bit Mono
    11kHz 16 Bit Stereo    
    12kHz 8 Bit Mono
    12kHz 8 Bit Stereo    
    12kHz 16 Bit Mono
    12kHz 16 Bit Stereo
    16kHz 8 Bit Mono   
    16kHz 8 Bit Stereo 
    16kHz 16 Bit Mono
    16kHz 16 Bit Stereo
    22kHz 8 Bit Mono
    22kHz 8 Bit Stereo
    22kHz 16 Bit Mono
    22kHz 16 Bit Stereo
    24kHz 8 Bit Mono
    24kHz 8 Bit Stereo
    24kHz 16 Bit Mono
    24kHz 16 Bit Stereo
    32kHz 8 Bit Mono
    32kHz 8 Bit Stereo
    32kHz 16 Bit Mono
    32kHz 16 Bit Stereo
    44kHz 8 Bit Mono
    44kHz 8 Bit Stereo
    44kHz 16 Bit Mono
    44kHz 16 Bit Stereo
    48kHz 8 Bit Mono
    48kHz 8 Bit Stereo
    48kHz 16 Bit Mono
    48kHz 16 Bit Stereo
   )

;-- This list represents the descriptions for the standard PCM wave formats in
;   the same sequence that the Standard PCM wave formats constant values are
;   defined from SAFT8kHz8BitMono (4) to SAFT48kHz16BitStereo (39).  If using
;   a DropDownList control to select from this list, add the +AltSubmit
;   property to the control which will cause the control to set the output
;   variable to the selected position number (the first item is 1, the second is
;   2, etc.).  After the item has been selected, add 3 to the result so that the
;   value will match the appropriate PCM wave format type.


;[====================]
;[  SpeechVisemeType  ]
;[====================]
SVP_0 :=0   ;-- silence
SVP_1 :=1   ;-- ae, ax, ah
SVP_2 :=2   ;-- aa
SVP_3 :=3   ;-- ao
SVP_4 :=4   ;-- ey, eh, uh
SVP_5 :=5   ;-- er
SVP_6 :=6   ;-- y, iy, ih, ix
SVP_7 :=7   ;-- w, uw
SVP_8 :=8   ;-- ow
SVP_9 :=9   ;-- aw
SVP_10:=10  ;-- oy
SVP_11:=11  ;-- ay
SVP_12:=12  ;-- h
SVP_13:=13  ;-- r
SVP_14:=14  ;-- l
SVP_15:=15  ;-- s, z
SVP_16:=16  ;-- sh, ch, jh, zh
SVP_17:=17  ;-- th, dh
SVP_18:=18  ;-- f, v
SVP_19:=19  ;-- d, t, n
SVP_20:=20  ;-- k, g, ng
SVP_21:=21  ;-- p, b, m
