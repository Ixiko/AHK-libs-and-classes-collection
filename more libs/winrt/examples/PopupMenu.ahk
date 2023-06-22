/*
  This script demonstrates the PopupMenu class. Keep your expectations low:
  it can only show up to 6 textual items, with no submenus, controls or graphics.
  More generally, it demonstrates:
    - Construct WinRT objects with/without parameters.
    - Pass an AutoHotkey bound function to a WinRT method.
    - Use the IInitializeWithWindow COM interface to establish HWND context.
    - Construct a struct (Windows.Foundation.Point).
    - Wait for an async operation to complete and get its result.
*/

#include ..\windows.ahk

ShowDemoMenuGui

ShowDemoMenuGui() {
    demoGui := Gui(, "PopupMenu demo window")
    demoGui.SetFont('s11')
    demoGui.AddText('w600 h400', "Right-click inside this window to show a PopupMenu.")
    demoGui.OnEvent('ContextMenu', ShowDemoMenu)
    demoGui.Show()
}

ShowDemoMenu(demoGui, *) {
    ; Create an alias for convenience and performance
    Popups := Windows.UI.Popups
    
    ; Create a PopupMenu
    pm := Popups.PopupMenu()
    
    ; Add 6 sample items (6 is the maximum)
    for fn in [ListVars, ListLines, Edit, Pause, Reload, ExitApp] {
        ; Create a UICommand, passing a bound function
        uiCommand := Popups.UICommand(fn.Name, invokeItem.Bind(fn))
        ; Add the UICommand
        pm.Commands.Append(uiCommand)
    }
    
    ; Give the PopupMenu an owner window (it's mandatory)
    InitializeWithWindow(pm, demoGui.Hwnd)
    
    ; Make a point...
    pt := Windows.Foundation.Point()
    MouseGetPos &x, &y
    pt.X := x * 96 / A_ScreenDPI
    pt.Y := y * 96 / A_ScreenDPI
    
    ; Show the PopupMenu
    ao := pm.ShowAsync(pt)
    
    ; We could return at this point, since we're using a callback.
    ; This next part shows one way to deal with IAsyncOperation.
    
    ; Wait on the IAsyncOperation<IUICommand>
    loop
        sleep 10
    until ao.status.n
    ; Get the selected UICommand (or "" for null)
    uiCommand := ao.GetResults()
    if uiCommand
        demoGui['Static1'].Text .= "`nGetResults returned command: " uiCommand.Label
    else
        demoGui['Static1'].Text := "No command was selected."
    
    invokeItem(fn, uiCommand) {
        demoGui['Static1'].Text := "Callback received command: " uiCommand.Label
        fn()
    }
}

InitializeWithWindow(obj, hwnd) {
    ; Get IInitializeWithWindow interface
    iww := ComObjQuery(obj, '{3E68D4BD-7135-4D10-8018-9FB6D9F33FA1}')
    ; Call IInitializeWithWindow::Initialize()
    ComCall(3, iww, 'ptr', hwnd)
}