# Entry points

AFC provides a structured way to organize your program's entry point.
You are expected to write an *application* class, which performs any necessary
tasks in its constructor.

## Examples

> ; Simple example - this is overkill
> AFC_EntryPoint(MyApp)
> 
> class MyApp
> {
>     __New(args)
>     {
>         MsgBox Hello, world!
>     }
> }

> ; Better example
> #include <CCtrlLabel>
> AFC_EntryPoint(GuiApp)
> 
> class GuiApp extends CWindow
> {
>     __New(args)
>     {
>         base.__New("Hello world")
>         new CCtrlLabel(this, "Hello, world!")
>         base.Show("w320 h240")
>     }
> }
