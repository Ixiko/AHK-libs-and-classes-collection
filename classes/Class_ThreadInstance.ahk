/*
/*
/*
Permite crear nuevas instancias de AutoHotKey y ejecutar un Script espesificado
Notas:
	• cuando el proceso principal (el que creo todas las instanacias) es terminado, todas sus instancias son automáticamente terminadas con él
	• cuando el objeto es destruido, tambien lo és la instancia asociada a él
	• no podrá utilizar ninguno de estos nombres para funciones: Script_OnExit()
	• no podrá utilizar ninguno de estos nombres para clases: Class_RegisterActiveObject
	• no deverá sobreescribir por ningún motivo las siguientes variables: Object_Class_RegisterActiveObject
	• no deverá utilizar ninguna de estas funciones: OnExit()
*/
class ThreadInstance {
	static Instances := []			;en esta variable almacenamos todas las instancias (processid) creadas
	static nCLSID := 1000		;esta variable la utilizamos para evitar repetir el CLSID al registrar el objeto activo (siempre debe tener 4 dígitos)

	/*
	Constructor: crear nueva instancia de AutoHotKey.exe que ejecutará el script espesificado
	Parámetros:
		• Script: script a ejecutar
		• OnExitScript: aquí debera poner el script q se ejecutará al encontrar un ExitApp en la nueva instancia, ya que al crea la nueva instancia, se utiliza la función incorporada de AHK OnExit() para eliminar el objeto al salir.
		• Wait: determina si se debe esperar hasta que el nuevo proceso termine
		• AhkPath: si el script está compilado, deberá espesificar la ruta a AutoHotKey.exe (si no se espesifica comprueba AutoHotKey.exe en el directorio en el que se está ejecutando el script o A_AhkPath)
	Variables de cada instancia o proceso:
		• ProcessId: PID del proceso nuevo
	Notas:
		• si Wait=TRUE, ErrorLevel se establece en el código de salida del proceso y la llamada a __New() devuelve 0
	*/
	__New(Script := "", OnExitScript := "", Wait := false, AhkPath := "") {
		if (A_IsCompiled) {
			
			;sin terminar. para funcionar, se necesita AutoHotKey.exe
			AhkPath := FileExist(A_ScriptDir . "\AutoHotKey.exe") ? A_ScriptDir . "\AutoHotKey.exe" : A_AhkPath
			
		} else AhkPath := A_AhkPath
		
		if !FileExist(AhkPath)
			return false
		
		;creamos un objeto activo para la instancia actual, para poder recibir valores del nuevo proceso
		this.AppId := "AHK-" . ThreadInstance.nCLSID
		thisCLSID := this.CLSID := "{B0FA566D-126C-" . ThreadInstance.nCLSID . "-BAF5-D74046AC1F50}"
		VarSetCapacity(GUID, 16, 0)
		if (DllCall("Ole32.dll\CLSIDFromString", "WStr", this.CLSID, "Ptr", &GUID) != 0), return false
		if (DllCall("OleAut32.dll\RegisterActiveObject", "Ptr", &this, "Ptr", &GUID, "UInt", 1, "UIntP", hRegister, "UInt") != 0), return false
		this.hRegister := hRegister
		RegWrite, REG_SZ, HKCU\Software\Classes\%this.AppId%,, % this.AppId
		RegWrite, REG_SZ, HKCU\Software\Classes\%this.AppId%\CLSID,, % this.CLSID
		RegWrite, REG_SZ, HKCU\Software\Classes\CLSID\%this.CLSID%,, % this.AppId
		
		;1) establecemos la ventana propietaria de la ventana del nuevo script a la del script actual
			;esto es para que cuando el proceso de éste script (o sea, el principal) termine, automáticamente terminen todos los proceso que éste inició (todo proceso tiene por lo menos una ventana)
		;2) registramos un objeto activo en el nuevo script para obtener información de éste, desde el script actual (o sea, el principal). Este objeto es manejable desde cualquier proceso sabiendo el CLSID
		;3) creamos una función para OnExit() y en ella añadimos funciones a DllCall para eliminar el Objeto Activo actual y restaurar la ventana propietaria (el escritorio) para poder terminar el proceso correctamente
		;Notas: si alguna función fallta, automáticamente el nuevo script termina
		AppId := "AHK" . ThreadInstance.nCLSID
		CLSID := "{B0FA566D-" . ThreadInstance.nCLSID . "-4ED7-BAF5-D74046AC1F50}"

		Script := "
		(
			DllCall('User32.dll\SetParent', 'Ptr', A_ScriptHwnd, 'Ptr', %A_ScriptHwnd%, 'Ptr')
			
			Object_Class_RegisterActiveObject := new Class_RegisterActiveObject('%CLSID%', '%AppId%')
			
			#Persistent
			#NoTrayIcon
			OnExit, Script_OnExit, 1
			VarSetCapacity(t, 4, 0), DllCall('Ntdll.dll\RtlAdjustPrivilege', 'UInt', 20, 'UChar', true, 'UChar', false, 'Ptr', &t)
			DllCall('Kernel32.dll\SetProcessWorkingSetSize', 'Ptr', DllCall('Kernel32.dll\GetCurrentProcess', 'Ptr'), 'UPtr', -1, 'UPtr', -1)
			%Script%
			
			Script_OnExit(ExitReason, ExitCode) {
				global Object_Class_RegisterActiveObject
				%OnExitScript%
				DllCall('OleAut32.dll\RevokeActiveObject', 'UInt', Object_Class_RegisterActiveObject.hRegister, 'Ptr', 0)
				RegDeleteKey, HKCU\Software\Classes\%AppId%
				RegDeleteKey, HKCU\Software\Classes\CLSID\%CLSID%
				DllCall('User32.dll\SetParent', 'Ptr', A_ScriptHwnd, 'Ptr', 0, 'Ptr')
				return 0
			}
			
			class Class_RegisterActiveObject {
				static Owner
				__New(CLSID, AppId) {
					try Class_RegisterActiveObject.Owner := ComObjActive('%thisCLSID%')
					catch
						ExitApp
					VarSetCapacity(GUID, 16, 0)
					if (DllCall('Ole32.dll\CLSIDFromString', 'WStr', CLSID, 'Ptr', &GUID) != 0), ExitApp
					if (DllCall('OleAut32.dll\RegisterActiveObject', 'Ptr', &this, 'Ptr', &GUID, 'UInt', 1, 'UIntP', hRegister, 'UInt') != 0), ExitApp
					this.hRegister := hRegister
					RegWrite, REG_SZ, HKCU\Software\Classes\`%AppId`%,, `% AppId
					RegWrite, REG_SZ, HKCU\Software\Classes\`%AppId`%\CLSID,, `% CLSID
					RegWrite, REG_SZ, HKCU\Software\Classes\CLSID\`%CLSID`%,, `% AppId
				}
				
				CallFunc(FuncName, Params*) {
					try if !Params.MaxIndex(), Result := `%FuncName`%()
					else Result := `%FuncName`%(Params*)
					this.Owner.Pipe(Result, ErrorLevel)
				}
					
				SetVar(VarName, Value) {
					global
					`%VarName`% := Value
					this.Owner.Pipe()
				}
				
				SetVarCapacity(VarName, Capacity, FillByte) {
					global
					if (Capacity = ""), Result := VarSetCapacity(`%VarName`%)
					else Result := VarSetCapacity(`%VarName`%, Capacity, FillByte)
					this.Owner.Pipe(Result)
				}
				
				GetVar(VarName) {
					global
					this.Owner.Pipe(`%VarName`%)
				}
			}
		)"
		ThreadInstance.nCLSID++ ;sumamos uno para evitar repetir el CLSID

		;creamos un archivo .ahk el cual ejecutará AutoHotKey.exe
		;en este proceso intentamos abrir un archivo .ahk en la carpeta temporal del sistema y escribimos el script en él
		RegDeleteKey, HKCU\Software\Classes\%AppId%
		Loop
			f := FileOpen(AhkScriptFile := A_Temp "\" A_Index ".ahk", "w-rwd")
		until IsObject(f)
		f.Write(Script), f.Close()
		
		;ejecutamos AutoHotKey.exe con la ruta del nuevo script.ahk
		;Run no modifica ErrorLevel, pero RunWait si, lo establece en el código de salida del proceso ejecutado
		if (Wait), RunWait, "%AhkPath%" "%AhkScriptFile%",,, PID
		else Run, "%AhkPath%" "%AhkScriptFile%",,, PID

		;comprobamos que se haya ejecutado correctamente y guardamos el PID
		if !(this.ProcessId := PID) || (Wait), return false
		ThreadInstance.Instances.Push(this.ProcessId)
		
		;esperamos hasta que la nueva instancia cree el objeto activo y lo guardamos para comunicarnos con la nueva instancia
		Loop
			RegRead("HKCU\Software\Classes\" AppId), Sleep(1)
		until !ErrorLevel || (A_Index = 400)
		try this.ActiveObject := ComObjActive(CLSID)
		catch
			return false
	}

	__Delete() {
		this.Terminate()
	}
	
	/*
	Terminar proceso y eliminar objeto activo
	*/
	Terminate() {
		try this.Call("ExitApp")
		DllCall("OleAut32.dll\RevokeActiveObject", "UInt", this.hRegister, "Ptr", 0)
		RegDeleteKey, HKCU\Software\Classes\%this.AppId%
		RegDeleteKey, HKCU\Software\Classes\CLSID\%this.CLSID%
		ThreadInstance.GetInstances()
	}
	
	/*
	obtiene un Array con todos los PIDs de procesos existentes actuales iniciados por esta clase
	*/
	GetInstances() {
		Instances := [] ;primero remueve procesos inexistentes del Array
		for Index, ProcessId in ThreadInstance.Instances
			if ProcessExist(ProcessId), Instances.Push(ProcessId)
		return ThreadInstance.Instances := Instances
	}
	
	/*
	Llama a la función espesificada en la nueva instancia
	Parámetros:
		• FuncName: nombre de la función a llamar
		• Params: parámetros a pasar
	*/
	Call(FuncName, Params*) {
		this.PipeOk := false
		if !Params.MaxIndex(), this.ActiveObject.CallFunc(FuncName)
		else this.ActiveObject.CallFunc(FuncName, Params*)
		while !this.PipeOk
			Sleep 0
		ErrorLevel := this.Error
		return this.OutputVar
	}

	/*
	Cambiar valor a una variable
	*/
	SetVar(VarName, Value := "") {
		this.PipeOk := false
		this.ActiveObject.SetVar(VarName, Value)
		while !this.PipeOk
			Sleep 0
	}
	
	/*
	Establecer capacidad de una variable
	*/
	SetVarCapacity(VarName, Capacity := "", FillByte := "") {
		this.PipeOk := false
		this.ActiveObject.SetVarCapacity(VarName, Capacity, FillByte)
		while !this.PipeOk
			Sleep 0
		ErrorLevel := this.Error
		return this.OutputVar
	}
	
	/*
	Obtener valor de una variable
	*/
	GetVar(VarName) {
		this.PipeOk := false
		this.ActiveObject.GetVar(VarName)
		while !this.PipeOk
			Sleep 0
		ErrorLevel := this.Error
		return this.OutputVar
	}
	
	;######################################################################################################################################################
	
	/*
	Esta función es utilizada por el nuevo proceso para mandar valores a éste proceso
	*/
	Pipe(OutputVar := "", Error := 0) {
		this.OutputVar := OutputVar
		this.Error := Error
		this.PipeOk := true
	}
}