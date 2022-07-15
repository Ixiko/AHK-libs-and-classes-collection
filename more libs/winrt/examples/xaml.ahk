#include ..\windows.ahk

ShowExampleGui

ShowExampleGui() {
    xg := BasicXamlGui('+Resize')
    
    ; Xaml follows the user's dark mode preference by default, but the window frame
    ; is pure Win32, so we need to handle that unless we want black-on-white:
    DarkModeIsActive() && SetDarkWindowFrame(xg.hwnd, true)
    ; An alternative strategy is to request the light theme for Xaml:
    ; Windows.UI.Xaml.Application.Current.RequestedTheme := 'Light'
    
    xg.Content := stk := Windows.UI.Xaml.Markup.XamlReader.Load("
    (
        <StackPanel xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Margin="10" Spacing="10">
            <TextBlock Text="AutoHotkey version: ">
                <Run Name="Version" Text="" Foreground="#0080ff"/>
            </TextBlock>
            <TextBox Name="Box"/>
            <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" Spacing="10">
                <Button Name="OK" Content="OK" Width="100"/>
                <Button Name="Cancel" Content="Cancel" Width="100"/>
            </StackPanel>
        </StackPanel>
    )")
    
    ; xg['Version'] just calls xg.Content.FindName('Version'), and xg.Content = stk.
    xg['Version'].Text := A_AhkVersion
    
    ; Note that the anonymous closure below captures xg, which prevents it from being
    ; deleted while the Xaml event is still registered. This isn't a big issue for this
    ; example because closing the GUI will still cause the script to exit.
    xg['OK'].add_Click((btn, args) => (
        xg.Hide(),
        MsgBox("Input: " xg['Box'].Text)
    ))
    
    xg['Cancel'].add_Click((btn, args) => (
        xg.Hide()
    ))
    
    sz := Windows.Foundation.Size()
    sz.Width := 600
    sz.Height := 200
    stk.Measure(sz)
    
    xg.Show("w600 h" (stk.DesiredSize.Height * A_ScreenDPI / 96))
    
    xg.NavigateFocus('First')
}

class BasicXamlGui extends Gui {
    __new(opt:='', title:=unset) {
        super.__new(opt ' -DPIScale', IsSet(title) ? title : A_ScriptName, this)
        
        this.OnEvent('Size', '_OnSize')
        
        static _ := (
            OnMessage(0x100, BasicXamlGui._OnKeyDown.Bind(BasicXamlGui)),
            OnMessage(0x102, BasicXamlGui._OnChar.Bind(BasicXamlGui))
        )
        
        this._dwxs := dwxs := Windows.UI.Xaml.Hosting.DesktopWindowXamlSource()
        
        ; IDesktopWindowXamlSourceNative is a traditional COM interface.
        dwxsn := ComObjQuery(dwxs, '{3cbcf1bf-2f76-4e9c-96ab-e84b37972554}')
        ComCall(AttachToWindow := 3, dwxsn, 'ptr', this.hwnd)
        ComCall(get_WindowHandle := 4, dwxsn, 'ptr*', &xwnd := 0)
        this._xwnd := xwnd
    }
    
    Content {
        get => this._dwxs.Content
        set => this._dwxs.Content := value
    }
    
    __Item[name] => this._dwxs.Content.FindName(name) ; FIXME: needs WinRT() to "down-cast" from UIElement to actual class
    
    ; reason: https://docs.microsoft.com/en-us/uwp/api/windows.ui.xaml.hosting.xamlsourcefocusnavigationreason?view=winrt-22621
    NavigateFocus(reason) =>
        this._dwxs.NavigateFocus(
            Windows.UI.Xaml.Hosting.XamlSourceFocusNavigationRequest(reason))
    
    _OnSize(minMax, width, height) {
        ; Must use SetWindowPos! Does not work with ControlMove+ControlShow!
        DllCall('SetWindowPos', 'ptr', this._xwnd, 'ptr', 0
            , 'int', 0, 'int', 0, 'int', width, 'int', height, 'int', 0x40)
    }
    
    static _OnKeyDown(wParam, lParam, nmsg, hwnd) {
        if !(wnd := GuiFromHwnd(hwnd, true)) || !(wnd is BasicXamlGui)
            return
        try
            native2 := ComObjQuery(wnd._dwxs, "{e3dcd8c7-3057-4692-99c3-7b7720afda31}")
        catch ; Older than Windows 10 v1903?
            return
        kmsg := Buffer(48, 0)
        NumPut('ptr', hwnd, 'ptr', nmsg, 'ptr', wParam, 'ptr', lParam
            , 'uint', A_EventInfo, kmsg)
        ; IDesktopWindowXamlSourceNative2::PreTranslateMessage
        ComCall(5, native2, 'ptr', kmsg, 'int*', &processed:=false)
        if processed
            return 0
    }
    
    static _OnChar(wParam, lParam, nmsg, hwnd) {
        if !(wnd := GuiFromHwnd(hwnd, true)) || !(wnd is BasicXamlGui)
            return
        ; Xaml islands (tested on 10.0.22000) do not respond to WM_GETDLGCODE
        ; correctly, so WM_CHAR messages are consumed by IsDialogMessage() and
        ; not dispatched to the island unless we do it directly.
        if WinGetClass(hwnd) = 'Windows.UI.Input.InputSite.WindowClass'
            return SendMessage(nmsg, wParam, lParam, hwnd)
    }
}

DarkModeIsActive() {
    return isColorLight(Windows.UI.ViewManagement.UISettings().GetColorValue('Foreground'))
    ; Algorithm from https://docs.microsoft.com/en-us/windows/apps/desktop/modernize/apply-windows-themes
    isColorLight(clr) =>
        ((5 * clr.G) + (2 * clr.R) + clr.B) > (8 * 128)
}

SetDarkWindowFrame(hwnd, dark) {
    if VerCompare(A_OSVersion, "10.0.17763") >= 0 {
        attr := 19
        if VerCompare(A_OSVersion, "10.0.18985") >= 0
            attr := 20 ; DWMWA_USE_IMMERSIVE_DARK_MODE is officially defined for 10.0.22000 as 20.
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", hwnd, "int", attr, "int*", dark, "int", 4)
    }
}
