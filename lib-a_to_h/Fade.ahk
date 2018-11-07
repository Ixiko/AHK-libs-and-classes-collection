FadeIn(window = "A", TotalTime = 500, transfinal = 255)
{
	StartTime := A_TickCount
	Loop
	{
	   Trans := Round(((A_TickCount-StartTime)/TotalTime)*transfinal)
	   WinSet, Transparent, %Trans%, %window%
	   if (Trans >= transfinal)
		  break
	   Sleep, 10
	}
}

FadeOut(window = "A", TotalTime = 500, FinalTrans = 0)
{
	StartTime := A_TickCount
	Loop
	{
	   Trans := ((TimeElapsed := A_TickCount-StartTime) < TotalTime) ? 100*(1-(TimeElapsed/TotalTime)) : 0
	   WinSet, Transparent, %Trans%, %window%
	   if (Trans = FinalTrans)
		  break
	   Sleep, 10
	}
}

Show(window = "A")
{
	WinSet, Transparent, 255, %window%
}

Hide(window = "A")
{
	WinSet, Transparent, 0, %window%
}