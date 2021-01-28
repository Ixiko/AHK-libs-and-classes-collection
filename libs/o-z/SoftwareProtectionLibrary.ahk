#NoEnv

SWP_Initialize( 0x18389024, 0x43729190 )
SWP_CheckRegistration( "ProgramX.Y.Z.", "agent@gg.com" )     
Gosub RunMyApp
Return

;-------------------------------------------------------------------------------
;
; Software Protection Library - GUI Implementation 0.11
;
; This library contains a simple set of GUI functions to allow easy 
; implementation of a software protection, using a registration code and a 
; computer fingerprint.
; 
; Requires: SWProtect-Internal.ahk
; 
; Original Code:        Laszlo Hars <www.Hars.US>
; Library/GUI Version:  Icarus
;
; AutoHotkey Forum Thread:
; http://www.autohotkey.com/forum/viewtopic.php?t=5763&postdays=0&postorder=asc&start=0
;
; USAGE 1:
;   1. Include this file in your script
;   2. In your loading sequence, call SWP_Initialize() then
;      SWP_CheckRegistration( "AppName", "DeveloperEmail" )
;      to check/ask for a valid registration.
;
; USAGE 2:
;   1. Include this file in a new script
;   2. Call SWP_Initialize() then SWP_ShowKeyGen() to activate a KeyGen dialog
;
; TODO:
;   - See if there is a way to use less global variables
;   - See if there is a way to avoid using a fixed GUI ID (currently, 20) and
;     instead pass it as an optional parameter. The reason why this is not 
;     implemented like this is because we need to have 20GuiEscape: labels
;
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;
; Software Protection Library 0.11
;
; This library contains a set of functions to generate a registration key
; based on a user fingerprint.
; To be used separately or together with the GUI library - SWProtect-GUI.ahk
; 
; Original Code:    Laszlo Hars <www.Hars.US>
; Library Version:  Icarus
;
; Original proof of concept by Laszlo, taken from AutoHotkey Forum at
; http://www.autohotkey.com/forum/viewtopic.php?t=5763&postdays=0&postorder=asc&start=0
;
;
; Functions in this version
; 
;   SWP_Initialize( [ secret1, secret 2, ... , secret 8 ] )
;   Fingerprint := SWP_GetPcFingerprint()
;   UserOK      := SWP_IsUserAuthenticated( username, email, key )
;   Key         := SWP_GenerateKey( username, email, fingerprint )
;
;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------
; TESTER - Comment or delete this tester when including the file
;

/*

; Initialize the required globals
;----------------------------------------
SWP_Initialize()        ; May be called with up to 8 secret keys


; Get a hardware fingerprint
;----------------------------------------
Fingerprint := SWP_GetPcFingerprint()
MsgBox 32,,Your computer ID is`n%Fingerprint%


; Generate a license key for this user
;----------------------------------------
Username    := "Icarus"
Email       := "Icarus@Sky.com"
Key         := SWP_GenerateKey( Username, Email, Fingerprint )
MsgBox 32,,Your registration details are:`nUser:`t%Username%`nEmail:`t%Email%`nKey:`t%Key%


; Check if a user's registration code is ok
;----------------------------------------
;Key := "some invalid key by the user"                      ; Uncomment to test
UserOK      := SWP_IsUserAuthenticated( Username, Email, Key )
If( UserOK )
    MsgBox 32,OK,User is authenticated
Else
    MsgBox 16,INVALID,User is NOT authenticated`n%Username%`n%Email%`n%Key%
    
    
Return


*/

;
; END OF TESTER
;-------------------------------------------------------------------------------




;-------------------------------------------------------------------------------
; API Functions
;-------------------------------------------------------------------------------
;  
; SWP_Initialize( [ secret1, secret 2, ... , secret 8 ] )
; Fingerprint := SWP_GetPcFingerprint()
; UserOK      := SWP_IsUserAuthenticated( username, email, key )
; Key         := SWP_GenerateKey( username, email, fingerprint )
;
;-------------------------------------------------------------------------------
SWP_Initialize( mk0=0x11111111, mk1=0x22222222, mk2=0x33333333, mk3=0x44444444
    ,ml0=0x12345678, ml1=0x12345678, mm0=0x87654321, mm1=0x87654321 ) {
    
    Global

    k0 := mk0                  ; 128-bit secret key (example)
    k1 := mk1
    k2 := mk2
    k3 := mk3
    
    l0 := ml0                  ; 64- bit 2nd secret key (example)
    l1 := ml1
    
    m0 := mm0                  ; 64- bit 3rd secret key (example)
    m1 := mm1

}


SWP_GetPcFingerprint() {
    PCdata = %COMPUTERNAME%%HOMEPATH%%USERNAME%%PROCESSOR_ARCHITECTURE%%PROCESSOR_IDENTIFIER%
    PCdata = %PCdata%%PROCESSOR_LEVEL%%PROCESSOR_REVISION%%A_OSType%%A_OSVersion%%Language%

    Fingerprint := XCBC(Hex(PCdata,StrLen(PCdata)), 0,0, 0,0,0,0, 1,1, 2,2)
    Return Fingerprint
}

SWP_GenerateKey( username, email, fingerprint ) {
    Global k0,k1,k2,k3,l0,l1,m0,m1
    
    If( not k0 ) {
        MsgBox 16,Error,Error in SWP_GenerateKey - values are not initialized.`nPlease call SWP_Initialize() first.
        Return false
    }
        
    Together = %username%%email%%fingerprint%
    Auth := XCBC(Hex(Together,StrLen(Together)), 0,0, k0,k1,k2,k3, l0,l1, m0,m1)
    Return Auth
}


SWP_IsUserAuthenticated( username, email, key ) {
    Global k0,k1,k2,k3,l0,l1,m0,m1
    
    If( not k0 ) {
        MsgBox 16,Error,Error in SWP_IsUserAuthenticated - values are not initialized.`nPlease call SWP_Initialize() first.
        Return false
    }

    Fingerprint := SWP_GetPcFingerprint()
    Together = %username%%email%%Fingerprint%

    AuthData := XCBC(Hex(Together,StrLen(Together)), 0,0, k0,k1,k2,k3, l0,l1, m0,m1)
    
    Return Key=AuthData
}




;-------------------------------------------------------------------------------
; Internal Functions by Laszlo
;-------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; TEA cipher ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Block encryption with the TEA cipher
; [y,z] = 64-bit I/0 block
; [k0,k1,k2,k3] = 128-bit key
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TEA(ByRef y,ByRef z, k0,k1,k2,k3)
{                                   ; need  SetFormat Integer, D
   s = 0
   d = 0x9E3779B9
   Loop 32                          ; could be reduced to 8 for speed
   {
      k := "k" . s & 3              ; indexing the key
      y := 0xFFFFFFFF & (y + ((z << 4 ^ z >> 5) + z  ^  s + %k%))
      s := 0xFFFFFFFF & (s + d)  ; simulate 32 bit operations
      k := "k" . s >> 11 & 3
      z := 0xFFFFFFFF & (z + ((y << 4 ^ y >> 5) + y  ^  s + %k%))
   }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; XCBC-MAC ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; x  = long hex string input
; [u,v] = 64-bit initial value (0,0)
; [k0,k1,k2,k3] = 128-bit key
; [l0,l1] = 64-bit key for not padded last block
; [m0,m1] = 64-bit key for padded last block
; Return 16 hex digits (64 bits) digest
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

XCBC(x, u,v, k0,k1,k2,k3, l0,l1, m0,m1)
{
   Loop % Ceil(StrLen(x)/16)-1   ; full length intermediate message blocks
      XCBCstep(u, v, x, k0,k1,k2,k3)

   If (StrLen(x) = 16)              ; full length last message block
   {
      u := u ^ l0                   ; l-key modifies last state
      v := v ^ l1
      XCBCstep(u, v, x, k0,k1,k2,k3)
   }
   Else {                           ; padded last message block
      u := u ^ m0                   ; m-key modifies last state
      v := v ^ m1
      x = %x%100000000000000
      XCBCstep(u, v, x, k0,k1,k2,k3)
   }
   Return Hex8(u) . Hex8(v)         ; 16 hex digits returned
}

XCBCstep(ByRef u, ByRef v, ByRef x, k0,k1,k2,k3)
{
   StringLeft  p, x, 8              ; Msg blocks
   StringMid   q, x, 9, 8
   StringTrimLeft x, x, 16
   p = 0x%p%
   q = 0x%q%
   u := u ^ p
   v := v ^ q
   TEA(u,v,k0,k1,k2,k3)
}

Hex8(i)                             ; 32-bit integer -> 8 hex digits
{
   format = %A_FormatInteger%       ; save original integer format
   SetFormat Integer, Hex
   i += 0x100000000                 ; convert to hex, set MS bit
   StringTrimLeft i, i, 3           ; remove leading 0x1
   SetFormat Integer, %format%      ; restore original format
   Return i
}

Hex(ByRef b, n=0)                   ; n bytes data -> stream of 2-digit hex
{                                   ; n = 0: all (SetCapacity can be larger than used!)
   format = %A_FormatInteger%       ; save original integer format
   SetFormat Integer, Hex           ; for converting bytes to hex

   m := VarSetCapacity(b)
   If (n < 1 or n > m)
       n := m
   Loop %n%
   {
      x := 256 + *(&b+A_Index-1)    ; get byte in hex, set 17th bit
      StringTrimLeft x, x, 3        ; remove 0x1
      h = %h%%x%
   }
   SetFormat Integer, %format%      ; restore original format
   Return h
}


;-------------------------------------------------------------------------------
; Revision History
;-------------------------------------------------------------------------------
/*

    0.11  2007 09 04
        - Fixed  : IsUserAuthenticated returned -1 in case of an uninitialized
                   globals, now returning false.
        
    0.10  2007 09 03
        - First version



*/

;-------------------------------------------------------------------------------
; TESTER - Comment or delete this tester when including the file
;
/*

#SingleInstance Force
SetWorkingDir %A_ScriptDir%

; USAGE 1: Add this in a separate file, to have your own keygen
;-------------------------
;SWP_Initialize( 0x81645732, 0x19573549 )   ; Up to 8 secret keys, 
;SWP_ShowKeyGen()
;Return
;-------------------------


; USAGE 2: Add this in your loading sequence to check/ask for a valid registration
;-------------------------
SWP_Initialize( 0x81645732, 0x19573549 )    ; Up to 8 secret keys, 
SWP_CheckRegistration( "My Application", "software@developer.com" )     
;-------------------------



Msgbox The program continues here`n`n`n`n`n`n`n`n
Return

*/
;
; END OF TESTER
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; Main GUI Function
;-------------------------------------------------------------------------------

SWP_CheckRegistration( appName, developerEmail, iniFilename="Reg.ini" ) {
;
; Checks for the existence of a valid registration file.
; If registration is valid, it will return the control to the caller, otherwise
; it will show a registration GUI (with an option to the user to ask for a 
; registration key) and will only resume normal operation if a valid 
; registration code is entered.
;
; When a valid key is entered, the registration details will be saved in an INI
; file (default: Reg.ini) so that next time this function is called, it will be
; able to find the registration code on its own.
;
;-------------------------------------------------------------------------------
    Global SWP_AppName, SWP_IniFilename, SWP_DeveloperEmail, SWP_LicenseOK
    
    SWP_AppName        := appName
    SWP_IniFilename    := iniFilename
    SWP_DeveloperEmail := developerEmail
    SWP_LicenseOK      := false
    
    If( Not FileExist( iniFilename ) ) {
        SWP_ShowRegisterDialog( appName )
        Loop 
            If( SWP_LicenseOK )     ; Loop will be broken by a valid license
                Break

    }
    Else {                          ; File exists, read registration data and validate
        SWP_ReadRegFile( iniFilename )
        Sleep 1000      ; This is here since the Reload in SWP_ReadRegFile
                        ; seem to still give the application to continue running
                        ; before it actually reloads.
                        ; Deleteing this launches the "The program continues"
                        ; msgbox
                        ; *** TODO: Can be fixed?

    }

}

SWP_ShowKeyGen() {
;
; This function shows a simple generator for registration numbers.
; Once the user has sent you his Computer ID, use this function to generate
; a valid registration key for this user+computer.
;
; The proper use of this function, is to create a separate ahk code, including
; this library, then calling this function.
;
; Note that you need to call SWP_Initialize with the same seed keys as in your
; SWP_CheckRegistration function BEFORE you call this function.
;
;-------------------------------------------------------------------------------
    Global SwpGuiVal_Name, SwpGuiVal_Email, SwpGuiVal_Key, SwpGuiVal_Fingerprint
        ,SWP_GuiID
    
    SWP_GuiID := 20
    GuiID := SWP_GuiID
    
    Gui %GuiID%:Margin, 10, 10

    ; Top introduction text
    Gui %GuiID%:Font, s10 bold
    Gui %GuiID%:Add, Text, x10 y10 w352 h22 center, Please enter user details:
    Gui %GuiID%:Font, s10 norm

    ; Text labels
    Gui %GuiID%:Add, Text, xp y+15 w135 h22 right section, % "Name/Company: "
    Gui %GuiID%:Add, Text, xp y+2  wp   hp  right        , % "Email Address: "
    Gui %GuiID%:Add, Text, xp Y+2  wp   hp  right        , % "Computer ID: "
    Gui %GuiID%:Add, Text, xp Y+2  wp   hp  right        , % "Key: "
    
    ; Edit fields
    Gui %GuiID%:Add, Edit, xs+137 ys  wp+64 hp vSwpGuiVal_Name
    Gui %GuiID%:Add, Edit, xp     y+2 wp    hp vSwpGuiVal_Email
    Gui %GuiID%:Add, Edit, xp     y+2 wp    hp vSwpGuiVal_Fingerprint
    Gui %GuiID%:Font, s10 bold
    Gui %GuiID%:Add, Edit, xp     y+2 wp    hp readonly center vSwpGuiVal_Key
    Gui %GuiID%:Font, s10 norm
    Gui %GuiID%:Add, Groupbox, xs ys-20 w352 h126
    
    ; Buttons
    Gui %GuiID%:Add, Button, xs  y+10 w109   h24 gSWP_RegisterDialogCancel  , E&xit
    Gui %GuiID%:Font, s10 bold
    Gui %GuiID%:Add, Button, x+2    yp   wp+20 hp  default gSWP_KeygenGenerate  , &Generate
    Gui %GuiID%:Font, s10 norm
    Gui %GuiID%:Add, Button, x+2    yp   wp-20 h24 gSWP_KeygenOk, &Copy && Exit  
    
    Gui %GuiID%:Show, w372, Registration Key Generator
}

;-------------------------------------------------------------------------------
; Other GUI Functions (you should generally avoid calling these functions)
;-------------------------------------------------------------------------------

SWP_ShowRegisterDialog( appName ) {
    Global SWP_GuiID        ; *** TODO: See if there is a way to have a dynamically 
                            ; created 20GuiEscape labels, so we can pass GuiID as
                            ; an optional parameter to the function

    Global SWP_AppName, SwpGuiVal_Name, SwpGuiVal_Email, SwpGuiVal_Key
    
    SWP_GuiID := 20
    GuiID := SWP_GuiID
    
    Gui %GuiID%:Margin, 10, 10

    ; Top introduction text
    Gui %GuiID%:Font, s10 bold
    Gui %GuiID%:Add, Text, x10 y10 w352 h22 center, %appName% is not registered.
    Gui %GuiID%:Font, s10 norm
    Gui %GuiID%:Add, Text, xp y+0 wp hp center, Please enter your registration details:

    ; Text labels
    Gui %GuiID%:Add, Text, xp y+15 w135 h22 right section, % "Name/Company: "
    Gui %GuiID%:Add, Text, xp y+2  wp   hp  right        , % "Email Address: "
    Gui %GuiID%:Add, Text, xp Y+2  wp   hp  right        , % "Registration Code: "
    
    ; Edit fields
    Gui %GuiID%:Add, Edit, xs+137 ys  wp+64 hp vSwpGuiVal_Name
    Gui %GuiID%:Add, Edit, xp     y+2 wp    hp vSwpGuiVal_Email
    Gui %GuiID%:Add, Edit, xp     y+2 wp    hp vSwpGuiVal_Key
    Gui %GuiID%:Add, Groupbox, xs ys-20 w352 h102
    
    ; Buttons
    Gui %GuiID%:Add, Button, xs  y+10 w168 h24 gSWP_RegisterDialogGetKey    , &Get a Registration Key
    Gui %GuiID%:Add, Button, x+2 yp   w90  h24 gSWP_RegisterDialogCancel    , E&xit
    Gui %GuiID%:Font, s10 bold
    Gui %GuiID%:Add, Button, x+2 yp   w90  h24 default gSWP_RegisterDialogOk, Register
    
    Gui %GuiID%:Show, w372, %appName% Registration
}

20GuiEscape:
20GuiClose:
SWP_RegisterDialogCancel:
    ExitApp 
Return

SWP_RegisterDialogOk:
    Gui %SWP_GuiID%:Submit, NoHide
    If( SwpGuiVal_Name = "" or SwpGuiVal_Email = "" or SwpGuiVal_Key = "" ) 
        MsgBox 16,Invalid Registration, Invalid Registration.`nPlease check your input.`t
    Else If( Not SWP_IsUserAuthenticated( SwpGuiVal_Name, SwpGuiVal_Email, SwpGuiVal_Key ) ) {
        MsgBox 16,Invalid Registration, Invalid Registration.`nPlease check your input.`t
    }
    Else {
        ; Registration ok, write to ini file and exit happily
        IniWrite %SwpGuiVal_Name%, %SWP_IniFilename%, Registration, Name
        IniWrite %SwpGuiVal_Email%, %SWP_IniFilename%, Registration, Email
        IniWrite %SwpGuiVal_Key%, %SWP_IniFilename%, Registration, Key
        MsgBox 64,Registration Accepted, Your registration was accepted and saved.`t`nThank you for using %SWP_AppName%.
        SWP_LicenseOK := true
        Gui %SWP_GuiID%:Destroy
    }   
Return

SWP_RegisterDialogGetKey:
    SWP_ShowGetKeyDialog()
Return

SWP_ShowGetKeyDialog() {
    Global SWP_GuiID, SWP_AppName, SwpGuiVal_Fingerprint, SwpGuiButton_Ok
        ,SWP_DeveloperEmail

    ; Destroy
    Gui %SWP_GuiID%:Destroy
    
    ; Then rebuild
    SwpGuiVal_Fingerprint := SWP_GetPcFingerprint()
    
    GuiID := SWP_GuiID
    Gui %GuiID%:Margin, 10, 10

    ; Middle box
    Gui %GuiID%:Font, s10 norm
    Gui %GuiID%:Add, Text, x20   y20  w332  h44 center section, Please send us this Computer ID together with your name and email address.
    Gui %GuiID%:Font, s12 bold
    Gui %GuiID%:Add, Edit, xp+10 y+2  wp-20 h24 r1 ReadOnly center vSwpGuiVal_Fingerprint, %SwpGuiVal_Fingerprint%
    Gui %GuiID%:Font, s10 bold
    Gui %GuiID%:Add, Text, xp    y+2  wp    h24 center, Send to %SWP_DeveloperEmail%
    Gui %GuiID%:Font, s10 norm
    Gui %GuiID%:Add, Groupbox, xs-10 ys-15 w352 h128
    
    ; Buttons
    Gui %GuiID%:Add, Button, xs-10  y+10 w90 h24 gSWP_RegisterDialogCancel  , E&xit
    Gui %GuiID%:Font, s10 bold
    Gui %GuiID%:Add, Button, x+2 yp w259  h24 default vSwpGuiButton_Ok gSWP_GetDialogOk, Copy to Clipboard && Exit  
    
    GuiControl %GuiID%:Focus, SwpGuiButton_Ok       ; To avoide the selection of the fingerprint
    
    Gui %GuiID%:Show, w372, %SWP_AppName% Registration
}

SWP_GetDialogOk:
    Gui %SWP_GuiID%:Submit
    Clipboard := "Computer ID: " SwpGuiVal_Fingerprint
    MsgBox 64,Copied to Clipboard, Your Computer ID was copied to the clipboard.`nPlease send it along with your name and email address to`t`n%SWP_DeveloperEmail%.
    ExitApp
Return


SWP_ReadRegFile( iniFilename ) {
    Global SWP_LicenseOK
    IniRead Name, %iniFilename%, Registration, Name
    IniRead Email, %iniFilename%, Registration, Email
    IniRead Key, %iniFilename%, Registration, Key
    SWP_LicenseOK := false
    If( Not SWP_IsUserAuthenticated( Name, Email, Key ) ) {
        MsgBox 16,Invalid Registration, Your registration details seem to be invalid.`t`n
        FileDelete %iniFilename%
        Reload
    }
    SWP_LicenseOK := true
}

SWP_KeygenGenerate:
    Gui %SWP_GuiID%:Submit, NoHide
    SwpGuiVal_Key := SWP_GenerateKey( SwpGuiVal_Name, SwpGuiVal_Email, SwpGuiVal_Fingerprint )
    GuiControl ,%SWP_GuiID%:,SwpGuiVal_Key,%SwpGuiVal_Key%
Return

SWP_KeygenOK:
    Gui %SWP_GuiID%:Submit, NoHide
    Clipboard = 
        ( LTRIM
            -----------------------------------
            Username: %SwpGuiVal_Name%
            Email:    %SwpGuiVal_Email%
            Key:      %SwpGuiVal_Key%
            -----------------------------------
        )
    Gui %SWP_GuiID%:Destroy

Return

RunMyApp:
MsgBox, Hi
return
;-------------------------------------------------------------------------------
; Revision History
;-------------------------------------------------------------------------------
/*

    0.11  2007 09 04
        - Added  : Keygen
        - Changed: Initialize function (secret seeds) now needs to be called
          separately prior to calling any of the other main GUI functions.
          This is done to allow different key generation for every software
          you develop.
          If this is not a requirement, the Initialize function can be put
          back into the two main GUI functions (only make sure you are using
          the same seeds)
        
    0.10  2007 09 03
        - First version



*/