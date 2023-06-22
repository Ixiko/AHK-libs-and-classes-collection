    OnExit(ObjBindMethod(eReader, "Cleanup"))
    Global __Handles := {}
    New eReader

    Exit ; End of AES

    ^Right::eReader.Next()
    ^Left::eReader.Previous()


    ;
    ;          /$$$$$$$                            /$$
    ;          | $$__  $$                          | $$
    ;  /$$$$$$ | $$  \ $$  /$$$$$$   /$$$$$$   /$$$$$$$  /$$$$$$   /$$$$$$
    ; /$$__  $$| $$$$$$$/ /$$__  $$ |____  $$ /$$__  $$ /$$__  $$ /$$__  $$
    ;| $$$$$$$$| $$__  $$| $$$$$$$$  /$$$$$$$| $$  | $$| $$$$$$$$| $$  \__/
    ;| $$_____/| $$  \ $$| $$_____/ /$$__  $$| $$  | $$| $$_____/| $$
    ;|  $$$$$$$| $$  | $$|  $$$$$$$|  $$$$$$$|  $$$$$$$|  $$$$$$$| $$
    ; \_______/|__/  |__/ \_______/ \_______/ \_______/ \_______/|__/
    ;
    ;
    ;
    ;              /$$$$$$  /$$
    ;             /$$__  $$| $$
    ;            | $$  \__/| $$  /$$$$$$   /$$$$$$$ /$$$$$$$
    ;            | $$      | $$ |____  $$ /$$_____//$$_____/
    ;            | $$      | $$  /$$$$$$$|  $$$$$$|  $$$$$$
    ;            | $$    $$| $$ /$$__  $$ \____  $$\____  $$
    ;            |  $$$$$$/| $$|  $$$$$$$ /$$$$$$$//$$$$$$$/
    ;             \______/ |__/ \_______/|_______/|_______/
    ;
    ;                         By Casper Harkin 31/07/2020


    Class eReader {

        __New() {

            ; Remove title bar and a thick window border/edge and set the GUI to be AlwaysOnTop
            Gui, -Caption +AlwaysOnTop
            ; Make GUI Background White (0xFFFFFF)
            Gui Color, FFFFFF
            ; Adding Edit Control with Handle saved as hDisplayEditControl
            Gui Add, Edit,  w185 h117 -E0x200 +Multi +HwndhDisplayEditControl
            ; Showing the GUI using Coordinates bassed on the Parent GUI (PDR Toolbar)
            Gui, Show, x5 y552,

            ; Because this is inside a class, we have to bind ContextMenuHandler to BoundMenu
            ; so we can reference it when pointing our menus to This.ContextMenuHandler
            BoundMenu := this.ContextMenuHandler.bind(this)

            ; Building the Menu Items and Icons
            Menu FileMenu, Add, Show/Hide IE Window, % BoundMenu
            Menu, FileMenu, Icon, Show/Hide IE Window, % A_WinDir . "\System32\SHELL32.dll", 14
            Menu FileMenu, Add, ; Spacer in Menu
            Menu FileMenu, Add, Close eReader, % BoundMenu
            Menu, FileMenu, Icon, Close eReader, % A_WinDir . "\System32\SHELL32.dll", 28


            This.SetParentByTitle("PDR Toolbar",1)

            __Handles.wb := ComObjCreate("InternetExplorer.Application")
            __Handles.wb.Visible := 0
            __Handles.hDisplayEditControl := hDisplayEditControl

            IniRead, navURL, % "C:\Settings.ini", General, navURL
            IniRead, Inner, % "C:\Settings.ini", General, Inner

            InputBox, navURL, URL, Please Enter the URL.,,,,,,,,%navURL%

            __Handles.wb.Navigate(navURL)

            This.LoadPage()
            This.InnerText()

            OnMessage(0x202, ObjBindMethod(this,"WM_LBUTTONUP"))
        }

        ContextMenuHandler() {

            If (A_ThisMenuItem = "Show/Hide IE Window") {
                If (__Handles.wb.Visible = 0)
                    __Handles.wb.Visible := 1
                Else
                    __Handles.wb.Visible := 0
            }

            If (A_ThisMenuItem = "Close eReader") {
                This.Cleanup()
                ExitApp
            }
        }

        WM_LBUTTONUP(wParam, lParam, Msg, Hwnd) {
            DllCall("TrackMouseEvent", "UInt", &TME)
            MouseGetPos,,,, MouseCtrl, 2
            If (KeyIsDown := GetKeyState("Shift","p")) {
                If (MouseCtrl = __Handles.hDisplayEditControl) {
                    ControlGetPos, ctlX, ctlY, ctlW, ctlH, , % "ahk_id " __Handles.hDisplayEditControl
                    Menu, FileMenu, Show, %ctlX%, % ctlY + ctlH
                }
            }
        }

        Next() {
            __Handles.wb.document.getElementById("next_chap").click()
            This.LoadPage()
            navURL := __Handles.wb.LocationURL
            IniWrite, % navURL, % "C:\Settings.ini", General, navURL
            This.InnerText()
        }

        Previous() {
            __Handles.wb.document.getElementById("prev_chap").click()
            This.LoadPage()
            navURL := __Handles.wb.LocationURL
            IniWrite, % navURL, % "C:\Settings.ini", General, navURL
            This.InnerText()
        }

        InnerText() {
            guicontrol, text, % __Handles.hDisplayEditControl, % text := __Handles.wb.document.getElementById("chapter-content").innerText
        }

        LoadPage() {
            While __Handles.wb.readyState != 4 || __Handles.wb.document.readyState != "complete" || __Handles.wb.busy
                Sleep, 20
        }

        Cleanup() {
            DetectHiddenWindows On
            __Handles.wb.quit
            DetectHiddenWindows Off
        }

        SetParentByTitle(Window_Title_Text, Gui_Number) {
            WinGetTitle, Window_Title_Text_Complete, %Window_Title_Text%
            Parent_Handle := DllCall( "FindWindowEx", "uint",0, "uint",0, "uint",0, "str", Window_Title_Text_Complete)
            Gui, %Gui_Number%: +LastFound
            Return DllCall( "SetParent", "uint", WinExist(), "uint", Parent_Handle )
        }
    }
