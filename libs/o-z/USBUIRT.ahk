;;;;;;;;;;;;;;;;;;;;;;;;;;;             USB-UIRT Functions Library             ;;;;;;;;;;;;;;;;;;;;;;;;
; Version 1.1 contains many bug fixes.  Much help was given by wtg, Thank You.	                      ;
;                                                                                                     ;
; Completed by Specter333 (I'm only half evil)                                                        ;  
; Based almost entirely on the work of Laszlo, cynopsys and Thracx.  I would have never been able to  ;
; complete this if not for them getting it as far along as they did.  Thank You.                      ;
; http://www.autohotkey.com/forum/viewtopic.php?t=43255&start=0                                       ;
;                                                                                                     ;
; USB-UIRT developed by Jon Rhees, http://www.usbuirt.com/.                                           ;                                                       ;
; A large database of IR remote codes can be found here;                                              ;
; http://files.remotecentral.com/                                                                     ;
; Test these remote codes by copying them into the edit window of the Transmit IR example script.     ;
;                                                                                                     ;
; Once installed the uuirt.dll should be in C:\WINDOWS\system32\                                      ;
; Example scripts and USB-UIRT developer info located at bottom.                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

/*
                            USB-UIRT Functions 
USBUIRT_LoadDLL()                           Opens communication with the USB-UIRT.
USBUIRT_ReleaseDLL()                        Terminates communication with the USB-UIRT.
USBUIRT_ReceiveIR()                         Receives IR codes suitable for use as a label.
USBUIRT_SendIRRaw(IRCode,RepeatCount=1)     Sends IR code stored in parameter in UIRT-native STRUCT or RAW format.
USBUIRT_SendIRPronto(IRCode,RepeatCount=1)  Sends IR code stored in parameter in Pronto format.
USBUIRT_DriverInfo()                        Retrieves driver version.
USBUIRT_HardwareInfo()                      Retrieves the USB-UIRT's firmware version, protocol version and firmware install date.
USBUIRT_ConfigInfo()                        Retrieves the USB-UIRT's configuration settings.
USBUIRT_SetConfig(config)                   Change the configuration.
USBUIRT_LearnRaw()                          Learn an IR code from a remote control and save in Raw format.
USBUIRT_Abort(LearnPID)                     Aborts the learning command by killing it's process from another script.
*/


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Load the DLL.
USBUIRT_LoadDLL()
	{ 
	DllCall("LoadLibrary", Str,"C:\WINDOWS\system32\uuirtdrv.dll")
	}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Release the DLL.
USBUIRT_ReleaseDLL()
	{ 
	DllCall("C:\WINDOWS\system32\uuirtdrv.dll\UUIRTClose", UInt,hndl)
	}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Receive IR codes for use as labels.
; Functioning but incomplete

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Receive IR codes
; Functioning but incomplete.  Runs subroutines by using "If Islabel" but does not return the IRcode 
; to the script.  Use the example below to capture IR codes for use as labels.
USBUIRT_ReceiveIR()
	{ 
	hndl := DllCall("C:\WINDOWS\system32\uuirtdrv.dll\UUIRTOpen") 
	getAirIrCodeAddress := RegisterCallback("USBUIRT_AirCode")
	DllCall("C:\WINDOWS\system32\uuirtdrv.dll\UUIRTSetReceiveCallback", UInt, hndl 
		, UInt, getAirIrCodeAddress ; Address of received IR code.
		, Str, Userdata) ; This parameter is useful for carrying context information, etc.
	}

USBUIRT_AirCode(IrEventStr,Userdata)
	{
	VarSetCapacity(IrCode, 12)
	DllCall("lstrcpy", Str, IrCode, UInt, irEventStr) ; Copy the string into the script's variable.
	VarSetCapacity(IrCode, -1) ; Update the variable's internally-stored length to reflect its new contents.
	
	If IsLabel(IRcode) 
		GoSub, %IRcode%
	}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Transmit an IR code for UIRT-native STRUCT or RAW.
; Added the ability to define the number of times to repeat the code as multiple repeats are required
; by some items.
USBUIRT_SendIRRaw(IRCode,RepeatCount=1)
	{
	hndl := DllCall("C:\WINDOWS\system32\uuirtdrv.dll\UUIRTOpen")
	DllCall("C:\WINDOWS\system32\uuirtdrv.dll\UUIRTTransmitIR", UInt,hndl
		, Str, IRCode ; Variable containing IR code to transmit
		, Int, 0x00 ;Codeformat (UUIRT: 0, UIRT-native STRUCT or RAW: 0x0000)
		, Int, RepeatCount  ; Variable containing the number of times to repeat the code.
		, Int, 100  ; inactivityWaitTime ms
		, Int, 0  ; HANDLE hEvent to signal code sent
		, UInt, 0, UInt, 0) ; reserved
	}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Transmit an IR code for PRONTO.
; Added the ability to define the number of times to repeat the code as multiple repeats are required
; by some items.
USBUIRT_SendIRPronto(IRCode,RepeatCount=1)
	{ 
	hndl := DllCall("C:\WINDOWS\system32\uuirtdrv.dll\UUIRTOpen")
	DllCall("C:\WINDOWS\system32\uuirtdrv.dll\UUIRTTransmitIR", UInt,hndl
		, Str, IRCode ; Variable containing IR code to transmit
		, Int, 0x10 ;Codeformat (UUIRT: 0, PRONTO: 0x0010)
		, Int, RepeatCount  ; Variable containing the number of times to repeat the code.
		, Int, 100  ; inactivityWaitTime ms
		, Int, 0  ; HANDLE hEvent to signal code sent
		, UInt, 0, UInt, 0) ; reserved
	}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Retrieve Driver Information.
USBUIRT_DriverInfo()
	{ 
	VarSetCapacity(vers,12)
	DllCall("C:\WINDOWS\system32\uuirtdrv.dll\UUIRTGetDrvInfo", UIntP,vers) ; Current driver version
	drvvers := NumGet(vers,0)
	Return vers
	}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Retrieve Hardware Information
USBUIRT_HardwareInfo()
	{ 
	hndl := DllCall("C:\WINDOWS\system32\uuirtdrv.dll\UUIRTOpen") 
	VarSetCapacity(uInfo,12)
	DllCall("C:\WINDOWS\system32\uuirtdrv.dll\UUIRTGetUUIRTInfo", UInt, hndl
	, UInt, &uInfo) ; String containing USB-UIRT hardware information.
	fwVersion:= NumGet(uInfo,0)"," ; Firmware Version
	ProtocolVersion:= NumGet(uInfo,4)"," ; Protocol Version 
	FW_DMY:= NumGet(uInfo,9,"UChar") "/" NumGet(uInfo,8,"UChar") "/"  NumGet(uInfo,10,"UChar")+2000 ; Firmware install date.
	Return fwVersion ProtocolVersion FW_DMY
	}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Get Current Configuration Info
USBUIRT_ConfigInfo()
	{
	hndl := DllCall("C:\WINDOWS\system32\uuirtdrv.dll\UUIRTOpen") 
	VarSetCapacity(uInfo,12)
	DllCall("C:\WINDOWS\system32\uuirtdrv.dll\UUIRTGetUUIRTConfig", UInt, hndl
		, UInt, &uInfo) ; Current configuration number.  See "Set Configuration" below for numbers.
	cinf:= NumGet(uInfo)
	Return cinf
	}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Set Configuration
USBUIRT_SetConfig(config)
	{
	hndl := DllCall("C:\WINDOWS\system32\uuirtdrv.dll\UUIRTOpen")
	DllCall("C:\WINDOWS\system32\uuirtdrv.dll\UUIRTSetUUIRTConfig", UInt, hndl
		, UInt, config) ; 1 = Blink on receive, 2 = Light on Transmit, 4 = Generate Legacy codes
	} ; Add numbers together to combine configuration settings. ie, 3 = Blink on receive and light on transmit.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Learn IR Code, Raw Format
USBUIRT_LearnRaw()
	{
	hndl := DllCall("C:\WINDOWS\system32\uuirtdrv.dll\UUIRTOpen")
	VarSetCapacity(IRcode, 2048)
	abort = 0
	DllCall("C:\WINDOWS\system32\uuirtdrv.dll\UUIRTLearnIR", UInt,hndl
		, Int, 0x100      ; codeFormat: UUIRTDRV_IRFMT_LEARN_FORCERAW
		, Str, IRCode     ; the received code
		, UInt, CBfunc    ; PLEARNCALLBACKPROC progressProc --------------- Not yet implemented
		, Str, "Userdata" ; *userData: passed by the USB-UIRT driver to progressProc calls
		, UIntP, abort    ; *pAbort set to 1 in another thread: requests abort --- Not yet implemented
		, UInt, 0         ; param1 = forced frequency
		, UInt,0, UInt,0) ; reserved
	Return IRCode "-" Userdata
	}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Abort Learning Process
; Once the learning process starts the gui window will lock up until an IR code is received.
; To abort the process the window's PID must be closed from another script.
; In the example below, another script is ran prior to starting the learn process.  The second script
; retrieves the PID of the first script and kills the process if the abort button is tested or the 
; 60 second timer runs out.	
USBUIRT_Abort(LearnPID)
	{
	Process, Close, %LearnPID%
	}
	
/*
                                          Working Example Scripts
************************* Receive IR ********************************************************************
; This first script is capturing the IR codes suitable for direct use as labels in your scripts.  As I can
; not figure out how to get the IRcode returned from the function, this script includes the necessary 
; functions and does not use the library functions.  The next script is an example of how to use these 
; codes as labels.

; Catch IR labels.
#NoEnv 
SendMode Input 
SetWorkingDir %A_ScriptDir%  
#SingleInstance Force
SetBatchLines -1
SetWinDelay -1
OnExit releasedll

Gui, Add, GroupBox, x5 y5 w150 h40, IR Code
Gui, Add, Edit, x10 y20 w140 vEdit1, ; Displays the received IR code.  Copy code from your remote and replace labels below.

Gui, Show, y10 w160, Catch IR Labels
Gosub openuuirt
Return

releasedll:
USBUIRT_ReleaseDLL()

Exit:
GuiClose:
Gui, Destroy
ExitApp

openuuirt:
DllCall("LoadLibrary", Str,"C:\WINDOWS\system32\uuirtdrv.dll")
hndl := DllCall("uuirtdrv.dll\UUIRTOpen") 
getAirIrCodeAddress := RegisterCallback("getAirIrCode")
DllCall("C:\WINDOWS\system32\uuirtdrv.dll\UUIRTSetReceiveCallback", UInt, hndl
, UInt, getAirIrCodeAddress  
, Str, Userdata) 

getAirIrCode(IrEventStr,data){
	VarSetCapacity(IrCode, 12) 
	DllCall("lstrcpy", Str, IrCode, UInt, irEventStr)
	VarSetCapacity(IrCode, -1)
	GuiControl, , Edit1, %IRcode%
	sLabel := IRcode
	If IsLabel(sLabel)
		GoSub, %sLabel%

}
Return


; The following script is a demonstration of using the IR codes captured with the script above as labels in your scripts.  
; This script runs in the background, no gui window will open but the normal AHK icon will be in the system tray.
; The only requirement for using IR labels is to make the two library calls to load the dll and receive the IR
; code in the auto execute section of your scripts.

; Use IR codes as labels.
#NoEnv 
SendMode Input 
SetWorkingDir %A_ScriptDir%  
#SingleInstance Force
#Persistent
OnExit releasedll
USBUIRT_LoadDLL() ; Loads uuirt driver, must be in auto execute section.
USBUIRT_ReceiveIR() ;Loads IR receive function.
Return

170000A8E0CB: ; Replace with your remote button code.
MsgBox, USB-UIRT 1
Return

1500003CE1E9: ; Replace with your remote button code.
MsgBox, USB-UIRT 2
Return

releasedll:
USBUIRT_ReleaseDLL()

1500003817FA: ; Replace with your remote button code.
Exit:
GuiClose:
Gui, Destroy
ExitApp


************************* Transmit IR *******************************************************************
; Any IR code in the edit box can be transmitted by pressing the corresponding format's send button.
; Example codes provided.

#NoEnv 
SendMode Input 
SetWorkingDir %A_ScriptDir%  
#SingleInstance Force
USBUIRT_LoadDLL()
OnExit releasedll

Gui, Add, Edit, x5 y5 w300 r10 vEdit1,

Gui, Add, GroupBox, x5 y+5 w300 h40 ,
Gui, Add, Button, x10 yp+12 w100 gIRsendR,  Send IR
Gui, Add, Button, x+5 w120 gloadcode, Load Example Code
Gui, Add, Text, x+5, RAW

Gui, Add, GroupBox, x5 yp+20 w300 h40 ,
Gui, Add, Button, x10 yp+12 w100 gIRsendP,  Send IR
Gui, Add, Button, x+5 w120 gloadcodep, Load Example Code
Gui, Add, Text, x+5, Pronto

Gui, Show, y10 ,
Return

27800328FFFF:  
SetTimer, IRsendR, 100
Return

IRsendR: 
SetTimer, IRsendR, Off 
Gui, Submit, NoHide
IRCode = %Edit1% 
USBUIRT_SendIRRaw(IRCode)
Return

IRsendP: 
Gui, Submit, NoHide
IRCode = %Edit1% 
USBUIRT_SendIRPronto(IRCode)
Return

releasedll:
USBUIRT_ReleaseDLL()

Exit:
GuiClose:
Gui, Destroy
ExitApp

; Both of these example codes were captured using the "Learn IR" example.
loadcodep: 
GuiControl, , Edit1,  ; IR Code to bring up the menu on a Dell projector.
(Join
0000 006A 0000 0022 015E 00B0 0016 0042 0016 0042 0016 0042 0016 0042 0016 0016 0016 0016
 0016 0042 0016 0016 0016 0016 0016 0016 0016 0016 0016 0016 0016 0042 0016 0016 0016 0042
 0016 0016 0016 0042 0016 0017 0016 0016 0016 0016 0016 0042 0016 0016 0016 0016 0016 0016
 0016 0016 0016 0042 0016 0042 0016 0042 0016 0016 0016 0042 0016 0042 0016 0042 0016 0646
)
Return

loadcode:
GuiControl, , Edit1, ; Same code as above.
(Join
F40R0327815B80AE16411641164116411616161616411616161616161616161616411616164116161641161616
16161616411616161616161616164116411641161616411641164116
)
Return

; ************************* Learn IR **********************************************************************
; Functions to learn an IR code.
; Once a learn button is pressed the gui will remain locked until an IR code is received or it's process
; is stopped via USBUIRT_Abort(LearnPID) from another script.
; This learning script is used in conjunction with the "Abort.ahk" script directly below.

#SingleInstance Force
#NoEnv
#NoTrayIcon ; Doesn't leave icon in tray when learning process is aborted.
OnExit releasedll

USBUIRT_LoadDLL()           ; open communication to UIRT

Gui, Add, Edit, x5 y5 w400 h150 vEdit1,
Gui, Add, GroupBox, y+5 w400 h160, 
Gui, Add, Text, x10 yp+15 w390, 
(Join
The USB-UIRT transceiver uses a short range receiver for the learning process.`n`n
1. Hold the remote from 1/2 to 2 inches from the transceiver.  Experiment to find the
 optimal range for your remote.`n
2. Click "Learn IR" to start the learning process in "Raw" format.`n
3. Press and hold the desired button on your remote until the learning process is complete.`n`n
Note, the abort function must be called from another script.  Once the learn process has started this gui window
 will stop responding until an IR code is received.  If a code is not received the process must
 be killed via the abort script.
)
Gui, Add, Button, y+10 w75 glearnir, Learn IR
Gui, Add, Button, x+5 w85 gclear, Clear Window

Gui, Add, Button, x+145 w85 gTestCode, Test IR Code

Gui, Show, w410, Learn IR Codes
Return

clear:
GuiControl, , Edit1,
Return

learnir:
GuiControl, , Edit1,
Run , Abort.ahk, %A_ScriptDir%, 
WinWait , Abort IR Learning Process

rawir:= USBUIRT_LearnRaw()
StringSplit, rinfo, rawir, -,, 
GuiControl, , Edit1, %rinfo1%
WinClose , Abort IR Learning Process
Return

TestCode:
Gui, Submit, NoHide
USBUIRT_SendIRRaw(Edit1)
Return

releasedll:
USBUIRT_ReleaseDLL()

Exit:
GuiClose:
Gui, Destroy
ExitApp


; *************************  Abort IR Learning ************************************************************
; This script is ran when the Learn IR script above enters the learning mode.   This script retrieves
; the PID of the IR Learning script and starts a 60 timer.  If the "Abort" button is clicked or the 
; timer runs out the IR Learning script's process is killed.  Otherwise the IR Learning gui will stay
; locked until an IR code is received.

#NoEnv  
SendMode Input  
SetWorkingDir %A_ScriptDir%  
#SingleInstance Force
#NoTrayIcon
Gui , Margin, 5, 5
Gui , Font , s12
Gui, Add,  Text, x5 y5 w290 Center, IR Learning Process Initiated.
Gui, Add,  Text, x5 y25 w180 Center, Process will terminate in
Gui , Font , s14
Gui, Add,  Text, x+5 y22 vCountDown, 60
Gui , Font , s12
Gui, Add,  Text, x+10 y25, seconds.
Gui, Add, Button, x5 y50 w290 h25 gLearnAbort, Abort
Gui , +AlwaysOnTop -Caption +0x400000
Gui, Show, y10 w300, Abort IR Learning Process
WinGet, WinPID, PID, Learn IR Codes,
Count = 60
SetTimer , CountDown, 1000
Return

CountDown:
Gui , Submit, NoHide
Count := Count-1
GuiControl , , CountDown, %Count%
If Count = 0
	{
	GoSub LearnAbort
	GoTo Exit
	}
IfWinNotExist , ahk_pid %WinPID%
	GoTo Exit
Return

LearnAbort:
Gui , Submit, NoHide
USBUIRT_Abort(WinPID)
Return

Exit:
GuiClose:
Gui, Destroy
ExitApp


;*************************  Configuration Get/Set ********************************************************
; The state of the Radio buttons upon opening the scripts is the result of Configuration get.
; To use Configuration Set, choose new settings and click Set.

#NoEnv 
SendMode Input 
SetWorkingDir %A_ScriptDir%  
#SingleInstance Force
OnExit releasedll

USBUIRT_LoadDLL()

Gui, Add, GroupBox, x5 y5 w100 h40 Center, Blinks on Receive
Gui, Add, Radio, x10 y25 vr1, On
Gui, Add, Radio, x50 y25 vr11, Off

Gui, Add, GroupBox, x105 y5 w100 h40 Center, Lights on Transmit
Gui, Add, Radio, x110 y25 vr2, On
Gui, Add, Radio, x160 y25 vr12, Off

Gui, Add, GroupBox, x5 y50 w100 h40 Center, Generate 'Legacy'
Gui, Add, Radio, x10 y70 vr3, On
Gui, Add, Radio, x50 y70 vr13, Off

Gui, Add, GroupBox, x105 y50 w100 h40 Center, Set Configuration
Gui, Add, Button, x115 y65 w80 h20 gdetconfig, Set 

Gui, Show, y25
GoSub ConfigInfo
Return

detconfig:
Gui, Submit, NoHide
If r1 = 1
	blink = 1
Else blink = 0
If r2 = 1
	light = 2
Else light = 0
If r3 = 1
	leg = 4
Else leg = 0
config := light + blink + leg
GoTo setconfig
Return

setconfig:
USBUIRT_SetConfig(config)
Return

releasedll:
USBUIRT_ReleaseDLL()

Exit:
GuiClose:
Gui, Destroy
ExitApp

ConfigInfo:
cinf := USBUIRT_ConfigInfo()
If cinf = 0
	{
	GuiControl, , r11, 1
	GuiControl, , r12, 1
	GuiControl, , r13, 1
	Return
	}
If cinf = 1
	{
	GuiControl, , r1, 1
	GuiControl, , r12, 1
	GuiControl, , r13, 1
	Return
	}
If cinf = 2
	{
	GuiControl, , r11, 1
	GuiControl, , r2, 1
	GuiControl, , r13, 1
	Return
	}
If cinf = 3
	{
	GuiControl, , r1, 1
	GuiControl, , r2, 1
	GuiControl, , r13, 1
	Return
	}
If cinf = 4
	{
	GuiControl, , r11, 1
	GuiControl, , r12, 1
	GuiControl, , r3, 1
	Return
	}
If cinf = 5
	{
	GuiControl, , r1, 1
	GuiControl, , r12, 1
	GuiControl, , r3, 1
	Return
	}
If cinf = 6
	{
	GuiControl, , r11, 1
	GuiControl, , r2, 1
	GuiControl, , r3, 1
	Return
	}
If cinf = 7
	{
	GuiControl, , r1, 1
	GuiControl, , r2, 1
	GuiControl, , r3, 1
	}
Return	

*************************  Hardware Info ****************************************************************

#NoEnv 
SendMode Input 
SetWorkingDir %A_ScriptDir%  
#SingleInstance Force
OnExit releasedll

USBUIRT_LoadDLL()

Gui, Add, GroupBox, x5 y5 w100 h40 , Firmware Version
Gui, Add, Edit, x10 y20 w90 r1 vEdit1,
Gui, Add, GroupBox, x5 y50 w100 h40 , Protocol Version
Gui, Add, Edit, x10 y65 w90 r1 vEdit2,
Gui, Add, GroupBox, x5 y95 w100 h40 , Firmware Date
Gui, Add, Edit, x10 y110 w90 r1 vEdit3,

hinf := USBUIRT_HardwareInfo()
StringSplit, info, hinf, `,, 
GuiControl, , Edit1, %info1%
GuiControl, , Edit2, %info2%
GuiControl, , Edit3, %info3%

Gui, Show, y10 w110, Hardware Info
Return

releasedll:
USBUIRT_ReleaseDLL()

Exit:
GuiClose:
Gui, Destroy
ExitApp

*************************  Driver Info ******************************************************************
#NoEnv 
SendMode Input 
SetWorkingDir %A_ScriptDir%  
#SingleInstance Force
OnExit releasedll

Gui, Add, GroupBox, x5 y5 w100 h40, Driver Version
Gui, Add, Edit, x10 y20 w90 r1 vEdit1,
driver := USBUIRT_DriverInfo()
GuiControl, , Edit1, %driver%
Gui, Show, y10 w110, Dver
Return

releasedll:
USBUIRT_ReleaseDLL()

Exit:
GuiClose:
Gui, Destroy
ExitApp
*/





/* USB-UIRT API: uuirtdrv.dll  (www.usbuirt.com/api_example_code.zip)
c:\t\USB-UIRT\uuirtdrv.dll

UUIRTDRV_API HUUHANDLE PASCAL UUIRTOpen(void);

Opens communication with the USB-UIRT. On success, returns a handle to be
used in subsequent calls to USB-UIRT functions. On failure, returns
INVALID_HANDLE_VALUE. A call to UUIRTOpen should occur prior to any other
driver function calls (with the exception of UUIRTGetDrvInfo below).


UUIRTDRV_API BOOL PASCAL UUIRTClose(HUUHANDLE hHandle);

Terminates communication with the USB-UIRT. Should be called prior to
terminating host program.


UUIRTDRV_API BOOL PASCAL UUIRTGetDrvInfo(unsigned int *puDrvVersion);

Retrieves information about the *driver* (not the hardware itself). This is
intended to allow version control on the .DLL driver and accomodate future
changes and enhancements to the API. Returns TRUE on success, as well as a
driver version number in *puDrvVersion. NOTE: This call may be called prior
to a call to UUIRTOpen.


UUIRTDRV_API BOOL PASCAL UUIRTGetUUIRTInfo(HUUHANDLE hHandle, PUUINFO *puuInfo);

Retrieves information about the UUIRT hardware. On success, returns TRUE and
fills in the structure PUUINFO, defined as follows:

typedef struct {
   unsigned int fwVersion;   // version of firmware residing on the USB-UIRT.
   unsigned int protVersion; // protocol version supported by the USB-UIRT firmware.
   unsigned char fwDateDay;  // firmware revision date
   unsigned char fwDateMonth;//
   unsigned char fwDateYear; //
} UUINFO, *PUUINFO;


UUIRTDRV_API BOOL PASCAL UUIRTGetUUIRTConfig(HUUHANDLE hHandle, PUINT32 puConfig);

Retrieves the current feature configuration bits from the USB-UIRT's
nonvolatile configuration memory. These various configuration bits control
how the USB-UIRT behaves. Most are reserved for future implementation and
shout be read and written as Zero. Using this API call is optional and is
only needed to support changing USB-UIRT's internal 'preferences'. Bits
defined in uConfig are as follows:

#define UUIRTDRV_CFG_LEDRX 0x01 // Indicator LED on USB-UIRT blinks when remote signals are received
#define UUIRTDRV_CFG_LEDTX 0x02 // Indicator LED on USB-UIRT lights during IR transmission.
#define UUIRTDRV_CFG_LEGACYRX 0x04 // Generate 'legacy' UIRT-compatible codes on receive
#define RESERVED0 0x08
#define RESERVED1 0x10
...

UUIRTDRV_API BOOL PASCAL UUIRTSetUUIRTConfig(HUUHANDLE hHandle, UINT32 uConfig);

Configures the current feature configuration bits for the USB-UIRT's
nonvolatile configuration memory. These various configuration bits control
how the USB-UIRT behaves. See definition of uConfig in UUIRGetUUIRTConfig
above


UUIRTDRV_API BOOL PASCAL UUIRTTransmitIR(HUUHANDLE hHandle, char *IRCode,
int codeFormat, int repeatCount, int inactivityWaitTime, HANDLE hEvent, void
*reserved0, void *reserved1);

Transmits an IR code via the USB-UIRT hardware. The IR code is a
null-terminated *string*. codeFormat is a format specifier which identifies
the format of the IRCode code. Currently, supported formats are
Compressed_UIRT (STRUCT), RAW, and Pronto-RAW. RepeatCount indicates how
many iterations of the code should be sent (in the case of a 2-piece code,
the first stream is sent once followed by the second stream sent repeatCount
times). InactivityWaitTime is the time in milliseconds since the last
received IR activity to wait before sending an IR code -- normally pass 0
for this parameter. hEvent is an optional event handle which is obtained by
a call to CreateEvent. If hEvent is NULL, the call to UUIRTTransmitIR will
block and not return until the IR code has been fully transmitted to the
air. If hEvent is not NULL, it must be a valid Windows event hande. In this
case, UUIRTTransmitIR will return immediately and when the IR stream has
completed transmission this event will be signalled by the driver. The last
parameters, labelled 'reservedx' are for future expansion and should be
NULL.


UUIRTDRV_API BOOL PASCAL UUIRTLearnIR(HUUHANDLE hHandle, int codeFormat,
char *IRCode, PLEARNCALLBACKPROC progressProc, void *userData, BOOL *pAbort,
unsigned int param1, void *reserved0, void *reserved1);

Instructs the USB-UIRT and the API to learn an IR code. The IR code learned
will be a complete IR stream suitable for subsequent transmission via
UUIRTTransmitIR. Consequently, the same formats supported by Transmit are
also available for learn. It is recommended to use either RAW or Pronto-RAW
codeFormat to offer the best compatibility; compressed-UIRT format is often
too limiting, although it does produce the smallest codes. IRCode will be
filled with the learned IR code upon return -- it is the responsibility of
the caller to allocate space for this string -- suggested string size is at
least 2048 bytes. ProgressProc is a caller-supplied callback function which
will be called periodically during the learn process and may be used to
update user dialogs, etc. Information passed to the callback are learn
progress %, signal quality, and carrier frequency. The parameter userData
will be passed by the USB-UIRT driver to any calls of progressProc. The
pAbort parameter should pass the pointer to a Boolean variable which should
be initialized to FALSE (0) prior to the call. Setting this variable TRUE
during the learn process will cause the UUIRTLearnIR process to abort and
the function to return. Since the UUIRTLearnIR function will block for the
duration of the learn process, one could set the *pAbort to TRUE either
within the callback function or from another thread. Param1 is currently
used only when the codeFormat includes the UUIRTDRV_IRFMT_LEARN_FORCEFREQ
flag (not normally needed) -- in which case param1 should indicate the
forced carrier frequency. The last parameters, labelled 'reservedx' are for
future expansion and should be NULL.


UUIRTDRV_API BOOL PASCAL UUIRTSetReceiveCallback(HUUHANDLE hHandle,
PUUCALLBACKPROC receiveProc, void *userData);

Registers a receive callback function which the driver will call when an IR
code is received from the air. receiveProc should contain the address of a
PUUCALLBACKPROC function defined as:

typedef void (WINAPI *PUUCALLBACKPROC) (char *IREventStr, void *userData);

When the USB-UIRT receives a code from the air, it will call the callback
function with a null-terminated, twelve-character (like IRMAN) ir code in
IREventStr. The driver will also pass the parameter userData, which is a
general-purpose 32-bit value supplied by the caller to
UUIRTSetReceiveCallback. This parameter is useful for carrying context
information, etc. Note that the types of codes which are passed to
IREventStr are *not* the same as the type of codes passed back from a
UUIRTLearnIR call (the codes from a UUIRTLearnIR are much larger and contain
all the necessary data to reproduce a code, whereas the codes passed to
IREventStr are simpler representations of IR codes only long enough to be
unique).

#define UUIRTDRV_IRFMT_UUIRT  0x0000  //  For UIRT-native STRUCT or RAW
#define UUIRTDRV_IRFMT_PRONTO 0x0010  //  For PRONTO

#define UUIRTDRV_IRFMT_LEARN_FORCERAW   0x0100
#define UUIRTDRV_IRFMT_LEARN_FORCESTRUC 0x0200
#define UUIRTDRV_IRFMT_LEARN_FORCEFREQ  0x0400
#define UUIRTDRV_IRFMT_LEARN_FREQDETECT 0x0800


Public Const INVALID_HANDLE_VALUE  = -1
Public Const ERROR_IO_PENDING      = 997
Public Const UUIRTDRV_ERR_NO_DEVICE= &H20000001
Public Const UUIRTDRV_ERR_NO_RESP  = &H20000002
Public Const UUIRTDRV_ERR_NO_DLL   = &H20000003
Public Const UUIRTDRV_ERR_VERSION  = &H20000004

Public Const UUIRTDRV_CFG_LEDRX    = &H1
Public Const UUIRTDRV_CFG_LEDTX    = &H2
Public Const UUIRTDRV_CFG_LEGACYRX = &H4

Public Const UUIRTDRV_IRFMT_TRANSMIT_DC = &H80
*/