; LintaList Include
; Purpose: Set and Toggle values for GUI (width, height and position of controls)
; Version: 1.0.3
; Date:    20170127

GuiStartupSettings:
SearchBoxWidth:=CompactWidth-30  ; Searchbox Width
YCtrl=26                         ; Y pos of controls (now only custom button bar controls)
YLView=45                        ; Y pos of Listview (e.g. bundle/search results)
ExtraLV=0
If (Width > CompactWidth)        ; if not change
	{
	 Yctrl=1
	 YLView=25
	 ExtraLV=20
	 barx:=Width-325
	}

Gosub, GuiRadioAndCheckPos

VisibleRows:=Ceil(LVHeight/20)  ; TODO: Calculate correct value for 20 for pagedown/pageup as is just a rough guess

Return

GuiToggleSettings:
If (Width < WideWidth)
	{
	 Width:=WideWidth
	 Height:=WideHeight
	 Yctrl=1
	 YLView=25
	 ExtraLV=20
	 barx:=Width-325  ; position of buttonbar
	}
Else
   { 
	Width:=CompactWidth
	Height:=CompactHeight
	Yctrl=26
	YLView=50
	ExtraLV=-5
	barx:=Width-329  ; position of buttonbar
   }	
Gosub, GuiRadioAndCheckPos
Return

GuiRadioAndCheckPos:

LVWidth:=Width-2                			; Listview Width
LVHeight:=Height-PreviewHeight-70+ExtraLV   ; Listview Height
YPosPreview:=Height-PreviewHeight-22    	; 

Return