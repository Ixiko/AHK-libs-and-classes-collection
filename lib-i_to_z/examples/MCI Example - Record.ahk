#NoEnv
#SingleInstance Force
ListLines Off

;;;;;gui Font,s12
gui Margin,0,0
gui -MinimizeBox
gui Add,Button,w300 Left gLevel,%A_Space% Show Microphone Level
gui Add,Button,wp        gStart     ,(Press me first)`nOpen new and start recording
gui Add,Button,wp   Left gPause     ,%A_Space% Pause
gui Add,Button,wp   Left gResume    ,%A_Space% Resume
gui Add,Button,wp   Left gStop      ,%A_Space% Stop
gui Add,Button,wp   Left gPlay      ,%A_Space% Playback from beginning
gui Add,Button,wp   Left gRPrefix   ,%A_Space% Record - Insert to the beginning
gui Add,Button,wp   Left gRSuffix   ,%A_Space% Record - Add to the end
gui Add,Button,wp   Left gOverwrite1,%A_Space% Record - Overwrite from the beginning
gui Add,Button,wp   Left gOverwrite2,%A_Space% Record - Overwrite from 3s to 6s
gui Add,Button,wp   Left gSave      ,%A_Space% Save and Exit
gui Add,Progress,wp -Smooth +0x8 hwndhwnd  ;-- 0x8=PBS_MARQUEE (Windows XP+)

gui Add,Text,x+10 ym+10 Section,Status:%A_Tab%%A_Tab%
gui Add,Text,x+0 vStatus,Stopped     %A_Space%
gui Add,Text,xs,Position:%A_Tab%
gui Add,Text,x+0 vPosition,000000
gui Add,Text,xs,Length:%A_Tab%%A_Tab%
gui Add,Text,x+0 vLength,000000
gui Add,Text,xs,Format:%A_Tab%%A_Tab%
gui Add,Text,x+0 vFormat,AaAaAaAaAaAaAaAaAaAaAaAaAaAaAa
gui Show
return


GUIClose:
ExitApp


Level:
hLevel:=MCI_Open("new","","type waveaudio")
Level:=PeakLevel:=0
gui 2:+Owner1
gui 2:-MinimizeBox
gui 2:Add,Text,xm,Level:%A_Space%
gui 2:Add,Text,x+0 vLevel,0000%A_Space%
gui 2:Add,Text,x+0,Peak:%A_Space%
gui 2:Add,Text,x+0 vPeakLevel,0000
gui 2:Add,Progress,xm     vLevelProgress Range0-128
gui 2:Add,Progress,xm y+0 vPeakLevelProgress Range0-128
gui 2:Show,,Mic Level
PeakTime:=A_TickCount
SetTimer Level2,30
WinWaitClose Mic Level ahk_class AutoHotkeyGUI
SetTimer Level2,Off
MCI_Close(hLevel)
gui 2:Destroy
return


Level2:
MCI_SendString("status " . hLevel . " level",Level)
GUIControl 2:,Level,%Level%
GuiControl 2:,LevelProgress,%Level%

if (A_TickCount-PeakTime)>1250
    {
    PeakLevel:=-1
    PeakTime:=A_TickCount
    }

if (Level>PeakLevel)
    {
    PeakLevel:=Level
    GUIControl 2:,PeakLevel,%PeakLevel%
    GuiControl 2:,PeakLevelProgress,%PeakLevel%
    }

return


Start:
if hMedia
    MCI_Close(hMedia)

hMedia:=MCI_Open("new","","type waveaudio")
MCI_Record(hMedia)
SetTimer UpdateStatus,250
gosub UpdateStatus
return


Pause:
MCI_Pause(hMedia)   ;-- This pauses recording or playback
return


Resume:
MCI_Resume(hMedia)  ;-- This resumes recording or playback
return


Stop:
MCI_Stop(hMedia)    ;-- This stops recording or playback
return


Play:
MCI_Stop(hMedia)
MCI_Seek(hMedia,"start")
MCI_Play(hMedia)
return


RPrefix:
MCI_Stop(hMedia)
MCI_Seek(hMedia,"start")
MCI_Record(hMedia,"insert")
return


RSuffix:
MCI_Stop(hMedia)
MCI_Seek(hMedia,"end")
MCI_Record(hMedia)
return


Overwrite1:
MCI_Stop(hMedia)
MCI_Seek(hMedia,"start")
MCI_Record(hMedia,"overwrite")
return


Overwrite2:
MCI_Stop(hMedia)
MCI_Seek(hMedia,"start")
MCI_Record(hMedia,"overwrite from 3000 to 6000")
return


Save:
MCI_Stop(hMedia)

gui +OwnDialogs
FileSelectFile SavePath,S8,.wav,,*.wav 
if ErrorLevel
    return

MCI_Save(hMedia,SavePath)
MCI_Close(hMedia)
ExitApp


UpdateStatus:
Status:=MCI_Status(hMedia)
MCI_SendString("status " . hMedia . " bitspersample",bitspersample)
MCI_SendString("status " . hMedia . " bytespersec",bytespersec)
MCI_SendString("status " . hMedia . " channels",channels)
MCI_SendString("status " . hMedia . " format tag",formattag)
MCI_SendString("status " . hMedia . " input",input)
MCI_SendString("status " . hMedia . " output",output)
MCI_SendString("status " . hMedia . " samplespersec",samplespersec)

GUIControl,,Status,%Status%
GUIControl,,Length,% MCI_Length(hMedia)
GUIControl,,Position,% MCI_Position(hMedia)
GUIControl,,Format,% samplespersec . "Hz " . bitspersample . "-Bit " . (channels=1 ? "Mono":"Stereo") . " (" . bytespersec . " B/s)"

if (Status=LastStatus)
    return

if Status in Playing,Recording
    SendMessage, 0x40A,1,60,,ahk_id %hwnd%
 else
    SendMessage, 0x40A,0,0,,ahk_id %hwnd%

LastStatus:=Status
return


#include MCI.ahk
