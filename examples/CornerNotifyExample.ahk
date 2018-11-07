#SingleInstance Force

CornerNotify(0, "Quick Flash", "This is a quick flash type of message. a a a a a a a a a a a a a a a a a a a a a")
Sleep 3000
CornerNotify(2, "2 Seconds", "This is a 2 second then fade message. Monkey giraffe zebra.")
Sleep 5000
CornerNotify(5, "5 Seconds", "This is a 5 second then fade message. It also uses the uses the optional parameter position=""b hc"" to indicate bottom horizontalcenter", "b hc")
Sleep 7000
CornerNotify(5, "5 Seconds (uses optional position argument)", "verticalcenter horizontalcenter", "vc hc")
Sleep 7000
CornerNotify(5, "5 Seconds (uses optional position argument)", "top horizontalcenter", "t hc")
Sleep 7000
CornerNotify(5, "5 Seconds (uses optional position argument)", "verticalcenter left", "vc l")
Sleep 7000
CornerNotify(5, "5 Seconds (uses optional position argument)", "verticalcenter right", "vc r")
Sleep 7000

#include CornerNotify.ahk
