Xbox360Lib := {}

Xbox360Lib.Enum := {}

Xbox360Lib.Enum.Buttons := {}
Xbox360Lib.Enum.Buttons.UP    := 1
Xbox360Lib.Enum.Buttons.DOWN  := 2
Xbox360Lib.Enum.Buttons.LEFT  := 3
Xbox360Lib.Enum.Buttons.RIGHT := 4
Xbox360Lib.Enum.Buttons.START := 5
Xbox360Lib.Enum.Buttons.BACK  := 6
Xbox360Lib.Enum.Buttons.GUIDE := 7
Xbox360Lib.Enum.Buttons.A     := 8
Xbox360Lib.Enum.Buttons.B     := 9
Xbox360Lib.Enum.Buttons.X     := 10
Xbox360Lib.Enum.Buttons.Y     := 11
Xbox360Lib.Enum.Buttons.LS    := 12
Xbox360Lib.Enum.Buttons.RS    := 13
Xbox360Lib.Enum.Buttons.LB    := 14
Xbox360Lib.Enum.Buttons.RB    := 15
Xbox360Lib.Enum.Buttons.LT    := 16
Xbox360Lib.Enum.Buttons.RT    := 17
Xbox360Lib.Enum.Buttons.LSX   := 18
Xbox360Lib.Enum.Buttons.LSY   := 29
Xbox360Lib.Enum.Buttons.RSX   := 20
Xbox360Lib.Enum.Buttons.RSY   := 21


Xbox360Lib.Enum.XInputStateButtons := {}
Xbox360Lib.Enum.XInputStateButtons[Xbox360Lib.Enum.Buttons.UP]    := 0x0001
Xbox360Lib.Enum.XInputStateButtons[Xbox360Lib.Enum.Buttons.DOWN]  := 0x0002
Xbox360Lib.Enum.XInputStateButtons[Xbox360Lib.Enum.Buttons.LEFT]  := 0x0004 
Xbox360Lib.Enum.XInputStateButtons[Xbox360Lib.Enum.Buttons.RIGHT] := 0x0008
Xbox360Lib.Enum.XInputStateButtons[Xbox360Lib.Enum.Buttons.START] := 0x0010
Xbox360Lib.Enum.XInputStateButtons[Xbox360Lib.Enum.Buttons.BACK]  := 0x0020
Xbox360Lib.Enum.XInputStateButtons[Xbox360Lib.Enum.Buttons.LS]    := 0x0040
Xbox360Lib.Enum.XInputStateButtons[Xbox360Lib.Enum.Buttons.RS]    := 0x0080
Xbox360Lib.Enum.XInputStateButtons[Xbox360Lib.Enum.Buttons.LB]    := 0x0100
Xbox360Lib.Enum.XInputStateButtons[Xbox360Lib.Enum.Buttons.RB]    := 0x0200
Xbox360Lib.Enum.XInputStateButtons[Xbox360Lib.Enum.Buttons.GUIDE] := 0x0400
Xbox360Lib.Enum.XInputStateButtons[Xbox360Lib.Enum.Buttons.A]     := 0x1000
Xbox360Lib.Enum.XInputStateButtons[Xbox360Lib.Enum.Buttons.B]     := 0x2000
Xbox360Lib.Enum.XInputStateButtons[Xbox360Lib.Enum.Buttons.X]     := 0x4000
Xbox360Lib.Enum.XInputStateButtons[Xbox360Lib.Enum.Buttons.Y]     := 0x8000

Xbox360Lib.Enum.XInputStateGamepad := {}
Xbox360Lib.Enum.XInputStateGamepad[Xbox360Lib.Enum.Buttons.LT]  := {code: 6,  type: "UChar"}
Xbox360Lib.Enum.XInputStateGamepad[Xbox360Lib.Enum.Buttons.RT]  := {code: 7,  type: "UChar"}
Xbox360Lib.Enum.XInputStateGamepad[Xbox360Lib.Enum.Buttons.LSX] := {code: 8,  type: "Short"}
Xbox360Lib.Enum.XInputStateGamepad[Xbox360Lib.Enum.Buttons.LSY] := {code: 10, type: "Short"}
Xbox360Lib.Enum.XInputStateGamepad[Xbox360Lib.Enum.Buttons.RSX] := {code: 12, type: "Short"}
Xbox360Lib.Enum.XInputStateGamepad[Xbox360Lib.Enum.Buttons.RSY] := {code: 14, type: "Short"}

Xbox360Lib.Enum.Threshold := {}
Xbox360Lib.Enum.Threshold[Xbox360Lib.Enum.Buttons.LT] := 30
Xbox360Lib.Enum.Threshold[Xbox360Lib.Enum.Buttons.RT] := 30

Xbox360Lib.Enum.Deadzone := {}
Xbox360Lib.Enum.Deadzone[Xbox360Lib.Enum.Buttons.LSX] := 7849
Xbox360Lib.Enum.Deadzone[Xbox360Lib.Enum.Buttons.LSY] := 7849
Xbox360Lib.Enum.Deadzone[Xbox360Lib.Enum.Buttons.RSX] := 8689
Xbox360Lib.Enum.Deadzone[Xbox360Lib.Enum.Buttons.RSY] := 8689

Xbox360Lib.Enum.Motor := {}
Xbox360Lib.Enum.Motor.LV := 1
Xbox360Lib.Enum.Motor.RV := 2
Xbox360Lib.Enum.Motor.BV := 3


Class Xbox360LibXInputVibration {
    leftMotorSpeed  := 0
    rightMotorSpeed := 0
    raw             :=
    address         :=
    
    __New() {
        this.SetCapacity("raw", 4)
        this.address := this.GetAddress("raw")
    }

    ParseToBinaryFormat() {
        NumPut(this.leftMotorSpeed, this.address,  0, "UShort")
        NumPut(this.rightMotorSpeed, this.address, 2, "UShort")
        return this
    }
}

Class Xbox360LibXInput {
    moduleAddress                :=
    getStateAddress              :=
    getKeystrokeAddress          :=
    getBatteryInformationAddress :=
    setStateAddress              :=
    powerOffControllerAddress    :=
	dllNames := ["Xinput1_4", "Xinput1_3", "Xinput_9_1_0"]
	
    __New() {
        this.LoadLibrary()
        this.getStateAddress              := DllCall("GetProcAddress" ,"UPtr", this.moduleAddress ,"UInt", 100, "UPtr")
        this.getKeystrokeAddress          := DllCall("GetProcAddress" ,"UPtr", this.moduleAddress ,"AStr", "XInputGetKeystroke", "UPtr")
        this.getBatteryInformationAddress := DllCall("GetProcAddress" ,"UPtr", this.moduleAddress ,"AStr", "XInputGetBatteryInformation", "UPtr")
        this.setStateAddress              := DllCall("GetProcAddress" ,"UPtr", this.moduleAddress ,"AStr", "XInputSetState", "UPtr")
        this.powerOffControllerAddress    := DllCall("GetProcAddress" ,"UPtr", this.moduleAddress ,"UInt", 103, "UPtr")
    }

    /**
     * @return int
     */
    GetState(index, stateOutAddress) {
        return DllCall(this.getStateAddress, "UInt", index, "UPtr", stateOutAddress)
    }

    /**
     * @return int
     */
    GetKeystroke(index, keystrokeOutAddress) {
        return DllCall(this.getKeystrokeAddress, "UInt", index, "UInt", 0, "UPtr", keystrokeOutAddress)
    }

    /**
     * @return int
     */
    GetBatteryInformation(index, type, batteryOutAddress) {
        return DllCall(this.getBatteryInformationAddress, "UInt", index, "UChar", type, "UPtr", batteryOutAddress)
    }
 
    /**
     * @return int
     */ 
	GetGamepadBatteryLevelValue(index) {
		VarSetCapacity(batteryOutAddress, 2)
		if (this.GetBatteryInformation(index, 0, &batteryOutAddress) == 0)
			return NumGet(batteryOutAddress, 1, "UChar")
		else
			return -1   ; -1 for "Unknown", different to 0 for "Empty"
	}
    
    /**
     * @return string
     */
    GetGamepadBatteryLevelName(index) {
        static names := {-1: "Unknown", 0: "Empty", 1: "Low", 2: "Medium", 3: "Full"}
        return names[this.GetGamepadBatteryLevelValue(index)]
    }
    
    /**
     * @return int
     */
	SetState(index, xvibration) {
 		return DllCall(this.setStateAddress, "UInt", index, "UInt", xvibration.ParseToBinaryFormat().address)
	}

    /**
     * @return int
     */
    CallPowerOffController(index) {
        return DllCall(this.powerOffControllerAddress, "UInt", index)
    }    

    /**
     * @return void
     */
    LoadLibrary() {
        For key, dllname in this.dllNames
        {
            this.moduleAddress := DllCall("LoadLibrary", "Str", dllname, "UPtr")
            if(this.moduleAddress) {
                break
            }
        }

        if(!this.moduleAddress) {
            throw "not found xinput dll"
        }
    }
    
    FreeLibrary() {
        DllCall("FreeLibrary", "UPtr", this.moduleAddress)
    }
}

Class Xbox360LibController {

    index      :=
    state      :=
    wbuttons   :=
    error      :=
    deadzone   :=
    threshold  :=
    xgamepad   :=
    xbuttons   :=
    buttons    :=
    xinput     :=
    xvibration :=
    motor      :=

    __New(index, xinput) {
        global Xbox360Lib
        this.motor      := Xbox360Lib.Enum.Motor        
        this.index      := index
        this.xinput     := xinput
        this.xvibration := new Xbox360LibXInputVibration()
        this.deadzone   := Xbox360Lib.Enum.Deadzone
        this.threshold  := Xbox360Lib.Enum.Threshold
        this.xgamepad   := Xbox360Lib.Enum.XInputStateGamepad
        this.buttons    := Xbox360Lib.Enum.Buttons
        this.xbuttons   := Xbox360Lib.Enum.XInputStateButtons
        this.setCapacity("state", 16)
    }
    
    __Get(name) {
        if (name == "IsConnected") {
            return this.IsConnected()
        }

        if (!this.IsConnected()){
            return 0
        }

        if (this.IsMotor(name)) {
            return this.GetMotorSpeed(name)
        }
        
        if (!this.ButtonExist(name)) {
            return 0
        }

        buttonCode := this.GetButtonCode(name)

        if (this.IsDigitalButton(buttonCode)) {
            return this.IsDigitalButtonActive(buttonCode)
        }

        if (this.IsAnalogButton(buttonCode)) {
            return this.GetAnalogButtonValue(buttonCode)
        }
        
        
        return 0
    }
    
    __Set(name, value) {
        if (this.IsMotor(name)) {
            return this.SetMotorSpeed(name, value)
        }
    }
    
    
    /**
     * @return bool
     */
    ButtonExist(buttonName) {
        if (this.buttons[buttonName]) {
            return true
        } else {
            return false
        }
    }

    /**
     * @return int
     */
    GetButtonCode(buttonName) {
        return this.buttons[buttonName]
    }

    /**
     * @return bool
     */
    IsDigitalButton(buttonCode) {
        if (this.xbuttons[buttonCode]) {
            return true
        } else {
            return false
        }
    }
    
    /**
     * @return bool
     */
    IsDigitalButtonActive(buttonCode) {
        wButtons := NumGet(this.getAddress("state"),  4, "UShort")
        if (wButtons & this.xbuttons[buttonCode]) {
            return true
        } else{
            return false
        }
    }

     /**
     * @return bool
     */
    IsAnalogButton(buttonCode) {
        if (this.xgamepad[buttonCode]) {
            return true
        } else {
            return false
        }
    }

    /**
     * @return int
     */
    GetAnalogButtonValue(buttonCode) {
        config := this.xgamepad[buttonCode]
        deadzoneOrThreshold := this.deadzone[buttonCode] ? this.deadzone[buttonCode] : this.threshold[buttonCode]
        value := NumGet(this.GetAddress("state"),  config.code, config.type)
        if (abs(value) > deadzoneOrThreshold) {
            return value
        } else {
            return 0
        }
    }


    IsMotor(motorName) {
        global Xbox360Lib
        if (Xbox360Lib.Enum.Motor[motorName]) {
            return true
        } else {
            return false
        }
    }
    
    GetMotorSpeed(motorName) {
        if (motorName == "LV") {
            return this.xvibration.leftMotorSpeed
        }

        if (motorName == "RV") {
            return this.xvibration.rightMotorSpeed
        }

        if (motorName == "BV") {
            return [this.xvibration.leftMotorSpeed, this.xvibration.rightMotorSpeed]
        }
    }
    
    SetMotorSpeed(motorName, value) {
        if (motorName == "LV") {
            this.LeftVibration(value)
            return value
        }

        if (motorName == "RV") {
            this.RightVibration(value)
            return value            
        }

        if (motorName == "BV") {
            this.BothVibration(value)
            return value
        }
    }
    
    
    /**
     * @return void
     */
    BothVibration(motorSpeed) {
        if (motorSpeed is integer) {
            this.xvibration.leftMotorSpeed  := motorSpeed 
            this.xvibration.rightMotorSpeed := motorSpeed 
        } else {
            this.xvibration.leftMotorSpeed  :=  motorSpeed[1]
            this.xvibration.rightMotorSpeed :=  motorSpeed[2]
        }
        this.error := this.xinput.SetState(this.index, this.xvibration)
    }
    

    /**
     * @return void
     */
    LeftVibration(leftMotorSpeed) {
        this.xvibration.leftMotorSpeed  := leftMotorSpeed 
        this.error := this.xinput.SetState(this.index, this.xvibration)
    }

    /**
     * @return void
     */
    RightVibration(rightMotorSpeed) {
        this.xvibration.rightMotorSpeed := rightMotorSpeed 
        this.error := this.xinput.SetState(this.index, this.xvibration)
    }


    /**
     * @return void
     */
    Update() {
        this.error := this.xinput.getState(this.index, this.GetAddress("state"))
    }

    /**
     * @return bool
     */
    IsConnected() {
        return !this.error
    }

    /**
     * @return int
     */
    GetError() {
        return this.error
    }
}

Class Xbox360LibControllerManager {
    
    static instance :=
    controls := []
    xinput   :=

    __New() {
        if(Xbox360LibControllerManager.instance) {
            return this.instance
        } else {
            this.xinput := new Xbox360LibXInput()
            Xbox360LibControllerManager.instance := this
        }
    }

    /**
     * @return Xbox360LibController
     */	
    InitializeController(index) {
        if(this.controls[index]) {
            return this.controls[index]
        }
        this.controls[index] := new Xbox360LibController(index, this.xinput)
        return this.controls[index]
    }

    /**
    * @brief Power off the controler 0-3
    */
    PowerOffController(index) {
        this.xinput.CallPowerOffController(index)
    }
}
