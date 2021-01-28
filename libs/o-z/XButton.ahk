/*
Gui +Owner +LastFound
  Gui_ID := WinExist()

;   ;AUTORADIOBUTTON w/TEXT - will get converted to GROUPBOX
  Xbutton1:=XButton_Add(Gui_ID, "Button1_Function", "CHECKBOX","", "Groupbox", "","x5 y2 w190 h215")
;
;   ;Changed style from AUTORADIOBUTTON - to - GROUPBOX  -May use GROUPBOX handle to set other buttons in groupbox **Will not send messages though**
  XButton_SetStyle(Xbutton1,"GROUPBOX")

  ;DEFPUSHBUTTON w/ICON
;   Xbutton2:=XButton_Add(Gui_ID, "Button2_Function", "DEFPUSHBUTTON","", "", "enable.ico,enable.ico,DailyLog.ico,enable.ico,enable.ico","x10 y25 w70 h70")

  ;AUTORADIALBUTTON w/ICON
  Xbutton3:=XButton_Add(Gui_ID, "Button3_Function", "AUTOCHECKBOX","RIGHTBUTTON", "CheckBox", "","x10 y30 w85 h80")
  Xbutton4:=XButton_Add(Gui_ID, "Button4_Function", "AUTO3STATE","RIGHTBUTTON", "CheckBox", "","x10 y80 w85 h80")
  Xbutton5:=XButton_Add(Gui_ID, "Button5_Function", "AUTORADIOBUTTON","RIGHTBUTTON", "CheckBox", "","x10 y130 w85 h80")

  ;USERBUTTON w/TEXT
;   Xbutton4:=XButton_Add(Gui_ID, "Button4_Function", "USERBUTTON","", "UserButton", "","x10 y120 w90 h50")

  ;USERBUTTON w/o TEXT & setting text after button created
   Xbutton5:=XButton_Add(Gui_ID, "Button5_Function", "USERBUTTON","TOP", "", "C:\Program Files\Microsoft Office\OFFICE11\FORMS\1033\SCDCNCLL.ICO,enable.ico,DailyLog.ico,enable.ico,enable.ico BOTTOM T15","x100 y120 w90 h50", 0)
;   XButton_SetText(Xbutton5,"testing")

  Gui, Show, w200 h220
return


;Controls functions for testing...
Button1_Function(hwnd, t)   {
  tooltip % "Button1_Function  " . t
  sleep 500
  tooltip
}

Button2_Function(hwnd, t)   {
  tooltip % "Button2_Function  " . t
  sleep 500
  tooltip
}

Button3_Function(hwnd, t)   {
  tooltip % "Button3_Function  " . t
  sleep 500
  tooltip
}

Button4_Function(hwnd, t)   {
  tooltip % "Button4_Function  " . t
  sleep 500
  tooltip
}

Button5_Function(hwnd, t)   {
  tooltip % "Button5_Function  " . t
  sleep 500
  tooltip
}

Button6_Function(hwnd, t)   {
  tooltip % "Button6_Function  " . t
  sleep 500
  tooltip
}

GuiClose:
ExitApp

*/


; xButton by: Weston Stover
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function:  XButton_Add
;			Add a specific Button type to the GUI.  Only set ONE control Type at a time.
;
; Parameters:
;			hCtrl		- Handle of the GUI. GUI must have defined size or shown.
;     xType   - Different button types may be applied(Only one type per button).  Types are listed below:
;			xStyle	- Styles to apply to the button control(May apply multiple styles). Styles are listed below:
;			xImage	- Path of image that you would like to add to the button... .jpg, .bmp, .ico, .png, etc...
;               Use Comma Delimeter to add up to 7 different icons to one button control( ** See XButton_Add_Image Function ** )
;               Path can be of the following formats:
;                 * File.ico                 - You can enter just the file name ( Will assume file is in A_WorkingDir )
;                 * A_Temp . "\File.DLL|3    - You can specify which icon within a .DLL file to use
;                 * C:\Program Files\Microsoft Office\OFFICE11\FORMS\1033\SCDCNCLL.ICO - You can specify full pathname
;
;               ** ALIGNMENT - Add a space after image path and specify: LEFT, RIGHT, CENTER, TOP, BOTTOM after image to align
;               ** MARGINS   - Add a space after alignment and specify: l r t b   ie: l20 r20 t10 b10  or just r50 ...Margins can only be set if alignment is set.  Otherwise the image is center aligned.
;			xPos		- Postion of button - any space separated combination of the x y w h keywords followed by the value... ie. "x10 y10 w100 h100" or just "y50"
;     xSize   - 1 = Large Icons, 0 = Small Icons ( Default is Large )
;
; Control Types:
;     3STATE            - Creates a button that is the same as a check box, except that the box can be grayed as well as checked or cleared. Use the grayed state to show that the state of the check box is not determined.
;     AUTO3STATE        - Creates a button that is the same as a three-state check box, except that the box changes its state when the user selects it. The state cycles through checked, indeterminate, and cleared.
;     GROUPBOX          - Creates a rectangle in which other controls can be grouped. Any text associated with this style is displayed in the rectangle's upper left corner.
;     USERBUTTON        - Obsolete, but provided for compatibility with 16-bit versions of Windows. Applications should use OWNERDRAW instead.
;     CHECKBOX          - Creates a small, empty check box with text. By default, the text is displayed to the right of the check box. To display the text to the left of the check box, combine this flag with the LEFTTEXT style (or with the equivalent RIGHTBUTTON style).
;     AUTOCHECKBOX      - Creates a button that is the same as a check box, except that the check state automatically toggles between checked and cleared each time the user selects the check box.
;     RADIOBUTTON       - Creates a small circle with text. By default, the text is displayed to the right of the circle. To display the text to the left of the circle, combine this flag with the LEFTTEXT style (or with the equivalent RIGHTBUTTON style). Use radio buttons for groups of related, but mutually exclusive choices.
;     AUTORADIOBUTTON   - Creates a button that is the same as a radio button, except that when the user selects it, the system automatically sets the button's check state to checked and automatically sets the check state for all other buttons in the same group to cleared.
;     PUSHBUTTON        - Creates a push button that posts a WM_COMMAND message to the owner window when the user selects the button.
;     DEFPUSHBUTTON     - Creates a push button that behaves like a PUSHBUTTON style button, but has a distinct appearance. If the button is in a dialog box, the user can select the button by pressing the ENTER key, even when the button does not have the input focus. This style is useful for enabling the user to quickly select the most likely (default) option.
;     SPLITBUTTON       - NOT TESTED - Microsoft Windows Vista and Version 6.00. Creates a split button. A split button has a drop down arrow.
;     DEFSPLITBUTTON    - NOT TESTED - Microsoft Windows Vista and Version 6.00. Creates a split button that behaves like a BS_PUSHBUTTON style button, but also has a distinctive appearance. If the split button is in a dialog box, the user can select the split button by pressing the ENTER key, even when the split button does not have the input focus. This style is useful for enabling the user to quickly select the most likely (default) option.
;     COMMANDLINK       - NOT TESTED - Microsoft Windows Vista and Version 6.00. Creates a command link button.
;     DEFCOMMANDLINK    - NOT TESTED - Microsoft Windows Vista and Version 6.00. Creates a command link button that behaves like a PUSHBUTTON style button. If the button is in a dialog box, the user can select the command link button by pressing the ENTER key, even when the command link button does not have the input focus. This style is useful for enabling the user to quickly select the most likely (default) option.
;
; Control Styles:
;     OWNERDRAW     - Creates an owner-drawn button. The owner window receives a WM_DRAWITEM message when a visual aspect of the button has changed. Do not combine the BS_OWNERDRAW style with any other button styles.
;     ICON          - Specifies that the button displays an icon. If Icon specified in style than no text will overlap...
;     BITMAP        - Specifies that the button displays a bitmap.
;     FLAT          - Specifies that the button is two-dimensional; it does not use the default shading to create a 3-D image.
;     PUSHLIKE      - Makes a button (such as a check box, three-state check box, or radio button) look and act like a push button. The button looks raised when it isn't pushed or checked, and sunken when it is pushed or checked.
;     RIGHTBUTTON   - Positions a radio button's circle or a check box's square on the right side of the button rectangle. Same as the BS_LEFTTEXT style.
;     MULTILINE     - Wraps the button text to multiple lines if the text string is too long to fit on a single line in the button rectangle.
;     TEXT          - Specifies that the button displays text.
;     LEFTTEXT      - Places text on the left side of the radio button or check box when combined with a radio button or check box style. Same as the BS_RIGHTBUTTON style.
;     RIGHT         - Right-justifies text in the button rectangle. However, if the button is a check box or radio button that does not have the BS_RIGHTBUTTON style, the text is right justified on the right side of the check box or radio button.
;     LEFT          - Left-justifies the text in the button rectangle. However, if the button is a check box or radio button that does not have the BS_RIGHTBUTTON style, the text is left justified on the right side of the check box or radio button.
;     BOTTOM        - Places text at the bottom of the button rectangle.
;     TOP           - Places text at the top of the button rectangle.
;     CENTER        - Centers text horizontally in the button rectangle.
;     VCENTER       - Places text in the middle (vertically) of the button rectangle.
;     TYPEMASK      - Microsoft Windows 2000: A composite style bit that results from using the OR operator on BS_* style bits. It can be used to mask out valid BS_* bits from a given bitmask. Note that this is out of date and does not correctly include all valid styles. Thus, you should not use this style.
;
; Returns:
;			Handle of the button control
;
; Example:
;     - Xbutton3:=XButton_Add(Gui_ID, "Button3_Function", "AUTOCHECKBOX","MULTILINE TOP", "CheckBox MultiLine w\Icon", "C:\Program Files\Microsoft Office\OFFICE11\FORMS\1033\SCDCNCLL.ICO,C:\Program Files\Microsoft Office\OFFICE11\FORMS\1033\SCDCNCLL.ICO,DailyLog.ico BOTTOM T50 l-10","x100 y30 w85 h80")
;     - Xbutton2:=XButton_Add(Gui_ID, "Button2_Function", "DEFPUSHBUTTON","", "", "enable.ico,enable.ico,DailyLog.ico,enable.ico,enable.ico","x10 y25 w70 h70")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
XButton_Add(hCtrl,xFunc,xType,xStyle,xText="",xImage="",xPos="",xSize=1)  {

local   hXButton, XBUTTONCLASS:="BUTTON"                                  ; Windows API Button class

static  WS_TABSTOP=0x10000,WS_VISIBLE=0x10000000,WS_CHILD=0x40000000,init
  ;Button Types
static BS_3STATE=0x5
static BS_AUTO3STATE=0x6
static BS_GROUPBOX=0x7
static BS_USERBUTTON=0x8
static BS_CHECKBOX=0x2

static BS_AUTOCHECKBOX=0x3
static BS_AUTORADIOBUTTON=0x9
static BS_RADIOBUTTON=0x4
static BS_PUSHBUTTON=0x0
static BS_DEFPUSHBUTTON=0x1
  ;Button Styles
static BS_LEFTTEXT=0x20
static BS_OWNERDRAW=0xB
static BS_BITMAP=0x80
static BS_BOTTOM=0x800
static BS_CENTER=0x300

static BS_ICON=0x40
static BS_FLAT=0x8000
static BS_LEFT = 0x100
static BS_MULTILINE=0x2000
static BS_NOTIFY=0x4000
static BS_PUSHLIKE=0x1000

static BS_RIGHT=0x200
static BS_RIGHTBUTTON=0x20
static BS_TEXT=0x0
static BS_TOP=0x400
static BS_TYPEMASK=0xF
static BS_VCENTER=0xC00

  xButtonType:=0,xButtonStyle:=0                          ; Set to 0 for integer adding
  StringSplit,xType,xType,%A_Tab%%A_Space%                ; Split type incase user tries to use two different button types at once
  If xType2                                               ; If there is a second button type listed then return error message
    return "Invalid button type...`n Only one button type per button!"
  xType=%xType%                                           ; Trim whitespace
  If BS_%xType% is number                                 ; Verifies button type is in the button type list
    xButtonType |= BS_%xType%                             ; Gives the button type a hex value
  If !xButtonType                                         ; If button type is not in the list then return error message
    return "Error: Please enter valid button type..."
  Loop,Parse,xStyle,%A_Tab%%A_Space%                      ; Add style hex values together to be put in button class
    xButtonStyle |= BS_%A_LoopField%

  If (xPos != ""){                                        ; Gets X,Y,W,H values for class   - Stripped from majkinetor - Toolbar.ahk @ http://www.autohotkey.com/forum/topic27382.html
		x := y := 0, w := h := 100                            ; Set initial X,Y,W,H values
		Loop, parse, xPos, %A_Tab%%A_Space%, %A_Tab%%A_Space% ; Loop through xPOS for values
		{
			IfEqual, A_LoopField, , Continue
			p := SubStr(A_LoopField, 1, 1)                      ; pulls first substr in the loopfield, "x" being first, then "y" and so on...
			If p not in x,y,w,h                                 ; verifies there are x,y,w,h values set, if missing value or no values, return error message
				return "Err: Invalid position specifier"
			%p% := SubStr(A_LoopField, 2)                       ; Sets p to the value of the second substr, if x50 then p would equal 50 and so on...
		}
	}

  If !init                                                ; Setup for notifications to control   -Also from majkinetor
    OnMessage(WM_COMMAND:=0x111, "xButton_OnCommand"), init := true   ; Call OnCommand Function as control is clicked

	hXButton := DllCall("CreateWindowEx"
                , "Uint", 0                               ; ExStyle (window style)
                , "str" , XBUTTONCLASS                    ; ClassName
                , "str" , xtext                           ; ButtonName
                , "Uint", WS_TABSTOP | WS_VISIBLE | WS_CHILD | BS_NOTIFY | xButtonType | xButtonStyle  ; Button Style
                , "int" , x                               ; Left
                , "int" , y                               ; Top
                , "int" , w                               ; Width
                , "int" , h                               ; Height
                , "Uint", hCtrl                           ; hWndParent
                , "Uint", 0                               ; hMenu
                , "Uint", 0                               ; hInstance
                , "Uint", 0)

  If (xImage != "")
    XButton_Add_Image(hXButton,xImage,xSize)           ; If image is specified than setup in imagelist

  Xbutton_%hXButton%_Func := xFunc
return hXButton                                        ; returns control handle
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function:   Xbutton_SetText
;     Sends text string to button control or retrieves button control text
;
; Parameters:
;		  hCtrl  - Handle of the button control
;     xText  - Sets button text ( If blank, will retrieve the text from the control )
;
; Returns:
;     Returns 1 if successful, 0 if Fail or button control text of second parameter is blank
;
; Example:
;   - XButton_SetText(Xbutton1Hwnd, "This is new text")
;   - Msgbox % XButton_SetText(Xbutton1Hwnd)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
XButton_SetText(hCtrl,xText="")  {
  static  WM_SETTEXT=0xC,WM_GETTEXT=0xD

  If (xText="")   {                                                ; If no xText specified then return text value of control
    VarSetCapacity(Retrieved_Text,250,0)                           ; Set 250 var capacity to receive 250 chars of text
    SendMessage,WM_GETTEXT,100,&Retrieved_Text,,ahk_id %hCtrl%     ; Send message "0xD" to control to retrieve text
    return Retrieved_Text                                          ; Return text from control
  }
  SendMessage,WM_SETTEXT,0,&xtext,,ahk_id %hCtrl%                  ; Set control to xText specified
    return ErrorLevel                                              ; Return errorlevel 1 if successful, 0 if fail
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function:   XButton_Add_Image
;     Contains information about an image list that is used with a button control.
;
; Parameters:
;		  hCtrl   - Handle of the button control
;     xImage  - Path of image to add to imagelist
;		  xSize	  - Size of Icon:  1 - Large , 0 - Small
;     xState  - Set different image to each state( See Notes below );
;               Use comma delimeter for each file:
;
;               * NORMAL,HOT,PUSHED,DISABLED,FOCUS,STYLUSHOT
;
;               ** Check/Radial button states:
;
;               * NORMAL,HOT,HOT&PUSHED,CHECKED,CHECKED&PUSHED
;
;               ** Can specify just: NORMAL,HOT,,CHECKED
;
; Returns:
;     Returns 1 if successful, 0 if Fail
;
; Notes:
;     STYLUSHOT is used only on tablet computers.
;     Each value is an index to the appropriate image in the image list.
;     If only one image is present, it is used for all states.
;     If the image list contains more than one image, each index corresponds to one state of the button.
;     If an image is not provided for each state, nothing is drawn for those states without images.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
XButton_Add_Image(hCtrl,xImage,xSize)  {
  static  BCM_FIRST=0x1600,BCM_GETIMAGELIST=0x3,BCM_SETIMAGELIST=0x2

  static  BUTTON_IMAGELIST_ALIGN_BOTTOM=3,BUTTON_IMAGELIST_ALIGN_CENTER=4,BUTTON_IMAGELIST_ALIGN_LEFT=0
         ,BUTTON_IMAGELIST_ALIGN_RIGHT=1,BUTTON_IMAGELIST_ALIGN_TOP=2



; set by IL when assiging..
hIL := IL_Create(6,0,xSize)                               ; Initialize imagelist


  StringSplit, xStates, xImage, `,                          ; Split different icon states

  Loop, 6                                                   ; Loop 6 times for each state of the button
  {
    xImage_List:=xImage_New:="",t=0                         ; Reset values for next loop iteration
    xImage_List:=xStates%A_Index%                           ; Sest xImage_List to the index of the stringplit xStates

    If !xStates%A_Index%                                    ; Skip file is none present
      xImage_List:="0"

    SplitPath, xImage_List, Alignment                       ; Gets the alignment and margins of the icon
    SplitPath, xImage_List,,Dir                             ; Checks path for spaces such as Program Files

    StringSplit, Alignment, Alignment, %A_Space%            ; Read aliment if anything in second space
    StringSplit, xImage_List, xImage_List, %A_Space%        ; Reads xImage to seperate path of file and Alignment

    If Alignment2
      xImage_New:= Dir . Alignment1                         ; Rebuild file path so xImage_New is not showing the aligment
    Else
      xImage_New=%xImage_List%                              ; Trim WhiteSpace




    If ( SubStr( xImage_New, 1, 1 ) = "." )  {              ; If Icon is a file extension.. use associated program icon
      xIcon := xImage_New
      RegRead, OutputClass, HKEY_LOCAL_MACHINE,Software\CLASSES\%xIcon%,
      RegRead, OutputIcon, HKEY_LOCAL_MACHINE,Software\CLASSES\%OutputClass%\DefaultIcon,
      StringSplit, IconArray, OutputIcon, `,, %A_Space%
      IconNum := IL_Add( hIL, IconArray1, IconArray2, pIconNum += 1 )
    }
    Else If InStr( xImage_New, ".dll|" )  {         ; if icon is a .dll|#
      StringSplit, iconArray, xImage_New, |, %A_Space%
      If iconArray2 is number
        IconNum := IL_Add( hIL, iconArray1, iconArray2 )
    }
    Else                                      ; Otherwise...
      IconNum := IL_Add( hIL, xImage_New, "", pIconNum += 1 )
  }

  Loop, 4                                                 ; L,R,T,B - Gets margins
    If ( A_Index > 2 )
      xMargin.=Alignment%A_Index% . " "

  Loop,Parse,xAlign,%A_Tab%%A_Space%                      ; Reads alignment and set to appropriate variable
    BUTTON_IMAGELIST_ALIGN := BUTTON_IMAGELIST_ALIGN_%A_LoopField%
  If !BUTTON_IMAGELIST_ALIGN                              ; Align center if no alignment is specified
    BUTTON_IMAGELIST_ALIGN:=BUTTON_IMAGELIST_ALIGN_CENTER

	l:=r:=1,t:=b:=1                                               ; Set Default margins
	Loop, parse, xMargin, %A_Tab%%A_Space%, %A_Tab%%A_Space%      ; Set margins if margins are specified
	{
		IfEqual, A_LoopField,, Continue
		p := SubStr(A_LoopField, 1, 1)
		If p not in l,r,t,b
			return "Error: Invalid margin"
		%p% := SubStr(A_LoopField, 2)
	}

  VarSetCapacity(XIMAGELIST, 24, 0)                        ; ImageList Struct setup
  NumPut(hIL, XIMAGELIST, 0, "Uint")                       ; ImageList Handle
  NumPut(l, XIMAGELIST, 4, "Int")                          ; Left Margin
  NumPut(t, XIMAGELIST, 8, "Int")                          ; Top Margin
  NumPut(r, XIMAGELIST, 12, "Int")                         ; Right Margin
  NumPut(b, XIMAGELIST, 16, "Int")                         ; Bottom Margin
  NumPut(BUTTON_IMAGELIST_ALIGN, XIMAGELIST, 20, "UInt")   ; Alignment
  SendMessage,BCM_FIRST|BCM_SETIMAGELIST,0,&XIMAGELIST,,ahk_id %hCtrl%     ; Set initial imagelist
    return ErrorLevel
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function:   Xbutton_SetImage
;     Associates a new image (icon or bitmap) with the button.
;
; Parameters:
;		  hCtrl    - Handle of the button control
;     IconNum  - Set to icon# in the icon list specified for each state
;                If no iconNum see Return value
;
; Return Value:
;     The return value is a handle to the image previously associated with the button, if any; otherwise, it is NULL.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
XButton_SetImage(hCtrl, IconNum=0)  {
  static BM_SETIMAGE=0xF7,BM_GETIMAGE=0xF6,IMAGE_ICON=1,IMAGE_BITMAP=0

  SendMessage,BM_SETIMAGE,IMAGE_ICON,IconNum,,ahk_id %hCtrl%
    return Errorlevel
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function:   XButton_SetShield
;     Sets the elevation required state for a specified button or command link to display an elevated icon.
;
; Parameters:
;		  hCtrl      - Handle of the button control
;     xElevated  - Set True(to raise) or False(not raise)
;
; Return Value:
;     Returns 1 if successful, or an error code otherwise.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
XButton_SetShield(hCtrl,xElevated=True)  {
  static BCM_FIRST=0x3,BCM_SETSHIELD=0x160C

  SendMessage,BCM_FIRST | BCM_SETSHIELD,0,xElevated,,ahk_id %hCtrl%
    return ErrorLevel
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function: XButton_GetImageList
;     Get Current Image list if one exists
;
; Parameters:
;		  hCtrl  - Handle of the button control
;
; Return Value:
;     If the message succeeds, it returns TRUE. Otherwise it returns FALSE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
XButton_GetImageList(hCtrl)  {
  static BCM_FIRST=0x3,BCM_GETIMAGELIST=0x1603

  VarSetCapacity(xImageList, 24, 0)           ;Set Imagelist structure - structure size is 24 - to return
  SendMessage,BCM_FIRST | BCM_GETIMAGELIST,0,&xImageList,,ahk_id %hCtrl%
    return ErrorLevel ? "True" : "False"
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function:   XButton_SetStyle
;     Sets the style of a button.
;
; Parameters:
;		  hCtrl   - Handle of the button control
;     xStyle  - Can be any combination style listed in Function:  XButton_Add
;     xRedraw - Determines if control is redrawn or not after style has been set.  Default value is TRUE
;
; Return Value:
;     This message always returns zero.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
XButton_SetStyle(hCtrl,xStyle="",xRedraw=True)  {
  static  BM_SETSTYLE=0xF4

  ;Type of buttons
static BS_3STATE=0x5
static BS_AUTO3STATE=0x6
static BS_GROUPBOX=0x7
static BS_USERBUTTON=0x8
static BS_CHECKBOX=0x2
static BS_AUTOCHECKBOX=0x3
static BS_AUTORADIOBUTTON=0x9
static BS_RADIOBUTTON=0x4
static BS_PUSHBUTTON=0x0
static BS_DEFPUSHBUTTON=0x1
  ;Style of buttons
static BS_LEFTTEXT=0x20
static BS_OWNERDRAW=0xB
static BS_BITMAP=0x80
static BS_BOTTOM=0x800
static BS_CENTER=0x300
static BS_ICON=0x40
static BS_FLAT=0x8000
static BS_LEFT = 0x100
static BS_MULTILINE=0x2000
static BS_NOTIFY=0x4000
static BS_PUSHLIKE=0x1000
static BS_RIGHT=0x200
static BS_RIGHTBUTTON=0x20
static BS_TEXT=0x0
static BS_TOP=0x400
static BS_TYPEMASK=0xF
static BS_VCENTER=0xC00

  xButtonStyle:=0                                         ; Set value as number
  Loop,Parse,xStyle,%A_Tab%%A_Space%                      ; Add hex value of each style together to be sent to control
    xButtonStyle |= BS_%A_LoopField%
  SendMessage,BM_SETSTYLE,xButtonStyle,xRedraw,,ahk_id %hCtrl%
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function: XButton_State
;     Sets the highlight state of a button. The highlight state indicates whether the button is highlighted as if the user had pushed it
;     Returns the effects of the button control
;
; Parameters:
;		  hCtrl   - Handle of the button control
;     xState  - Set TRUE - (Pressed) or FALSE - (unPressed)
;               Leave blank to get current state of button control
;
; Remarks:
;     Highlighting affects only the appearance of a button. It has no effect on the check state of a radio button or check box.
;     A button is automatically highlighted when the user positions the cursor over it and presses and holds the left mouse button. The highlighting is removed when the user releases the mouse button.
;
; Return Value:
;     Returns state of buttons if no xState specified.  If xstate spcified, always returns 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
XButton_State(hCtrl, xState="")  {
  static  BM_SETSTATE=0xF3,BM_GETSTATE=0xF2

  static  BST_CHECKED=0x1,BST_FOCUS=0x8,BST_HOT=0x0200,BST_INDETERMINATE=0x2
         ,BST_PUSHED=0x4,BST_UNCHECKED=0x0

  If (xState="")  {
    SendMessage,BM_GETSTATE,0,0,,ahk_id %hCtrl%
    tm := ErrorLevel
    OPTIONS=HOT,FOCUS,PUSHED,INDETERMINATE,CHECKED
    Loop, parse, OPTIONS,`,
      tm >= BST_%A_LoopField% ? (tmDesc.=(tmDesc ? " " A_LoopField : A_LoopField), tm-=BST_%A_LoopField%)  :  ""
    return % tmDesc
  }
  Else
    SendMessage,BM_SETSTATE,xState,0,,ahk_id %hCtrl%
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function:   xButton_GetCheck
;     Gets the check state of a radio button or check box.
;
; Parameters:
;		  hCtrl  - Handle of the button control
;
; Returns:
;     Returns "CHECKED" or "INDETERMINATE" text string.  Return value is NULL if any other state
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
XButton_GetCheck(hCtrl)   {
  static  BM_GETCHECK=0xF0

  static  BST_CHECKED=0x1,BST_INDETERMINATE=0x2,BST_UNCHECKED=0x0

  SendMessage,BM_GETCHECK,0,0,,ahk_id %hCtrl%
  tm := ErrorLevel
  OPTIONS=INDETERMINATE,CHECKED
  Loop, parse, OPTIONS,`,
    tm >= BST_%A_LoopField% ? (tmDesc.=(tmDesc ? " " A_LoopField : A_LoopField), tm-=BST_%A_LoopField%)  :  ""
  return % tmDesc
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function: XButton_SetDontClick
;     Sets a flag on a radio button that controls the generation of BN_CLICKED messages when the button receives focus.
;
; Parameters:
;	    hCtrl  - Handle of the button control
;     xFlag  - Set TRUE - (Cannot Click) or FALSE - (Clickable)
;
; Return Value:
;     No return value.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
XButton_SetDontClick(hCtrl, xFlag)  {
  static BM_SETDONTCLICK=0xF8

  SendMessage,BM_SETDONTCLICK,xFlag,0,,ahk_id %hCtrl%
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function: XButton_Click
;     Simulates the user clicking a button.
;     This message causes the button to receive the WM_LBUTTONDOWN and WM_LBUTTONUP messages, and the button's parent window to receive a BN_CLICKED notification message.
;
; Parameters:
;		  hCtrl  - Handle of the button control
;
; Remarks:
;     If the button is in a dialog box and the dialog box is not active, the BM_CLICK message might fail.
;     To ensure success in this situation, call the SetActiveWindow function to activate the dialog box before sending the BM_CLICK message to the button.
;
; Return Value:
;     This message does not return a value.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
XButton_Click(hCtrl)  {
  static BM_CLICK=0xF5

  SendMessage,BM_CLICK,0,0,,ahk_id %hCtrl%
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function:   XButton_Check
;     Sets the check state of a radio button or check box
;
; Parameters:
;		  hCtrl  - Handle of the button control
;     xState - See list of styles
;
; Styles:
;     CHECKED        - Sets the button state to checked.
;     INDETERMINATE  - Sets the button state to grayed, indicating an indeterminate state. Use this value only if the button has the BS_3STATE or BS_AUTO3STATE style.
;     UNCHECKED      - Sets the button state to cleared
;
; Remarks:
;     The BM_SETCHECK message has no effect on push buttons.
;
; Returns:
;     This message will return the radio button or check box check state
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
XButton_Check(hCtrl, xState)  {
  static  BM_SETCHECK=0xF1

  static  BST_CHECKED=0x1,BST_INDETERMINATE=0x2,BST_UNCHECKED=0x0

  xButtonState:=0
  Loop,Parse,xState,%A_Tab%%A_Space%                      ; Adds hex values together to be sent to control
    xButtonState |= BST_%A_LoopField%
  SendMessage,BM_SETCHECK,xButtonState,0,,ahk_id %hCtrl%
    return Errorlevel
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function:   XButton_GetNoteLength
;     Gets the length of the note text that may be displayed in the description for a command link button.
;
; Parameters:
;		  hCtrl  - Handle of the button control
;
; Return Value:
;     Returns the length of the note text in WCHARs, not including any terminating NULL, or zero if there is no note text.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
XButton_GetNoteLength(hCtrl)  {
  static BCM_FIRST=0x3,BCM_GETNOTELENGTH=0x160B

  SendMessage,BCM_FIRST | BCM_GETNOTELENGTH,0,0,,ahk_id %hCtrl%
    return ErrorLevel
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function:   XButton_GetNote
;     Gets the text of the note associated with a command link button.
;
; Parameters:
;		  hCtrl  - Handle of the button control
;     xText  - Text to set the note value to
;
; Remarks:
;     BCM_GETNOTE messages work only with the BS_COMMANDLINK and BS_DEFCOMMANDLINK button styles.
;
; Return Value:
;     If the message succeeds, it returns TRUE. Otherwise it returns FALSE.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
XButton_GetNote(hCtrl, xText="")  {
  static BCM_FIRST=0x3,BCM_GETNOTE=0x160A,BCM_SETNOTE=0x1609

  If (xText="") {
    xLength:=XButton_GetNoteLength(hCtrl)
    SendMessage,BCM_FIRST | BCM_GETNOTE,xLength,xLength,,ahk_id %hCtrl%
      return ErrorLevel
  }  Else  {
    VarSetCapacity(XNOTETEXT, 4, 0)
    NumPut(xText,XNOTETEXT,0,"UInt")
    SendMessage,BCM_FIRST | BCM_SETNOTE,0,&XNOTETEXT,,ahk_id %hCtrl%
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function:   xButton_SetDropDownState
;     Sets the drop down state for a button with style TBSTYLE_DROPDOWN
;
; Parameters:
;		  hCtrl   - Handle of the button control
;     xState  - set TRUE for state of DROPDOWNPUSHED, or FALSE otherwise.
;
; Return Value:
;     Returns TRUE if successful, or FALSE otherwise.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
xButton_SetDropDownState(hCtrl, xState=False)  {
  static BCM_FIRST=0x3,BCM_SETDROPDOWNSTATE=0x1606

  SendMessage,BCM_FIRST | BCM_SETDROPDOWNSTATE,0,xState,,ahk_id %hCtrl%
    return ErrorLevel
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
XButton_SetDefault(hCtrl)   {
  static  WM_USER=0x400,DM_SETDEFID=1
  SendMessage,WM_USER | DM_SETDEFID,hCtrl,0,,ahk_id %hCtrl%
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function:   xButton_OnCommand
;     Controls button action by recieving clicks
;
; Return Value:
;     returns to the control function "CHECKED" or "PUSHED"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
xButton_OnCommand(wparam,lparam)    {
  static CLICKED=1                                  ; Generic code set

  xAction:=(NumGet(wparam)&0xFF)-47                 ; Control Action   -842203183
  Hwnd:=(lparam)                                    ; Control Handle

  xFunc := xButton_%hwnd%_Func                      ; Set controls function handle
  xCheck_State:=XButton_GetCheck(hwnd)              ; returns state of button

  If (xAction = CLICKED) {                          ; If button is clicked
    If Instr(xCheck_State,"CHECKED")
      %xFunc%(hwnd,"CHECKED")                       ; Send "CHECKED" state to button function
    Else If Instr(xCheck_State,"INDETERMINATE")
      %xFunc%(hwnd,"INDETERMINATE")                 ; Send "INDETERMINATE" sate to button function
    Else
      %xFunc%(hwnd,"PUSHED")                        ; Send "PUSHED" state to button function
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; XButton_TextMargin(hCtrl)  {
;   static BCM_FIRST=0x3,BCM_SETTEXTMARGIN=0x1604,BCM_GETTEXTMARGIN=0x1605
;
;   VarSetCapacity(xRECT, 4, 0)
; ;     NumPut(xText,xRECT,0,"UInt")
;   SendMessage,BCM_FIRST | BCM_GETTEXTMARGIN,0,&xRECT,,ahk_id %hCtrl%
;
;   SendMessage,BCM_FIRST | BCM_SETTEXTMARGIN,0,&xRECT,,ahk_id %hCtrl%
; }


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; XButton_SplitInfo(hCtrl)  {
;   static BCM_FIRST=0x3,BCM_SETSPLITINFO=0x1607,BCM_GETSPLITINFO=0x1608
;
;   SendMessage,BCM_FIRST | BCM_SETSPLITINFO, ?, ?,, ahk_id %hCtrl%
; }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; xButton_SetColor(hCtrl)   {
;   static  WM_CTLCOLORBTN = 0x135
;   VarSetCapacity(xBtnColor, 4 + 255 * 9, 0)
;   SendMessage,WM_CTLCOLORBTN,0xFFFFFF, 0,,ahk_id %hCtrl%
;     return errorlevel
; }