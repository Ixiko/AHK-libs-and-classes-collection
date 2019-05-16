### Note

This is an example branch, consider this branch and the entire repo in _alpha_ stage. This branch features one example function.

# Documentation

### `xDllCall`

Asynchronously calls a function in memory or inside a DLL, such as a standard Windows API function.

```autohotkey
xDllCall(callback, function, Type1, Arg1, Type2, Arg2, ..., ReturnType)
```

### Parameters

* `Callback`, a function object which will be called when the asynchronous exectution of `function` completes. This function must accept one parameter, see below. This parameter is optional.

The function does not return a value. The remaining parameters are the same as for the built-in function [`DllCall`](https://lexikos.github.io/v2/docs/commands/DllCall.htm) with the following differences,

* Suffix `*` or `p` is not supported for the types `astr/wstr/str`.
* At most `14` parameters are supported. 
* To call a variadic function on __64-bit__  build, specify `...`, (three dots) for the `ReturnType`, in addition to the (optional) calling convention and return type. The `...` is ignored on __32-bit__ build.

Once the function has been called, the script becomes persistent due to internal message monitoring, to turn off, call `xlib.threadHandler.OnMessageUnReg()`, when appropriate.

### The callback function

The callback function is called with one parameter, which is an object, holding the result from the execution of `function`. To retrieve the value of parameter `i`, access member `i` of the result object. I.e, `param_i := result[i]`. The return value is stored at `i := 0`. Example,

```autohotkey
callback := (result) => msgbox( 'The function returned: ' . result[0] . '.')
xDllCall callback, 'msvcrt.dll\atan2', 'double', 2.0, 'double', 3.0, 'cdecl double'
```

# Examples

There are three example files. The first parameter for all example functions are the script callback function `cb`. 

### Example 1

`_MsgBox([cb, msg := '', title := '', opt := 0])`

Displays a message box. When the user closes the message box the script callback is called with the result, the result is numeric, see [msdn](https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-messagebox).

* `msg`, string, the message to display.
* `title`, string, the title of the message box
* `opt`. numeric, options for the message  box, see [msdn](https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-messagebox)

### Example 2

Async wait for a window to be created.

```autohotkey
aWinWait(cb,
	lpszClass := '',
	lpszWindow := '',
	timeout := -1,
	hWndParent := 0,
	hWndChildAfter := 0)
```

* `timeout`, maximum time in __ms__ to wait for the window, maximum wait time is `0xffffffff`.
* `lpszClass`, string, the class name of the window to wait for.
* `lpszWindow`, string, the title of the window to wait for.
 
For all other parameters, see [msdn](https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-findwindowexw) (`FindWindowExW` function).

The function returns the `hwnd` of the found window, `0` is returned if the wait times out.

### Example 3

async wait for screen area to change

```autohotkey
OnScreenChange(cb,
	hwnd := 0,
	x := 0, y := 0, w := '', h := '',
	timeout := -1 ) 
```
* `hwnd`, handle to the window to consider, omit or pass `0` to consider the screen. Can also be an object: `{hwnd: hwnd, hrgnClip:hrgnClip, flags:flags}`, see [`GetDCEx`](https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-getdcex) documentation for details.
* `x, y, w, h`, integers, dimensions of client area unless `DCX_WINDOW` flag is set. If omitted, `w` and `h` defaults to the targets full _width_ and _height_
* `timeout`, integer, max time in ms to wait, pass `-1` to never stop waiting.

__Return__:

* `0`, the area changed
* `1`, timed out, no change
* `-1. -2`, indicates and error. Both errors will occur if the window doesn't exist, but the cause can be something else too.