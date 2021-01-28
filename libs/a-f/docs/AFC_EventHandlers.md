# Event handlers

AFC's event handling system works via callbacks. When a GUI event is fired,
the corresponding method is invoked upon the GUI object. This allows you to specify
event handlings via either including a method definition in your custom window class
or assigning a function reference.

Control events work the same way, except that their implicit `this` parameter refers
to their parent window object. This allows you to easily bind controls to event handler
methods in your class with a simple assignment: `controlObj.OnXYZ := this.MyHandler`.

## Examples

> ; This example shows how to bind an event handler to
> ; a raw-constructed window.
> 
> #include <CCtrlLabel> ; includes CWindow
> 
> ; Create the window
> gui := new CWindow("Event demo #1")
> 
> ; Create some controls
> new CCtrlLabel(gui, "Close me!")
> 
> ; Register an OnClose event handler
> gui.OnClose := Func("OnGuiClose")
> 
> ; Show the window
> gui.Show("w320 h240")
> 
> ; Our OnClose event handler
> OnGuiClose(guiObj)
> {
>     MsgBox, You closed it!
>     ExitApp
> }

> ; This example shows how to bind an event handler
> ; to a custom GUI class
> 
> #include <CCtrlLabel> ; includes CWindow
> AFC_EntryPoint(MyGui)
> 
> ; Our GUI class
> class MyGui extends CWindow
> {
>     __New()
>     {
>         ; Call the CWindow constructor
>         base.__New("Event demo #1")
>         
>         ; Create some controls
>         new CCtrlLabel(this, "Close me!")
>         
>         ; Show the window
>         this.Show("w320 h240")
>     }
>     
>     ; Our overriden OnClose() event handler
>     OnClose()
>     {
>         MsgBox, You closed it!
>         ExitApp
>     }
> }