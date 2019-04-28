;MS_SAPI by icuurd12b42
;
; Wrapper create and enum Definitions 
; I got most of what I need. if you want more simply grab it off MS's site
;
; I'm not going to wrap this in a silly little clss. it's COM it's already in a set of silly little classes
;
; what you will find here are the enums in the form of a class
;
; and the helper com creates for instance not created for you by a base object function
;
; You just pass the New_Object function the prefict of you function event handler(s) and you are set to go
;
; the examples pretty much cover everything in excruciating detail especially on recognition because
; a silly "here's my series of commands I want you to detect class" is simply too limiting, expecially
; when the SAPI system is so easy to setup a real complex systems with an xml rule definition!!! You just need to take one aspect at a time
; and not want a canned solution, because there is none. and the silly little class that does simple little things poorly
; is the reason most people think SAPI is silly. It's defenitly NOT!
;

;for the Microsft Speech API 5.4

;LIMITATION
;Win32 only and your imagination... and the confusing uber complex hierarchy

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;recog stuff
;https://msdn.microsoft.com/en-us/library/ee125205(v=vs.85).aspx
Class SpeechRecoContextState {
    static SRCS_Disabled := 0
    static SRCS_Enabled := 1
}
;Back mapping array
;use gArrName[Retval+1] to translate a value from the enum
global gSpeechRecoContextStateArr := ["SRCS_Disabled"
                        ,"SRCS_Enabled"]


;https://technet.microsoft.com/en-us/library/ee125211(v=vs.85).aspx
class SpeechRuleState {
    static SGDSInactive := 0
    static SGDSActive := 1
    static SGDSActiveWithAutoPause := 3
    static SGDSActiveUserDelimited := 4
}
;Back mapping array
;use gArrName[Retval+1] to translate a value from the enum
global gSpeechRuleStateArr := ["SGDSInactive"
                        ,"SGDSActive"
                        ,"SGDSActiveWithAutoPause"
                        ,"SGDSActiveWithAutoPause"
                        ,"SGDSActiveUserDelimited"]

Class SpeechGrammarState{
    static SGSDisabled := 0
    static SGSEnabled := 1
    static SGSExclusive := 3
}
;Back mapping array
;use gArrName[Retval+1] to translate a value from the enum
global gSpeechGrammarStateArr := ["SGSDisabled"
                        ,"SGSEnabled"
                        ,"SGSExclusive"]
                        
;https://msdn.microsoft.com/en-us/library/ee125203(v=vs.85).aspx
class SpeechLoadOption {
    static SLOStatic := 0
    static SLODynamic := 1
}
;Back mapping array
;use gArrName[Retval+1] to translate a value from the enum
global gSpeechLoadOptionArr := ["SLOStatic", "SLODynamic"]

;https://msdn.microsoft.com/en-us/library/ms720828(v=vs.85).aspx
class SpeechRecognitionType {
    static SRTStandard := 0
    static SRTAutopause := 1
    static SRTEmulated := 2
    static SRTSMLTimeout := 3
    static SRTExtendableParse := 4
    static SRTReSent := 5
}
;Back mapping array
;use gArrName[Retval+1] to translate a value from the enum
global gSpeechRecognitionTypeArr := ["SRTStandard"
                        ,"SRTAutopause"
                        ,"SRTEmulated"
                        ,"SRTSMLTimeout"
                        ,"SRTExtendableParse"
                        ,"SRTReSent"]

;https://msdn.microsoft.com/en-us/library/ee125208(v=vs.85).aspx
class SpeechRecognizerState {
    static SRSInactive := 0
    static SRSActive := 1
    static SRSActiveAlways := 2
    static SRSInactiveWithPurge := 3
}
;Back mapping array
;use gArrName[Retval+1] to translate a value from the enum
global gSpeechRecognizerStateArr := ["SRSInactive"
                        ,"SRSActive"
                        ,"SRSActiveAlways"
                        ,"SRSInactiveWithPurge"]

;https://msdn.microsoft.com/en-us/library/ee125191(v=vs.85).aspx
class SpeechBookmarkOptions {
    static SBONone := 0
    static SBOPause := 1
}
;Back mapping array
;use gArrName[Retval+1] to translate a value from the enum
global gSpeechBookmarkOptionsArr := ["SBONone", "SBOPause"]

;https://msdn.microsoft.com/en-us/library/ee125201(v=vs.85).aspx
class SpeechInterference
{
    static SINone := 0
    static SINoise := 1
    static SINoSignal := 2
    static SITooLoud := 3
    static SITooQuiet := 4
    static SITooFast := 5
    static SITooSlow := 6
    static SILatencyWarning := 7
    static SILatencyTruncateBegin := 8
    static SILatencyTruncateEnd := 9
}
;Back mapping array
;use gArrName[Retval+1] to translate a value from the enum
global gSpeechInterferenceArr := ["SINone"
                        ,"SINoise"
                        ,"SINoSignal"
                        ,"SITooLoud"
                        ,"SITooQuiet"
                        ,"SITooFast"
                        ,"SITooSlow"
                        ,"SILatencyWarning"
                        ,"SILatencyTruncateBegin"
                        ,"SILatencyTruncateEnd"]

;https://msdn.microsoft.com/en-us/library/ee125206(v=vs.85).aspx
Class SpeechRecoEvents {
    static SREStreamEnd := 1
    static SRESoundStart := 2
    static SRESoundEnd := 4
    static SREPhraseStart := 8
    static SRERecognition := 16
    static SREHypothesis := 32
    static SREBookmark := 64
    static SREPropertyNumChange := 128
    static SREPropertyStringChange := 256
    static SREFalseRecognition := 512
    static SREInterference := 1024
    static SRERequestUI := 2048
    static SREStateChange := 4096
    static SREAdaptation := 8192
    static SREStreamStart := 16384
    static SRERecoOtherContext := 32768
    static SREAudioLevel := 65536
    static SREPrivate := 262144
    static SREAllEvents := 393215
}

;Thank god for that guy
;http://eggbox.fantomfactory.org/pods/afFancomSapi/api/SpeechStringConstants/src#line17
class SpeechStringConstants {

    ;** Value is '*'
    static SpeechGrammarTagDictation := "*"

    ;** Value is '*+'
    static SpeechGrammarTagUnlimitedDictation := "*+"

    ;** Value is '...'
    static SpeechGrammarTagWildcard := "..."

    ;** Value is 'AdaptationOn'
    static SpeechPropertyAdaptationOn := "AdaptationOn"

    ;** Value is 'AddRemoveWord'
    static SpeechAddRemoveWord := "AddRemoveWord"

    ;** Value is 'Attributes'
    static SpeechTokenKeyAttributes := "Attributes"

    ;** Value is 'AudioProperties'
    static SpeechAudioProperties := "AudioProperties"

    ;** Value is 'AudioVolume'
    static SpeechAudioVolume := "AudioVolume"

    ;** Value is 'CLSID'
    static SpeechTokenValueCLSID := "CLSID"

    ;** Value is 'ComplexResponseSpeed'
    static SpeechPropertyComplexResponseSpeed := "ComplexResponseSpeed"

    ;** Value is 'DefaultTTSRate'
    static SpeechVoiceCategoryTTSRate := "DefaultTTSRate"

    ;** Value is 'EngineProperties'
    static SpeechEngineProperties := "EngineProperties"

    ;** Value is 'Files'
    static SpeechTokenKeyFiles := "Files"

    ;** Value is 'HKEY_CURRENT_USER\SOFTWARE\Microsoft\Speech'
    static SpeechRegistryUserRoot := "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Speech"

    ;** Value is 'HKEY_CURRENT_USER\SOFTWARE\Microsoft\Speech\CurrentUserLexicon'
    static SpeechTokenIdUserLexicon := "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Speech\CurrentUserLexicon"

    ;** Value is 'HKEY_CURRENT_USER\SOFTWARE\Microsoft\Speech\RecoProfiles'
    static SpeechCategoryRecoProfiles := "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Speech\RecoProfiles"

    ;** Value is 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech'
    static SpeechRegistryLocalMachineRoot := "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech"

    ;** Value is 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\AppLexicons'
    static SpeechCategoryAppLexicons := "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\AppLexicons"

    ;** Value is 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\AudioInput'
    static SpeechCategoryAudioIn := "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\AudioInput"

    ;** Value is 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\AudioOutput'
    static SpeechCategoryAudioOut := "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\AudioOutput"

    ;** Value is 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\PhoneConverters'
    static SpeechCategoryPhoneConverters := "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\PhoneConverters"

    ;** Value is 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\Recognizers'
    static SpeechCategoryRecognizers := "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\Recognizers"

    ;** Value is 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\Voices'
    static SpeechCategoryVoices := "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\Voices"

    ;** Value is 'HighConfidenceThreshold'
    static SpeechPropertyHighConfidenceThreshold := "HighConfidenceThreshold"

    ;** Value is 'LowConfidenceThreshold'
    static SpeechPropertyLowConfidenceThreshold := "LowConfidenceThreshold"

    ;** Value is 'MicTraining'
    static SpeechMicTraining := "MicTraining"

    ;** Value is 'NormalConfidenceThreshold'
    static SpeechPropertyNormalConfidenceThreshold := "NormalConfidenceThreshold"

    ;** Value is 'RecoProfileProperties'
    static SpeechRecoProfileProperties := "RecoProfileProperties"

    ;** Value is 'ResourceUsage'
    static SpeechPropertyResourceUsage := "ResourceUsage"

    ;** Value is 'ResponseSpeed'
    static SpeechPropertyResponseSpeed := "ResponseSpeed"

    ;** Value is 'Sentence'
    static SpeechVoiceSkipTypeSentence := "Sentence"

    ;** Value is 'Spelling'
    static SpeechDictationTopicSpelling := "Spelling"

    ;** Value is 'UI'
    static SpeechTokenKeyUI := "UI"

    ;** Value is 'UserTraining'
    static SpeechUserTraining := "UserTraining"

    ;** Value is '{7CEEF9F9-3D13-11d2-9EE7-00C04F797396}'
    static SpeechAudioFormatGUIDText := "{7CEEF9F9-3D13-11d2-9EE7-00C04F797396}"

    ;** Value is '{C31ADBAE-527F-4ff5-A230-F62BB61FF70C}'
    static SpeechAudioFormatGUIDWave := "{C31ADBAE-527F-4ff5-A230-F62BB61FF70C}"


}
;https://msdn.microsoft.com/en-us/library/ee125069(v=vs.85).aspx
New_SpSharedRecoContext(handlerPrefix:="") 
{
    Com := 0
    try
    {
        Com := ComObjCreate("SAPI.SpSharedRecoContext") ;obtain speech recognizer (ISpeechRecognizer object)
    }
    catch e
    {
        throw Exception("New_SpSharedRecoContext ComObjCreate " . e.Message)
    }
    if(handlerPrefix!="")
    {
        try
        {
            ComObjConnect(Com , handlerPrefix)
        }
        catch e
        {
            throw Exception("New_SpSharedRecoContext ComObjConnect " . e.Message)
        }
    }
    return Com
}


;https://msdn.microsoft.com/en-us/library/ee125052(v=vs.85).aspx
New_SpInProcRecoContext(handlerPrefix:="") 
{
    Com := 0
    try
    {
        Com := ComObjCreate("SAPI.SpInProcRecoContext") ;obtain speech recognizer (ISpeechRecognizer object)
    }
    catch e
    {
        throw Exception("New_SpInProcRecoContext ComObjCreate " . e.Message)
    }
    if(handlerPrefix!="")
    {
        try
        {
            ComObjConnect(Com , handlerPrefix)
        }
        catch e
        {
            throw Exception("New_SpInProcRecoContext ComObjConnect " . e.Message)
        }
    }
    return Com
}

;https://msdn.microsoft.com/en-us/library/ee125580(v=vs.85).aspx
New_SpObjectTokenCategory(handlerPrefix:="") 
{
    Com := 0
    try
    {
        Com := ComObjCreate("SAPI.SpObjectTokenCategory") ;obtain speech recognizer (ISpeechRecognizer object)
    }
    catch e
    {
        throw Exception("New_SpObjectTokenCategory ComObjCreate " . e.Message)
    }
    if(handlerPrefix!="")
    {
        try
        {
            ComObjConnect(Com , handlerPrefix)
        }
        catch e
        {
            throw Exception("New_SpObjectTokenCategory ComObjConnect " . e.Message)
        }
    }
    return Com
}

New_SpObjectToken(handlerPrefix:="") 
{
    Com := 0
    try
    {
        Com := ComObjCreate("SAPI.SpObjectToken") ;obtain speech recognizer (ISpeechRecognizer object)
    }
    catch e
    {
        throw Exception("New_SpObjectToken ComObjCreate " . e.Message)
    }
    if(handlerPrefix!="")
    {
        try
        {
            ComObjConnect(Com , handlerPrefix)
        }
        catch e
        {
            throw Exception("New_SpObjectToken ComObjConnect " . e.Message)
        }
    }
    return Com
}
;recog stuff END
;;;;;;;;;;;;;;;;;;;;;;;;;;;
        


;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Text To Speech Stuff
;https://msdn.microsoft.com/en-us/library/ee125223(v=vs.85).aspx
; Some missing values I gor frem secondary source
class SpeechVoiceSpeakFlags {
    static SVSFDefault := 0
    static SVSFlagsAsync := 1
    static SVSFPurgeBeforeSpeak := 2
    static SVSFIsFilename := 4
    static SVSFIsXML := 8
    static SVSFIsNotXML := 16
    static SVSFPersistXML := 32
    static SVSFNLPSpeakPunc := 64 
    static SVSFParseSapi := 128 ;was missing
    static SVSFParseSsml := 256 ;was missing
    static SVSFParseAutoDetect := 0 ;was missing
    static SVSFNLPMask := 64
    static SVSFParseMask := 384 ;was missing
    static SVSFVoiceMask := 511 ;127 ;Original, other source is 511
    static SVSFUnusedFlags := 0xfffffe00 ;original is -128, this other source may be more compatible
}
/*

SVSFDefault = 0,
        SVSFlagsAsync = 1,
        SVSFPurgeBeforeSpeak = 2,
        SVSFIsFilename = 4,
        SVSFIsXML = 8,
        SVSFIsNotXML = 16,
        SVSFPersistXML = 32,
        SVSFNLPSpeakPunc = 64,
        SVSFParseSapi = 128,
        SVSFParseSsml = 256,
        SVSFParseAutodetect = 0,
        SVSFNLPMask = 64,
        SVSFParseMask = 384,
        SVSFVoiceMask = 511,
        SVSFUnusedFlags = 0xfffffe00
*/

;https://msdn.microsoft.com/en-us/library/ee431843(v=vs.85).aspx
;and another set?!!!
class SPEAKFLAGS {

    static SPF_DEFAULT := 0
    static SPF_ASYNC := 1
    static SPF_PURGEBEFORESPEAK := 2
    static SPF_IS_FILENAME := 3
    static SPF_IS_XML := 4
    static SPF_IS_NOT_XML := 5
    static SPF_PERSIST_XML := 6

    static SPF_NLP_SPEAK_PUNC := 7

    static SPF_PARSE_SAPI := 8
    static SPF_PARSE_SSML := 9
    static SPF_PARSE_AUTODETECT := 10

    static SPF_NLP_MASK := 11
    static SPF_PARSE_MASK := 12
    static SPF_VOICE_MASK := 13
    static SPF_UNUSED_FLAGS := 14
} 
        
New_SpVoice(handlerPrefix:="") 
{
    Com := 0
    try
    {
        Com := ComObjCreate("SAPI.SpVoice") ;obtain speech recognizer (ISpeechRecognizer object)
    }
    catch e
    {
        throw Exception("New_SpVoice ComObjCreate " . e.Message)
    }
    if(handlerPrefix!="")
    {
        try
        {
            ComObjConnect(Com , handlerPrefix)
        }
        catch e
        {
            throw Exception("New_SpVoice ComObjConnect " . e.Message)
        }
    }
    return Com
}
;Text To Speech stuff END
;;;;;;;;;;;;;;;;;;;;;;;;;;;


SAPIDecodeErrorFromExceptionString(ExceptionString)
{
    StartPos := InStr(ExceptionString, "0x")
    err := SubStr(ExceptionString, StartPos , 10)
    if(err == "0x80045001")
    {
        return err . " - The object has not been properly initialized."
    }
    else if(err=="0x80045002")
    {
        return err . " - The object has already been initialized."
    }
    else if(err=="0x80045003")
    {
        return err . " - The caller has specified an unsupported format."
    }
    else if(err=="0x80045004")
    {
        return err . " - The caller has specified invalid flags for this operation."
    }
    else if(err=="0x00045005")
    {
        return err . " - The operation has reached the end of stream."
    }
    else if(err=="0x80045006")
    {
        return err . " - The wave device is busy."
    }
    else if(err=="0x80045007")
    {
        return err . " - The wave device is not supported."
    }
    else if(err=="0x80045008")
    {
        return err . " - The wave device is not enabled."
    }
    else if(err=="0x80045009")
    {
        return err . " - There is no wave driver installed."
    }
    else if(err=="0x8004500a")
    {
        return err . " - The file must be Unicode."
    }
    else if(err=="0x0004500b")
    {
        return err . " -  "
    }
    else if(err=="0x8004500c")
    {
        return err . " - The phrase ID specified does not exist or is out of range."
    }
    else if(err=="0x8004500d")
    {
        return err . " - The caller provided a buffer too small to return a result."
    }
    else if(err=="0x8004500e")
    {
        return err . " - Caller did not specify a format prior to opening a stream."
    }
    else if(err=="0x8004500f")
    {
        return err . " - The stream I/O was stopped by setting the audio object to the stopped state. This will be returned for both read and write streams."
    }
    else if(err=="0x00045010")
    {
        return err . " - This will be returned only on input (read) streams when the stream is paused. Reads on paused streams will not block, and this return code indicates that all of the data has been removed from the stream."
    }
    else if(err=="0x80045011")
    {
        return err . " - Invalid rule name passed to ActivateGrammar."
    }
    else if(err=="0x80045012")
    {
        return err . " - An exception was raised during a call to the current TTS driver."
    }
    else if(err=="0x80045013")
    {
        return err . " - An exception was raised during a call to an application sentence filter."
    }
    else if(err=="0x80045014")
    {
        return err . " - In speech recognition, the current method cannot be performed while a grammar rule is active."
    }
    else if(err=="0x00045015")
    {
        return err . " - The operation was successful, but only with automatic stream format conversion."
    }
    else if(err=="0x00045016")
    {
        return err . " - There is currently no hypothesis recognition available."
    }
    else if(err=="0x80045017")
    {
        return err . " - Cannot create a new object instance for the specified object category."
    }
    else if(err=="0x00045018")
    {
        return err . " - The word, pronunciation, or POS pair being added is already in lexicon."
    }
    else if(err=="0x80045019")
    {
        return err . " - The word does not exist in the lexicon."
    }
    else if(err=="0x0004501a")
    {
        return err . " - The client is currently synced with the lexicon."
    }
    else if(err=="0x8004501b")
    {
        return err . " - The client is excessively out of sync with the lexicon. Mismatches may not sync incrementally."
    }
    else if(err=="0x8004501c")
    {
        return err . " - A rule reference in a grammar was made to a named rule that was never defined."
    }
    else if(err=="0x8004501d")
    {
        return err . " - A non-dynamic grammar rule that has no body."
    }
    else if(err=="0x8004501e")
    {
        return err . " - The grammar compiler failed due to an internal state error."
    }
    else if(err=="0x8004501f")
    {
        return err . " - An attempt was made to modify a non-dynamic rule."
    }
    else if(err=="0x80045020")
    {
        return err . " - A rule name was duplicated."
    }
    else if(err=="0x80045021")
    {
        return err . " - A resource name was duplicated for a given rule."
    }
    else if(err=="0x80045022")
    {
        return err . " - Too many grammars have been loaded."
    }
    else if(err=="0x80045023")
    {
        return err . " - Circular reference in import rules of grammars."
    }
    else if(err=="0x80045024")
    {
        return err . " - A rule reference to an imported grammar that could not be resolved."
    }
    else if(err=="0x80045025")
    {
        return err . " - The format of the WAV file is not supported."
    }
    else if(err=="0x00045026")
    {
        return err . " - This success code indicates that an SR method called with the SPRIF_ASYNC flag is being processed. When it has finished processing, an SPFEI_ASYNC_COMPLETED event will be generated."
    }
    else if(err=="0x80045027")
    {
        return err . " - A grammar rule was defined with a null path through the rule. That is, it is possible to satisfy the rule conditions with no words."
    }
    else if(err=="0x80045028")
    {
        return err . " - It is not possible to change the current engine or input. This occurs in the following cases: 1) SelectEngine called while a recognition context exists, or 2) SetInput called in the shared instance case."
    }
    else if(err=="0x80045029")
    {
        return err . " - A rule exists with matching IDs (names) but different names (IDs)."
    }
    else if(err=="0x8004502a")
    {
        return err . " - A grammar contains no top-level, dynamic, or exported rules. There is no possible way to activate or otherwise use any rule in this grammar."
    }
    else if(err=="0x8004502b")
    {
        return err . " - Rule 'A' refers to a second rule 'B' which, in turn, refers to rule 'A'."
    }
    else if(err=="0x0004502c")
    {
        return err . " - Parse path cannot be parsed given the currently active rules."
    }
    else if(err=="0x8004502d")
    {
        return err . " - Parse path cannot be parsed given the currently active rules."
    }
    else if(err=="0x8004502e")
    {
        return err . " - A marshaled remote call failed to respond."
    }
    else if(err=="0x8004502f")
    {
        return err . " - This will only be returned on input (read) streams when the stream is paused because the SR driver has not retrieved data recently."
    }
    else if(err=="0x80045030")
    {
        return err . " - The result does not contain any audio, nor does the portion of the element chain of the result contain any audio."
    }
    else if(err=="0x80045031")
    {
        return err . " - This alternate is no longer a valid alternate to the result it was obtained from. Returned from ISpPhraseAlt methods."
    }
    else if(err=="0x80045032")
    {
        return err . " - The result does not contain any audio, nor does the portion of the element chain of the result contain any audio. Returned from ISpResult::GetAudio and ISpResult::SpeakAudio."
    }
    else if(err=="0x80045033")
    {
        return err . " - The XML format string for this RULEREF is invalid, e.g. not a GUID or REFCLSID."
    }
    else if(err=="0x00045034")
    {
        return err . " - The operation is not supported for stream input."
    }
    else if(err=="0x80045035")
    {
        return err . " - The operation is invalid for all but newly created application lexicons."
    }
    else if(err=="0x80045036")
    {
        return err . " - The word exists but without pronunciation."
    }
    else if(err=="0x00045037")
    {
        return err . " - The word exists but without pronunciation."
    }
    else if(err=="0x80045038")
    {
        return err . " - An operation was attempted on a stream object that has been closed."
    }
    else if(err=="0x80045039")
    {
        return err . " - When enumerating items, the requested index is greater than the count of items."
    }
    else if(err=="0x8004503a")
    {
        return err . " - The requested data item (data key, value, etc.) was not found."
    }
    else if(err=="0x8004503b")
    {
        return err . " - Audio state passed to SetState() is invalid."
    }
    else if(err=="0x8004503c")
    {
        return err . " - A generic MMSYS error not caught by _MMRESULT_TO_HRESULT."
    }
    else if(err=="0x8004503d")
    {
        return err . " - An exception was raised during a call to the marshaling code."
    }
    else if(err=="0x8004503e")
    {
        return err . " - Attempt was made to manipulate a non-dynamic grammar."
    }
    else if(err=="0x8004503f")
    {
        return err . " - Cannot add ambiguous property."
    }
    else if(err=="0x80045040")
    {
        return err . " - The key specified is invalid."
    }
    else if(err=="0x80045041")
    {
        return err . " - The token specified is invalid."
    }
    else if(err=="0x80045042")
    {
        return err . " - The xml parser failed due to bad syntax."
    }
    else if(err=="0x80045043")
    {
        return err . " - The xml parser failed to load a required resource (e.g., voice, phoneconverter, etc.)."
    }
    else if(err=="0x80045044")
    {
        return err . " - Attempted to remove registry data from a token that is already in use elsewhere."
    }
    else if(err=="0x80045045")
    {
        return err . " - Attempted to perform an action on an object token that has had associated registry key deleted."
    }
    else if(err=="0x80045046")
    {
        return err . " - The selected voice was registered as multi-lingual. SAPI does not support multi-lingual registration."
    }
    else if(err=="0x80045047")
    {
        return err . " - Exported rules cannot refer directly or indirectly to a dynamic rule."
    }
    else if(err=="0x80045048")
    {
        return err . " - Error parsing the SAPI Text Grammar Format (XML grammar)."
    }
    else if(err=="0x80045049")
    {
        return err . " - Incorrect word format, probably due to incorrect pronunciation string."
    }
    else if(err=="0x8004504a")
    {
        return err . " - Methods associated with active audio stream cannot be called unless stream is active."
    }
    else if(err=="0x8004504b")
    {
        return err . " - Arguments or data supplied by the engine are in an invalid format or are inconsistent."
    }
    else if(err=="0x8004504c")
    {
        return err . " - An exception was raised during a call to the current SR engine."
    }
    else if(err=="0x8004504d")
    {
        return err . " - Stream position information supplied from engine is inconsistent."
    }
    else if(err=="0x0004504e")
    {
        return err . " - Operation could not be completed because the recognizer is inactive. It is inactive either because the recognition state is currently inactive or because no rules are active."
    }
    else if(err=="0x8004504f")
    {
        return err . " - When making a remote call to the server, the call was made on the wrong thread."
    }
    else if(err=="0x80045050")
    {
        return err . " - The remote process terminated unexpectedly."
    }
    else if(err=="0x80045051")
    {
        return err . " - The remote process is already running; it cannot be started a second time."
    }
    else if(err=="0x80045052")
    {
        return err . " - An attempt to load a CFG grammar with a LANGID different than other loaded grammars."
    }
    else if(err=="0x00045053")
    {
        return err . " - A grammar-ending parse has been found that does not use all available words."
    }
    else if(err=="0x80045054")
    {
        return err . " - An attempt to deactivate or activate a non top-level rule."
    }
    else if(err=="0x00045055")
    {
        return err . " - An attempt to parse when no rule was active."
    }
    else if(err=="0x80045056")
    {
        return err . " - An attempt to ask a container lexicon for all words at once."
    }
    else if(err=="0x00045057")
    {
        return err . " - An attempt to activate a rule/dictation/etc without calling SetInput first in the InProc case."
    }
    else if(err=="0x80045059")
    {
        return err . " - The requested language is not supported."
    }
    else if(err=="0x8004505a")
    {
        return err . " - The operation cannot be performed because the voice is currently paused."
    }
    else if(err=="0x8004505b")
    {
        return err . " - This will only be returned on input (read) streams when the real time audio device stops returning data for a long period of time."
    }
    else if(err=="0x8004505c")
    {
        return err . " - An audio device stopped returning data from the Read() method even though it was in the run state. This error is only returned in the END_SR_STREAM event."
    }
    else if(err=="0x8004505d")
    {
        return err . " - The SR engine is unable to add this word to a grammar. The application may need to supply an explicit pronunciation for this word."
    }
    else if(err=="0x8004505e")
    {
        return err . " - An attempt to call ScaleAudio on a recognition result having previously called GetAlternates. Allowing the call to succeed would result in the previously created alternates located in incorrect audio stream positions."
    }
    else if(err=="0x8004505f")
    {
        return err . " - The method called is not supported for the shared recognizer For example, ISpRecognizer::GetInputStream()."
    }
    else if(err=="0x80045060")
    {
        return err . " - A task could not complete because the SR engine had timed out."
    }
    else if(err=="0x80045061")
    {
        return err . " - An SR engine called synchronize while inside of a synchronize call."
    }
    else if(err=="0x80045062")
    {
        return err . " - The grammar contains a node no arcs."
    }
    else if(err=="0x80045063")
    {
        return err . " - Neither audio output nor input is supported for non-active console sessions."
    }
    else if(err=="0x80045064")
    {
        return err . " - The object is a stale reference and is invalid to use. For example, having an ISpeechGrammarRule object reference and then calling ISpeechRecoGrammar::Reset() will cause the rule object to be invalidated. Calling any methods after this will result in this error."
    }
    else if(err=="0x00045065")
    {
        return err . " - This can be returned when Read or Write attempts to call audio streams when the stream is stopped."
    }
    else if(err=="0x80045066")
    {
        return err . " - The Recognition Parse Tree couldn't be generated. For example, the rule name may begin with a numeric digit. The XML parser does not allow this."
    }
    else if(err=="0x80045067")
    {
        return err . " - The SML could not be generated. For example, the transformation XSLT template may not be well-formed."
    }
    else if(err=="0x80045068")
    {
        return err . " - The current voice is not a prompt voice, so the ISpPromptVoice functions do not work."
    }
    else if(err=="0x80045069")
    {
        return err . " - There is already a root rule for this grammar. Defining another root rule will fail."
    }
    else if(err=="0x80045070")
    {
        return err . " - Support for embedded script not supported because browser security settings have disabled it."
    }
    else if(err=="0x80045071")
    {
        return err . " - A time-out occurred while starting the SAPI server."
    }
    else if(err=="0x80045072")
    {
        return err . " - A time-out occurred obtaining the lock for starting or connecting to the SAPI server"
    }
    else if(err=="0x80045073")
    {
        return err . " - When a CFG grammar is loaded, the security manager cannot be changed."
    }
    else if(err=="0x00045074")
    {
        return err . " - Parse is valid but could be extendable (internal use only)"
    }
    else
    {
        return "Unknown Error: " . ExceptionString 
    }
}