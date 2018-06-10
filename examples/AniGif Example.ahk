#SingleInstance force
SetBatchLines, -1

#Include AniGIF.ahk

Gui, +LastFound
guiID := WinExist() ; Get Hwnd for gui
Gui, Show, w500 h500

hAniGif := AniGif_CreateControl(guiID, 0, 0, 500, 500) ; Create Gif layer, x0 y0 width500 height500
AniGif_LoadGifFromFile(hAniGif, "test.gif") ; Load test.gif into gui
AniGif_SetBkColor(hAniGif, 0xF0F0F0) ; Set gif layer's background color to F0F0F0
Sleep, 5000
AniGif_UnloadGif(hAniGif) ; Unload gif, remove from gui
return