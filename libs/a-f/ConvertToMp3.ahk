ConvertToMp3(fnInputFilePath,fnOutputFilePath := "",fnOverWrite = 0,fnBitRate = "128k")
{
	; uses ffmpeg to convert files to mp3
	; MsgBox fnInputFilePath: %fnInputFilePath%`nfnOutputFilePath: %fnOutputFilePath%`nfnBitRate: %fnBitRate%


	; declare local, global, static variables


	Try
	{
		; set default return value
		ReturnValue := 0 ; success


		; validate parameters
		IfNotExist, %fnInputFilePath%
			Throw, Exception("Input file doesn't exist: " fnInputFilePath)
		If fnOverWrite not in 0,1
			Throw, Exception("Invalid value for fnOverWrite specified. Should be 0 or 1.")
		If !RegExMatch(fnBitRate,"^[0-9]+k$")
			Throw, Exception("Invalid value for fnBitRate specified. Should be e.g. 128k, 64k.")


		; initialise variables
		If !fnOutputFilePath
		{
			SplitPath, fnInputFilePath,, InputFileFolder,, InputFileNameNoExt
			fnOutputFilePath := InputFileFolder "\" InputFileNameNoExt ".mp3"
		}
		fnOutputFilePath := StrReplace(fnOutputFilePath,".mp3","_" fnBitRate ".mp3")
		If !fnOverWrite
			IfExist, %fnOutputFilePath%
				fnOutputFilePath := StrReplace(fnOutputFilePath,".mp3","_" A_Now ".mp3")
			

		; create output folder if necessary
		SplitPath, fnOutputFilePath,, OutputFolder
		IfNotExist, %OutputFolder%
			FileCreateDir, %OutputFolder%
		
		
		; convert file
		CmdString := "ffmpeg.exe "
		CmdString .= "-i """ fnInputFilePath """ " ; set the input file
		CmdString .= "-vn "                        ; disable video recording
		CmdString .= "-b:a " fnBitRate " "         ; set the bitrate for all audio streams
		CmdString .= "-ac 2 "                      ; set the number of audio channels to 2 (stereo)
		CmdString .= "-acodec libmp3lame "         ; set the mp3 codec
		; CmdString .= "-map_metadata 0 "            ; copy metadata to output file		
		CmdString .= """" fnOutputFilePath """"    ; set the output file
		RunWait, *RunAs %ComSpec% /c "%CmdString%",, Hide

	}
	Catch, ThrownValue
	{
		ReturnValue := !ReturnValue
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,1)
	}
	Finally
	{
	}

	; return
	Return ReturnValue
}


/* ; testing
InputFilePath := "abc.mp3"
OutputFilePath := ""
OverWrite := 0
BitRate := "32k"
ReturnValue := ConvertToMp3(InputFilePath,OutputFilePath,OverWrite,BitRate)
MsgBox, ConvertToMp3`n`nReturnValue: %ReturnValue%
*/