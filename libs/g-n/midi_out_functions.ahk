;+++++++++++++++++++++++++++++++++MIDI Functions++++++++++++++++++++++++++++++++++++++++
;AHK functions for performing various midi output operations by calling winmm.dll
;by Tom Boughner
;Last Modified 4/27/07
;
;
;
  ;-----------------------------Open the Windows midi API dll---------------------------------
OpenMidiAPI()   ;this should be done at the beginning of every script that uses any of these functions to load winmm.dll into memory
{
;it is important that you call this function by assigning it to a variable, so you retain the handle to it for closing later
  hModule := DllCall("LoadLibrary", "str", "winmm.dll")
return %hModule%
}

;*********************************************************************************************
;**********************Functions for Sending Individual Messages******************************
;*********************************************************************************************
;Keep in mind that ahk doesn't allow for precise timing control - sleep is always at least 10ms and can vary depending on processor load
;So, if you need to send several events with precise timing, use the Midi Stream functions instead.

  ;---------------------------------Open the midi port---------------------------------
  ;This is only used when opening the port for sending individual midi messages.
  ;To send a buffer of midi stream data, use midiStreamOpen
midiOutOpen(uDeviceID = 0)
{
  ;returns a handle for the device to be opened.  This handle must be used in all other function calls that reference this device.
  ;uDeviceID is the midi output port to open.  You can list these ports with the midiOutGetDevCaps function 
  strh_midiout = "0000"    ;initialize as a 4 byte string
  dwFlags := 0

  result := DllCall("winmm.dll\midiOutOpen"
        , UInt, &strh_midiout
        , UInt, uDeviceID
        , UInt, 0
        , UInt, 0
        , UInt, dwFlags
        , "UInt")

  if (result or errorlevel)
  {
    msgbox There was an error opening the midi port.  The port may be in use.  Try closing and reopening all midi-enabled applications.
    return -1
  }
  ;not sure why this is necessary, but handle is invalid without converting it:
  VarSetCapacity(h_midiout,4,0)
  h_midiout := ExtractInteger(strh_midiout, 0, False, 4)
return %h_midiout%
}

;---------------------------------Send 1 Midi message---------------------------------
midiOutShortMsg(h_midiout, EventType, Channel, Param1, Param2)
{
  ;h_midiout is handle to midi output device returned by midiOutOpen function
  ;EventType and Channel are combined to create the MidiStatus byte.  
  ;MidiStatus message table can be found at http://www.harmony-central.com/MIDI/Doc/table1.html
  ;Possible values for EventTypes are NoteOn (N1), NoteOff (N0), CC, PolyAT (PA), ChanAT (AT), PChange (PC), Wheel (W) - vals in () are optional shorthand 
  ;SysEx not supported by the midiOutShortMsg call
  ;Param3 should be 0 for PChange, ChanAT, or Wheel.  When sending Wheel events, put the entire Wheel value
  ;in Param2 - the function will split it into it's two bytes 
  ;returns 0 if successful, -1 if not.  
  
  ;Calc MidiStatus byte
  If (EventType = "NoteOn" OR EventType = "N1")
    MidiStatus :=  143 + Channel
  Else if (EventType = "NoteOff" OR EventType = "N0")
    MidiStatus := 127 + Channel
  Else if (EventType = "CC")
    MidiStatus := 175 + Channel
  Else if (EventType = "PolyAT" OR EventType = "PA")
    MidiStatus := 159 + Channel
  Else if (EventType = "ChanAT" OR EventType = "AT")
    MidiStatus := 207 + Channel
  Else if (EventType = "PChange" OR EventType = "PC")
    MidiStatus := 191 + Channel
  Else if (EventType = "Wheel" OR EventType = "W")
  {  
    MidiStatus := 223 + Channel
    Param2 := Param1 >> 8 ;MSB of wheel value
    Param1 := Param1 & 0x00FF ;strip MSB, leave LSB only
  }

  ;Midi message Dword is made up of Midi Status in lowest byte, then 1st parameter, then 2nd parameter.  Highest byte is always 0
  dwMidi := MidiStatus + (Param1 << 8) + (Param2 << 16)
  
  ;Call api function to send midi event  
  result := DllCall("winmm.dll\midiOutShortMsg"
            , UInt, h_midiout
            , UInt, dwMidi
            , UInt)
  
  if (result or errorlevel)
  {
    msgbox, There was an error sending the midi event
    return -1
  }
return
}

;---------------------------------Close MidiOutput---------------------------------
;This function should only be called when you are done using the midi output port, such as in a script's OnExit routine
midiOutClose(h_midiout)
{
  result := DllCall("winmm.dll\midiOutClose", UInt, h_midiout)
  if (result or errorlevel)
  {
    msgbox, There was an error closing the midi output port.  There may still be midi events being processed through it.
    return -1
  }
return
}

;---------------------------------Free winmm.dll---------------------------------
FreeMidiAPI(hModule)
{
  DllCall("FreeLibrary", "Uint", hModule) 

  if (result or errorlevel)
  {
    msgbox, There was an error freeing the MidiAPI file.  Are you sure you assigned the OpenMidiAPI call to a variable and passed that variable (unchanged) to this function?
    return -1
  }
return
}
;*********************************************************************************************
;**********************************Functions for Stream Output********************************
;*********************************************************************************************
;Functions:
;midiStreamOpen
;

;-------------Open the midi port for streaming-------------------------------------------
midiStreamOpen(DeviceID)
  ;MMRESULT midiStreamOpen(
  ;LPHMIDISTRM lphStream, pointer to handle to identify stream - filled by call to midiStreamOpen 
  ;LPUINT      puDeviceID, pointer to DeviceID (for some reason, pointing to the DeviceID doesn't work for me, I had to just pass the deviceID itself.)
  ;DWORD       cMidi,      Always 1
  ;DWORD_PTR   dwCallback,  pointer to callback function, event, etc. (0 = none)
  ;DWORD_PTR   dwInstance,   number you can assign to this stream
  ;DWORD      fdwOpen        type of callback
  ;);

  ;Returns handle to midi stream, used by all other midi stream out functions
  ;Note this routine does not use any callbacks
{
  strh_stream = "0000"    ;init stream pointer
  cMidi := 1      ;must be 1 per spec
  dwCallback := 0
  dwInstance := 0
  CALLBACK_NULL := 0
  
  VarSetCapacity(uDeviceID, 4, 0)
  InsertInteger(DeviceID, uDeviceID, 0, 4)

  result := DllCall("winmm.dll\midiStreamOpen"
        , UInt, &strh_stream
        , UInt, &uDeviceID
        , UInt, cMidi
        , UInt, dwCallback
        , UInt, dwInstance
        , UInt, CALLBACK_NULL
        , "UInt")

  if (result or errorlevel)
  {
    msgbox There was an error opening the midi port.  The port may be in use.  Try closing and reopening all midi-enabled applications.
    return -1
  }
  
  ;Not sure why, but the lines below are necessary to get AHK to treat the handle as a number instead of a string:
  ;the h_stream handle created by the above dll call is converted to an unsigned integer value - uih_stream,
  ;which is used as the handle for all of send midi commands that follow 
  VarSetCapacity(h_stream,4,0)
  h_stream := ExtractInteger(strh_stream, 0, False, 4)
return h_stream
}

;-------------Create Single Event----------------------------------------------------------
;Assembles MIDIEVENT structure for a single event.  This structure contains the event itself, plus it's timing.  
;This MIDIEVENT is then placed into the MidiBuffer.
;--Event Structure
;typedef struct { 
;    DWORD dwDeltaTime; offset to time this event should be sent 
;    DWORD dwStreamID;  streamID this should be sent to (assumed to always be 0 for our purposes)
;    DWORD dwEvent;     Event DWord (Highest byte is EventCode [shortMsg for us], followed by param2, param1, status)
;    DWORD dwParms[];   not needed for short messages
;} MIDIEVENT; 

;NOTE:  MidiBuffer needs to have already been given the correct size using VarSetCapacity. 
;This means you must determine how many events to send in the buffer before calling this routine
;BufferSize = 12 * number of events
;The function automatically places events in the buffer in the order they are received. 
AddEventToBuffer(ByRef MidiBuffer, DeltaTime, EventType, Channel, Param1, Param2, NewBuffer = 0)
;NewBuffer is optional parameter - it signals the function to reset BufOffset to 0, meaning we are starting a new buffer
{
  Static BufOffset := 0  ;variable to keep track of where in the buffer the next event goes, set to global so that it can be reset by calling script when starting a new buffer
  if (NewBuffer)
  {
    BufOffset := 0 
  }
  ;Check to make sure we haven't reached end of buffer already
  If (BufOffset + 12 > VarSetCapacity(MidiBuffer))
  {
    msgbox, Midi Buffer is already full.`nEvent %EventType% %Channel% %Param1% %Param2%`n could not be added.
    return -1
  }  

  ;Calc MidiStatus byte (same as in midiOutShortMsg Function)
  If (EventType = "NoteOn" OR EventType = "N1")
    MidiStatus :=  143 + Channel
  Else if (EventType = "NoteOff" OR EventType = "N0")
    MidiStatus := 127 + Channel
  Else if (EventType = "CC")
    MidiStatus := 175 + Channel
  Else if (EventType = "PolyAT" OR EventType = "PA")
    MidiStatus := 159 + Channel
  Else if (EventType = "ChanAT" OR EventType = "AT")
    MidiStatus := 207 + Channel
  Else if (EventType = "PChange" OR EventType = "PC")
    MidiStatus := 191 + Channel
  Else if (EventType = "Wheel" OR EventType = "W")
  {  
    MidiStatus := 223 + Channel
    Param2 := Param1 >> 8 ;MSB of wheel value
    Param1 := Param1 & 0x00FF ;strip MSB, leave LSB only
  }
  Else
  {
    msgbox, Invalid EventType.
    pause
  }

  ;Midi message Dword is made up of Midi Status in lowest byte, then 1st parameter, then 2nd parameter.  Highest byte is always 0
  dwEvent := MidiStatus + (Param1 << 8) + (Param2 << 16)
  VarSetCapacity(MIDIEVENT, 12)     ;12 is size of a single midievent
  
  ;create MIDIEVENT
  InsertInteger(DeltaTime, MIDIEVENT, 0, 4)
  InsertInteger(StreamID, MIDIEVENT, 4, 4)  
  InsertInteger(dwEvent, MIDIEVENT, 8, 4)  

  ;MEEvent := ExtractInteger(MIDIEVENT, 8, False, 4)    ;should be midi event
  ;Add Event to Buffer
  DllCall("RtlMoveMemory", "UInt", &MidiBuffer + BufOffset, "UInt", &MIDIEVENT, "UInt", 12)
  ;msgbox % errorlevel . " " . dwEvent . " " . dwEventTest . " " . &MIDIEVENT  . " " . &MidiBuffer

  ;MBDeltaTime := ExtractInteger(MidiBuffer, 0, False, 4)    ;should equal deltatime
  ;MBStreamID := ExtractInteger(MidiBuffer, 4, False, 4)    ;should equal 0
  ;MBEvent := ExtractInteger(MidiBuffer, 8, False, 4)    ;should be midi event
  ;msgbox, DT = %MBDeltaTime%  ID = %MBStreamID%    BufEvent = %MBEvent%   MidiEvent = %MEEvent%
  ;pause
  BufOffset := BufOffset + 12
}  
  
;--------------Set Tempo/Timebase for Stream------------------------------------
;Tempo and timebase are set by calling the midiStreamProperty function
;MMRESULT midiStreamProperty(
;  HMIDISTRM hm,                        handle to midi out device
;  LPBYTE lppropdata,                   Pointer to Property data
;  DWORD dwProperty                     Flags to specify what to change
;);
SetTempoandTimebase(h_stream, BPM, PPQ)
;BPM = tempo in beats per minute, PPQ = ticks (parts) per quarter note
{
;Create MIDIPROPTIMEDIV structure
;typedef struct { 
;    DWORD cbStruct;    seems to always = 8? why is this even needed?
;    DWORD dwTimeDiv;   contains number of ticks per quarter note
;} MIDIPROPTIMEDIV; 
  VarSetCapacity(MIDIPROPTIMEDIV, 8)
  InsertInteger(8, MIDIPROPTIMEDIV, 0, 4)
  InsertInteger(PPQ, MIDIPROPTIMEDIV, 4, 4)
  
;call function to set TimeDiv
  result := DllCall("winmm.dll\midiStreamProperty"
        , UInt, h_stream
        , UInt, &MIDIPROPTIMEDIV
        , UInt, 0x80000001      ;flags = MIDIPROPSET (0x80000000) and MIDIPROP_TIMEDIV (1)
        , "UInt")

  ;msgbox % errorlevel . "  " . result
  if (result)
  {
    msgbox There was an error setting the Timebase.
    pause
    return -1
  }

;Create MIDIPROPTEMPO structure and call function to set tempo  
;note - default tempo is 120BPM, we are changing to 125BPM since that makes each midi tick almost exactly .5ms
;typedef struct { 
;    DWORD cbStruct; 
;    DWORD dwTempo;  tempo as microseconds per quarter = 1/[125BPM/60(s/m)/1000000(us/s)] = 480,000
;} MIDIPROPTEMPO; 
  ;calculate tempo in micro-seconds per beat
  Tempo := 6.E7/BPM
  VarSetCapacity(MIDIPROPTEMPO, 8)
  InsertInteger(8, MIDIPROPTEMPO, 0, 4)
  InsertInteger(Tempo, MIDIPROPTEMPO, 4, 4)

  result := DllCall("winmm.dll\midiStreamProperty"
        , UInt, h_stream
        , UInt, &MIDIPROPTEMPO
        , UInt, 0x80000002      ;flags = MIDIPROPSET (0x80000000) and MIDIPROP_TEMPO (2)
        , "UInt")

  if (result)
  {
    msgbox There was an error setting the tempo.
    return -1
  }
return
}
  
;---------------------------Play Midi Buffer------------------------------------------
;Once the Buffer is created it's header must be 'Prepared' before sending it to the stream device.
;typedef struct { 
;    LPSTR      lpData;                 pointer to midi data stream
;    DWORD      dwBufferLength;         size of buffer
;    DWORD      dwBytesRecorded;        number of bytes of actual midi data in buffer
;    DWORD_PTR  dwUser;                 custom user data
;    DWORD      dwFlags;                should be 0
;    struct midihdr_tag far * lpNext;   do not use
;    DWORD_PTR  reserved;               do not use
;    DWORD      dwOffset;               offset generated by callback - not used in this routine
;    DWORD_PTR  dwReserved[4];          do not use
;} MIDIHDR; 
midiOutputBuffer(h_stream, ByRef MidiBuffer, BufSize, BufDur)
;BufSize is size of buffer in bytes.
;BufDur is the duration in ms of the buffer
{
  Global MIDIHDR      ;necessary so other functions can access MIDIHDR
  VarSetCapacity(MIDIHDR, 36, 0)    
  InsertInteger(&MidiBuffer, MIDIHDR, 0, 4)
  InsertInteger(BufSize, MIDIHDR, 4, 4)
  InsertInteger(BufSize, MIDIHDR, 8, 4)
  ; remaining props can all be 0

;Send header to prepare header function 
;MMRESULT midiOutPrepareHeader(
;  HMIDIOUT hmo,            
;  LPMIDIHDR lpMidiOutHdr,  
;  UINT cbMidiOutHdr        
;);
  result := DllCall("winmm.dll\midiOutPrepareHeader"
            , UInt, h_stream
            , UInt, &MIDIHDR
            , UInt, 36      ;size of header
            , "UInt")

  if (result)
  {
    msgbox There was an error in the midiOutPrepareHeader call.
    return -1
  }

;Send Header to MidiOut
;Sends Midi Buffer to Stream Output device, ready to play.  
;Note - this function does not actually play the buffer, it just cues it up.
;Use midiStreamRestart to play the buffer
;MMRESULT midiStreamOut(
;  HMIDISTRM hMidiStream,     handle for midi stream  
;  LPMIDIHDR lpMidiHdr,       pointer to MIDIHDR
;  UINT cbMidiHdr             size of MIDIHDR
;);

  result := DllCall("winmm.dll\midiStreamOut"
        , UInt, h_stream
        , UInt, &MIDIHDR
        , UInt, 36      ;size of header
        , "UInt")

  if (result)
  {
    msgbox There was an error in the midiStreamOut function.
    return -1
  }

;Start playback
    result := DllCall("winmm.dll\midiStreamRestart"
        , UInt, h_stream
        , "UInt")

  if (result)
  {
    msgbox There was an error in the midiStreamRestart function.
    return -1
  }
  
;Wait for duration of entire buffer - actual wait time will be at least this long
  Sleep, BufDur
  
  ;Stop Stream - this keeps it from going to sleep.  If this is not done, the stream seems to get suspended when not in use for about 1s, which causes it to 
  ;send the next buffer's events all at the same time.
  DllCall("winmm.dll\midiStreamStop", UInt, h_stream) 

return
}


;------------------When closing routine, unprepare header and close stream:------------------
midiOutCloseStream(h_stream, ByRef MIDIHDR)
;Unprepare Header
;uses identical format to midiOutPrepareHeader
{
  result := DllCall("winmm.dll\midiOutUnprepareHeader"
        , UInt, h_stream
        , UInt, &MIDIHDR
        , UInt, 36      ;size of header
        , "UInt")

  if (result)
  {
    msgbox There was an error in the midiOutUnprepareHeader function.
    return -1
  }

;CloseMidiStream
  result := DllCall("winmm.dll\midiStreamClose"
        , UInt, h_stream
        , "UInt")

  if (result)
  {
    msgbox There was an error closing the midi stream.
    return -1
  }
return
}







;*********************************************************************************************
;***********************************Utility Functions*****************************************
;*********************************************************************************************


;Get number of midi output devices on system
;Note that the first device has an ID of 0
MidiOutGetNumDevs()
{
  result := DllCall("winmm.dll\midiOutGetNumDevs")
return %result%
}


;Get name of a midiOut device for a given ID
MidiOutNameGet(uDeviceID = 0)
{
;MMRESULT midiOutGetDevCaps(
;  UINT_PTR      uDeviceID,      
;  LPMIDIOUTCAPS lpMidiOutCaps,  
;  UINT          cbMidiOutCaps   
;);

;typedef struct { 
;    WORD      wMid; 
;    WORD      wPid; 
;    MMVERSION vDriverVersion; 
;    CHAR      szPname[MAXPNAMELEN]; 
;    WORD      wTechnology; 
;    WORD      wVoices; 
;    WORD      wNotes; 
;    WORD      wChannelMask; 
;    DWORD     dwSupport; 
;} MIDIOUTCAPS; 

  ;Setup midiOutCaps structure (the only value we care about is szPname)
  VarSetCapacity(MidiOutCaps, 50, 0)  ;allows for szPname to be 32 bytes  
  OffsettoPortName := 8
  PortNameSize := 32
  result := DllCall("winmm.dll\midiOutGetDevCapsA"
            , UInt, uDeviceID
            , UInt, &MidiOutCaps
            , UInt, 50
            , UInt)
  
  if (result OR errorlevel)
  {
    msgbox, There was an error retrieving the name of midi output %uDeviceID%
    return -1
  }

  VarSetCapacity(PortName, 32)
  DllCall("RtlMoveMemory", str, PortName, Uint, &MidiOutCaps + OffsettoPortName, Uint, PortNameSize) 
  ;PortName := ExtractInteger(MidiOutCaps, OffsettoPortName, False, 4) 
  ;SubStr(MidiOutCaps, OffsettoPortName, PortNameSize)
return %PortName%
}

MidiOutsEnumerate()
{
;Returns the number of midi output devices, and also creates
;a global array called MidiOutPortName with the names of each device
  Global      ;variables created will be global by default
  local NumPorts, PortName, PortID
  NumPorts := MidiOutGetNumDevs()
  
  Loop, %NumPorts%
  {
    PortID := A_Index -1
    MidiOutPortName%PortID% := MidiOutNameGet(PortID)
    ;PortList = %PortList%PortID %PortID%: %PortName%`n
  }
  ;msgbox % msg
return % NumPorts
}

ExtractInteger(ByRef pSource, pOffset = 0, pIsSigned = false, pSize = 4)
; pSource is a string (buffer) whose memory area contains a raw/binary integer at pOffset.
; The caller should pass true for pSigned to interpret the result as signed vs. unsigned.
; pSize is the size of PSource's integer in bytes (e.g. 4 bytes for a DWORD or Int).
; pSource must be ByRef to avoid corruption during the formal-to-actual copying process
; (since pSource might contain valid data beyond its first binary zero).
{
    Loop %pSize%  ; Build the integer by adding up its bytes.
        result += *(&pSource + pOffset + A_Index-1) << 8*(A_Index-1)
    if (!pIsSigned OR pSize > 4 OR result < 0x80000000)
        return result  ; Signed vs. unsigned doesn't matter in these cases.
    ; Otherwise, convert the value (now known to be 32-bit) to its signed counterpart:
    return -(0xFFFFFFFF - result + 1)
}

InsertInteger(pInteger, ByRef pDest, pOffset = 0, pSize = 4)
; The caller must ensure that pDest has sufficient capacity.  To preserve any existing contents in pDest,
; only pSize number of bytes starting at pOffset are altered in it.
{
    Loop %pSize%  ; Copy each byte in the integer into the structure as raw binary data.
        DllCall("RtlFillMemory", "UInt", &pDest + pOffset + A_Index-1, "UInt", 1, "UChar", pInteger >> 8*(A_Index-1) & 0xFF)
}