;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  DllCall check routine
;;  Copyright (C) 2012 Adrian Hawryluk
;;
;;  This program is free software: you can redistribute it and/or modify
;;  it under the terms of the GNU General Public License as published by
;;  the Free Software Foundation, either version 3 of the License, or
;;  (at your option) any later version.
;;
;;  This program is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;  GNU General Public License for more details.
;;
;;  You should have received a copy of the GNU General Public License
;;  along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#include <Hex>

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DllCall check
;;                                          - by Adrian Hawryluk November 2012
;;                                             - Tested under AHK_L v1.1.08.01
;;
;;  This checks your DllCall to ensure that it is working as you expect.
;;  Yes, it takes a bit more typing, but this is a necessary evil at the moment
;;  but can possibly save you headaches down the line.
;;
;; Usage:
;;  Simple to use, just type:
;;
;;    _(DllCall(), errorCodeType)
;;
;;  where:
;;    DllCall() is your call as you currently use it now.
;;    errorCodeType is the type of the return value of the DllCall you invoked
;;
;;  Current errorCodeTypes available are _.BOOL, _.NON_ZERO, _.STATUS, _.ZERO
;;  _.HRESULT, and _.VOID.  You can extend the types as to how the codes are
;;  displayed by adding a member variable to the class _, like this:
;;
;;    _.TEST1 := [ "Error 1" ]
;;    _.TEST2 := { 2:"Error 2" }
;;
;;    _(1, _.TEST1) ; DLL result was (0x00000001) Error 1
;;    _(1, _.TEST2) ; DLL result was (0x00000001) *UNDEFINED*
;;    _(2, _.TEST2) ; DLL result was (0x00000001) Error 2
;;
;;  NOTE that when you use an extended type, 0 is always considered a successful
;;  outcome.
;;
;;  If you are expecting a particular value, you can specify it instead of
;;  the errorCodeType.  I.e.
;;
;;    _(1, 1) ; No error
;;    _(1, 2) ; DLL result was 0x00000001 and not 0x00000002
;;
;;  Further, the GetLastError() result is interrogated and the system message is
;;  also displayed.  Its error code is displayed in both hex and decimal 
;;  notation.
;;
;;  This library relys on hex to display the error codes as a hexadecimal 
;;  numbers.
;;
;; LOG
;;  Dec 1, 2012
;;  - Made it so that the script name and line number doen't need to be added
;;    to the call.  It is retreived through the system exception handling
;;    mechnisim.  The old style is still supported for compatibility.
;;  - Outputs to the OutputDebug prior to popping up the dialogue.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; _DllCall_Test()
;;
;;  Simple test of the results
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_DllCall_Test()
{
	; NOTE: I'm just passing a constant as the first parameter as a test.
	;       You would replace that constant with your DllCall().
	_(-1, _.HRESULT)

	_.TEST1 := [ "Error 1" ]
	_.TEST2 := { 2:"Error 2" }

	_(0, _.TEST1) ; No error
	_(1, _.TEST1) ; DLL result was (0x00000001) Error 1
	_(1, _.TEST2) ; DLL result was (0x00000001) *UNDEFINED*
	_(2, _.TEST2) ; DLL result was (0x00000001) Error 2

	_(1, 1) ; No error
	_(1, 2) ; DLL result was 0x00000001 and not 0x00000002
}
;_DllCall_Test()

; Stores constants and translation classes of error results
class _
{
	static NON_ZERO := { NON_ZERO:0 }
	, BOOL := _.NON_ZERO
	, ZERO := { ZERO:0 }
	, STATUS := _.ZERO
	, VOID := _._VOID()
	
	_VOID()
	{
		; initialises base class to report error if
		; try to get a member that doesn't exist.
		_.base := {__GET: _.__GET }
		return { VOID:1 }
	}

	class HRESULT
	{
		; this doesn't work
		; static base := { base: { __Get: HRESULT.__Get } }
		static base_ := _.HRESULT._init()
		_init()
		{
			this.base := { __GET: this.__GET }
	;    return { __GET: this.__GET }
		}
		
		__Get(element)
		{
			if element is not integer
				MsgBox % "HRESULT member must be a integer, value is '" element "'."
			else
			{
				static severityMsg := { 0: "SUCCESS", 1: "INFORMATIONAL", 2: "WARNING", 3: "ERROR" }
				severityCode := (element >> 30) & 3
				defined := ((element >> 29) & 1) ? "Customer" : "Microsoft"
				mappedNTStatus := (element >> 28) & 1
				reservedFacilityCode := (element >> 27) & 1
				facility := (element >> 16) & (2**11 - 1)
				code := element & (2**16 - 1)
				static facilityOrigin := { 0: "NULL",  1:"RPC (Remote Procedure Call)", 2:"Dispatch", 3:"Storage", 4:"ITF (COM/OLE Interface Managment)"
					, 7:"Win32", 8:"Windows", 9:"SSPI (Security)", 10:"Control", 11:"CERT", 12:"Internet", 13:"Media server", 14:"MSMQ (MS Message Queue)"
					, 15:"SetupAPI", 16:"SCARD (Smart-card subsystem)", 17:"COM+", 18:"AAF (MS agent)", 19:"URT (.NET CLR)"
					, 20:"ACS (Audit Control System)", 21:"DPLAY (Direct play)", 22:"UMI (Ubiquitous Memory Introspection service)", 23:"SXS (Side-by-side servicing)"
					, 24:"Windows CE", 25:"HTTP", 26:"Usermode commonlog", 31:"Usermode fileter manager", 32:"Background copy", 33:"Configuration"
					, 34:"State management", 35:"Metadirectory", 36:"Windows update", 37:"Directory service (Active directory)", 38:"Graphics", 39:"Shell"
					, 40:"TPM Services (Trusted Platform Module)", 41:"TPM Software (Trusted Platform Module)", 48:"PLA (Performance Logs and Alerts)"
					, 49:"FVE (Full Volume Encryption)", 50:"FWP (Firewall Platform)", 51:"WINRM (Windows Resource Manager)", 52:"NDIS (Network Driver Interface System)"
					, 53:"Usermode Hypervisor", 54:"CMI (Configuration Managment Infrastructure)", 55:"Usermode virtualization", 56:"Usermode volumen manager"
					, 57:"BCD (Boot Configuration Database", 58:"Usermode VHD (Virtual Hard disk Driver Support)", 60:"System Diagnonstics", 61:"Web Services"
					, 80:"Windows Defender", 81:"OPC (Open Connnectivity Service)"}
				return severityMsg[severityCode] ":"
					. "`n`tFrom: " defined 
					. "`n`tNT Status is: " mappedNTStatus
					. "`n`tReserved facility code: " reservedFacilityCode
					. "`n`tFacility origin: (" facility ") " facilityOrigin[facility]
					. "`n`tError code: " code
			}
		}
	}

	__GET(element)
	{
		if (ObjHasKey(this, element))
			return this[element]
		else
			MsgBox, % "Don't know what return type '" element "' is."
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; _(dllResult, scriptName, lineNumber, successIs)
;; _(dllResult, successIs)
;;
;; DllCall helper to report if there is any ErrorLevel result returned
;; or if the returned value is within expected values.
;;
;;    dllResult  - the result returned by the DllCall() fucntion
;;    scriptName - should be A_ScriptName (defaults to script's name
;;                 called from)
;;    lineNumber - should be A_LineNumber (defaults to script's line
;;                 called from)
;;    successIs  - indicates what a successful dllResult is supposed to
;;                 be.  This can be a specific value by surrounding
;;                 the value with [] (i.e. make it in to an array with
;;                 one element, equaling the value should be returned),
;;                 or can be one of the following constants:
;;
;;                   _.NON_ZERO - success is a non-zero result
;;                   _.BOOL     - success is a non-zero result
;;                   _.STATUS   - success is a 0 result, status
;;                                otherwise
;;                   _.HRESULT  - success is a 0 result, status
;;                                otherwise
;;                   _.ZERO     - success is a 0 result, status
;;                                otherwise
;;                   _.VOID     - no return result, just check
;;                                ErrorLevel
;;    Returns dllResult with no modification, even when using _.VOID.
;;
;; This function is to allow for some semi-automated error checking
;; when using the DllCall() function call, checking the returned value
;; by the function as well as the ErrorLevel status after the call.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_(dllResult, p1, p*)
{
	if (p.MaxIndex())
		successIs := p.2
	else
		successIs := p1
	
	if (ErrorLevel != 0)
	{
		if (substr(ErrorLevel, 1, 1) == "A")
		{
			offBy := substr(ErrorLevel, 2)
			if (offBy > 0)
				msg := "Too many agruments passed.  Expected " offBy 
						 . " arguments or DLL function requires a Cdecl as part of its return type."
			else
				msg := "Too few arguments passed.  Expected " (-offby) " arguments."
		}
		else if (ErrorLevel == -1)
			msg := "Called DllCall with a floating point number as it's [DllFile]\Function parameter."
		else if (ErrorLevel == -2)
			msg := "One of the types passed to DllCall is invalid."
		else if (ErrorLevel == -3)
			msg := "Could not access (find or have sufficiant permissions) the DllFile."
		else if (ErrorLevel == -4)
			msg := "Could not find the function in DLL."
		else if (ErrorLevel > 0)
			msg := "Recieved fatal expection error " hex(ErrorLevel, 8) "."
		else
			msg := "Unknown ErrorLevel " ErrorLevel " received by DllCall."
	}
	else if (IsObject(successIs))
	{
		if (ObjHasKey(successIs, "ZERO"))
		{
			if (dllResult != 0)
				msg := "DLL result was " hex(dllResult,8) " and not  0."
		}
		else if (ObjHasKey(successIs, "NON_ZERO"))
		{
			if (dllResult == 0)
				msg := "DLL result was 0 and should have been non-zero."
		}
		else if (! ObjHasKey(successIs, "VOID"))
		{
			if (dllResult != 0)
				msg := "DLL result was (" hex(dllResult,8) ") " (successIs[dllResult] != "" ? successIs[dllResult] : "*UNDEFINED*")
		}
	}
	else if (dllResult != successIs)
		msg := "DLL result was " hex(dllResult,8) " and not " hex(successIs,8) "."
	
	if (msg != "")
	{
		oEx := Exception("", -1)
		if (p.MaxIndex())
		{
			scriptName := p1
			, lineNumber := p.1
		}
		else
		{
			scriptName := oEx.file
			SplitPath scriptName, scriptName
			lineNumber := oEx.line
		}
		msg := "Error (" scriptName ":" lineNumber "): " msg "`n`nGetLastError msg is: " SystemErrorMsg(A_LastError) "`n`nFull name and path to script:`n   " oEx.file
		OutputDebug %msg%
		MsgBox %msg%
	}
	return dllResult
}

SystemErrorMsg(err)
{
	; from msdn 2000
	static FORMAT_MESSAGE_ALLOCATE_BUFFER := 0x00000100 
	, FORMAT_MESSAGE_FROM_SYSTEM := 0x00001000 
	, FORMAT_MESSAGE_IGNORE_INSERTS := 0x00000200 
	, LANG_NEUTRAL := 0
	, SUBLANG_DEFAULT := 1
	, NULL := 0
	VarSetCapacity(lpMsgBuf, 16)
	size := DllCall("FormatMessage"
		, "uint", FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS
		, "Ptr", NULL
		, "uint", err
		, "uint", MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT) ; Default language
		, "Ptr", &lpMsgBuf
		, "uint", 0
		, "Ptr", NULL
		, "Cdecl UInt")
	loop % size * (A_IsUnicode ? 2 : 1)
		result .= chr(NumGet(NumGet(lpMsgBuf), A_Index-1, "uchar"))
	result := "(" hex(err,8) " / " err ") " trim(result, " `t`n`r")
	;// Free the buffer.
	if (0 != DllCall("LocalFree", "Ptr",lpMsgBuf, "Ptr"))
		MsgBox Error freeing memory.
	return result
}

MAKELANGID(p, s)
{
	return (s << 10) | (p)
}
