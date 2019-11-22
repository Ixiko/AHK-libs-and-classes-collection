#NoEnv
#Include ../XBOX360.ahk

x360 := []

manager :=  new Xbox360LibControllerManager()

loop 4 {
    x360[A_Index -1] := manager.InitializeController(A_Index -1)
}

CoordMode, ToolTip, Screen

loop {
    x := 0
    msg := ""
    while x < 4 {
        control := x360[x]
        control.Update()
        msg .= "Player" . (x+1) . "`n"
        msg .= "Connected: " . (control.IsConnected ? "Yes" : "No") . "`n"
        if (control.IsConnected) {
            msg .= "GUIDE: " . control.GUIDE . "`n"
            msg .= "START: " . control.START . "`n"
            msg .= "BACK: "  . control.BACK  . "`n"
            msg .= "UP: "    . control.UP    . "`n"
            msg .= "DOWN: "  . control.DOWN  . "`n"
            msg .= "LEFT: "  . control.LEFT  . "`n"
            msg .= "RIGHT: " . control.RIGHT . "`n"
            msg .= "A: "     . control.A     . "`n"
            msg .= "B: "     . control.B     . "`n"
            msg .= "X: "     . control.X     . "`n"
            msg .= "Y: "     . control.Y     . "`n"
            msg .= "LB: "    . control.LB    . "`n"
            msg .= "RB: "    . control.RB    . "`n"
            msg .= "LT: "    . control.LT    . "`n"
            msg .= "RT: "    . control.RT    . "`n"
            msg .= "LS: "    . control.LS    . "`n"
            msg .= "RS: "    . control.RS    . "`n"
            msg .= "LSX: "   . control.LSX   . "`n"
            msg .= "LSY: "   . control.LSY   . "`n"
            msg .= "RSX: "   . control.RSX   . "`n"
            msg .= "RSY: "   . control.RSY   . "`n"
        }
        msg .= "`n"
        x++
    }
    ToolTip, %msg%, 0, 500 
}
