; Example: A moving progress bar overlayed on a background image.

#include <CCtrlImage>
#include <CCtrlButton>
#include <CCtrlProgress>
#include <CCtrlLabel>

AFC_Entrypoint(MyApp)

class MyApp extends CWindow
{
	__New()
	{
		base.__New("Progress demo")
		this.SetColor("White")
		new CCtrlButton(this, "Start Moving the Bar", "Default xp+20 yp+250").OnEvent := this.Btn_OnClick
		this.prgr := new CCtrlProgress(this, 0, "w416 -Smooth")
		this.lbl := new CCtrlLabel(this, "", "wp")
		new CCtrlImage(this, "background.png", "x0 y0 0x4000000")
		this.Show()
		
		AFC_AtExit(this.ExitRoutine1)
		AFC_AtExit(this.ExitRoutine2)
	}
	
	Btn_OnClick()
	{
		Loop, %A_WinDir%\system32\*.*
		{
			if A_Index > 100
				break
			this.prgr.Value := A_Index
			this.lbl.Text := A_LoopFileName
			Sleep 50
		}
		this.lbl.Text := "Bar finished."
	}
	
	ExitRoutine1()
	{
		this.whatever := "Yeah, it worked."
	}
	
	ExitRoutine2()
	{
		MsgBox % this.whatever
	}
}
