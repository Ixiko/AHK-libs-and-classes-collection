# Python and AutoHotkey V2 call each other, ctypes implementation

## Use AutoHotkey V2 in Python
#### example1 Gui, Hotkey ...
```python
from ctypes import c_wchar_p
from pyahk import *

AhkApi.initialize()	# init ahk
AhkApi.addScript('''
; show tray icon
A_IconHidden:=0
f4::exitapp
#HotIf WinActive('ahk_exe notepad.exe')
''')

# import ahk's global vars, or AhkApi[varname]
from pyahk import Gui, MsgBox, FileAppend, Array, Map, JSON, Hotkey, HotIf, WinActive

def onbutton(ob, inf):
	v = ob.Gui['Edit1'].Value
	MsgBox(v)

g = Gui()
g.AddEdit('w320 h80', 'hello python')
g.AddButton(None, 'press').OnEvent('Click', onbutton)
g.show('NA')
arr = Array(8585, 'ftgy', 85, Map(85,244,'fyg', 58))
FileAppend(JSON.stringify(arr), '*')

def onf6(key):
	MsgBox(key)

@WINFUNCTYPE(None, c_wchar_p)
def onf7(key):
	MsgBox(key)

# Take effect under this condition
HotIf(lambda key: WinActive(g.hwnd))
Hotkey('F6', onf6)	# use ComProxy callback
# Use an existing conditional expression in ahk
HotIf("WinActive('ahk_exe notepad.exe')")
Hotkey('F7', onf7)	# use CFuncType callback
HotIf()

# ahk's message pump, block until the AHK interpreter exits
AhkApi.pumpMessages()
```

#### example2 ahk's VarRef
```python
from pyahk import *

AhkApi.initialize()	# init ahk
AhkApi.addScript('''
mul(&v) {
	v := v * v
	return v
}
''')

from pyahk import MouseGetPos, mul

print(MouseGetPos(Var(), Var(), Var(), Var()))
print(mul(InputVar(32)), mul(Var(32)))

# exit AHK interpreter
AhkApi.finalize()
```

## Use Python in AutoHotkey V2
```ahk
py := Python()
; import py's lib
; stdout := py.__import__('sys').stdout
py.exec('from sys import stdout')
ahk_arr := [213,4,'das',423.24,'fdg']
; ahk array to py list
; v2h.exe, IObject interface
; py.print(ahk_arr, l := py.list(ahk_arr))	; <IAhkObject object at 0x...> [213, 4, 'das', 423.24, 'fdg']

; v2l.exe, IDispatch interface
l := py.list()
for it in ahk_arr
	l.append(it)
py.print(ahk_arr, l)						; <pyahk.comproxy.Dispatch object at 0x...> [213, 4, 'das', 423.24, 'fdg']

py.stdout.flush()
; py list to ahk array
arr := [l*]
l := 0
```