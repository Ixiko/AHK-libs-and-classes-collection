sleep, 500
WinActivate, SwingSet3
sleep, 1000
JavaControlDoAction(0, "GridBagLayout ", "toggle button", "Demonstrates GridBagLayout, a layout which allows to arrange components in containers.", "1", "left click")
; the action "left click" for clicking with the mouse is used as the SwingSet demo sometimes does not react to the direct "click action"

sleep, 2000
JavaControlDoAction(0, "JSplitPane ", "toggle button", "Demonstrates JSplitPane, a container which lays out two components in an adjustable split view (horizontal or vertical)", "1", "left click")
sleep, 3000
JavaControlDoAction(0, "Vertical Split", "radio button", "", "1", "click")
sleep, 2000
JavaControlDoAction(0, "Horizontal Split", "radio button", "", "1", "click")
sleep, 2000
JavaControlDoAction(0, "JList ", "toggle button", "Demonstrates JList, a component which supports display/editing of a data list", "1", "left click")
sleep, 2000
JavaControlDoAction(0, "Tera", "check box", "", "1", "click")
sleep, 2000
JavaControlDoAction(0, "Tera", "check box", "", "1", "click")
msgbox, Done!
return

#Include JavaAccessBridge.ahk
