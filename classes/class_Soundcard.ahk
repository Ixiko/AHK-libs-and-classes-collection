;#warn
; Utility for changing soundcards and toggling Realtek loudness equalisation quickly.
class Soundcard
{
    static tle_dir := "D:\batcave\tle"
    static tle_exe =
    static tle_dev =
    static traytiptime := 900
    static loudness_eq_regpath := "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render\{51d210ff-df3a-41f6-8d8d-5b278543fac4}\FxProperties"
    
    initlib()
    {
        this.tle_exe := this.tle_dir . "\toggleloudnessequalization.exe"
        this.tle_dev := this.tle_dir . "\device.txt"
    }
    
    checkeqstate()
    {
        traytip
        ler := this.loudness_eq_regpath
        ttt := this.traytiptime
        regread, eqstate, %ler%, {E0A941A0-88A2-4df5-8D6B-DD20BB06E8FB}`,4
        eqstate := ((eqstate = 1) ? "ON" : "OFF")
        traytip, Loudness equalisation, Setting is %eqstate%,,17
        sleep, %ttt%
        traytip
    }
    
    setloudnesseq(state)
    {
        traytip
        if state not in on,off
            return
        tdir := this.tle_dir
        td := this.tle_dev
        ttt := this.traytiptime
        /*
        runwait, powershell "Import-Module AudioDeviceCmdlets;Get-DefaultAudioDevice" > %td%,,hide
        fileread, sounddevice, %td%
        filedelete, %td%
        if !instr(sounddevice, "Speakers")
        {
            traytip, Soundcard, ONBOARD is not selected at the moment,,17
            return
        }
        */
        runwait, %tdir%\toggleloudnessequalization.exe %state%,, hide useerrorlevel
        if errorlevel
        {
            msgbox, Something went wrong while toggling loudness equalisation
            return
        }
        stringupper, state, state
        traytip, Loudness equalisation, Setting was set to %state%,,17
        sleep, %ttt%
        traytip
    }
    
    toggleeq()
    {
        blockinput, on
        tdir := this.tle_dir
        td := this.tle_dev
        ler := this.loudness_eq_regpath
        ttt := this.traytiptime
        runwait, powershell "Import-Module AudioDeviceCmdlets;Get-DefaultAudioDevice" > %td%,,hide
        fileread, sounddevice, %td%
        filedelete, %td%
        if !instr(sounddevice, "Speakers")
        {
            blockinput, off
            return
        }
        runwait, %tdir%\toggleloudnessequalization.exe toggle,,hide useerrorlevel
        if errorlevel
        {
            blockinput, off
            msgbox, Something went wrong while toggling loudness equalisation
            return
        }
        traytip
        regread, eqstate, %ler%, {E0A941A0-88A2-4df5-8D6B-DD20BB06E8FB}`,4
        ;msgbox, %state% %A_ScriptDir%
        eqstate := ((eqstate = 1) ? "ON" : "OFF")
        blockinput, off
        traytip, Loudness equalisation, Setting was set to %eqstate%,,17
        sleep, %ttt%
        traytip
    }
    
    soundcard(option)
    {
        ;global traytiptime, tle_dir
        let_traytiptime := this.traytiptime
        let_tle_dir := this.tle_dir
        traytip
        if (option = "e")
        {
            option_str := "AUREON"
            runwait, %let_tle_dir%\toggleloudnessequalization.exe off,, hide
        }
        else if (option = "i")
            option_str := "ONBOARD"
        run,sound%option%,,hide
        traytip, Soundcard, %option_str% was selected,,17
        sleep, %let_traytiptime%
        traytip
        traytip
        sleep, %let_traytiptime%
        traytip
        traytip
    }
}
