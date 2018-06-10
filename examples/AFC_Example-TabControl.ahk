
#include <CCtrlButton>
#include <CCtrlLabel>
#include <CCtrlEdit>
#include <CCtrlTab>

AFC_Entrypoint(MyGui)

class MyGui extends CWindow
{
	__New()
	{
		base.__New("Tab control test")
		ctrlTab := new CCtrlTab(this, "First|Second|Third")
		new CCtrlLabel(this, "Hello, world!")
		ctrlTab.BeginDef(2)
		new CCtrlLabel(this, "Another tab!")
		ctrlTab.BeginDef(3)
		new CCtrlLabel(this, "Yet another tab!")
		ctrlTab.BeginDef(1)
		new CCtrlButton(this, "Button")
		ctrlTab.EndDef()
		new CCtrlLabel(this, "I do not belong to any tab")
		this.Show()
	}
}
