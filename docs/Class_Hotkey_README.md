## Class Hotkey</br>
```AutoHotkey
hk := new Hotkey(_keyName, _callbacks*[, _enabled:="true"]) ; [hotkey]
jk := new Hotkey(_keyName, _callbacks*[, _enabled:="true"]) ; [joy hotkey]
```
##### description:</br>
Create a new hotkey instance.</br>
###### parameters:</br>
. ``_keyName`` [STRING]</br>
###### description:</br>
> The key to bind (such as `!i` for ALT+I, `^u` for CTRL+U, `#v` for WIN+V *etc*.) including the `Up` variant for any joy *button*: `1Joy3 Up`, `4Joy7 Up` *etc*. If a joy button is specified while the port number is omitted, the script will auto-determine it; that is, `JoyX` does not amounts in any case to specify `1JoyX`.</br>
#####
. ``_callbacks`` *VARIADIC* *OPTIONAL* [FUNC OBJECT|BOUNDFUNC OBJECT|STRING|OBJECT]</br>
###### description:</br>
> One or more functions to execute when the hotkey represented by `_keyName` fires. Each callback parameter can be either the name of a function, a function reference, a boundFunc object or an object which implements a `__Call` meta-function.</br>
#####
. ``_enabled`` *OPTIONAL* [BOOLEAN]</br>
###### description:</br>
> A boolean which determine whether or not the hotkey should start off in an initially-enabled state (defaults to `true`).</br>
#####
- The `__New` meta-function throws ErrorLevel upon failure (such as if, for instance, a callback is not valid).</br>
#####

## Properties
##
. ``hk/jk.keyName`` [STRING]</br>
##### description:</br>
> The hotkey name representing the hotkey. Note: when a hotkey is first created its key name is normalized. Modifiers are sorted into the following order:</br>
``* <^ <! <+ <# >^ >! >+ ># ^ ! + #``</br>
See also: https://github.com/Lexikos/xHotkey.ahk#hotkeynormalize</br>
#####
``hk/jk.enabled`` [BOOLEAN]</br>
##### description:</br>
> Contains `1` (`true`) if the hotkey is currently enabled or `0` (`false`) if it is disabled.</br>
#####
``hk/jk.isJoyHotkey`` [BOOLEAN]</br>
#####
##### description:</br>
> If the given hotkey is a joy hotkey, this variable contains `1`. Otherwise, it contains `0`.</br>
#####
``jk.portNumber``</br>
> ; ...</br>
#####
``jk.buttonNumber``</br>
> ; ...</br>
#####
``jk.ITERATOR_DELAY`` [INTEGER]</br>
##### description:</br>
> The delay, in miliseconds, after which the key, after being first held down, will be released and, then, pressed and released repetitively, as long as the joy button is hold down. Defaults to 300.</br>
#####
``jk.ITERATOR_PERIOD`` [INTEGER]</br>
##### description:</br>
> While the joy button is held down, the number of milliseconds that must pass before a new up&down event is simulated. Defaults to 95. For this very reason, the callback chain passed to the caller of the `__New` meta-function should be written to complete quickly.</br>
#####
``hk/jk.context``</br>
##### description:</br>
> The hotkey instance's own context object. Its keys - `type` and `title` - correspond to the first two criteria by which hotkeys are stored in `Hotkey.keyboard/joystick`. When modifying a hotkey instance -  *e.g.* by enabling it using the `enable` method -, it is internally and automatically reasserted.</br>
#####

## Methods
##
``hk/jk.delete()``</br>
##### description:</br>
> 'Delete' the given hotkey (though this does not delete the instance itself). In particular, this method differs from the disable one since it releases the object the key is bound to.</br>
#####
``hk/jk.enable()``</br>
##### description:</br>
> Enable a given hotkey.</br>
#####
``hk/jk.disable()``</br>
##### description:</br>
> Disable a given hotkey.</br>
#####
``jk.onReleased(_callbacks*)``</br>
##### description:</br>
> Returns a dual joy button hotkey by specifying for the given joy hotkey one or more functions to execute when the joy button is released.</br>
###### parameters:</br>
``_callbacks`` *VARIADIC* *OPTIONAL* [FUNC OBJECT|BOUNDFUNC OBJECT|STRING|OBJECT]</br>
###### description:</br>
> One or more functions to execute when the hotkey represented by `_keyName` fires. Each callback parameter can be either the name of a function, a function reference, a boundFunc object or an object which implements a `__Call` meta-function.</br>
#####

## Base object methods
##
``Hotkey.setContext([_type:="IfWinActive", _param:="A"])``</br>
##### description:</br>
> Make all subsequently-created hotkey(s) context sensitive.</br>
#####
###### parameters:</br>
``_type`` *OPTIONAL* [STRING]</br>
###### description:</br>
> The type of the context whose each subsequently created hotkeys will inherit. Can be either 'IfWinActive', 'IfWinNotActive', 'IfWinExist', 'IfWinNotExist' or 'If'.</br>
#####
``_param``</br>
###### description:</br>
> The title of the context whose each subsequently created hotkeys will inherit.</br>
. I. (`_type` is not 'If') *OPTIONAL* [STRING] A window title or other criteria identifying the target window.</br>
. II. (`_type` is 'If') [FUNC OBJECT|BOUNDFUNC OBJECT] A single variable or an expression containing an object with a call method (the hotkey will only execute if calling the given function object yields a non-zero number the moment it should fire).</br>
#####
``Hotkey.clearContext()``</br>
##### description:</br>
> Turn off context sensitivity for all potential subsequently-created hotkeys.</br>
#####
``Hotkey.deleteAll(_group:="")``</br>
##### description:</br>
> Delete all or a specific kind of hotkeys.</br>
###### parameters:</br>
``_group`` *OPTIONAL* [STRING]</br>
###### description:</br>
> Determine which group of hotkeys should be deleted, if need be. If specified, this parameter can be the name of a group created by means of the `setGroup` method. If omitted, all hotkeys will be deleted.</br>
#####
``Hotkey.enableAll(_group:="")``</br>
##### description:</br>
> Enable all or a specific kind of hotkeys.</br>
###### parameters:</br>
``_group`` *OPTIONAL* [STRING]</br>
###### description:</br>
> Determine which group of hotkeys should be enabled, if need be. If specified, this parameter can be the name of a group created by means of the `setGroup` method. If omitted, all hotkeys will be enabled.</br>
#####

``Hotkey.disableAll(_group:="")``</br>
##### description:</br>
> Disable all or a specific kind of hotkeys.</br>
###### parameters:</br>
``_group`` *OPTIONAL* [STRING]</br>
###### description:</br>
> Determine which group of hotkeys should be disabled, if need be. If specified, this parameter can be the name of a group created by means of the `setGroup` method. If omitted, all hotkeys will be disabled.</br>
#####

## Base object properties
##
``Hotkey["hk_group GroupName"]``</br>
##### description:</br>
> Each instance is stored in `Hotkey["hk_group GroupName"]`, directly in the base object, by means of its unique combination in which consist its normalized key name alongside the context it inherited upon its creation.</br>
#####
``Hotkey.baseContext``</br>
##### description:</br>
> The current context object which applies for each subsequently created hotkeys.</br>
#####
``Hotkey.setGroup(_group:="")``</br>
##### description:</br>
> Binds together a collection of related hotkeys. It affects all hotkeys physically beneath it in the script.</br>
###### parameters:</br>
``_group`` *OPTIONAL* [STRING]</br>
###### description:</br>
> If specified, the name of a group, henceforth binding together a collection of related hotkeys. If the group doesn't exist, it will be created. If omitted, `Hotkey._group` is set to the value `Default`.</br>
#####

###### Acknowledgements:</br>
Thanks to Runar "RUNIE" Borge, lord_ne and lexikos whose respective works served as bases for this one.</br>
. https://github.com/Run1e/Class_Hotkey; https://github.com/Run1e/Class_Hotkey/blob/master/Class%20Hotkey.ahk</br>
. https://autohotkey.com/boards/viewtopic.php?f=6&t=42071</br>
. https://github.com/Lexikos/xHotkey.ahk/blob/master/Lib/HotkeyNormalize.ahk</br>
