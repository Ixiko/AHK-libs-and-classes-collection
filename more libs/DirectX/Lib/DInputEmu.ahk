global g_dinputemu := {}
g_dinputemu.controls := ["A","B","X","Y"
, "LEFT_THUMB", "RIGHT_THUMB", "LEFT_SHOULDER", "RIGHT_SHOULDER"
, "start", "back", "bRightTrigger", "bLeftTrigger"]

InitDInputEmu(byref config, _unicode = true)
{
	if XinPutGetState(1)
		return
	logerr(getDirectInput(_unicode))
	_unicode ? logerr(IDirectInputDeviceW.hook("GetDeviceState")) : logerr(IDirectInputDeviceA.hook("GetDeviceState"))
	
	cfg := parseConfig(config)
	for k, v in g_dinputemu.controls
		g_dinputemu.xinput[v] := cfg[v]  ;+0	
	
	if cfg.deadzone
	{
		g_dinputemu.deadzone := cfg.deadzone * 32768 
		g_dinputemu.deadzone_minus := g_dinputemu.deadzone*(-1)
	}
	return
}

IDirectInputDeviceW_GetDeviceState(p1, p2, p3)
{
	critical
	r := dllcall(IDirectInputDeviceW.GetDeviceState, uint, p1, uint, p2, uint, p3)

	if (p2 = 60)	
	{	
		if XinputGetState(1)	
			return r
		
		callback := "xinputcallback"
		DIJOYSTATE60[] := p3
		loop, 32
			DIJOYSTATE60.rgbButtons[A_index] := 0
		
		XINPUT_GAMEPAD_DPAD_RIGHT ? DIJOYSTATE60.lX := 0xffff : XINPUT_GAMEPAD_DPAD_LEFT ? DIJOYSTATE60.lX := 0
		XINPUT_GAMEPAD_DPAD_DOWN ? DIJOYSTATE60.lY := 0xffff : XINPUT_GAMEPAD_DPAD_UP ? DIJOYSTATE60.lY := 0
						
		for k, v in g_dinputemu.controls
		{
			if (k < 11)
			{
				val = % XINPUT_GAMEPAD_%v%	
				valprev = % XINPUT_GAMEPAD_%v%_PREV
			}				
			else 
			{
				val := XINPUT_GAMEPAD[v]
				valprev = % XINPUT_GAMEPAD_%v%_PREV
			}	

			z := g_dinputemu.xinput[v] 
			if z is number 	
				 val ? DIJOYSTATE60.rgbButtons[g_dinputemu.xinput[v]] := 128 		
			else val ? valprev ?: isfunc(callback) ? %callback%(z) 			
		}				
	}
	else if (p2 = 80)	
	{		
		if XinputGetState(1)	
			return r
		
		callback := "xinputcallback"
		DIJOYSTATE[] := p3
		loop, 32
			DIJOYSTATE.rgbButtons[A_index] := 0
		
		DIJOYSTATE.lX := 0,	DIJOYSTATE.lY := 0, DIJOYSTATE.lZ := 0	
		DIJOYSTATE.RX := 0,	DIJOYSTATE.RY := 0, DIJOYSTATE.RZ := 0	
		
		if g_dinputemu.deadzone 
		{	
			if XINPUT_GAMEPAD.sThumbLX > g_dinputemu.deadzone 
				DIJOYSTATE.lX := XINPUT_GAMEPAD.sThumbLX * 0xffff/32768
			else if XINPUT_GAMEPAD.sThumbLX < g_dinputemu.deadzone_minus 
				DIJOYSTATE.lX := XINPUT_GAMEPAD.sThumbLX * 0xffff/32768
			
			if XINPUT_GAMEPAD.sThumbLY > g_dinputemu.deadzone
				DIJOYSTATE.LY := -XINPUT_GAMEPAD.sThumbLY * 0xffff/32768
			else if XINPUT_GAMEPAD.sThumbLY < g_dinputemu.deadzone_minus 
				DIJOYSTATE.LY := -XINPUT_GAMEPAD.sThumbLY * 0xffff/32768
		}
				
		XINPUT_GAMEPAD_DPAD_RIGHT ? DIJOYSTATE.lX := 0xffff : XINPUT_GAMEPAD_DPAD_LEFT ? DIJOYSTATE.lX := -0xffff
		XINPUT_GAMEPAD_DPAD_DOWN ? DIJOYSTATE.lY := 0xffff : XINPUT_GAMEPAD_DPAD_UP ? DIJOYSTATE.lY := -0xffff
						
		for k, v in g_dinputemu.controls
		{
			if (k < 11)
			{
				val = % XINPUT_GAMEPAD_%v%	
				valprev = % XINPUT_GAMEPAD_%v%_PREV
			}				
			else 
			{
				val := XINPUT_GAMEPAD[v]
				valprev	:= XINPUT_GAMEPAD[v "_prev"]
			}	

			z := g_dinputemu.xinput[v] 						
			if z is number 	
				 val ? DIJOYSTATE.rgbButtons[g_dinputemu.xinput[v]] := 128 		
			else val ? valprev ?: isfunc(callback) ? %callback%(z) 			
		}					
	}	
	return r
}	
