#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.



	GLOBAL GUI_Color_FontControl := "009CA6", GUI_Color_BGControl := "0A0A0A"

	Gui, Add, Text,,`n Test ListView
	Gui, Add, ListView, r5 w400 vLV1 hwndhListView +AltSubmit +LV0x4000 r5, Title 1|Title 2|Title 3|Title 4|Title 5|Title 6
	gosub IconList


	;Set: Color for ListView Header
		Func_GUI_Control_Subclass(hListView, "Func_ListView_Header_CustomDraw")


	LV_Add("Icon1", "blabla", "1", "11", "abc abc abc abc abc abc abc abc abc abc")
	LV_Add("Icon2", "test", "2", "22",,"long text here, or there? .... blubb")
	LV_Add("Icon3", "nngg", "3", "33")
	LV_Add(, "343434", "4", "44")


	Gui, Show
	Return


GuiClose:
	ExitApp


IconList:
	LV_ImageList := IL_Create(, 1)
	, LV_SetImageList(LV_ImageList)

	Loop, 10
	{
		IL_Add(LV_ImageList, "Shell32.DLL", A_Index)
	}
	
	Return
	


; ----------------------------------------------------------------------------------------------------


Func_ListView_Header_CustomDraw(H, M, W, L, IdSubclass, RefData)
{
	;https:;www.autohotkey.com/boards/viewtopic.php?style=17&t=87318
	;by just me 07.03.2021
	
	Global GUI_Color_FontControl, GUI_Color_BGControl
	
	Static DC_Brush := DllCall("GetStockObject", "UInt", 18, "UPtr") ; DC_BRUSH = 18
	, DC_Pen := DllCall("GetStockObject", "UInt", 19, "UPtr") ; DC_PEN = 19
	, HDM_GETITEM := (A_IsUnicode ? 0x120B : 0x1203) ; ? HDM_GETITEMW : HDM_GETITEMA
	, OHWND := 0
	, OCode := (2 * A_PtrSize)
	, ODrawStage := OCode + A_PtrSize
	, OHDC := ODrawStage + A_PtrSize
	, ORect := OHDC + A_PtrSize
	, OItemSpec := ORect + 16
	, OItemState := OItemSpec + A_PtrSize
	, LM := 4 ; left margin of the first column (determined experimentally)
	, TM := 6 ; left and right text margins (determined experimentally)
	, Grid := 1 ; Grid Yes or No
	;, DefGridClr := DllCall("GetSysColor", "Int", 15, "UInt") ; COLOR_3DFACE
	
	
	;
	Critical 1000 ; ?
	;
	
	
	If (M = 0x004E) && (NumGet(L + OCode, "Int") = -12)
	{
		; WM_NOTIFY -> NM_CUSTOMDRAW
		
		
		;GET: Sending control's HWND
			HHD := NumGet(L + OHWND, "UPtr")
		
	  
		;Note: It's BGR instead of RGB!
			RegExMatch(GUI_Color_BGControl, "O)(.{0,2})(.{0,2})(.{0,2})", Dummy_Value)
			, GUI_Color_BG := "0x" Dummy_Value.Value( 3 ) Dummy_Value.Value( 2 ) Dummy_Value.Value( 1 )
			, RegExMatch(GUI_Color_FontControl, "O)(.{0,2})(.{0,2})(.{0,2})", Dummy_Value)
			, GUI_Color_FontNormal := "0x" Dummy_Value.Value( 3 ) Dummy_Value.Value( 2 ) Dummy_Value.Value( 1 )
		
		DrawStage := NumGet(L + ODrawStage, "UInt")
		
		; -------------------------------------------------------------------------------------------------------------
		
		If (DrawStage = 0x00010001)
		{
			; CDDS_ITEMPREPAINT
			
			;GET: The item's text, format and column order
				Item := NumGet(L + OItemSpec, "Ptr")
				, VarSetCapacity(HDITEM, 24 + (6 * A_PtrSize), 0)
				, VarSetCapacity(ItemTxt, 520, 0)
				, NumPut(0x86, HDITEM, "UInt") ; HDI_TEXT (0x02) | HDI_FORMAT (0x04) | HDI_ORDER (0x80)
				, NumPut(&ItemTxt, HDITEM, 8, "Ptr")
				, NumPut(260, HDITEM, 8 + (2 * A_PtrSize), "Int")
				, DllCall("SendMessage", "Ptr", HHD, "UInt", HDM_GETITEM, "Ptr", Item, "Ptr", &HDITEM)
				, VarSetCapacity(ItemTxt, -1)
				, Fmt := NumGet(HDITEM, 12 + (2 * A_PtrSize), "UInt") & 3
				, Order := NumGet(HDITEM, 20 + (3 * A_PtrSize), "Int")
			  
			;GET: The device context
				HDC := NumGet(L + OHDC, "Ptr")
			
			;Draw: A solid rectangle for the background
				VarSetCapacity(RC, 16, 0)
				, DllCall("CopyRect", "Ptr", &RC, "Ptr", L + ORect)
				, NumPut(NumGet(RC, "Int") + (!(Item | Order) ? LM : 0), RC, "Int")
				, NumPut(NumGet(RC, 8, "Int") + 1, RC, 8, "Int")
				, DllCall("SetDCBrushColor", "Ptr", HDC, "UInt", GUI_Color_BG)
				, DllCall("FillRect", "Ptr", HDC, "Ptr", &RC, "Ptr", DC_Brush)
			
			;Draw: The text
				DllCall("SetBkMode", "Ptr", HDC, "UInt", 0)
				, DllCall("SetTextColor", "Ptr", HDC, "UInt", GUI_Color_FontNormal)
				, DllCall("InflateRect", "Ptr", L + ORect, "Int", -TM, "Int", 0)
			
			; DT_EXTERNALLEADING (0x0200) | DT_SINGLELINE (0x20) | DT_VCENTER (0x04)
			; HDF_LEFT (0) -> DT_LEFT (0)
			; HDF_CENTER (2) -> DT_CENTER (1)
			; HDF_RIGHT (1) -> DT_RIGHT (2)
				DT_ALIGN := 0x0224 + ((Fmt & 1) ? 2 : (Fmt & 2) ? 1 : 0)
				, DllCall("DrawText", "Ptr", HDC, "Ptr", &ItemTxt, "Int", -1, "Ptr", L + ORect, "UInt", DT_ALIGN)
				
			
			;Draw: A 'Grid' Line
				If (Grid) && (Order)
				{
					DllCall("SelectObject", "Ptr", HDC, "Ptr", DC_Pen, "UPtr")
					, DllCall("SetDCPenColor", "Ptr", HDC, "UInt", GUI_Color_FontNormal)
					
					
					/*
					, L := NumGet(RC,  0, "Int") ; Left
					, T := NumGet(RC,  4, "Int") ; Top
					, R := NumGet(RC,  8, "Int") ; Right
					, B := NumGet(RC, 12, "Int") ; Bottom
					*/
					
					
					;Left
						, DllCall("Polyline", "Ptr", HDC, "Ptr", Func_SetRect( RCL, NumGet(RC,  0, "Int"), NumGet(RC,  4, "Int"), NumGet(RC,  0, "Int"), NumGet(RC, 12, "Int") ), "Int", 2)
					
					;Top
						, DllCall("Polyline", "Ptr", HDC, "Ptr", Func_SetRect( RCL, NumGet(RC,  0, "Int"), NumGet(RC,  4, "Int"), NumGet(RC,  8, "Int"), NumGet(RC, 4, "Int") ), "Int", 2)
					
					;Bottom
						, DllCall("Polyline", "Ptr", HDC, "Ptr", Func_SetRect( RCL, NumGet(RC,  0, "Int"), NumGet(RC, 12, "Int") - 1, NumGet(RC, 8, "Int"), NumGet(RC, 12, "Int") - 1 ), "Int", 2)
				}
			
			
			Return 4 ; CDRF_SKIPDEFAULT
		}
		
		; -------------------------------------------------------------------------------------------------------------
		
		If (DrawStage = 1)
		{
			; CDDS_PREPAINT
			Return 0x30 ; CDRF_NOTIFYITEMDRAW | CDRF_NOTIFYPOSTPAINT
		}
		
		; -------------------------------------------------------------------------------------------------------------
		
		
		If (DrawStage = 2)
		{
			; CDDS_POSTPAINT
			
			VarSetCapacity(RC, 16, 0)
			, DllCall("GetClientRect", "Ptr", HHD, "Ptr", &RC, "UInt")
			, Cnt := DllCall("SendMessage", "Ptr", HHD, "UInt", 0x1200, "Ptr", 0, "Ptr", 0, "Int") ; HDM_GETITEMCOUNT
			, VarSetCapacity(RCI, 16, 0)
			, DllCall("SendMessage", "Ptr", HHD, "UInt", 0x1207, "Ptr", Cnt - 1, "Ptr", &RCI) ; HDM_GETITEMRECT
			, R1 := NumGet(RC, 8, "Int")
			, R2 := NumGet(RCI, 8, "Int")
			
			If (R2 < R1)
			{
				
				;Conflict: with LVS_EX_LABELTIP LV0x4000 > shows only the background without text
				
				HDC := NumGet(L + OHDC, "UPtr")
				, NumPut(R2, RC, 0, "Int")
				, DllCall("SetDCBrushColor", "Ptr", HDC, "UInt", GUI_Color_BG)
				, DllCall("FillRect", "Ptr", HDC, "Ptr", &RC, "Ptr", DC_Brush)
				
				
				If (Grid)
				{
					DllCall("SelectObject", "Ptr", HDC, "Ptr", DC_Pen, "UPtr")
					, DllCall("SetDCPenColor", "Ptr", HDC, "UInt", GUI_Color_FontNormal)
					, NumPut(NumGet(RC, 0, "Int"), RC, 8, "Int")
					, DllCall("Polyline", "Ptr", HDC, "Ptr", &RC, "Int", 2)
				}
				
			}
			
			Return 4 ; CDRF_SKIPDEFAULT
		}
		
		
		; All other drawing stages ------------------------------------------------------------------------------------
		Return 0 ; CDRF_DODEFAULT
	}
	Else If (M = 0x0002)
	{
		; WM_DESTROY
		Func_GUI_Control_Subclass(H, "") ; remove the subclass procedure
	}
	
	
	; All messages not completely handled by the function must be passed to the DefSubclassProc:
	Return DllCall("DefSubclassProc", "Ptr", H, "UInt", M, "Ptr", W, "Ptr", L, "Ptr")
}


Func_SetRect(ByRef RC, L := 0, T := 0, R := 0, B := 0)
{
	VarSetCapacity(RC, 16, 0)
	, NumPut(L, RC,  0, "Int")
	, NumPut(T, RC,  4, "Int")
	, NumPut(R, RC,  8, "Int")
	, NumPut(B, RC, 12, "Int")
	
	Return &RC
}


Func_GUI_Control_Subclass(HCTL, FuncName, Data := 0)
{
	; ======================================================================================================================
	; SubclassControl	 Installs, updates, or removes the subclass callback for the specified control.
	; Parameters:		  HCTL	  -  Handle to the control.
	;						  FuncName -  Name of the callback function as string.
	;										  If you pass an empty string, the subclass callback will be removed.
	;						  Data	  -  Optional integer value passed as dwRefData to the callback function.
	; Return value:		Non-zero if the subclass callback was successfully installed, updated, or removed;
	;						  otherwise, False.
	; Remarks:			  The callback function must have exactly six parameters, see
	;						  SUBCLASSPROC -> msdn.microsoft.com/en-us/library/bb776774(v=vs.85).aspx
	; MSDN:				  Subclassing Controls -> msdn.microsoft.com/en-us/library/bb773183(v=vs.85).aspx
	; ======================================================================================================================
	
	Static ControlCB := []
	
	If ControlCB.HasKey(HCTL)
	{
		DllCall("RemoveWindowSubclass", "Ptr", HCTL, "Ptr", ControlCB[ HCTL ], "Ptr", HCTL)
		, DllCall("GlobalFree", "Ptr", ControlCB[ HCTL ], "Ptr")
		, ControlCB.Delete(HCTL)
		
		If (FuncName = "")
		{
			Return True
		}
	}
	
	If !DllCall("IsWindow", "Ptr", HCTL, "UInt")
	|| !IsFunc(FuncName) || (Func(FuncName).MaxParams <> 6)
	|| !(CB := RegisterCallback(FuncName, , 6))
		Return False
	
	If !DllCall("SetWindowSubclass", "Ptr", HCTL, "Ptr", CB, "Ptr", HCTL, "Ptr", Data)
	{
		Return (DllCall("GlobalFree", "Ptr", CB, "Ptr") & 0)
	}
	
	Return (ControlCB[ HCTL ] := CB)
}
