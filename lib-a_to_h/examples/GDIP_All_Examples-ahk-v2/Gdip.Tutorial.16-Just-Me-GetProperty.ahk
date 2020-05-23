SetBatchLines, -1
#Include ..\Gdip_All.ahk
GDIPToken := Gdip_Startup()
PicFolder := ""
;_______________________________________________________________________________________________________________________
Gui, Margin, 20, 20
Gui, Add, ListBox, w600 r20 +Sort gShowPicProps vPicList
Gui, Add, Button, gSelectPics, Select Folder
Gui, Show, , Pictures
GoSub, SelectPics
Return
;_______________________________________________________________________________________________________________________
GuiClose:
   Gdip_Shutdown(GDIPToken)
ExitApp
;_______________________________________________________________________________________________________________________
SelectPics:
   StartingFolder := PicFolder <> "" ? "*" . PicFolder : ""
   FileSelectFolder, PicFolder, %StartingFolder%, 2, Select the pictures' folder, please!
   If (PicFolder = "")
      Return
   GuiControl, , PicList, |
   Loop, %PicFolder%\*.*, 0, 0
      If A_LoopFileExt In bmp,jpg,png
         GuiControl, , PicList, %A_LoopFileLongPath%
Return
;_______________________________________________________________________________________________________________________
ShowPicProps:
   GuiControlGet, Pic, , PicList
   If (Pic = "")
      Return
   Gui, +OwnDialogs
   GDIPImage := Gdip_LoadImageFromFile(Pic)
   ; PropArray := Gdip_GetPropertyIdList(GDIPImage)
   ; Msg := ""
   ; For ID, Name In PropArray
   ;    Msg .= ID . " : " . Name . "`r`n"
   ; MsgBox, %Msg%
   Properties := Gdip_GetAllPropertyItems(GDIPImage)
   If (ErrorLevel) || (Properties.Count = 0) {
      MsgBox, 16, Error %Errorlevel%, Couldn't get properties of image %Pic%
      Return
   }
   Gdip_DisposeImage(GDIPImage)
   Gui, New, +LastFound +Owner1 +LabelProps +ToolWindow
   Gui, Margin, 0, 0
   Gui, Add, ListView, Grid w600 r20, ID|Name|Length|Type|Value
   For ID, Val In Properties {
      If ID Is Integer
      {
         PropName := Gdip_GetPropertyTagName(ID)
         PropType := Gdip_GetPropertyTagType(Val.Type)
         If (PropType = "Byte") || (PropType = "Undefined") || (PropType = "Unknown")
            LV_Add("", ID, PropName, Val.Length, PropType, "")
         Else
            LV_Add("", ID, PropName, Val.Length, PropType, Val.Value)
      }
   }
   LV_ModifyCol(1, "Integer")
   Loop, % LV_GetCount("Column")
      LV_ModifyCol(A_Index, "AutoHdr")
   LV_ModifyCol(1, "Sort")
   Gui, Show, , % PIC . " - " . Properties.Count . " properties"
   WinWaitActive
   WinWaitClose
Return
;_______________________________________________________________________________________________________________________
PropsClose:
PropsEscape:
   Gui, Destroy
Return