#NoEnv
#SingleInstance Force
ListLines Off

;-- SYstem metrics
SysGet SM_CXVSCROLL,2
    ;-- Width of a vertical scroll bar, in pixels.

;-- Build/Show GUI
gui Margin,0,0
gui Add,Button,w70 h40         gOpen ,Open
gui Add,Button,x+0 wp hp       gPlay ,Play
gui Add,Button,x+0 wp hp       gPause,Pause
gui Add,Button,x+0 wp hp vStop gStop ,Stop
gui,Add,Button,x+0 wp hp       gPrev ,Prev
gui,Add,Button,x+0 wp hp       gNext ,Next

gui Add
   ,Slider
   ,x+0 w180 hp +Disabled +ToolTip vSlider gSlider

gui Add
   ,ListView
   ,xm w600 r13 Count50 -Hdr vPlaylist gPlaylistAction
   ,CDAudio Track

LV_ModifyCOl(1,600-(SM_CXVSCROLL+4))
gui Show

;-- Start 'R Up
gosub Open
return


GUIEscape:
GUIClose:
if Open
    {
    MCI_Stop(hCDAudio)
    MCI_Close(hCDAudio)
    }

ExitApp


PlaylistAction:
if (A_GUIEvent="DoubleClick")
    {
    ;-- Anything selected? (Seems redundant for a double-click, but it's not)
    if LV_GetCount("Selected")
        {
        PlaylistIndex:=A_EventInfo-1
        gosub Next
        }
    }

return


Open:

;-- Attach messages/dialogs to current GUI
gui +OwnDialogs

;-- Close if anything is open
if Open
    {
    MCI_Stop(hCDAudio)
    MCI_Close(hCDAudio)
    Open:=False
    CDPaused:=False
    SetTimer UpdateSlider,off
    GUIControl,,Slider,0
    GUIControl Disable,Slider
    }

;-- Initialize
LV_Delete()

;-- Try to open first CDROM drive
hCDAudio:=MCI_OpenCDAudio()
if not hCDAudio
    {
    MsgBox
        ,16
        ,CD Audio
        ,No CDROM drive or no audio CD in the CDROM drive.  %A_Space%

    return
    }

;---------------------
;-- Populate playlist
;---------------------
;-- Get drive info
DriveGet ListOfCDROMDrives,List,CDROM
Drive:=SubStr(ListOfCDROMDrives,1,1)

;-- Load 'em up
GUIControl -Redraw,Playlist ;-- Redraw off
Loop % MCI_NumberOfTracks(hCDAudio)
    LV_Add("","cda://" . Drive . "," . SubStr("0" . A_Index,-1))

GUIControl +Redraw,Playlist ;-- Redraw on

;-- Close device
MCI_Close(hCDAudio)

;-- Get it started
PlaylistIndex:=0
gosub Next
return


Play:
if Open
    {
    if CDPaused
        {
        MCI_Resume(hCDAudio)
        CDPaused:=False
        }
     else
        if (MCI_Status(hCDAudio)="Stopped")
            {
            Flags:="from " . TrackFromPos . " to " . TrackToPos
            MCI_Play(hCDAudio,Flags,"NotifyEndOfPlay")  ;-- Notify is set here
            }
    }

return


Pause:
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
            Flags:="from " . MCI_Position(hCDAudio) . " to " . TrackToPos
            MCI_Play(hCDAudio,Flags,"NotifyEndOfPlay")
            CDPaused:=False
            }
    }

return


Stop:
if Open
    {
    MCI_Stop(hCDAudio)
    CDPaused:=False
    }

return


Prev:
if (PlaylistIndex>1)
    {
    PlaylistIndex:=PlaylistIndex-2
    gosub Next
    return
    }

return


Next:
if Open
    {
    MCI_Stop(hCDAudio)
    MCI_Close(hCDAudio)
    Open:=False
    CDPaused:=False
    SetTimer UpdateSlider,off
    GUIControl,,Slider,0
    GUIControl Disable,Slider
    }

;-- At the end?
if (PlaylistIndex>=LV_GetCount())
    return

;-- Increment index
PlayListIndex++

;-- Open CD Audio
LV_GetText(CDAFile,PlaylistIndex,1)
Drive:=SubStr(CDAFile,7,1)
Track:=SubStr(CDAFile,9)
hCDAudio:=MCI_OpenCDAudio(Drive)
if not hCDAudio
    {
    MsgBox Error opening CD Audio
    return
    }

Open:=True
CDPaused:=False
TrackLength :=MCI_Length(hCDAudio,Track)
TrackFromPos:=MCI_Position(hCDAudio,Track)
TrackToPos  :=TrackFromPos+TrackLength
    ;-- These "Track" variables are collected/calculated once on open.  The
    ;   variables are used by other routines.

;-- UnSelect All, select new item
LV_Modify(0,"-Select")
LV_Modify(PlaylistIndex,"+Select +Focus +Vis")

;-- Update slider
GUIControl Enable,Slider
SetTimer UpdateSlider,250

;-- Play it
gosub Play
return


Slider:
if Open
    {
    if (MCI_Status(hCDAudio)="Playing") or CDPaused
        {
        SeekPos:=Round(TrackLength*(Slider/100))
        Flags:="from " . TrackFromPos+SeekPos . " to " . TrackToPos

        MCI_Play(hCDAudio,Flags,"NotifyEndOfPlay")
        Sleep 30  ;-- Allow notify to fire.
            ;-- MCI_Seek is not used to reposition the media in this example
            ;   because the function will cause a Notify interruption for most
            ;   devices.
            ;   
            ;   Using the "From" flag, MCI_Play will successfully reposition
            ;   the media for most MCI devices.  Calling MCI_Play (with
            ;   callback) while media is playing will abort the original Notify
            ;   condition (if any) and will create a new Notify condition.

        if CDPaused
            MCI_Pause(hCDAudio)
        }

    ;-- Reset focus
    GUIControl Focus,Stop
    }

return


UpdateSlider:
if Open
    {
    TrackPosition:=MCI_Position(hCDAudio)-TrackFromPos

    ;-- Only update slider if object is NOT in focus
    GUIControlGet Control,FocusV
    if (Control<>"Slider")
        GUIControl,,Slider,% (TrackPosition/TrackLength)*100
    }

return


NotifyEndOfPlay(Flag)
    {
    if (Flag=1)  ;-- Normal EOP
        gosub Next

    return
    }


#include MCI.ahk


/*
Programming notes:

Open
====
Be sure to use the MCI_OpenCDAudio function to open a CDAudio device.  Although
the MCI library has no trouble opening and playing CD tracks as files, the OS
can only see these tracks as files on "standard" CD Audio discs.  The OS can not
see these tracks on most "enhanced" CD Audio discs.


Pause & Resume
==============
Unlike most other MCI devices, the Pause command _does_ interrupt Notify when
used on a CDAudio device.  Although the MCI_Resume function will resume play, it
cannot be used if Notify is used.  The MCI_Play function is used to resume play
and reestablish Notify.

When used to "resume", the MCI_Play function (accurate to the millisecond) is
not as accurate the MCI_Resume function (accurate to the frame) but the
positioning is very close.
*/

