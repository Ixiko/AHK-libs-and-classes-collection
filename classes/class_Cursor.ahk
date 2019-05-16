;==============================================================================
; FILE:     CursorClass.ahk
; CLASSES:  CCursor
;           CWaitCursor
;           CAppStartingCursor
;           CHiddenCursor
;==============================================================================


;==============================================================================
; CLASS:    CCursor
; DESC:     Changes the mouse cursor's appearance, or hides it completely.
;
;           This class fully supports animated cursors.  Their motion will display
;           properly rather than just show a single frozen image.  It also 
;           automatically restores the mouse cursor when the script exits.
;
;           IMPORTANT - Only standard system cursors are affected!  If an
;           application is displaying its own custom cursor image, the mouse 
;           cursor will not change appearance until it is moved over an area 
;           that uses a standard cursor.
;
; AUTHOR:   Dan Updegraff (UppyDan @ autohotkey.com).
;
; PUBLIC METHODS:
;   set()
;   restore()
;   appStarting()
;   arrow()
;   cross()
;   hand()
;   help()
;   hide()
;   ibeam()
;   no()
;   size()
;   sizeNESW()
;   sizeNS()
;   sizeNWSE()
;   sizeWE()
;   upArrow()
;   wait()
;   handle()
;
; PRIVATE METHODS: (for internal use)
;   _cleanup()
;   _ErrorLevelBool()
;   _setExitHandler()
;
; EXAMPLE 1: (Uses CCursor as a static class object.)
;
;    if not CCursor.set("IDC_WAIT")  ; Same as calling CCursor.wait() .
;        MsgBox % "ERROR - " ErrorLevel  ; <-- Demonstrates error handling.
;    Sleep 2000
;    CCursor.set("IDC_APPSTARTING")  ; Same as calling CCursor.appStarting() .
;    Sleep 2000
;    CCursor.hide()
;    Sleep 2000
;    CCursor.set("C:\Windows\Cursors\horse.ani")
;    Sleep 2000
;    CCursor.restore()
;   
; EXAMPLE 2: (News up a CCursor object to change the mouse cursor until the object is destroyed.)
;            (See also CWaitCursor below.)
;
;    someFunction()
;    {
;        waitCursor := new CCursor("IDC_WAIT")
;
;        ... Do some long task here ...
;
;    } ; The mouse cursor is automatically restored when 'waitCursor' goes out of scope.
;
class CCursor
{
    ;***************
    ;  Static Vars 
    ;***************
    static _AndMask := "", _XorMask := "", _MaskSize := 32
        , _Width := "", _Height := ""_ExitHandler := false, _CurrentCursor := ""
        , _SystemCursors := { "IDC_ARROW": 32512, "IDC_IBEAM": 32513, "IDC_WAIT": 32514
                , "IDC_CROSS": 32515, "IDC_UPARROW": 32516, "IDC_SIZENWSE": 32642
                , "IDC_SIZENESW": 32643, "IDC_SIZEWE": 32644, "IDC_SIZENS": 32645
                , "IDC_SIZEALL": 32646, "IDC_NO": 32648, "IDC_HAND": 32649
                , "IDC_APPSTARTING": 32650, "IDC_HELP": 32651 }

    ;******************************
    ;  Constructor and Destructor
    ;******************************
    __New(newCursor, restorationDelay := 0)
    {
        ObjInsert(this, "restorationDelay", restorationDelay)
        if newCursor
            CCursor.set(newCursor)
    }
    
    __Delete() 
    {
        CCursor.restore(this.restorationDelay)
    }

    ;******************
    ;  Public Methods 
    ;******************

    ;--------------------------------------------------------------------------
    ; The following methods change the mouse to a standard system cursor.
    ; Refer to set() for more details.
    arrow() {
        CCursor.set("IDC_ARROW")
    }
    ibeam() {
        CCursor.set("IDC_IBEAM")
    }
    wait() {
        CCursor.set("IDC_WAIT")
    }
    cross() {
        CCursor.set("IDC_CROSS")
    }
    upArrow() {
        CCursor.set("IDC_UPARROW")
    }
    sizeNWSE() {
        CCursor.set("IDC_SIZENWSE")
    }
    sizeNESW() {
        CCursor.set("IDC_SIZENESW")
    }
    sizeWE() {
        CCursor.set("IDC_SIZEWE")
    }
    sizeNS() {
        CCursor.set("IDC_SIZENS")
    }
    size() {
        CCursor.set("IDC_SIZEALL")
    }
    no() {
        CCursor.set("IDC_NO")
    }
    hand() {
        CCursor.set("IDC_HAND")
    }
    appStarting() {
        CCursor.set("IDC_APPSTARTING")
    }
    help() {
        CCursor.set("IDC_HELP")
    }

    ;--------------------------------------------------------------------------
    ; Method:           hide
    ; Description:      Hides the cursor.  Call restore() to show it again.
    ; Parameters:
    ;   None.
    ;
    ; Returns true if successful, false otherwise and 'ErrorLevel' will contain a displayable error message.
    ;
    hide() 
    {
        global gCursor_AndMask, gCursor_XorMask
        
        if (CCursor._CurrentCursor = "HIDDEN")
            return  ; Nothing to do.
        
        CCursor._setExitHandler()
        VarSetCapacity(gCursor_AndMask, CCursor._MaskSize*4, 0xFF)
        VarSetCapacity(gCursor_XorMask, CCursor._MaskSize*4, 0x00) 

        for each, systemCursorID in CCursor._SystemCursors
        {
            hBlankImage := DllCall("CreateCursor", "ptr",0, "int",0, "int",0
                                    , "int",CCursor._MaskSize, "int",CCursor._MaskSize
                                    , "ptr",&gCursor_AndMask, "ptr",&gCursor_XorMask)
            DllCall("SetSystemCursor", "ptr",hBlankImage, "uint",systemCursorID)
        }
        
        CCursor._CurrentCursor := "HIDDEN"
        return CCursor._ErrorLevelBool()
    }
    
    ;--------------------------------------------------------------------------
    ; Method:           restore
    ; Description:      Restores the mouse cursor to its normal behavior.
    ; Parameters:
    ;   delayMillisecs  - The number of milliseconds to delay the restoration of the
    ;                     cursor after this function is called.  Passing in 0 restores 
    ;                     the cursor immediately.
    ;                     If another method in this class is called to change the cursor 
    ;                     during this delay period, the cursor will not be restored.
    ;
    ; Returns true if successful, false otherwise and 'ErrorLevel' will contain a displayable error message.
    ;
    restore(delayMillisecs := 0)
    {
        if (delayMillisecs > 0)
        {
            SetTimer CCursor_Timer, -%delayMillisecs%
            return true
        }
        
        SetTimer CCursor_Timer, Off
        DllCall("SystemParametersInfo", "uint",0x57, "uint",0, "ptr",0, "uint",0) ; SPI_SETCURSORS
        CCursor._CurrentCursor := ""
        return CCursor._ErrorLevelBool()
    }
    
    ;--------------------------------------------------------------------------
    ; Method:           set
    ; Description:      Changes the mouse cursor's appearance given a cursor name,
    ;                   or a .CUR or .ANI file name.  
    ;
    ;                   To restore the cursor to normal, call restore().
    ;                   Note: Passing in "IDC_ARROW" does NOT restore the cursor to
    ;                         normal!  It forces the cursor to remain an arrow shape
    ;                         regardless of where the mouse is.  (i.e. You won't get
    ;                         an I-beam cursor when over text.)
    ; Parameters:
    ;   cursor          - Specifies the mouse cursor's new appearance.
    ;                       To change the cursor to a .CUR or .ANI file, set this parameter 
    ;                       to the file's full path and name.
    ;
    ;                       To change the cursor to one of the standard system cursors, set 
    ;                       this parameter to one of the following:
    ;
    ;                           "IDC_ARROW"     "IDC_IBEAM"   "IDC_WAIT"         "IDC_CROSS" 
    ;                           "IDC_UPARROW"   "IDC_SIZE     "IDC_ICON"         "IDC_SIZENWSE" 
    ;                           "IDC_SIZENESW"  "IDC_SIZEWE"  "IDC_SIZENS"       "IDC_SIZEALL" 
    ;                           "IDC_NO"        "IDC_HAND"    "IDC_APPSTARTING"  "IDC_HELP"
    ;
    ; Returns true if successful, false otherwise and 'ErrorLevel' will contain a displayable error message.
    ;
    set(newCursor)
    {
        newCursorID := "", fileName := "", ext := ""

        if (newCursor = CCursor._CurrentCursor)
        {
            ; Cursor shape already set.  Reset the restoration timer and return.
            if this.restorationDelay
                SetTimer CCursor_Timer, % -this.restorationDelay
            return
        }
        else
            SetTimer CCursor_Timer, Off

        CCursor._setExitHandler()
        
        if not CCursor._Width
        {
            SysGet tmp, 13  ; SM_CXCURSOR
            CCursor._Width := tmp
            
            SysGet tmp, 14  ; SM_CYCURSOR
            CCursor._Height := tmp
        }
        
        if (substr(newCursor, 1, 4) = "IDC_")
        {
            ; Always restore the default system cursor shapes.  This is necessary so we
            ; change all the cursor types to one of the standard shapes.
            CCursor.restore()

            ; Verify the caller passed in a valid system cursor name.
            if not newCursorID := CCursor._SystemCursors[newCursor]
                return CCursor._ErrorLevelBool("Invalid system cursor name '" newCursor "'.")

            ; Animated cursors must be loaded using LoadCursorFromFile(), otherwise they won't animate.
            ; So we need to get the file name assigned to the new cursor from the registry.  (If no file 
            ; has been assigned, the cursor is not animated and we can use its ID instead.)
            RegRead fileName, % "HKEY_CURRENT_USER\Control Panel\Cursors", % substr(newCursor,5)
            if not ErrorLevel
            {
                fileName := RegExReplace(fileName, "%SystemRoot%", A_WinDir)
                if not FileExist(fileName)
                    return CCursor._ErrorLevelBool("Missing cursor file """ fileName """")
            }
        }
        else if FileExist(newCursor)  ; Caller pass in a file name?
            fileName := newCursor
        else ; Invalid cursor name!
        {
            this.restore()  ; Restores default cursor.
            return CCursor._ErrorLevelBool("Invalid cursor name.  (" newCursor ")")
        }

        ; Verify the file type is supported.
        if fileName
        {
            SplitPath fileName,,, ext
            if (ext != "cur" and ext != "ani")
                return CCursor._ErrorLevelBool("Unsupported cursor file type.  (" ext ")")
        }

        ; Set the new cursor.
        if (newCursorID and (fileName = "" or ext = "cur"))
        {
            ; Load the new cursor image using LoadCursor().
            for each, systemCursorID in CCursor._SystemCursors
            {
                if hNewImage := DllCall("LoadCursor", "ptr",0, "int",newCursorID)
                {
                    if hNewImage := DllCall("CopyImage", "ptr",hNewImage, "uint",0x2
                                        , "int",CCursor._Width, "int",CCursor._Height, "uint",0)
                    {
                        DllCall("SetSystemCursor", "ptr",hNewImage, "uint",systemCursorID)
                    }
                    else
                        return CCursor._ErrorLevelBool("Failed to make a copy of the system cursor for """ newCursor """.")
                }
                else
                    return CCursor._ErrorLevelBool("Failed to load the cursor named """ newCursor """.")
            }
        }
        else
        {
            ; Change each system cursor to 'fileName' using LoadCursorFromFile().
            ; IMPORTANT: DO NOT call DestroyCursor() on the handle returned by LoadCursorFromFile().
            ;            It creates a shared cursor that must not be deleted.
            for each, systemCursorID in CCursor._SystemCursors
            {
                if hNewImage := DllCall("LoadCursorFromFile", "str",fileName)
                    DllCall("SetSystemCursor", "ptr",hNewImage, "uint",systemCursorID)
                else
                    return CCursor._ErrorLevelBool("Failed to load the cursor file named """ fileName """.")
            }
        }

        CCursor._CurrentCursor := newCursor
        return true
    }
    
    ;--------------------------------------------------------------------------
    ; Method:           handle
    ; Description:      Returns the cursor's handle.
    ; Parameters:
    ;   None.
    ;
    ; Returns the cursor's handle, or 0 on failure.
    ;
    ; EXAMPLE:
    ;   LShift::
    ;       while GetKeyState(A_ThisHotkey, "P")
    ;       {
    ;           ToolTip % A_Cursor " (" CCursor.handle() ")"
    ;           Sleep 500
    ;       }
    ;       ToolTip
    ;   return
    ;
    handle()
    {
        NumPut(VarSetCapacity(CursorInfo, A_PtrSize + 16), CursorInfo, "uint")
        DllCall("GetCursorInfo", "ptr", &CursorInfo)
        return NumGet(CursorInfo, 8)  ; hCursor
    }
    
    ;**************************************
    ;  Private Methods (for internal use)
    ;**************************************
    
    ;--------------------------------------------------------------------------
    ; Method:           _setExitHandler
    ; Description:      Makes sure a method has been assigned to the script's OnExit call.
    ;                   When the script exits, the mouse cursor will automatically be 
    ;                   restored to normal, preventing the cursor from being permanently
    ;                   altered or hidden.
    ; Parameters:
    ;   None.
    ;
    ; Returns nothing.
    ;
    _setExitHandler()
    {
        if not CCursor._ExitHandler
        {
            ; Setup an exit handler to restore the original cursor when the script exits.
            OnExit(ObjBindMethod(CCursor, "_cleanup"))
            CCursor._ExitHandler := true
        }
    }
    
    ;--------------------------------------------------------------------------
    ; Method:           _cleanup
    ; Description:      Used by _setExitHandler() to automatically restore the
    ;                   mouse cursor when the script exits.  
    ;                   IMPORTANT - This method must return nothing (or 0) so 
    ;                               the script to exit!
    ; Parameters:
    ;   None.
    ;
    ; Returns nothing.
    ;
    _cleanup() 
    {
        SetTimer CCursor_Timer, Off
        CCursor.restore(0)
    }
    
    ;--------------------------------------------------------------------------
    ; Method:           _ErrorLevelBool
    ; Description:      A handy method for returning errors.
    ; Parameters:
    ;   err             - The value to set ErrorLevel to.  If empty "",
    ;                     ErrorLevel will not be changed.
    ;
    ; Returns true if ErrorLevel indicates no error (0), false otherwise.
    ;
    _ErrorLevelBool(err := "")
    {
        if (err != "")
            ErrorLevel := err
        return ErrorLevel ? false : true
    }
    
    ;--------------------------------------------------------------------------
    ; Method:           _Timer
    ; Description:      A private method used when delaying restoration of the cursor.
    ; Parameters:
    ;   None.
    ;
    ; Returns nothing..
    ;
    _Timer()
    {
        ;--------------------
         CCursor_Timer:
        ;--------------------
        SetTimer CCursor_Timer, Off
        CCursor.restore(0)
        return
    }
} ; CCursor


;==============================================================================
; CLASS:    CWaitCursor, CAppStartingCursor, CHiddenCursor
; DESC:     Newing up these classes changes the mouse cursor and automatically
;           restores it when the new variable goes out of scope.
; EXAMPLE:
;    someFunction()
;    {
;        wc := new CWaitCursor()
;
;        ... Do some long task here ...
;
;    } ; The mouse cursor is automatically restored when 'wc' goes out of scope.
;
class CWaitCursor extends CCursor 
{
    __New(restorationDelay := 0) {
        base.__New("IDC_WAIT", restorationDelay)
    }
} ; CWaitCursor

class CAppStartingCursor extends CCursor 
{
    __New(restorationDelay := 0) {
        base.__New("IDC_APPSTARTING", restorationDelay)
    }
} ; CAppStartingCursor

class CHiddenCursor extends CCursor 
{
    __New(restorationDelay := 0) 
    {
        base.__New("", restorationDelay)
        this.hide()
    }
} ; CHiddenCursor

;--- End of File ---