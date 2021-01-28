#NoEnv
#SingleInstance Force
ListLines Off

gui Margin,0,0
;;;;;gui Add,Button,w60 h25   ,Open
gui Add,Button,w80 h50,Play
gui Add,Button,x+0 wp hp,Pause
gui Add,Button,x+0 wp hp,Stop
gui,Add,Button,x+0 wp hp,Prev
gui,Add,Button,x+0 wp hp,Next
gui Add,StatusBar
gui Show

gosub ButtonOpen
if not Open
    ExitApp

return


GUIEscape:
GUIClose:
if Open
    {
    MCI_Stop(hCDAudio)
    MCI_Close(hCDAudio)
    }

ExitApp


ButtonOpen:
if Open
    {
    MCI_Stop(hCDAudio)
    MCI_Close(hCDAudio)
    }

Open:=False
hCDAudio:=MCI_OpenCDAudio()
if not hCDAudio
    {
    MsgBox
        ,16
        ,CD Audio
        ,No CDROM drive or no audio CD in the CDROM drive.  %A_Space%

    return
    }

Open:=True
CDPaused:=False
gosub ButtonPlay
return


ButtonPlay:
if Open
    {
    if CDPaused
        {
        MCI_Resume(hCDAudio)
        CDPaused:=False
        }
     else
        if (MCI_Status(hCDAudio)="Stopped")
            MCI_Play(hCDAudio,"from " . MCI_Position(hCDAudio,1))
    }

SetTimer UpdateSB,200
return


ButtonPause:
if Open
    {
    if (MCI_Status(hCDAudio)="Playing")
        {
        MCI_Pause(hCDAudio)
        CDPaused:=True
        }
     else
        if CDPaused
            {
            MCI_Resume(hCDAudio)
            CDPaused:=False
            }
    }

return


ButtonStop:
if Open
    {
    MCI_Stop(hCDAudio)
    CDPaused:=False
    }

SetTimer UpdateSB,Off
SB_SetText("")
return


ButtonPrev:
if Open
    {
    CurrentTrack:=MCI_CurrentTrack(hCDAudio)
    if (CurrentTrack>1)
        {
        MCI_Play(hCDAudio,"from " . MCI_Position(hCDAudio,CurrentTrack-1))
        CDPaused:=False
        }
    }

return


ButtonNext:
if Open
    {
    CurrentTrack:=MCI_CurrentTrack(hCDAudio)
    if (CurrentTrack<MCI_NumberOfTracks(hCDAudio))
        {
        MCI_Play(hCDAudio,"from " . MCI_Position(hCDAudio,CurrentTrack+1))
        CDPaused:=False
        }
    }

return


UpdateSB:
Track   :=MCI_CurrentTrack(hCDAudio)
Position:=MCI_ToHHMMSS(MCI_Position(hCDAudio)-MCI_Position(hCDAudio,Track))
Length  :=MCI_ToHHMMSS(MCI_Length(hCDAudio,Track))
SBText  :="Track " . Track . " -- " . Position . "/" . Length
if (SBText<>PrevSBText)
    {
    SB_SetText(SBText)
    PrevSBText:=SBText
    }

return


#include MCI.ahk
