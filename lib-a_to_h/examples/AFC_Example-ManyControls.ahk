
#include %A_ScriptDir%\..\CCtrlButton.ahk
#include %A_ScriptDir%\..\CCtrlLabel.ahk
#include %A_ScriptDir%\..\CCtrlEdit.ahk
#include %A_ScriptDir%\..\CCtrlUpDown.ahk
#include %A_ScriptDir%\..\CCtrlListView.ahk
#include %A_ScriptDir%\..\CCtrlTreeView.ahk
#include %A_ScriptDir%\..\CCtrlStatusBar.ahk

AFC_Entrypoint(MyWin)

class MyWin extends CWindow
{
	__New()
	{
		Random, ov, 1, 10000
		base.__New("#" ov " - Hello, world!")
		this.SetFont("s10")
		new CCtrlLabel(this, "AFC Demonstration Window")
		this.SetFont()
		objButton := new CCtrlButton(this, "Testing", "Section")
		objButton.OnEvent := this.ButtonClick
		button2 := new CCtrlButton(this, "Login form", "ys")
		button2.OnEvent := this.ShowOtherGUI
		editBox := new CCtrlEdit(this, "", "ys")
		this.editBox := editBox
		buddyCtrl := new CCtrlEdit(this, "", "ys w100")
		updownCtrl := new CCtrlUpDown(buddyCtrl, 5, "Range1-10 Horz Left Wrap")
		lv := new CCtrlListView(this, "First column|Second column", "xs Section")
		lv.OnDoubleClick := this.lvDoubleClick
		lv.AddRow(["Hello", "world!"])

		tv := new CCtrlTreeView(this, "r7")
		tv.OnDoubleClick := this.tvDoubleClick

		p1 := tv.AddNode("First parent")
		p1c1 := p1.AddNode("Parent 1's first child")
		p2 := tv.AddNode("Second parent")
		p2c1 := p2.AddNode("Parent 2's first child")
		p2c2 := p2.AddNode("Parent 2's second child")
		p2c2c1 := p2c2.AddNode("Parent 2's second child's first child")

		sb := new CCtrlStatusBar(this)
		sb.OnClick := this.sbClick
		sb.SetPartText("Ready.")

		this.Show()
	}

	ButtonClick(oCtrl)
	{
		this.OwnDialogs()
		oCtrl.text := "Edited!"
		oCtrl.enabled := false
		text := this.editBox.Text
		MsgBox, Hello, world!`n%text%
		this.editBox.Text .= "WORKS"
	}

	ShowOtherGUI()
	{
		this.loginform := new CLoginForm(this)
		this.loginform.OnEvent := this.EnteredNameAndPass
	}

	EnteredNameAndPass(name, pass)
	{
		this.OwnDialogs()
		MsgBox,
		(LTrim
		Name: %name%
		Pass: %pass%
		)
	}

	lvDoubleClick(lv, row)
	{
		this.OwnDialogs()
		MsgBox % lv.Item[row, 1] ", " lv.Item[row, 2]
		lv.InsertRow(row+1, lv.RowData[row])
		lv.Item[row, 1] .= "TEST"
		lv.Item[row, 2] .= "EDITED"
		lv.AutoSizeCol()
	}

	tvDoubleClick(tv, node)
	{
		this.OwnDialogs()
		t := "Children of " node.Text ":`n`n"
		for i,child in node
			t .= "[" i "]: " child.Text "`n"
		MsgBox % t

		node.Text .= "EDITED"
		node.Bold := !node.Bold
	}

	sbClick(sb)
	{
		this.OwnDialogs()
		MsgBox, Hey, you clicked me!
		sb.SetPartText("You have already clicked me")
	}
}

class CLoginForm extends COwnedWindow
{
	__New(owner)
	{
		owner.SetOptions("+Disabled")
		base.__New(owner, "Log in", "-MinimizeBox")
		new CCtrlLabel(this, "Please enter the following:")
		new CCtrlLabel(this, "Username:", "w60 +Right Section")
		this.ctrlName := new CCtrlEdit(this, "username", "ys w100")
		new CCtrlLabel(this, "Password:", "xs w60 +Right Section")
		this.ctrlPass := new CCtrlEdit(this, "password", "ys w100 +Password")
		but := new CCtrlButton(this, "OK", "xs+60 w50 Default")
		but.OnEvent := this.ButtonOk
		this.Show()
	}

	ButtonOk()
	{
		name := this.ctrlName.Text
		pass := this.ctrlPass.Text
		if (name = "") || (pass = "")
		{
			this.OwnDialogs()
			MsgBox, 48,, You must enter a name and a password!
			return
		}
		this.Close()
		this.OnEvent.(this.owner, name, pass)
	}

	OnDestroy()
	{
		this.owner.SetOptions("-Disabled")
	}
}
