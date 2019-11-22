;Include the Library
#Include ../XBOX360.ahk

;Instance the Controller Manager
manager := new Xbox360LibControllerManager()

;Initialize Controller (0-3), you can use 4 controllers
player1 := manager.InitializeController(0)


;Make something useful
Loop {
    msg := ""
;Update state of controller

    player1.Update()

    if (player1.GUIDE) {
        msg .= "Player One Press Guide`n"
    }

    if (player1.BACK) {
        msg .= "Player One Press Back`n"
    }

    if (player1.START) {
        msg .= "Player One Press Start`n"
    }

    if (player1.UP) {
        msg .= "Player One Press Up`n"
    }

    if (player1.DOWN) {
        msg .= "Player One Press Down`n"
    }

    if (player1.LEFT) {
        msg .= "Player One Press Left`n"
    }

    if (player1.RIGHT) {
        msg .= "Player One Press Right`n"
    }

    if (player1.A) {
        msg .= "Player One Press A`n"
    }

    if (player1.B) {
        msg .= "Player One Press B`n"
    }

    if (player1.X) {
        msg .= "Player One Press X`n"
    }

    if (player1.Y) {
        msg .= "Player One Press Y`n"
    }

    if (player1.LB) {
        msg .= "Player One Press LB`n"
    }

    if (player1.RB) {
        msg .= "Player One Press RB`n"
    }

    if (value := player1.LT) {
        msg .= "Player One Press LT, Analog Value : " . value . " (0-255)`n"
    }

    if (value := player1.RT) {
        msg .= "Player One Press RT`, Analog Value : " . value . " (0-255)`n"
    }

    if (value := player1.LV) {
        msg .= "Left Motor Speed : " . value . "`n"
    }

    if (value := player1.RV) {
        msg .= "Right Motor Speed : " . value . "`n"
    }

    if (value := player1.BV && (value[0] || value[1])) {
        msg .= " Both Motor Speed, Left: " . value[1] . ", Right: " . value[2] . "`n"
    }

;Left Stick
    if (player1.LS) {
        msg .= "Player One Press LS`n"
    }

;Right Stick
    if (player1.RS) {
        msg .= "Player One Press RS`n"
    }

;Left Stick X(Left/Right) Movement
    if (value := player1.LSX) {
        asDigital := player1.LSX < 0 ? "Left" : "Right"
        msg .= "Player One Move Left Sick In X Axis, Analog Value : " . value . ", Digital: " . asDigital . "`n"
    }

;Left Stick Y(Up/Down) Movement
    if (value := player1.LSY) {
        asDigital := player1.LSY > 0 ? "Up" : "Down"
        msg .= "Player One Move Left Sick In Y Axis, Analog Value : " . value . ", Digital: " . asDigital . "`n"
    }

;Right Stick X(Left/Right) Movement
    if (value := player1.RSX) {
        asDigital := player1.RSX < 0 ? "Left" : "Right"
        msg .= "Player One Move Right Sick In X Axis, Analog Value : " . value . ", Digital: " . asDigital . "`n"
    }

;Right Stick Y(Up/Down) Movement
    if (value := player1.RSY) {
        asDigital := player1.RSY > 0 ? "Up" : "Down"
        msg .= "Player One Move Right Sick In Y Axis, Analog Value : " . value . ", Digital: " . asDigital . "`n"
    }

;Vibration, Move Left And Right sticks
    leftMotorSpeed := Ceil((Abs(player1.LSY) + Abs(player1.LSX)) / 64932 * 65532)
    rightMotorSpeed := Ceil((Abs(player1.RSY) + Abs(player1.RSX)) / 64932 * 65532)
    player1.BV := [leftMotorSpeed, rightMotorSpeed]
    if (msg)
        msg .= "Player One Battery Level: " manager.xinput.GetGamepadBatteryLevelName(0) "`n"
    ToolTip, %msg%
    Sleep 5
}