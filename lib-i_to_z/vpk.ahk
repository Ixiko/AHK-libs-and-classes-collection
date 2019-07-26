/*
Func: vpk_Compile
    Compiles a folder to .vpk format

Parameters:
	SourcePath	-	Path to folder

Returns:
	SourcePath compiled into .vpk file, stored in same directory as SourcePath

Examples:
	> vpk_Compile("e:\Downloads\_temp\pak01_dir")
	=	Folder pak01_dir gets compiled into e:\Downloads\_temp\pak01_dir.vpk
*/
vpk_Compile(SourcePath) {
	If !( InStr( FileExist(SourcePath), "D") )
		return
	vpk_Run(A_ScriptDir "\res\vpk\steam\vpk.exe """ SourcePath """ ")
}

/*
Func: vpk_Extract
    Extracts a .vpk file into a folder

Parameters:
	SourcePath	-	Path to .vpk file

Returns:
	SourcePath compiled into folder, stored in same directory as SourcePath

Examples:
	> vpk_Extract("e:\Downloads\_temp\pak01_dir.vpk")
	=	File pak01_dir.vpk gets compiled into e:\Downloads\_temp\pak01_dir
*/
vpk_Extract(SourcePath) {
	SplitPath, SourcePath, , , SourcePathExt
	If !FileExist(SourcePath) or !(SourcePathExt = "vpk")
		return
	vpk_Run(A_ScriptDir "\res\vpk\nosteam\vpk.exe """ SourcePath """ ")
}

/*
Func: vpk_Run
    Provides errorhandling for and runs vpk.exe 

Parameters:
	command	-	<A_ScriptDir \res\steam\vpk.exe> (compiling) OR <A_ScriptDir \res\nosteam\vpk.exe> (extracting)
				<path to target file or folder in double quotes>

Returns:
	Will exit the script if required vpk.exe files or folders are missing in ScriptDir
	or if command parameter does not contain vpk.exe

Examples:
	> SourcePath := "e:\Downloads\_temp\pak01_dir.vpk"
	> vpk_Run(A_ScriptDir "\res\vpk\nosteam\vpk.exe """ SourcePath """ ")
	=	File pak01_dir.vpk gets compiled into e:\Downloads\_temp\pak01_dir
*/
vpk_Run(command) {
	vpkFiles =
	( LTrim
	\res\vpk\nosteam
	\res\vpk\steam
	\res\vpk\nosteam\FileSystem_Stdio.dll
	\res\vpk\nosteam\tier0.dll
	\res\vpk\nosteam\vpk.exe
	\res\vpk\nosteam\vstdlib.dll
	\res\vpk\steam\filesystem_stdio.dll
	\res\vpk\steam\tier0.dll
	\res\vpk\steam\vpk.exe
	\res\vpk\steam\vstdlib.dll
	)
	

	If !InStr(command, "\vpk.exe") ; prompt incorrect parameter
	{
		msgbox vpk_Run(): "%command%" does not contain vpk.exe to run`n`nClosing
		exitapp
	}
	
	loop, parse, vpkFiles, `n ; check for missing files
	{
		If !FileExist(A_ScriptDir A_LoopField)
		{
			msgbox,
			( LTrim
			vpk_Run(): Missing file:
			" %A_ScriptDir%%A_LoopField% "
			
			Install https://github.com/0125/l4d-vpk
			into %A_ScriptDir%
			
			Closing
			)
			
			exitapp
		}
	}

	DetectHiddenWindows, On
	
	run, % command, , Hide, vpkPID
	
	WinWait, % "ahk_pid " vpkPID, , 5
	If (ErrorLevel = 1)
	{
		msgbox, vpk_Run(): Waited 5 seconds for vpkPID: '%vpkPID%' to start after running command: '%command%' `n`nFix this`n`nClosing
		exitapp
	}
	WinWaitClose, % "ahk_pid " vpkPID
	
	DetectHiddenWindows, Off
}