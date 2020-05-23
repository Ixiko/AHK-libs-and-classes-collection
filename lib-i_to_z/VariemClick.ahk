;================================================================================================
;
; Function:     VariemClick
; Description:  Finds and Clicks multiple instances of a single image on screen and
;		if no image is found it increases the allowed variation for the next search
;
;		The function Also returns a Sting with ether a error message or
;		a list of X,Y coord clicked and the variation used
;
; Online Ref.:  http://www.autohotkey.com/forum
;
; Last Update:  19/4/2012 12:00
;
; Created by:   Blackholyman
;               http://www.autohotkey.com/community/memberlist.php?mode=viewprofile&u=55126
;
; Thanks to:    All the Ahk forum members that post code examples for me to learn from
;
;================================================================================================
;
; VariemClick(ImageFile [, NumberOfTries, Start_Vari, Max_Vari, Click_X_Offset, Click_Y_Offset, WaitBetweenClicks]
;
;================================================================================================
;
; * The parameters for this function are:
;
; + Required parameters:
;
; - ImageFile			The full file path must be enclosed in "" double quotes for ImageSearch to use
;
; + Optional parameters:
;
; - NumberOfTries		Number Of times to find `n click or increse the variation (default is 10)
; - Start_Vari			Allowed shades of variation to start with (default is 0)
; - Max_Vari			Maximum shades of variation to be used (default is 80)
; - Click_X_Offset		Offset from the X coordinate to use (default is 0)
; - Click_Y_Offset		Offset from the Y coordinate to use (default is 0)
; - WaitBetweenClicks		Time to Wait Between Clicks (default is 1/10 of a second)
;
;================================================================================================



VariemClick(ImageFile, NumberOfTries=10, Start_Vari=0, Max_Vari=80, Click_X_Offset=0, Click_Y_Offset=0, WaitBetweenClicks=100) {
StartTime := A_TickCount					;Store the time of start
BatchSave := A_BatchLines					;Store BatchLines current setting
MouseDelay := A_MouseDelay					;Store MouseDelays current setting
SetBatchLines -1						;Set the between lines sleep to -1
SetMouseDelay -1						;set MouseDelay to -1
CoordMode, ToolTip						;Set the ToolTips to use screen coordinates
Loop % NumberOfTries
	{
	ImageSearch, X, Y, 0, 0, A_ScreenWidth, A_ScreenHeight, *%Start_Vari% %ImageFile%
	if ErrorLevel = 2
		{
			Clicks := "ErrorLevel = 2 ""Could not conduct the search."""
			SetBatchLines %BatchSave%		;Set between lines sleep back to the call scripts setting
			SetMouseDelay %MouseDelay%		;set MouseDelay back to the call scripts setting
			return %Clicks%
		}
	if ErrorLevel = 1
		{
		ToolTip, Image with variation %Start_Vari% on try %A_index% was not found., 10, 10, 2
		Sleep, 10
		Start_Vari += 5					;Increse the variation
		if (Start_Vari >= Max_Vari)
			{
			ToolTip,,,,2				;Have ToolTip 2 disappear
			Clicks := "The image could not be found with under the max(" Max_Vari ") shades of variation."
			SetBatchLines %BatchSave%		;Set between lines sleep back to the call scripts setting
			SetMouseDelay %MouseDelay%		;set MouseDelay back to the call scripts setting
			Return %Clicks%
			}
		else
		continue
		}
	else
		{
		Vari_inc :=	Max_Vari - Start_Vari
		Vari_inc //= NumberOfTries
		Vari := Start_Vari				;Store the variation
		MouseMove, %X%,%Y%				;Move the mouse cursor to the found image
		MouseGetPos, , , id				;Get the Window id under the cursor
		WinGetClass, class, ahk_id %id%			;Get the Window class
		WinActivate,ahk_class %class%			;Activate the Window with that class
		break
		}
	}
while (Vari_Tries <> NumberOfTries) and (ClickNumb <> NumberOfTries)
	{
	StartX := NewX						;Set the Searchs Starting X coordinat
	StartY := NewY						;Set the Searchs Starting Y coordinat
	ImageSearch, FoundX, FoundY, %StartX%, %StartY%, A_ScreenWidth, A_ScreenHeight, *%Vari% %ImageFile%
	if ErrorLevel = 1
		{
		ToolTip, No more Images was found with a variation of %Vari% so variation increased., 10, 10, 2
		NewX := 0					;Set the next Searchs x coord to 0
		NewY := ClickedY+1				;Set the next Searchs Y coord to the last clicked Y coord
		Error++						;Increse the internal Error setting
		If (Error = 2)
			{
			NewX := 0				;Set the next Searchs x coord to 0
			NewY := 0				;Set the next Searchs Y coord to 0
			If (Vari > Max_Vari)			;If at max variation
				{
				VariUpOrDown = Down		;Set value to down
				Max_Vari_toggle = 1		;Toggle that max variation has been reached
				}
			If (Vari < Start_Vari)			;If at under start variation
				VariUpOrDown = Up		;Set value to up
			If (VariUpOrDown = Up)
				Vari+=Vari_inc
			Else
				Vari-=Vari_inc
			Vari_Tries++				;Increse the count of variation tried
			Error--					;Decrese the internal Error setting
			}
		Sleep, 10
		continue
		}
	else
		{
		Off_X := FoundX+Click_X_Offset			;Add the X Offset to the found X coordinate
		Off_Y := FoundY+Click_Y_Offset			;Add the Y Offset to the found Y coordinate
		NewX := Foundx+1				;Set and Increse the X coordinate
		Clickedx := FoundX				;Store the last Found X coordinate
		ClickedY := FoundY				;Store the last Found Y coordinate
		WinActivate,ahk_id %id%				;Activate the Window with that id
		Mousemove, %Off_X%, %Off_Y%			;Move the mouse to the Offset X,y coordinates
		Sleep, 10
		SendInput {Click}
		Sleep, 10
		Mousemove, 0, 0					;Move the mouse away
		ClickNumb++					;Increse the click count
		Error := 0 					;The internal Error setting is set to 0
		Clicks .= "The image was found and tried clicked at " . FoundX . "x" . FoundY . " with a variation of " . Vari . ".`n"
		Sleep, %WaitBetweenClicks%
		continue
		}
	}
ToolTip								;Have ToolTip 1 disappear
ToolTip,,,,2							;Have ToolTip 2 disappear
SetBatchLines %BatchSave%					;Set between lines sleep back to the call scripts setting
SetMouseDelay %MouseDelay%					;set MouseDelay back to the call scripts setting
ElapsedTime := A_TickCount - StartTime				;Calculate and store the elapsed time
Clicks .= "The Number of clicks was (" . ClickNumb . ") and it took (" . (ElapsedTime //= 1000) . ") seconds."
Return %Clicks%							;Return the list of coordinates clicked and variation used
}