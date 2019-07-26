class class_progress {
	static Instances := []

	__New(MainText = "", ProgressBar = "", SubText = "", ProgressBar2 = "", SubText2 = "") {
		Gui, New, +hwndhwnd
		this.hwnd := hwnd
		class_progress.Instances[hwnd] := this
		this.Events := []
		this.Events["Close"] := this.Close.Bind(this)
		
		; properties
		w := 400
		m := 5
		Gui % this.hwnd ":Margin", % m, % m
		
		; controls
		If (MainText) {
			Gui % this.hwnd ":Font", s11 w700
			Gui % this.hwnd ":Add", text, % "w" w " center", % MainText
			Gui % this.hwnd ":Font"
		}
			
		If (ProgressBar) {
			Gui % this.hwnd ":Add", progress, % "w" w - (m * 2) " h20 BackgroundE6E6E6 Border"
			Gui % this.hwnd ":Add", text, % "w" w " y+-17 +Center +BackgroundTrans +0x200"
		}
	
		If (SubText) {
			Gui % this.hwnd ":Font", s11
			Gui % this.hwnd ":Add", text, % "w" w " center", % SubText
			Gui % this.hwnd ":Font"
		}
		
		If (ProgressBar2) {
			Gui % this.hwnd ":Add", progress, % "w" w - (m * 2) " h20 BackgroundE6E6E6 Border"
			Gui % this.hwnd ":Add", text, % "w" w " y+-17 +Center +BackgroundTrans +0x200"
		}
			
		If (SubText2) {
			Gui % this.hwnd ":Font", s11
			Gui % this.hwnd ":Add", text, % "w" w " center", % SubText2
			Gui % this.hwnd ":Font"
		}
	
		Gui % this.hwnd ":Show"
	}
	
	MainText(input) {
		GuiControl % this.hwnd ":",  static1, % input
	}
	
	ProgressBar(input) {
		GuiControl % this.hwnd ":",  msctls_progress321, % input
		
		If !(this.PBMaxRange = "")
			this.ProgressBarIncrement(input)
	}
	
	ProgressBarMaxRange(input) {
		this.PBMaxRange := input, this.PBCount := 0
		
		GuiControl % this.hwnd ":+Range0-" input,  msctls_progress321
		GuiControl % this.hwnd ":",  msctls_progress321, 0
		this.ProgressBarIncrement()
	}
	
	ProgressBarIncrement(input = "") {
		If (input)
			this.PBCount += StrReplace(input, "+")
		GuiControl % this.hwnd ":",  static2, % this.PBCount " / " this.PBMaxRange
	}
	
	SubText(input) {
		GuiControl % this.hwnd ":",  static3, % input
	}
	
	ProgressBar2(input) {
		GuiControl % this.hwnd ":",  msctls_progress322, % input
		
		If !(this.PB2MaxRange = "")
			this.ProgressBar2Increment(input)
	}
	
	ProgressBar2MaxRange(input) {
		this.PB2MaxRange := input, this.PB2Count := 0
		
		GuiControl % this.hwnd ":+Range0-" input,  msctls_progress322
		GuiControl % this.hwnd ":",  msctls_progress322, 0
		this.ProgressBar2Increment()
	}
	
	ProgressBar2Increment(input = "") {
		If (input)
			this.PB2Count += StrReplace(input, "+")
		GuiControl % this.hwnd ":",  static4, % this.PB2Count " / " this.PB2MaxRange
	}
	
	SubText2(input) {
		GuiControl % this.hwnd ":",  static5, % input ; also show x out of y. where x is the minimum range and y the maximum
	}
	
	Close() {
		msgbox, 68, % A_ScriptName, Are you sure you want to exit the program?
		IfMsgBox, No
			return
		exitapp
	}
	
	Destroy() {
		class_progress.Instances := ""
		this.Events := ""
	}
	
	__Delete() {
		Gui % this.hwnd ":Destroy"
	}
}

GuiClose:
	for a, b in class_progress.Instances 
		if (a = A_Gui+0)
			b["Events"][SubStr(A_ThisLabel, 4)].Call()
			
return