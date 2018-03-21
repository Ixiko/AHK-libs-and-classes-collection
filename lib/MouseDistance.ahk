SetBatchLines -1
CoordMode,Mouse,Screen
Menu,Tray,NoStandard
Menu,Tray,Add,Copy counters to clipboard,Copy
Menu,Tray,Add,Autostart at logon,Autostart
Menu,Tray,Add,About,About
Menu,Tray,Add,Exit,Exit
GoSub,Startup
GoSub,Track
GoSub,UpdateTrayTip
OnExit,MessageAndExit
Exit

*~Escape Up::Return

Remove_Decimal(Temp_Number)
{
	Temp_Number := Round(Temp_Number)
	Return Temp_Number
}

Reduce_Decimal(Temp_Number)
{
	Temp_Number := Round(Temp_Number,2)
	If (RegExMatch(Temp_Number,".") != 0){
		Loop 8 {
			StringRight,ZerosRight,Temp_Number,1
			If (ZerosRight = 0){
				StringLeft,Temp_Number,Temp_Number,(StrLen(Temp_Number) - 1)
			} else If (ZerosRight = "."){
				StringLeft,Temp_Number,Temp_Number,(StrLen(Temp_Number) - 1)
			}
		}
	}
	Return Temp_Number
}

Startup:
SysGet,Mon_Bbox,Monitor
MouseGetPos,Current_x,Current_y
Start_Time := A_TickCount / 1000
Old_x := Current_x
Old_y := Current_y
Icon_Status = 1
Distance_Moved_x = 0
Distance_Moved_y = 0
Total_Distance = 0
Copy_To_Clipboard = 0
IfExist,C:\users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Mouse Distance.lnk
{
	Menu,Tray,ToggleCheck,Autostart at logon
	Goto,Autostart_Done_2
}
IfExist,C:\Documents and Settings\%username%\Start Menu\Programs\Startup\Mouse Distance.lnk
{
	Menu,Tray,ToggleCheck,Autostart at logon
}
Autostart_Done_2:
Return

Copy:
Copy_To_Clipboard = 1
Gosub,Track
Return

Autostart:
IfExist,C:\users\
{
	IfExist,C:\users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Mouse Distance.lnk
	{
	FileDelete,C:\users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Mouse Distance.lnk
	GoTo,Autostart_done
	} else {
		FileCreateShortcut,%A_ScriptFullPath%,C:\users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Mouse Distance.lnk,%A_WorkingDir%,,Mouse Distance,%A_ScriptFullPath%,m
		GoTo,Autostart_done
	}
}
IfExist,C:\Documents and settings\
{
	IfExist,C:\Documents and Settings\%username%\Start Menu\Programs\Startup\Mouse Distance.lnk
	{
	FileDelete,C:\Documents and Settings\%username%\Start Menu\Programs\Startup\Mouse Distance.lnk
	} else {
		FileCreateShortcut,%A_ScriptFullPath%,C:\Documents and Settings\%username%\Start Menu\Programs\Startup\Mouse Distance.lnk,%A_WorkingDir%,,Mouse Distance,%A_ScriptFullPath%,m
	}
}
Autostart_done:
Menu,Tray,ToggleCheck,Autostart at logon
Return

About:
Progress,A M2 zh0 C00 WM400 w430,,Mouse Distance`n`nCreated by: Robert Eding`nVersion number: 1.2`n`nThis program guesses at how far you have moved the mouse using a 96 pixels per square inch formula.`n`nPixels per square inch:`nSquare root of: ((Hres X Hres) + (Vres X Vres)) / screen size(in inches),About Mouse Distance
Return

Track:
MouseGetPos,Current_x,Current_y
If (Current_x < Mon_BboxLeft){
	GoTo,Skip
}
If (Current_x > Mon_BboxRight){
	GoTo,Skip
}
If (Current_y < Mon_BboxTop){
	GoTo,Skip
}
If (Current_y > Mon_BboxBottom){
	GoTo,Skip
}

If (Current_x < Old_x){
	Distance_Moved_x := Old_x - Current_x
	Old_x := Current_x
} else {
	Distance_Moved_x := Current_x - Old_x
	Old_x := Current_x
}
If (Current_y < Old_y){
	Distance_Moved_y := Old_y - Current_y
	Old_y := Current_y
} else {
	Distance_Moved_y := Current_y - Old_y
	Old_y := Current_y
}
TMP := sqrt((Distance_Moved_x * Distance_Moved_x) + (Distance_Moved_y * Distance_Moved_y))
If (TMP > sqrt((A_ScreenWidth * A_ScreenWidth) + (A_ScreenHeight * A_ScreenHeight))){
	GoTo, Skip
}
Total_Distance := Total_Distance + TMP
Skip:
SetTimer,Track,1
Return

UpdateTrayTip:
TET := (A_TickCount / 1000) - Start_Time
if ((((TET / 60) / 60) / 24) >= 1){
	TET := (((TET / 60) / 60) / 24)
	TET := Reduce_Decimal(TET)
	TET = %TET% Days
}else if (((TET / 60) / 60) >= 1){
	TET := ((TET / 60) / 60)
	TET := Reduce_Decimal(TET)
	TET = %TET% Hours
}else if ((TET / 60) >= 1){
	TET := (TET / 60)
	TET := Reduce_Decimal(TET)
	TET = %TET% Minutes
}else{
	TET := Reduce_Decimal(TET)
	TET = %TET% Seconds
}
Tray_Tip = Runtime: %TET%
Total_Distance := Remove_Decimal(Total_Distance)
Tray_Tip = %Tray_Tip% `r`nEst Mouse Distance In: `r`nPixels: %Total_Distance%
If ((Total_Distance / 96) >= 1){
	Tmp := Total_Distance / 96
	Tmp := Reduce_Decimal(Tmp)
	Tray_Tip = %Tray_Tip% `r`nInches: %Tmp%
	;inches
}
If (((Total_Distance / 96) / 12) >= 1){
	Tmp := (Total_Distance / 96) / 12
	Tmp := Reduce_Decimal(Tmp)
	Tray_Tip = %Tray_Tip% `r`nFeet: %Tmp%
	;feet
}
If ((((Total_Distance / 96) / 12) / 3) >= 1){
	Tmp := ((Total_Distance / 96) / 12) / 3
	Tmp := Reduce_Decimal(Tmp)
	Tray_Tip = %Tray_Tip% `r`nYards: %Tmp%
	;yards
}
If ((((Total_Distance / 96) / 12) / 5280) >= 1){
	Tmp := ((Total_Distance / 96) / 12) / 5280
	Tmp := Reduce_Decimal(Tmp)
	Tray_Tip = %Tray_Tip% `r`nMiles: %Tmp%
	;miles
}
If (Copy_To_Clipboard = 1){
	ClipBoard := Tray_Tip
	Copy_To_Clipboard = 0
}
Menu,Tray,Tip,%Tray_Tip%
SetTimer,UpdateTrayTip,1000
Return

MessageAndExit:
GoSub,UpdateTrayTip
FileAppend,%Tray_Tip%`r`n`r`n,Mouse Distance.log
ExitApp
Return

Exit:
ExitApp