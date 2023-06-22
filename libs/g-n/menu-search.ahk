SetBatchLines -1
OnMessage(0x100, "GuiKeyDown")
OnMessage(0x6, "GuiActivate")
return

Alt::
Gui +LastFoundExist
if WinActive()
    goto GuiEscape
Gui Destroy
Gui Font, s11
Gui Margin, 0, 0
Gui Add, Edit, x20 w500 vQuery gType
Gui Add, Text, x5 y+2 w15, 1`n2`n3`n4`n5`n6`n7`n8`n9
Gui Add, ListBox, x+0 yp-2 w500 r21 vCommand gSelect AltSubmit
Gui Add, StatusBar
Gui +ToolWindow +Resize +MinSize +MinSize200x +MaxSize +MaxSize%A_ScreenWidth%x
window := WinExist("A")
if !(cmds := MenuGetAll(window))
{
    Send {Alt}
    return
}
gosub Type
WinGetTitle title, ahk_id %window%
title := RegExReplace(title, ".* - ")
Gui Show,, Searching menus of:  %title%
GuiControl Focus, Query
return

Type:
SetTimer Refresh, -10
return

Refresh:
GuiControlGet Query
r := cmds
if (Query != "")
{
    StringSplit q, Query, %A_Space%
    Loop % q0
        r := Filter(r, q%A_Index%, c)
}
rows := ""
row_id := []
Loop Parse, r, `n
{
    RegExMatch(A_LoopField, "(\d+)`t(.*)", m)
    row_id[A_Index] := m1
    rows .= "|"  m2
}
GuiControl,, Command, % rows ? rows : "|"
if (Query = "")
    c := row_id.MaxIndex()

Select:
GuiControlGet Command
if !Command
    Command := 1
Command := row_id[Command]
SB_SetText("Total " c " results`t`tID: " Command)
if (A_GuiEvent != "DoubleClick")
    return

Confirm:
if !GetKeyState("Shift")
{
    gosub GuiEscape
    WinActivate ahk_id %window%
}
DllCall("SendNotifyMessage", "ptr", window, "uint", 0x111, "ptr", Command, "ptr", 0)
return

GuiEscape:
Gui Destroy
cmds := r := ""
return

GuiSize:
GuiControl Move, Query, % "w" A_GuiWidth-20
GuiControl Move, Command, % "w" A_GuiWidth-20
return

GuiActivate(wParam)
{
    if (A_Gui && wParam = 0)
        SetTimer GuiEscape, -5
}

GuiKeyDown(wParam, lParam)
{
    if !A_Gui
        return
    if (wParam = GetKeyVK("Enter"))
    {
        gosub Confirm
        return 0
    }
    if (wParam = GetKeyVK(key := "Down")
     || wParam = GetKeyVK(key := "Up"))
    {
        GuiControlGet focus, FocusV
        if (focus != "Command")
        {
            GuiControl Focus, Command
            if (key = "Up")
                Send {End}
            else
                Send {Home}
            return 0
        }
        return
    }
    if (wParam >= 49 && wParam <= 57 && !GetKeyState("Shift"))
    {
        SendMessage 0x18E,,, ListBox1
        GuiControl Choose, Command, % wParam-48 + ErrorLevel
        GuiControl Focus, Command
        gosub Select
        return 0
    }
    if (wParam = GetKeyVK(key := "PgUp")
     || wParam = GetKeyVK(key := "PgDn"))
    {
        GuiControl Focus, Command
        Send {%key%}
        return
    }
}

Filter(s, q, ByRef count)
{
    if (q = "")
    {
        StringReplace s, s, `n, `n, UseErrorLevel
        count := ErrorLevel
        return s
    }
    i := 1
    match := ""
    result := ""
    count := 0
    while i := RegExMatch(s, "`ami)^.*\Q" q "\E.*$", match, i + StrLen(match))
    {
        result .= match "`n"
        count += 1
    }
    return SubStr(result, 1, -1)
}

MenuGetAll(hwnd)
{
    if !menu := DllCall("GetMenu", "ptr", hwnd, "ptr")
        return ""    
    MenuGetAll_sub(menu, "", cmds)
    return cmds
}

MenuGetAll_sub(menu, prefix, ByRef cmds)
{
    Loop % DllCall("GetMenuItemCount", "ptr", menu)
    {
        VarSetCapacity(itemString, 2000)
        if !DllCall("GetMenuString", "ptr", menu, "int", A_Index-1, "str", itemString, "int", 1000, "uint", 0x400)
            continue
        StringReplace itemString, itemString, &
        itemID := DllCall("GetMenuItemID", "ptr", menu, "int", A_Index-1)
        if (itemID = -1)
        if subMenu := DllCall("GetSubMenu", "ptr", menu, "int", A_Index-1, "ptr")
        {
            MenuGetAll_sub(subMenu, prefix itemString " > ", cmds)
            continue
        }
        cmds .= itemID "`t" prefix RegExReplace(itemString, "`t.*") "`n"
    }
}