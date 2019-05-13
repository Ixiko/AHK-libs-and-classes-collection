#NoEnv
#SingleInstance Force
ListLines Off

gui Margin,0,0
gui Add,Button,w70 h40,Open
gui Add,Button,x+0 wp hp,Play
gui Add,Button,x+0 wp hp,Pause
gui Add,Button,x+0 wp hp,Stop
gui,Add,Button,x+0 wp hp,Rev10
gui,Add,Button,x+0 wp hp,Middle
gui,Add,Button,x+0 wp hp,Fwd10
gui Show

gosub ButtonOpen
return


GUIEscape:
GUIClose:
if Open
    MCI_Close(hMedia)

ExitApp


ButtonOpen:
if Open
    MCI_Close(hMedia)

if not DefaultFolder
    DefaultFolder:=A_MyDocuments

gui +OwnDialogs
FileSelectFile, MediaFile,1,%DefaultFolder%,Choose a media file
if (MediaFile="")
   return

SplitPath MediaFile,,DefaultFolder

hMedia:=MCI_Open(MediaFile)
if Not hMedia
    {
    MsgBox Error opening media file
    return
    }

Open:=True
gosub ButtonPlay
return


ButtonPlay:
if Open
    {
    Status:=MCI_Status(hMedia)
    if (Status="Stopped")
        MCI_Play(hMedia,"","NotifyEndOfPlay")
            ;-- Note: The callback option is used here as an example.  This
            ;   script is not a really a good example of how/where the
            ;   callback option should be used because of all of the seek
            ;   interruptions.
     else
        if (Status="Paused")
            MCI_Resume(hMedia)
    }

return


ButtonPause:
if Open
    {
    Status:=MCI_Status(hMedia)
    if (Status="Playing")
        MCI_Pause(hMedia)
     else
        if (Status="Paused")
            MCI_Resume(hMedia)
    }

return


ButtonStop:
if Open
    {
    MCI_Stop(hMedia)
    MCI_Seek(hMedia,0)
    }

return


ButtonFwd10:
if Open
    if (MCI_Status(hMedia)="Playing")
        MCI_Seek(hMedia,MCI_Position(hMedia)+10000)
            ;-- Note: This seek method works for most (but not all) MCI devices

return


ButtonMiddle:
if Open
    if (MCI_Status(hMedia)="Playing")
        MCI_Seek(hMedia,MCI_Length(hMedia)/2)
            ;-- Note: This seek method works for most (but not all) MCI devices

return


ButtonRev10:
if Open
    if (MCI_Status(hMedia)="Playing")
        MCI_Seek(hMedia,MCI_Position(hMedia)-10000)
            ;-- Note: This seek method works for most (but not all) MCI devices

return


NotifyEndOfPlay(Flag)
    {
    Global
    if (Flag=1)  ;-- 1=play ended normally
        {
        MCI_Stop(hMedia)
        MCI_Seek(hMedia,0)
        }
    }


#include MCI.ahk
