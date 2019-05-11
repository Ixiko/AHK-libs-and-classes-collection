DriveGetLabels(fnDrivesList)
{
	; creates an array for each attached drive to store the label of that drive
	; MsgBox fnDrivesList: %fnDrivesList%


	; declare local, global, static variables
	Global DriveLabelA, DriveLabelB, DriveLabelC, DriveLabelD, DriveLabelE, DriveLabelF, DriveLabelG, DriveLabelH, DriveLabelI, DriveLabelJ, DriveLabelK, DriveLabelL, DriveLabelM, DriveLabelN, DriveLabelO, DriveLabelP, DriveLabelQ, DriveLabelR, DriveLabelS, DriveLabelT, DriveLabelU, DriveLabelV, DriveLabelW, DriveLabelX, DriveLabelY, DriveLabelZ


	Try
	{
		; set default return value
		ReturnValue := 0 ; success


		; validate parameters
		AlphabetCSV := "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z"
		DrivesList := ""
		FailedValidation := 0
		Loop, Parse, fnDrivesList
			If A_LoopField in %AlphabetCSV%
				DrivesList .= A_LoopField
		If !DrivesList
			Throw, Exception("No valid drives found in fnDrivesList")


		; initialise variables


		; create array
		Loop, Parse, DrivesList
		{
			ThisDriveLetter := A_LoopField
			Try ; allow for unlabeled drives
			{
				DriveGet, ThisDriveLabel, Label, %ThisDriveLetter%:
				DriveLabel%ThisDriveLetter% := ThisDriveLabel
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


/* ; testing
DrivesList := "CD"
ReturnValue := DriveGetLabels(DrivesList)
DrivesList := "DE"
ReturnValue := DriveGetLabels(DrivesList)
MsgBox, % "DriveGetLabels`n`nReturnValue: " ReturnValue "`n`nDriveLabelC: " DriveLabelC "`nDriveLabelD: " DriveLabelD "`nDriveLabelE: " DriveLabelE
*/