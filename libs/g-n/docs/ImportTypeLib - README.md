## ImportTypeLib
This project will allow calling COM object methods by name even on non-dispatch methods by using type information interfaces

### Example
Sounds complicated? Here is how it will look:

```ahk
UIAutomation := ImportTypeLib(A_WinDir "\System32\UIAutomationCore.dll")
automation := new UIAutomation.IUIAutomation(new UIAutomation.CUIAutomation())

list := ""
for field, value in UIAutomation.TreeScope
	list .= "TreeScope." field " = " value "`n"
list .= "`n"
for field, value in UIAutomation.OrientationType
	list .= "OrientationType." field " = " value "`n"
MsgBox % list

desktop := new UIAutomation.IUIAutomationElement(automation.GetRootElement())
MsgBox % "Desktop process PID: " desktop.CurrentProcessId
MsgBox % "Desktop class: " desktop.CurrentClassName

MsgBox % "The desktop has " . (desktop.CurrentOrientation == UIAutomation.OrientationType.Horizontal ? "horizontal" : (desktop.CurrentOrientation == UIAutomation.OrientationType.Vertical ? "vertical" : "no")) . " orientation."
```

This will work for all COM interfaces for which a "type library" is available (in the example above, it is in `%A_WinDir%\System32\UIAutomationCore.dll`).