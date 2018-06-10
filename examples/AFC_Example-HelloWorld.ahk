
#include <CCtrlLabel>
#include <CCtrlButton>

AFC_EntryPoint(HelloWorldApp)
class HelloWorldApp extends CWindow
{
	times := 0
	
	__New()
	{
		base.__New("Hello World")
		new CCtrlLabel(this, "Hello world!")
		new CCtrlButton(this, "Click me").OnEvent := this.BtnClick
		this.lbl := new CCtrlLabel(this, "You have not clicked the button yet.")
		this.Show("w320 h240")
	}
	
	BtnClick()
	{
		this.OwnDialogs()
		MsgBox, Hello world!
		this.lbl.Text := "You have clicked it " (++this.times) " times."
	}
}
