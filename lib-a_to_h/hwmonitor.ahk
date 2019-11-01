
GetCPUClock() {
    return GetSensorValue("CPU Core", "Clock")
}

GetGPUClock() {
    return GetSensorValue("GPU Core", "Clock")
}

GetCPULoad() {
    return GetSensorValue("CPU Total", "Load")
}

GetGPULoad() {
    return GetSensorValue("GPU Core", "Load")
}

GetCPUTemp() {
    temperature := GetSensorValue("CPU Package", "Temperature")
    if temperature
        return temperature
    return GetSensorValue("CPU Core", "Temperature")
}

GetGPUTemp() {
    return GetSensorValue("GPU Core", "Temperature")
}

; ListSensors("gpu")
; GetSensorValue("CPU Package", "Temperature")

; Available types: Load Temperature Voltage Power Clock Data SmallData Control Factor Fan Level
GetSensorValue(name, type)
{
    objItem:=ComObjGet("winmgmts:\\.\root\OpenHardwareMonitor").ExecQuery("select * from Sensor where SensorType = '" type "' and Name = '" name "'")
    if objItem.Count() < 1
    {
        return
    }
    for item in objItem
    {
        name := item.name
        value := item.value
        return value
    }
}

; list in powershell:
; get-wmiobject -namespace root\OpenHardwareMonitor -query 'select * from Sensor' | select name, value, sensortype, parent | sort sensortype
ListSensors(filter)
{
    s := ""
    for objItem in ComObjGet("winmgmts:\\.\root\OpenHardwareMonitor").ExecQuery("SELECT * FROM Sensor")
    {
        name := objItem.Name
        IfInString, name, %filter%
        {
            s .= objItem.Name " (" objItem.SensorType "): " objItem.Value "`n"
        }
    }
    MsgBox, %s%
}