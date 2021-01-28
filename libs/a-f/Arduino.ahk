#include %A_ScriptDir%\include\Serial.ahk
; Arduino AHK Library
arduino_setup(start_polling_serial=true,ping_device=true){
	global
	ARDUINO_Settings = %ARDUINO_Port%:baud=%ARDUINO_Baud% parity=%ARDUINO_Parity% data=%ARDUINO_Data% stop=%ARDUINO_Stop% dtr=off ;to=off  xon=off odsr=off octs=off rts=off idsr=off
	ARDUINO_Handle := Serial_Initialize(ARDUINO_Settings)
	if ping_device {
		arduino_send("")
	}
	if (arduino_poll_serial_enabled := start_polling_serial) {
		SetTimer, arduino_poll_serial, -1
	}
}

arduino_send(data){
	global ARDUINO_Handle
	Serial_Write(ARDUINO_Handle, data)
	sleep, 50
	return arduino_read_raw()
}

arduino_read(){
	global ARDUINO_Handle
	return Serial_Read(ARDUINO_Handle, "0xFF", Bytes_Received)
}

arduino_read_raw(){
	global ARDUINO_Handle
	return Serial_Read_Raw(ARDUINO_Handle, "0xFF", "raw",Bytes_Received)
}

arduino_close(){
	global ARDUINO_Handle, arduino_poll_serial
	; turn off timer if it is running
	SetTimer, arduino_poll_serial, Off
	; wait a bit for timer to finished if it happened
	Sleep, 100
	Serial_Close(ARDUINO_Handle)
}

arduino_poll_serial:
	if (IsFunc(f:="OnSerialData")&&(arduino_poll_serial_enabled == true)){
		SerialData := arduino_read_raw()
		if SerialData {
				%f%(SerialData)
			}
		SetTimer, arduino_poll_serial, -1
	}else{
		MsgBox, OnSerialData function not defined. 
		SetTimer, arduino_poll_serial, Off
		arduino_poll_serial_enabled = false
		}
return
