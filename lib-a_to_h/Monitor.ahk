/*
    Recupera el identificador al monitor que está más cerca de la ventana especificada.
    Parámetros:
        Hwnd:
            El identificador de la ventana de interés. Si es cero, recupera el identificador del monitor primario.
*/
MonitorFromWindow(Hwnd := 0)
{
    ; MonitorFromWindow function
    ; https://docs.microsoft.com/es-es/windows/desktop/api/winuser/nf-winuser-monitorfromwindow
    return DllCall("User32.dll\MonitorFromWindow", "Ptr", Hwnd, "UInt", Hwnd?2:1)
}





/*
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
*/
GetMonitorInfo(hMonitor)
{
    ; GetMonitorInfo function
    ; https://docs.microsoft.com/es-es/windows/desktop/api/winuser/nf-winuser-getmonitorinfoa
    local MONITORINFOEX := ""
    VarSetCapacity(MONITORINFOEX, 104)
    NumPut(104, &MONITORINFOEX, "UInt")
    if (!DllCall("User32.dll\GetMonitorInfoW", "Ptr", hMonitor, "UPtr", &MONITORINFOEX))
        return FALSE
    return {     L: NumGet(&MONITORINFOEX+ 4, "Int"),  T: NumGet(&MONITORINFOEX+ 8, "Int"),  R: NumGet(&MONITORINFOEX+12, "Int"),  B: NumGet(&MONITORINFOEX+16, "Int")
           ,    WL: NumGet(&MONITORINFOEX+20, "Int"), WT: NumGet(&MONITORINFOEX+24, "Int"), WR: NumGet(&MONITORINFOEX+28, "Int"), WB: NumGet(&MONITORINFOEX+32, "Int")
           , Flags: NumGet(&MONITORINFOEX+36, "UInt")
           ,  Name: StrGet(&MONITORINFOEX+40, 64, "UTF-16") }
}





/*
    Recupera los puntos por pulgada (ppp) del monitor especificado.
    Parámetros:
        Type:
            El tipo de DPI que se consulta. Los valores posibles son los siguientes. Este parámetro se ignora en WIN_8 o anterior.
            0 (MDT_EFFECTIVE_DPI) = El DPI efectivo. Este valor se debe usar al determinar el factor de escala correcto para escalar elementos UI. Esto incorpora el factor de escala establecido por el usuario para esta pantalla específica.
            1 (MDT_ANGULAR_DPI)   = El DPI angular. Este DPI garantiza la reproducción con una resolución angular compatible en la pantalla. Esto no incluye el factor de escala establecido por el usuario para esta pantalla específica.
            2 (MDT_RAW_DPI)       = El DPI sin procesar. Este valor es el DPI lineal de la pantalla medido en la pantalla. Use este valor cuando quiera leer la densidad de píxeles y no la configuración de escalamiento recomendada. Esto no incluye el factor de escala establecido por el usuario para esta pantalla específica y no se garantiza que sea un valor PPP admitido.
    Return:
        Si tuvo éxito devuelve un objeto con las claves X e Y, o cero en caso contrario.
    Observaciones:
        Esta función no es DPI Aware y no debe utilizarse si el thread de llamada es compatible con DPI por monitor. Para la versión de esta función que tiene en cuenta el DPI, consulte GetDpiForWindow.
    Ejemplo:
        MsgBox(GetDpiForMonitor(MonitorFromWindow()).X)
*/
GetDpiForMonitor(hMonitor, Type := 0)
{
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





/*
    Devuelve el valor de puntos por pulgada (ppp) para la ventana asociada.
*/
GetDpiForWindow(Hwnd)    ; WIN_10+
{
    ; GetDpiForWindow function
    ; https://docs.microsoft.com/es-es/windows/desktop/api/winuser/nf-winuser-getdpiforwindow
    return DllCall("User32.dll\GetDpiForWindow", "Ptr", Hwnd)
}





/*
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
*/
EnumDisplayDevices(DeviceName := "", DevNum := -1, Flags := 1)
{
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

        Devices[A_Index].DeviceName   := StrGet(Address+4, 32, "UTF-16")      ; El nombre del dispositivo. Este es el dispositivo adaptador o el dispositivo monitor.
        Devices[A_Index].DeviceString := StrGet(Address+68, 128, "UTF-16")    ; La cadena de contexto del dispositivo. Esta es una descripción del adaptador de pantalla o del monitor de pantalla.
        Devices[A_Index].StateFlags   := NumGet(Address+324, "UInt")          ; Indicadores de estado del dispositivo. Puede ser una combinación de valores.
        Devices[A_Index].DeviceID     := StrGet(Address+328, 128, "UTF-16")   ; No utilizado.
        Devices[A_Index].DeviceKey    := StrGet(Address+584, 128, "UTF-16")   ; Reservado.
    } Until (A_Index > 1 && DevNum >= 0)

    return  Devices.Pop() && Devices.Length() ? (DevNum < 0 ? Devices : Devices[1]) : 0
}
