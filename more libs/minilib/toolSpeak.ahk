toolSpeak(str,wait:=0){
    static tts:=comObjCreate("SAPI.SpVoice")
    tts.speak(str,wait?2:3)
}