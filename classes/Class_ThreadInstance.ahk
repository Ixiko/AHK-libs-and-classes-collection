/*
Allows you to create new instances of AutoHotKey and execute a specified Script
Notes:
• when the main process (the one that created all the instances) is terminated, all its instances are automatically terminated with it
• when the object is destroyed, so is the instance associated with it
• you will not be able to use any of these names for functions: Script_OnExit ()
• you will not be able to use any of these names for classes: Class_RegisterActiveObject
• the following variables should not be overridden for any reason: Object_Class_RegisterActiveObject
• you should not use any of these functions: OnExit ()
*/
class ThreadInstance {
	static Instances := []			;en esta variable almacenamos todas las instancias (processid) creadas
	static nCLSID := 1000		;esta variable la utilizamos para evitar repetir el CLSID al registrar el objeto activo (siempre debe tener 4 dígitos)

	/*
	Constructor: create new instance of AutoHotKey.exe that will run the specified script
	Parameters:
	• Script: script to execute
	• OnExitScript: here you should put the script that will be executed when an ExitApp is found in the new instance, since when creating the new instance, the built-in function of AHK OnExit () is used to delete the object on exit.
	• Wait: determines whether to wait until the new process ends
	• AhkPath: If the script is compiled, you will need to specify the path to AutoHotKey.exe (if it is not specified, check AutoHotKey.exe in the directory where the script is running or A_AhkPath)
	Variables of each instance or process:
	• ProcessId: PID of the new process
	Notes:
	• if Wait = TRUE, ErrorLevel is set in the process exit code and the call to __New () returns 0
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
	End process and delete active object
	*/
	Terminate() {
		try this.Call("ExitApp")
		DllCall("OleAut32.dll\RevokeActiveObject", "UInt", this.hRegister, "Ptr", 0)
		RegDeleteKey, HKCU\Software\Classes\%this.AppId%
		RegDeleteKey, HKCU\Software\Classes\CLSID\%this.CLSID%
		ThreadInstance.GetInstances()
	}

	/*
	gets an Array with all the PIDs of current existing processes started by this class
	*/
	GetInstances() {
		Instances := [] ;primero remueve procesos inexistentes del Array
		for Index, ProcessId in ThreadInstance.Instances
			if ProcessExist(ProcessId), Instances.Push(ProcessId)
		return ThreadInstance.Instances := Instances
	}

	/*
	Call the function specified in the new instance
	Parameters:
	• FuncName: name of the function to call
	• Params: parameters to pass
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
	change value to a variable
	*/
	SetVar(VarName, Value := "") {
		this.PipeOk := false
		this.ActiveObject.SetVar(VarName, Value)
		while !this.PipeOk
			Sleep 0
	}

	/*
	Set capacity of a variable
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
	Get value of a variable
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
	This function is used by the new process to send values to this process
	*/
	Pipe(OutputVar := "", Error := 0) {
		this.OutputVar := OutputVar
		this.Error := Error
		this.PipeOk := true
	}
}