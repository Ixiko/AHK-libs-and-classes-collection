; ==================================================================================================================================
; !!! Win Vista+ !!!
; ==================================================================================================================================
#NoEnv
SetBatchLines, -1
Image := A_ScriptDir . "\DAD.png"
If !FileExist(Image)
   UrlDownloadToFile, https://autohotkey.com/assets/images/features-why.png, %Image%
; ==================================================================================================================================
#Include SHDoDragDrop.ahk
; ==================================================================================================================================
Clipboard := ""
DragImage := LoadPicture(Image, "GDI+ w72 h72")
Gui, +hwndHGUI
Gui, Margin, 20, 20
Gui, Add, ListView, w400 r5 gSubLV hwndHLV, Column 1|Column 2
Loop, 5
   LV_Add("", "Row " . A_Index, "Column 2")
DllCall("UxTheme.dll\SetWindowTheme", "Ptr", HLV, "WStr", "Explorer", "Ptr", 0)
Gui, Add, Text, xm wp , Click and drag a ListView item
Gui, Add, Text, xm wp hp+6 Center +0x200 gDragTextDef +Border, Copy some text (default drag image)
Gui, Add, Text, xm wp hp+0 Center +0x200 gDragTextUsr +Border, Move some text (user defined drag image)
Gui, Show, , Drop Source Test
Return
; ==================================================================================================================================
GuiClose:
ExitApp
; ==================================================================================================================================
SubLV:
If (A_GuiEvent == "D") {
   LV_GetText(Text, A_EventInfo)
   Clipboard := Text ? Text : "Test Text"
   GoSub, DragDropLV
}
Return
; ==================================================================================================================================
DragTextDef:
   Clipboard := "Copy some text"
   MsgBox, % SHDoDragDrop()
Return
; ==================================================================================================================================
DragTextUsr:
   Clipboard := "Move some text"
   MsgBox, % SHDoDragDrop(DragImage, , 2)
Return
; ==================================================================================================================================
DragDropLV:
   MsgBox, % SHDoDragDrop(HLV)
Return
; ==================================================================================================================================
ClipboardSetFiles(FilesToSet, DropEffect := "Copy") {
   Static SizeT := A_IsUnicode ? 2 : 1 ; size of a TCHAR
   Static PreferredDropEffect := DllCall("RegisterClipboardFormat", "Str", "Preferred DropEffect")
   Static DropEffects := {1: 1, 2: 2, Copy: 1, Move: 2}
   ; -------------------------------------------------------------------------------------------------------------------
   ; Count files and total string length
   TotalLength := 0
   FileArray := []
   Loop, Parse, FilesToSet, `n, `r
   {
      If (Length := StrLen(A_LoopField))
         FileArray.Push({Path: A_LoopField, Len: Length + 1})
      TotalLength += Length
   }
   FileCount := FileArray.Length()
   If !(FileCount && TotalLength)
      Return
   ; -------------------------------------------------------------------------------------------------------------------
   ; Add files to the clipboard
   If DllCall("OpenClipboard", "Ptr", A_ScriptHwnd) && DllCall("EmptyClipboard") {
      ; hMem format ---------------------------------------------------------------------------------------------------
      ; 0x42 = GMEM_MOVEABLE (0x02) | GMEM_ZEROINIT (0x40)
      hMem := DllCall("GlobalAlloc", "UInt", 0x42, "UInt", 20 + (TotalLength + FileCount + 1) * SizeT, "UPtr")
      pMem := DllCall("GlobalLock", "Ptr", hMem)
      Offset := 20
      NumPut(Offset, pMem + 0, "UInt")         ; DROPFILES.pFiles = offset of file list
      NumPut(!!A_IsUnicode, pMem + 16, "UInt") ; DROPFILES.fWide = 0 --> ANSI, fWide = 1 --> Unicode
      For Each, File In FileArray
         Offset += StrPut(File.Path, pMem + Offset, File.Len) * SizeT
      DllCall("GlobalUnlock", "Ptr", hMem)
      DllCall("SetClipboardData", "UInt", 0x0F, "UPtr", hMem) ; 0x0F = CF_HDROP
      ; Preferred DropEffect format ------------------------------------------------------------------------------------
      If (DropEffect := DropEffects[DropEffect]) {
         hMem := DllCall("GlobalAlloc", "UInt", 0x42, "UInt", 4, "UPtr")
         pMem := DllCall("GlobalLock", "Ptr", hMem)
         NumPut(DropEffect, pMem + 0, "UChar")
         DllCall("GlobalUnlock", "Ptr", hMem)
         DllCall("SetClipboardData", "UInt", PreferredDropEffect, "Ptr", hMem)
      }
      DllCall("CloseClipboard")
   }
   Return
}