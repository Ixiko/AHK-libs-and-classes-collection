; PotPlayer Function Library by Specter333
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=45385
; A complete list of functions can be found at the bottom of the page.
; Use Send functions to control PotPlayer with out it being active.


PotPlayer(msg)
	{
	; For "msg" use a number from the list of commands at the bottom of the page.
	SendMessage,0x0111,msg,,,ahk_class PotPlayer64
	}
PotPlayer_Play()
	{
	SendMessage,0x0111,20001,,,ahk_class PotPlayer64
	}
PotPlayer_Pause()
	{
	SendMessage,0x0111,20000,,,ahk_class PotPlayer64
	}
PotPlayer_PlayPause()
	{
	SendMessage,0x0111,10014,,,ahk_class PotPlayer64
	}
PotPlayer_Stop()
	{
	SendMessage,0x0111,20002,,,ahk_class PotPlayer64
	}
PotPlayer_Previous()
	{
	SendMessage,0x0111,10123,,,ahk_class PotPlayer64
	}
PotPlayer_Next()
	{
	SendMessage,0x0111,10124,,,ahk_class PotPlayer64
	}
PotPlayer_VolumeUp()
	{
	SendMessage,0x0111,10035,,,ahk_class PotPlayer64
	}
PotPlayer_VolumeDown()
	{
	SendMessage,0x0111,10036,,,ahk_class PotPlayer64
	}
PotPlayer_Mute()
	{
	SendMessage,0x0111,10037,,,ahk_class PotPlayer64
	}
PotPlayer_Close()
	{
	WinClose, ahk_class PotPlayer64
	}
PotPlayer_Current()
	{
	SendMessage, 0x0400, 0x5004,,, ahk_class PotPlayer64
	PotPlayerConvert := PotPlayerConvertMillisecToTime(ErrorLevel)
	Return, %PotPlayerConvert%
	}

;;;;;;;;;;;;;   This function provided by Odlanir
PotPlayerConvertMillisecToTime(msec)
	{
	secs := floor(mod((msec / 1000),60))
	mins := floor(mod((msec / (1000 * 60)), 60) )
	hour := floor(mod((msec / (1000 * 60 * 60)) , 24))
	return Format("{:02}:{:02}:{:02}",hour,mins,secs)
	}

PotPlayer_GetVol()
		{
		SendMessage, 0x0400, 0x5000,,, ahk_class PotPlayer64
		Return, %ErrorLevel%
		}
PotPlayer_SetVol(newvol)
		{
		SendMessage, 0x0400, 0x5001,newvol,, ahk_class PotPlayer64
		}
PotPlayer_GetTotalTime()
		{
		SendMessage, 0x0400, 0x5002,,, ahk_class PotPlayer64
		PotPlayerTotalTime := PotPlayerConvertMillisecToTime(ErrorLevel)
		Return, %PotPlayerTotalTime%
		}
PotPlayer_SetTime(newtime) ; Value in milliseconds
		{
		SendMessage, 0x0400, 0x5005,newtime,, ahk_class PotPlayer64
		}

PotPlayer_JumpForward() ; Set for 5 seconds but seems to jump an arbitrary amount.
		{
		ppct := ppctm()
		newtime := ppct+5000 ; Add 5 seconds to current time.
		SendMessage, 0x0400, 0x5005,newtime,, ahk_class PotPlayer64
		}
PotPlayer_JumpBackward() ; Set for -5 seconds but seems to jump an arbitrary amount.
		{
		ppct := ppctm()
		newtime := ppct-5000 ; Subract 5 seconds from current time.
		SendMessage, 0x0400, 0x5005,newtime,, ahk_class PotPlayer64
		}
ppctm() ; Retrives the current possition in milliseconds
		{
		SendMessage, 0x0400, 0x5004,,, ahk_class PotPlayer64
		Return, %ErrorLevel%
		}
PotPlayer_Status()
		{
		SendMessage, 0x0400, 0x5006,,, ahk_class PotPlayer64
		Return, %ErrorLevel%
		}

PotPlayer_AOT()
		{
		WinSet, AlwaysOnTop, Toggle, ahk_class PotPlayer64
		}

/*
Use one of the numbers from the commands below with the PotPlayer(msg)
function to call commands not included in this library.

Use only the number, example: the Open File function = PotPlayer(10158)

These commands use 0x0111 as the Msg parameter.
local CMD_PLAY              = 20001;
local CMD_PAUSE             = 20000;
local CMD_STOP              = 20002;
local CMD_PREVIOUS          = 10123;
local CMD_NEXT              = 10124;
local CMD_PLAY_PAUSE        = 10014;
local CMD_VOLUME_UP         = 10035;
local CMD_VOLUME_DOWN       = 10036;
local CMD_TOGGLE_MUTE       = 10037;
local CMD_TOGGLE_PLAYLIST   = 10011;
local CMD_TOGGLE_CONTROL    = 10383;
local CMD_OPEN_FILE         = 10158;
local CMD_TOGGLE_SUBS       = 10126;
local CMD_TOGGLE_OSD        = 10351;
local CMD_CAPTURE           = 10224;


These commands use 0x0400 as the Msg parameter
POT_GET_VOLUME   0x5000 // 0 ~ 100
POT_SET_VOLUME   0x5001 // 0 ~ 100
POT_GET_TOTAL_TIME  0x5002 // ms unit
POT_GET_PROGRESS_TIME 0x5003 // ms unit
POT_GET_CURRENT_TIME 0x5004 // ms unit
POT_SET_CURRENT_TIME 0x5005 // ms unit
POT_GET_PLAY_STATUS  0x5006 // -1:Stopped, 1:Paused, 2:Running
POT_SET_PLAY_STATUS  0x5007 // 0:Toggle, 1:Paused, 2:Running
POT_SET_PLAY_ORDER  0x5008 // 0:Prev, 1:Next
POT_SET_PLAY_CLOSE  0x5009
POT_SEND_VIRTUAL_KEY 0x5010 // Virtual Key(VK_UP, VK_DOWN....)
*/
