hwnd(win,hwnd=""){
	static window:=[]
	if (win.rem){
		Gui,% win.rem ":Destroy"
		return window.remove(win.rem)
	}
	if IsObject(win)
		return "ahk_id" window[win.1]
	if !hwnd
		return window[win]
	window[win]:=hwnd
	return % "ahk_id" hwnd
}