;-- Based on http://ahkscript.org/boards/viewtopic.php?f=5&t=8700 by jballi
;-- Modified by just me
#NoEnv
#SingleInstance, Force
ListLines, Off
SetBatchLines, -1
;-- DragDrop constants -------------------------------------------------------------------------------------------------------------
;-- DragDrop flags
DRAGDROP_S_DROP   := 0x40100 ; 262400
DRAGDROP_S_CANCEL := 0x40101 ; 262401
;-- DROPEFFECT flags
DROPEFFECT_NONE := 0 ;-- Drop target cannot accept the data.
DROPEFFECT_COPY := 1 ;-- Drop results in a copy. The original data is untouched by the drag source.
DROPEFFECT_MOVE := 2 ;-- Drag source should remove the data.
DROPEFFECT_LINK := 4 ;-- Drag source should create a link to the original data.
;-- Key state values (grfKeyState parameter)
MK_LBUTTON := 0x01   ;-- The left mouse button is down.
MK_RBUTTON := 0x02   ;-- The right mouse button is down.
MK_SHIFT   := 0x04   ;-- The SHIFT key is down.
MK_CONTROL := 0x08   ;-- The CTRL key is down.
MK_MBUTTON := 0x10   ;-- The middle mouse button is down.
MK_ALT     := 0x20   ;-- The ALT key is down.
; MK_BUTTON  := ?    ;-- Not documented.
;-- DragDrop includes --------------------------------------------------------------------------------------------------------------
#Include IDropTarget2.ahk
;-- GUI ----------------------------------------------------------------------------------------------------------------------------
Gui, +AlwaysOnTop
Gui, Margin, 20, 20
Gui, Add, ListView, r20 w700 hwndHLV vLV, #|FormatNum|FormatName|TYMED|Size|Value
Gui, Add, Text, xp y+2, % "   N/S = not supported"
Gui, Show, , ListView as Drop Target Example
;-- Register the ListView as a drop potential target for OLE drag-and-drop operations.
IDT_LV := IDropTarget_Create(HLV, "_LV", -1) ; no format required - only for testing purposes
Return
; ==================================================================================================================================
GUIClose:
GUIEscape:
;-- Revoke the registration of the ListView as a potential target for OLE drag-and-drop operations.
IDT_LV.RevokeDragDrop()
Gui, Destroy
ExitApp
; ==================================================================================================================================
; Drop user function called by IDropTarget on drop
; ==================================================================================================================================
IDropTargetOnDrop_LV(TargetObject, pDataObj, KeyState, X, Y, DropEffect) {
   ; Standard clipboard formats
   Static CF := {1:  "CF_TEXT"
               , 2:  "CF_BITMAP"
               , 3:  "CF_METAFILEPICT"
               , 4:  "CF_SYLK"
               , 5:  "CF_DIF"
               , 6:  "CF_TIFF"
               , 7:  "CF_OEMTEXT"
               , 8:  "CF_DIB"
               , 9:  "CF_PALETTE"
               , 10: "CF_PENDATA"
               , 11: "CF_RIFF"
               , 12: "CF_WAVE"
               , 13: "CF_UNICODETEXT"
               , 14: "CF_ENHMETAFILE"
               , 15: "CF_HDROP"
               , 16: "CF_LOCALE"
               , 17: "CF_DIBV5"
               , 0x0080: "CF_OWNERDISPLAY"
               , 0x0081: "CF_DSPTEXT"
               , 0x0082: "CF_DSPBITMAP"
               , 0x0083: "CF_DSPMETAFILEPICT"
               , 0x008E: "CF_DSPENHMETAFILE"}
   ; TYMED enumeration
   Static TM := {1:  "HGLOBAL"
               , 2:  "FILE"
               , 4:  "ISTREAM"
               , 8:  "ISTORAGE"
               , 16: "GDI"
               , 32: "MFPICT"
               , 64: "ENHMF"}
   Static CF_NATIVE := A_IsUnicode ? 13 : 1 ; CF_UNICODETEXT  : CF_TEXT
   ; "Private" formats don't get GlobalFree()'d
   Static CF_PRIVATEFIRST := 0x0200
   Static CF_PRIVATELAST  := 0x02FF
   ; "GDIOBJ" formats do get DeleteObject()'d
   Static CF_GDIOBJFIRST  := 0x0300
   Static CF_GDIOBJLAST   := 0x03FF
   ; "Registered" formats
   Static CF_REGISTEREDFIRST := 0xC000
   Static CF_REGISTEREDLAST  := 0xFFFF
   Gui, +OwnDialogs
   ; IDataObject_SetPerformedDropEffect(pDataObj, DropEffect)
   LV_Delete()
   GuiControl, -Redraw, LV
   If (pEnumObj := IDataObject_EnumFormatEtc(pDataObj)) {
      While IEnumFORMATETC_Next(pEnumObj, FORMATETC) {
         IDataObject_ReadFormatEtc(FORMATETC, Format, Device, Aspect, Index, Type)
         TYMED := "NONE"
         For Index, Value In TM {
            If (Type & Index) {
               TYMED := Value
               Break
            }
         }
         If (Format >= CF_REGISTEREDFIRST) && (Format <= CF_REGISTEREDLAST) {
            VarSetCapacity(Name, 520, 0)
            If !DllCall("GetClipboardFormatName", "UInt", Format, "Str", Name, "UInt", 260)
               Name := "*REGISTERED"
         }
         Else If (Format >= CF_GDIOBJFIRST) && (Format <= CF_GDIOBJLAST)
            Name := "*GDIOBJECT"
         Else If (Format >= CF_PRIVATEFIRST) && (Format <= CF_PRIVATELAST)
            Name := "*PRIVATE"
         Else If !(Name := CF[Format])
            Name := "*UNKNOWN"
         IDataObject_GetData(pDataObj, FORMATETC, Size, Data)
         If (Size = -1)
            Size := "N/S"
         ; Example for getting values out of the returned binary Data
         Value := "N/S"
         If Format In 1,7,13,15,16
         {
            If (Format = CF_NATIVE)       ; CF_TEXT or CF_UNICODETEXT
               Value := StrGet(&Data)
            Else If (Format = 16)         ; CF_LOCALE
               Value := NumGet(Data, "UInt")
            Else If (Format = 15) {       ; CF_HDROP
               LV_Add("", A_Index, Format, Name, TYMED, Size, "")
               If IDataObject_GetDroppedFiles(pDataObj, Files) {
                  For Each, File In Files
                     LV_Add("", "", "", "", "", "", File)
               }
               Continue
            }
         }
         Else If (Size = 4)
            Value := NumGet(Data, 0, "UInt")
         LV_Add("", A_Index, Format, Name, TYMED, Size, Value)
      }
      ObjRelease(pEnumObj)
   }
   Loop, % LV_GetCount("Column")
      LV_ModifyCol(A_Index, "AutoHdr")
   GuiControl, +Redraw, LV
   Effect := {0: "NONE", 1: "COPY", 2: "MOVE", 4: "LINK"}[DropEffect]
   SB_SetText("   DropEffect: " . Effect)
   Return DropEffect
}