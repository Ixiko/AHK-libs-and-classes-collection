; ----------------------------------------------------------------------------------------------------------------------
; Name .........: WinEvents library
; Description ..: Minimal Windows Events API implementation. It can be used to attach events to the Windows Events Logs.
; AHK Version ..: AHK_L 1.1.13.01 x32/64 Unicode
; Author .......: Cyruz (http://ciroprincipe.info)
; License ......: WTFPL - http://www.wtfpl.net/txt/copying/
; Changelog ....: Sep. 30, 2012 - v0.1 - First revision.
; ..............: Oct. 06, 2012 - v0.2 - Fixed some wrong behaviours.
; ..............: Jan. 09, 2014 - v0.3 - Unicode and x64 version. Now it uses arrays instead of continuation sections.
; ----------------------------------------------------------------------------------------------------------------------

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: WinEvents_RegisterForEvents
; Description ..: Registers the application to send Windows log events.
; Parameters ...: sLogName - Can be "Application", "System" or a custom event log name.
; Return .......: Handle to the registered source on success, NULL on failure.
; ----------------------------------------------------------------------------------------------------------------------
WinEvents_RegisterForEvents(sLogName) {
    Return DllCall( "Advapi32.dll\RegisterEventSource", Ptr,0, Str,sLogName )
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: WinEvents_DeregisterForEvents
; Description ..: Deregisters the previously registered application.
; Parameters ...: hSource    - Handle to a previously registered events source with RegisterForEvents.
; Return .......: Nonzero if the function succeeds or zero if it fails.
; ----------------------------------------------------------------------------------------------------------------------
WinEvents_DeregisterForEvents(hSource) {
    Return DllCall( "Advapi32.dll\DeregisterEventSource", Ptr,hSource )
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: WinEvents_SendWinLogEvent
; Description ..: Writes an entry at the end of the specified Windows event log.
; Parameters ...: hSource    - Handle to a previously registered events source with RegisterForEvents.
; ..............: evType     - Can be: EVENTLOG_SUCCESS
; ..............:                      EVENTLOG_AUDIT_FAILURE
; ..............:                      EVENTLOG_AUDIT_SUCCESS
; ..............:                      EVENTLOG_ERROR_TYPE
; ..............:                      EVENTLOG_INFORMATION_TYPE
; ..............:                      EVENTLOG_WARNING_TYPE
; ..............: evId       - Event ID, can be any dword value.
; ..............: evCat      - Any value, used to organize events in categories.
; ..............: arrStrings - A simple array of strings (each max 31839 chars).
; ..............: pData      - A buffer containing the binary data.
; Return .......: Nonzero if the function succeeds or zero if it fails.
; ----------------------------------------------------------------------------------------------------------------------
WinEvents_SendWinLogEvent(hSource, evType, evId, evCat:=0, ByRef arrStrings:=0, ByRef pData:=0) {
    Static EVENTLOG_SUCCESS    := 0x0000, EVENTLOG_AUDIT_FAILURE    := 0x0010, EVENTLOG_AUDIT_SUCCESS := 0x0008
         , EVENTLOG_ERROR_TYPE := 0x0001, EVENTLOG_INFORMATION_TYPE := 0x0004, EVENTLOG_WARNING_TYPE  := 0x0002
    
    If ( !%evType% )
        Return 0
    
    nLen := arrStrings.MaxIndex()
    VarSetCapacity(arrFinal, nLen*A_PtrSize)
    Loop %nLen% ; Fills the array of strings
        NumPut(arrStrings.GetAddress(A_Index), arrFinal, (A_Index-1)*A_PtrSize, "Ptr")
        
    Return DllCall( "Advapi32.dll\ReportEvent", UInt,hSource, UShort,%evType%, UShort,evCat, UInt,evId, Ptr,0
                                              , UShort,nLen, UInt,szData:=VarSetCapacity(pData), Ptr,(nLen)?&arrFinal:0
                                              , Ptr,(szData)?&pData:0 )
}

/* EXAMPLE CODE:
; Register the application for sending events.
hSource := WinEvents_RegisterForEvents("Application")

; Send a simple INFORMATION_TYPE Event with ID 0x0123 to the Application log. 
WinEvents_SendWinLogEvent(hSource, "EVENTLOG_INFORMATION_TYPE", 0x0123)

; Array of strings.
arrStr := [ "This is the first test string."
          , "Yay, this is the second test string."
          , "This is the third and final test string." ]


; Some hex data (a simple icon).
inDataHex = 
( Join
000001000100101010000100040028010000160000002800000010000000200000000100040000000000C00000
0000000000000000000000000000000000C6080800CE101000CE181800D6212100D6292900E13F3F00E7525200
EF5A5A00EF636300F76B6B00F7737300FF7B7B00FFC6C600FFCEC600FFDEDE00FFFFFF00CCCCCCCCCCCCCCCCC0
0000000000000CC11111111111111CC22222CFFE22222CC33333CFFE33333CC44444CFFE44444CC55555CFFE55
555CC55555CFFE55555CC55555CFFE55555CC66666CFFE66666CC77777777777777CC88888CFFC88888CC99999
CFFC99999CCAAAAAAAAAAAAAACCBBBBBBBBBBBBBBCCCCCCCCCCCCCCCCC00000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000
)

; -- MCode by Laszlo.
VarSetCapacity(inData, StrLen(inDataHex)//2)
Loop % StrLen(inDataHex)//2
    NumPut("0x" . SubStr(inDataHex, 2*A_Index-1, 2), inData, A_Index-1, "UChar")
; --

; Send a SUCCESS Event with ID 0x0001, arrStr as string and inData as binary data, to the Application log.
WinEvents_SendWinLogEvent(hSource, "EVENTLOG_WARNING_TYPE", 0x0001, 0, arrStr, inData)

; Deregister the application.
WinEvents_DeregisterForEvents(hSource)