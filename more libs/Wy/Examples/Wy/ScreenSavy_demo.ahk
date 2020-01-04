#include %A_ScriptDir%\..\..\lib\Wy\ScreenSavy.ahk

; Just get the screensaver properties
MsgBox("actived: " ScreenSavy.activated "`nsecured: " ScreenSavy.secured "`ntimeout: " ScreenSavy.timeout " sec`nexe: " ScreenSavy.exe)

; Toggling through ScreenSavy activation
sActivated1 := ScreenSavy.activated ; store the orignal state
ScreenSavy.activated := !ScreenSavy.activated
sActivated2 := ScreenSavy.activated ; state after first toogle
ScreenSavy.activated := !ScreenSavy.activated
sActivated3 := ScreenSavy.activated ; state after second toggle - should be the original state again ...
MsgBox("Toggling activation`n`nOriginal: " sActivated1 "`nAfter Toggle: " sActivated2 "`nRestored: " sActivated3 )

; Modify the ScreenSavy timeout
sTimeout1 := ScreenSavy.timeout ; Store original timeout
ScreenSavy.timeout := 999 ; set new timeout
sTimeout2 := ScreenSavy.timeout
ScreenSavy.timeout := sTimeout1 ; restore original timeout
MsgBox("Modifying timeout`n`nOriginal: " sTimeout1 "`nModified: " sTimeout2 "`nRestored: " ScreenSavy.timeout )

ExitApp