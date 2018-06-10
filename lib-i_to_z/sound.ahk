;
; AutoHotkey Version: 1.0.47.00
; Language:       Anyone
; Author:         Fincs <fernandoincs@hotmail.com>
;
; Script Function:
;   Functions to handle multimedia files
;

;===============================================================================
;
; Function Name:   Sound_Open
; Description::    Opens a sound file for use with other sound functions
; Parameter(s):    File - The sound file
;                  Alias [optional] - A name such as sound1, if you do not
;                                     specify one it is automatically generated
; Return Value(s): The sound handle or a 0 to indicate failure
; ErrorLevel value:   0 - No Error
;                   1 - Open failed
;                   2 - File doesn't exist
;
;===============================================================================

Sound_Open(File, Alias=""){
   Static SoundNumber = 0
   IfNotExist, %File%
   {
      ErrorLevel = 2
      Return 0
   }
   If Alias =
   {
      SoundNumber ++
      Alias = AutoHotkey%SoundNumber%
   }
   Loop, %File%
      File_Short = %A_LoopFileShortPath%
   r := Sound_SendString("open " File_Short " alias " Alias)
   If r
   {
      ErrorLevel = 1
      Return 0
   }Else{
      ErrorLevel = 0
      Return %Alias%
   }
}

;===============================================================================
;
; Function Name:   Sound_Close
; Description::    Closes a sound
; Parameter(s):    SoundHandle - Sound handle returned by Sound_Open
; Return Value(s): 1 - Success, 0 - Failure
;
;===============================================================================

Sound_Close(SoundHandle){
   r := Sound_SendString("close " SoundHandle)
   Return NOT r
}

;===============================================================================
;
; Function Name:   Sound_Play
; Description::    Plays a sound from the current position (beginning is the default)
; Parameter(s):    SoundHandle - Sound handle returned by Sound_Open
;               Wait - If set to 1 the script will wait for the sound to finish before continuing
;                   - If set to 0 the script will continue while the sound is playing
; Return Value(s): 1 - Success, 0 - Failure
;
;===============================================================================

Sound_Play(SoundHandle, Wait=0){
   If(Wait <> 0 AND Wait <> 1)
      Return 0
   If Wait
      r := Sound_SendString("play " SoundHandle " wait")
   Else
      r := Sound_SendString("play " SoundHandle " from 0")    ;play door from 0

   Return NOT r
}

;===============================================================================
;
; Function Name: Sound_Stop
; Description::    Stops the sound
; Parameter(s):    SoundHandle - Sound handle returned by Sound_Open
; Return Value(s): 1 - Success, 0 - Failure
;
;===============================================================================

Sound_Stop(SoundHandle){
   r := Sound_SendString("seek " SoundHandle " to start")
   r2 := Sound_SendString("stop " SoundHandle)
   If(r AND r2)
   {
      Return 0
   }Else{
      Return 1
   }
}

;===============================================================================
;
; Function Name:   Sound_Pause
; Description::    Pauses the sound
; Parameter(s):    SoundHandle - Sound handle returned by Sound_Open
; Return Value(s): 1 - Success, 0  - Failure
;
;===============================================================================

Sound_Pause(SoundHandle){
   r := Sound_SendString("pause " SoundHandle)
   Return NOT r
}

;===============================================================================
;
; Function Name:   Sound_Resume
; Description::    Resumes the sound after being paused
; Parameter(s):    SoundHandle - Sound handle returned by Sound_Open
; Return Value(s): 1 - Success, 0  - Failure
;
;===============================================================================

Sound_Resume(SoundHandle){
   r := Sound_SendString("resume " SoundHandle)
   Return NOT r
}

;===============================================================================
;
; Function Name:   Sound_Length
; Description::    Returns the length of the sound
; Parameter(s):    SoundHandle - Sound handle returned by Sound_Open
; Return Value(s): Length of the sound - Success
;
;===============================================================================

Sound_Length(SoundHandle){
   r := Sound_SendString("set time format miliseconds", 1)
   If r
      Return 0
   r := Sound_SendString("status " SoundHandle " length", 1, 1)
   Return %r%
}

;===============================================================================
;
; Function Name:   Sound_Seek
; Description::    Seeks the sound to a specified time
; Parameter(s):    SoundHandle - Sound handle returned by Sound_Open
;                  Hour, Min, Sec - Time to seek to
; Return Value(s): 1 - Success, 0 - Failure,
;
;===============================================================================

Sound_Seek(SoundHandle, Hour, Min, Sec){
   milli := 0
   r := Sound_SendString("set time format milliseconds", 1)
   If r
      Return 0
   milli += Sec  * 1000
   milli += Min  * 1000 * 60
   milli += Hour * 1000 * 60 * 60
   r := Sound_SendString("seek " SoundHandle " to " milli)
   Return NOT r
}

;===============================================================================
;
; Function Name:   Sound_Status
; Description::    All devices can return the "not ready", "paused", "playing", and "stopped" values.
;               Some devices can return the additional "open", "parked", "recording", and "seeking" values.(MSDN)
; Parameter(s):    SoundHandle - Sound handle returned by Sound_Open
; Return Value(s): Sound Status
;
;===============================================================================

Sound_Status(SoundHandle){
   Return Sound_SendString("status " SoundHandle " mode", 1, 1)
}

;===============================================================================
;
; Function Name:   Sound_Pos
; Description::    Returns the current position of the song
; Parameter(s):    SoundHandle - Sound handle returned by Sound_Open
; Return Value(s): Current Position - Success, 0 - Failure
;
;===============================================================================

Sound_Pos(SoundHandle){
   r := Sound_SendString("set time format miliseconds", 1)
   If r
      Return 0
   r := Sound_SendString("status " SoundHandle " position", 1, 1)
   Return %r%
}

;===============================================================================

Sound_SendString(string, UseSend=0, ReturnTemp=0){
   If UseSend
   {
      VarSetCapacity(stat1, 32, 32)
      DllCall("winmm.dll\mciSendStringA", "UInt", &string, "UInt", &stat1, "Int", 32, "Int", 0)
   }Else{
      DllCall("winmm.dll\mciExecute", "str", string)
   }
   If(UseSend And ReturnTemp)
      Return stat1
   Else
      Return %ErrorLevel%
}