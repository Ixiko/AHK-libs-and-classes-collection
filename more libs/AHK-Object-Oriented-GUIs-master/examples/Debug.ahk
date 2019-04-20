disp(x*) {
	return Debug.Printer(x*)
}

m(x*) {
	msgbox % disp(x*)
	
}

p(x*) {
	static First := true ; haha hackety fuckin hack
	Debug.Print((First ? ("", First := false) : "`n") . Disp(x*))
}

t(x*) {
	static thisfunc := Func("t")
	tooltip % x ? disp(x*) : ""
	SetTimer, % thisfunc, % x ? 3500 : "Off"
}

Class Debug {
	__New() {
		static instance := new Debug()
		if instance
			return instance
		class := this.__Class
		%class% := this
		
		try
			Studio := ComObjActive("{DBD5A90A-A85C-11E4-B0C7-43449580656B}")
		catch e
			return this.StudioNotRunning()
		
		this.Pane := Studio.GetDebugPane()
		
		;this.Clear()
		this.Show()
	}
	
	Print(Print*) {
		try 
			this.Pane.Print(Debug.Printer(Print*))
		catch e
			this.StudioNotRunning()
	}
	
	Clear() {
		this.Pane.Clear()
	}
	
	Show() {
		this.Pane.Show()
	}
	
	Hide() {
		this.Pane.Hide()
	}
	
	StudioNotRunning() {
		; runs if program runs and it couldn't connect to the studio output pane
	}
	
	Class Log extends Debug.Functor {
		static LogFolder := A_ScriptDir "\logs" 
		
		Call(Exception) {
			if !FileExist(this.LogFolder)
				FileCreateDir % this.LogFolder
			this.Exception(Exception)
			soundbeep
		}
		
		Exception(ex, data := "") {
			Format := A_Hour ":" A_Min ":" A_Sec " (" A_DD "/" A_MM "/" A_YYYY ")"
			. "`n`nMessage: " ex.Remove("Message")
			. "`nWhat: " ex.Remove("What")
			. "`nFile: " ex.Remove("File")
			. "`nLine: " ex.Remove("Line")
			
			if StrLen(ex.Extra)
				Format .= "`n`nExtra:`n" ex.Remove("Extra")
			
			for junk in ex {
				Format .= "`n`nAdditional:`n" Debug.Printer(ex)
				break
			}
			
			if IsObject(data)
				Format .= "`n`nObject(s) dump:`n" Debug.Printer(data)
			
			FileOpen(this.LogFolder "\" A_Now A_MSec ".txt", "w").Write(StrReplace(Format, "`n", "`r`n"))
		}
		
		Folder(Folder) {
			this.LogFolder := Folder
		}
	}
	
	Class Functor {
		__Call(Type, Param*) {
			return (new this).Call(Param*)
		}
	}
	
	Class Printer extends Debug.Functor {
		static Indent := "      "
		static Open := "["
		static Close := "]"
		static Arrow := " -> "
		static TopSplit := ""
		static Ignore := ["Client", "SafeReference", "SafeRef", "Gui"]
		
		Call(Print*) {
			for Index, Value in Print
				text .= "`n" . (IsObject(Value) ? this.Object(Value) : Value)
			return SubStr(text, 2)
		}
		
		Object(Object, Indent := "", Seen := "") {
			if !Seen
				Seen := [], Top := true
			try {
				for Key, Value in Object {
					for Index, Val in this.Ignore
						if (Key = Val)
							continue
					out .= "`n" Indent this.Open Key this.Close
					if IsFunc(Value)
						out .= this.Arrow Value.Name
					else if IsObject(Value) {
						if Seen.HasKey(&Value) {
							out .= this.Arrow "(ALREADY PRINTED)"
							continue
						} Seen[&Value] := ""
						ObjVal := this.Object(Value, Indent this.Indent, Seen)
						out .= (ObjVal ? "`n" ObjVal : this.Arrow "[]")
					} else if (value * 0 = 0)
						out .= this.Arrow Value
					else
						out .= this.Arrow """" Value """"
					if Top
						out .= this.TopSplit
				}
			}
			return SubStr(out, 2)
		}
	}
}

Class Timer {
	__New() {
		static instance := new Timer()
		if instance
			return instance
		class := this.__Class
		%class% := this
		
		DllCall("QueryPerformanceFrequency", "Int64P", F)
		this.Freq := F
		this.Timers := {}
	}
	
	Current() {
		DllCall("QueryPerformanceCounter", "Int64P", Current)
		return Current / this.Freq
	}
	
	Start(ID) {
		this.Timers[ID] := this.Current()
	}
	
	Stop(ID) {
		return (this.Current() - this.Timers[ID]), this.Timers.Delete(ID)
	}
}