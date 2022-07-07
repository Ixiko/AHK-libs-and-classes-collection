#Include, ..\VMR.ahk
SetBatchLines, 20ms

Global vm, GUI_hwnd, is_win_pos_changing:=0

vm := new VMR()
vm.login()
showUI()
vm.on_update_levels_callback:= Func("syncLevel") ; register level callback func
vm.on_update_parameters_callback:= Func("syncParameters") ; register params callback func
OnMessage(0x46, Func("onPosChanging"))

showUI(){
    Global
    Gui, vm:New, +HwndGUI_hwnd, VoiceMeeter Remote UI
    xPos:=10
    Loop % vm.bus.Length() { ; add UI controls for each bus
        ;bus title
        yPos:=0, funcObj:=""
        Gui, Add, Text, x%xPos% y%yPos% w100, Bus[%A_Index%]
        
        ;bus level
        yPos+= 30
        Gui, Add, Progress, x%xPos% y%yPos% w20 h200 Range-72-20 c0x70C399 Background0x2C3D4D vertical Hwndbus_%A_Index%_level
        
        ;bus gain
        yPos+= 220
        Gui, Add, Edit, w50 x%xPos% y%yPos% ReadOnly 
        Gui, Add, UpDown,Hwndbus_%A_Index%_gain Range-60-12 x0
        funcObj:= Func("updateParam").bind("gain", A_Index)
        GuiControl +g, % bus_%A_Index%_gain, % FuncObj

        ;bus mute
        yPos+= 30
        Gui, Add, CheckBox, x%xPos% y%yPos% Hwndbus_%A_Index%_mute, Mute
        funcObj:= Func("updateParam").bind("mute", A_Index)
        GuiControl +g, % bus_%A_Index%_mute, % FuncObj
        
        xPos+=150
    }
    syncParameters() ; get initial values for gui controls
    Gui, Show, H350,VoiceMeeter Remote UI
}

; update vm bus parameters when they change on the AHK UI
updateParam(param, index){
    GuiControlGet, val,,% bus_%index%_%param%
    vm.bus[index][param]:= val
    SetTimer, syncParameters, -500 ; make sure params are in sync
}

; sync AHK UI controls with vm bus parameters
syncParameters(){
    Loop % vm.bus.Length() {
        GuiControl,, % bus_%A_Index%_gain, % vm.bus[A_Index].gain
        GuiControl,, % bus_%A_Index%_mute, % Format("{:i}", vm.bus[A_Index].mute) ; convert 0.0/1.0 to 0/1
    }
}

; sync level meters with vm bus levels
syncLevel(){
    if(is_win_pos_changing) ;dont update levels if the window is changing its position
        return
    Loop % vm.bus.Length() {
        GuiControl,, % bus_%A_Index%_level, % Max(vm.bus[A_Index].level*) ; get peak level for the bus
    }
}

vmGuiClose(){
    ExitApp
}

onPosChanging(){
    is_win_pos_changing:=1
    SetTimer, onPosChanged, -50
}

onPosChanged(){
    is_win_pos_changing:=0
}
