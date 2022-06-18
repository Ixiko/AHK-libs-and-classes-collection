DetectContextMenu() { ; based on closeContextMenu() by Stefaan - http://www.autohotkey.com/community/viewtopic.php?p=163183#p163183

   GuiThreadInfoSize = 8 + 6 * A_PtrSize + 16
   VarSetCapacity(GuiThreadInfo, GuiThreadInfoSize)
   NumPut(GuiThreadInfoSize, GuiThreadInfo, 0)
   if !DllCall("GetGUIThreadInfo", "uint", 0, "ptr", &GuiThreadInfo)  {
      MsgBox GetGUIThreadInfo() indicated a failure.
      return
   }

   ; GuiThreadInfo contains a DWORD flags at byte 4
   ; Bit 4 of this flag is set if the thread is in menu mode. GUI_INMENUMODE = 0x4

return (NumGet(GuiThreadInfo, 4) & 0x4) ? true : false
}
