;#include xDllCall.ahk



msg := "Hello world."
ttl := "My box."
callback := (r) => msgbox("You clicked button: " r[]  "`nOn message box with text: "" r[2, "str"] "" and title: "" r[3, "str"] "".")
msgbox "Press F1 to show a new msgbox, press ESC to exit script."

loop
	tooltip(a_index), sleep(25)
	
esc::exitapp
f1::xDllCall callback, "MessageBox", "Ptr", 0, "Ptr", &msg, "Ptr", &ttl, "Uint", [0x1,0x22,0x33,0x44][random(1,4)]
