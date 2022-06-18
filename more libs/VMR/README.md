<h1 align="center">
VMR.ahk
</h1>
<p align="center">
  AutoHotkey wrapper class for Voicemeeter Remote API.
</p>

## Getting Started
To use `VMR.ahk` in your script, follow these steps:
1.  Include it using `#Include VMR.ahk` or copy it to a [library folder](https://www.autohotkey.com/docs/Functions.htm#lib) and use `#Include <VMR>`

2.  create an object of the VMR class:
    ```ahk
        voicemeeter:= new VMR()
    ```
    you can optionally pass the path for voicemeeter's folder:
    ```ahk
        voicemeeter:= new VMR("C:\path\to\voicemeeter\")
    ```
3.  call the `login()` method:
    ```ahk
        voicemeeter.login()
    ```
4. The `VMR` object will have two arrays (`bus` and`strip`), as well as other objects, that will allow you to control voicemeeter in AHK.
    ```ahk
        voicemeeter.bus[1].mute:= true
        voicemeeter.strip[4].gain++
    ```

##### For more info, check out the [documentation](https://saifaqqad.github.io/VMR.ahk/)
