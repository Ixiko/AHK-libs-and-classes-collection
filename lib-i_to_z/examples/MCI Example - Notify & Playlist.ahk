#NoEnv
#SingleInstance Force
ListLines Off

;-- Build GUI
gui Margin,0,0
gui Add,Button,w70 h35         gOpen ,Open
gui Add,Button,x+0 wp hp       gPlay ,Play
gui Add,Button,x+0 wp hp       gPause,Pause
gui Add,Button,x+0 wp hp vStop gStop ,Stop
gui,Add,Button,x+0 wp hp       gPrev ,Prev
gui,Add,Button,x+0 wp hp       gNext ,Next
gui Add
   ,Slider
   ,x+0 w180 hp +Disabled +ToolTip vSlider gSlider

Messages:="Notify messages are displayed here.  New items added to the top."
gui Add
   ,Edit
   ,xm w600 h180 +ReadOnly vMessages
   ,%Messages%

gui Add
   ,ListView
   ,xm w600 h200 Count1000 -Hdr vPlaylist gPlaylistAction
   ,Media File Name

gui Show

;-- Start 'R Up
gosub Open
return


GUIEscape:
GUIClose:
if Open
    {
    MCI_Stop(hMedia)
    MCI_Close(hMedia)
    }

ExitApp


PlaylistAction:

;-- Doubleclick?
if (A_GuiEvent="DoubleClick")
    {
    ;-- Anything selected? (Seems redundant for a double-click, but it's not)
    if LV_GetCount("Selected")
        {
        PlaylistIndex:=A_EventInfo-1
        gosub Next
        return
        }
    }

return


Open:

;-- Attach messages/dialogs to current GUI
gui +OwnDialogs

;-- Close if anything is open
if Open
    {
    MCI_Stop(hMedia)
    Sleep 30  ;-- Give notify a chance to display
    MCI_Close(hMedia)
    Open:=False
    SetTimer UpdateSlider,Off
    GUIControl,,Slider,0
    GUIControl Disable,Slider
    }

;-- Initialize
LV_Delete()
if MediaPath is Space
    MediaPath:=A_MyDocuments

;-- Browse for it
FileSelectFolder
    ,MediaFolder
    ,*%MediaPath%
    ,0
    ,Add media folder...

;-- Nothing selected?
If ErrorLevel
    {
    MsgBox 48,Open Failure,No media folder selected.
    return
    }

MediaPath:=MediaFolder

;[=====================]
;[  Populate playlist  ]
;[=====================]
;-- Redraw off
GUIControl -Redraw,Playlist

;-- Find media files
Loop %MediaFolder%\*.*,,1
    if A_LoopFileExt in mp3,wav  ;-- Add more extensions if desired
        LV_Add("",A_LoopFileLongPath)

;-- Redraw on
GUIControl +Redraw,Playlist

;-- Anything loaded
if LV_GetCount()=0
    {
    MsgBox 48,Open Failure,No media files found.
    return
    }

;-- Get it started
PlaylistIndex:=0
gosub Next
return


Play:
if Open
    {
    Status:=MCI_Status(hMedia)
    if (Status="Stopped")
        {
        MCI_Play(hMedia,"","NotifyEndOfPlay")  ;-- Notify is set here
        Messages:=A_Now . ": Notify set`n" . Messages
        GUIControl,,Messages,%Messages%
        }
     else
        if (Status="Paused")
            MCI_Resume(hMedia)
    }

return


Pause:
if Open
    {
    Status:=MCI_Status(hMedia)
    if (Status="Playing")
        MCI_Pause(hMedia)
     else
        if (Status="Paused")
            MCI_Resume(hMedia)

    ;-- Note: Pause and Resume do not interrupt Notify
    }

return


Stop:
if Open
    {
    MCI_Stop(hMedia)
    MCI_Seek(hMedia,0)
    Sleep 30  ;-- Give notify a chance to display
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
    MCI_Stop(hMedia)
    Sleep 30  ;-- Give notify a chance to display
    MCI_Close(hMedia)
    Open:=False
    SetTimer UpdateSlider,Off
    GUIControl,,Slider,0
    GUIControl Disable,Slider
    }

;-- At the end?
if (PlaylistIndex>=LV_GetCount())
    return

;-- Increment index
PlayListIndex++

;-- Open media file
LV_GetText(MediaFile,PlaylistIndex,1) 
hMedia:=MCI_Open(MediaFile)
if not hMedia
    {
    MsgBox Error opening media file
    return
    }

Open:=True
MediaLength:=MCI_Length(hMedia)
    ;-- The length of the media file is collected once on open.  The value is
    ;   used by the Slider routines.

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
    Status:=MCI_Status(hMedia)
    if Status in Playing,Paused
        {
        MCI_Play(hMedia,"from " . Floor(MediaLength*(Slider/100)),"NotifyEndOfPlay")
            ;-- MCI_Seek is not used to reposition the media in this example
            ;   because the function will cause a Notify interruption for most
            ;   devices.
            ;   
            ;   Using the "From" flag, MCI_Play will successfully reposition
            ;   the media for most MCI devices.  Calling MCI_Play (with
            ;   callback) while media is playing will abort the original Notify
            ;   condition (if any) and will create a new Notify condition.

        Messages:=A_Now . ": Notify reset`n" . Messages
        GUIControl,,Messages,%Messages%

        if (Status="Paused")
            MCI_Pause(hMedia)
        }

    ;-- Reset focus
    GUIControl Focus,Stop
    }

return


UpdateSlider:
if Open
    {
    ;-- Only update slider if object is NOT in focus
    GUIControlGet Control,FocusV
    if (Control<>"Slider")
        GUIControl,,Slider,% (MCI_Position(hMedia)/MediaLength)*100
    }

return


NotifyEndOfPlay(Flag)
    {
    Global

    if (Flag=1)
        MCINotifyValue=MCI_NOTIFY_SUCCESSFUL (1)

    if (Flag=2)
        MCINotifyValue=MCI_NOTIFY_SUPERSEDED (2)

    if (Flag=4)
        MCINotifyValue=MCI_NOTIFY_ABORTED (4)

    if (Flag=8)
        MCINotifyValue=MCI_NOTIFY_FAILURE (8)

    Messages:=A_Now . ": " . MCINotifyValue . "`n" . Messages
    GUIControl,,Messages,%Messages%

    if (Flag=1)
        gosub Next

    return
    }


#include MCI.ahk
