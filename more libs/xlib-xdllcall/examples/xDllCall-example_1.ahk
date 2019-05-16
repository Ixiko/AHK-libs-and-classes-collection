; Basic msgbox example, press f1 to show messageboxes, script thread continues to run. Esc to exit script.

#include xdllcall.ahk

_msgbox(cb := '', msg := '', title := '', opt := 0){
	xdllcall cb, 'MessageBox', 'ptr', 0, 'str', msg, 'str', title, 'uint', opt, 'uint'
}

; Example
cb := (r) => msgbox( 'You clicked button: ' . r[] . '.')
ctr := 0


loop
	tooltip(a_index), sleep(25)

f1::_msgbox(cb, 'Hello from parallel thread: ' . ++ctr . '.', 'Title', [0x1,0x22,0x33,0x44][random(1,4)])
esc::exitapp