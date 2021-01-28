; Link:
; Author:
; Date:
; for:     	AHK_L

/*


*/

#SingleInstance
#Include %A_ScriptDir%\..\class_NotifyTile.ahk

;DEMO CODE
str .= str .= str .= str := "The quick brown fox jumped over the lazy dog. "

;Show tiles with default 10s timeout
new NotifyTile(str, "Default Options")
new NotifyTile(str, "Size - 2 Rows", {"Size": "R2"})
new NotifyTile(str, "Size - 1 Row", {"Size": "R1"})
new NotifyTile(str, "Size - 4 Rows", {"Size": "R4"})
new NotifyTile(str, "Size - 5 Rows", {"Size": "R5"})
t := new NotifyTile("Tiles hang around for 10 seconds by default.")

while t.Hwnd
    Sleep(1000), t.ModMessage("Tiles hang around for 10 seconds by default.`n" (10 - A_Index) "...")

;Update titles and text
t := new NotifyTile(str, "Watch Closely", {"Time": 12})
Sleep(2000)
t.ModTitle("As the Title Changes")
Sleep(2000)
t.ModMessage("Along with the text.")
Sleep(2000)
t.ModTitle("Text that doesn't fit is truncated automatically")
Sleep(2000)
t.ModMessage("Works for both the title and the message text. "
           . "Works for both the title and the message text. "
           . "Works for both the title and the message text. "
           . "Works for both the title and the message text. ")

While t.Hwnd
    Sleep(200)

;Destroy tiles
t := []
Loop 5
    t.Push(new NotifyTile("Discard() lets you destroy a notification.", "Discard"))
Sleep(1500)
t[2].ModTitle("Bye!")
Sleep(500)
t.RemoveAt(2).Discard()
Sleep(500)
t[3].ModTitle("Bye!")
Sleep(500)
t.RemoveAt(3).Discard()
Sleep(1000)
Loop t.Length()
    t[A_Index].ModTitle("DiscardAll"), t[A_Index].ModMessage("DiscardAll() lets you destroy them all.")
Sleep(2000)
NotifyTile.DiscardAll()

Sleep(1000)
Loop 5
    new NotifyTile("DiscardAll(0) to destroy the notifications without animating them. It's faster", "DiscardAll(0)")
Sleep(4000)
NotifyTile.DiscardAll(0)
Sleep(1000)

;apply styles
NotifyTile.SetOption("Style", "Soft")
new NotifyTile("You can also create tiles with different styles if you'd prefer. There are a lot of options.", "Styles")
new NotifyTile("There is one built-in style (this one). Add more if you like!", "Styles")
Sleep(5000)
NotifyTile.DiscardAll()


;change sizes, go off screen, etc.
NotifyTile.SetOption({"Style": "", "HasButton": true, "Time": ""})
new NotifyTile("Make notifications stick around indefinitely. Let the user dismiss them with a button.", "You Can Also")
new NotifyTile("Change tile width", "You Can Also", {"W": 450})
new NotifyTile("Change tile height", "You Can Also", {"H": 400})
Loop 4
    new NotifyTile("Have notifications stack up until they're off the screen", "You Can Also")

;wait for user to dismiss all the tiles
While NotifyTile.GetActiveTile(1)
    Sleep(200)

;finish the demo
NotifyTile.SetModeTimeout()
new NotifyTile("If you haven't figured it out already, titles are optional.")
new NotifyTile("", "Message text is also optional")
NotifyTile.SetModeButton()
t := new NotifyTile("Dismiss this message to end the demo.", "That's it!")

While t.Hwnd
    Sleep(200)

NotifyTile.DiscardAll()

Return