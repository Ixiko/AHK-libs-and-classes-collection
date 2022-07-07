<pre>
+-- Class vKeyboard extends KeypadInterface
+-- Class KeypadInterface extends Keypad
¦   +-- Class _JoystickDevice extends Joystick.Device
¦   +-- Class _Hotkeys
¦   ¦   +-- Class Settings
¦   +-- Class _JoystickEventsManagement
+-- Class Keypad extends _Keypad
¦   +-- Class _HostWindowWrapper extends _KeypadEvents._HostWindowWrapper
¦   +-- Class _xAutocomplete extends eAutocomplete
¦   +-- Class _BasicOperations extends Keypad._BasicOperations._DefaultProcedures
¦   ¦   +-- Class _DefaultProcedures
¦   +-- Class _Callbacks
+-- Class _Keypad extends _KeypadEvents
+-- Class _KeypadEvents extends _KeypadAXObjectWrapper
¦   +-- Class _HostWindowWrapper
¦   +-- Class _KeypressHandler extends _Hotkey
+-- Class _KeypadGraphicsMapping extends _KeypadAXObjectWrapper
¦   +-- Class Keymap
+-- Class _KeypadAXObjectWrapper

+-- Class Joystick
¦   +-- Class DeviceManagement
¦   +-- Class Device
¦   ¦   +-- Class _Directional
¦   ¦   +-- Class DPad extends Joystick.Device._Directional
¦   ¦   +-- Class Thumbstick extends Joystick.Device._Directional
¦   +-- Class _Callbacks

+-- Class Hotkey extends _Hk
+-- Class _HotkeyIt extends __Hotkey__
+-- Class _Hotkey extends __Hotkey__
+-- Class __Hotkey__ extends _Hk
¦   +-- Class _Callbacks
+-- Class _Hk extends _Context
+-- Class _Context
+-- Class _JoyButtonKeypressHandler extends ObjBindTimedMethod
+-- Class ObjBindTimedMethod

+-- Class eAutocomplete
+-- Class JSON
</pre>
