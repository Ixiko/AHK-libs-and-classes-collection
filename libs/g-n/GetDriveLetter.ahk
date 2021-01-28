GetDriveLetter(fnVolumeIdentifier)
{
	; returns the drive letter for a given volume label or serial number
	; MsgBox fnVolumeIdentifier %fnVolumeIdentifier%


	; declare local, global, static variables


	Try
	{
		; set default return value
		DriveLettersList := ""


		; validate parameters
		If !fnVolumeIdentifier
			Throw, Exception("fnVolumeIdentifier was empty")


		; initialise variables


		; get a list of all drives
		DriveGet, ExternalDrivesList, List
		
		
		; compare fnVolumeIdentifier to labels and serial numbers and list matching drive letters
		Loop, Parse, ExternalDrivesList
		{
			ThisDriveLetter := A_LoopField
			
			DriveGet, ThisDriveVolumeLabel,   Label, %ThisDriveLetter%:
			DriveGet, ThisDriveSerialNumber, Serial, %ThisDriveLetter%:
			
			If fnVolumeIdentifier in %ThisDriveVolumeLabel%,%ThisDriveSerialNumber%
			{
				DriveLettersList .= ThisDriveLetter
				Break ; return first match
			}
		}


	}
	Catch, ThrownValue
	{
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,0)
	}
	Finally
	{
	}

	; return
	Return DriveLettersList
}


/* ; testing
params := xxx
ReturnValue := GetDriveLetter(params)
MsgBox, GetDriveLetter`n`nReturnValue: %ReturnValue%
*/