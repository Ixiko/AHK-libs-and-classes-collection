# HotClass
A class that enhances AutoHotkey's input detection (ie hotkeys) capabilities

Supports any combination of the following types of "key".  
Keyboard keys.  
Mouse Buttons: 1-5.  
Mouse Wheel: U,D,L,R.  
Joystick Buttons: 1-32  
Joystick POV Hat / Dpad Directions: U,D,L,R.  

Any number of keys, pressed in any order.  

##How it works
Keyboard / mouse input is read via `SetWindowsHookEx` callbacks.  Blocking of Keyboard / mouse input can be achieved through this call.  
Joystick Button down events are handled by AHK's hotkey command, up events are simulated with a `GetKeyState` loop.  
Joystick POV Hat detection is done via a `GetKeyState` loop.  