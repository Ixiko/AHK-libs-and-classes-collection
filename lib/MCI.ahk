;- v0.3.1
;*********************
;*                   *
;*                   *
;*        MCI        *
;*                   *
;*                   *
;*********************
/*
Each MCI function is documented separately.  The following is general
information that relates to the entire library.

Notes
=====

    MCI Reference Guide:

        http://msdn.microsoft.com/en-us/library/ms709461(VS.85).aspx


    Devices referenced within the function documentation:

        Driver      Type            Description
        ------      ----            -----------
        MCIAVI      avivideo

        MCICDA      cdaudio         CD audio

                    dat             Digital-audio tape player

                    digitalvideo    Digital video in a window (not GDI-based)

                    MPEGVideo       General-purpose media player

                    other           Undefined MCI device

                    overlay         Overlay device (analog video in a window)

                    scanner         Image scanner

        MCISEQ      sequencer       MIDI sequencer

                    vcr             Video-cassette recorder or player

        MCIPIONR    videodisc       Videodisc (Pioneer LaserDisc)

        MCIWAVE     waveaudio       Audio device that plays digitized waveform
                                    files 



Programming Notes
=================
OutputDebug statements in the core of some of the functions that only execute
on condition are permanent and are provided to help the developer find and
eliminate programming errors.  Under normal conditions, these debugging
statements should not slow down the operation of the functions because they
"should" only execute when the developer has made a programming/logic error or
if there are unusual conditions.



Credit
======
 -  Original library released by Fincs as the "Sound_*" library and then as the
    "Media_*" library.  The orginal libraries are a conversion-to-AutoHotkey
    from the AutoIt "Sound.au3" standard library written by RazerM.

    This library would not be possible without the significant effort by
    Fincs to translate and enhance the original library and RazerM for providing
    the original AutoIt library.  Some of the code and documentation are from
    the libraries provided by Fincs:

        Post 1: http://www.autohotkey.com/forum/viewtopic.php?t=20666
        Post 2: http://www.autohotkey.com/forum/viewtopic.php?t=22662
    

 -  Notify idea and code from Sean:
        Post: http://www.autohotkey.com/forum/viewtopic.php?p=132331#132331

 -  mciGetErrorString DLL function code from PhiLho:
        Post: http://www.autohotkey.com/forum/viewtopic.php?p=116011#116011
*/




;----------
;
;   Function: MCI_Open
;
;
;   Description:
;
;       Opens an MCI device and loads the specified file (p_MediaFile).
;
;
;   Parameters:
;
;       p_MediaFile - A multimedia file. [Required]
;
;       p_Alias - Alias [Optional].  A name such as media1.  If blank, an
;            alias will automatically be generated.
;
;       p_Flags - Flags that determine how the device is opened. [Optional]
;
;           Some commonly used flags include the following:
;
;               type {device_type}
;               sharable
;
;           If more than one flag is used, separate each flag/flag value with a
;           space.  For example:
;
;               type MPEGVideo sharable
;
;           Notes
;           -----
;            -  The "wait" flag is automatically added to the end of the
;               command string.  This flag directs the device to complete the
;               "open" request before returning.
;
;
;            -  By default, the MCI device that is opened is determined by the
;               file's extension.  The "type" flag can be used to  1) override
;               the default device that is registered for the file extension or
;               to  2) open a media file with a file extension that is not
;               registered as a MCI file extension.
;
;               To see a list of MCI devices that have been registered for your
;               computer, go the following registry locations:
;
;                 Windows NT4/2000/XP/2003/Vista/etc.:
;
;                   16-bit:
;                     HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MCI
;
;                   32-bit:
;                     HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MCI32
;
;
;                 Windows 95/98/ME:
;
;                   HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\MediaResources\MCI
;
;
;               To see a list of registered file extensions and the MCI device
;               that has been assigned to each extension, go the following
;               locations:
;
;                 For Windows NT4/2000/XP/2003/Vista, this information is
;                 stored in the registry at the following location:
;               
;                   HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MCI Extensions
;
;
;                 For Windows 95/98/ME, this information is stored in the
;                 %windir%\win.ini file in the "MCI Extensions" section.
;
;
;            -  Use the "shareable" flag with care.  Per msdn, the "shareable"
;               flag "initializes the device or file as shareable. Subsequent
;               attempts to open the device or file fail unless you specify
;               "shareable" in both the original and subsequent open commands.
;               MCI returns an invalid device error if the device is already
;               open and not shareable.  The MCISEQ sequencer and MCIWAVE
;               devices do not support shared files."
;
;
;            -  For a complete list of flags and descriptions for the "open"
;               command string, see the "MCI Reference Guide" (link at the top
;               of this library).
;
;
;   Return value:
;
;       Returns the multimedia handle (alias) or a 0 to indicate failure.
;       Failure will occur with any of the following conditions:
;
;        -  The media file does not exist.
;
;        -  The media file's extension is not a regisitered MCI extension.
;           Note: This test is only performed if the "type" flag is not
;           specified.
;
;        -  Non-zero return code from the MCI_SendString function.
;
;
;   Remarks:
;
;     - Use the MCI_OpenCDAudio function to open a CDAudio device.
;
;     - After the device has been successfully opened, this function sets the
;       time format to milliseconds.  This time format will remain in effect
;       until it is manually set to another value or until the device is
;       closed.
;
;------------------------------------------------------------------------------
MCI_Open(p_MediaFile,p_Alias="",p_Flags="")
    {
    Static s_Seq=0

    ;[==============]
    ;[  Parameters  ]
    ;[==============]
    ;-- p_MediaFile
    if p_MediaFile<>new
        {
        ;-- Media file exist?
        IfNotExist %p_MediaFile%
            {
            outputdebug,
               (ltrim join`s
                End Func: %A_ThisFunc%: The media file can't be
                found.  Return=0
               )
            
            return false
            }
    
    
        ;-- "Type" flag not defined?
        if InStr(A_Space . p_Flags . A_Space," type ")=0
            {
            ;-- Registered file extension?
            SplitPath p_MediaFile,,,l_Extension


            ;-- Which OS type?
            if A_OSType=WIN32_NT  ;-- Windows NT4/2000/XP/2003/Vista
                RegRead
                    ,l_Dummy
                    ,HKEY_LOCAL_MACHINE
                    ,SOFTWARE\Microsoft\Windows NT\CurrentVersion\MCI Extensions
                    ,%l_Extension%
             else
                {
                ;-- Windows 95/98/ME
                iniRead
                    ,l_Value
                    ,%A_WinDir%\win.ini
                    ,MCI Extensions
                    ,%l_Extension%

                if l_Value=ERROR
                    ErrorLevel=1
                }


            ;-- Not found?
            if ErrorLevel
                {
                outputdebug,
                   (ltrim join`s
                    End Func: %A_ThisFunc%: The file extension for this media
                    file is not registered as a valid MCI extension.  Return=0
                   )
        
                return false
                }
            }


        ;-- Enclose in DQ
        p_MediaFile="%p_MediaFile%"  
        }


    ;-- Alias
    if p_Alias is Space
       {
       s_Seq++
       p_Alias=MCIFile%s_Seq%
       }


    ;[===============]
    ;[  Open device  ]
    ;[===============]
    l_CmdString=open %p_MediaFile% alias %p_Alias% %p_Flags% wait
    l_Return:=MCI_SendString(l_CmdString,Dummy)
    if l_Return
        l_Return:=0
     else
        l_Return:=p_Alias


    ;-- Set time format to milliseconds
    if l_Return
        {
        l_CmdString=set %p_Alias% time format milliseconds wait
        MCI_SendString(l_CmdString,Dummy)
        }


    ;-- Return to sender
    return l_Return
    }



;----------
;
;   Function: MCI_OpenCDAudio
;
;
;   Description:
;
;       Opens a CDAudio device.
;
;
;   Parameters:
;
;       p_Drive - CDROM drive letter. [Optional]  If blank, the first CDROM
;           drive found is used.
;
;       p_Alias - Alias. [optional]  A name such as media1.  If blank, an
;            alias will automatically be generated.
;
;       p_CheckForMedia - Check for media [Optional].  The default is TRUE.
;
;
;   Return value:
;
;       Returns the multimedia handle (alias) or a 0 to indicate failure.
;       Failure will occur with any of the following conditions:
;        -  The computer does not have a CDROM drive.
;        -  The specified drive is not CDROM drive.
;        -  Non-zero return code from the MCI_SendString function.
;
;       If p_CheckForMedia is TRUE (the default), failure will also occur with
;       any of the following conditions:
;        -  No media was found in the device.
;        -  Media does not contain audio tracks.
;
;
;   Remarks:
;
;       After the device has been successfully opened, this function sets
;       the time format to milliseconds.  This time format will remain in effect
;       until it is manually set to another value or until the device is closed.
;
;------------------------------------------------------------------------------
MCI_OpenCDAudio(p_Drive="",p_Alias="",p_CheckForMedia=true)
    {
    Static s_Seq=0

    ;-- Parameters
    p_Drive=%p_Drive%  ;-- Autotrim
    p_Drive:=SubStr(p_Drive,1,1)
    if p_Drive is not Alpha
        p_Drive:=""


    ;-- Drive not specified
    if p_Drive is Space
        {
        ;-- Collect list of CDROM drives
        DriveGet l_ListOfCDROMDrives,List,CDROM
        if l_ListOfCDROMDrives is Space
            {
            outputdebug,
               (ltrim join`s
                End Func: %A_ThisFunc%: This PC does not have functioning CDROM
                drive.  Return=0
               )
    
            return false
            }

        ;-- Assign the first CDROM drive
        p_Drive:=SubStr(l_ListOfCDROMDrives,1,1)
        }


    ;-- Is this a CDROM drive?
    DriveGet l_DriveType,Type,%p_Drive%:
    if l_DriveType<>CDROM
        {
        outputdebug,
           (ltrim join`s
            End Func: %A_ThisFunc%: The specified drive (%p_Drive%:) is not
            a CDROM drive.  Return=0
           )

        return false
        }


    ;-- Alias
    if p_Alias is Space
       {
       s_Seq++
       p_Alias=MCICDAudio%s_Seq%
       }


    ;-- Open device
    l_CmdString=open %p_Drive%: alias %p_Alias% type cdaudio shareable wait
    l_Return:=MCI_SendString(l_CmdString,Dummy)
    if l_Return
        l_Return:=0
     else
        l_Return:=p_Alias


    ;-- Device is open
    if l_Return
        {
        ;-- Set time format to milliseconds
        l_CmdString=set %p_Alias% time format milliseconds wait
        MCI_SendString(l_CmdString,Dummy)


        ;-- Check for media?
        if p_CheckForMedia
            {
            if not MCI_MediaIsPresent(p_Alias)
                {
                MCI_Close(p_Alias)
                outputdebug,
                   (ltrim join`s
                    End Func: %A_ThisFunc%: Media is not present in the
                    specified drive (%p_Drive%:).  Return=0
                   )

                return false
                }

            ;-- 1st track an audio track?
            if not MCI_TrackIsAudio(p_Alias,1)
                {
                MCI_Close(p_Alias)
                outputdebug,
                   (ltrim join`s
                    End Func: %A_ThisFunc%: Media in drive %p_Drive%: does not
                    contain CD Audio tracks.  Return=0
                   )

                return false
                }
            }
        }


    return l_Return
    }



;----------
;
;   Function: MCI_Close
;
;
;   Description:
;
;       Closes the device and any associated resources.
;
;
;   Parameters:
;
;       p_lpszDeviceID - Device name or alias. [Required]
;
;
;   Return value:
;
;       Returns the return code from the MCI_SendString function which is 0
;       if the command completed successfully.
;
;
;   Remarks:
;
;       Closing a device usually stops playback but not always.  Consider
;       stopping the device before closing it.
;
;
;
;------------------------------------------------------------------------------
MCI_Close(p_lpszDeviceID)
    {
    Static MM_MCINOTIFY:=0x03B9


    ;-- Close device
    l_Return:=MCI_SendString("close " . p_lpszDeviceID . " wait",Dummy)


    ;-- Turn off monitoring of MM_MCINOTIFY message?
    if OnMessage(MM_MCINOTIFY)="MCI_Notify"
        {
        ;-- Don't proceed unless all MCI devices are closed
        MCI_SendString("sysinfo all quantity open",l_OpenMCIDevices)
        if l_OpenMCIDevices=0
            {
            ;-- Disable monitoring
            OnMessage(MM_MCINOTIFY,"")
            }
        }

    return l_Return
    }



;----------
;
;   Function: MCI_Play
;
;
;   Description:
;
;       Starts playing a device.
;
;
;   Parameters:
;
;       p_lpszDeviceID - Device name or alias. [Required]
;
;       p_Flags - Flags that determine how the device is played. [Optional]
;           If blank, no flags are used.
;
;           Some commonly used flags include the following:
;
;               from {position}
;               to {position}
;               wait
;
;           If more than one flag is used, separate each flag/flag value with a
;           space.  For example:
;
;               from 10144 to 95455 wait
;
;           Notes
;           -----
;            -  With the exception of very short sound files (<300 ms), the
;               "wait" flag is not recommended.  The entire application will be
;               non-responsive while the media is being played.
;
;            -  Do not add the "notify" flag unless you plan to have your
;               script trap the MM_MCINOTIFY message outside of this function.
;               The "notify" flag is automatically added if the p_Callback
;               parameter contains a value.
;
;            -  For a complete list of flags and descriptions for the "play"
;               command string, see the "MCI Reference Guide" (link at the top
;               of this library).
;
;
;       p_Callback - Function name that is called when the MM_MCINOTIFY message
;           is sent. [Optional].  If defined, the "notify" flag is automatically
;           added.
;
;           Important:  The syntax of this parameter and the associated function
;           is critical.  If not defined correctly, the script may crash.
;
;           The function must have at least one parameter.  For example:
;
;               MyNotifyFunction(NotifyFlag)
;
;           Additional parameters are allowed but they must be optional (contain
;           a default value).  For example:
;
;               MyNotifyFunction(NotifyFlag,FirstCall=false,Parm3="ABC")
;
;           When a notify message is sent, the approriate MM_MCINOTIFY flag is
;           sent to the developer-defined function as the first parameter.  See
;           the MCI_Notify function for a description and a list of MM_MCINOTIFY
;           flag values.
;
;
;       p_hWndCallback - Handle to a callback window if the p_Callback 
;           parameter contains a value and/or if the "notify" flag is defined
;           [Optional].  If undefined but needed, the handle to default
;           Autohotkey window is used.
;
;
;   Return value:
;
;       Returns the return code from the MCI_SendString function which is 0
;       if the command completed successfully.
;
;------------------------------------------------------------------------------
MCI_Play(p_lpszDeviceID,p_Flags="",p_Callback="",p_hwndCallback=0)
    {
    Static MM_MCINOTIFY:=0x03B9

    ;-- Build command string
    l_CmdString:="play " . p_lpszDeviceID
    if p_Flags
        l_CmdString:=l_CmdString . A_Space . p_Flags


    ;-- Notify
    p_Callback=%p_Callback%  ;-- AutoTrim
    if StrLen(p_Callback)
        {
        l_CmdString:=l_CmdString . " notify"

        ;-- Attach p_Callback to MCI_Notify function
        MCI_Notify(p_Callback,"","","")


        ;-- Monitor for MM_MCINOTIFY message
        OnMessage(MM_MCINOTIFY,"MCI_Notify")
            ;-- Note:  If the MM_MCINOTIFY message was monitored elsewhere,
            ;   this statement will override it.
        }


    ;-- Callback handle
    if not p_hwndCallback
        {
        if InStr(A_Space . l_CmdString . A_Space," notify ")
        or StrLen(p_Callback)
            {
            l_DetectHiddenWindows:=A_DetectHiddenWindows
            DetectHiddenWindows On
            Process Exist
            p_hwndCallback:=WinExist("ahk_pid " . ErrorLevel . " ahk_class AutoHotkey")
            DetectHiddenWindows %l_DetectHiddenWindows%
            }
        }


    ;-- Send it!
    l_return:=MCI_SendString(l_CmdString,Dummy,p_hwndCallback)
    return l_Return
    }



;----------
;
;   Function: MCI_Notify  (Internal function.  Do not call directly).                                                         ;-- Experimental
;
;
;   Description:
;
;       This function has 2 responsibilties:
;
;        1) If called by the MCI_Play function, wParam contains the name of the
;           developer-defined function.  This value is assigned to the
;           s_Callback static variable for future use.
;
;        2) When called as a result of MM_MCINOTIFY message, this function will
;           call the developer-defined function (name stored in the s_Callback
;           static variable) sending the MM_MCINOTIFY status flag as the first
;           parameter.
;
;
;   Parameters:
;
;       wParam - Function name or a MM_MCINOTIFY flag.  MM_MCINOTIFY flag
;           values are as follows:
;
;               MCI_NOTIFY_SUCCESSFUL=0x1
;                   The conditions initiating the callback function have been
;                   met.
;
;               MCI_NOTIFY_SUPERSEDED=0x2
;                   The device received another command with the "notify" flag
;                   set and the current conditions for initiating the callback
;                   function have been superseded.
;
;               MCI_NOTIFY_ABORTED=0x4
;                   The device received a command that prevented the current
;                   conditions for initiating the callback function from being
;                   met.  If a new command interrupts the current command and 
;                   it also requests notification, the device sends this
;                   message only and not MCI_NOTIFY_SUPERSEDED.
;
;               MCI_NOTIFY_FAILURE=0x8
;                   A device error occurred while the device was executing the
;                   command.
;
;       lParam - lDevID.  This is the identifier of the device initiating the
;           callback function.  This information is only useful if operating
;           more than one MCI device at a time.
;
;
;   Return value:
;
;       Per msdn, returns 0 to indicate a successful call.
;
;
;   Remarks:
;
;       This function does not complete until the call to the developer-defined
;       function has completed.  If a MM_MCINOTIFY message is issued while this
;       function is running, the message will be treated as unmonitored.
;
;------------------------------------------------------------------------------
MCI_Notify(wParam,lParam,msg,hWnd)
    {
;;;;;    Critical
        ;-- This will cause MM_MCINOTIFY messages to be buffered rather than
        ;   discared if this function is still running when another MM_MCINOTIFY
        ;   message is sent.


    Static s_Callback

    ;-- Internal call?
    if lParam is Space
        {
        s_Callback:=wParam
        return
        }

    ;-- Call developer function
    if s_Callback is not Space
        %s_Callback%(wParam)


    return 0
    }



;----------
;
;   Function: MCI_Stop
;
;
;   Description:
;
;       Stops playback or recording.
;
;
;   Parameters:
;
;       p_lpszDeviceID - Device name or alias. [Required]
;
;
;   Return value:
;
;       Returns the return code from the MCI_SendString function which is 0
;       if the command completed successfully.
;
;
;   Remarks:
;
;     - After close, a "seek to start" is not done because  1) it slows down the
;       the stop request and  2) it may be unwanted.  If you need to set the
;       media position back to the beginning after a stop, call the MCI_Seek
;       function and set the p_Position parameter to 0.
;
;     - For (some) CD audio devices, the stop command stops playback and resets
;       the current track position to zero.
;
;------------------------------------------------------------------------------
MCI_Stop(p_lpszDeviceID)
    {
    l_Return:=MCI_SendString("stop " . p_lpszDeviceID . " wait",Dummy)
    return l_Return
    }



;----------
;
;   Function: MCI_Pause
;
;
;   Description:
;
;       Pauses playback or recording.
;
;
;   Parameters:
;
;       p_lpszDeviceID - Device name or alias. [Required]
;
;
;   Return value:
;
;       Returns the return code from the MCI_SendString function which is 0
;       if the command completed successfully.
;
;
;   Remarks:
;
;       msdn: With the MCICDA, MCISEQ, and MCIPIONR drivers, the pause command
;       works the same as the stop command.
;
;       Observation: For MCISEQ devices, pause works OK for me.
;
;------------------------------------------------------------------------------
MCI_Pause(p_lpszDeviceID)
    {
    l_Return:=MCI_SendString("pause " . p_lpszDeviceID . " wait",Dummy)
    return l_Return
    }



;----------
;
;   Function: MCI_Resume
;
;
;   Description:
;
;       Resumes playback or recording after the device has been paused (see the
;       MCI_Pause function).
;
;
;   Parameters:
;
;       p_lpszDeviceID - Device name or alias. [Required]
;
;
;   Return value:
;
;       Returns the return code from the MCI_SendString function which is 0
;       if the command completed successfully.
;
;
;   Remarks:
;
;       msdn: Digital-video, VCR, and waveform-audio devices recognize this
;       command. Although CD audio, MIDI sequencer, and videodisc devices
;       also recognize this command, the MCICDA, MCISEQ, and MCIPIONR device
;       drivers do not support it.
;
;
;   Programming notes:
;
;       An alternative to this command is the MCI_Play command.  Many devices
;       will begin to play where they were last paused.  If the device does not
;       begin playback correctly, try specifying an appropriate "From"
;       and "To" value (if needed) in the p_Flags parameter.
;
;------------------------------------------------------------------------------
MCI_Resume(p_lpszDeviceID)
    {
    l_Return:=MCI_SendString("resume " . p_lpszDeviceID . " wait",Dummy)
    return l_Return
    }



;----------
;
;   Function: MCI_Record
;
;
;   Description:
;
;       Starts recording.
;
;
;   Parameters:
;
;       p_lpszDeviceID - Device name or alias. [Required]
;
;       p_Flags - Flags that determine how the device operates for
;           recording. [Optional] If blank, no flags are used.
;
;           Some commonly used flags include the following:
;
;               from {position}
;               to {position}
;               insert
;               overwrite
;
;           If more than one flag is used, separate each flag/flag value with a
;           space.  For example:
;
;               overwrite from 18122 to 26427
;
;
;           Notes
;           -----
;            -  The "wait" flag is not recommended.  The entire application will
;               be non-responsive until recording is stopped with a Stop or
;               Pause command.
;
;            -  For a complete list of flags and descriptions for the "record"
;               command string, see the "MCI Reference Guide" (link at the top
;               of this library).
;
;
;   Return value:
;
;       Returns the return code from the MCI_SendString function which is 0
;       if the command completed successfully.
;
;
;   Remarks:
;
;       msdn: Recording stops when a Stop or Pause command is issued.  For the
;       MCIWAVE driver, all data recorded after a file is opened is discarded if
;       the file is closed without saving it.
;
;
;   Credit:
;
;       Original function and examples by heresy.
;
;------------------------------------------------------------------------------
MCI_Record(p_lpszDeviceID,p_Flags="")
    {
    l_CmdString=record %p_lpszDeviceID% %p_Flags%
    l_Return:=MCI_SendString(l_CmdString,Dummy)
    return l_Return
    }


;----------
;
;   Function: MCI_Save
;
;
;   Description:
;
;       Saves an MCI file.
;
;
;   Parameters:
;
;       p_lpszDeviceID - Device name or alias. [Required]
;
;       p_FileName - File name to store a MCI file.  [Required]  If the file
;           does not exist, a new file will be created.  If the file exists, it
;           will be overwritten.
;
;
;   Return value:
;
;       Returns the return code from the MCI_SendString function which is 0
;       if the command completed successfully.
;
;
;   Remarks:
;
;       This command can overwrite existing files.  Use with care.
;
;
;   Credit:
;
;       Original function and examples by heresy.
;
;------------------------------------------------------------------------------
MCI_Save(p_lpszDeviceID,p_FileName)
    {
    l_CmdString=save %p_lpszDeviceID% "%p_FileName%"
    l_Return:=MCI_SendString(l_CmdString,Dummy)
    return l_Return   
    }




;----------
;
;   Function: MCI_Seek
;
;
;   Description:
;
;       Move to a specified position.
;
;
;   Parameters:
;
;       p_lpszDeviceID - Device name or alias. [Required]
;
;       p_Position - Position to stop the seek. [Required]  Value must be
;           "start", "end", or an integer.
;
;
;   Return value:
;
;       Returns the return code from the MCI_SendString function which is 0
;       if the command completed successfully.
;
;------------------------------------------------------------------------------

/*
Usage and Programming notes:

MCI Bug?: For some reason, seek for cdaudio doesn't work correctly on the
first attempt.  Second and susequent attempts work fine.

*/


MCI_Seek(p_lpszDeviceID,p_Position)
    {
    ;-- Get current status
    l_Status:=MCI_Status(p_lpszDeviceID)


    ;-- Adjust p_Position if necessary
    if p_Position not in start,end
        {
        if p_Position is not Number
            p_Position=0
    
        p_Position:=Round(p_Position)  ;-- Integer values only
   
        if (p_Position>MCI_Length(p_lpszDeviceID))
            p_Position:="end"
         else
            if p_Position<1
                p_Position:="start"
                    ;-- This is necessary because some devices don't like a "0"
                    ;   position.
        }


    ;-- Seek
    l_CmdString=seek %p_lpszDeviceID% to %p_Position% wait
    l_Return:=MCI_SendString(l_CmdString,Dummy)


    ;-- Return to mode before seek
    if l_Status in paused,playing
        {
        MCI_Play(p_lpszDeviceID)

        ;-- Re-pause
        if l_Status=paused
            MCI_Pause(p_lpszDeviceID)
        }


    l_CurrentPos:=MCI_Position(p_lpszDeviceID)


    ;-- Return to sender
    return l_Return
    }



;----------
;
;   Function: MCI_Length
;
;
;   Description:
;
;       Returns the total length of the media in the current time format.
;
;
;   Parameters:
;
;       p_lpszDeviceID - Device name or alias. [Required]
;
;       p_Track - Track number. [Optional]  The default is 0 (no track number).
;
;
;   Return value:
;
;       If a track number is not specified (the default), the length of the
;       entire media is returned.  If a track number is specified, only the
;       the length of the specified track is returned.
;
;------------------------------------------------------------------------------
MCI_Length(p_lpszDeviceID,p_Track=0)
    {
    ;-- Build command string
    l_CmdString:="status " . p_lpszDeviceID . " length"
    if p_Track
        l_CmdString:=l_CmdString . " track " . p_Track


    ;-- Send it!
    MCI_SendString(l_CmdString,l_lpszReturnString)
    return l_lpszReturnString
    }



;----------
;
;   Function: MCI_Status
;
;
;   Description:
;
;       Identifies the current mode of the device.
;
;
;   Parameters:
;
;       p_lpszDeviceID - Device name or alias. [Required]
;
;
;   Return value:
;
;       Returns the current mode of the device.
;
;       msdn: All devices can return the "not ready", "paused", "playing", and
;       "stopped" values. Some devices can return the additional "open", 
;       "parked", "recording", and "seeking" values.
;
;------------------------------------------------------------------------------
MCI_Status(p_lpszDeviceID)
    {
    MCI_SendString("status " . p_lpszDeviceID . " mode",l_lpszReturnString)
    return l_lpszReturnString
    }



;----------
;
;   Function: MCI_Position
;
;
;   Description:
;
;       Identifies the current playback or recording position. 
;
;
;   Parameters:
;
;       p_lpszDeviceID - Device name or alias. [Required]
;
;       p_Track - Track number. [Optional]  The default is 0 (no track number).
;
;
;   Return value:
;
;       Returns the current playback or recording position in the current time
;       format.  If the p_Track parameter contains a non-zero value, returns the
;       start position of the track relative to entire media.
;
;------------------------------------------------------------------------------
MCI_Position(p_lpszDeviceID,p_Track=0)
    {
    ;-- Build command string
    l_CmdString:="status " . p_lpszDeviceID . " position"
    if p_Track
        l_CmdString:=l_CmdString . " track " . p_Track


    ;-- Send it!
    MCI_SendString(l_CmdString,l_lpszReturnString)
    return l_lpszReturnString
    }



;----------
;
;   Function: MCI_DeviceType
;
;
;   Description:
;
;       Identifies the device type name.
;
;
;   Parameters:
;
;       p_lpszDeviceID - Device name or alias. [Required]
;
;
;   Return value:
;
;       Returns a device type name, which can be one of the following:
;
;           cdaudio
;           dat
;           digitalvideo
;           other
;           overlay
;           scanner
;           sequencer
;           vcr
;           videodisc
;           waveaudio
;
;------------------------------------------------------------------------------
MCI_DeviceType(p_lpszDeviceID)
    {
    l_CmdString=capability %p_lpszDeviceID% device type
    MCI_SendString(l_CmdString,l_lpszReturnString)
    return l_lpszReturnString
    }



;----------
;
;   Function: MCI_MediaIsPresent
;
;
;   Description:
;
;       Checks to see if media is present in the device.
;
;
;   Parameters:
;
;       p_lpszDeviceID - Device name or alias. [Required]
;
;
;   Return value:
;
;       Returns TRUE if the media is inserted in the device or FALSE otherwise.
;
;       msdn: Sequencer, video-overlay, digital-video, and waveform-audio
;       devices (always) return TRUE.
;
;------------------------------------------------------------------------------
MCI_MediaIsPresent(p_lpszDeviceID)
    {
    l_CmdString=status %p_lpszDeviceID% media present
    l_RC:=MCI_SendString(l_CmdString,l_lpszReturnString)

    if l_RC  ;-- Probably invalid command for the device
        l_Return:=false
     else
        if (l_lpszReturnString="true")
            l_Return:=true
         else
            l_Return:=false

    return l_Return
    }



;----------
;
;   Function: MCI_TrackIsAudio
;
;   Description:
;
;       Determines if the specified track is an audio track.
;
;
;   Parameters:
;
;       p_lpszDeviceID - Device name or alias.  [Required]
;
;       p_Track - Track number. [Optional]  The default is 1.
;
;
;   Return value:
;
;       Returns TRUE if the specified track is an audio track otherwise returns
;       FALSE.
;
;
;   Remarks:
;
;       This command will only work on a device that supports multiple tracks.
;
;------------------------------------------------------------------------------
MCI_TrackIsAudio(p_lpszDeviceID,p_Track=1)
    {
    if p_Track is not Integer
        p_Track=1

    l_CmdString=status %p_lpszDeviceID% type track %p_Track%
    l_RC:=MCI_SendString(l_CmdString,l_lpszReturnString)

    if l_RC  ;-- Probably invalid command for the device
        l_Return:=false
     else
        if l_lpszReturnString=audio
            l_Return:=true
         else
            l_Return:=false

    return l_Return
    }



;----------
;
;   Function: MCI_CurrentTrack
;
;
;   Description:
;
;       Identifies the current track.
;
;
;   Parameters:
;
;       p_lpszDeviceID - Device name or alias. [Required]
;
;
;   Return value:
;
;       Returns the current track. The MCISEQ sequencer returns 1.
;
;------------------------------------------------------------------------------
MCI_CurrentTrack(p_lpszDeviceID)
    {
    l_CmdString:="status " . p_lpszDeviceID . " current track"
    l_Return:=MCI_SendString(l_CmdString,l_lpszReturnString)
    return l_lpszReturnString
    }



;----------
;
;   Function: MCI_NumberOfTracks
;
;
;   Description:
;
;       Identifies the number of tracks on the media.
;
;
;   Parameters:
;
;       p_lpszDeviceID - Device name or alias. [Required]
;
;
;   Return value:
;
;       Returns the number of tracks on the media.
;
;
;   Remarks:
;
;       msdn: The MCISEQ and MCIWAVE devices return 1, as do most VCR devices.
;       The MCIPIONR device does not support this flag.
;
;------------------------------------------------------------------------------
MCI_NumberOfTracks(p_lpszDeviceID)
    {
    l_CmdString:="status " . p_lpszDeviceID . " number of tracks"
    l_Return:=MCI_SendString(l_CmdString,l_lpszReturnString)
    return l_lpszReturnString
    }



;----------
;
;   Function: MCI_SetVolume
;
;
;   Description:
;
;       Sets the average audio volume for both audio channels. If the left and
;       right volumes have been set to different values, then the ratio of
;       left-to-right volume is approximately unchanged.
;
;
;   Parameters:
;
;       p_lpszDeviceID - Device name or alias. [Required]
;
;       p_Factor - Volume factor [Required]
;
;
;   Return value:
;
;       Returns the return code from the MCI_SendString function which is 0
;       if the command completed successfully.
;
;
;   Observations:
;
;     - Factor range appears to be from 0 to 1000.
;     - Most MCI devices do not support this command.
;
;------------------------------------------------------------------------------
MCI_SetVolume(p_lpszDeviceID,p_Factor)
    {
    l_CmdString:="setaudio " . p_lpszDeviceID . " volume to " . p_Factor
    l_Return:=MCI_SendString(l_CmdString,Dummy)
    return l_Return
    }



;----------
;
;   Function: MCI_SetBass
;
;
;   Description:
;
;       Sets the audio low frequency level.
;
;
;   Parameters:
;
;       p_lpszDeviceID - Device name or alias. [Required]
;
;       p_Factor - Bass factor [Require]
;
;
;   Return value:
;
;       Returns the return code from the MCI_SendString function which is 0
;       if the command completed successfully.
;
;
;   Observations:
;
;     - Factor range appears to be from 0 to ?????.
;     - Most MCI devices do not support this command.
;
;------------------------------------------------------------------------------
MCI_SetBass(p_lpszDeviceID,p_Factor)
    {
    l_CmdString:="setaudio " . p_lpszDeviceID . " bass to " . p_Factor
    l_Return:=MCI_SendString(l_CmdString,Dummy)
    return l_lpszReturnString
    }



;----------
;
;   Function: MCI_SetTreble
;
;   Description:
;
;       Sets the audio high-frequency level.
;
;
;   Parameters:
;
;       p_lpszDeviceID - Device name or alias. [Required]
;
;       p_Factor - Treble factor [Required]
;
;
;   Return value:
;
;       Returns the return code from the MCI_SendString function which is 0
;       if the command completed successfully.
;
;
;   Observations:
;
;     - Factor range appears to be from 0 to ?????.
;     - Most MCI devices do not support this command.
;
;------------------------------------------------------------------------------
MCI_SetTreble(p_lpszDeviceID,p_Factor)
    {
    l_CmdString:="setaudio " . p_lpszDeviceID . " treble to " . p_Factor
    l_Return:=MCI_SendString(l_CmdString,Dummy)
    return l_lpszReturnString
    }



;----------
;
;   Function: MCI_ToMilliseconds
;
;
;   Description:
;
;       Converts the specified hour, minute and second into a valid milliseconds
;       timestamp.
;
;
;   Parameters:
;
;       Hour, Min, Sec - Position to convert to milliseconds
;
;
;   Return value:
;
;       The specified position converted to milliseconds.
;
;------------------------------------------------------------------------------
MCI_ToMilliseconds(Hour,Min,Sec)
    {
    milli:=Sec*1000
    milli += (Min*60)*1000
    milli += (Hour*3600)*1000
    return milli
    }



;----------
;
;   Function: MCI_ToHHMMSS
;
;
;   Description:
;
;       Converts the specified number of milliseconds to hh:mm:ss format.
;
;
;   Parameters:
;
;       p_ms - Number of milliseconds. [Required]
;
;       p_MinimumSize - Minimum size.  [Optional]  The default is 4.  This is
;           the minimum size in characters (not significant digits) that you
;           want returned.  Unless you want a ":" character to show as the
;           leading character, don't set this value to 3 or 6.
;
;
;   Return value:
;
;       Returns the amount of time in hh:mm:ss format with leading zero and ":"
;       characters suppressed unless the length is less than p_MinimumSize.
;
;       Note:  If the number of hours is greater than 99, the size of hour
;       ("hh") will increase as needed.
;
;
;   Usage Notes:
;
;       To use this function to create separate variables for the number of
;       hours, minutes, and seconds, set the p_MinimumSize parameter to 8 and
;       use simple SubStr commands to create these variables.  For example:
;
;           x:=MCI_ToHHMMSS(NumberOfMilliseconds,8)
;           HH:=SubStr(x,1,2)
;           MM:=SubStr(x,4,2)
;           SS:=SubStr(x,6,2)
;
;       To remove leading zeros from these variables, simply add 0 to the
;       extracted value.  For example:
;
;           MM:=SubStr(x,4,2)+0
;
;
;   Credit:
;
;       This function is a customized version of an example that was extracted
;       from the AutoHotkey documenation.
;
;------------------------------------------------------------------------------
MCI_ToHHMMSS(p_ms,p_MinimumSize=4)
    {
    ;-- Convert p_ms to whole seconds
    if p_ms is not Number
        l_Seconds=0
     else
        if p_ms<0
            l_Seconds=0
         else
            l_Seconds:=floor(p_ms/1000)

        
    ;-- Initialize and format
    l_Time=20121212  ;-- Midnight of an arbitrary date
    EnvAdd l_Time,l_Seconds,Seconds
    FormatTime l_mmss,%l_Time%,mm:ss
    l_FormattedTime:="0" . l_Seconds//3600 . ":" . l_mmss
        ;-- Allows support for more than 24 hours.


    ;-- Trim insignificant leading characters
    loop
        if StrLen(l_FormattedTime)<=p_MinimumSize
            break
         else
            if SubStr(l_FormattedTime,1,1)="0"
                StringTrimLeft l_FormattedTime,l_FormattedTime,1
             else
                if SubStr(l_FormattedTime,1,1)=":"
                    StringTrimLeft l_FormattedTime,l_FormattedTime,1
                else
                    break


    ;-- Return to sender
    return l_FormattedTime
    }



;----------
;
;   Function: MCI_SendString
;
;
;   Description:
;
;       This is the primary function that controls MCI operations.  With the
;       exception of the formatting functions, all of the functions in this
;       library call this function.
;
;
;   Parameters:
;
;       p_lpszCommand - MCI command string. [Required]
;
;       p_lpszReturnString - Variable name that receives return information.
;           [Required]
;
;       p_hwndCallback - Handle to a callback window if the "notify" flag was
;           specified in the command string.  [Optional]  The default is 0
;           (No callback window).
;
;
;   Return value:
;
;       Two values are returned:
;
;        1) The function returns zero if successful or an error number
;           otherwise.  See the "Debugging" section for more information.
;
;        2) If the MCI command string was a request for information, the
;           variable named in the p_lpszReturnString parameter will contain the
;           requested information.
;
;
;   Debugging:
;
;       If a non-zero value is returned from the call to the mciSendString
;       function, a call to the mciGetErrorString function is made to convert
;       the error number into a developer-friendly error message.  All of this
;       information is sent to the debugger in an easy-to-read format.
;
;------------------------------------------------------------------------------
MCI_SendString(p_lpszCommand,ByRef p_lpszReturnString,p_hwndCallback=0)
    {
    VarSetCapacity(p_lpszReturnString,100,0)
    l_Return:=DllCall("winmm.dll\mciSendStringA"
                     ,"str",p_lpszCommand                   ;-- lpszCommand
                     ,"str",p_lpszReturnString              ;-- lpszReturnString
                     ,"uint",100                            ;-- cchReturn
                     ,"uint",p_hwndCallback                 ;-- hwndCallback
                     ,"Cdecl int")                          ;-- Return type

    if ErrorLevel
        MsgBox
            ,262160  ;-- 262160=0 (OK button) + 16 (Error icon) + 262144 (AOT)
            ,%A_ThisFunc% Function Error,
               (ltrim join`s
                Unexpected ErrorLevel from DllCall to the
                "winmm.dll\mciSendStringA"
                function.  ErrorLevel=%ErrorLevel%  %A_Space%
                `nSee the AutoHotkey documentation (Keyword: DLLCall) for more
                information.  %A_Space%
               )


    ;-- Return code?
    if l_Return
        {
        VarSetCapacity(l_MCIErrorString,1024)
        DllCall("winmm\mciGetErrorStringA"
               ,"uint",l_Return                             ;-- MCI error number
               ,"str",l_MCIErrorString                      ;-- MCI error text
               ,"uint",1024)

        ;-- This is provided to help debug MCI calls
        outputdebug,
           (ltrim join`s
            End Func: %A_ThisFunc%: Unexpected return code from command string:
            "%p_lpszCommand%"
            `n--------- Return code=%l_Return% - %l_MCIErrorString%
           )
        }


    return l_Return
    }
