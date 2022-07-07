class VMR{
    bus:=Array(), strip:=Array(), recorder:=, option:=, patch:=, fx:=
    , on_update_levels_callback:=, on_update_parameters_callback:=, on_update_macrobuttons_callback:=

    
    __New(p_path:=""){
        VBVMR.DLL_PATH := p_path? p_path . "\"
            : "C:\Program Files" . (A_Is64bitOS? " (x86)" : "") . "\VB\Voicemeeter\"
        VBVMR.DLL_FILE := A_PtrSize = 8 ? "VoicemeeterRemote64.dll" : "VoicemeeterRemote.dll"
        if(!FileExist(VBVMR.DLL_PATH . VBVMR.DLL_FILE))
            Throw, Format("Voicemeeter is not installed in the path :`n{}", VBVMR.DLL_PATH)
        VBVMR.STR_TYPE := A_IsUnicode? "W" : "A"
        VBVMR.DLL := DllCall("LoadLibrary", "Str", VBVMR.DLL_PATH . VBVMR.DLL_FILE, "Ptr")
        VBVMR.__getAddresses()
    }
    
    login(){
        if(VBVMR.Login()){
            this.runVoicemeeter()
            sleep, 1000
        }
        OnExit(ObjBindMethod(VBVMR, "Logout"))
        syncWithDLL := ObjBindMethod(this, "__syncWithDLL")
        SetTimer, %syncWithDLL%, 20, 1
        this.getType()
        this.__init_arrays()
        this.__init_obj()
    }
    
    
    getType(){
        if(!VBVMR.VM_TYPE){
            VBVMR.VM_TYPE:= VBVMR.GetVoicemeeterType()
            Switch VBVMR.VM_TYPE {
                case 1:
                    VBVMR.BUSCOUNT:= 2
                    VBVMR.STRIPCOUNT:= 3
                    VBVMR.VBANINCOUNT:= 4
                    VBVMR.VBANOUTCOUNT:= 4
                case 2:
                    VBVMR.BUSCOUNT:= 5
                    VBVMR.STRIPCOUNT:= 5
                    VBVMR.VBANINCOUNT:= 8
                    VBVMR.VBANOUTCOUNT:= 8
                case 3:
                    VBVMR.BUSCOUNT:= 8
                    VBVMR.STRIPCOUNT:= 8
                    VBVMR.VBANINCOUNT:= 8
                    VBVMR.VBANOUTCOUNT:= 8
            }
        }
        return VBVMR.VM_TYPE
    }

    runVoicemeeter(p_type := ""){
        if(p_type){
            Run, % VBVMR.DLL_PATH . this.__getTypeExecutable(p_type) , % VBVMR.DLL_PATH, UseErrorLevel Hide
        }else{
            loop 3 {
                Run, % VBVMR.DLL_PATH . this.__getTypeExecutable(4-A_Index) , % VBVMR.DLL_PATH, UseErrorLevel Hide
                if(!ErrorLevel)
                    return
            }
        }
        if(ErrorLevel)
            Throw, "Could not run Voicemeeter"
    }

    updateDevices(){
        VMR.VM_BUS_STRIP.BusDevices:= Array()
        VMR.VM_BUS_STRIP.StripDevices:= Array()
        loop % VBVMR.Output_GetDeviceNumber()
            VMR.VM_BUS_STRIP.BusDevices.Push(VBVMR.Output_GetDeviceDesc(A_Index-1))
        loop % VBVMR.Input_GetDeviceNumber()
            VMR.VM_BUS_STRIP.StripDevices.Push(VBVMR.Input_GetDeviceDesc(A_Index-1))
    }

    __init_obj(){
        this.recorder:= new this.recorder_base
        this.option:= new this.option_base
        if(this.gettype() >= 2)
            this.patch:= new this.patch_base
        this.vban.init()
        if(this.gettype() >= 3)
            this.fx := new this.fx_base
        VMR.vban.stream.initiated:=1
    }

    __init_arrays(){
        loop % VBVMR.BUSCOUNT {
            this.bus.Push(new this.VM_BUS_STRIP("Bus"))
        }
        loop % VBVMR.STRIPCOUNT {
            this.strip.Push(new this.VM_BUS_STRIP("Strip"))
        }
        this.updateDevices()
        VMR.VM_BUS_STRIP.initiated:=1
    }

    __getTypeExecutable(p_type){
        switch (p_type) {
            case 1: return "voicemeeter.exe"
            case 2: return "voicemeeterpro.exe"
            case 3: return Format("voicemeeter8{}.exe", A_Is64bitOS? "x64":"")
        }
    }

    __syncWithDLL(){
        static ignore_msg:=0
        try {
            ;sync vmr parameters
            isParametersDirty:= VBVMR.IsParametersDirty()
            
            ;sync macro buttons states
            isMacroButtonsDirty:= VBVMR.MacroButton_IsDirty()

            ;sync bus/strip level arrays
            loop % VBVMR.BUSCOUNT {
                this.bus[A_Index].__updateLevel()
            }
            loop % VBVMR.STRIPCOUNT {
                this.strip[A_Index].__updateLevel()
            }

            ;sync successful
            ignore_msg:=0

            ;level callback
            if(IsFunc(this.on_update_levels_callback)){
                this.on_update_levels_callback.Call()
            }

            ;parameter callback
            if(isParametersDirty && IsFunc(this.on_update_parameters_callback)){
                this.on_update_parameters_callback.Call()
            }

            ;macrobutton callback
            if(isMacroButtonsDirty && IsFunc(this.on_update_macrobuttons_callback)){
                this.on_update_macrobuttons_callback.Call()
            }
        } catch e {
            if(!ignore_msg){
                MsgBox, 52, VMR.ahk, An error occurred during synchronization: %e%`nAttempt to restart VoiceMeeter?
                IfMsgBox Yes
                    this.runVoicemeeter(VBVMR.VM_TYPE)
                IfMsgBox, No
                    ignore_msg:=1
                sleep, 1000
            }
        }
    }

    __Delete(){
        DllCall("FreeLibrary", "Ptr", VBVMR.DLL)
    }
    
    class VM_BUS_STRIP {
        static BUS_COUNT:=0, BUS_LEVEL_COUNT:=0, BusDevices:=Array(), STRIP_COUNT:=0, STRIP_LEVEL_COUNT:=0, StripDevices:=Array(), initiated
        BUS_STRIP_TYPE:=, BUS_STRIP_INDEX:=, BUS_STRIP_ID, LEVEL_INDEX, level, gain_limit
        
        __Set(p_name, p_value, p_sec_value:=""){
            if(VMR.VM_BUS_STRIP.initiated && this.BUS_STRIP_ID){
                switch p_name {
                    case "gain":
                        return Format("{:.1f}",this.setParameter(p_name, max(-60.0, min(p_value, this.gain_limit))))
                    case "limit":
                        return Format("{:.1f}",this.setParameter(p_name, max(-40.0, min(p_value, 12.0))))
                    case "device":
                        driver:= p_sec_value? p_value : "wdm"
                        name:= p_sec_value? p_sec_value : p_value
                        return this.__setDevice(name,driver)
                    case "mute":
                        if(p_value = -1)
                            p_value:= !this.mute
                }
                return this.setParameter(p_name,p_value)
            }
        }

        __Get(p_name){
            if(VMR.VM_BUS_STRIP.initiated && this.BUS_STRIP_ID){
                switch p_name {
                    case "gain","limit":
                        return Format("{:.1f}",this.getParameter(p_name))
                    case "device":
                        return this.getParameter("device.name")
                }
                return this.getParameter(p_name)
            }
        }

        __New(p_type){
            this.BUS_STRIP_TYPE := p_type
            this.level := Array()
            this.LEVEL_INDEX := Array()
            this.gain_limit:= 12.0
            if (p_type="Strip") {
                this.BUS_STRIP_INDEX := VMR.VM_BUS_STRIP.STRIP_COUNT++
                loop % this.__isPhysical() ? 2 : 8 
                    this.LEVEL_INDEX.Push(VMR.VM_BUS_STRIP.STRIP_LEVEL_COUNT++)
            }else{
                this.BUS_STRIP_INDEX := VMR.VM_BUS_STRIP.BUS_COUNT++
                loop 8 
                    this.LEVEL_INDEX.Push(VMR.VM_BUS_STRIP.BUS_LEVEL_COUNT++)
            }
            this.BUS_STRIP_ID := this.BUS_STRIP_TYPE . "[" . this.BUS_STRIP_INDEX . "]"
        }

        getGainPercentage(){
            return Format("{:.2f}",this.getPercentage(this.gain))
        }

        getPercentage(dB){
            min_s := 10**(-60/20), max_s := 10**(0/20)
            return ((10**(dB/20))-min_s)/(max_s-min_s)*100
        }

        setParameter(parameter, value){
            local func
            if parameter contains device,FadeTo,Label
                func:= "setParameterString"
            else
                func:= "setParameterFloat"
            return (VBVMR)[func](this.BUS_STRIP_ID, parameter, value)
        }

        getParameter(parameter){
            local func
            if parameter contains device,FadeTo,Label
                func:= "getParameterString"
            else
                func:= "getParameterFloat"
            VBVMR.IsParametersDirty()
            return (VBVMR)[func](this.BUS_STRIP_ID, parameter)
        }

        __setDevice(name,driver){
            if (!this.__isPhysical())
                return -4
            if driver not in wdm,mme,ks,asio
                return -5
            deviceObj := this.__getDeviceObj(name,driver)
            return this.setParameter("device." . deviceObj.Driver,deviceObj.Name)
        }
        
        __getDeviceObj(substring,driver:="wdm"){
            local devices:= VMR.VM_BUS_STRIP[this.BUS_STRIP_TYPE . "Devices"]
            for i in devices 
                if (devices[i].driver = driver && InStr(devices[i].name, substring)>0)
                    return devices[i]
        }

        __updateLevel(){
            local type := this.BUS_STRIP_TYPE="Bus" ? 3 : 1
            loop % this.LEVEL_INDEX.Length() {
                level := VBVMR.GetLevel(type, this.LEVEL_INDEX[A_Index])
                this.level[A_Index] := Max(Round(20 * Log(level)), -999)
            }
        }

        __isPhysical(){
            Switch VBVMR.VM_TYPE {
                case 1:
                    if(this.BUS_STRIP_TYPE = "Strip")
                        return this.BUS_STRIP_INDEX < 2
                    else
                        return 1
                case 2:
                        return this.BUS_STRIP_INDEX < 3
                case 3:
                        return this.BUS_STRIP_INDEX < 5
            }
        }
    }
    
    class fx_base {

        reverb(onOff := -2) {
            switch (onOff) {
                case -2: ;getParam
                    return VBVMR.GetParameterFloat("Fx.Reverb", "on")
                case -1: ;invert state
                    onOff := !VBVMR.GetParameterFloat("Fx.Reverb", "on")
            }
            return VBVMR.SetParameterFloat("Fx.Reverb","on", onOff)
        }

        delay(onOff := -2) {
            switch (onOff) {
                case -2: ;getParam
                    return VBVMR.GetParameterFloat("Fx.delay", "on")
                case -1: ;invert state
                    onOff := !VBVMR.GetParameterFloat("Fx.delay", "on")
            }
            return VBVMR.SetParameterFloat("Fx.delay","on", onOff)
        }
    }

    class command {

        restart(){
            return VBVMR.SetParameterFloat("Command","Restart",1)
        }

        shutdown(){
            return VBVMR.SetParameterFloat("Command","Shutdown",1)
        }

        show(open := 1){
            return VBVMR.SetParameterFloat("Command","Show",open)
        }

        eject(){
            return VBVMR.SetParameterFloat("Command","Eject",1)
        }

        reset(){
            return VBVMR.SetParameterFloat("Command","Reset",1)
        }

        save(filePath){
            return VBVMR.SetParameterString("Command","Save",filePath)
        }

        load(filePath){
            return VBVMR.SetParameterString("Command","Load",filePath)
        }

        showVBANChat(show := 1) {
            return VBVMR.SetParameterFloat("Command","dialogshow.VBANCHAT",show)
        }

        state(buttonNum, newPos := -2) {
            switch (newPos){
                case -2: ;getParam
                    return VBVMR.GetParameterFloat("Command.Button[" . buttonNum . "]", "state")
                case -1: ;invert state
                    newPos := !VBVMR.GetParameterFloat("Command.Button[" . buttonNum . "]", "state")
            }
            return VBVMR.SetParameterFloat("Command.Button[" . buttonNum . "]", "state", newPos)
        }

        stateOnly(buttonNum, newPos := -2) {
            switch (newPos){
                case -2: ;getParam
                    return VBVMR.GetParameterFloat("Command.Button[" . buttonNum . "]", "stateOnly")
                case -1: ;invert state
                    newPos := !VBVMR.GetParameterFloat("Command.Button[" . buttonNum . "]", "stateOnly")
            }
            return VBVMR.SetParameterFloat("Command.Button[" . buttonNum . "]", "stateOnly", newPos)
        }

        trigger(buttonNum, newPos := -2) {
            switch (newPos){
                case -2: ;getParam
                    return VBVMR.GetParameterFloat("Command.Button[" . buttonNum . "]", "trigger")
                case -1: ;invert state
                    newPos := !VBVMR.GetParameterFloat("Command.Button[" . buttonNum . "]", "trigger")
            }
            return VBVMR.SetParameterFloat("Command.Button[" . buttonNum . "]", "trigger", newPos)
        }
    }

    class vban {
        static instream:=,outstream:=

        enable{
            set{
                return VBVMR.SetParameterFloat("vban", "Enable", value)
            }
            get{
                return VBVMR.GetParameterFloat("vban", "Enable")
            }
        }

        init(){
            VMR.vban.instream:= Array()
            VMR.vban.outstream:= Array()
            loop % VBVMR.VBANINCOUNT
                VMR.vban.instream.Push(new VMR.vban.stream("in", A_Index))
            loop % VBVMR.VBANOUTCOUNT
                VMR.vban.outstream.Push(new VMR.vban.stream("out", A_Index))
        }
        
        class stream{
            static initiated:= 0
            __New(p_type,p_index){
                this.PARAM_PREFIX:= Format("vban.{}stream[{}]", p_type, p_index)
            }
            __Set(p_name,p_value){
                if(VMR.vban.stream.initiated) {
                    if p_name contains name, ip
                        return VBVMR.SetParameterString(this.PARAM_PREFIX, p_name, p_value)
                    return VBVMR.SetParameterFloat(this.PARAM_PREFIX, p_name, p_value)
                }
                
            }
            __Get(p_name){
                if(VMR.vban.stream.initiated){
                    if p_name contains name, ip
                        return VBVMR.GetParameterString(this.PARAM_PREFIX, p_name)
                    return VBVMR.GetParameterFloat(this.PARAM_PREFIX, p_name)
                }
            }		
        }
    }

    class macroButton {
        
        setStatus(nuLogicalButton, fValue, bitMode := 1){
            return VBVMR.MacroButton_SetStatus(nuLogicalButton, fValue, bitMode)
        }
        
        getStatus(nuLogicalButton, bitMode := 1){
            return VBVMR.MacroButton_GetStatus(nuLogicalButton, bitMode)
        }
        
    }

    class patch_base {

        __Set(p_name, p_value){
            return VBVMR.SetParameterFloat("Patch", p_name, p_value)
        }
        
        __Get(p_name){
            return VBVMR.GetParameterFloat("Patch", p_name)
        }
    }

    class option_base {
        
        __Set(p_name, p_value){
            return VBVMR.SetParameterFloat("Option", p_name, p_value)
        }
        
        __Get(p_name){
            return VBVMR.GetParameterFloat("Option", p_name)
        }
        
        delay(busNum, p_delay := "") {
            ; in keeping with the 1 indexed class...
            busNum := busNum - 1
            if(p_delay == "") {
                ; get the value
                return VBVMR.GetParameterFloat("Option", "delay[" . busNum . "]")
            }
            else {
                ; set it to a new value
                return VBVMR.SetParameterFloat("Option", "delay[" . busNum . "]", Min(Max(p_delay,0),500))
            }
            
        }
    }

    class recorder_base {
        
        __Set(p_name,p_value){
            return VBVMR.SetParameterFloat("Recorder",p_name, p_value)
        }

        __Get(p_name){
            return VBVMR.GetParameterFloat("Recorder",p_name)
        }

        ArmBus(bus, set:=-1){
            if(set > -1){
                VBVMR.SetParameterFloat("Recorder","mode.recbus", 1)
                VBVMR.SetParameterFloat("Recorder","ArmBus(" (bus-1) ")", set)
            }else{
                return VBVMR.GetParameterFloat("Recorder","ArmBus(" (bus-1) ")")
            }
        }

        ArmStrips(strip*){
            loop { 
                Try 
                    this.armStrip(A_Index,0)
                Catch
                    Break
            }
            for i in strip
                Try this.armStrip(strip[i],1)
        }

        ArmStrip(strip, set:=-1){
            if(set > -1){
                VBVMR.SetParameterFloat("Recorder","mode.recbus", 0)
                VBVMR.SetParameterFloat("Recorder","ArmStrip(" . (strip-1) . ")", set)
            }else{
                return VBVMR.GetParameterFloat("Recorder","ArmStrip(" (strip-1) ")")
            }
        }
    }
}

class VBVMR {
    static DLL, DLL_PATH:=, DLL_FILE:=, VM_TYPE:=, BUSCOUNT:=, STRIPCOUNT:=, STR_TYPE:=, VBANINCOUNT:=, VBANOUTCOUNT:=
    static FUNC_ADDR:={ Login:0
        ,Logout:0
        ,SetParameterFloat:0
        ,SetParameterStringW:0
        ,SetParameterStringA:0
        ,GetParameterFloat:0
        ,GetParameterStringW:0
        ,GetParameterStringA:0
        ,GetVoicemeeterType:0
        ,GetLevel:0
        ,Output_GetDeviceNumber:0
        ,Output_GetDeviceDescW:0
        ,Output_GetDeviceDescA:0
        ,Input_GetDeviceNumber:0
        ,Input_GetDeviceDescW:0
        ,Input_GetDeviceDescA:0
        ,IsParametersDirty:0
        ,MacroButton_IsDirty:0
        ,MacroButton_GetStatus:0
        ,MacroButton_SetStatus:0}

    Login(){
        errLevel := DllCall(VBVMR.FUNC_ADDR.Login)
        if(errLevel<0)
            Throw, Format("`nVBVMR_Login returned {}`nDllCall returned {}", errLevel, ErrorLevel)
        return errLevel
    }

    Logout(){
        errLevel := DllCall(VBVMR.FUNC_ADDR.Logout)
        if(errLevel<0)
            Throw, Format("`nVBVMR_Logout returned {}`nDllCall returned {}", errLevel, ErrorLevel)
        return errLevel
    }

    SetParameterFloat(p_prefix, p_parameter, p_value){
        this.IsParametersDirty()
        errLevel := DllCall(VBVMR.FUNC_ADDR.SetParameterFloat, "AStr" , p_prefix . "." . p_parameter , "Float" , p_value, "Int")
        if (errLevel<0)
            Throw, Format("`nVBVMR_SetParameterFloat returned {}`nDllCall returned {}", errLevel, ErrorLevel)
        return p_value
    }

    SetParameterString(p_prefix, p_parameter, p_value){
        this.IsParametersDirty()
        errLevel := DllCall(VBVMR.FUNC_ADDR["SetParameterString" . VBVMR.STR_TYPE], "AStr", p_prefix . "." . p_parameter , VBVMR.STR_TYPE . "Str" , p_value , "Int")
        if (errLevel<0)
            Throw, Format("`nVBVMR_SetParameterString returned {}`nDllCall returned {}", errLevel, ErrorLevel)
        return p_value
    }

    GetParameterFloat(p_prefix, p_parameter){
        local value
        this.IsParametersDirty()
        VarSetCapacity(value, 4)
        errLevel := DllCall(VBVMR.FUNC_ADDR.GetParameterFloat, "AStr" , p_prefix . "." . p_parameter , "Ptr" , &value, "Int")
        if (errLevel<0)
            Throw, Format("`nVBVMR_GetParameterFloat returned {}`nDllCall returned {}", errLevel, ErrorLevel)
        value := NumGet(&value, 0, "Float")
        return value
    }

    GetParameterString(p_prefix, p_parameter){
        local value
        this.IsParametersDirty()
        VarSetCapacity(value, A_IsUnicode? 1024 : 512)
        errLevel := DllCall(VBVMR.FUNC_ADDR["GetParameterString" . VBVMR.STR_TYPE], "AStr" , p_prefix . "." . p_parameter , "Ptr" , &value , "Int")
        if (errLevel<0)
            Throw, Format("`nVBVMR_GetParameterString returned {}`nDllCall returned {}", errLevel, ErrorLevel)
        value := StrGet(&value,512)
        return value
    }

    GetLevel(p_type, p_channel){
        local level
        this.IsParametersDirty()
        VarSetCapacity(level,4)
        errLevel := DllCall(VBVMR.FUNC_ADDR.GetLevel, "Int", p_type, "Int", p_channel, "Ptr", &level)
        if(errLevel<0){
            SetTimer,, Off
            Throw, Format("`nVBVMR_GetLevel returned {}`nDllCall returned {}", errLevel, ErrorLevel)
        }
        level := NumGet(&level, 0, "Float")
        return level
    }

    GetVoicemeeterType(){
        local vtype
        VarSetCapacity(vtype, 4)
        errLevel := DllCall(VBVMR.FUNC_ADDR.GetVoicemeeterType, "Ptr", &vtype, "Int")
        if(errLevel<0)
            Throw, Format("`nVBVMR_GetVoicemeeterType returned {}`nDllCall returned {}", errLevel, ErrorLevel)
        vtype:= NumGet(&vtype, 0, "Int")
        return vtype
    }

    Output_GetDeviceNumber(){
        errLevel := DllCall(VBVMR.FUNC_ADDR.Output_GetDeviceNumber,"Int") 
        if(errLevel<0)
            Throw, Format("`nVBVMR_Output_GetDeviceNumber returned {}`nDllCall returned {}", errLevel, ErrorLevel)
        else
            return errLevel
    }
    
    Output_GetDeviceDesc(p_index){
        local name, driver, device := {}
        VarSetCapacity(name, A_IsUnicode? 1024 : 512)
        VarSetCapacity(driver, 4)
        errLevel := DllCall(VBVMR.FUNC_ADDR["Output_GetDeviceDesc" . VBVMR.STR_TYPE], "Int", p_index, "Ptr" , &driver , "Ptr", &name, "Ptr", 0, "Int")
        if(errLevel<0)
            Throw, Format("`nVBVMR_Output_GetDeviceDesc returned {}`nDllCall returned {}", errLevel, ErrorLevel)
        driver := NumGet(&driver, 0, "UInt")
        name := StrGet(&name,512)
        device.name := name
        device.driver := (driver=3 ? "wdm" : (driver=4 ? "ks" : (driver=5 ? "asio" : "mme"))) 
        return device
    }

    Input_GetDeviceNumber(){
        errLevel := DllCall(VBVMR.FUNC_ADDR.Input_GetDeviceNumber,"Int") 
        if(errLevel<0)
            Throw, Format("`nVBVMR_Input_GetDeviceNumber returned {}`nDllCall returned {}", errLevel, ErrorLevel)
        else
            return errLevel
    }

    Input_GetDeviceDesc(p_index){
        local name, driver, device := {}
        VarSetCapacity(name, A_IsUnicode? 1024 : 512)
        VarSetCapacity(driver, 4)
        errLevel := DllCall(VBVMR.FUNC_ADDR["Input_GetDeviceDesc" . VBVMR.STR_TYPE], "Int", p_index, "Ptr" , &driver , "Ptr", &name, "Ptr", 0, "Int")
        if(errLevel<0)
            Throw, Format("`nVBVMR_Input_GetDeviceDesc returned {}`nDllCall returned {}", errLevel, ErrorLevel)
        driver := NumGet(&driver, 0, "UInt")
        name := StrGet(&name,512)
        device.name := name
        device.driver := (driver=3 ? "wdm" : (driver=4 ? "ks" : (driver=5 ? "asio" : "mme"))) 
        return device
    }

    IsParametersDirty(){
        errLevel := DllCall(VBVMR.FUNC_ADDR.IsParametersDirty)
        if(errLevel<0)
            Throw, Format("`nVBVMR_IsParametersDirty returned {}`nDllCall returned {}", errLevel, ErrorLevel)
        else
            return errLevel 
    }

    MacroButton_GetStatus(nuLogicalButton, bitMode := 0){
        local pValue
        this.IsMacroButtonsDirty()
        VarSetCapacity(pValue, 4)
        errLevel := DllCall(VBVMR.FUNC_ADDR.MacroButton_GetStatus, "Int" , nuLogicalButton , "Ptr", &pValue, "Int", bitMode, "Int")
        if (errLevel<0)
            Throw, Exception("VBVMR_MacroButton_GetStatus returned " . errLevel . "`n DLLCALL returned " . ErrorLevel, -1)
        pValue := NumGet(&pValue, 0, "Int")
        return [pValue, bitMode]
    }
    
    MacroButton_SetStatus(nuLogicalButton, fValue := 0, bitMode := 1){
        this.IsMacroButtonsDirty()
        errLevel := DllCall(VBVMR.FUNC_ADDR.MacroButton_SetStatus, "Int" ,  nuLogicalButton , "Float" , fValue, "Int", bitMode, "Int")
        if (errLevel<0)
            Throw, Exception("VBVMR_MacroButton_SetStatus returned " . errLevel, -1)
        return [fValue, bitMode]
    }
    
    MacroButton_IsDirty(){
        errLevel := DllCall(VBVMR.FUNC_ADDR.MacroButton_IsDirty)
        if(errLevel<0)
            Throw, Exception("VBVMR_MacroButton_IsParametersDirty returned " . errLevel, -1)
        else
            return errLevel 
    }

    __getAddresses(){
        for fName in VBVMR.FUNC_ADDR 
            (VBVMR.FUNC_ADDR)[fName]:= DllCall("GetProcAddress", "Ptr", VBVMR.DLL, "AStr", "VBVMR_" . fName, "Ptr")
    }
}
