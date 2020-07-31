; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

	
class Progress_Slider	{
	__New(pSlider_GUI_NAME , pSlider_Control_ID , pSlider_X , pSlider_Y , pSlider_W , pSlider_H , pSlider_Range_Start , pSlider_Range_End , pSlider_Value:=0 , pSlider_Background_Color := "Black" , pSlider_Top_Color := "Red" , pSlider_Pair_With_Edit := 0 , pSlider_Paired_Edit_ID := "" , pSlider_Use_Tooltip := 0 ,  pSlider_Vertical := 0 , pSlider_Smooth := 1){
		This.GUI_NAME:=pSlider_GUI_NAME
		This.Control_ID:=pSlider_Control_ID
		This.X := pSlider_X
		This.Y := pSlider_Y
		This.W := pSlider_W
		This.H := pSlider_H
		This.Start_Range := pSlider_Range_Start
		This.End_Range := pSlider_Range_End
		This.Slider_Value := pSlider_Value
		This.Background_Color := pSlider_Background_Color
		This.Top_Color := pSlider_Top_Color
		This.Vertical := pSlider_Vertical
		This.Smooth := pSlider_Smooth
		This.Pair_With_Edit := pSlider_Pair_With_Edit
		This.Paired_Edit_ID := pSlider_Paired_Edit_ID
		This.Use_Tooltip := pSlider_Use_Tooltip
		This.Add_pSlider()
	}
	Add_pSlider(){
		Gui, % This.GUI_NAME ":Add" , Text , % "x" This.X " y" This.Y " w" This.W " h" This.H " hwndpSliderTriggerhwnd"
		pSlider_Trigger := This.Adjust_pSlider.BIND( THIS ) 
		GUICONTROL +G , %pSliderTriggerhwnd% , % pSlider_Trigger
		if(This.Smooth=1&&This.Vertical=0)
			Gui, % This.GUI_NAME ":Add" , Progress , % "x" This.X " y" This.Y " w" This.W " h" This.H " Background" This.Background_Color " c" This.Top_Color " Range" This.Start_Range "-" This.End_Range  " v" This.Control_ID ,% This.Slider_Value
		else if(This.Smooth=0&&This.Vertical=0)
			Gui, % This.GUI_NAME ":Add" , Progress , % "x" This.X " y" This.Y " w" This.W " h" This.H " -Smooth Range" This.Start_Range "-" This.End_Range  " v" This.Control_ID ,% This.Slider_Value
		else if(This.Smooth=1&&This.Vertical=1)
			Gui, % This.GUI_NAME ":Add" , Progress , % "x" This.X " y" This.Y " w" This.W " h" This.H " Background" This.Background_Color " c" This.Top_Color " Range" This.Start_Range "-" This.End_Range  " Vertical v" This.Control_ID ,% This.Slider_Value
		else if(This.Smooth=0&&This.Vertical=1)
			Gui, % This.GUI_NAME ":Add" , Progress , % "x" This.X " y" This.Y " w" This.W " h" This.H " -Smooth Range" This.Start_Range "-" This.End_Range  " Vertical v" This.Control_ID ,% This.Slider_Value
	}
	Adjust_pSlider(){
		CoordMode,Mouse,Client
		while(GetKeyState("LButton")){
			MouseGetPos,pSlider_Temp_X,pSlider_Temp_Y
			if(This.Vertical=0)
				This.Slider_Value := Round((pSlider_Temp_X - This.X ) / ( This.W / (This.End_Range - This.Start_Range) )) + This.Start_Range
			else
				This.Slider_Value := Round(((pSlider_Temp_Y - This.Y ) / ( This.H / (This.End_Range - This.Start_Range) )) + This.Start_Range )* -1 + This.End_Range
			if(This.Slider_Value > This.End_Range )
				This.Slider_Value:=This.End_Range
			else if(This.Slider_Value<This.Start_Range)
				This.Slider_Value:=This.Start_Range
			GuiControl,% This.GUI_NAME ":" ,% This.Control_ID , % This.Slider_Value 
			if(This.Pair_With_Edit=1)
				GuiControl,% This.GUI_NAME ":" ,% This.Paired_Edit_ID , % This.Slider_Value 
			if(This.Use_Tooltip=1)
				ToolTip , % This.Slider_Value 
		}
		if(This.Use_Tooltip=1)
			ToolTip,
	}
	SET_pSlider(NEW_pSlider_Value){
		This.Slider_Value := NEW_pSlider_Value
		GuiControl,% This.GUI_NAME ":" ,% This.Control_ID , % This.Slider_Value
		if(This.Pair_With_Edit=1)
			GuiControl,% This.GUI_NAME ":" ,% This.Paired_Edit_ID , % This.Slider_Value
	}
}
