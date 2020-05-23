;-- Example created from code provided by Laszlo
;   Post: http://www.autohotkey.com/board/topic/10236-drag-drop-in-edit-controls/page-2#entry303878

#SingleInstance Force
#NoEnv
SetBatchLines -1

OnMessage(0x201,"LButtonDown")                      ; react to 0x201 = WM_LBUTTONDOWN
OnMessage(0x202,"LButtonUp")                        ; react to 0x202 = WM_LBUTTONUP

gui -DPIScale -MinimizeBox
gui Font,s16                                        ; TEST GUI
gui Margin,0,0
gui Add,Button,h0 w0                               ; only to unselect edit text below
gui Font,cRed
gui Add,Edit,r4 w300,1234567890`nabcdefghijklm`nnopqrstuvwxyz
gui Font,cGreen
gui Add,Edit,r4 w300,Apple`nBanana`nPeach`nPineapple`nPlum`nStrawberry
gui Font,cBlue
gui Add,Edit,r4 w300,Red`nGreen`nBlue`nYellow`nCyan`nMagenta`nBlack`nWhite
gui Font

SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,,%$ScriptTitle%

;-- Instructions
gui +OwnDialogs
MsgBox
    ,0x40   ;-- 0x0 (OK button) + 0x40 (Info icon)
    ,Instructions,
       (ltrim join`s
        Select one or more characters from any of the edit fields and drag to
        the same or any other edit field.
       )

return

GUIClose:
GUIEscape:
ExitApp


LButtonDown(wParam,lParam,Msg,hWnd)
    {
    Global c,c1,c2,cH,cW,cX,cY,hEdit1
    MouseGetPos mX,mY,,Ctrl                         ; Info about pointer location
    if (SubStr(Ctrl,1,4)<>"Edit")                   ; Bounce if not Edit control
        return

    hEdit1:=hWnd
    ControlGetPos cX,cY,cW,cH,,ahk_id %hEdit1%      ; Top-left corner, Width, Height of Ctrl
    c:=Edit_CharFromPos(hEdit1,mX-cX,mY-cY)         ; Char# nearest to mouse
    Edit_GetSel(hEdit1,c1,c2)                       ; GetSel
    if (c<c1 or c2<=c)                              ; Clicked outside of selection
        return                                      ; Continue with standard mouse action

    SetTimer Cursor,100                             ; Flash selection, Show insertion point
    Return 0                                        ; No further handling of click
    }


LButtonUp(wParam,lParam,Msg,hEdit2)
    {
    Global c,c1,c2,cH,cW,cX,cY,hEdit1
    SetTimer Cursor,Off                             ; Stop flashing selection, insertion point
    MouseGetPos mX,mY,Win1,Ctrl                     ; Pointer location
    if (SubStr(Ctrl,1,4)<>"Edit")                   ; Bounce if not Edit control
        return

    CtState:=GetKeyState("Ctrl")
    if (hEdit1<>hEdit2)                             ; Drag to another edit control
        {
        Edit_SetSel(hEdit1,c1,c2)                   ; Re-select flashing text
        T:=Edit_GetSelText(hEdit1)                  ; Get selected text
        if !CtState                                 ; Drag moves, Ctrl-Drag duplicates
            Edit_ReplaceSel(hEdit1,"",False)        ; Clear selection.  No undo

        ControlGetPos cX1,cY1,,,,ahk_id %hEdit2%    ; Top-left corner
        c:=Edit_CharFromPos(hEdit2,mX-cX1,mY-cY1)   ; Char# nearest to mouse
        Edit_SetSel(hEdit2,c,c)                     ; SetSel mouse -> insertion point
        Edit_ReplaceSel(hEdit2,T,True)              ; Replace selection. Can Undo
        Edit_SetSel(hEdit2,c,c+c2-c1)               ; SetSel select moved text
        ControlFocus,,ahk_id %hEdit2%               ; Focus to new control
        Return
        }

    if (c<c1 or c2<=c)                              ; Clicked outside of selection
        Return

    c:=Edit_CharFromPos(hEdit2,mX-cX,mY-cY)         ; Char# nearest to mouse
    if (c1<=c and c<c2)                             ; Pointer still in selection
        Return                                      ; No further mouse action

    tp:=Edit_GetFirstVisibleLine(hEdit1)            ; GetFirstVisibleLine Top of Ctrl
    Edit_SetSel(hEdit1,c1,c2)                       ; SetSel re-select
    T:=Edit_GetSelText(hEdit1)                      ; Save selected text
    if !CtState                                     ; Drag moves, Ctrl-Drag duplicates
        Edit_ReplaceSel(hEdit1,"",False)            ; Clear selection. Cannot undo

    if (!CtState and c1<c)                          ; Deleted text moves insertion point
        c:=c+c1-c2

    Edit_SetSel(hEdit1,c,c)                         ; SetSel mouse -> insertion point
    Edit_ReplaceSel(hEdit1,T,True)                  ; ReplaceSel = insert T. Can undo.
    Edit_SetSel(hEdit1,c,c+c2-c1)                   ; SetSel select moved text
    Edit_Scroll(hEdit1,0,tp-Edit_GetFirstVisibleLine(hEdit1))
                                                    ; Scroll to restore line positions
    }

Cursor:                                             ; Flashing selection + caret
    MouseGetPos mX,mY                               ; Pointer location
    v:=(mY-cY>cH)-(mY-cY<0)                         ; Up/Down: -1/1
    h:=(mX-cX>cW)-(mX-cX<0)                         ; Left/Right: -1/1
    Edit_Scroll(hEdit1,h,v)                         ; Scroll
    if A_TickCount & 256                            ; Flash
        Edit_SetSel(hEdit1,c1,c2)
    else
        {
        d:=Edit_CharFromPos(hEdit1,mX-cX,mY-cY)     ; Char# nearest to mouse
        Edit_SetSel(hEdit1,d,d)                     ; Select
        }

return


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%\_Functions
#include Edit.ahk
