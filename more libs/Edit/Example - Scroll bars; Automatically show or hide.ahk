/*
    Credit: Idea, most of the testing, and some code from Edd.  Thanks!

    In this example, scroll bars will automatically show or hide, depending on
    the data in the Edit control.  Only showing scroll bars when the data
    requires it might be useful if screen space is at a premium.

    Changes are made in real time, i.e. as the user is adding or removing text
    in the Edit control.  This example uses the Fnt_GetMultilineStringSize
    function in the the Fnt library to determine the width and the height of the
    text in the Edit control.

    Scroll bars for the Edit control:
    -----
    Scroll bars are embedded into the multi-line Edit control and are always
    available.  The scroll bar options specified at creation only determine
    whether the scroll bars are initially visible or not.  The scroll bars used
    by the Edit control were designed to be completely controlled by the Edit
    control.

    This example attempts to bypass some of the default behavior by showing a
    scroll bar only when needed and hiding it otherwise.  Hiding a scroll bar
    will increase the formatting rectangle of the Edit control so that more text
    can be shown at a time.  Showing a scroll bar decreases the formatting
    rectangle but allows the user to scroll to text that could not be seen
    otherwise.

    Overriding the default behavior introduces unexpected behavior that probably
    would not be seen otherwise.  For example, showing or hiding one scroll bar
    may cause the other scroll bar to show or hide unexpectedly.

    This example is result of a trial and error and a lot of testing.  Some
    portions of the code are performed twice because one change may trigger
    unexpected behavior which must be "reversed" on the second pass.

    Resources, response, and other considerations:
    -----
    This method should work fine for small edit fields because the amount of
    data to process is usually small.  However, if there is large amount a text,
    the processing requirements can increase significantly.  Since the routine
    will run for every change in the edit control, response time may be
    unacceptable in these cases.  A timer can be added so that the routine will
    only run when there is a gap in the changes (i.e. the user pauses typing)
    but the delayed changes to the edit control may not be very user friendly.
*/

#NoEnv
#SingleInstance Force
ListLines Off

ListOfItems=
   (ltrim
    Aqua Marine
    Blanched Almond
    Blue
    Dark Slate Blue
    Green
    Medium Goldenrod Yellow
    Spring Green
    Red
    )

;-- Build GUI
gui -DPIScale -MinimizeBox
gui Margin,15,15
    ;-- Just to add a little breathing room for this example

;-- Instructions for the user
gui Add
   ,Text
   ,xm,
       (ltrim
        Instructions: Add or remove text from the Edit control.  Scroll bars
        will automatically show or hide as needed.
        `nNote: The Edit control is set with a random font size to show that
        this will work with any font.
       )

;-- Random font size
Random FontSize,8,20
gui Font,s%FontSize%

;-- Temporarily create a logical font to set the width of the Edit control
hFont :=Fnt_CreateFont("","s" . FontSize)
EditW :=Fnt_GetFontAvgCharWidth(hFont)*25
Fnt_DeleteFont(hFont)

;-- Edit control
;   Note: No scroll bars specified here
gui Add
   ,Edit
   ,% ""
        . "xm "
        . "w" . EditW . A_Space
        . "r5 "
        . "+Multi "
        . "-Wrap "
        . "hWndhEdit "
        . "vMyEdit "
        . "gMyEditAction "

gui Font
gui Add,Button,gReload,%A_Space% Rebuild example... %A_Space%

;-- Hide all scroll bars so that we can identify the maximum formatting
;   rectangle of the Edit control.
Edit_HideAllScrollBars(hEdit)

;-- Get the formatting rectangle of the Edit control.
;   Calculate the available Width and Height of the Edit control.
;   Note: This information needs to be re-collected if/when the font of the Edit
;   control is changed.
Edit_GetRect(hEdit,Left,Top,Right,Bottom)
MyEditW :=Right-Left
MyEditH :=Bottom-Top

;-- Show all scroll bars so that we can identify the minimum formatting
;   rectangle of the Edit control.
Edit_ShowAllScrollBars(hEdit)

;-- Re-collect the formatting rectangle of the Edit control.
;   Calculate the space taken as a result of showing the scroll bars.
Edit_GetRect(hEdit,Left,Top,Right,Bottom)
VScrollGap :=MyEditW-(Right-Left)
HScrollGap :=MyEditH-(Bottom-Top)

;-- Collect the font of the Edit control while we're at it.
;   Note: Fnt_GetFont does the same thing.
hFont :=Edit_GetFont(hEdit)

;-- Show it
SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,,%$ScriptTitle%

;-- Populate the control with the test data (optional)
GUIControl,,MyEdit,%ListOfItems%

;-- Set the scroll bars for the data just loaded
gosub MyEditAction
return


;*********************
;*                   *
;*    Subroutines    *
;*                   *
;*********************
;-- This routine is called when anything in the Edit control is changed.
MyEditAction:

;-- Collect the text from the Edit control.
;   Note: Edit_GetText can be used instead.
gui Submit,NoHide

;-- Get the size (width and height) of the text in the Edit control
Fnt_GetMultilineStringSize(hFont,MyEdit,TextW,TextH)

;-- Check and Set
;   Note: In rare situations, hiding/showing one scroll bar will hide/show the
;   other scroll bar.  To ensure that this condition is dealt with, this section
;   is run up to 2 times.  The second iteration is only performed if a change
;   was made in the first iteration.
ChangeMade :=False
Loop 2
    {
    ;-- Compare the text with the available space in the Edit control
    ;   Note: Must check the measurements twice because showing one scroll bar
    ;   will reduce the width or height available and may trigger the need to
    ;   show the other scroll bar.
    ShowVScrollbar:=False
    ShowHScrollbar:=False
    Loop 2
        {
        if (TextW>MyEditW-(ShowVScrollbar ? VScrollGap:0))
            ShowHScrollbar:=True

        if (TextH>MyEditH-(ShowHScrollbar ? HScrollGap:0))
            ShowVScrollbar:=True
        }

    ;-- Get the current status of the scroll bars
    VScrollBarVisible :=Edit_IsVScrollBarVisible(hEdit)
    HScrollBarVisible :=Edit_IsHScrollBarVisible(hEdit)

    ;-- Show/Hide both? (at the same time)
    ;   Note: If needed, it is more efficient to show or hide both scroll bars
    ;   at the same.  The first two tests determine if both scroll bars are to
    ;   be shown or hidden at the same time.  The subsequent tests will
    ;   check/set the scroll bars one at a time.
     if (ShowVScrollbar and ShowHScrollbar)
    and (!VScrollBarVisible and !HScrollBarVisible)
        {
        Edit_ShowAllScrollBars(hEdit)
        ChangeMade:=True
        }
    else if (!ShowVScrollbar and !ShowHScrollbar)
    and (VScrollBarVisible and HScrollBarVisible)
        {
        Edit_HideAllScrollBars(hEdit)

        ;-- Scroll all the way to the left
        Edit_LineScroll(hEdit,"Left")
        ChangeMade:=True
        }
     else
        {
        if ShowVScrollbar
            {
            if not VScrollBarVisible
                {
                Edit_ShowVScrollbar(hEdit)
                ChangeMade:=True
                }
            }
         else
            {
            if VScrollBarVisible
                {
                Edit_HideVScrollbar(hEdit)
                ChangeMade:=True
                }
            }

        if ShowHScrollbar
            {
            if not HScrollBarVisible
                {
                Edit_ShowHScrollbar(hEdit)
                ChangeMade:=True
                }
            }
         else
            {
            if HScrollBarVisible
                {
                Edit_HideHScrollbar(hEdit)

                ;-- Scroll all the way to the left
                Edit_LineScroll(hEdit,"Left")
                ChangeMade:=True
                }
            }
        }

    if not ChangeMade
        Break
    }

;-- Scrolls the caret into view if a scroll bar change has been made
if ChangeMade
    Edit_ScrollCaret(hEdit)

return


GUIClose:
GUIEscape:
ExitApp


Reload:
Reload
return


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%\_Functions
#include Edit.ahk
#include Fnt.ahk
