#SingleInstance Force

hLVIL := IL_Create(2)
IL_Add(hLVIL, "shell32.dll", 1)
IL_Add(hLVIL, "shell32.dll", 2)
Gui, Add, ListView, w450 h340 vTLV gLVClick AltSubmit +LV0x2, Col 1|Col 2|Col 3|Col 4|Col 5|Col 6|Col 7|Col 8|Col 9|Col 10
LV_SetImageList(hLVIL, 1)
LV_ModifyCol(1, 60)
LV_ModifyCol(2, 200)
LV_Add("Icon9999","test 22")
LV_Add("Icon9999","test 33")
LV_Add("Icon9999","test 59")
LV_Add("Icon9999","test 74")
LV_Add("Icon9999","test 26")
LV_Add("Icon9999","test 05")
LV_Add("","test")
LV_Add("Icon9999","test 15")
LV_Add("Icon9999","test 85")
LV_Add("Icon9999","test 62")
LV_Add("Icon9999","test 05")
LV_Add("Icon9999","test 94")
LV_Add("Icon9999","test 38")
LV_Add("Icon9999","test 55")
LV_Add("Icon9999","test 15")
LV_Add("Icon9999","test 08")
LV_Add("Icon9999","test 99")
LV_Add("Icon9999","test 42")
LV_Add("Icon9999","test 24")
LV_Add("Icon9999","test 88")

Gui, Add, Button, gGoBut vGoBut, test
Gui, Add, Text, w100 vLabel_Row, 0
Gui, Add, Text, w100 vLabel_Col, 0
Gui, Show



LVA_ListViewAdd("TLV", "AR ac cbsilver")

LVA_SetProgressBar("TLV", 1, 2, "s0xD8CB27 e0xFF91FF r200")
LVA_SetProgressBar("TLV", 3, 4, "bmaroon s0xD8CB27 r121")
LVA_SetProgressBar("TLV", 5, 2, "s0xD8CB27 e0xFF91FF Smooth")
LVA_SetCell("TLV", 2, 1, "red")
LVA_SetCell("TLV", 4, 1, "", "0x00F00A")
LVA_SetCell("TLV", 5, 1, "", "0x0000FF")
LVA_SetCell("TLV", 6, 0, "0xFFFFFF")
LVA_SetCell("TLV", 7, 0, "0x56B2C4")
LVA_SetCell("TLV", 0, 4, "0xFF00FF")
LVA_SetSubItemImage("TLV", 1, 2, 1)
LVA_SetSubItemImage("TLV", 2, 0, 2)
LVA_SetSubItemImage("TLV", 2, 1, 2)

LVA_SetCell("TLV", 8, 1, "white")
LVA_SetCell("TLV", 8, 2, "black")
LVA_SetCell("TLV", 8, 3, "silver")
LVA_SetCell("TLV", 9, 1, "gray")
LVA_SetCell("TLV", 9, 2, "maroon")
LVA_SetCell("TLV", 9, 3, "red")
LVA_SetCell("TLV", 10, 1, "purple")
LVA_SetCell("TLV", 10, 2, "fuchsia")
LVA_SetCell("TLV", 10, 3, "green")
LVA_SetCell("TLV", 11, 1, "lime")
LVA_SetCell("TLV", 11, 2, "olive")
LVA_SetCell("TLV", 11, 3, "yellow")
LVA_SetCell("TLV", 12, 1, "navy")
LVA_SetCell("TLV", 12, 2, "blue")
LVA_SetCell("TLV", 12, 3, "teal")
LVA_SetCell("TLV", 13, 1, "aqua")
LVA_SetCell("TLV", 14, 0, "black")

OnMessage("0x4E", "LVA_OnNotify")

return

GoBut:
GuiControl,,Label_Row, % LVA_GetCellNum("GetRows", "TLV")
GuiControl,,Label_Col, % LVA_GetCellNum("GetCols", "TLV")
LVA_SetCell("TLV", 6, 0)
LVA_SetCell("TLV", 7, 0)
LVA_Refresh("TLV")
Loop, 100
{
  LVA_Progress("TLV",1,2,A_Index)
  LVA_Progress("TLV",3,4,A_Index)
  LVA_Progress("TLV",5,2,A_Index)
  Sleep, 100
}
MsgBox, Now all colors and Progressbars will disappear !
LVA_EraseAllCells("TLV")
LVA_Refresh("TLV")
MsgBox, Even the alternating row coloring
LVA_ListViewModify("TLV", "-AR")
LVA_Refresh("TLV")
MsgBox, Now we change the alternating column colors
LVA_ListViewModify("TLV", "CBred")
LVA_Refresh("TLV")
sleep, 1000
LVA_ListViewModify("TLV", "CBblack")
LVA_Refresh("TLV")
sleep, 1000
LVA_ListViewModify("TLV", "CBred")
LVA_Refresh("TLV")
sleep, 1000
LVA_Refresh("TLV")
MsgBox, Now we remove the alternating column colors
LVA_ListViewModify("TLV", "-AC")
LVA_Refresh("TLV")
MsgBox, Now we play with the alternating rows
LVA_ListViewModify("TLV", "AR")
LVA_ListViewModify("TLV", "RBblack RFwhite")
LVA_Refresh("TLV")
sleep, 1000
LVA_ListViewModify("TLV", "RBfuchsia RFblack")
LVA_Refresh("TLV")
sleep, 1000
LVA_ListViewModify("TLV", "RBaqua")
LVA_Refresh("TLV")
sleep, 1000
LVA_ListViewModify("TLV", "RB0x27CBD8")
LVA_Refresh("TLV")
sleep, 1000
LVA_ListViewModify("TLV", "RB0xD8CB27 rfred")
LVA_Refresh("TLV")
sleep, 1000

return

LVClick:
  if (A_GuiEvent = "Normal")
  {
    LVA_GetCellNum(0, A_GuiControl)
    GuiControl,,Label_Row, % LVA_GetCellNum("Row")
    GuiControl,,Label_Col, % LVA_GetCellNum("Col")
  }
return

GuiClose:
ExitApp
return

; Uncomment following line if LVA.ahk is not inside the StdLib!
#Include LVA.ahk
