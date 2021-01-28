; Monitor functions for AHK_V2


MonitorFromWindow(Hwnd := 0) {
	/* 	DESCRIPCIÓN / DESCRIPTION

    Recupera el identificador al monitor que está más cerca de la ventana especificada.
    Parámetros:
        Hwnd:
            El identificador de la ventana de interés. Si es cero, recupera el identificador del monitor primario.
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	Retrieve the identifier to the monitor that is closest to the specified window.
     Parameters:
         Hwnd:
             The identifier of the window of interest. If it is zero, it retrieves the identifier of the primary monitor.

	*/
    ; MonitorFromWindow function
    ; https://docs.microsoft.com/es-es/windows/desktop/api/winuser/nf-winuser-monitorfromwindow
    return DllCall("User32.dll\MonitorFromWindow", "Ptr", Hwnd, "UInt", Hwnd?2:1)
}

GetMonitorInfo(hMonitor) {

	/*	DESCRIPCIÓN / DESCRIPTION

    Recupera información del monitor especificado.

    Return:
        Devuelve un objeto con las siguientes claves.
        L / T / R / B       = Rectángulo del monitor, expresado en coordenadas de pantalla virtual. Tenga en cuenta que si el monitor no es el principal, algunas de las coordenadas pueden ser negativas.
        WL / W T / W R / WB = Rectángulo del área de trabajo del monitor.  //
        Flags               = Un conjunto de valores que representan atributos del monitor de visualización.
            1 (MONITORINFOF_PRIMARY) = Este es el monitor de visualización principal.
        Name                = Una cadena que especifica el nombre del dispositivo del monitor que se está utilizando.

    Ejemplo:
        MsgBox(GetMonitorInfo(MonitorFromWindow()).Name)

	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	Retrieve information from the specified monitor.

     Return:
         Returns an object with the following keys.
         L / T / R / B = Monitor rectangle, expressed in virtual screen coordinates. Note that if the monitor is not the main one, some of the coordinates may be negative.
         WL / W T / W R / WB = Rectangle of the work area of the monitor. //
         Flags = A set of values that represent attributes of the display monitor.
             1 (MONITORINFOF_PRIMARY) = This is the main display monitor.
         Name = A string that specifies the name of the monitor device being used.

	*/

    ; GetMonitorInfo function
    ; https://docs.microsoft.com/es-es/windows/desktop/api/winuser/nf-winuser-getmonitorinfoa
    local MONITORINFOEX := ""
    VarSetCapacity(MONITORINFOEX, 104)
    NumPut(104, &MONITORINFOEX, "UInt")
    if (!DllCall("User32.dll\GetMonitorInfoW", "Ptr", hMonitor, "UPtr", &MONITORINFOEX))
        return FALSE
    return {  L:    	  NumGet(&MONITORINFOEX+ 4	, "Int")
		    	, T:    	  NumGet(&MONITORINFOEX+ 8	, "Int")
		    	, R:   	  NumGet(&MONITORINFOEX+12	, "Int")
		    	, B:    	  NumGet(&MONITORINFOEX+16	, "Int")
		    	, WL: 	  NumGet(&MONITORINFOEX+20	, "Int")
		    	, WT: 	  NumGet(&MONITORINFOEX+24	, "Int")
		    	, WR:	  NumGet(&MONITORINFOEX+28	, "Int")
				, WB: 	  NumGet(&MONITORINFOEX+32	, "Int")
		    	, Flags:   NumGet(&MONITORINFOEX+36	, "UInt")
		    	, Name: StrGet(&MONITORINFOEX+40,64	, "UTF-16") }
}

GetDpiForMonitor(hMonitor, Type := 0) {

	/*	DESCRIPCIÓN / DESCRIPTION

    Recupera los puntos por pulgada (ppp) del monitor especificado.

    Parámetros:
        Type:
            El tipo de DPI que se consulta. Los valores posibles son los siguientes. Este parámetro se ignora en WIN_8 o anterior.
            0 (MDT_EFFECTIVE_DPI)	= El DPI efectivo. Este valor se debe usar al determinar el factor de escala correcto para escalar elementos UI. Esto incorpora el factor de escala establecido por el usuario para esta pantalla específica.
            1 (MDT_ANGULAR_DPI)	= El DPI angular. Este DPI garantiza la reproducción con una resolución angular compatible en la pantalla. Esto no incluye el factor de escala establecido por el usuario para esta pantalla específica.
            2 (MDT_RAW_DPI)       	= El DPI sin procesar. Este valor es el DPI lineal de la pantalla medido en la pantalla. Use este valor cuando quiera leer la densidad de píxeles y no la configuración de escalamiento recomendada.
		                                         		Esto no incluye el factor de escala establecido por el usuario para esta pantalla específica y no se garantiza que sea un valor PPP admitido.

    Return:
        Si tuvo éxito devuelve un objeto con las claves X e Y, o cero en caso contrario.

    Observaciones:
        Esta función no es DPI Aware y no debe utilizarse si el thread de llamada es compatible con DPI por monitor. Para la versión de esta función que tiene en cuenta el DPI, consulte GetDpiForWindow.

    Ejemplo:
        MsgBox(GetDpiForMonitor(MonitorFromWindow()).X)

	Retrieve the dots per inch (dpi) of the specified monitor.

    Parameters:
        Type:
            The type of DPI that is consulted. Possible values ​​are as follows. This parameter is ignored in WIN_8 or earlier.
            0 (MDT_EFFECTIVE_DPI)	= The effective DPI. This value should be used when determining the correct scale factor to scale UI elements. This incorporates the scale factor set by the user for this specific screen.
            1 (MDT_ANGULAR_DPI)	= The angular DPI. This DPI guarantees playback with a compatible angular resolution on the screen. This does not include the scale factor set by the user for this specific screen.
            2 (MDT_RAW_DPI) 			= The raw DPI. This value is the linear DPI of the screen measured on the screen. Use this value when you want to read the pixel density and not the recommended scaling settings.
														This does not include the scale factor set by the user for this specific screen and is not guaranteed to be a supported PPP value.
    Return:
        If successful it returns an object with the keys X and Y, or zero otherwise.

    Observations:
        This function is not DPI Aware and should not be used if the call thread is compatible with DPI per monitor. For the version of this function that takes into account the DPI, see GetDpiForWindow.

    Example:
        MsgBox(GetDpiForMonitor(MonitorFromWindow()).X)

	*/

    local osv := StrSplit(A_OSVersion, ".")    ; https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/content/wdm/ns-wdm-_osversioninfoexw
    if (osv[1] < 6 || (osv[1] == 6 && osv[2] < 3))    ; WIN_8-
    {
        local hDC := 0, info := GetMonitorInfo(hMonitor)
        if (!info || !(hDC := DllCall("Gdi32.dll\CreateDC", "Str", info.name, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr")))
            return FALSE    ; LOGPIXELSX = 88 | LOGPIXELSY = 90
        return {X:DllCall("Gdi32.dll\GetDeviceCaps", "Ptr", hDC, "Int", 88), Y:DllCall("Gdi32.dll\GetDeviceCaps", "Ptr", hDC, "Int", 90)+0*DllCall("Gdi32.dll\DeleteDC", "Ptr", hDC)}
    }
    ; GetDpiForMonitor function
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shellscalingapi/nf-shellscalingapi-getdpiformonitor
    local dpiX := 0, dpiY := 0
    return DllCall("Shcore.dll\GetDpiForMonitor", "Ptr", hMonitor, "Int", Type, "UIntP", dpiX, "UIntP", dpiY, "UInt") ? 0 : {X:dpiX,Y:dpiY}
}

GetDpiForWindow(Hwnd) {

	/*	DESCRIPCIÓN / DESCRIPTION

	WIN10+

    Devuelve el valor de puntos por pulgada (ppp) para la ventana asociada.

	Returns the value of points per inch (dpi) for the associated window.

	*/

    ; GetDpiForWindow function
    ; https://docs.microsoft.com/es-es/windows/desktop/api/winuser/nf-winuser-getdpiforwindow
    return DllCall("User32.dll\GetDpiForWindow", "Ptr", Hwnd)
}

EnumDisplayDevices(DeviceName := "", DevNum := -1, Flags := 1) {

	/*	DESCRIPCIÓN / DESCRIPTION

    Enumera todos los dispositivos de visualización en la sesión actual.
    Parámetros:
        DeviceName:
            El nombre del dispositivo. Si es una cadena vacía, la función devuelve información para los adaptadores de pantalla en la máquina, según «DevNum».
        DevNum:
            Un valor de índice que especifica el dispositivo de visualización de interés. Si es -1 recupera todos.
    Return:
        Si tuvo éxito y DevNum es -1, devuelve un Array de objetos con la información del dispositivo.
        Si tuvo éxito y DevNum es mayor o igual a cero, devuelve un objeto con la inoformación del dispositivo.
        Si hubo un error devuelve cero.
        El objeto tiene las siguientes claves: DeviceName, DeviceString, StateFlags, DeviceID y DeviceKey. Ver el enlace de la estructura DISPLAY_DEVICE.
    Ejemplos:
        For DevIndex, Info in EnumDisplayDevices()    ; recupera información de todos los dispositivos de visualización
            MsgBox("DevIndex: " DevIndex "`nDeviceName: " Info.DeviceName "`nDeviceString: " Info.DeviceString "`nStateFlags: " Info.StateFlags "`nDeviceID: " Info.DeviceID "`nDeviceKey: " Info.DeviceKey)

        MsgBox(EnumDisplayDevices(,0).DeviceName)    ; recupera el nombre del dispositivo de visualización identificado con el índice cero
        MsgBox(EnumDisplayDevices(EnumDisplayDevices()[1].DeviceName,0).DeviceString)    ; recupera el nombre del monitor en el dispositivo de índice cero

	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	List all display devices in the current session.

     Parameters:
         DeviceName:
             The name of the device. If it is an empty string, the function returns information for the screen adapters on the machine, according to «DevNum».
         DevNum:
             An index value that specifies the display device of interest. If it is -1, recover all.

     Return:
         If it was successful and DevNum is -1, it returns an Array of objects with the device information.
         If it was successful and DevNum is greater than or equal to zero, it returns an object with the device information.
         If there was an error it returns zero.
         The object has the following keys: DeviceName, DeviceString, StateFlags, DeviceID and DeviceKey. See the structure link DISPLAY_DEVICE.

     Examples:
         For DevIndex, Info in EnumDisplayDevices()                                                                                        	; retrieve information from all display devices
             MsgBox("DevIndex:" DevIndex "` nDeviceName: "Info.DeviceName" `nDeviceString:" Info.DeviceString "` nStateFlags: "Info.StateFlags" `nDeviceID:" Info.DeviceID "` nDeviceKey: "Info.DeviceKey)

         MsgBox(EnumDisplayDevices(, 0) .DeviceName)                                                                                	; retrieves the name of the display device identified with the zero index
         MsgBox(EnumDisplayDevices(EnumDisplayDevice()[1].DeviceName,0).DeviceString)                      	; retrieve the name of the monitor on the zero index device

	*/

    local Devices := [], Address := 0

    Loop
    {
        ; DISPLAY_DEVICE structure
        ; https://docs.microsoft.com/es-es/windows/desktop/api/wingdi/ns-wingdi-_display_devicea
        Devices[Devices.Push({Buffer:""})].SetCapacity("Buffer", 840)
        NumPut(840, Address := Devices[A_Index].GetAddress("Buffer"), "UInt")

        ; EnumDisplayDevices function
        ; https://docs.microsoft.com/es-es/windows/desktop/api/winuser/nf-winuser-enumdisplaydevicesa
        if (!DllCall("User32.dll\EnumDisplayDevicesW", "UPtr", DeviceName==""?0:&DeviceName, "UInt", DevNum<0?A_Index-1:DevNum, "UPtr", Address, "UInt", Flags))
            break

        Devices[A_Index].DeviceName  	:= StrGet(Address+4, 32, "UTF-16")     		; The name of the device. This is the adapter device or the monitor device.
        Devices[A_Index].DeviceString  	:= StrGet(Address+68, 128, "UTF-16")     	; The device context string. This is a description of the display adapter or the display monitor.
        Devices[A_Index].StateFlags     	:= NumGet(Address+324, "UInt")            	; Device status indicators. It can be a combination of values.
        Devices[A_Index].DeviceID        	:= StrGet(Address+328, 128, "UTF-16")   	; Not used.
        Devices[A_Index].DeviceKey    	:= StrGet(Address+584, 128, "UTF-16")   	; reserved.

    } Until (A_Index > 1 && DevNum >= 0)

 return  Devices.Pop() && Devices.Length() ? (DevNum < 0 ? Devices : Devices[1]) : 0
}

