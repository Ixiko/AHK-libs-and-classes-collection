SnapFolderWindows(fnFolderNamesList,fnWhichSide := "R")
{
	; function description
	; MsgBox fnFolderNamesList: %fnFolderNamesList%`nfnWhichSide %fnWhichSide%


	; declare local, global, static variables


	Try
	{
		; set default return value
		ReturnValue := 0 ; success


		; validate parameters
		If !fnFolderNamesList
			Throw, Exception("fnFolderNamesList was empty")
		If fnWhichSide not in L,R
			Throw, Exception("Invalid value for fnWhichSide")


		; initialise variables


		; do something
		WinGet, SourceControlFoldersList, List, ahk_class CabinetWClass
		Loop, %SourceControlFoldersList%
		{
			ThisWinId := SourceControlFoldersList%A_Index%
			WinGetTitle, ThisWinTitle, ahk_id %ThisWinId%
			If ThisWinTitle contains %fnFolderNamesList%
			{
				WinGetPos, ThisWinX, ThisWinY, ThisWinW, ThisWinH, ahk_id %ThisWinId%
				If (ThisWinX != 1913 || ThisWinY != 0 || ThisWinW != 654 || ThisWinH != 970)
				{
					WinActivate, ahk_id %ThisWinId%
					WinWaitActive, ahk_id %ThisWinId%
					If (fnWhichSide = "L")
						Send #{Left}
					Else
						Send #{Right}
					Sleep, 100 ;slight pause for move to complete
					; WinSet, Bottom,, ahk_id %ThisWinId%
				}
			}
		}


	}
	Catch, ThrownValue
	{
		ReturnValue := !ReturnValue
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,0)
	}
	Finally
	{
	}

	; return
	Return ReturnValue
}


; /* ; testing
FolderNamesList := "Stored Procedures,Functions,Programmability,Stored Procedures,Synonyms,Tables,User Defined Types,Views"
ReturnValue := SnapFolderWindows(FolderNamesList)
MsgBox, SnapFolderWindows`n`nReturnValue: %ReturnValue%
*/