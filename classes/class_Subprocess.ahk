Subprocess_Run(args*)
{
	return new Subprocess(args*)
}

class Subprocess
{
	__New(cmd, cwd:="")
	{
		  DllCall("CreatePipe", "Ptr*", stdin_read, "Ptr*", stdin_write, "Ptr", 0, "UInt", 0)
		, DllCall("SetHandleInformation", "Ptr", stdin_read, "UInt", 1, "UInt", 1)
		, DllCall("CreatePipe", "Ptr*", stdout_read, "Ptr*", stdout_write, "Ptr", 0, "UInt", 0)
		, DllCall("SetHandleInformation", "Ptr", stdout_write, "UInt", 1, "UInt", 1)
		, DllCall("CreatePipe", "Ptr*", stderr_read, "Ptr*", stderr_write, "Ptr", 0, "UInt", 0)
		, DllCall("SetHandleInformation", "Ptr", stderr_write, "UInt", 1, "UInt", 1)

		static _STARTUPINFO
		if !VarSetCapacity(_STARTUPINFO) {
			sizeof_si := A_PtrSize==8 ? 104 : 68 ; 40 + 7*A_PtrSize + 2*(pad := A_PtrSize==8 ? 4 : 0)
			  VarSetCapacity(_STARTUPINFO, sizeof_si, 0)
			, NumPut(sizeof_si, _STARTUPINFO, "UInt")
			, NumPut(0x100, _STARTUPINFO, A_PtrSize==8 ? 60 : 44, "UInt") ; dwFlags=STARTF_USESTDHANDLES)
		}

		  NumPut(stderr_write
		, NumPut(stdout_write
		, NumPut(stdin_read, _STARTUPINFO, A_PtrSize==8 ? 80 : 56)))

		static sizeof_pi := 8 + 2*A_PtrSize
		this.SetCapacity("PROCESS_INFORMATION", sizeof_pi)
		proc_info := this.GetAddress("PROCESS_INFORMATION")

		if IsObject(cmd) {
			static quot := Func("Format").Bind("{1}{2}{1}", Chr(34))
			length := cmd.Length(), args := cmd, cmd := ""
			for i, arg in args
				cmd .= (InStr(arg, " ") ? quot.Call(arg) : arg) . (i<length ? " " : "")
		}

		success := DllCall("CreateProcess", "Ptr", 0, "Str", cmd, "Ptr", 0
			, "Ptr", 0, "Int", 1, "UInt", 0x8000000, "Ptr", 0, "Str", cwd=="" ? A_WorkingDir : cwd
			, "Ptr", &_STARTUPINFO, "Ptr", proc_info)
		if (!success)
			throw Exception("Failed to create process.", -1, cmd)

		this.StdIn  := new Subprocess.StreamWriter(stdin_write)
		this.StdOut := new Subprocess.StreamReader(stdout_read)
		this.StdErr := new Subprocess.StreamReader(stderr_read)

		  DllCall("CloseHandle", "Ptr", stdin_read)
		, DllCall("CloseHandle", "Ptr", stdout_write)
		, DllCall("CloseHandle", "Ptr", stderr_write)
	}

	__Delete()
	{
		  proc_info := this.GetAddress("PROCESS_INFORMATION")
		, DllCall("CloseHandle", "Ptr", NumGet(proc_info + 0))         ; hProcess
		, DllCall("CloseHandle", "Ptr", NumGet(proc_info + A_PtrSize)) ; hThread
	}

	__Handle[] ; hProcess
	{
		get {
			return NumGet(this.GetAddress("PROCESS_INFORMATION"))
		}
	}

	ProcessID[]
	{
		get {
			return NumGet(this.GetAddress("PROCESS_INFORMATION") + 2*A_PtrSize, "UInt") ; dwProcessId
		}
	}

	Status[] ; Running=0 , Done=1
	{
		get {
			return !(this.ExitCode == 259) ; STILL_ACTIVE=259
		}
	}

	ExitCode[] ; STILL_ACTIVE=259
	{
		get {
			if DllCall("GetExitCodeProcess", "Ptr", this.__Handle, "UInt*", exit_code)
				return exit_code
		}
	}

	Terminate(exit_code:=0)
	{
		if (exit_code == 259) ; STILL_ACTIVE
			throw Exception("Exit code 'STILL_ACTIVE' is reserved", -1, exit_code)

	; use gentler method - attempt to close window(s) first
		prev_dhw := A_DetectHiddenWindows
		DetectHiddenWindows On
		hwnd_lfw := WinExist() ; store current Last Found window

		wintitle := "ahk_pid " . this.ProcessID
		while (hwnd := WinExist(wintitle)) {
			WinClose
			if WinExist("ahk_id " . hwnd)
				WinKill
		}

		WinExist("ahk_id " . hwnd_lfw) ; restore Last Found window
		DetectHiddenWindows %prev_dhw%

	; still running, force kill
		if (this.Status == 0)
			DllCall("TerminateProcess", "Ptr", this.__Handle, "UInt", exit_code)
	}

	class Pipe
	{
		__New(handle)
		{
			this.__Handle := handle + 0
		}

		__Delete()
		{
			this.Close()
		}

		Close()
		{
			try this._Stream.Close(), this._Stream := ""
			DllCall("CloseHandle", "Ptr", this.__Handle)
		}

		_Stream := ""

		Stream[]
		{
			get {
				if (!this._Stream)
					this._Stream := FileOpen(this.__Handle, "h")
				return this._Stream
			}
		}

		Encoding[]
		{
			get {
				return this.Stream.Encoding
			}

			set {
				return this.Stream.Encoding := value
			}
		}
	}

	class StreamReader extends Subprocess.Pipe
	{
		Read(chars*)
		{
			return this.Stream.Read(chars*)
		}

		ReadLine()
		{
			return this.Stream.ReadLine()
		}

		ReadAll()
		{
			all := ""
			encoding := this.Encoding
			VarSetCapacity(data, 4096)
			while (read := this.Stream.RawRead(data, 4096))
				NumPut(0, data, read, "UShort"), all .= StrGet(&data, read, encoding)
			return all
		}

		RawRead(ByRef var_or_address, bytes)
		{
			return this.Stream.RawRead(var_or_address, bytes)
		}

		Peek(ByRef data:="", bytes:=4096, ByRef read:="", ByRef avail:="", ByRef left:="")
		{
			VarSetCapacity(data, bytes)
			return DllCall("PeekNamedPipe", "Ptr", this.__Handle, "Ptr", &data
				, "UInt", bytes, "UInt*", read, "UInt*", avail, "UInt*", left)
		}
	}

	class StreamWriter extends Subprocess.Pipe
	{
		Write(string)
		{
			return this.Stream.Write(string)
		}

		WriteLine(string)
		{
			return this.Stream.WriteLine(string)
		}

		RawWrite(ByRef var_or_address, bytes)
		{
			return this.Stream.RawWrite(var_or_address, bytes)
		}
	}
}