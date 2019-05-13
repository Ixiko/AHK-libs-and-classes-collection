;{ License
/* This file is part of Mini-Framework For AutoHotkey.
 * 
 * Mini-Framework is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 2 of the License.
 * 
 * Mini-Framework is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with Mini-Framework.  If not, see <http://www.gnu.org/licenses/>.
 */
; End:License ;}


;{ Class Comments
/*!
	Class: Mfunc
		Command Functions - Mfunc create a wrapper for many of the built in AutoHotkey command functions and adds a
		few other functions for common use.  
		All functions are static.
	Inherits: MfObject
*/
; End:Class Comments ;}
Class Mfunc extends MfObject
{
/*!
		Constructor: ()
			Initializes a new instance of the Mfunc class.
		Remarks:
			It is not necessary to construct new instance of Mfunc class
			as Mfunc class contains static properties only
		Throws:
			Throws MfNotSupportedException if class instance is created
	*/
	__New() {
		throw new MfNotSupportedException(MfString.Format(MfEnvironment.Instance.GetResourceString("NotSupportedException_Static_Class"), "Mfunc"))
	}
;{ 	ControlGet						- Static - Method
/*
	Method: ControlGet()

	OutputVar := Mfunc.ControlGet(Cmd [, Value, Control, WinTitle, WinText, ExcludeTitle, ExcludeText])

	Mfunc.ControlGet(Cmd [, Value, Control, WinTitle, WinText, ExcludeTitle, ExcludeText])
		Retrieves various types of information about a control.
	Parameters:
			Cmd, Value
			See list below.
			
		Control
			Can be either ClassNN (the classname and instance number of the control) or the control's text, both of which can
			be determined via Window Spy. When using text, the matching behavior is determined by SetTitleMatchMode.
			If this parameter is blank, the target window's topmost control will be used.
			To operate upon a control's HWND (window handle), leave the Control parameter blank and specify "ahk_id" . ControlHwnd for
			the WinTitle parameter (this also works on hidden controls even when DetectHiddenWindows is Off).
			The HWND of a control is typically retrieved via ControlGet Hwnd, MouseGetPos, or DllCall.
		WinTitle
			A window title or other criteria identifying the target window. See WinTitle.
		WinText
			If present, this parameter must be a substring from a single text element of the target window
			(as revealed by the included Window Spy utility). Hidden text elements are detected if DetectHiddenText is ON.
		ExcludeTitle
			Windows whose titles include this value will not be considered
		ExcludeText
			Windows whose text include this value will not be considered.
	Returns:
		Returns the results of cmd.
	Throws:
		Throws MfException if error occurs.
	Remarks:
		Wrapper for AutoHotkey ControlGet.
		Static Method
		Any and/or all parameter for this function can be instance of MfString or var containing string.
		See Also:AutoHotkey Docs - ControlGet
*/
	ControlGet(Cmd, Value = "", Control = "", WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "") {
		_cmd := MfString.GetValue(Cmd), _Control := MfString.GetValue(Control), _WinTitle := MfString.GetValue(WinTitle)
		_WinText := MfString.GetValue(WinText), _ExcludeTitle := MfString.GetValue(ExcludeTitle), _ExcludeText := MfString.GetValue(ExcludeText)
		ControlGet, v, %_Cmd%, %_Value%, %_Control%, %_WinTitle%, %_WinText%, %_ExcludeTitle%, %_ExcludeText%
		if (ErrorLevel) {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Return, v
	}
; 	End:ControlGet ;}
;{ 	ControlGetFocus					- Static - Method
/*
	Method: ControlGetFocus()

	OutputVar := Mfunc.ControlGetFocus([WinTitle, WinText, ExcludeTitle, ExcludeText])

	Mfunc.ControlGetFocus([WinTitle, WinText, ExcludeTitle, ExcludeText])
		Retrieves which control of the target window has input focus, if any.
	Parameters:
		WinTitle
			A window title or other criteria identifying the target window.
		WinText
			If present, this parameter must be a substring from a single text element of the target window
			(as revealed by the included Window Spy utility). Hidden text elements are detected if DetectHiddenText is ON.
		ExcludeTitle
			Windows whose titles include this value will not be considered.
		ExcludeText
			Windows whose text include this value will not be considered.
	Returns:
		Returns the variable in which to store the identifier of the control, which consists of its classname followed by
		its sequence number within its parent window, e.g. Button12.
	Throws:
		Throws MfException if error occurs.
	Remarks:
		Wrapper for AutoHotkey ControlGetFocus.
		Static Method
		Any and/or all parameter for this function can be instance of MfString or var containing string.
		See Also: AutoHotkey Docs - ControlGetFocus
*/
	ControlGetFocus(WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "") {
		_WinTitle := MfString.Getvalue(WinTitle), _WinText := MfString.Getvalue(WinText)
		_ExcludeTitle := MfString.Getvalue(ExcludeTitle), _ExcludeText := MfString.Getvalue(ExcludeText)
		ControlGetFocus, v, %_WinTitle%, %_WinText%, %_ExcludeTitle%, %_ExcludeText%
		if (ErrorLevel) {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Return, v
	}
; 	End:ControlGetFocus ;}
;{ 	ControlGetText					- Static - Method
/*
	Method: ControlGetText()

	OutputVar := Mfunc.ControlGetText([Control, WinTitle, WinText, ExcludeTitle, ExcludeText])

	Mfunc.ControlGetText([Control, WinTitle, WinText, ExcludeTitle, ExcludeText])
		Retrieves text from a control.
	Parameters:
		Control
			Can be either ClassNN (the classname and instance number of the control) or the control's text,
			both of which can be determined via Window Spy. When using text, the matching behavior is determined by SetTitleMatchMode.
			If this parameter is blank or omitted, the target window's topmost control will be used.
	Returns:
		Returns the name of the variable in which to store the retrieved text.
	Throws:
		Throws MfException if error occurs.
	Remarks:
		Wrapper for AutoHotkey ControlGetText.
		Static Method.
		Any and/or all parameter for this function can be instance of MfString or var containing string.
		See Also: AutoHotkey Docs - ControlGetText
*/
	ControlGetText(Control = "", WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "") {
		_Control := MfString.Getvalue(Control), _WinTitle := MfString.Getvalue(WinTitle)
		_WinText := MfString.Getvalue(WinText), _ExcludeTitle := MfString.Getvalue(ExcludeTitle)
		_ExcludeText := MfString.Getvalue(ExcludeText)
		ControlGetText, v, %_Control%, %_WinTitle%, %_WinText%, %_ExcludeTitle%, %_ExcludeText%
		if (ErrorLevel) {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Return, v
	}
; 	End:ControlGetText ;}
;{ 	DriveGet						- Static - Method
/*
	Method: DriveGet()

	OutputVar := Mfunc.DriveGet(Cmd [, Value])

	Mfunc.DriveGet(Cmd [, Value])
		Retrieves various types of information about the computer's drive(s).
	Parameters:
			see AutoHotkey Docs - DriveGet
	Returns:
		Returns the name of the variable in which to store the result of Cmd.
	Throws:
		Throws MfException if error occurs.
	Remarks:
		Wrapper for AutoHotkey - DriveGet.
		Static method.
		Any and/or all parameter for this function can be instance of MfString or var containing string.
		See Also:AutoHotkey - DriveGet
*/
	DriveGet(Cmd, Value = "") {
		_Cmd := MfString.Getvalue(Cmd), _Value := MfString.Getvalue(Value)
		DriveGet, v, %_Cmd%, %_Value%
		if (ErrorLevel) {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Return, v
	}
; 	End:DriveGet ;}
;{ 	DriveSpaceFree					- Static - Method
/*
	Method: DriveSpaceFree()

	OutputVar := Mfunc.DriveSpaceFree(path)

	Mfunc.DriveSpaceFree(path)
		Retrieves the free disk space of a drive, in Megabytes.
	Parameters:
		path
			Path of drive to receive information from. Since NTFS supports mounted volumes and directory junctions,
			different amounts of free space might be available in different folders of the same "drive" in some cases.
			Can be MfString instance or var containing string.
	Returns:
		Returns value in which which is rounded down to the nearest whole number.
	Remarks:
		Wrapper for AutoHotkey - DriveSpaceFree.
		Static method.
*/
	DriveSpaceFree(Path) {
		_Path := MfString.Getvalue(Path)
		DriveSpaceFree, v, %Path%
		Return, v
	}
; End:DriveSpaceFree ;}
;{ 	EnvGet							- Static - Method
/*
	Method: EnvGet()

	OutputVar := Mfunc.EnvGet(EnvVarName)

	Mfunc.EnvGet(EnvVarName)
		Retrieves an environment variable.
	Parameters:
		EnvVarName
			The name of the environment variable to retrieve. For example: OutputVar := Mfunc.EnvGet("Path").
			Can be MfString instance or var containing string.
	Returns:
		Returns the operating system environment variable or null if environment variable is empty or does not exist.
	Remarks:
		Wrapper for AutoHotkey - EnvGet.
		Static method.
		If the specified environment variable is empty or does not exist, Return value is null.
		The operating system limits each environment variable to 32 KB of text.
*/
	EnvGet(EnvVarName) {
		_EnvVarName := MfString.Getvalue(EnvVarName)
		EnvGet, v, %_EnvVarName%
		Return, v
	}
; 	End:EnvGet ;}
;{ 	FileAppend						- Static - Method
/*
	Method: FileAppend()
	Mfunc.FileAppend([Text, Filename, Encoding])
		Writes text to the end of a file (first creating the file, if necessary).
	Parameters:
		Text
			The text to append to the file. This text may include linefeed characters (`n) to start new lines.
			In addition, a single long line can be broken up into several shorter ones by means of a continuation section.
			If Text is blank, Filename will be created as an empty file (but if the file already exists, its modification time will be updated).
			If Text is %ClipboardAll% or a variable that was previously assigned the value of ClipboardAll,
			Filename will be unconditionally overwritten with the entire contents of the clipboard (i.e. FileDelete is not necessary).
		Filename
			The name of the file to be appended, which is assumed to be in %A_WorkingDir% if an absolute path isn't specified.
			End of line (EOL) translation: To disable EOL translation, prepend an asterisk to the filename.
			This causes each linefeed character (`n) to be written as a single linefeed (LF) rather than the Windows standard of CR+LF.
			For example: *C:\My Unix File.txt.
			If the file is not already open (due to being inside a file-reading loop), EOL translation is automatically disabled if
			Text contains any carriage return and linefeed pairs (`r`n). In other words, the asterisk option described in the previous
			paragraph is put into effect automatically. However, specifying the asterisk when Text contains `r`n improves performance
			because the program does not need to scan Text for `r`n.
			Standard Output (stdout): Specifying an asterisk (*) for Filename causes Text to be sent to standard output (stdout).
			Such text can be redirected to a file, piped to another EXE, or captured by fancy text editors. For example,
			the following would be valid if typed at a command prompt:
			%ProgramFiles%\AutoHotkey\AutoHotkey.exe" "My Script.ahk" >"Error Log.txtb
			However, text sent to stdout will not appear at the command prompt it was launched from.
			This can be worked around by piping a script's output to another command or program. For example:
			"%ProgramFiles%\AutoHotkey\AutoHotkey.exe" "My Script.ahk" |more
			For /F "tokens=*" %L in ('""%ProgramFiles%\AutoHotkey\AutoHotkey.exe" "My Script .ahk""') do @Echo %L
			AutoHotkey [v1.1.20+]: Specifying two asterisks (**) for Filename causes Text to be sent to the stderr stream.
		Encoding
			AutoHotkey [v1.0.90+]: Overrides the default encoding set by FileEncoding, where Encoding follows the same format.
	Throws:
		Throws MfException with InnerException set to A_LastError
	Remarks:
		Wrapper for AutoHotkey - FileAppend.
		Static method.
		To overwrite an existing file, delete it with Mfunc.FileDelete prior to using Mfunc.FileAppend.
		Any and/or all parameter for this function can be instance of MfString or var containing string.
*/
	FileAppend(Text="", Filename="", Encoding="") {
		_Text := MfString.Getvalue(Text), _Filename := MfString.Getvalue(Filename), _Encoding := MfString.Getvalue(Encoding)
		try {
			if (_Encoding) {
				enc := _Encoding
			} else {
				enc := A_FileEncoding
			}
			FileAppend, %_Text%, %_Filename%, %_enc%
			
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("IO.FileAppendError",FileName), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (ErrorLevel = 1) {
			e := new MfException(A_LastError)
			ex := new MfException(MfEnvironment.Instance.GetResourceString("IO.FileAppendError",FileName), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
	}
; 	End:FileAppend ;}
;{ 	FileCopy						- Static - Method
/*
	Method: FileCopy()

	OutputVar := Mfunc.FileCopy(SourcePattern, DestPattern [, Flag])

	Mfunc.FileCopy(SourcePattern, DestPattern [, Flag])
		FileCopy() Copies one or more files.
	Parameters:
		SourcePattern
			The name of a single file or folder, or a wildcard pattern such as C:\Temp*.tmp. SourcePattern is assumed to be in
			%A_WorkingDir% if an absolute path isn't specified.
		DestPattern
			The name or pattern of the destination, which is assumed to be in %A_WorkingDir% if an absolute path isn't specified. To
			perform a simple copy -- retaining the existing file name(s) -- specify only the folder name.
		Flag
			(optional) this flag determines whether to overwrite files if they already exist:
			0 = (default) do not overwrite existing files
			1 = overwrite existing files
			This parameter can be an expression, even one that evaluates to true or false (since true and false are stored
			internally as 1 and 0).
	Returns:
		Returns 0 on success; otherwise the number of files that failed to copy is returned.
	Throws:
		Throws MfException throw any errors with InnerException error message.
	Remarks:
		Wrapper for AutoHotkey Docs - FileCopy.
		Static method.
		FileCopy copies files only. To instead copy the contents of a folder (all its files and subfolders), see the examples
		section below. To copy a single folder (including its subfolders), use Mfunc.FileCopyDir.
		ErrorLevel is set to the number of files that could not be copied due to an error, or 0 otherwise.
		In either case, if the source file is a single file (no wildcards) and it does not exist, ErrorLevel is set to 0. To
		detect this condition, use IfExist or FileExist() on the source file prior to copying it.
		Unlike Mfunc.FileMove(), copying a file onto itself is always counted as an error, even if the overwrite mode is in effect.
		If files were found, A_LastError is set to 0 (zero) or the result of the operating system's GetLastError() function
		immediately after the last failure. Otherwise A_LastError contains an error code that might indicate why no files werefound.
		Any and/or all parameter for this function can be instance of MfString or var containing string.
*/
	FileCopy(SourcePattern, DestPattern, Flag = "") {
		_SourcePattern := MfString.Getvalue(SourcePattern), _DestPattern := MfString.Getvalue(DestPattern), _Flag := MfString.Getvalue(Flag)
		try {
			FileCopy, %_SourcePattern%, %_DestPattern%, %_Flag%
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		return ErrorLevel
	}
; 	End:FileCopy ;}
;{ 	FileCopyDir						- Static - Method
/*
	Method: FileCopyDir()
	Mfunc.FileCopyDir(Source, Dest [, Flag])
		Copies a folder along with all its sub-folders and files (similar to xcopy).
	Parameters:
		Source
			Name of the source directory (with no trailing backslash), which is assumed to be in %A_WorkingDir%
			if an absolute path isn't specified. For example: C:\My Folder
		Dest
			Name of the destination directory (with no trailing baskslash), which is assumed to be in
			%A_WorkingDir%if an absolute path isn't specified. For example: C:\Copy of My Folder
		Flag
			(optional) this flag determines whether to overwrite files if they already exist:
			0 = (default): Do not overwrite existing files. The operation will fail and have no effect if Dest
			already exists as a file or directory.
			1 = Overwrite existing files. However, any files or subfolders inside Dest that do not have a
			counterpart in Source will not be deleted.
			This parameter can be an expression, even one that evalutes to true or false (since true and false
			are stored internally as 1 and 0).
	Throws:
		Throws MfException throw any errors with InnerException set to the Autohotkey - FileCopyDir error
		message.
		Throws MfException any other general error occurs.
	Remarks:
		Wrapper for AutoHotkey Docs - FileCopyDir.
		Static method.
		If the destination directory structure doesn't exist it will be created if possible.
		ErrorLevel is set to 1 if there was a problem or 0 otherwise. However, if the source directory
		contains any saved webpages consisting of a PageName.htm file and a corresponding directory named
		PageName_files, an error may be indicated even when the copy is successful.
		Mfunc.FileCopyDir copies a single folder. To instead copy the contents of a folder (all its files
		and subfolders), see the examples section of Mfunc.FileCopy.
		If the source directory contains any saved webpages consisting of a PageName.htm file and a
		corresponding directory named PageName_files, an error may be thrown even when the copy is
		successful.
		Any and/or all parameter for this function can be instance of MfString or var containing string.
*/
	FileCopyDir(Source, Dest, Flag = "") {
		try {
			_Source := MfString.Getvalue(Source), _Dest := MfString.Getvalue(Dest), _Flag := MfString.Getvalue(Flag)
			FileCopyDir, %_Source%, %_Dest%, %_Flag%
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (ErrorLevel) {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
; 	End:FileCopyDir ;}
;{	FileCreateDir					- Static - Method
/*
	Method: FileCreateDir()
	Mfunc.FileCreateDir(DirName)
		Creates a directory/folder.
	Parameters:
		DirName
			Name of the directory to create, which is assumed to be in %A_WorkingDir% if an absolute path isn't specified.
			Can be MfString instance or var containing string.
	Throws:
		Throws MfException is non-zero then InnerException has a message of A_LastError
	Remarks:
		Wrapper for AutoHotkey Docs - FileCreateDir.
		Static method.
		This command will also create all parent directories given in DirName if they do not already exist.
*/
	FileCreateDir(DirName) {
		try {
			_DirName := MfString.Getvalue(DirName)
			FileCreateDir, %_DirName%
			if ((ErrorLevel) && (A_LastError)) {
				ex := new MfException(A_LastError)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
; End:FileCreateDir ;}
;{	FileDelete						- Static - Method
/*
	Method: FileDelete()
	Mfunc.FileDelete(FilePattern)
		Deletes one or more files.
	Parameters:
		FilePattern
			The name of a single file or a wildcard pattern such as C:\Temp*.tmp. FilePattern is assumed to be
			in %A_WorkingDir% if an absolute path isn't specified.
			To remove an entire folder, along with all its sub-folders and files, use Mfunc.FileRemoveDir.
			Can be MfString instance or var containing string.
	Throws:
		Throws MfException on error if A_LastError is non-zero then InnerException message is set to the value of A_LastError.
	Remarks:
		Wrapper for AutoHotkey Docs - FileDelete.
		Static method.
		To delete a read-only file, first remove the read-only attribute.
		For example: Mfunc.FileSetAttrib("-R", "C:\My File.txt").
*/
	FileDelete(FilePattern) {
		try {
			_FilePattern := MfString.Getvalue(FilePattern)
			FileDelete, %_FilePattern%
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (ErrorLevel) {
			e := ""
			if (A_LastError) {
				e := new MfException(A_LastError)
				e.Source := A_ThisFunc
			}
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
	}
; End:FileDelete ;}
;{	FileGetAttrib					- Static - Method
/*
	Method: FileGetAttrib()

	OutputVar := Mfunc.FileGetAttrib([Filename])

	Mfunc.FileGetAttrib([Filename])
		Reports whether a file or folder is read-only, hidden, etc.
	Parameters:
		Filename
			The name of the target file, which is assumed to be in %A_WorkingDir% if an absolute path isn't specified.
			If omitted, the current file of the innermost enclosing File-Loop will be used instead.
			Can be MfString instance or var containing string.
	Returns:
		Returns a string with a subset of the letters "RASHNDOCT"
	Throws:
		Throws MfException is non-zero then InnerException has a message of A_LastError
	Remarks:
		Wrapper for AutoHotkey Docs - FileGetAttrib.
		Static method.
		The string returned will contain a subset of the letters in the string "RASHNDOCT":
		R = read-only
		A = ARCHIVE
		S = SYSTEM
		H = HIDDEN
		N = NORMAL
		D = DIRECTORY
		O = OFFLINE
		C = COMPRESSED
		T = TEMPORARY
*/
	FileGetAttrib(Filename = "") {
		try {
			_Filename := MfString.Getvalue(Filename)
			FileGetAttrib, v, %_Filename%
			if ((ErrorLevel) && (A_LastError)) {
				ex := new MfException(A_LastError)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		Return, v
	}
; End:FileGetAttrib ;}
;{	FileGetShortcut					- Static - Method
/*
	Method: FileGetShortcut()
		FileGetShortcut() Retrieves information about a shortcut (.lnk) file, such as its target file.
	Mfunc.FileGetShortcut(LinkFile [, OutTarget, OutDir, OutArgs, OutDescription, OutIcon, OutIconNum, OutRunState])

	Parameters:
		LinkFile
			Name of the shortcut file to be analyzed, which is assumed to be in %A_WorkingDir% if an absolute path
			isn't specified. Be sure to include the .lnk extension.
		OutTarget
			Name of the variable in which to store the shortcut's target (not including any arguments it might have).
			For example: C:\WINDOWS\system32\notepad.exe
		OutDir
			Name of the variable in which to store the shortcut's working directory.
			For example: C:\My Documents. If environment variables such as %WinDir% are present in the string,
			one way to resolve them is via StringReplace. For example: StringReplace, OutDir, OutDir, %WinDir%, %A_WinDir%
		OutArgs
			Name of the variable in which to store the shortcut's parameters (blank if none).
		OutDescription
			Name of the variable in which to store the shortcut's comments (blank if none).
		OutIcon
			Name of the variable in which to store the filename of the shortcut's icon (blank if none).
		OutIconNum
			Name of the variable in which to store the shortcut's icon number within the icon file (blank if none).
			This value is most often 1, which means the first icon.
		OutRunState
			Name of the variable in which to store the shortcut's initial launch state, which is one of the following digits:
			1: Normal
			3: Maximized
			7: Minimized
	Throws:
		Throws MfException throw any errors with InnerException set to the Autohotkey - FileGetShortcut error message.
		Throws MfException any other general error occurs.
	Remarks:
		Wrapper for AutoHotkey Docs - FileGetShortcut.
		Static method.
		Any of the output variables may be omitted if the corresponding information is not needed.
		Any and/or all parameter for this function can be instance of MfString or var containing string.
*/
	FileGetShortcut(LinkFile, ByRef OutTarget = "", ByRef OutDir = "", ByRef OutArgs = "", ByRef OutDescription = "", ByRef OutIcon = "", ByRef OutIconNum = "", ByRef OutRunState = "") {
		try {
			_LinkFile := MfString.Getvalue(LinkFile), _OutTarget := MfString.Getvalue(OutTarget), _OutDir := MfString.Getvalue(OutDir)
			_OutArgs := MfString.Getvalue(OutArgs), _OutDescription := MfString.Getvalue(OutDescription)
			_OutIcon := MfString.Getvalue(OutIcon), _OutIconNum := MfString.Getvalue(OutIconNum)
			_OutRunState := MfString.Getvalue(OutRunState)
			FileGetShortcut, %_LinkFile%, _OutTarget, _OutDir, _OutArgs, _OutDescription, _OutIcon, _OutIconNum, _OutRunState
			Mfunc._SetObjValue(OutTarget, _OutTarget)
			Mfunc._SetObjValue(OutDir, _OutDir)
			Mfunc._SetObjValue(OutArgs, _OutArgs)
			Mfunc._SetObjValue(OutDescription, _OutDescription)
			Mfunc._SetObjValue(OutIcon, _OutIcon)
			Mfunc._SetObjValue(OutIconNum, _OutIconNum)
			Mfunc._SetObjValue(OutRunState, _OutRunState)
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (ErrorLevel) {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
; End:FileGetShortcut ;}
;{ 	FileGetSize						- Static - Method
/*
	Method: FileGetSize()

	OutputVar := Mfunc.FileGetSize([Filename, Units])

	Mfunc.FileGetSize([Filename, Units])
		Retrieves the size of a file.
	Parameters:
		Filename
			The name of the target file, which is assumed to be in %A_WorkingDir% if an absolute path isn't specified.
			If omitted, the current file of the innermost enclosing File-Loop will be used instead.
		Units
			If present, this parameter causes the result to be returned in units other than bytes:
			K = kilobytes
			M = megabytes
	Returns:
		Returns the retrieved size (rounded down to the nearest whole number).
	Throws:
		Throws MfException is non-zero then InnerException has a message of A_LastError
	Remarks:
		Wrapper for AutoHotkey Docs - FileGetSize.
		Static method.
		Files of any size are supported, even those over 4 gigabytes, and even if Units is bytes.
		If the target file is a directory, the size will be reported as whatever the OS believes it to be (probably zero in all cases).
*/
	FileGetSize(Filename = "", Units = "") {
		try {
			_Filename := MfString.Getvalue(Filename), _Units := MfString.Getvalue(Units)
			FileGetSize, v, %_Filename%, %_Units%
			if ((ErrorLevel) && (A_LastError)) {
				ex := new MfException(A_LastError)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Return, v
	}
; 	End:FileGetSize ;}
;{ 	FileGetTime						- Static - Method
/*
	Method: FileGetTime()

	OutputVar := Mfunc.FileGetTime([Filename, WhichTime])

	Mfunc.FileGetTime([Filename, WhichTime])
		Retrieves the datetime stamp of a file or folder.
	Parameters:
		Filename
			The name of the target file or folder, which is assumed to be in %A_WorkingDir% if an absolute path isn't specified.
			If omitted, the current file of the innermost enclosingFile-Loop will be used instead.
		WhichTime
			Which timestamp to retrieve:
			M = Modification time (this is the default if the parameter is omitted)
			C = Creation time
			A = Last access time
	Returns:
		Returns the retrieved date-time in format YYYYMMDDHH24MISS. The time is your own local time, not UTC/GMT.
	Throws:
		Throws MfException is non-zero then InnerException has a message of A_LastError
	Remarks:
		Wrapper for AutoHotkey - FileGetTime.
		Static method.
		Any and/or all parameter for this function can be instance of MfString or var containing string.
		See YYYYMMDDHH24MISS for an explanation of dates and times.
*/
	FileGetTime(Filename = "", WhichTime = "") {
		try {
			_Filename := MfString.Getvalue(Filename), _WhichTime := MfString.Getvalue(WhichTime)
			FileGetTime, v, %_Filename%, %_WhichTime%
			if ((ErrorLevel) && (A_LastError)) {
				ex := new MfException(A_LastError)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		Return, v
	}
; 	End:FileGetTime ;}
;{ 	FileGetVersion					- Static - Method
/*
	Method: FileGetVersion()

	OutputVar := Mfunc.FileGetVersion([Filename])

	Mfunc.FileGetVersion([Filename])
		Retrieves the version of a file.
	Parameters:
		Filename
			The name of the target file, which is assumed to be in %A_WorkingDir% if an absolute path isn't specified.
			If omitted, the current file of the innermost enclosing File-Loop will be used instead.
			Can be MfString instance or var containing string.
	Returns:
		Returns the version number/string.
	Throws:
		Throws MfException is non-zero then InnerException has a message of A_LastError
	Remarks:
		Wrapper for AutoHotkey Docs - FileGetVersion.
		Static method.
		Most non-executable files (and even some EXEs) won't have a version, and thus the return will be blank in these cases.
*/
	FileGetVersion(Filename = "") {
		try {
			_Filename := MfString.Getvalue(Filename)
			FileGetVersion, v, %_Filename%
			if ((ErrorLevel) && (A_LastError)) {
				ex := new MfException(A_LastError)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Return, v
	}
; 	End:FileGetVersion ;}
;{ 	FileMove						- Static - Method
/*
	Method: FileMove()
	Mfunc.FileMove(DestPattern [, Flag])
		Moves or renames one or more files.
	Parameters:
		SourcePattern
			The name of a single file or folder, or a wildcard pattern such as C:\Temp*.tmp.
			SourcePattern is assumed to be in %A_WorkingDir% if an absolute path isn't specified.
		DestPattern
			The name or pattern of the destination, which is assumed to be in %A_WorkingDir% if an absolute path isn't specified.
			To perform a simple copy -- retaining the existing file name(s) -- specify only the folder name.
		Flag
			(optional) this flag determines whether to overwrite files if they already exist:
			0 = (default) do not overwrite existing files
			1 = overwrite existing files
			This parameter can be an expression, even one that evaluates to true or false (since true and false are stored
			internally as 1 and 0).
	Throws:
		Throws MfException on error if A_LastError is non-zero then InnerException message is set to the value of A_LastError.
	Remarks:
		Wrapper for AutoHotkey Docs - FileMove.
		Static method.
		Unlike Mfunc.FileCopy, moving a file onto itself is always considered successful, even if the overwrite mode is
		not in effect.
		
		FileMove moves files only. To instead move the contents of a folder (all its files and subfolders),
		see the examples section below. To move or rename a single folder, use Mfunc.FileMoveDir.
		The operation will continue even if error(s) are encountered.
		Although this command is capable of moving files to a different volume, the operation will take longer than a
		same-volume move. This is because a same-volume move is similar to a rename, and therefore much faster.
		Any and/or all parameter for this function can be instance of MfString or var containing string.
*/
	FileMove(Source, Dest, Flag="") {
		try {
			_Source := MfString.Getvalue(Source), _Dest := MfString.Getvalue(Dest), _Flag := MfString.Getvalue(Flag)
			FileMove, %_Source%, %_Dest%, %_Flag%
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (ErrorLevel) {
			e := ""
			if (A_LastError) {
				e := new MfException(A_LastError)
				e.Source := A_ThisFunc
			}
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
	}
; 	End:FileMove ;}
;{ 	FileMoveDir						- Static - Method
/*
	Method: FileMoveDir()
	Mfunc.FileMoveDir(Source, Dest [, Flag])
		Moves a folder along with all its sub-folders and files. It can also rename a folder.
	Parameters:
		Source
			Name of the source directory (with no trailing backslash), which is assumed to be in %A_WorkingDir%
			if an absolute path isn't specified. For example: C:\My Folder
		Dest
			The new path and name of the directory (with no trailing baskslash), which is assumed to be in
			%A_WorkingDir% if an absolute path isn't specified. For example: D:\My Folder. Note: Dest is the
			actual path and name that the directory will have after it is moved; it is not the directory into
			which Source is moved (except for the known limitation mentioned below).
		Flag
			(options) Specify one of the following single characters:
			0 (default): Do not overwrite existing files. The operation will fail if Dest already exists as a
				file or directory.
			1: Overwrite existing files. However, any files or subfolders inside Dest that do not have a
				counterpart in Source will not be deleted. Known limitation: If Dest already exists as a folder and
				it is on the same volume as Source, Source will be moved into it rather than overwriting it. To
				avoid this, see the next option.
			2: The same as mode 1 above except that the limitation is absent.
			R: Rename the directory rather than moving it. Although renaming normally has the same effect as
				moving, it is helpful in cases where you want "all or none" behavior; that is, when you don't want
				the operation to be only partially successful when Source or one of its files is locked (in use).
				Although this method cannot move Source onto a different volume, it can move it to any other
				directory on its own volume. The operation will fail if Dest already exists as a file or directory.
	Throws:
		Throws MfException throw any errors with InnerException set to the Autohotkey - FileMoveDir error
		message.
		Throws MfException any other general error occurs.
	Remarks:
		Wrapper for AutoHotkey Docs - FileMoveDir.
		Static method.
		FileMoveDir moves a single folder to a new location. To instead move the contents of a folder (all
		its files and subfolders), see the examples section of Mfunc.FileMove.
*/
	FileMoveDir(Source, Dest, Flag="") {
		try {
			_Source := MfString.Getvalue(Source), _Dest := MfString.Getvalue(Dest), _Flag := MfString.Getvalue(Flag)
			FileMoveDir %_Source%, %_Dest%, %_Flag%
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (ErrorLevel) {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
; 	End:FileMoveDir ;}
;{ 	FileRead						- Static - Method
/*
	Method: FileRead()

	OutputVar := Mfunc.FileRead(Filename)

	Mfunc.FileRead(Filename)
		Reads a file's contents and returns them.
	Parameters:
		Filename
			The name of the file to read, which is assumed to be in %A_WorkingDir% if an absolute path isn't
			specified.
			Options: Zero or more of the following strings may be also be present immediately before the name of
			the file. Separate each option from the next with a single space or tab. For example: t m5000 C:\Log
			Files\200601.txt.
			
			*c: Load a ClipboardAll file or other binary data. All other options are ignored when c is present.
			
			*m1024: If this option is omitted, the entire file is loaded unless there is insufficient memory, in
					which case an error message is shown and the thread exits (but Try can be used to avoid this).
					Otherwise, replace 1024 with a decimal or hexadecimal number of bytes. If the file is larger than
					this, only its leading part is loaded. Note: This might result in the last line ending in a naked
					carriage return (`r) rather than `r`n.
			
			*t: Replaces any/all occurrences of carriage return & linefeed (`r`n) with linefeed (`n). However,
				this translation reduces performance and is usually not necessary. For example, text containing
				`r`n is already in the right format to be added to a Gui Edit control. Similarly, FileAppend
				detects the presence of `r`n when it opens a new file; it knows to write each `r`n as-is rather
				than translating it to `r`r`n. Finally, the following parsing loop will work correctly regardless
				of whether each line ends in `r`n or just `n: Loop, parse, MyFileContents, `n, `r.
			
			*Pnnn: AutoHotkey [v1.0.90+]: Overrides the default encoding set by FileEncoding, where nnn must be
				a numeric code page identifier.
			
			Can be MfString instance or var containing string.
	Returns:
		Returns the contents of the file represented by parameter Filename
	Throws:
		Throws MfException if a problem occurs such as the file being "in use", not existing or files
		greater then 1 GB.
	Remarks:
		Wrapper for AutoHotkey Docs - FileRead.
		Static method.
		
		When the goal is to load all or a large part of a file into memory, FileRead performs much better
		than using a file-reading loop.
		
		FileRead does not obey #MaxMem. If there is concern about using too much memory, check the file size
		beforehand with Mfunc.FileGetSize.
		
		FileOpen() provides more advanced functionality than FileRead, such as reading or writing data at a
		specific location in the file without reading the entire file into memory. See File Object for a
		list of functions.
		
		Reading Binary Data
		
		Depending on the file, parameters and default settings, FileRead may interpret the file data as text
		and convert it to the native encoding used by the script. This is likely to cause problems if the
		file contains binary data, except in the following cases:
		
		If the *C option is present, all code page and end-of-line translations are unconditionally bypassed.
		
		If the *Pnnn option is present and nnn corresponds to the native string encoding, no code page translation occurs.
		
		If the current file encoding setting corresponds to the native string encoding, no code page translation occurs.

		Note that once the data has been read into OutputVar, only the text before the first binary zero (if
		any are present) will be "seen" by most AutoHotkey commands and functions. However, the entire
		contents are still present and can be accessed by advanced methods such as NumGet().
		Finally, FileOpen() and File.RawRead or File.ReadNum may be used to read binary data without first
		reading the entire file into memory.
*/
	FileRead(Filename) {
		v := Null
		try {
			_Filename := MfString.Getvalue(Filename)
			FileRead, v, %_Filename%
		} catch e {
			msg := MfString.Format(MfEnvironment.Instance.GetResourceString("Exception_FileRead"), FileName)
			ex := new MfException(msg, e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		Return, v
	}
; 	End:FileRead ;}
;{ 	FileReadLine					- Static - Method
/*
	Method: FileReadLine()

	OutputVar := Mfunc.FileReadLine(Filename, LineNum)

	Mfunc.FileReadLine(Filename, LineNum)
		Reads the specified line from a file and returns the text.
	Parameters:
		Filename
			The name of the file to access, which is assumed to be in %A_WorkingDir% if an absolute path isn't
			specified. Windows and Unix formats are supported; that is, the file's lines may end in either
			carriage return and linefeed (`r`n) or just linefeed (`n).
			Can be MfString instance or var containing string.
		LineNum
			Which line to read (1 is the first, 2 the second, and so on). This can be an expression.
			If the specified line number is greater than the number of lines in the file, ErrorLevel is set to 1
			and Return value is not changed. This also happens when the specified line number is the last line
			in the file but that line is blank and does not end in a newline/CRLF.
			Can be MfInteger instance or var containing integer.
	Returns:
		Returns the retrieved text.
	Throws:
		Throws MfException is non-zero then InnerException has a message of A_LastError.
		If the specified line number is greater than the number of lines in the file then MfException is
		thrown with InnerException. This also happens when the specified line number is the last line in the
		file but that line is blank and does not end in a newline/CRLF.
	Remarks:
		Wrapper for AutoHotkey Docs - FileCreateDir.
		Static method.
		It is strongly recommended to use this command only for small files, or in cases where only a single
		line of text is needed. To scan and process a large number of lines (one by one), use a  file-
		reading loop for best performance. To read an entire file into a variable, use Mfunc.FileRead.
		Although any leading and trailing tabs and spaces present in the line will be written to return
		value, the linefeed character (`n) at the end of the line will not. Tabs and spaces can be trimmed
		from both ends of any variable by assigning it to itself while AutoTrim is on (the default). For
		example:
		MyLine = %MyLine%.
		Lines up to 65,534 characters long can be read. If the length of a line exceeds this, the remaining
		characters cannot be retrieved by this method.
*/
	FileReadLine(Filename, LineNum) {
		try {
			_Filename := MfString.Getvalue(Filename), _LineNum := MfInteger.GetValue(LineNum)
			FileReadLine, v, %_Filename%, %_LineNum%
			if ((ErrorLevel) && (A_LastError)) {
				ex := new MfException(A_LastError)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Return, v
	}
; 	End:FileReadLine ;}
;{ 	FileRemoveDir					- Static - Method
/*
	Method: FileRemoveDir()
	Mfunc.FileRemoveDir(DirName [, Recurse?])

	Parameters:
		DirName
			Name of the directory to delete, which is assumed to be in %A_WorkingDir% if an absolute path isn't
			specified.
			Can be MfString instance or var containing string.
		Recurse?
			0 (default): Do not remove files and sub-directories contained in DirName. In this case, if DirName
			is not empty, no action will be taken.
			1: Remove all files and subdirectories (like the Windows command "rmdir /S").
			This parameter can be an expression, even one that evaluates to true or false (since true and false
			are stored internally as 1 and 0) or MfBool instance or var containing true or false.
	Throws:
		Throws MfException throw any errors with InnerException set to the Autohotkey - FileRemoveDir error
		message.
		Throws MfException any other general error occurs.
	Remarks:
		Wrapper for AutoHotkey - FileRemoveDir.
		Static method.
*/
	FileRemoveDir(Path, Recurse = 0) {
		try {
			_Path := MfString.Getvalue(Path), _Recurse := MfBool.GetValue(Recurse, false)
			FileRemoveDir, %_Path%, %_Recurse%
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (ErrorLevel) {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

	}
; 	End:FileRemoveDir ;}
;{ 	FileSelectFile					- Static - Method
/*
	Method: FileSelectFile()

	OutputVar := Mfunc.FileSelectFile([Options, RootDir\Filename, Prompt, Filter])

	Mfunc.FileSelectFile([Options, RootDir\Filename, Prompt, Filter])
		Displays a standard dialog that allows the user to open or save file(s).
	Parameters:
		Options
			If omitted, it will default to zero, which is the same as having none of the options below.
			
			M: Multi-select. Specify the letter M to allow the user to select more than one file via shift-
			click, control-click, or other means. M may optionally be followed by a number as described below
			(for example, both M and M1 are valid). To extract the individual files, see the example at the
			bottom of this page.
			
			S: Save button. Specify the letter S to cause the dialog to always contain a Save button instead of
			an Open button. S may optionally be followed by a number (or sum of numbers) as described below (for
			example, both S and S24 are valid).
			Even if M and S are absent, the following numbers can be used. To put more than one of them into
			effect, add them up. For example, to use 8 and 16, specify the number 24.
			
			1: File Must Exist
			2: Path Must Exist
			8: Prompt to Create New File
			16: Prompt to OverWrite File
			32 [v1.0.43.09+]: Shortcuts (.lnk files) are selected as-is rather than being resolved to their
			   targets. This option also prevents navigation into a folder via a folder shortcut.
			
			If the "Prompt to Overwrite" option is present without the "Prompt to Create" option, the dialog
			will contain a Save button rather than an Open button. This behavior is due to a quirk in Windows.
		RootDir\Filename
			If present, this parameter contains one or both of the following:
			RootDir: The root (starting) directory, which is assumed to be a subfolder in %A_WorkingDir% if an
			absolute path is not specified. If omitted or blank, the starting directory will be a default that
			might depend on the OS version (it will likely be the directory most recently selected by the user
			during a prior use of FileSelectFile). In v1.0.43.10+ on Windows XP/2003 and earlier, a CLSID such
			as ::{20d04fe0-3aea-1069-a2d8-08002b30309d} (i.e. My Computer) may also be specified, in which case
			any subdirectory present after the CLSID should end in a backslash (otherwise, the string after the
			last backslash will be interpreted as the default filename, below).
			Filename: The default filename to initially show in the dialog's edit field. Only the naked filename
			(with no path) will be shown. To ensure that the dialog is properly shown, ensure that no illegal
			characters are present (such as /<|:").
			Examples:
				C:\My Pictures\Default Image Name.gif ; Both RootDir and Filename are present.
				C:\My Pictures ; Only RootDir is present.
				My Pictures ; Only RootDir is present, and it's relative to the current working directory.
		Prompt
			Text displayed in the window to instruct the user what to do. If omitted or blank, it will default
			to "Select File - %A_SCRIPTNAME%" (i.e. the name of the current script).
		Filter
			Indicates which types of files are shown by the dialog.
			
			Example: Documents (*.txt)
			Example: Audio (.wav; .mp2; *.mp3)
			
			If omitted, the filter defaults to All Files (.). An option for Text Documents (*.txt) will also be
			available in the dialog's "files of type" menu.
			
			Otherwise, the filter uses the indicated string but also provides an option for All Files (.) in the
			dialog's "files of type" drop-down list. To include more than one file extension in the filter,
			separate them with semicolons as illustrated in the example above.
	Returns:
		Returns the filename(s) selected by the user. If the user didn't select anything (e.g. pressed
		CANCEL), returns null.
	Throws:
		Throws MfException throw any errors with InnerException set to the Autohotkey - FileRemoveDir error
		message.
	Remarks:
		Wrapper for AutoHotkey - FileSelectFile.
		Static method.

		If the user didn't select anything (e.g. pressed CANCEL), return is null. ErrorLevel is set to 1. No
		Exception is thrown on Cancel.
		
		If multi-select is not in effect, OutputVar is set to the full path and name of the single file
		chosen by the user.
		
		If the M option (multi-select) is in effect, OutputVar is set to a list of items, each of which
		except the last is followed by a linefeed (`n) character. The first item in the list is the path
		that contains all the selected files (this path will end in a backslash only if it is a root folder
		such as C:). The other items are the selected filenames (without path). For example:
			C:\My Documents\New Folder [this is the path in which all the files below reside]
			test1.txt [these are the naked filenames: no path info]
			test2.txt
			... etc.

		When multi-select is in effect, the sum of the lengths of the selected filenames is limited to 64
		KB. Although this is typically enough to hold several thousand files, OutputVar will be made blank
		if the limit is exceeded.
		
		A GUI window may display a modal file-selection dialog by means of Gui +OwnDialogs. A modal dialog
		prevents the user from interacting with the GUI window until the dialog is dismissed.
		
		Known limitation: A timer that launches during the display of a FileSelectFile dialog will postpone
		the effect of the user's clicks inside the dialog until after the timer finishes. To work around
		this, avoid using timers whose subroutines take a long time to finish, or disable all timers during
		the dialog:
			Thread, NoTimers
			FileSelectFile, OutputVar
			Thread, NoTimers, false
		
		Obsolete option: In [v1.0.25.06+], the multi-select option "4" is obsolete. However, for
		compatibility with older scripts, it still functions as it did before. Specifically, if the user
		selects only one file, OutputVar will contain its full path and name followed by a linefeed (`n)
		character. If the user selects more than one file, the format is the same as that of the M option
		described above, except that the last item also ends in a linefeed (`n).
		
		Any and/or all parameter for this function can be instance of MfString or var containing string.
*/
	FileSelectFile(Options = "", RootDir = "", Prompt = "", Filter = "") {
		try {
			_Options := MfString.Getvalue(Options), _RootDir := MfString.Getvalue(RootDir), _Prompt := MfString.Getvalue(Prompt)
			_Filter := MfString.Getvalue(Filter)
			FileSelectFile, v, %_Options%, %_RootDir%, %_Prompt%, %_Filter%	
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Return, v
	}
; 	End:FileSelectFile ;}
;{ 	FileSelectFolder				- Static - Method
/*
	Method: FileSelectFolder()

	OutputVar := Mfunc.FileSelectFolder([StartingFolder, Options, Prompt])

	Mfunc.FileSelectFolder([StartingFolder, Options, Prompt])
		Displays a standard dialog that allows the user to select a folder.
	Parameters:
		StartingFolder
			If blank or omitted, the dialog's initial selection will be the user's My Documents folder (or
			possibly My Computer). A CLSID folder such as ::{20d04fe0-3aea-1069-a2d8-08002b30309d} (i.e. My
			Computer) may be specified start navigation at a specific special folder.
			
			Otherwise, the most common usage of this parameter is an asterisk followed immediately by the
			absolute path of the drive or folder to be initially selected. For example, *C:\ would initially
			select the C drive. Similarly, *C:\My Folder would initially select that particular folder.
			
			The asterisk indicates that the user is permitted to navigate upward (closer to the root) from the
			starting folder. Without the asterisk, the user would be forced to select a folder inside
			StartingFolder (or StartingFolder itself). One benefit of omitting the asterisk is that
			StartingFolder is initially shown in a tree-expanded state, which may save the user from having to
			click the first plus sign.
			
			If the asterisk is present, upward navigation may optionally be restricted to a folder other than
			Desktop. This is done by preceding the asterisk with the absolute path of the uppermost folder
			followed by exactly one space or tab. In the following example, the user would not be allowed to
			navigate any higher than C:\My Folder (but the initial selection would be C:\My Folder\Projects):
			C:\My Folder *C:\My Folder\Projects
		Options
			One of the following numbers:
			
			0: The options below are all disabled (except on Windows 2000, where the "make new folder" button
				might appear anyway).
			1 (default): A button is provided that allows the user to create new folders.
			
			Add 2 to the above number to provide an edit field that allows the user to type the name of a
				folder. For example, a value of 3 for this parameter provides both an edit field and a "make new
				folder" button.
			Add 4 to the above number to omit the BIF_NEWDIALOGSTYLE property. Adding 4 ensures that
				FileSelectFolder will work properly even in a Preinstallation Environment like WinPE or BartPE.
				However, this prevents the appearance of a "make new folder" button, at least on Windows XP. ["4"
				requires v1.0.48+]
			
			If the user types an invalid folder name in the edit field, OutputVar will be set to the folder
			selected in the navigation tree rather than what the user entered, at least on Windows XP.
			
			This parameter can be an expression.
		Prompt
			Text displayed in the window to instruct the user what to do. If omitted or blank, it will default
			to "Select Folder - %A_SCRIPTNAME%" (i.e. the name of the current script).
	Returns:
		Returns the user's selected folder. This will be made blank if the user cancels the dialog (i.e.
		does not wish to select a folder). If the user selects a root directory (such as C:), OutputVar will
		contain a trailing backslash. If this is undesirable, remove it as follows:
			Folder := Mfunc.FileSelectFolder()
			Folder := RegExReplace(Folder, "\\$") ; Removes the trailing backslash, if present.
	Throws:
		Throws MfException throw any errors with InnerException set to the Autohotkey - FileSelectFolder
		error message.
	Remarks:
		Wrapper for AutoHotkey - FileSelectFolder.
		Static method.
		
		If the user didn't select anything (e.g. pressed CANCEL), return is null. ErrorLevel is set to 1. No
		Exception is thrown on Cancel.
		
		A GUI window may display a modal folder-selection dialog by means of Gui +OwnDialogs. A modal dialog
		prevents the user from interacting with the GUI window until the dialog is dismissed.
		
		Known limitation: A timer that launches during the display of a FileSelectFolder dialog will
		postpone the effect of the user's clicks inside the dialog until after the timer finishes. To work
		around this, avoid using timers whose subroutines take a long time to finish, or disable all timers
		during the dialog:
			Thread, NoTimers
			FileSelectFile, OutputVar
			Thread, NoTimers, false
		
		Any and/or all parameter for this function can be instance of MfString or var containing string.
*/
	FileSelectFolder(StartingFolder = "", Options = "", Prompt = "") {
		try {
			_StartingFolder := MfString.Getvalue(StartingFolder)
			_Options := MfString.Getvalue(Options), _Prompt := MfString.Getvalue(Prompt)
			FileSelectFolder, v, %_StartingFolder%, %_Options%, %_Prompt%
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Return, v
	}
; 	End:FileSelectFolder ;}
;{ 	FileSetAttrib					- Static - Method
/*
	Method: FileSetAttrib()
	Mfunc.FileSetAttrib(Attributes [, FilePattern, OperateOnFolders?, Recurse?])
		Changes the attributes of one or more files or folders. Wildcards are supported.
	Parameters:
		Attributes
			The attributes to change (see Remarks).
			Can be MfString instance or var containing string.
		FilePattern
			The name of a single file or folder, or a wildcard pattern such as C:\Temp*.tmp. FilePattern is
			assumed to be in %A_WorkingDir% if an absolute path isn't specified.
			Can be MfString instance or var containing string.
		OperateOnFolders?
			0 (default) Folders are not operated upon (only files).
			1 All files and folders that match the wildcard pattern are operated upon.
			2 Only folders are operated upon (no files).
			
			Note: If FilePattern is a single folder rather than a wildcard pattern, it will always be operated
			upon regardless of this setting.
			This parameter can be an expression, MfBool instance or var containing true or false.
		Recurse?
			0 (default) Subfolders are not recursed into.
			1 Subfolders are recursed into so that files and folders contained therein are operated upon if they
			match FilePattern. All subfolders will be recursed into, not just those whose names match
			FilePattern. However, files and folders with a complete path name longer than 259 characters are
			skipped over as though they do not exist. Such files are rare because normally, the operating system
			does not allow their creation. This parameter can be an expression, MfBool instance or var
			containing true or false.
	Throws:
		Throws MfException is non-zero then InnerException message is set to the value of A_LastError
	Remarks:
		Wrapper for AutoHotkey - FileSetAttrib.
		Static method.
		The Attributes parameter consists of a collection of operators and attribute letters.
		
		Operators:
		+ Turn on the attribute.
		- Turn off the attribute.
		^ Toggle the attribute (set it to the opposite value of what it is now)
		
		Attribute letters:
		R = read-only
		A = ARCHIVE
		S = SYSTEM
		H = HIDDEN
		N = NORMAL (this is valid only when used without any other attributes)
		O = OFFLINE
		T = TEMPORARY
		
		Note: Currently, the compression state of files cannot be changed with this command.
*/
	FileSetAttrib(Attributes, FilePattern="", OperateOnFolders=0, Recurse=0) {
		try {
			_Attributes := MfString.Getvalue(Attributes), _FilePattern := MfString.Getvalue(FilePattern)
			_OperateOnFolders := MfBool.GetValue(OperateOnFolders, false), _Recurse := MfBool.GetValue(Recurse, false)
			FileSetAttrib, %_Attributes%, %_FilePattern%, %_OperateOnFolders%, %_Recurse%
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (ErrorLevel) {
			e := ""
			if (A_LastError) {
				e := new MfException(A_LastError)
				e.Source := A_ThisFunc
			}
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
; 	End:FileSetAttrib ;}
;{ 	FormatTime						- Static - Method
/*!
	Method: FormatTime([YYYYMMDDHH24MISS, Format])
		FormatTime() Transforms a [YYYYMMDDHH24MISS](http://ahkscript.org/docs/commands/FileSetTime.htm#YYYYMMDD){_blank} timestamp into the specified date/time format.
	Parameters:
		YYYYMMDDHH24MISS - Leave this parameter blank to use the current local date and time. Otherwise, specify all or
			the leading part of a timestamp in the [YYYYMMDDHH24MISS](http://ahkscript.org/docs/commands/FileSetTime.htm#YYYYMMDD){_blank}
			format. If the date and/or time portion of the timestamp is invalid -- such as February 29th of a non-leap year -- the
			date and/or time will be omitted from return value. Although only years between 1601 and 9999 are supported, a formatted
			time can still be produced for earlier years as long as the time portion is valid.  
			` `  
			Can be [MfString](MfString.html) instance or var containing string.
		Format - If omitted, it defaults to the time followed by the long date, both of which will be formatted according to the
			current user's locale. For example: 4:55 PM Saturday, November 27, 2004
			` `  
			Otherwise, specify one or more of the date-time formats below, along with any literal spaces and punctuation in
			between (commas do not need to be escaped; they can be used normally). In the following example, note that M must
			be capitalized: M/d/yyyy h:mm tt  
			` `  
			Can be [MfString](MfString.html) instance or var containing string.
	Extra:@file:md\MfuncFormatTimeExtra.md
	Example:@file:md\MfuncFormatTimeExample.scriptlet
*/
	FormatTime(YYYYMMDDHH24MISS = "", Format = "") {
		_YYYYMMDDHH24MISS := MfString.Getvalue(YYYYMMDDHH24MISS), _Format := MfString.Getvalue(Format)
		FormatTime, v, %_YYYYMMDDHH24MISS%, %_Format%
		Return, v
	}
; 	End:FormatTime ;}
;{ 	Functions						- Static - Method
/*!
	Method: Functions()
		Functions() Returns True. Functions to check and see if include exist
	Returns:
		Returns **true**
	Example:
		> if (!MFunc.Functions()) {
		> 	throw exception("Missing include for Mfunc")
		> }
*/
	Functions() {
		Return, true
	}
; 	End:Functions ;}
;{ 	GuiControlGet					- Static - Method
/*
	Method: GuiControlGet()

	OutputVar := Mfunc.GuiControlGet([Sub-command, ControlID, Param4])

	Mfunc.GuiControlGet([Sub-command, ControlID, Param4])
		Retrieves various types of information about a control in a GUI window.
	Parameters:
		Sub
			command - See list below.
		ControlID
			If the target control has an associated variable, specify the variable's name as the ControlID (this
			method takes precedence over the ones described next). For this reason, it is usually best to assign
			a variable to any control that will later be accessed via GuiControl or GuiControlGet, even if that
			control is not input-capable (such as GroupBox or Text).
			
			Otherwise, ControlID can be either ClassNN (the classname and instance number of the control) or the
			control's text, both of which can be determined via Window Spy. When using text, the matching
			behavior is determined by SetTitleMatchMode. Note: a picture control's file name (as it was
			specified at the time the control was created) may be used as its ControlID.
			
			AutoHotkey [v1.1.04+]: ControlID can be the HWND of a control. As with any other ControlID, Sub-
			command must also include the name or number of the GUI if it is not the default window.
			For example, Value := GuiControlGet("2:", Hwnd).
		Param4 This parameter is omitted except where noted in the list of sub
			commands below.
	Returns:
		Returns result of Sub-command. If the command cannot complete (see ErrorLevel below), this variable
		is made blank.
	
	Sub-commands
		(Blank): Leave Sub-command blank to retrieve the control's contents. All control types are self-
		(explanatory except the following:
		
		Picture: Retrieves the picture's file name as it was originally specified when the control was
			created. This name does not change even if a new picture file name is specified.
		
		Edit: Retrieves the contents but any line breaks in the text will be represented as plain linefeeds
			(`n) rather than the traditional CR+LF (`r`n) used by non-GUI commands such as ControlGetText and
			ControlSetText.
		
		Hotkey: Retrieves a blank value if there is no hotkey in the control. Otherwise it retrieves the
			modifiers and key name. Examples: ^!C, ^Home, +^NumpadHome.
		
		Checkbox /Radio: Retrieves 1 if the control is checked, 0 if it is unchecked, or -1 if it has a gray
			checkmark. To retrieve the control's text/caption instead, specify the word Text for Param4. Note:
			Unlike the Gui Submit command, radio buttons are always retrieved individually, regardless of
			whether they are in a radio group.
		
		UpDown/ Slider/ Progress: Retrieves the control's current position.
		
		Tab/ DropDownList/ ComboBox/ ListBox: Retrieves the text of the currently selected item/tab (or its
			position if the control has the AltSubmit property). For a ComboBox, if there is no selected item,
			the text in the control's edit field is retrieved instead. For a multi-select ListBox, the output
			uses the window's current delimiter.
		
		ListView and TreeView: These are not supported when Sub-command is blank. Instead, use the built-in
			ListView functions and TreeView functions
		
		StatusBar: Retrieves only the first part's text.
		
		ActiveX: Retrieves a new wrapper object for the control's ActiveX component.
		
		Note: To unconditionally retrieve any control's text/caption rather than its contents, specify the
		word Text for Param4.
		
		GuiControlGet, OutputVar, Pos: Retrieves the position and size of the control. The position is
		relative to the GUI window's client area, which is the area not including title bar, menu bar, and
		borders. The information is stored in four variables whose names all start with OutputVar. For
		example:
			MyEdit := Mfunc.GuiControlGet("Pos", "MyEdit")
			MsgBox The X coordinate is %MyEditX%. The Y coordinate is %MyEditY%. The width is %MyEditW%. The
			height is %MyEditH%.
		
		Within a function, to create a set of variables that is global instead of local, declare OutputVar
		as a global variable prior to using this command (the converse is true for assume-global functions).
		
		GuiControlGet, OutputVar, Focus: Retrieves the control identifier (ClassNN) for the control that
			currently has keyboard focus. Since the specified GUI window must be active for one of its controls
			to have focus, OutputVar will be made blank if it is not active. Example usage: focused_control :=
			Mfunc.GuiControlGet("focus").
		
		GuiControlGet, OutputVar, FocusV [v1.0.43.06+]: Same as Focus (above) except that it retrieves the
			name of the focused control's associated variable. If that control lacks an associated variable, the
			first 63 characters of the control's text/caption is retrieved instead (this is most often used to
			avoid giving each button a variable name).
		
		GuiControlGet, OutputVar, Enabled: Retrieves 1 if the control is enabled or 0 if it is disabled.
		
		GuiControlGet, OutputVar, Visible: Retrieves 1 if the control is visible or 0 if it is hidden.
		
		GuiControlGet, OutputVar, Hwnd [v1.0.46.16+]: Retrieves the window handle (HWND) of the control. A
			control's HWND is often used with PostMessage, SendMessage, and DllCall. Note: HwndOutputVar is
			usually a more concise way to get the HWND.
		
		GuiControlGet, OutputVar, Name [v1.1.03+]: Retrieves the name of the control's associated variable
			if it has one, otherwise return value is made blank.
	Throws:
		Throws MfException throw any errors with InnerException set to the Autohotkey - FileRemoveDir error
		message.
		Throws MfException any other general error occurs.
	Remarks:
		Wrapper for AutoHotkey - GuiControlGet.
		Static method.
		
		To operate upon a window other than the default (see below), include its name or number followed by
		a colon in front of the sub-command as in these examples:
			MyEdit := Mfunc.GuiControlGet("MyGui:")
			MyEdit := Mfunc.GuiControlGet("MyGui:Pos")
			Outputvar := Mfunc.GuiControlGet("MyGui:Focus")
		
		This is required even if ControlID is a control's associated variable or HWND.
		A GUI thread is defined as any thread launched as a result of a GUI action. GUI actions include
		selecting an item from a GUI window's menu bar, or triggering one of its g-labels (such as by
		pressing a button).
		
		The default window name for a GUI thread is that of the window that launched the thread. Non-GUI
		threads use 1 as their default.
		
		Any and/or all parameter for this function can be instance of MfString or var containing string.
		See Also:AutoHotkey Docs - GuiControlGet.
*/
	GuiControlGet(Subcommand = "", ControlID = "", Param4 = "") {
		try {
			_Subcommand := MfString.Getvalue(Subcommand), _ControlID := MfString.Getvalue(ControlID), _Param4 := MfString.Getvalue(Param4)
			GuiControlGet, v, %_Subcommand%, %_ControlID%, %_Param4%
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (ErrorLevel) {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		Return, v
	}
; 	End:GuiControlGet ;}
;{	HasAttribute()					- Inhertis	- MfObject
	/*!
		Method: HasAttribute(attrib)
			HasAttribute() Gets if the current instance of class derived from [MfObject](MfObject.html)
			has [MfAttribute](MfAttribute.html).  
			Inherited from [MfObject](MfObject.html).
		Parameters:
			attrib - The object instance derived from [MfAttribute](MfAttribute.html).
		Returns:
			Returns **true** if this instance of class has the [MfAttribute](MfAttribute.html); otherwise **false**.
	*/
;	End:HasAttribute() ;}
;{ 	IfBetween						- Static - Method
/*
	Method: IfBetween()

	OutputVar := Mfunc.IfBetween(byref var, LowerBound, UpperBound)

	Mfunc.IfBetween(byref var, LowerBound, UpperBound)
		Checks whether a variable's contents are numerically or alphabetically between two values (inclusive).
	Parameters:
		Var
			The variable name whose contents will be checked.
		LowerBound
			To be within the specified range, Var must be greater than or equal to this string, number, or variable reference.
		UpperBound
			To be within the specified range, Var must be less than or equal to this string, number, or variable reference.
	Returns:
		Returns true if var is between LowerBound and UpperBound; Otherwise; false.
	Remarks:
		If all three of the parameters are purely numeric, they will be compared as numbers rather than as strings.
		Otherwise, they will be compared alphabetically as strings (that is, alphabetical order will determine whether
		Var is within the specified range). In that case, StringCaseSense On can be used to make the comparison case sensitive.
		Static Method.
*/
	IfBetween(ByRef var, LowerBound, UpperBound) {
		
		If var between %LowerBound% and %UpperBound%
		Return, true
	}
; 	End:IfBetween ;}
;{ 	IfNotBetween					- Static - Method
/*
	Method: IfNotBetween()

	OutputVar := Mfunc.IfNotBetween(byref var, LowerBound, UpperBound)

	Mfunc.IfNotBetween(byref var, LowerBound, UpperBound)
		Checks whether a variable's contents are not numerically or alphabetically between two values (inclusive).
	Parameters:
		var
			The variable name whose contents will be checked.
		LowerBound
			To be within the specified range, var must be greater than or equal to this string, number, or variable reference.
		UpperBound
			To be within the specified range, var must be less than or equal to this string, number, or variable reference.
	Returns:
		Returns true if var is not between LowerBound and UpperBound; Otherwise false.
	Remarks:
		If all three of the parameters are purely numeric, they will be compared as numbers rather than as strings.
		Otherwise, they will be compared alphabetically as strings (that is, alphabetical order will determine whether
		Var is within the specified range). In that case, StringCaseSense On can be used to make the comparison
		case sensitive.
		Static Method.
*/
	IfNotBetween(ByRef var, LowerBound, UpperBound) {
		If var not between %LowerBound% and %UpperBound%
		Return, true
	}
; 	End:IfNotBetween ;}
;{ 	IfIn							- Static - Method
/*
	Method: IfIn()

	OutputVar := Mfunc.IfIn(ByRef var, MatchList)

	Mfunc.IfIn(ByRef var, MatchList)
		Checks whether a variable's contents match one of the items in a list.
	Parameters:
		Var
			The name of the variable whose contents will be checked. For the "in" operator,
			an exact match with one of the list items is required.
		MatchList
			A comma-separated list of strings, each of which will be compared to the contents of
			Var for a match. Any spaces or tabs around the delimiting commas are significant,
			meaning that they are part of the match string. For example, if MatchList is set to
			"ABC , XYZ" then Var must contain either ABC with a trailing space or XYZ with a
			leading space to cause a match.
	Returns:
		Returns true if Var is in MatchList; Otherwise false.
	Remarks:
		The comparison is always done alphabetically, not numerically.
		Static Method.
*/
	IfIn(ByRef var, MatchList) {
		If var in %MatchList%
		Return, true
	}
; 	End:IfIn ;}
;{ 	IfNotIn							- Static - Method
/*
	Method: IfNotIn()
		IfNotIn() Checks whether a variable's contents does not match one of the items in a list.

	OutputVar := Mfunc.IfNotIn(ByRef var, MatchList)

	Mfunc.IfNotIn(ByRef var, MatchList)
		Checks whether a variable's contents does not match one of the items in a list.
	Parameters:
		var
			The name of the variable whose contents will be checked. For the "in" operator, an exact
			match with one of the list items is required.
		MatchList
			A comma-separated list of strings, each of which will be compared to the contents of var
			for a match. Any spaces or tabs around the delimiting commas are significant, meaning that
			they are part of the match string. For example, if MatchList is set to "ABC , XYZ" then var
			must contain either ABC with a trailing space or XYZ with a leading space to cause a match.
	Returns:
		Returns true if var is not in MatchList; Otherwise false.
	Remarks:
		The comparison is always done alphabetically, not numerically.
		Static Method.
*/
	IfNotIn(ByRef var, MatchList) {
		If var not in %MatchList%
		Return, true
	}
; 	End:IfNotIn ;}
;{ 	IfContains						- Static - Method
/*
	Method: IfContains()

	OutputVar := Mfunc.IfContains(ByRef var, MatchList)

	Mfunc.IfContains(ByRef var, MatchList)
		Checks whether a variable's contents match one of the items in a list.
	Parameters:
		Var
			The name of the variable whose contents will be checked. For the "contains" operator,
			a match occurs more easily: whenever Var contains one of the list items as a substring.
		MatchList
			A comma-separated list of strings, each of which will be compared to the contents of
			Var for a match. Any spaces or tabs around the delimiting commas are significant, meaning
			that they are part of the match string. For example, if MatchList is set to "ABC , XYZ"
			then Var must contain either ABC with a trailing space or XYZ with a leading space to cause a match.
	Returns:
		Returns true if var is contained in MatchList; otherwise false.
	Remarks:
		The comparison is always done alphabetically, not numerically.
		Static Method.
*/
	IfContains(ByRef var, MatchList) {
		If var contains %MatchList%
		Return, true
	}
; 	End:IfContains ;}
;{ 	IfNotContains					- Static - Method
/*
	Method: IfNotContains()

	OutputVar := Mfunc.IfNotContains(ByRef var, MatchList)

	Mfunc.IfNotContains(ByRef var, MatchList)
		Checks whether a variable's contents does not match one of the items in a list.
	Parameters:
		var
			The name of the variable whose contents will be checked. For the "contains" operator,
			a match occurs more easily: whenever Var contains one of the list items as a substring.
		MatchList
			A comma-separated list of strings, each of which will be compared to the contents of var
			for a match. Any spaces or tabs around the delimiting commas are significant, meaning that
			they are part of the match string. For example, if MatchList is set to "ABC , XYZ" then var
			must contain either ABC with a trailing space or XYZ with a leading space to cause a match.
	Returns:
		Returns true if var is not contained MatchList; Otherwise false.
	Remarks:
		The comparison is always done alphabetically, not numerically.
		Static Method.
*/
	IfNotContains(ByRef var, MatchList) {
		If var not contains %MatchList%
		Return, true
	}
; 	End:IfNotContains ;}
;{ 	IfIs							- Static - Method
/*
	Method: IfIs()

	OutputVar := Mfunc.IfIs(ByRef var, type)

	Mfunc.IfIs(ByRef var, type)
		Checks whether a variable's contents are numeric, uppercase, etc.
	Parameters:
		var
			The variable name.
		type
			supported types are integer,float,number,digit,xdigit,alpha,upper,lower,alnum,space, and time
	Returns:
		Returns true if var is type; Otherwise false.
	Remarks:
		Also See:AutoHotkey if var is type method
		Static Method.
*/
	IfIs(ByRef var, type) {
		If var is %type%
		Return, true
	}
; 	End:IfIs ;}
;{ 	IfIsNot							- Static - Method
/*
	Method: IfIsNot()

	OutputVar := Mfunc.IfIsNot(ByRef var, type)

	Mfunc.IfIsNot(ByRef var, type)
		Checks whether a variable's contents are not numeric, uppercase, etc.
	Parameters:
		var
			The variable name.
		type
			supported types are integer,float,number,digit,xdigit,alpha,upper,lower,alnum,space, and time
	Returns:
		Returns true if var is not type; Otherwise false.
	Remarks:
		Also See:AutoHotkey if var is type method
		Static Method.
*/
	IfIsNot(ByRef var, type) {
		If var is not %type%
		Return, true
	}
; 	End:IfIsNot ;}
;{ 	ImageSearch						- Static - Method
/*
	Method: ImageSearch()

	OutputVar := Mfunc.ImageSearch(OutputVarX, OutputVarY, X1, Y1, X2, Y2, ImageFile)

	Mfunc.ImageSearch(OutputVarX, OutputVarY, X1, Y1, X2, Y2, ImageFile)
		Searches a region of the screen for an image.
	Parameters:
		OutputVarX/Y
			The names of the variables in which to store the X and Y coordinates of the upper-left pixel of
			where the image was found on the screen (if no match is found, the variables are made blank).
			Coordinates are relative to the active window unless CoordMode was used to change that.
			
			Either or both of these parameters may be left blank, in which case ErrorLevel (see below) can be
			used to determine whether a match was found.
			Can be MfInteger instance or var containing integer.
		X1,Y1
			The X and Y coordinates of the upper left corner of the rectangle to search, which can be
			expressions. Coordinates are relative to the active window unless CoordMode was used to change that.
			Can be MfInteger instance or var containing integer.
		X2,Y2
			The X and Y coordinates of the lower right corner of the rectangle to search, which can be
			expressions. Coordinates are relative to the active window unless CoordMode was used to change that.
			Can be MfInteger instance or var containing integer.
		ImageFile
			See ImageFile Parameter below
	Returns:
		Returns ErrorLevel
	
	ImageFile Parameter
		The file name of an image, which is assumed to be in %A_WorkingDir% if an absolute path isn't
		specified. All operating systems support GIF, JPG, BMP, ICO, CUR, and ANI images (BMP images must be
		16-bit or higher). Other sources of icons include the following types of files: EXE, DLL, CPL, SCR,
		and other types that contain icon resources. On Windows XP or later, additional image formats such
		as PNG, TIF, Exif, WMF, and EMF are supported. Operating systems older than XP can be given support
		by copying Microsoft's free GDI+ DLL into the AutoHotkey.exe folder (but in the case of a compiled
		script, copy the DLL into the script's folder). To download the DLL, search for the following phrase
		at www.microsoft.com: gdi redistributable
		
		Can be MfString instance or var containing string.
		
		Options: Zero or more of the following strings may be also be present immediately before the name of
			the file. Separate each option from the next with a single space or tab. For example: *2 *w100 *h-1
			C:\Main Logo.bmp.
		
		*IconN: To use an icon group other than the first one in the file, specify Icon followed immediately
			by the number of the group. For example, Icon2 would load the default icon from the second icon
			group.
		
		*n (variation): Specify for n a number between 0 and 255 (inclusive) to indicate the allowed number
			of shades of variation in either direction for the intensity of the red, green, and blue components
			of each pixel's color. For example, 2 would allow two shades of variation. This parameter is
			helpful if the coloring of the image varies slightly or if ImageFile uses a format such as GIF or
			JPG that does not accurately represent an image on the screen. If you specify 255 shades of
			variation, all colors will match. The default is 0 shades.
		
		*TransN: This option makes it easier to find a match by specifying one color within the image that
			will match any color on the screen. It is most commonly used to find PNG, GIF, and TIF files that
			have some transparent areas (however, icons do not need this option because their transparency is
			automatically supported). For GIF files, TransWhite might be most likely to work. For PNG and TIF
			files, TransBlack might be best. Otherwise, specify for N some other color name or RGB value (see
			the color chart for guidance, or use PixelGetColor in its RGB mode). Examples: TransBlack,
			TransFFFFAA, Trans0xFFFFAA.
		
		*wn and hn: Width and height to which to scale the image (this width and height also determines
			which icon to load from a multi-icon .ICO file). If both these options are omitted, icons loaded
			from ICO, DLL, or EXE files are scaled to the system's default small-icon size, which is usually 16
			by 16 (you can force the actual/internal size to be used by specifying w0 h0). Images that are not
			icons are loaded at their actual size. To shrink or enlarge the image while preserving its aspect
			ratio, specify -1 for one of the dimensions and a positive number for the other. For example,
			specifying w200 h-1 would make the image 200 pixels wide and cause its height to be set
			automatically.
	Throws:
		Throws MfException throw any errors with InnerException set to the Autohotkey - ImageSearch error
		message.
		No error is thrown when only ErrorLevel is set.
	Remarks:
		Wrapper for AutoHotkey Docs - ImageSearch.
		Static method.
		
		ImageSearch can be used to detect graphical objects on the screen that either lack text or whose
		text cannot be easily retrieved. For example, it can be used to discover the position of picture
		buttons, icons, web page links, or game objects. Once located, such objects can be clicked via
		Click.
		
		A strategy that is sometimes useful is to search for a small clipping from an image rather than the
		entire image. This can improve reliability in cases where the image as a whole varies, but certain
		parts within it are always the same. One way to extract a clipping is to:
		
		1. Press Alt+PrintScreen while the image is visible in the active window. This places a screen-shot
		on the clipboard.
		2. Open an image processing program such as Paint.
		3. Paste the contents of the clipboard (that is, the screen-shot.
		3. Select a region that does not vary and that is unique to the image.
		4. Copy and paste that region to a new image document.
		6. Save it as a small file for use with ImageSearch.
		
		To be a match, an image on the screen must be the same size as the one loaded via the ImageFile
		parameter and its options.
		
		The region to be searched must be visible; in other words, it is not possible to search a region of
		a window hidden behind another window. By contrast, images that lie partially beneath the mouse
		cursor can usually be detected. The exception to this is game cursors, which in most cases will
		obstruct any images beneath them.
		
		Since the search starts at the top row of the region and moves downward, if there is more than one
		match, the one closest to the top will be found.
		
		Icons containing a transparent color automatically allow that color to match any color on the
		screen. Therefore, the color of what lies behind the icon does not matter.
		
		ImageSearch supports 8-bit color screens (256-color) or higher.
		
		The search behavior may vary depending on the display adapter's color depth (especially for GIF and
		JPG files). Therefore, if a script will run under multiple color depths, it is best to test it on
		each depth setting. You can use the shades-of-variation option (*n) to help make the behavior
		consistent across multiple color depths.
		
		If the image on the screen is translucent, ImageSearch will probably fail to find it. To work around
		this, try the shades-of-variation option (*n) or make the window temporarily opaque via WinSet,
		Transparent, Off.
		
		ErrorLevel is set to 0 if the image was found in the specified region, 1 if it was not found, or 2
		if there was a problem that prevented the command from conducting the search (such as failure to
		open the image file or a badly formatted option).
*/
	ImageSearch(ByRef OutputVarX, ByRef OutputVarY, X1, Y1, X2, Y2, ImageFile) {
		try {
			_OutputVarX := MfInteger.GetValue(OutputVarX, "", true), _OutputVarY := MfInteger.GetValue(OutputVarY, "", true)
			_X1 := MfInteger.GetValue(X1, "", true), _Y1 := MfInteger.GetValue(Y1, "", true), _X2 := MfInteger.GetValue(X2, "", true), _Y2 := MfInteger.GetValue(Y2, "", true)
			_ImageFile := MfString.Getvalue(ImageFile)
			ImageSearch, _OutputVarX, _OutputVarY, %_X1%, %_Y1%, %_X2%, %_Y2%, %_ImageFile%
			Mfunc._SetObjValue(OutputVarX, _OutputVarX)
			Mfunc._SetObjValue(OutputVarY, _OutputVarY)
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return ErrorLevel
	}
; 	End:ImageSearch ;}
;{ 	IniDelete						- Static - Method
/*
	Method: IniDelete()
	Mfunc.IniDelete(Filename, Section [, Key])
		Deletes a value from a standard format .ini file.
	Parameters:
		Filename
			The name of the .ini file, which is assumed to be in %A_WorkingDir% if an absolute path isn't specified.
		Section
			The section name in the .ini file, which is the heading phrase that appears in square brackets
			(do not include the brackets in this parameter).
		Key
			The key name in the .ini file. If omitted, the entire Section will be deleted.
	Throws:
		Throws MfException throw any errors with InnerException set to the Autohotkey - IniDelete error message.
		Throws MfException any other general error occurs.
	Remarks:
		A standard ini file looks like:
			[SectionName]
			Key=Value
		
		Any and/or all parameter for this function can be instance of MfString or var containing string.
		Wrapper for AutoHotkey - IniDelete.
		Static method.
*/
	IniDelete(Filename, Section, Key= "") {
		try {
			_Filename := MfString.Getvalue(Filename), _Section := MfString.Getvalue(Section), _Key := MfString.Getvalue(Key)
			IniDelete, %_Filename%, %_Section%, %_Key%
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		if (ErrorLevel) {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
; 	End:IniDelete ;}
;{ 	IniRead							- Static - Method
/*
	Method: IniRead()
		IniRead() Reads a value, section or list of section names from a standard format .ini file.

	OutputVar := Mfunc.IniRead(Filename)
	OutputVar := Mfunc.IniRead(Filename, Section)
	OutputVar := Mfunc.IniRead(Filename, Section, Key)
	OutputVar := Mfunc.IniRead(Filename, Section, Key, Default)

	Mfunc.IniRead(Filename)
		Returns a linefeed (`n) delimited list of section names.

	Mfunc.IniRead(Filename, Section)
		Returns an entire section. Comments and empty lines are omitted. Only the first 65,533 characters of
		the section are retrieved.

	Mfunc.IniRead(Filename, Section, Key)
		Returns a value from the ini file for the current Section and Key. If the value cannot be retrieved,
		the variable is set to the value "ERROR"

	Mfunc.IniRead(Filename, Section, Key, Default)
		Returns a value from the ini file for the current Section and Key. If the value cannot be retrieved,
		the variable is set to the value indicated by the Default parameter.
	Parameters:
		Filename
			The name of the .ini file, which is assumed to be in %A_WorkingDir% if an absolute path isn't specified.
		Section
			The section name in the .ini file.
		Key
			The key name in the .ini file.
		Default
			The value to return if the requested key is not found. If omitted, it defaults to the word ERROR.
			To store a blank value (empty string), specify %A_Space%.
	Remarks:
		Wrapper for AutoHotkey Docs - IniRead.
		Static method.
		The operating system automatically omits leading and trailing spaces/tabs from the retrieved string.
		To prevent this, enclose the string in single or double quote marks. The outermost set of single or
		double quote marks is also omitted, but any spaces inside the quote marks are preserved.
		
		Values longer than 65,535 characters are likely to yield inconsistent results.
		
		A standard ini file looks like:
		[SectionName]
		Key=Value
		
		Unicode: Mfunc.IniRead and Mfunc.IniWrite rely on the external functions GetPrivateProfileString
		and WritePrivateProfileString to read and write values.
		These functions support Unicode only in UTF-16 files; all other files are assumed to use the system's
		default ANSI code page.
		
		This method does not throw any exceptions.
		If there is an error then then null or the value of Default parameter is returned.
		
		Any and/or all parameter for this function can be instance of MfString or var containing string.
*/
	IniRead(Filename, Section = "", Key = "", Default = "") {
		_Filename := MfString.Getvalue(Filename), _Section := MfString.Getvalue(Section)
		_Key := MfString.Getvalue(Key), _Default := MfString.Getvalue(Default)
		IniRead, v, %_Filename%, %_Section%, %_Key%, %_Default%
		Return, v
	}
; 	End:IniRead ;}
;{ 	IniWrite						- Static - Method
/*
	Method: IniWrite()
		IniWrite() Writes a value or section to a standard format .ini file.
	Mfunc.IniWrite(Pairs, Filename, Section)
		Writes the Pairs to the Section for a standard format .ini file.

	Mfunc.IniWrite(Value, Filename, Section, Key)
		Writes a value to the Section for a standard format .ini file.
	Parameters:
		Value
			The string or number that will be written to the right of Key's equal sign (=).
			If the text is long, it can be broken up into several shorter lines by means of a continuation
			section, which might improve readability and maintainability.
		Pairs
			[v1.0.90+]: The complete content of a section to write to the .ini file, excluding the [SectionName]
			header. Key must be omitted. Pairs must not contain any blank lines. If the section already exists,
			everything up to the last key=value pair is overwritten. Pairs can contain lines without an equal sign
			(=), but this may produce inconsistent results. Comments can be written to the file but are stripped
			out when they are read back by Mfunc.IniRead.
		Filename
			The name of the .ini file, which is assumed to be in %A_WorkingDir% if an absolute path isn't specified.
		Section
			The section name in the .ini file, which is the heading phrase that appears in square brackets
			(do not include the brackets in this parameter).
		Key
			The key name in the .ini file.
	Remarks:
		Wrapper for AutoHotkey Docs - IniWrite.
		Static method. Values longer than 65,535 characters can be written to the file, but may produce inconsistent
		results as they usually cannot be read correctly by Mfunc.IniRead or other applications.
		A standard ini file looks like:
			[SectionName]
			Key=Value
		
		New files are created in either the system's default ANSI code page or UTF-16, depending on the version of AutoHotkey.
		UTF-16 files may appear to begin with a blank line, as the first line contains the UTF-16 byte order mark.
		See below for a workaround.
		
		Unicode: IniRead and IniWrite rely on the external functions GetPrivateProfileString and WritePrivateProfileString
		to read and write values. These functions support Unicode only in UTF-16 files; all other files are assumed to use
		the system's default ANSI code page. In Unicode scripts, IniWrite uses UTF-16 for each new file.
		If this is undesired, ensure the file exists before calling IniWrite.
*/
	IniWrite(Value, FileName, Section, Key = "") {
		_Value := MfString.Getvalue(Value), _FileName := MfString.Getvalue(FileName)
		_Section := MfString.Getvalue(Section), _Key := MfString.Getvalue(Key)
		IniWrite, %_Value%, %_FileName%, %_Section%, %_Key%
		return ErrorLevel
	}
; 	End:IniWrite ;}
;{ 	Input							- Static - Method
/*
	Method: Input()

	OutputVar := Mfunc.Input([Options, EndKeys, MatchList])

	Mfunc.Input([Options, EndKeys, MatchList])
		Waits for the user to type a string.
	Parameters:
		Options
			See Options Section below.
		EndKeys
			See EndKeys Section below.
		MatchList
			See MatchList section below.
		
		Options Parameter
			A string of zero or more of the following letters (in any order, with optional spaces in between):
			
			B: Backspace is ignored. Normally, pressing backspace during an Input will remove the most recently
				pressed character from the end of the string. Note: If the input text is visible (such as in an
				editor) and the arrow keys or other means are used to navigate within it, backspace will still
				remove the last character rather than the one behind the caret (insertion point).
			
			C: Case sensitive. Normally, MatchList is not case sensitive (in versions prior to AutoHotkey
				[1.0.43.03], only the letters A-Z are recognized as having varying case, not letters like ü/Ü).
			
			I: Ignore input generated by any AutoHotkey script, such as the SendEvent command. However, the
				SendInput and SendPlay methods are always ignored, regardless of this setting.
			
			L: Length limit (e.g. L5). The maximum allowed length of the input. When the text reaches this
				length, the Input will be terminated and ErrorLevel will be set to the word Max unless the text
				matches one of the MatchList phrases, in which case ErrorLevel is set to the word Match. If
				unspecified, the length limit is 16383, which is also the absolute maximum.
			
			M: Modified keystrokes such as Control-A through Control-Z are recognized and transcribed if they
			correspond to real ASCII characters. Consider this example, which recognizes Control-C:
			Transform, CtrlC, Chr, 3 ; Store the character for Ctrl-C in the CtrlC var.
				Input, OutputVar, L1 M
				if OutputVar = %CtrlC%
				MsgBox, You pressed Control-C.
				ExitApp
			
			Note: The characters Ctrl-A through Ctrl-Z correspond to Chr(1) through Chr(26). Also, the M option
			might cause some keyboard shortcuts such as Ctrl-LeftArrow to misbehave while an Input is in
			progress.
			
			T: Timeout (e.g. T3). The number of seconds to wait before terminating the Input and setting
				ErrorLevel to the word Timeout. If the Input times out, return value will be set to whatever text
				the user had time to enter. This value can be a floating point number such as 2.5.
			
			V: Visible. Normally, the user's input is blocked (hidden from the system). Use this option to have
				the user's keystrokes sent to the active window.
			
			*: Wildcard (find anywhere). Normally, what the user types must exactly match one of the MatchList
				phrases for a match to occur. Use this option to find a match more often by searching the entire
				length of the input text.
				
			Can be MfString instance or var containing string.
			
		EndKeys Parameter
			A list of zero or more keys, any one of which terminates the Input when pressed (the EndKey itself
			is not written to OutputVar). When an Input is terminated this way, ErrorLevel is set to the word
			EndKey followed by a colon and the name of the EndKey. Examples: EndKey:., EndKey:Escape.
			
			The EndKey list uses a format similar to the Send command. For example, specifying {Enter}.{Esc}
			would cause either ENTER, period (.), or ESCAPE to terminate the Input. To use the braces themselves
			as end keys, specify {{} and/or {}}.
			
			To use Control, Alt, or Shift as end-keys, specify the left and/or right version of the key, not the
			neutral version. For example, specify {LControl}{RControl} rather than {Control}.
			
			Although modified keys such as Control-C (^c) are not supported, certain keys that require the shift
			key to be held down -- namely punctuation marks such as ?!:@&{} -- are supported in AutoHotkey
			[v1.0.14+].
			
			An explicit virtual key code such as {vkFF} may also be specified. This is useful in the rare case
			where a key has no name and produces no visible character when pressed. Its virtual key code can be
			determined by following the steps at the bottom fo the key list page.
			
			Can be MfString instance or var containing string.
		
		MatchList Parameter
			A comma-separated list of key phrases, any of which will cause the Input to be terminated (in which
			case ErrorLevel will be set to the word Match). The entirety of what the user types must exactly
			match one of the phrases for a match to occur (unless the * option is present). In addition, any
			spaces or tabs around the delimiting commas are significant, meaning that they are part of the match
			string. For example, if MatchList is "ABC , XYZ ", the user must type a space after ABC or before
			XYZ to cause a match.
			
			Two consecutive commas results in a single literal comma. For example, the following would produce a
			single literal comma at the end of string: "string1,,,string2". Similarly, the following list
			contains only a single item with a literal comma inside it: "single,,item".
			
			Because the items in MatchList are not treated as individual parameters, the list can be contained
			entirely within a variable. In fact, all or part of it must be contained in a variable if its length
			exceeds 16383 since that is the maximum length of any script line. For example, MatchList might
			consist of %List1%,%List2%,%List3% -- where each of the variables contains a large sub-list of match
			phrases.
			
			Can be MfString instance or var containing string.
		
		ErrorLevel
			AutoHotkey [v1.1.04+] This command is able to throw an exception if called with no parameters and
			there is no Input in progress. For more information, see Runtime Errors.
			
			* 1 or 0 - Whenever the command is used without parameters, ErrorLevel is set to 0 if it successfully
				terminates a prior input, or 1 if there is no Input in progress.
			* NewInput - The Input was interrupted by another thread that used the Input command.
			* Max - The Input reached the maximum allowed length and it does not match any of the items in MatchList.
			* Timeout - The Input timed out.
			* Match - The Input matches one of the items in MatchList.
			* EndKey:name - One of the EndKeys was pressed to terminate the Input. In this case, ErrorLevel
				contains the word EndKey followed by a colon and the name of the terminating key without braces,
				e.g. "EndKey:Enter", "EndKey:Escape", etc.
	Returns:
		If the parameters are omitted, any Input in progress in another thread is terminated and its
		ErrorLevel is set to the word NewInput. By contrast, the ErrorLevel of the current command will be
		set to 0 if it terminated a prior Input, or 1 if there was no prior Input to terminate.
		Return value does not store keystrokes per se. Instead, it stores characters produced by keystrokes
		according to the active window's keyboard layout/language. Consequently, keystrokes that do not
		produce characters (such as PageUp and Escape) are not stored (though they can be recognized via the
		EndKeys parameter below).
		Whitespace characters such as TAB (`t) are stored literally. ENTER is stored as linefeed (`n).
	Remarks:
		Wrapper for AutoHotkey Docs - Input.
		Static method.
		
		If this command is used while an Input is already in progress in another thread, that Input will be
		terminated and its ErrorLevel will be set to the word NewInput. After that (if parameters were
		given), the new Input will commence.
		
		While an Input is in progress, new threads such as custom menu items and timed subroutines can still
		be created. Similarly, keyboard hotkeys are still in effect if the Input is visible. If the Input is
		not visible, only hook hotkeys can be triggered.
		
		When a script first uses this command, the keyboard hook is installed (if it is not already). In
		addition, the script becomes persistent, meaning that ExitApp should be used to terminate it. The
		keyboard hook will stay installed until the next use of the Suspend or Hotkey command, at which time
		it is removed if not required by any hotkeys or hotstrings.
		
		If you use multiple languages or keyboard layouts, Input uses the keyboard layout of the active
		window rather than the script's (regardless of whether the Input is visible). However, in versions
		prior to AutoHotKey [1.0.44.03], the script's own layout is used.
		
		Although not as flexible, hotstrings are generally easier to use than the Input command.
*/
	Input(Options = "", EndKeys = "", MatchList = "") {
		_Options := MfString.Getvalue(Options), _EndKeys := MfString.Getvalue(EndKeys), _MatchList := MfString.Getvalue(MatchList)
		Input, v, %_Options%, %_EndKeys%, %_MatchList%
		Return, v
	}
; 	End:Input ;}
;{ 	InputBox						- Static - Method
/*
	Method: InputBox()

	OutputVar := Mfunc.InputBox([Title, Prompt, HIDE, Width, Height, X, Y, Font, Timeout, Default])

	Mfunc.InputBox([Title, Prompt, HIDE, Width, Height, X, Y, Font, Timeout, Default])
		Displays an input box to ask the user to enter a string.
	Parameters:
		Title
			The title of the input box. If blank or omitted, it defaults to the name of the script.
			Can be MfString instance or var containing string.
		Prompt
			The text of the input box, which is usually a message to the user indicating what kind of input is
			expected. If Prompt is long, it can be broken up into several shorter lines by means of a
			continuation section, which might improve readability and maintainability.
			Can be MfString instance or var containing string.
		HIDE
			If this parameter is the word HIDE, the user's input will be masked, which is useful for passwords.
			This Parameter and true or false. Can be an instance of MfBool or can be instance of MfString
			containing a value of "HIDE" or a var.
		Width
			If this parameter is blank or omitted, the starting width of the window will be 375. This parameter
			can be an expressions.
			Can be MfInteger instance or var containing integer.
		Height
			If this parameter is blank or omitted, the starting height of the window will be 189. This parameter
			can be an expression.
			Can be MfInteger instance or var containing integer.
		X, Y
			The X and Y coordinates of the window (use 0,0 to move it to the upper left corner of the desktop),
			which can be expressions.. If either coordinate is blank or omitted, the dialog will be centered in
			that dimension. Either coordinate can be negative to position the window partially or entirely off
			the desktop.
			Can be MfInteger instance or var containing integer.
		Font
			Not yet implemented (leave blank). In the future it might accept something like verdana:8
			Can be MfString instance or var containing string.
		Timeout
			Timeout in seconds (can contain a decimal point or be an expressions.). If this value exceeds
			2147483 (24.8 days), it will be set to 2147483. After the timeout has elapsed, the InputBox window
			will be automatically closed and ErrorLevel will be set to 2. OutputVar will still be set to what
			the user entered.
			Can be MfFloat instance or var containing float.
		Default
			A string that will appear in the InputBox's edit field when the dialog first appears. The user can
			change it by backspacing or other means.
			Can be MfString instance or var containing string.
	Returns:
		Returns the text entered by the user.
	Throws:
		Throws MfException throw any errors with InnerException set to the Autohotkey - InputBox error
		message.
	Remarks:
		Wrapper for AutoHotkey Docs - InputBox.
		Static method.
		
		The dialog allows the user to enter text and then press OK or CANCEL. The user can resize the dialog
		window by dragging its borders.
		
		ErrorLevel is set to 1 if the user presses the CANCEL button, 0 if the user presses OK, or 2 if the
		dialog times out. In all three cases, Return is set to the value entered. This allows the CANCEL
		button to perform a function other than CANCEL should the script designer wish it.
		
		A GUI window may display a modal InputBox by means of Gui +OwnDialogs. A modal InputBox prevents the
		user from interacting with the GUI window until the InputBox is dismissed.
*/
	InputBox(Title = "", Prompt = "", HIDE = "", Width = "", Height = "", X = "", Y = "", Font = "", Timeout = "", Default = "") {
		try {
			_Title := MfString.Getvalue(Title), _Prompt := MfString.Getvalue(Prompt)
			_HIDE := ""
			if (HIDE) {
				if (IsObject(HIDE)) {
					if (MfObject.IsObjInstance(HIDE, "MfString")) {
						_HIDE := HIDE.Value
					} else if (MfObject.IsObjInstance(HIDE, "MfBool")) {
						if (HIDE.Value = true) {
							_HIDE := "HIDE"
						}
					}
				} else {
					if (MfBool.TryParse(bHide, HIDE)) {
						if (bHide = true) {
							_HIDE := "HIDE"
						}
					} Else {
						_HIDE := HIDE
					}
					
				}
			}
			
			_Width := MfInteger.GetValue(Width, "", true), _Height := MfInteger.GetValue(Height, "", true), _X := MfInteger.GetValue(X, "", true)
			_Y := MfString.Getvalue(Y), _Font := MfString.Getvalue(Font), _Timeout := MfFloat.Getvalue(Timeout, "", true)
			_Default := MfString.Getvalue(Default)
			InputBox, v, %_Title%, %_Prompt%, %_HIDE%, %_Width%, %_Height%, %_X%, %_Y%, , %_Timeout%, %_Default%
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Return, v
	}
; 	End:InputBox ;}
;{ 	MouseGetPos						- Static - Method
/*
	Method: MouseGetPos()
	Mfunc.MouseGetPos([OutputVarX, OutputVarY, OutputVarWin, OutputVarControl, 1|2|3])
		Retrieves the current position of the mouse cursor, and optionally which window and control it is
		hovering over.
	Parameters:
		OutputVarX/Y
			The names of the variables in which to store the X and Y coordinates. The retrieved coordinates are
			relative to the active window unless CoordMode was used to change to screen coordinates.
			Can be MfInteger instance or var containing integer.
		OutputVarWin
			This optional parameter is the name of the variable in which to store the unique ID number of the
			window under the mouse cursor. If the window cannot be determined, this variable will be made blank.
			Can be MfString instance or var containing string.
		OutputVarControl
			This optional parameter is the name of the variable in which to store the name (ClassNN) of the
			control under the mouse cursor. If the control cannot be determined, this variable will be made
			blank.
			The names of controls should always match those shown by the version of Window Spy distributed with
			AutoHotkey [v1.0.14+] (but not necessarily older versions of Window Spy). However, unlike Window
			Spy, the window under the mouse cursor does not have to be active for a control to be detected.
			Can be MfString instance or var containing string.
		1|2|3
			If omitted, it defaults to 0. Otherwise, specify one of the following digits:
			1: Uses a simpler method to determine OutputVarControl. This method correctly retrieves the
				active/topmost child window of an Multiple Document Interface (MDI) application such as SysEdit or
				TextPad. However, it is less accurate for other purposes such as detecting controls inside a
				GroupBox control.
			2  AutoHotkey [v1.0.43.06+]: Stores the control's HWND in OutputVarControl rather than the control's
				ClassNN.
			3 AutoHotkey [v1.0.43.06+]: A combination of 1 and 2 above.
			
			Can be MfByte instance or var containing 1,2 or 3.
	Remarks:
		Wrapper for AutoHotkey Docs - MouseGetPos.
		Static method.
*/
	MouseGetPos(ByRef OutputVarX = "", ByRef OutputVarY = "", ByRef OutputVarWin = "", ByRef OutputVarControl = "", Mode = "") {
		_OutputVarX := MfInteger.GetValue(OutputVarX, "", true), _OutputVarY := MfInteger.GetValue(OutputVarY, "", true)
		_OutputVarWin := MfString.Getvalue(OutputVarWin), _OutputVarControl := MfString.Getvalue(OutputVarControl), _Mode := MfByte.Getvalue(Mode, "", true)
		MouseGetPos, _OutputVarX, _OutputVarY, _OutputVarWin, _OutputVarControl, %_Mode%
		Mfunc._SetObjValue(OutputVarX, _OutputVarX)
		Mfunc._SetObjValue(OutputVarY, _OutputVarY)
		Mfunc._SetObjValue(OutputVarWin, _OutputVarWin)
		Mfunc._SetObjValue(OutputVarControl, _OutputVarControl)
	}
; 	End:MouseGetPos ;}
;{ 	PixelGetColor					- Static - Method
/*
	Method: PixelGetColor()

	OutputVar := Mfunc.PixelGetColor(X, Y [, Alt|Slow|RGB])

	Mfunc.PixelGetColor(X, Y [, Alt|Slow|RGB])
		Retrieves the color of the pixel at the specified x,y coordinates.
	Parameters:
		X, Y
			The X and Y coordinates of the pixel, which can be expressions. Coordinates are relative to the
			active window unless CoordMode was used to change that.
			Can be MfInteger instance or var containing integer.
		Alt|Slow|RGB
			This parameter may contain zero or more of the following words. If more than one word is present,
			separate each from the next with a space (e.g. Alt RGB).
			
			Alt AutoHotkey [v1.0.43.10+]: Uses an alternate method to retrieve the color, which should be used
				when the normal method produces invalid or inaccurate colors for a particular type of window. This
				method is about 10% slower than the normal method.
			
			Slow AutoHotkey [v1.0.43.10+]: Uses a more elaborate method to retrieve the color, which may work in
				certain full-screen applications when the other methods fail. This method is about three times
				slower than the normal method. Note: Slow takes precedence over Alt, so there is no need to specify
				Alt in this case.
			
			RGB: Retrieves the color in RGB vs. BGR format. In other words, the red and the blue components are
				swapped. This is useful for retrieving colors compatible with WinSet, Gui, Progress, and
				SplashImage.
			Can be MfString instance or var containing string.
	Returns:
		Returns the color ID in hexadecimal blue-green-red (BGR) format. For example, the color purple is
		defined 0x800080 because it has an intensity of 80 for its blue and red components but an intensity
		of 00 for its green component.
	Throws:
		Throws MfException throw any errors with InnerException set to the Autohotkey - PixelGetColor error
		message.
		Throws MfException any other general error occurs.
	Remarks:
		Wrapper for AutoHotkey - PixelGetColor.
		Static method.

		The pixel must be visible; in other words, it is not possible to retrieve the pixel color of a
		window hidden behind another window. By contrast, pixels beneath the mouse cursor can usually be
		detected. The exception to this is game cursors, which in most cases will hide any pixels beneath
		them.
		
		Use Window Spy (available in tray icon menu) or the example at the bottom of this page to determine
		the colors currently on the screen.
		
		Known limitations:
		A window that is partially transparent or that has one of its colors marked invisible (TransColor)
			typically yields colors for the window behind itself rather than its own.
		PixelGetColor might not produce accurate results for certain applications. If this occurs, try
			specifying the word Alt or Slow in the last parameter.
*/
	PixelGetColor(X, Y, RGB = "") {
		try {
			_X := MfInteger.GetValue(X), _Y := MfInteger.GetValue(Y), _RGB := MfString.Getvalue(RGB)
			PixelGetColor, v, %_X%, %_Y%, %_RGB%
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (ErrorLevel) {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Return, v
	}
; 	End:PixelGetColor ;}
;{ 	PixelSearch						- Static - Method
/*
	Method: PixelSearch()
	Mfunc.PixelSearch(OutputVarX, OutputVarY, X1, Y1, X2, Y2, ColorID [, Variation, Fast|RGB])
		Searches a region of the screen for a pixel of the specified color.
	Parameters:
		OutputVarX/Y
			The names of the variables in which to store the X and Y coordinates of the first pixel that matches
			ColorID (if no match is found, the variables are made blank). Coordinates are relative to the active
			window unless CoordMode was used to change that.
			
			Either or both of these parameters may be left blank, in which case ErrorLevel (see below) can be
			used to determine whether a match was found.
		X1, Y1
			The X and Y coordinates of the upper left corner of the rectangle to search, which can be
			expressions. Coordinates are relative to the active window unless CoordMode was used to change that.
		X2, Y2
			The X and Y coordinates of the lower right corner of the rectangle to search, which can be
			expressions. Coordinates are relative to the active window unless CoordMode was used to change that.
		ColorID
			The decimal or hexadecimal color ID to search for, in Blue-Green-Red (BGR) format, which can be an
			expression. Color IDs can be determined using Window Spy (accessible from the tray menu) or via
			Mfunc.PixelGetColor. For example: 0x9d6346.
		Variation
			A number between 0 and 255 (inclusive) to indicate the allowed number of shades of variation in
			either direction for the intensity of the red, green, and blue components of the color (can be an
			expression). This parameter is helpful if the color sought is not always exactly the same shade. If
			you specify 255 shades of variation, all colors will match. The default is 0 shades.
		Fast|RGB
			This parameter may contain the word Fast, RGB, or both (if both are present, separate them with a
				space; that is, Fast RGB).
			
			Fast: Uses a faster searching method that in most cases dramatically reduces the amount of CPU time
				used by the search. Although color depths as low as 8-bit (256-color) are supported, the fast mode
				performs much better in 24-bit or 32-bit color. If the screen's color depth is 16-bit or lower, the
				Variation parameter might behave slightly differently in fast mode than it does in slow mode.
				Finally, the fast mode searches the screen row by row (top down) instead of column by column.
				Therefore, it might find a different pixel than that of the slow mode if there is more than one
				matching pixel.
			
			RGB: Causes ColorID to be interpreted as an RGB value instead of BGR. In other words, the red and
				blue components are swapped.
	Throws:
		Throws MfException throw any errors with InnerException set to the Autohotkey - PixelSearch error
		message.
	Remarks:
		Wrapper for AutoHotkey - PixelSearch
		Static method.

		The region to be searched must be visible; in other words, it is not possible to search a region of
		a window hidden behind another window. By contrast, pixels beneath the mouse cursor can usually be
		detected. The exception to this is cursors in games, which in most cases will hide any pixels
		beneath them.
		
		Slow mode only: By default, the search starts at the upper-left pixel of the region and checks all
		pixels vertically beneath it for a match. If no match is found there, the search continues to the
		right, column by column, until it finds a matching pixel. The default left-to-right search order can
		be inverted by swapping X1 and X2 in the parameter list. In other words, if X1 is greater than X2,
		the search will be conducted from right to left, starting at column X1. Similarly, if Y1 is greater
		than Y2, each column of pixels to be searched starting at the bottom rather than the top. Finally,
		if the region to be searched is large and the search is repeated with high frequency, it may consume
		a lot of CPU time. To alleviate this, keep the size of the area to a minimum.

	ErrorLevel:
		ErrorLevel is set to 0 if the color was found in the specified region, 1 if it was not found, or 2
		if there was a problem that prevented the command from conducting the search.
*/
	PixelSearch(ByRef OutputVarX, ByRef OutputVarY, X1, Y1, X2, Y2, ColorID, Variation = "", Mode = "") {
		try {
			_OutputVarX := MfInteger.GetValue(OutputVarX), _OutputVarY := MfInteger.GetValue(OutputVarY)
			_X1 := MfInteger.GetValue(X1), _Y1 := MfInteger.GetValue(Y1), _X2 := MfInteger.GetValue(X2), _Y2 := MfInteger.GetValue(Y2)
			_Variation := MfByte.GetValue(Variation, "", true), _Mode := MfString.Getvalue(Mode)
			PixelSearch, _OutputVarX, _OutputVarY, %_X1%, %_Y1%, %_X2%, %_Y2%, %_ColorID%, %_Variation%, %_Mode%
			Mfunc._SetObjValue(OutputVarX, _OutputVarX)
			Mfunc._SetObjValue(OutputVarY, _OutputVarY)
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
; 	End:PixelSearch ;}
;{ 	Process							- Static - Method
/*
	Method: Process()

	OutputVar := Mfunc.Process(Cmd [, PID-or-Name, Param3])

	Mfunc.Process(Cmd [, PID-or-Name, Param3])
		Performs one of the following operations on a process: checks if it exists; changes its priority;
		closes it; waits for it to close.
	Parameters:
		Cmd
			One of the following words:
			
			Exist: Sets ErrorLevel to the Process ID (PID) if a matching process exists, or 0 otherwise. If the
				PID-or-Name parameter is blank, the script's own PID is retrieved. An alternate, single-line method
				to retrieve the script's PID is PID := DllCall("GetCurrentProcessId").
			
			Close: If a matching process is successfully terminated, ErrorLevel is set to its former Process ID
				(PID). Otherwise (there was no matching process or there was a problem terminating it), it is set to
				0. Since the process will be abruptly terminated -- possibly interrupting its work at a critical
				point or resulting in the loss of unsaved data in its windows (if it has any) -- this method should
				be used only if a process cannot be closed by using WinClose on one of its windows.
			
			List: Although List is not yet supported, the examples section demonstrates how to retrieve a list
				of processes via DllCall.
			
			Priority: Changes the priority (as seen in Windows Task Manager) of the first matching process to
				Param3 and sets ErrorLevel to its Process ID (PID). If the PID-or-Name parameter is blank, the
				script's own priority will be changed. If there is no matching process or there was a problem
				changing its priority, ErrorLevel is set to 0.
			
			Param3 should be one of the following letters or words: L (or Low), B (or BelowNormal), N (or
			Normal), A (or AboveNormal), H (or High), R (or Realtime). Note: Any process not designed to run at
			Realtime priority might reduce system stability if set to that level.
			
			Wait: Waits up to Param3 seconds (can contain a decimal point) for a matching process to exist. If
				Param3 is omitted, the command will wait indefinitely. If a matching process is discovered,
				ErrorLevel is set to its Process ID (PID). If the command times out, ErrorLevel is set to 0.
			
			WaitClose: Waits up to Param3 seconds (can contain a decimal point) for ALL matching processes to
				close. If Param3 is omitted, the command will wait indefinitely. If all matching processes are
				closed, ErrorLevel is set to 0. If the command times out, ErrorLevel is set to the Process ID (PID)
				of the first matching process that still exists.
		PID
			or-Name - This parameter can be either a number (the PID) or a process name as described below. It
				can also be left blank to change the priority of the script itself.
			
			PID: The Process ID, which is a number that uniquely identifies one specific process (this number is
				valid only during the lifetime of that process). The PID of a newly launched process can be
				determined via the Run command. Similarly, the PID of a window can be determined with WinGet. The
				Process command itself can also be used to discover a PID.
			
			Name: The name of a process is usually the same as its executable (without path), e.g. notepad.exe
				or winword.exe. Since a name might match multiple running processes, only the first process will be
				operated upon. The name is not case sensitive.
		Param3
			See Cmd above for details.
	Returns:
		Returns ErrorLevel
	Remarks:
		Wrapper for AutoHotkey - Process.
		Static method.
		
		For Wait and WaitClose: Processes are checked every 100 milliseconds; the moment the condition is
		satisfied, the command stops waiting. In other words, rather than waiting for the timeout to expire,
		it immediately sets ErrorLevel as described above, then continues execution of the script. Also,
		while the command is in a waiting state, new threads can be launched via hotkey, custom menu item,
		or timer.
		
		Any and/or all parameter for this function can be instance of MfString or var containing string.
*/
	Process(Cmd, Pid_Or_Name, Parm3="") {
		_Cmd := MfString.Getvalue(Cmd), _Pid_Or_Name := MfString.Getvalue(Pid_Or_Name), _Parm3 := MfString.Getvalue(Parm3)
		Process, %_Cmd%, %_Pid_Or_Name%, %_Parm3%
		return ErrorLevel
	}
; End:Process ;}
;{ 	Random							- Static - Method
/*
	Method: Random()

	OutputVar := Mfunc.Random([ Min, Max])
	OutputVar := Mfunc.Random(, NewSeed)

	Mfunc.Random()
		Generates a pseudo-random number.
	Parameters:
		Min
			The smallest number that can be generated, which can be negative, floating point, or an expression.
			If omitted, the smallest number will be 0. The lowest allowed value is -2147483648 for integers, but
			floating point numbers have no restrictions.
		Max
			The largest number that can be generated, which can be negative, floating point, or an expression.
			If omitted, the largest number will be 2147483647 (which is also the largest allowed integer value
			-- but floating point numbers have no restrictions).
		NewSeed
			This mode reseeds the random number generator with NewSeed (which can be an expression). This
			affects all subsequently generated random numbers. NewSeed should be an integer between 0 and
			4294967295 (0xFFFFFFFF). Reseeding can improve the quality/security of generated random numbers,
			especially when NewSeed is a genuine random number rather than one of lesser quality such as a
			pseudo-random number. Generally, reseeding does not need to be done more than once.
			
			If reseeding is never done by the script, the seed starts off as the low-order 32-bits of the 64-bit
			value that is the number of 100-nanosecond intervals since January 1, 1601. This value travels from
			0 to 4294967295 every ~7.2 minutes.
	Returns:
		Returns random number as var. The format of stored floating point numbers is determined by
		SetFormat.
	Remarks:
		Wrapper for AutoHotkey Docs - Random.
		Static method.
		
		This command yields a pseudo-randomly generated number, which is a number that simulates a true
		random number but is really a number based on a complicated formula to make determination/guessing
		of the next number extremely difficult.
		
		All numbers within the specified range have approximately the same probability of being generated
		(however, see "known limitations" below).
		
		If either Min or Max contains a decimal point, the end result will be a floating point number in the
		format set by SetFormat. Otherwise, the result will be an integer.
		
		Known limitations for floating point: 1) only about 4,294,967,296 distinct numbers can be generated
		for any particular range, so all other numbers in the range will never be generated; 2) occasionally
		a result can be slightly greater than the specified Max (this is caused in part by the imprecision
		inherent in floating point numbers).
		
		Comments based on the original source
		
		This function uses the Mersenne Twister random number generator, MT19937, written by Takuji
		Nishimura and Makoto Matsumoto, Shawn Cokus, Matthe Bellew and Isaku Wada.
		
		The Mersenne Twister is an algorithm for generating random numbers. It was designed with
		consideration of the flaws in various other generators. The period, 219937-1, and the order of
		equidistribution, 623 dimensions, are far greater. The generator is also fast; it avoids
		multiplication and division, and it benefits from caches and pipelines. For more information see the
		inventors' web page at www.math.keio.ac.jp/~matumoto/emt.html
		
		Copyright (C) 1997 - 2002, Makoto Matsumoto and Takuji Nishimura, All rights reserved.
		Redistribution and use in source and binary forms, with or without modification, are permitted
		provided that the following conditions are met:
		
		* Redistributions of source code must retain the above copyright notice, this list of conditions and
		  the following disclaimer.
		* Redistributions in binary form must reproduce the above copyright notice, this list of conditions
		  and the following disclaimer in the documentation and/or other materials provided with the
		  distribution.
		* The names of its contributors may not be used to endorse or promote products derived from this
		  software without specific prior written permission.
		
		THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
		IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
		FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
		CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
		DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
		DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
		IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
		THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
		
		Do NOT use for CRYPTOGRAPHY without securely hashing several returned values together, otherwise the
		generator state can be learned after reading 624 consecutive values.
		
		When you use this, send an email to: matumoto@math.keio.ac.jp with an appropriate reference to your
		work. It would be nice to CC: rjwagner@writeme.com and Cokus@math.washington.edu when you write.
		
		This above has been already been done for AutoHotkey, but if you use the Random command in a
		publicly distributed application, consider sending an e-mail to the above people to thank them.
*/
	Random(Min = "", Max = "") {
		Random, v, %Min%, %Max%
		Return, v
	}
; 	End:Random ;}
;{ 	RegRead							- Static - Method
/*
	Method: RegRead()

	OutputVar := Mfunc.RegRead(RootKey, SubKey [, ValueName])

	Mfunc.RegRead(RootKey, SubKey [, ValueName])
		Reads a value from the registry.
	Parameters:
		RootKey
			Must be either HKEY_LOCAL_MACHINE, HKEY_USERS, HKEY_CURRENT_USER, HKEY_CLASSES_ROOT, or
			HKEY_CURRENT_CONFIG (or the abbreviations for each of these, such as HKLM). To access a remote
			registry, prepend the computer name and a colon, as in this example:
			\workstation01:HKEY_LOCAL_MACHINE
		SubKey
			The name of the subkey (e.g. Software\SomeApplication).
		ValueName
			The name of the value to retrieve. If omitted, Subkey's default value will be retrieved, which is
			the value displayed as "(Default)" by RegEdit. If there is no default value (that is, if RegEdit
			displays "value not set"), OutputVar is made blank and ErrorLevel is set to 1.
	Returns:
		Returns the name of the variable in which to store the retrieved value. If the value cannot be
		retrieved, the variable is made blank and ErrorLevel is set to 1.
	Throws:
		Throws MfException is non-zero then InnerException message is set to the value of A_LastError
	Remarks:
		Wrapper for AutoHotkey Docs - RegRead.
		Static method.
		
		Currently only the following value types are supported: REG_SZ, REG_EXPAND_SZ, REG_MULTI_SZ,
		REG_DWORD, and REG_BINARY.
		
		REG_DWORD values are always expressed as positive decimal numbers.
		
		When reading a REG_BINARY key the result is a string of hex characters. For example, the REG_BINARY
		value of 01,a9,ff,77 will be read as the string 01A9FF77.
		When reading a REG_MULTI_SZ key, each of the components ends in a linefeed character (`n). If there
		are no components, Return value will be made blank. See Mfunc.FileSelectFile for an example of how
		to extract the individual components from return value.
		
		REG_BINARY values larger than 64K can only be read in AutoHotkey [v1.1.10.01+] and later.
		To retrieve and operate upon multiple registry keys or values, consider using a registry-loop.
		For details about how to access the registry of a remote computer, see the remarks in registry-loop.
		
		To read and write entries from the 64-bit sections of the registry in a 32-bit script or vice versa,
		use SetRegView.
		
		Any and/or all parameter for this function can be instance of MfString or var containing string.
*/
	RegRead(RootKey, SubKey, ValueName = "") {
		try {
			_RootKey := MfString.Getvalue(RootKey), _SubKey := MfString.Getvalue(SubKey), _ValueName := MfString.Getvalue(ValueName)
			RegRead, v, %_RootKey%, %_SubKey%, %_ValueName%
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (ErrorLevel) {
			e := ""
			if (A_LastError) {
				e := new MfException(A_LastError)
				e.Source := A_ThisFunc
			}
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Return, v
	}
; 	End:RegRead ;}
;{ 	RegWrite						- Static - Method
/*
	Method: RegWrite()
	Mfunc.RegWrite(ValueType, RootKey, SubKey [, ValueName, Value])
		Writes a value to the registry.
	Parameters:
		ValueType
			Must be either REG_SZ, REG_EXPAND_SZ, REG_MULTI_SZ, REG_DWORD, or REG_BINARY.
		RootKey
			Must be either HKEY_LOCAL_MACHINE, HKEY_USERS, HKEY_CURRENT_USER, HKEY_CLASSES_ROOT, or
			HKEY_CURRENT_CONFIG (or the abbreviations for each of these, such as HKLM). To access a remote
			registry, prepend the computer name and a colon, as in this example:
			\workstation01:HKEY_LOCAL_MACHINE
		SubKey
			The name of the subkey (e.g. Software\SomeApplication). If SubKey does not exist, it is created
			(along with its ancestors, if necessary). If SubKey is left blank, the value is written directly
			into RootKey (though some operating systems might refuse to write in HKEY_CURRENT_USER's top level).
		ValueName
			The name of the value that will be written to. If blank or omitted, Subkey's default value will be
			used, which is the value displayed as "(Default)" by RegEdit.
		Value
			The value to be written. If omitted, it will default to an empty (blank) string, or 0, depending on
			ValueType. If the text is long, it can be broken up into several shorter lines by means of a
			continuation section, which might improve readability and maintainability.
	Throws:
		Throws MfException is non-zero then InnerException message is set to the value of A_LastError
	Remarks:
		Wrapper for AutoHotkey - RegWrite.
		Static method.
		
		If ValueType is REG_DWORD, Value should be between -2147483648 and 4294967295 (0xFFFFFFFF).
		
		When writing a REG_BINARY key, use a string of hex characters, e.g. the REG_BINARY value of
		01,a9,ff,77 can be written by using the string 01A9FF77.
		
		When writing a REG_MULTI_SZ key, you must separate each component from the next with a linefeed
		character (`n). The last component may optionally end with a linefeed as well. No blank components
		are allowed. In other words, do not specify two linefeeds in a row (`n`n) because that will result
		in a shorter-than-expected value being written to the registry.
		
		REG_BINARY and REG_MULTI_SZ values larger than 64K are supported in AutoHotkey [v1.1.10.01] and
		later. In older versions, they are truncated to 64K
		To retrieve and operate upon multiple registry keys or values, consider using a registry-loop.
		
		For details about how to access the registry of a remote computer, see the remarks in registry-loop.
		To read and write entries from the 64-bit sections of the registry in a 32-bit script or vice versa,
		use SetRegView.
		
		Any and/or all parameter for this function can be instance of MfString or var containing string.
*/
	RegWrite(ValueType, RootKey, SubKey, ValueName := "", Value := "") {
		try {
			_ValueType := MfString.Getvalue(ValueType), _RootKey := MfString.Getvalue(RootKey)
			_ValueName := MfString.Getvalue(ValueName), _Value := MfString.Getvalue(Value)
			_SubKey := MfString.Getvalue(SubKey)
			RegWrite, %_ValueType%,%_RootKey%,%_SubKey%,%_ValueName%,%_Value%
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		if (ErrorLevel) {
			e := ""
			if (A_LastError) {
				e := new MfException(A_LastError)
				e.Source := A_ThisFunc
			}
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
; 	End:RegWrite ;}
;{ 	Run								- Static - Method
/*
	Method: Run()
	Mfunc.Run(Target [, WorkingDir, Max|Min|Hide|UseErrorLevel])
		Runs an external program. Unlike Run, RunWait will wait until the program finishes before
		continuing.
	Parameters:
		Target
			A document, URL, executable file (.exe, .com, .bat, etc.), shortcut (.lnk), or system verb to launch
			(see remarks). If Target is a local file and no path was specified with it, A_WorkingDir will be
			searched first. If no matching file is found there, the system will search for and launch the file
			if it is integrated ("known"), e.g. by being contained in one of the PATH folders.
			
			To pass parameters, add them immediately after the program or document name. If a parameter contains
			spaces, it is safest to enclose it in double quotes (even though it may work without them in some
			cases).
		WorkingDir
			The working directory for the launched item. Do not enclose the name in double quotes even if it
			contains spaces. If omitted, the script's own working directory (A_WorkingDir) will be used.
		Max|Min|Hide
		UseErrorLevel
			If omitted, Target will be launched normally. Alternatively, it can contain one or more of these
			words:
			
			Max: launch maximized
			
			Min: launch minimized
			
			Hide: launch hidden (cannot be used in combination with either of the above)
			
			Note: Some applications (e.g. Calc.exe) do not obey the requested startup state and thus
			Max/Min/Hide will have no effect.
			
			UseErrorLevel: UseErrorLevel can be specified alone or in addition to one of the above words (by
			separating it from the other word with a space). If the launch fails, this option skips the warning
			dialog, sets ErrorLevel to the word ERROR, and allows the current thread to continue. If the launch
			succeeds, RunWait sets ErrorLevel to the program's exit code, and Run sets it to 0.
			
			When UseErrorLevel is specified, the variable A_LastError is set to the result of the operating
			system's GetLastError() function. A_LastError is a number between 0 and 4294967295 (always formatted
			as decimal, not hexadecimal). Zero (0) means success, but any other number means the launch failed.
			Each number corresponds to a specific error condition (to get a list, search www.microsoft.com for
			"system error codes"). Like ErrorLevel, A_LastError is a per-thread setting; that is, interruptions
			by other threads cannot change it. However, A_LastError is also set by DllCall.
	Returns:
		Returns the name of the variable in which to store the newly launched program's unique Process ID
		(PID). The variable will be made blank if the PID could not be determined, which usually happens if
		a system verb, document, or shortcut is launched rather than a direct executable file. RunWait also
		supports this parameter, though its OuputVarPID must be checked in another thread (otherwise, the
		PID will be invalid because the process will have terminated by the time the line following RunWait
		executes).
		
		After the Run command retrieves a PID, any windows to be created by the process might not exist yet.
		To wait for at least one window to be created, use WinWait ahk_pid %OutputVarPID%.
	Throws:
		Throws MfException throw any errors with InnerException set to the Autohotkey - Run error message.
	ErrorLevel
		Mfunc.Run unless UseErrorLevel (above) is in effect, in which case ErrorLevel is set to the word
		ERROR upon failure or 0 upon success.
		Mfunc.RunWait to the program's exit code (a signed 32-bit integer). If UseErrorLevel is in effect
		and the launch failed, the word ERROR is stored.
	Remarks:
		Wrapper for AutoHotkey - Run/RunWait.
		Static method.

		Unlike Run, RunWait will wait until Target is closed or exits, at which time ErrorLevel will be set
		to the program's exit code (as a signed 32-bit integer). Some programs will appear to return
		immediately even though they are still running; these programs spawn another process.
		
		If Target contains any commas, they may ( but not necessary ) be escaped as shown three times in the
		following example:
			Mfunc.Run("rundll32.exe shell32.dll`,Control_RunDLL desk.cpl`,`, 3") ; Opens Control Panel > Display
			Properties > Settings
			; Escape is not necessary with Mfunc.Run()
			Mfunc.Run("rundll32.exe shell32.dll,Control_RunDLL desk.cpl,, 3") ; Opens Control Panel > Display
			Properties > Settings
		
		When running a program via Comspec (cmd.exe) -- perhaps because you need to redirect the program's
		input or output -- if the path or name of the executable contains spaces, the entire string should
		be enclosed in an outer pair of quotes and all inner quotes need to be doubled as shown in this
		example:

			Mfunc.Run(comspec . " /c ""C:\My Utility.exe"" ""param 1"" ""second param"" >""C:\My File.txt""")
		
		If Target cannot be launched, an error window is displayed and the current thread is exited, unless
		the string UseErrorLevel is included in the third parameter or the error is caught by a Try /Catch
		statement.
		
		Performance may be slightly improved if Target is an exact path, e.g.
		Mfunc.Run("C:\Windows\Notepad.exe ""C:\My Documents\Test.txt""") rather than Mfunc.Run("C:\My
		Documents\Test.txt").
		
		Special CLSID folders may be opened via Run. For example:
			Mfunc.Run("::{20d04fe0-3aea-1069-a2d8-08002b30309d}") ; Opens the "My Computer" folder.
			Mfunc.Run("::{645ff040-5081-101b-9f08-00aa002f954e}") ; Opens the Recycle Bin.
		
		System verbs correspond to actions available in a file's right-click menu in the Explorer. If a file
		is launched without a verb, the default verb (usually "open") for that particular file type will be
		used. If specified, the verb should be followed by the name of the target file. The following verbs
		are currently supported:
		
		*verb - AutoHotkey [v1.0.90+]: Any system-defined or custom verb. For example: Mfunc.Run("Compile "
			. A_ScriptFullPath) On Windows Vista and later, the RunAs verb may be used in place of the Run As
			Administrator right-click menu item.
		
		properties - Displays the Explorer's properties window for the indicated file. For example: Run,
			properties "C:\My File.txt" Note: The properties window will automatically close when the script
			terminates. To prevent this, use WinWait to wait for the window to appear, then use WinWaitClose to
			wait for the user to close it.
		
		find - Opens an instance of the Explorer's Search Companion or Find File window at the indicated
			folder. For example: Mfunc.Run("find D:\")
		
		explore - Opens an instance of Explorer at the indicated folder. For example: Mfunc.Run("explore " .
			A_ProgramFiles).
		
		edit - Opens the indicated file for editing. It might not work if the indicated file's type does not
			have an "edit" action associated with it. For example: Mfunc.Run("edit ""C:\My File.txt""")
		
		open - Opens the indicated file (normally not needed because it is the default action for most file
			types). For example: Mfunc.Run("open ""My File.txt""").
		
		print - Prints the indicated file with the associated application, if any. For example:
			Mfunc.Run("print ""My File.txt""")
		
		While RunWait is in a waiting state, new threads can be launched via hotkey, custom menu item, or
		timer.
		
		Any and/or all parameter for this function can be instance of MfString or var containing string.
*/
	Run(Target, WorkingDir = "", Mode = "") {
		try {
			_Target := MfString.Getvalue(Target), _WorkingDir := MfString.Getvalue(WorkingDir), _Mode := MfString.Getvalue(Mode)
			Run, %_Target%, %_WorkingDir%, %_Mode%, v	
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Return, v	
	}
; 	End:Run ;}
;{ 	RunWait							- Static - Method
/*
	Method: RunWait()
	Mfunc.RunWait(Target [, WorkingDir, Max|Min|Hide|UseErrorLevel])
		Runs an external program. Unlike Run, RunWait will wait until the program finishes before
		continuing.
	Parameters:
		Target
			A document, URL, executable file (.exe, .com, .bat, etc.), shortcut (.lnk), or system verb to launch
			(see remarks). If Target is a local file and no path was specified with it, A_WorkingDir will be
			searched first. If no matching file is found there, the system will search for and launch the file
			if it is integrated ("known"), e.g. by being contained in one of the PATH folders.
			
			To pass parameters, add them immediately after the program or document name. If a parameter contains
			spaces, it is safest to enclose it in double quotes (even though it may work without them in some
			cases).
		WorkingDir
			The working directory for the launched item. Do not enclose the name in double quotes even if it
			contains spaces. If omitted, the script's own working directory (A_WorkingDir) will be used.
		Max|Min|Hide
		UseErrorLevel
			If omitted, Target will be launched normally. Alternatively, it can contain one or more of these
			words:
			Max: launch maximized
			
			Min: launch minimized
			
			Hide: launch hidden (cannot be used in combination with either of the above)
			
			Note: Some applications (e.g. Calc.exe) do not obey the requested startup state and thus
			Max/Min/Hide will have no effect.
			
			UseErrorLevel: UseErrorLevel can be specified alone or in addition to one of the above words (by
			separating it from the other word with a space). If the launch fails, this option skips the warning
			dialog, sets ErrorLevel to the word ERROR, and allows the current thread to continue. If the launch
			succeeds, RunWait sets ErrorLevel to the program's exit code, and Run sets it to 0.
			
			When UseErrorLevel is specified, the variable A_LastError is set to the result of the operating
			system's GetLastError() function. A_LastError is a number between 0 and 4294967295 (always formatted
			as decimal, not hexadecimal). Zero (0) means success, but any other number means the launch failed.
			Each number corresponds to a specific error condition (to get a list, search www.microsoft.com for
			"system error codes"). Like ErrorLevel, A_LastError is a per-thread setting; that is, interruptions
			by other threads cannot change it. However, A_LastError is also set by DllCall.
	Returns:
		Returns the name of the variable in which to store the newly launched program's unique Process ID
		(PID). The variable will be made blank if the PID could not be determined, which usually happens if
		a system verb, document, or shortcut is launched rather than a direct executable file. RunWait also
		supports this parameter, though its OuputVarPID must be checked in another thread (otherwise, the
		PID will be invalid because the process will have terminated by the time the line following RunWait
		executes).
		
		After the Run command retrieves a PID, any windows to be created by the process might not exist yet.
		To wait for at least one window to be created, use WinWait ahk_pid %OutputVarPID%.
	Throws:
		Throws MfException throw any errors with InnerException set to the Autohotkey - Run error message.
	ErrorLevel
		Mfunc.Run unless UseErrorLevel (above) is in effect, in which case ErrorLevel is set to the word
		ERROR upon failure or 0 upon success.
		
		Mfunc.RunWait to the program's exit code (a signed 32-bit integer). If UseErrorLevel is in effect
		and the launch failed, the word ERROR is stored.
	Remarks:
		Wrapper for AutoHotkey - Run/RunWait.
		Static method.
		
		Unlike Run, RunWait will wait until Target is closed or exits, at which time ErrorLevel will be set
		to the program's exit code (as a signed 32-bit integer). Some programs will appear to return
		immediately even though they are still running; these programs spawn another process.
		
		If Target contains any commas, they may ( but not necessary ) be escaped as shown three times in the
		following example:
			Mfunc.Run("rundll32.exe shell32.dll`,Control_RunDLL desk.cpl`,`, 3") ; Opens Control Panel > Display
			Properties > Settings
			; Escape is not necessary with Mfunc.Run()
			Mfunc.Run("rundll32.exe shell32.dll,Control_RunDLL desk.cpl,, 3") ; Opens Control Panel > Display
			Properties > Settings
		
		When running a program via Comspec (cmd.exe) -- perhaps because you need to redirect the program's
		input or output -- if the path or name of the executable contains spaces, the entire string should
		be enclosed in an outer pair of quotes and all inner quotes need to be doubled as shown in this
		example:
			Mfunc.Run(comspec . " /c ""C:\My Utility.exe"" ""param 1"" ""second param"" >""C:\My File.txt""")
		
		If Target cannot be launched, an error window is displayed and the current thread is exited, unless
		the string UseErrorLevel is included in the third parameter or the error is caught by a Try /Catch
		statement.
		
		Performance may be slightly improved if Target is an exact path, e.g.
		Mfunc.Run("C:\Windows\Notepad.exe ""C:\My Documents\Test.txt""") rather than Mfunc.Run("C:\My
		Documents\Test.txt").
		
		Special CLSID folders may be opened via Run. For example:
			Mfunc.Run("::{20d04fe0-3aea-1069-a2d8-08002b30309d}") ; Opens the "My Computer" folder.
			Mfunc.Run("::{645ff040-5081-101b-9f08-00aa002f954e}") ; Opens the Recycle Bin.
		
		System verbs correspond to actions available in a file's right-click menu in the Explorer. If a file
		is launched without a verb, the default verb (usually "open") for that particular file type will be
		used. If specified, the verb should be followed by the name of the target file. The following verbs
		are currently supported:
		
		*verb - AutoHotkey [v1.0.90+]: Any system-defined or custom verb. For example: Mfunc.Run("Compile "
			. A_ScriptFullPath) On Windows Vista and later, the RunAs verb may be used in place of the Run As
			Administrator right-click menu item.
		
		properties - Displays the Explorer's properties window for the indicated file. For example: Run,
		
		properties "C:\My File.txt" Note: The properties window will automatically close when the script
			terminates. To prevent this, use WinWait to wait for the window to appear, then use WinWaitClose to
			wait for the user to close it.
		
		find - Opens an instance of the Explorer's Search Companion or Find File window at the indicated
		
		folder. For example: Mfunc.Run("find D:\")
		
		explore - Opens an instance of Explorer at the indicated folder. For example: Mfunc.Run("explore " .
			A_ProgramFiles).
		
		edit - Opens the indicated file for editing. It might not work if the indicated file's type does not
			have an "edit" action associated with it. For example: Mfunc.Run("edit ""C:\My File.txt""")
		
		open - Opens the indicated file (normally not needed because it is the default action for most file
			types). For example: Mfunc.Run("open ""My File.txt""").
		
		print - Prints the indicated file with the associated application, if any. For example:
			Mfunc.Run("print ""My File.txt""")
		
		While RunWait is in a waiting state, new threads can be launched via hotkey, custom menu item, or
		timer.
		
		Any and/or all parameter for this function can be instance of MfString or var containing string.
*/
	RunWait(Target, WorkingDir = "", Mode = "") {
		try {
			_Target := MfString.Getvalue(Target), _WorkingDir := MfString.Getvalue(WorkingDir), _Mode := MfString.Getvalue(Mode)
			RunWait, %_Target%, %_WorkingDir%, %_Mode%, v	
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Return, v	
	}
; 	End:RunWait ;}
;{ 	SoundGet						- Static - Method
/*
	Method: SoundGet()

	OutputVar := Mfunc.SoundGet([ComponentType, ControlType, DeviceNumber])

	Mfunc.SoundGet([ComponentType, ControlType, DeviceNumber])
		Retrieves various settings from a sound device (master mute, master volume, etc.)
	Parameters:
		ComponentType
			If omitted or blank, it defaults to the word MASTER. Otherwise, it can be one of the following
			words: MASTER (synonymous with SPEAKERS), DIGITAL, LINE, MICROPHONE, SYNTH, CD, TELEPHONE,
			PCSPEAKER, WAVE, AUX, ANALOG, HEADPHONES, or N/A. If the sound device lacks the specified
			ComponentType, ErrorLevel will indicate the problem.
			
			The component labeled Auxiliary in some mixers might be accessible as ANALOG rather than AUX.
			
			If a device has more than one instance of ComponentType (two of type LINE, for example), usually the
			first contains the playback settings and the second contains the recording settings. To access an
			instance other than the first, append a colon and a number to this parameter. For example: Analog:2
			is the second instance of the analog component.
			
			Can be MfString instance or var containing string.
		ControlType
			If omitted or blank, it defaults to VOLUME. Otherwise, it can be one of the following words: VOLUME
			(or VOL), ONOFF, MUTE, MONO, LOUDNESS, STEREOENH, BASSBOOST, PAN, QSOUNDPAN, BASS, TREBLE,
			EQUALIZER, or the number of a valid control type (see soundcard analysis script). If the specified
			ComponentType lacks the specified ControlType, ErrorLevel will indicate the problem.
			
			Note: sound devices usually support only VOLUME (or VOL) and MUTE, although others may be available
			depending on Windows and the sound device.
			
			Can be MfString instance or var containing string.
		DeviceNumber
			A number between 1 and the total number of supported devices. If this parameter is omitted, it
			defaults to 1 (the first sound device), or on Windows Vista or above, the system's default device
			for playback. This parameter can be an expression. The soundcard analysis script may help determine
			which number to use.
			
			Can be MfInteger instance or var containing integer.
	Returns:
		Returns the name of the variable in which to store the retrieved setting, which is either a floating
		point number between 0 and 100 (inclusive) or the word ON or OFF (used only for ControlTypes ONOFF,
		MUTE, MONO, LOUDNESS, STEREOENH, and BASSBOOST). The variable will be made blank if there was a
		problem retrieving the setting. The format of the floating point number, such as its decimal places,
		is determined by SetFormat.
	ErrorLevel
		ErrorLevel is set to 0 if the command succeeded. Otherwise, it is set to one of the following
		phrases:
		* Invalid Control Type or Component Type
		* Can't Open Specified Mixer
		* Mixer Doesn't Support This Component Type
		* Mixer Doesn't Have That Many of That Component Type
		* Component Doesn't Support This Control Type
		* Can't Get Current Setting
	Throws:
		Throws MfException throw any errors with InnerException set to the Autohotkey - SoundGet error
		message.
	Remarks:
		Support for Windows Vista and later was added in AutoHotKey [v1.1.10+].
		
		To discover the capabilities of the sound devices (mixers) installed on the system -- such as the
		available component types and control types -- run the soundcard analysis script.
		
		For more functionality and finer grained control over audio, consider using the VA library.
*/
	SoundGet(ComponentType = "", ControlType = "", DeviceNumber = "") {
		try {
			_ComponentType := MfString.Getvalue(ComponentType), _ControlType := MfString.Getvalue(ControlType)
			_DeviceNumber := MfInteger.GetValue(DeviceNumber, "")
			SoundGet, v, %_ComponentType%, %_ControlType%, %_DeviceNumber%
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		Return, v
	}
; 	End:SoundGet ;}
;{ 	SetFormat						- Static - Method
/*
	Method: SetFormat()

	OutputVar := Mfunc.SetFormat(NumberType, Format)

	Mfunc.SetFormat(NumberType, Format)
		Sets the format of integers and floating point numbers generated by math operations and returns the
		previous format.
	Parameters:
		NumberType
			Must be one of the enumeration items of MfSetFormatNumberType. Can be passed in as Instance of
			MfSetFormatNumberType, MfSetFormatNumberType.Instance.[EnumItem], integer matching  enumeration item
			values of MfSetFormatNumberType or string matching one of the enumeration item names
			MfSetFormatNumberType.
		Format
			For NumberType Integer or IntegerFast, specify H or HEX for hexadecimal, or D for decimal.
			Hexadecimal numbers all start with the prefix 0x (e.g. 0xFF). AutoHotkey [v1.0.90+]: Hexadecimal
			integers are formatted with digits A-F in lowercase when this parameter is h and uppercase when it
			is H.
			
			For NumberType Float or FloatFast, specify TotalWidth.DecimalPlaces (e.g. 0.6). In v1.0.46.11+, the
			letter "e" may be appended to produce scientific notation; e.g. 0.6e or 0.6E (using uppercase
			produces an uppercase E in each number instead of lowercase). Note: In AutoHotkey 1.x, scientific
			notation must include a decimal point; e.g. 1.0e1 is valid but not 1e1.
			TotalWidth is typically 0 to indicate that number should not have any blank or zero padding. If a
			higher value is used, numbers will be padded with spaces or zeroes (see remarks) to make them that
			wide.
			
			DecimalPlaces is the number of decimal places to display (rounding will occur). If blank or zero,
			neither a decimal portion nor a decimal point will be displayed, that is, floating point results are
			displayed as integers rather than a floating point number. The starting default is 6.
			
			Padding: If TotalWidth is high enough to cause padding, spaces will be added on the left side; that
			is, each number will be right-justified. To use left-justification instead, precede TotalWidth with
			a minus sign. To pad with zeroes instead of spaces, precede TotalWidth with a zero (e.g. 06.2).
	Returns:
		Returns the Format the previous format as string var.
	Fast vs. Slow Mode
		In AutoHotKey [v1.0.48+], IntegerFast may be used instead of Integer, and FloatFast may be used
		instead of Float.
		
		* Advantages: The fast mode preserves the ability of variables to cache integers and floating point
		  numbers, which substantially accelerates numerically-intensive operations. (By contrast, the slow
		  mode forces all numeric results to be immediately converted and stored as strings.)
		
		* Disadvantages: When storing a number in a variable, the fast mode delays the effects of SetFormat
		  until the script actually needs a text/string version of that variable (e.g. to display in a
		  MsgBox). Since a different SetFormat may be in effect at that time (e.g. more or fewer decimal
		  places), this can lead to unexpected results. To make the current fast format take effect
		  immediately, use an operation like HexValue .= "", which appends an empty string to the number
		  currently stored in HexValue.
		
		If the slow mode "Integer" or "Float" is used anywhere in the script, even if that SetFormat line is
		never executed, the caching of integers or floating point numbers (respectively) is disabled the
		moment the script launches.
	Floating Point Format
		In AutoHotKey [v1.0.48+], floating point variables have about 15 digits of precision internally
		unless SetFormat Float (i.e. the slow mode) is present anywhere in the script. In that case, the
		stored precision of floating point numbers is determined by DecimalPlaces (like it was in
		[AutoHotkye pre-1.0.48] versions). In other words, once a floating point result is stored in a
		variable, the extra precision is lost and cannot be reclaimed without redoing the calculation with
		something like Mfunc.SetFormat("Float", 0.15). To avoid this loss of precision, avoid using
		SetFormat Float anywhere in the script, or use SetFormat FloatFast instead.
		
		Regardless of whether slow or fast mode is in effect, floating point results and variables are
		rounded off to DecimalPlaces whenever they are displayed or converted to a string of text (e.g.
		MsgBox or FileAppend). To see the full precision, use something like Mfunc.SetFormat("FloatFast",
		0.15).
		
		To convert a floating point number to an integer, use Var:=Round(Var), Var:=Floor(Var), or
		Var:=Ceil(Var). To convert an integer to a floating point number, add 0.0 to it (e.g. Var+=0.0) or
		use something like MyFloat:=Round(MyInteger, 1).
		
		The built-in variable A_FormatFloat contains the current floating point format (e.g. 0.6).
	Integer Format
		Integer results are normally displayed as decimal, not hexadecimal. To switch to hexadecimal, use
		Mfunc.SetFormat("IntegerFast", "Hex"). This may also be used to convert an integer from decimal to
		hexadecimal (or vice versa) as shown in the example at the very bottom of this page.
		
		Literal integers specified in a script may be written as either hexadecimal or decimal. Hexadecimal
		integers all start with the prefix 0x (e.g. 0xA9). They may be used anywhere a numerical value is
		expected. For example, Sleep 0xFF is equivalent to Sleep 255 regardless of the current integer
		format set by SetFormat.
		
		AutoHotkey supports 64-bit signed integers, which range from -9223372036854775808
		(-0x8000000000000000) to 9223372036854775807 (0x7FFFFFFFFFFFFFFF).
		The built-in variable A_FormatInteger contains the current integer format (H or D).
	Throws:
		Throws MfArgumentNullException if NumberType or Format is null.
		Throws MfArgumentException if there are errors with the Parameters.
		Throws MfException if there is any other errors.
	General Remarks:
		Wrapper for AutoHotkey - SetFormat.
		Static method.
		If SetFormat is not used in a script, integers default to decimal format, and floating point numbers
		default to TotalWidth.DecimalPlaces = 0.6. Every newly launched thread (such as a hotkey, custom
		menu item, or timed subroutine) starts off fresh with these defaults; but the defaults may be
		changed by using SetFormat in the auto-execute section (top part of the script).
		
		An old-style assignment like x=%y% omits any leading or trailing spaces (i.e. padding). To avoid
		this, use AutoTrim or the colon-equals operator (e.g. x:=y).
		
		You can determine whether a variable contains a numeric value by using "if var is
		number/integer/float"
*/
	SetFormat(NumberType, Format) {
		_numberType := Null
		EnumNt := Null
		WasFormat := Null
		if (MfNull.IsNull(NumberType))
		{
			ex := new MfArgumentNullException("NumberType")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (MfString.IsNullOrEmpty(Format))
		{
			ex := new MfArgumentNullException("Format")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Try
		{
			if (IsObject(NumberType))
			{
				if (MfObject.IsObjInstance(NumberType, MfSetFormatNumberType))
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType", "NumberType" ,"MfSetFormatNumberType")
						, "NumberType")
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				EnumNt := NumberType
				_numberType := EnumNt.ToString()

			}
			Else
			{
				if Mfunc.IsInteger(NumberType)
				{
					EnumNT := MfEnum.ToObject(MfSetFormatNumberType.GetType(), NumberType)
					_numberType := EnumNT.ToString()
				}
				Else
				{
					EnumNT := MfEnum.Parse(MfSetFormatNumberType.GetType(), NumberType)
					_numberType := EnumNT.ToString()
				}
			}
			if (EnumNt.Value < 3)
			{
				WasFormat := A_FormatInteger
				; format must be H or D
				if ((!(Format = "H")) && (!(Format = "D"))) ; check is case in-sensitive mannor
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectTypeOr", "Format", "H", "D"), "Format")
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
			Else
			{
				WasFormat := A_FormatFloat
			}
			SetFormat, %_numberType%, %Format%
		}
		Catch e
		{
			; if error originated in this method then thow it as is
			if (MfObject.IsObjInstance(e, MfException) && e.Source = A_ThisFunc)
			{
				Throw e
			}
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
			
		return WasFormat
	}
; 	End:SetFormat ;}
;{ 	SoundGetWaveVolume				- Static - Method
/*
	Method: SoundGetWaveVolume()
		SoundGetWaveVolume() Retrieves the wave output volume for a sound device.

	OutputVar := Mfunc.SoundGetWaveVolume([DeviceNumber])

	Mfunc.SoundGetWaveVolume([DeviceNumber])

	Parameters:
		DeviceNumber
			If this parameter is omitted, it defaults to 1 (the first sound device), which is usually the
			system's default device for recording and playback. Specify a number higher than 1 to operate upon a
			different sound device.
			Can be MfInteger instance or var containing integer.
	Returns:
		Returns the name of the variable in which to store the retrieved volume level, which is a floating
		point number between 0 and 100 inclusive. The variable will be made blank if there was a problem
		retrieving the volume. The format of the floating point number, such as its decimal places, is
		determined by Mfunc.SetFormat.
	Throws:
		Throws MfException throw any errors with InnerException set to the Autohotkey - SoundGetWaveVolume
		error message.
		Throws MfException any other general error occurs.
	Remarks:
		Wrapper for AutoHotkey Docs - SoundGetWaveVolume.
		Static method.
		
		The current wave output volume level can be set via SoundSetWaveVolume. Settings such as Master
		Volume, Synth, Microphone, Mute, Treble, and Bass can be set and retrieved using SoundSet and
		SoundGet.
		Windows Vista and later AutoHotKey [v1.1.10+]: This command is equivalent to SoundGet with
		ComponentType set to Wave and ControlType set to Volume.
*/
	SoundGetWaveVolume(DeviceNumber = 1) {
		try {
			_DeviceNumber := MfInteger.GetValue(DeviceNumber, 1)
			SoundGetWaveVolume, v, %_DeviceNumber%
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (ErrorLevel) {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Return, v
	}
; 	End:SoundGetWaveVolume ;}
;{ 	StatusBarGetText				- Static - Method
/*
	Method: StatusBarGetText()

	OutputVar := Mfunc.StatusBarGetText([Part#, WinTitle, WinText, ExcludeTitle, ExcludeText])

	Mfunc.StatusBarGetText([Part#, WinTitle, WinText, ExcludeTitle, ExcludeText])
		Retrieves the text from a standard status bar control.
	Parameters:
		Part#
			Which part number of the bar to retrieve, which can be an expression. Default 1, which is usually
			the part that contains the text of interest.
			
			Can be MfInteger instance or var containing integer.
		WinTitle
			A window title or other criteria identifying the target window. See WinTitle.
			
			Can be MfString instance or var containing string.
		WinText
			If present, this parameter must be a substring from a single text element of the target window (as
			revealed by the included Window Spy utility). Hidden text elements are detected if DetectHiddenText
			is ON.
			
			Can be MfString instance or var containing string.
		ExcludeTitle
			Windows whose titles include this value will not be considered.
			
			Can be MfString instance or var containing string.
		ExcludeText
			Windows whose text include this value will not be considered.
			
			Can be MfString instance or var containing string.
	Returns:
		Returns the retrieved text.
	Throws:
		Throws MfException throw any errors with InnerException set to the Autohotkey - StatusBarGetText
		error message.
		Throws MfException any other general error occurs.
	Remarks:
		Wrapper for Autohotkey - StatusBarGetText.
		Static method.
		
		This command attempts to read the first standard status bar on a window (Microsoft common control:
		msctls_statusbar32). Some programs use their own status bars or special versions of the MS common
		control, in which case the text cannot be retrieved.
		
		Rather than using this command in a loop, it is usually more efficient to use StatusBarWait, which
		contains optimizations that avoid the overhead of repeated calls to StatusBarGetText.
		Window titles and text are case sensitive. Hidden windows are not detected unless DetectHiddenText
		has been turned on.
*/
	StatusBarGetText(Part = "", WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "") {
		try {
			_Part := MfInteger.GetValue(Part, "", true), _WinTitle := MfString.Getvalue(WinTitle), _WinText := MfString.Getvalue(WinText)
			_ExcludeTitle := MfString.Getvalue(ExcludeTitle), _ExcludeText := MfString.Getvalue(ExcludeText)
			StatusBarGetText, v, %_Part%, %_WinTitle%, %_WinText%, %_ExcludeTitle%, %_ExcludeText%
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (ErrorLevel) {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Return, v
	}
; 	End:StatusBarGetText ;}
;{ 	SplitPath						- Static - Method
/*
	Method: SplitPath()
	Mfunc.SplitPath(Input [, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive])
		Separates a file name or URL into its name, directory, extension, and drive.
	Parameters:
		Input
			Name of the variable containing the file name to be analyzed.
			Can be MfString instance or var containing string.
		OutFileName
			Name of the variable in which to store the file name without its path. The file's extension is
			included.
			Can be MfString instance or var containing string.
		OutDir
			Name of the variable in which to store the directory of the file, including drive letter or share
			name (if present). The final backslash is not included even if the file is located in a drive's root
			directory.
			Can be MfString instance or var containing string.
		OutExtension
			Name of the variable in which to store the file's extension (e.g. TXT, DOC, or EXE). The dot is not
			included.
			Can be MfString instance or var containing string.
		OutNameNoExt
			Name of the variable in which to store the file name without its path, dot and extension.
			Can be MfString instance or var containing string.
		OutDrive
			Name of the variable in which to store the drive letter or server name of the file. If the file is
			on a local or mapped drive, the variable will be set to the drive letter followed by a colon (no
			backslash). If the file is on a network path (UNC), the variable will be set to the share name, e.g.
			\\Workstation01
			Can be MfString instance or var containing string.
	Remarks:
		Wrapper for AutoHotkey Docs - SplitPath.
		Static method.
		
		Any of the output variables may be omitted if the corresponding information is not needed.
		
		If InputVar contains a filename that lacks a drive letter (that is, it has no path or merely a
		relative path), OutDrive will be made blank but all the other output variables will be set
		correctly. Similarly, if there is no path present, OutDir will be made blank; and if there is a path
		but no file name present, OutFileName and OutNameNoExt will be made blank.
		
		Actual files and directories in the file system are not checked by this command. It simply analyzes
		the string given in InputVar.
		
		Wildcards (* and ?) and other characters illegal in filenames are treated the same as legal
		characters, with the exception of colon, backslash, and period (dot), which are processed according
		to their nature in delimiting the drive letter, directory, and extension of the file.
		
		Support for URLs: If Input contains a colon-double-slash, such as http://domain.com or
		ftp://domain.com, OutDir is set to the protocol prefix + domain name + directory (e.g.
		http://domain.com/images) and OutDrive is set to the protocol prefix + domain name (e.g.
		http://domain.com). All other variables are set according to their definitions above.
		
		Any and/or all parameter for this function can be instance of MfString or var containing string.
*/
	SplitPath(ByRef Input, ByRef OutFileName = "", ByRef OutDir = "", ByRef OutExtension = "", ByRef OutNameNoExt = "", ByRef OutDrive = "") {
		_InputVar := MfString.Getvalue(Input), _OutFileName := MfString.Getvalue(OutFileName), _OutDir := MfString.Getvalue(OutDir)
		_OutExtension := MfString.Getvalue(OutExtension), _OutNameNoExt := MfString.Getvalue(OutNameNoExt), _OutDrive := MfString.Getvalue(OutDrive)
		SplitPath, _InputVar, _OutFileName, _OutDir, _OutExtension, _OutNameNoExt, _OutDrive
		Mfunc._SetObjValue(Input, _InputVar), Mfunc._SetObjValue(OutFileName, _OutFileName), Mfunc._SetObjValue(OutDir, _OutDir)
		Mfunc._SetObjValue(OutExtension, _OutExtension), Mfunc._SetObjValue(OutNameNoExt, _OutNameNoExt), Mfunc._SetObjValue(OutDrive, _OutDrive)
	}
; 	End:SplitPath ;}
;{ 	StringGetPos					- Static - Method
/*!
/*
	Method: StringGetPos()

	OutputVar := Mfunc.StringGetPos(Input, SearchText [, L#|R#, Offset])

	Mfunc.StringGetPos()
		Retrieves the position of the specified substring within a string.
	Parameters:
		Input
			The name of the input variable, whose contents will be searched.
			Can be MfString instance or var containing string.
		SearchText
			The string to search for. Matching is not case sensitive unless StringCaseSense has been turned on.
			
			Can be MfString instance or var containing string.
		L#|R#
			This affects which occurrence will be found if SearchText occurs more than once within Input. If
			this parameter is omitted, Input will be searched starting from the left for the first match. If
			this parameter is 1 or the letter R, the search will start looking at the right side of Input and
			will continue leftward until the first match is found.
			
			To find a match other than the first, specify the letter L or R followed by the number of the
			occurrence. For example, to find the fourth occurrence from the right, specify r4. Note: If the
			number is less than or equal to zero, no match will be found.
			
			Can be MfString instance or var containing string.
		Offset
			The number of characters on the leftmost or rightmost side (depending on the parameter above) to
			skip over. If omitted, the default is 0. For example, the following would start searching at the
			tenth character from the left: OutputVar := Mfunc.StringGetPos(Input, "abc", , 9). This parameter
			can be an expression.
			
			Can be MfInteger instance or var containing integer.
	Returns:
		Returns the retrieved position relative to the first character of Input. Position 0 is the first
		character for StringGetPos and position 1 is the first character for InStr().
	Remarks:
		Wrapper for AutoHotkey Docs - StringGetPos.
		Static method.
		
		Unlike StringMid and InStr(), 0 is defined as the position of the first character for StringGetPos.
		
		The retrieved position is always relative to the first character of Input, regardless of whether
		L#|R# and/or Offset are specified. For example, if the string "abc" is found in 123abc789, its
		reported position will always be 3 regardless of the method by which it was found.
		
		Use Mfunc.SplitPath to more easily parse a file path into its directory, filename, and extension.
		
		The built-in variables %A_Space% and %A_Tab% contain a single space and a single tab character,
		respectively. They are useful when searching for spaces and tabs alone or at the beginning or end of
		SearchText.
	ErrorLevel
		ErrorLevel is set to 1 if the specified occurrence of SearchText could not be found within Input, or
		0 otherwise.
*/
	StringGetPos(ByRef Input, SearchText, Mode = "", Offset = "") {
		_InputVar := MfString.Getvalue(Input), _SearchText := MfString.Getvalue(SearchText)
		_Mode := MfString.Getvalue(Mode), _Offset := MfInteger.GetValue(Offset, "", true)
		StringGetPos, v, _InputVar, %_SearchText%, %_Mode%, %_Offset%
		Mfunc._SetObjValue(Input, _InputVar)
		Return, v
	}
; 	End:StringGetPos ;}
;{ 	StringLeft						- Static - Method
/*
	Method: StringLeft()

	OutputVar := Mfunc.StringLeft(Input, Count)

	Mfunc.StringLeft(Input, Count)
		Retrieves a number of characters from the left side of a string.
	Parameters:
		Input
			The name of the variable whose contents will be extracted from.
			Can be MfString instance or var containing string.
		Count
			The number of characters to extract, which can be an expression. If Count is less than or equal to
			zero, return value will be made null (blank). If Count exceeds the length of Input, return value
			will be set equal to the entirety of Input.
			
			Can be MfInteger instance or var containing integer.
	Returns:
		Returns the substring extracted from Input as var containing string.
	Remarks:
		Wrapper for AutoHotkey Docs - StringLeft.
		Static method.
*/
	StringLeft(ByRef Input, Count) {
		_InputVar := MfString.Getvalue(Input), _Count := MfInteger.GetValue(Count)
		StringLeft, v, _InputVar, %_Count%
		Mfunc._SetObjValue(Input, _InputVar)
		Return, v
	}
; 	End:StringLeft ;}
;{ 	StringLen						- Static - Method
/*
	Method: StringLen()

	OutputVar := Mfunc.StringLen(Input)

	Mfunc.StringLen(Input)
		Retrieves the count of how many characters are in a string.
	Parameters:
		Input
			The name of the variable whose contents will be measured.
			
			Can be var or any object that inherits from MfObject.
	Returns:
		Returns the length of the string as a var containing integer.
	Remarks:
		Wrapper for AutoHotkey Docs - StringLen.
		Static method.
		
		If Input is a variable to which ClipboardAll was previously assigned, StringLen will report its total size.
		
		If Input is an object derived from MfObject. then the the return value will be the length of the objects
		ToString() result.
*/
	StringLen(ByRef Input) {

		if(MfNull.IsNull(Input))
		{
			return 0
		}
		str := Mfunc._GetStringFromVarOrObj(Input)
		
		StringLen, v, str
		Return, v
	}
; 	End:StringLen ;}
	
;{ 	StringLower						- Static - Method
/*
	Method: StringLower()

	OutputVar := Mfunc.StringLower(Input [, T])

	Mfunc.StringLower(Input [, T])
		Converts a string to lowercase.
	Parameters:
		Input
			The name of the variable whose contents will be read from.
			Can be var or any object that inherits from MfObject.
		T
			If this parameter is the letter T, the string will be converted to title case. For example,
			"GONE with the WIND" would become "Gone With The Wind".
			
			Can be var containing the value of T or MfString containing the value of T
	Returns:
		Returns the newly converted string of lowercase characters as var containing string.
	Remarks:
		Wrapper for AutoHotkey Docs - StringLower.
		Static method.
		
		To detect whether a character or string is entirely uppercase or lowercase, use "if var is [not] upper/lower".
		
		If Input is an object derived from MfObject. then the the return value will be from the objects ToString() method result.
*/
	StringLower(ByRef Input, T = "") {
		if(MfNull.IsNull(Input))
		{
			return ""
		}
		str := Mfunc._GetStringFromVarOrObj(Input)
		_T := MfString.GetValue(T)
		StringLower, v, str, %_T%
		Return, v
	}
; 	End:StringLower ;}
;{ 	StringMid						- Static - Method
/*
	Method: StringMid()

	OutputVar := Mfunc.StringMid(Input, StartChar [, Count , L])

	Mfunc.StringMid(Input, StartChar [, Count , L])
		Retrieves one or more characters from the specified position in a string.
	Parameters:
		Input
			The name of the variable from whose contents the substring will be extracted.
		StartChar
			The position of the first character to be extracted, which can be an expression. Unlike
			Mfunc.StringGetPos, 1 is the first character. If StartChar is less than 1, it will be assumed to be
			1. If StartChar is beyond the end of the string, OutputVar is made null (blank).
			
			Can be MfInteger instance or var containing integer.
		Count
			In AutoHotKey [v1.0.43.10+], this parameter may be omitted or left blank, which is the same as
			specifying an integer large enough to retrieve all characters from the string.
			Otherwise, specify the number of characters to extract, which can be an expression. If Count is less
			than or equal to zero, return value will be made empty (blank). If Count exceeds the length of Input
			measured from StartChar, return value will be set equal to the entirety of Input starting at
			StartChar.
			
			Can be MfInteger instance or var containing integer.
		L
			The letter L can be used to extract characters that lie to the left of StartChar rather than to the
			right.
			Can be var containing the value of L or MfString containing the value of L.
			In the following example, return value will be set to Red:
				Input = The Red Fox
				OutputVar := Mfunc.StringMid(Input, 7, 3, "L")
			
			If the L option is present and StartChar is less than 1, return value will be made null (empty). If
			StartChar is beyond the length of Input, only those characters within reach of Count will be
			extracted. For example, the below will set return value to Fox:
				Input = The Red Fox
				OutputVar := Mfunc.StringMid(Input, 14, 6, "L")
	Returns:
		Returns the substring extracted from Input.
	Remarks:
		Wrapper for AutoHotkey - StringMid.
		Static method.
*/
	StringMid(ByRef Input, StartChar, Count , L = "") {
		if(MfNull.IsNull(Input))
		{
			return ""
		}
		_StartChar := MfInteger.GetValue(StartChar)
		_count := MfInteger.GetValue(Count)
		_L := MfString.GetValue(L)

		str := Mfunc._GetStringFromVarOrObj(Input)
		StringMid, v, str, %_StartChar%, %_Count%, %_L%
		Return, v
	}
; 	End:StringMid ;}
;{ 	StringReplace					- Static - Method
/*
	Method: StringReplace()

	OutputVar := Mfunc.StringReplace(Input, SearchText [, ReplaceText, ReplaceAll?])

	Mfunc.StringReplace(Input, SearchText [, ReplaceText, ReplaceAll?])
		Replaces the specified substring with a new string.
	Parameters:
		Input
			The name of the variable whose contents will be read from.
			
			Can be MfString or var containing string.
		SearchText
			The string to search for. Matching is not case sensitive unless StringCaseSense has been turned on.
			
			Can be MfString or var containing string.
		ReplaceText
			SearchText will be replaced with this text. If omitted or null, SearchText will be replaced with
			null (empty). In other words, it will be omitted from return value.
			
			Can be MfString or var containing string.
		ReplaceAll?
			If omitted, only the first occurrence of SearchText will be replaced. But if this parameter is 1,
			A, or All, all occurrences will be replaced.
			
			Can be MfString or var containing string.
			
			Specify the word UseErrorLevel to store in ErrorLevel the number of occurrences replaced (0 if none).
			UseErrorLevel implies "All".
	Returns:
		Returns the result of the replacement process.
	Remarks:
		Wrapper for AutoHotkey Docs - StringReplace.
		Static method.
		The built-in variables %A_Space% and %A_Tab% contain a single space and a single tab character,
		respectively. They are useful when searching for spaces and tabs alone or at the beginning or end
		of SearchText.
		
		In AutoHotkey [v1.0.45], the AllSlow option became obsolete due to improvements to performance and
		memory utilization. Although it may still be specified, it has no effect.
		
		Any and/or all parameter for this function can be instance of MfString or var containing string
*/
	StringReplace(ByRef Input, SearchText, ReplaceText = "", All = "") {
		if(MfNull.IsNull(Input))
		{
			return ""
		}
		_InputVar := Mfunc._GetStringFromVarOrObj(Input)
		_SearchText := MfString.Getvalue(SearchText)
		_ReplaceText := MfString.Getvalue(ReplaceText), _All := MfString.Getvalue(All)
		StringReplace, v, _InputVar, %_SearchText%, %_ReplaceText%, %_All%
		Mfunc._SetObjValue(InputVar, _InputVar)
		Return, v
	}
; 	End:StringReplace ;}
;{ 	StringRight						- Static - Method
/*
	Method: StringRight()

	OutputVar := Mfunc.StringRight(Input, Count)

	Mfunc.StringRight(Input, Count)
		Retrieves a number of characters from the right-hand side of a string.
	Parameters:
		Input
			The name of the variable whose contents will be extracted from.
			
			Can be MfString instance or var containing string.
		Count
			The number of characters to extract, which can be an expression.
			If Count is less than or equal to zero, return value will be made null (blank).
			If Count exceeds the length of Input, return value will be set equal to the entirety of Input.
			
			Can be MfInteger instance or var containing integer.
	Returns:
		Returns the substring extracted from Input as var containing string.
	Remarks:
		Wrapper for AutoHotkey - StringRight.
		Static method.
*/
	StringRight(ByRef Input, Count) {
		_InputVar := MfString.Getvalue(Input), _Count := MfInteger.GetValue(Count)
		StringRight, v, Input, %Count%
		Mfunc._SetObjValue(Input, _InputVar)
		Return, v
	}
; 	End:StringRight ;}
;{ 	StringSplit						- Static - Method
/*
	Method: StringSplit()

	OutputVar := Mfunc.StringSplit(Input [, Delimiters, OmitChars])

	Mfunc.StringSplit(Input [, Delimiters, OmitChars])
		Separates a string into an array of substrings using the specified delimiters.
	Parameters:
		Input
			The name of the variable whose contents will be analyzed. Do not enclose the name in percent signs
			unless you want the contents of the variable to be used as the name. Input must not be one of the
			variables in OutputArray.
			Can be instance of MfString or var containing string.
		Delimiters
			If this parameter is blank or omitted, each character of Input will be treated as a separate
			substring. Otherwise, Delimiters contains one or more characters (case sensitive), each of which is
			used to determine where the boundaries between substrings occur in Input.
			Since the delimiter characters are not considered to be part of the substrings themselves, they are
			never copied into OutputArray.
			Also, if there is nothing between a pair of delimiters within Input, the corresponding array element
			will be blank.
			
			Can be instance of MfString or var containing string.
		OmitChars
			An optional list of characters (case sensitive) to exclude from the beginning and end of each array
			element.
			For example, if OmitChars is A_Space . A_Tab, spaces and tabs will be removed from the beginning and
			end (but not the middle) of every element.
			Can be instance of MfString or var containing string.
	Returns:
		An Object Array containing the split values if any. The return Object Array contains a Count
		Property as well. See Example below.
	Remarks:
		Wrapper for AutoHotkey - StringSplit.
		Static method.
*/
	StringSplit(ByRef Input, Delimiters := "", OmitChars := "") {
		; Functions can not return Pseudo-Arrays
		_InputVar := MfString.Getvalue(Input), _Delimiters := MfString.GetValue(Delimiters), _OmitChars := MfString.GetValue(OmitChars)
		StringSplit, val, _InputVar, %_Delimiters%, %_OmitChars%
		Mfunc._SetObjValue(InputVar, _InputVar)
				
		SplitArray := Object()
		Loop, %val0%
		{
			SplitValue := val%A_Index%
			SplitArray.Push(SplitValue)
		}
		ObjRawSet(SplitArray, "Count", val0)
		return SplitArray
	}
; 	End:StringSplit ;}
;{ 	StringTrimLeft					- Static - Method
/*
	Method: StringTrimLeft()

	OutputVar := Mfunc.StringTrimLeft(Input, Count)

	Mfunc.StringTrimLeft(Input, Count)
		Removes a number of characters from the left-hand side of a string.
	Parameters:
		Input
			The name of the variable whose contents will be read from.
			
			Can be instance of MfString or var containing string.
		Count
			The number of characters to remove, which can be an expression. If Count is less than or equal to
			zero, return value will be set equal to the entirety of Input. If Count exceeds the length of Input,
			return value will be made null (blank).
			
			Can be MfInteger instance or var containing integer.
	Returns:
		Returns the shortened version of Input as var containing string.
	Remarks:
		Wrapper for AutoHotkey Docs - StringTrimLeft.
		Static method.
*/
	StringTrimLeft(ByRef Input, Count) {
		_InputVar := MfString.Getvalue(Input), _Count := MfInteger.GetValue(Count, "", true)
		StringTrimLeft, v, _InputVar, %_Count%
		Mfunc._SetObjValue(Input, _InputVar)
		Return, v
	}
; 	End:StringTrimLeft ;}
;{ 	StringTrimRight					- Static - Method
/*
	Method: StringTrimRight()

	OutputVar := Mfunc.StringTrimRight(Input, Count)

	Mfunc.StringTrimRight(Input, Count)
		Removes a number of characters from the right-hand side of a string.
	Parameters:
		Input
			The name of the variable whose contents will be read from.
			
			Can be instance of MfString or var containing string.
		Count
			The number of characters to remove, which can be an expression. If Count is less than or equal to
			zero, return value will be set equal to the entirety of Input. If Count exceeds the length of Input,
			return value will be made null (blank).
			
			Can be MfInteger instance or var containing integer.
	Returns:
		Returns the shortened version of Input as var containing string.
	Remarks:
		Wrapper for AutoHotkey Docs - StringTrimRight.
		Static method.
*/
	StringTrimRight(ByRef Input, Count) {
		_InputVar := MfString.Getvalue(Input), _Count := MfInteger.GetValue(Count, "", true)
		StringTrimRight, v, _InputVar, %_Count%
		Mfunc._SetObjValue(Input, _InputVar)
		Return, v
	}
; 	End:StringTrimRight ;}
;{ 	StringUpper						- Static - Method
/*
	Method: StringUpper()

	OutputVar := Mfunc.StringUpper(Input [, T])

	Mfunc.StringUpper(Input [, T])
		Converts a string to uppercase.
	Parameters:
		Input
			The name of the variable whose contents will be read from.
			
			Can be var or any object that inherits from MfObject.
		T
			If this parameter is the letter T, the string will be converted to title case. For example, "GONE
			with the WIND" would become "Gone With The Wind".
			
			Can be var containing the value of T or MfString containing the value of T
	Returns:
		Returns the newly converted string.
	Remarks:
		Wrapper for AutoHotkey - StringUpper.
		Static method.
		
		To detect whether a character or string is entirely uppercase or lowercase, use "if var is [not]
		upper/lower".
		
		If Input is an object derived from MfObject. then the the return value will be from the objects
		ToString() method result.
*/
	StringUpper(ByRef Input, T = "") {
		if(MfNull.IsNull(Input))
		{
			return ""
		}
		str := Mfunc._GetStringFromVarOrObj(Input)
		_T := MfString.GetValue(T)
		StringUpper, v, str, %_T%
		Return, v
	}
; 	End:StringUpper ;}
;{ 	SysGet							- Static - Method
/*
	Method: SysGet()

	OutputVar := Mfunc.SysGet(Sub-command [, Param3])

	Mfunc.SysGet(Sub-command [, Param3])
		Retrieves screen resolution, multi-monitor info, dimensions of system objects, and other system
		properties.
	Parameters:
		Sub
			command - See list below.
		Param3
			This parameter is omitted except where noted below.
	Returns:
		Returns the results of the Sub-command
	Sub-commands
		Can be MfString instance or var containing string.
		
		MonitorCount: Retrieves the total number of monitors. Unlike SM_CMONITORS mentioned in the table
			below, MonitorCount includes all monitors, even those not being used as part of the desktop.
		
		MonitorPrimary: Retrieves the number of the primary monitor, which will be 1 in a single-monitor
			system.
		
		Monitor [, N]: Retrieves the bounding coordinates of monitor number N (if N is omitted, the primary
		monitor is used). The information is stored in four variables whose names all start with OutputVar.
		If N is too high or there is a problem retrieving the info, the variables are all made blank. For
		example:
			Mon2 := Mfunc.SysGet(*Monitor*, 2)
			MsgBox, Left: %Mon2Left% -- Top: %Mon2Top% -- Right: %Mon2Right% -- Bottom %Mon2Bottom%.
		
		Within a function, to create a set of variables that is global instead of local, declare Mon2 as a
		global variable prior to using this command (the converse is true for assume-global functions).
		
		MonitorWorkArea [, N]: Same as the above except the area is reduced to exclude the area occupied by
			the taskbar and other registered desktop toolbars.
		
		MonitorName [, N]: The operating system's name for monitor number N (if N is omitted, the primary
			monitor is used).
		
		(Numeric): Specify for Sub-command one of the numbers from the table below to retrieve the
			(corresponding value. The following example would store the number of mouse buttons in a variable
			(named "MouseButtonCount" MouseButtonCount := Mfunc.SysGet43).
		
		Commonly Used
		80 - SM_CMONITORS: Number of display monitors on the desktop (not including "non-display pseudo-
			monitors").
		43 - SM_CMOUSEBUTTONS: Number of buttons on mouse (0 if no mouse is installed).
		16, 17 - SM_CXFULLSCREEN, SM_CYFULLSCREEN: Width and height of the client area for a full-screen
			window on the primary display monitor, in pixels.
		61, 62 - SM_CXMAXIMIZED, SM_CYMAXIMIZED: Default dimensions, in pixels, of a maximized top-level
			window on the primary display monitor.
		59, 60 - SM_CXMAXTRACK, SM_CYMAXTRACK: Default maximum dimensions of a window that has a caption and
			sizing borders, in pixels. This metric refers to the entire desktop. The user cannot drag the window
			frame to a size larger than these dimensions.
		28, 29 - SM_CXMIN, SM_CYMIN: Minimum width and height of a window, in pixels.
		57, 58 - SM_CXMINIMIZED, SM_CYMINIMIZED: Dimensions of a minimized window, in pixels.
		34, 35 - SM_CXMINTRACK, SM_CYMINTRACK: Minimum tracking width and height of a window, in pixels. The
			user cannot drag the window frame to a size smaller than these dimensions. A window can override
			these values by processing the WM_GETMINMAXINFO message.
		0, 1 - SM_CXSCREEN, SM_CYSCREEN: Width and height of the screen of the primary display monitor, in
			pixels. These are the same as the built-in variables A_ScreenWidth and A_ScreenHeight.
		78, 79 - SM_CXVIRTUALSCREEN, SM_CYVIRTUALSCREEN: Width and height of the virtual screen, in pixels.
			The virtual screen is the bounding rectangle of all display monitors. The SM_XVIRTUALSCREEN,
			SM_YVIRTUALSCREEN metrics are the coordinates of the top-left corner of the virtual screen.
		19 - SM_MOUSEPRESENT: Nonzero if a mouse is installed; zero otherwise.
		75 - SM_MOUSEWHEELPRESENT: Nonzero if a mouse with a wheel is installed; zero otherwise.
		63 - SM_NETWORK: Least significant bit is set if a network is present; otherwise, it is cleared. The
			other bits are reserved for future use.
		8193 - SM_REMOTECONTROL: This system metric is used in a Terminal Services environment. Its value is
			nonzero if the current session is remotely controlled; zero otherwise.
		4096 - SM_REMOTESESSION: This system metric is used in a Terminal Services environment. If the
			calling process is associated with a Terminal Services client session, the return value is nonzero.
			If the calling process is associated with the Terminal Server console session, the return value is
			zero. The console session is not necessarily the physical console.
		70 - SM_SHOWSOUNDS: Nonzero if the user requires an application to present information visually in
			situations where it would otherwise present the information only in audible form; zero otherwise.
		8192 - SM_SHUTTINGDOWN: Nonzero if the current session is shutting down; zero otherwise. Windows
		2000: The retrieved value is always 0.
		23 - SM_SWAPBUTTON: Nonzero if the meanings of the left and right mouse buttons are swapped; zero
			otherwise.
		76, 77 - SM_XVIRTUALSCREEN, SM_YVIRTUALSCREEN: Coordinates for the left side and the top of the
			virtual screen. The virtual screen is the bounding rectangle of all display monitors. By contrast,
			the SM_CXVIRTUALSCREEN, SM_CYVIRTUALSCREEN metrics (further above) are the width and height of the
			virtual screen.
		
		Not Commonly Used
		
		56 - SM_ARRANGE: Flags specifying how the system arranged minimized windows. See MSDN for more
			information.
		67 - SM_CLEANBOOT: Specifies how the system was started:
		0. Normal boot
		1. Fail-safe boot
		2. Fail-safe with network boot
		5, 6 - SM_CXBORDER, SM_CYBORDER: Width and height of a window border, in pixels. This is equivalent
			to the SM_CXEDGE value for windows with the 3-D look.
		13, 14 - SM_CXCURSOR, SM_CYCURSOR: Width and height of a cursor, in pixels. The system cannot create
			cursors of other sizes.
		36, 37 - SM_CXDOUBLECLK, SM_CYDOUBLECLK: Width and height of the rectangle around the location of a
			first click in a double-click sequence, in pixels. The second click must occur within this rectangle
			for the system to consider the two clicks a double-click. (The two clicks must also occur within a
			specified time.)
		68, 69 - SM_CXDRAG, SM_CYDRAG: Width and height of a rectangle centered on a drag point to allow for
			limited movement of the mouse pointer before a drag operation begins. These values are in pixels. It
			allows the user to click and release the mouse button easily without unintentionally starting a drag
			operation.
		45, 46 - SM_CXEDGE, SM_CYEDGE: Dimensions of a 3-D border, in pixels. These are the 3-D counterparts
			of SM_CXBORDER and SM_CYBORDER.
		7, 8 - SM_CXFIXEDFRAME, SM_CYFIXEDFRAME (synonymous with SM_CXDLGFRAME, SM_CYDLGFRAME): Thickness of
			the frame around the perimeter of a window that has a caption but is not sizable, in pixels.
			SM_CXFIXEDFRAME is the height of the horizontal border and SM_CYFIXEDFRAME is the width of the
			vertical border.
		83, 84 - SM_CXFOCUSBORDER, SM_CYFOCUSBORDER: Width (in pixels) of the left and right edges and the
			height of the top and bottom edges of a control's focus rectangle. Windows 2000: The retrieved value
			is always 0.
		21, 3 - SM_CXHSCROLL, SM_CYHSCROLL: Width of the arrow bitmap on a horizontal scroll bar, in pixels;
			and height of a horizontal scroll bar, in pixels.
		10 - SM_CXHTHUMB: Width of the thumb box in a horizontal scroll bar, in pixels.
		11, 12 - SM_CXICON, SM_CYICON: Default width and height of an icon, in pixels.
		38, 39 - SM_CXICONSPACING, SM_CYICONSPACING: Dimensions of a grid cell for items in large icon view,
			in pixels. Each item fits into a rectangle of this size when arranged. These values are always
			greater than or equal to SM_CXICON and SM_CYICON.
		71, 72 - SM_CXMENUCHECK, SM_CYMENUCHECK: Dimensions of the default menu check-mark bitmap, in
			pixels.
		54, 55 - SM_CXMENUSIZE, SM_CYMENUSIZE: Dimensions of menu bar buttons, such as the child window
			close button used in the multiple document interface, in pixels.
		47, 48 - SM_CXMINSPACING SM_CYMINSPACING: Dimensions of a grid cell for a minimized window, in
			pixels. Each minimized window fits into a rectangle this size when arranged. These values are always
			greater than or equal to SM_CXMINIMIZED and SM_CYMINIMIZED.
		30, 31 - SM_CXSIZE, SM_CYSIZE: Width and height of a button in a window's caption or title bar, in
			pixels.
		32, 33 - SM_CXSIZEFRAME, SM_CYSIZEFRAME: Thickness of the sizing border around the perimeter of a
			window that can be resized, in pixels. SM_CXSIZEFRAME is the width of the horizontal border, and
		SM_CYSIZEFRAME is the height of the vertical border. Synonymous with SM_CXFRAME and SM_CYFRAME.
		49, 50 - SM_CXSMICON, SM_CYSMICON: Recommended dimensions of a small icon, in pixels. Small icons
			typically appear in window captions and in small icon view.
		52, 53 - SM_CXSMSIZE SM_CYSMSIZE: Dimensions of small caption buttons, in pixels.
		2, 20 - SM_CXVSCROLL, SM_CYVSCROLL: Width of a vertical scroll bar, in pixels; and height of the
			arrow bitmap on a vertical scroll bar, in pixels.
		4 - SM_CYCAPTION: Height of a caption area, in pixels.
		18 - SM_CYKANJIWINDOW: For double byte character set versions of the system, this is the height of
			the Kanji window at the bottom of the screen, in pixels.
		15 - SM_CYMENU: Height of a single-line menu bar, in pixels.
		51 - SM_CYSMCAPTION: Height of a small caption, in pixels.
		9 - SM_CYVTHUMB: Height of the thumb box in a vertical scroll bar, in pixels.
		42 - SM_DBCSENABLED: Nonzero if User32.dll supports DBCS; zero otherwise.
		22 - SM_DEBUG: Nonzero if the debug version of User.exe is installed; zero otherwise.
		82 - SM_IMMENABLED: Nonzero if Input Method Manager/Input Method Editor features are enabled; zero
			otherwise.
		SM_IMMENABLED indicates whether the system is ready to use a Unicode-based IME on a Unicode
			application. To ensure that a language-dependent IME works, check SM_DBCSENABLED and the system ANSI
			code page. Otherwise the ANSI-to-Unicode conversion may not be performed correctly, or some
			components like fonts or registry setting may not be present.
		87 - SM_MEDIACENTER: Nonzero if the current operating system is the Windows XP, Media Center
			Edition, zero if not.
		40 - SM_MENUDROPALIGNMENT: Nonzero if drop-down menus are right-aligned with the corresponding menu-
			bar item; zero if the menus are left-aligned.
		74 - SM_MIDEASTENABLED: Nonzero if the system is enabled for Hebrew and Arabic languages, zero if
		not.
		41 - SM_PENWINDOWS: Nonzero if the Microsoft Windows for Pen computing extensions are installed;
			zero otherwise.
		44 - SM_SECURE: Nonzero if security is present; zero otherwise.
		81 - SM_SAMEDISPLAYFORMAT: Nonzero if all the display monitors have the same color format, zero
			otherwise. Note that two displays can have the same bit depth, but different color formats. For
			example, the red, green, and blue pixels can be encoded with different numbers of bits, or those
			bits can be located in different places in a pixel's color value.
		86 - SM_TABLETPC: Nonzero if the current operating system is the Windows XP Tablet PC edition, zero
			if not.
	Remarks:
		Wrapper for AutoHotkey - SysGet.
		Static method.
		
		The built-in variables A_ScreenWidth and A_ScreenHeight contain the dimensions of the primary
		monitor, in pixels.
		
		Any and/or all parameter for this function can be instance of MfString or var containing string.
*/
	SysGet(Subcommand, Param3 = "") {
		_Subcommand := MfString.Getvalue(Subcommand), _Param3 := MfString.Getvalue(Param3)
		SysGet, v, %_Subcommand%, %_Param3%
		Return, v
	}
; 	End:SysGet ;}
;{ 	Transform						- Static - Method
/*
	Method: Transform()

	OutputVar := Mfunc.Transform(Cmd, Value1 [, Value2])

	Mfunc.Transform(Cmd, Value1 [, Value2])
		Performs miscellaneous math functions, bitwise operations, and tasks such as ASCII/Unicode
		conversion.
	Parameters:
			Cmd, Value1/2
			See list below.
	Returns:
		Returns the result of Cmd. Mfunc.SetFormat determines whether integers are stored as hexadecimal or
		decimal.
	
	Cmd, Value1, Value2
		The Cmd, Value1 and Value2 parameters are dependent upon each other and their usage is described
		below.
		
		Unicode [, String]: (This command is not available in Unicode versions of AutoHotkey.) Retrieves or
			stores Unicode text on the clipboard. Note: The entire clipboard may be saved and restored by means
			of ClipboardAll, which allows "Transform Unicode" to operate without losing the original contents of
			the clipboard.
		
		There are two modes of operation as illustrated in the following examples:
			OutputVar := Mfunc.Transform("Unicode") ; Retrieves the clipboard's Unicode text as a UTF-8 string.
			Clipboard := Mfunc.Transform("Unicode", MyUTF_String) ; Places Unicode text onto the clipboard.
		
		In the second example above, a literal UTF-8 string ( wrapped in double quotes ) may be optionally
		used in place of MyUTF_String.
		
		Use a hotkey such as the following to determine the UTF-8 string that corresponds to a given Unicode
		string:
		^!u:: ; Control+Alt+U hotkey.
			MsgBox Copy some Unicode text onto the clipboard, then return to this window and press OK to
			continue.
			ClipUTF := Mfunc.Transform("Unicode")
			Clipboard := Mfunc.Transform("Unicode", ClipUTF . "`r`n")
			MsgBox The clipboard now contains the following line that you can paste into your script. When
			executed, this line will cause the original Unicode string you copied to be placed onto the
			clipboard:`n`n%Clipboard%
			return
		
		Note: The Send {U+nnnn} command is an alternate way to produce Unicode characters.
		
		Asc, String: Retrieves the ASCII code (a number between 1 and 255) for the first character in
			String. If String is empty, OutputVar will also be made empty. For example: OutputVar :=
			Mfunc.Transform("Asc", VarContainingString). Corresponding function: Asc(String).
		
		Deref, String: Expands variable references and escape sequences contained inside other variables.
			Any badly formatted variable references will be omitted from the expanded result. The same is true
			if OutputVar is expanded into itself; in other words, any references to OutputVar inside String's
			variables will be omitted from the expansion (note however that String itself can be %OutputVar%).
			In the following example, if var1 contains the string "test" and var2 contains the literal string
			"%var1%", OutputVar will be set to the string "test": OutputVar := Mfunc.Transform("deref", var2).
			Within a function, each variable in String always resolves to a local variable unless there is no
			such variable, in which case it resolves to a global variable (or blank if none).
		
		HTML, String [, Flags]:
		
		For ANSI executables: Converts String into its HTML equivalent by translating characters whose ASCII
		values are above 127 to their HTML names (e.g. £ becomes &pound;). In addition, the four characters
		"&<> are translated to &quot;&amp;&lt;&gt;. Finally, each linefeed (`n) is translated to <br>`n
		(i.e. <br> followed by a linefeed). The Flags parameter is ignored.
		
		For Unicode executables: In addition of the functionality above, Flags can be zero or a combination
		(sum) of the following values. If omitted, it defaults to 1.
			1: Converts certain characters to named expressions. e.g. € is converted to &euro;
			2: Converts certain characters to numbered expressions. e.g. € is converted to &#8364;
		
		Only non-ASCII characters are affected. If Flags = 3, numbered expressions are used only where a
		named expression is not available. The following characters are always converted: <>"& and `n (line
		feed).
		
		FromCodePage / ToCodePage: Deprecated. Use StrPut() / StrGet() instead.
		
		Mod, Dividend, Divisor: Retrieves the remainder of Dividend divided by Divisor. If Divisor is zero,
			Return value will be null (empty). Dividend and Divisor can both contain a decimal point. If
			negative, Divisor will be treated as positive for the calculation. In the following example, the
			result is 2: OutputVar := Mfunc.Transform("mod", 5, 3). Corresponding function: Mod(Dividend,
			Divisor).
		
		Pow, Base, Exponent: Retrieves Base raised to the power of Exponent. Both Base and Exponent may
			contain a decimal point. If Exponent is negative, Return value will be formatted as a floating point
			number even if Base and Exponent are both integers. A negative Base combined with a fractional
			Exponent such as 1.5 is not supported; it will cause OutputVar to be made blank. See also: **
			operator.
		
		Exp, N: Retrieves e (which is approximately 2.71828182845905) raised to the Nth power. N may be
			negative and may contain a decimal point. Corresponding function: Exp(N).
		
		Sqrt, Value1: Retrieves the square root of Value1. If Value1 is negative, Return value will be made
			null (empty). Corresponding function: Sqrt(Number).
		
		Log, Value1: Retrieves the logarithm (base 10) of Value1. If Value1 is negative, Return value will
			be made null (empty). Corresponding function: Log(Number).
		
		Ln, Value1: Retrieves the natural logarithm (base e) of Value1. If Value1 is negative, Return value
			will be made null (empty). Corresponding function: Ln(Number).
		
		Round, Value1 [, N]: If N is omitted, OutputVar will be set to Value1 rounded to the nearest
			integer. If N is positive number, Value1 will be rounded to N decimal places. If N is negative,
			Value1 will be rounded by N digits to the left of the decimal point. For example, -1 rounds to the
			ones place, -2 rounds to the tens place, and-3 rounds to the hundreds place. Note: Round does not
			remove trailing zeros when rounding decimal places. For example, 12.333 rounded to one decimal place
			would become 12.300000. This behavior can be altered by using something like
			Mfunc.SetFormat("Float", 0.1) prior to the operation (in fact,Mfunc.SetFormat might eliminate the
			need to use Round in the first place). Corresponding function: Round(Number [, N]).
		
		Ceil, Value1: Retrieves Value1 rounded up to the nearest integer. Corresponding function:
			Ceil(Number).
		
		Floor, Value1: Retrieves Value1 rounded down to the nearest integer. Corresponding function:
			Floor(Number).
		
		Abs, Value1: Retrieves the absolute value of Value1, which is computed by removing the leading minus
			sign (dash) from Value1 if it has one. Corresponding function: Abs(Number).
		
		Sin, Value1: Retrieves the trigonometric sine of Value1. Value1 must be expressed in radians.
			Corresponding function: Sin(Number).
		
		Cos, Value1: Retrieves the trigonometric cosine of Value1. Value1 must be expressed in radians.
			Corresponding function: Cos(Number).
		
		Tan, Value1: Retrieves the trigonometric tangent of Value1. Value1 must be expressed in radians.
			Corresponding function: Tan(Number).
		
		ASin, Value1: Retrieves the arcsine (the number whose sine is Value1) in radians. If Value1 is less
			than -1 or greater than 1, Return value will be made null (empty). Corresponding function:
			ASin(Number).
		
		ACos, Value1: Retrieves the arccosine (the number whose cosine is Value1) in radians. If Value1 is
			less than -1 or greater than 1, Return value will be made null (empty). Corresponding function:
			ACos(Number).
		
		ATan, Value1: Retrieves the arctangent (the number whose tangent is Value1) in radians.
			Corresponding function: ATan(Number).
		
		NOTE: Each of the following bitwise operations has a more concise bitwise operator for use in
		expressions.
		
		BitNot, Value1: Stores the bit-inverted version of Value1 in Return value (if Value1 is floating
			point, it is truncated to an integer prior to the calculation). If Value1 is between 0 and
			4294967295 (0xffffffff), it will be treated as an unsigned 32-bit value. Otherwise, it is treated as
			a signed 64-bit value. In the following example, the result is 0xfffff0f0 (4294963440): OutputVar :=
			Mfunc.Transform("BitNot", 0xf0f).
		
		BitAnd, Value1, Value2: Retrieves the result of the bitwise-AND of Value1 and Value2 (floating point
			values are truncated to integers prior to the calculation). In the following example, the result is
			0xff00 (65280): OutputVar := Mfunc.Transform("BitAnd", 0xff0f, 0xfff0).
		
		BitOr, Value1, Value2: Retrieves the result of the bitwise-OR of Value1 and Value2 (floating point
			values are truncated to integers prior to the calculation). In the following example, the result is
			0xf0f0 (61680): OutputVar := Mfunc.Transform("BitOr", 0xf000, 0x00f0).
		
		BitXOr, Value1, Value2: Retrieves the result of the bitwise-EXCLUSIVE-OR of Value1 and Value2
			(floating point values are truncated to integers prior to the calculation). In the following
			example, the result is 0xff00 (65280): OutputVar := Mfunc.Transform("BitXOr", 0xf00f, 0x0f0f).
		
		BitShiftLeft, Value1, Value2: Retrieves the result of shifting Value1 to the left by Value2 bit
			positions, which is equivalent to multiplying Value1 by "2 to the Value2th power" (floating point
			values are truncated to integers prior to the calculation). In the following example, the result is
			8: OutputVar := Mfunc.Transform("BitShiftLeft", 1, 3).
		
		BitShiftRight, Value1, Value2: Retrieves the result of shifting Value1 to the right by Value2 bit
			positions, which is equivalent to dividing Value1 by "2 to the Value2th power", truncating the
			remainder (floating point values are truncated to integers prior to the calculation). In the
			following example, the result is 2:
				OutputVar := Mfunc.Transform("BitShiftRight", 17, 3).
	Remarks:
		Wrapper for AutoHotkey Docs - Transform.
		Static method.
		
		Sub-commands that accept numeric parameters can also use expressions for those parameters.
		
		If either Value1 or Value2 is a floating point number, the following Cmds will retrieve a floating
		point number rather than an integer: Mod, Pow, Round, and Abs. The number of decimal places
		retrieved is determined by Mfunc.SetFormat.
		
		To convert a radians value to degrees, multiply it by 180/pi (approximately 57.29578). To convert a
		degrees value to radians, multiply it by pi/180 (approximately 0.01745329252).
		
		The value of pi (approximately 3.141592653589793) is 4 times the arctangent of 1.
		
		Any and/or all parameter for this function can be instance of MfString or var containing string.
*/
	Transform(Cmd, Value1, Value2 = "") {
		_Cmd := MfString.Getvalue(Cmd), _Value1 := MfString.Getvalue(Value1), _Value2 := MfString.Getvalue(Value2)
		Transform, v, %_Cmd%, %_Value1%, %_Value2%
		Return, v
	}
; 	End:Transform ;}
;{ 	WinActivate						- Static - Method
/*
	Method: WinActivate()
	Mfunc.WinActivate([WinTitle, WinText, ExcludeTitle, ExcludeText])
		Activates the specified window (makes it foremost).
	Parameters:
		WinTitle
			A window title or other criteria identifying the target window. See WinTitle.
			Can be MfString instance or var containing string.
		WinText
			If present, this parameter must be a substring from a single text element of the target window (as
			revealed by the included Window Spy utility). Hidden text elements are detected if DetectHiddenText
			is ON.
			Can be MfString instance or var containing string.
		ExcludeTitle
			Windows whose titles include this value will not be considered.
			Can be MfString instance or var containing string.
		ExcludeText
			Windows whose text include this value will not be considered.
			Can be MfString instance or var containing string.
	Remarks:
		Wrapper for AutoHotkey Docs - WinActivate.
		Static method.
		
		If the window is minimized, it is automatically restored prior to being activated.
		Six attempts will be made to activate the target window over the course of 60ms. Thus, it is usually
		unnecessary to follow WinActivate with WinWaitActive or IfWinNotActive.
		
		If a matching window is already active, that window will be kept active rather than activating any
		other matching window beneath it. In general, if more than one window matches, the topmost (most
		recently used) will be activated. You can activate the bottommost (least recently used) via
		WinActivateBottom.
		
		When a window is activated immediately after the activation of some other window, task bar buttons
		might start flashing on some systems (depending on OS and settings). To prevent this, use
		#WinActivateForce.
		
		Window titles and text are case sensitive. Hidden windows are not detected unless
		DetectHiddenWindows has been turned on.
*/
	WinActivate(WinTitle = "", WinText = "", ExcludeTitle ="",ExcludeText = "") {
		_WinTitle := MfString.Getvalue(WinTitle), _WinText := MfString.Getvalue(WinText)
		_ExcludeTitle := MfString.Getvalue(ExcludeTitle), _ExcludeText := MfString.Getvalue(ExcludeText)
		WinActivate, %_WinTitle%, %_WinText%, %_ExcludeTitle%, %_ExcludeText%
	}
; 	End:WinActivate ;}
;{ 	WinGet							- Static - Method
/*
	Method: WinGet()

	OutputVar := Mfunc.WinGet([Cmd, WinTitle, WinText, ExcludeTitle, ExcludeText])

	Mfunc.WinGet([Cmd, WinTitle, WinText, ExcludeTitle, ExcludeText])
		Retrieves the specified window's unique ID, process ID, process name, or a list of its controls. It
		can also retrieve a list of all windows matching the specified criteria.
	Parameters:
		Cmd
			See list below.
		WinTitle
			A window title or other criteria identifying the target window. See WinTitle.
			
			Can be MfString instance or var containing string.
		WinText
			If present, this parameter must be a substring from a single text element of the target window (as
			revealed by the included Window Spy utility). Hidden text elements are detected if DetectHiddenText
			is ON.
			
			Can be MfString instance or var containing string.
		ExcludeTitle
			Windows whose titles include this value will not be considered.
			
			Can be MfString instance or var containing string.
		ExcludeText
			Windows whose text include this value will not be considered.
			Can be MfString instance or var containing string.
			Cmd is the operation to perform, which if blank defaults to ID. It can be one of the following
			words:
		
		ID: Retrieves the unique ID number (HWND/handle) of a window. If there is no matching window, return
			value is null (empty). The functions WinExist() and WinActive() can also be used to retrieve the ID
			of a window; for example, WinExist("A") is a fast way to get the ID of the active window. To
			discover the HWND of a control (for use with Post/SendMessage or DllCall), use ControlGet Hwnd or
			MouseGetPos.
		
		IDLast: Same as above except it retrieves the ID of the last/bottommost window if there is more than
			one match. If there is only one match, it performs identically to ID. This concept is similar to
			that used by WinActivateBottom.
		
		PID: Retrieves the Process ID (PID) of a window.
		
		ProcessName: Retrieves the name of the process (e.g. notepad.exe) that owns a window. If there are
			no matching windows, Return value is made null (empty).
		
		ProcessPath AutoHotKey [v1.1.01+]: Similar to ProcessName, but retrieves the full path and name of
			the process instead of just the name.
		
		Count: Retrieves the number of existing windows that match the specified WinTitle, WinText,
			ExcludeTitle, and ExcludeText (0 if none). To count all windows on the system, omit all four
			title/text parameters. Hidden windows are included only if DetectHiddenWindows has been turned on.
		
		List: Retrieves the unique ID numbers of all existing windows that match the specified WinTitle,
			WinText, ExcludeTitle, and ExcludeText (to retrieve all windows on the entire system, omit all four
			title/text parameters). Each ID number is stored in a variable whose name begins with OutputVar's
			own name (to form a pseudo-array), while Return value itself is set to the number of retrieved items
			(0 if none). For example, if Return value is var OutputVar is MyArray and two matching windows are
			discovered, MyArray1 will be set to the ID of the first window, MyArray2 will be set to the ID of
			the second window, and MyArray itself will be set to the number 2. Windows are retrieved in order
			from topmost to bottommost (according to how they are stacked on the desktop). Hidden windows are
			included only if DetectHiddenWindows has been turned on. Within a function, to create a pseudo-array
			that is global instead of local, declare MyArray as a global variable prior to using this command
			(the converse is true for assume-global functions).
		
		MinMax: Retrieves the minimized/maximized state for a window. OuputVar is made blank if no matching
			window exists; otherwise, it is set to one of the following numbers:
			-1: The window is minimized (WinRestore can unminimize it).
			1: The window is maximized (WinRestore can unmaximize it).
			0: The window is neither minimized nor maximized.
		
		ControlList: Retrieves the control names for all controls in a window. If no matching window exists
			or there are no controls in the window, OutputVar is made blank. Otherwise, each control name
			consists of its class name followed immediately by its sequence number (ClassNN), as shown by Window Spy.
			
			Each item except the last is terminated by a linefeed (`n). To examine the individual control names
			one by one, use a parsing loop as shown in the examples section below.
			Controls are sorted according to their Z-order, which is usually the same order as TAB key
			navigation if the window supports tabbing.
			
			The control currently under the mouse cursor can be retrieved via MouseGetPos.
		ControlListHwnd AutoHotKey [v1.0.43.06+]: Same as above except it retrieves the window handle (HWND)
			of each control rather than its ClassNN.
		
		Transparent: Retrieves the degree of transparency of a window (see WinSet for how to set
			transparency). Return value is null (empty) if:
			1) the OS is older than Windows XP
			2) there are no matching windows
			3) the window has no transparency level
			4) other conditions (caused by OS behavior)
			such as the window having been minimized, restored, and/or resized since it was made transparent.
			Otherwise, a number between 0 and 255 is stored, where 0 indicates an invisible window and 255
			indicates an opaque window. For example:
				Mfunc.MouseGetPos(,, MouseWin)
				Transparent := Mfunc.WinGet("Transparent", "ahk_id" . MouseWin) ; Transparency of window under the
				mouse cursor.
		TransColor: Retrieves the color that is marked transparent in a window (see WinSet for how to set
			the TransColor). Return value is null (empty) if:
			1) the OS is older than Windows XP
			2) there are no matching windows
			3) the window has no transparent color
			4) other conditions (caused by OS behavior)
			such as the window having been minimized, restored, and/or resized since it was made transparent.
			Otherwise, a six-digit hexadecimal RGB color is stored, e.g. 0x00CC99. For example:
				Mfunc.MouseGetPos(,, MouseWin)
				TransColor := Mfunc.WinGet("Transparent", "ahk_id" . MouseWin) ; TransColor of the window under the
				mouse cursor.
		
		Style or ExStyle: Retrieves an 8-digit hexadecimal number representing style or extended style
			(respectively) of a window. If there are no matching windows, OutputVar is made blank. The following
			example determines whether a window has the WS_DISABLED style:
				Style := Mfunc.WinGet("Style", "My Window Title")
				if (Style & 0x8000000) ; 0x8000000 is WS_DISABLED.
				;... the window is disabled, so perform appropriate action.
			The next example determines whether a window has the WS_EX_TOPMOST style (always-on-top):
				ExStyle :=  Mfunc.WinGet("ExStyle", "My Window Title")
				if (ExStyle & 0x8) ; 0x8 is WS_EX_TOPMOST.
				;... the window is always-on-top, so perform appropriate action.
			See the styles table for a partial listing of styles.
	Returns:
		Returns the result of Cmd.
	Remarks:
		Wrapper for AutoHotkey - WinGet.
		Static method.
		
		A window's ID number is valid only during its lifetime. In other words, if an application restarts,
		all of its windows will get new ID numbers.
		
		ID numbers retrieved by this command are numeric (the prefix "ahk_id" is not included) and are
		stored in hexadecimal format regardless of the setting of Mfunc.SetFormat.
		
		The ID of the window under the mouse cursor can be retrieved with Mfunc.MouseGetPos.
		Although ID numbers are currently 32-bit unsigned integers, they may become 64-bit in future
		versions. Therefore, it is unsafe to perform numerical operations such as addition on these values
		because such operations require that their input strings be parsable as signed rather than unsigned
		integers.
		
		Window titles and text are case sensitive. Hidden windows are not detected unless
		DetectHiddenWindows has been turned on.
		
		Any and/or all parameter for this function can be instance of MfString or var containing string.
*/
	WinGet(Cmd = "", WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "") {
		_Cmd := MfString.Getvalue(Cmd), _WinTitle := MfString.Getvalue(WinTitle), _WinText := MfString.Getvalue(WinText)
		_ExcludeTitle := MfString.Getvalue(ExcludeTitle), _ExcludeText := MfString.Getvalue(ExcludeText)
		WinGet, v, %_Cmd%, %_WinTitle%, %_WinText%, %_ExcludeTitle%, %_ExcludeText%
		Return, v
	}
; 	End:WinGet ;}
;{ 	WinGetActiveTitle				- Static - Method
/*
	Method: WinGetActiveTitle()

	OutputVar := Mfunc.WinGetActiveTitle()

	Mfunc.WinGetActiveTitle()
		Retrieves the title of the active window.
	Returns:
		Returns the title of the active window.
	Remarks:
		This command is equivalent to: OutputVar := Mfunc.WinGetTitle("A").
*/
	WinGetActiveTitle() {
		WinGetActiveTitle, v
		Return, v
	}
; 	End:WinGetActiveTitle ;}
;{ 	WinGetClass						- Static - Method
/*
	WinGetClass()
		OutputVar := Mfunc.WinGetClass([WinTitle, WinText, ExcludeTitle, ExcludeText])
	Mfunc.WinGetClass([WinTitle, WinText, ExcludeTitle, ExcludeText])
	
	Retrieves the specified window's class name.
	Parameters
		WinTitle
			A window title or other criteria identifying the target window. See WinTitle.
			Can be MfString instance or var containing string.
		WinText
			If present, this parameter must be a substring from a single text element of the target
			window (as revealed by the included Window Spy utility). Hidden text elements are detected
			if DetectHiddenText is ON.
			Can be MfString instance or var containing string.
		ExcludeTitle
			Windows whose titles include this value will not be considered.
			Can be MfString instance or var containing string.
		ExcludeText
			Windows whose text include this value will not be considered.
			Can be MfString instance or var containing string.
	Returns
		Returns the retrieved class name.
	Remarks
		Wrapper for AutoHotkey Docs - WinGetClass.
		Static method.
		Only the class name is retrieved (the prefix "ahk_class" is not included in return value).
		Window titles and text are case sensitive. Hidden windows are not detected unless
		DetectHiddenWindows has been turned on.

*/
	WinGetClass(WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "") {
		_WinTitle := MfString.Getvalue(WinTitle), _WinText := MfString.Getvalue(WinText)
		_ExcludeTitle := MfString.Getvalue(ExcludeTitle), _ExcludeText := MfString.Getvalue(ExcludeText)
		WinGetClass, v, %_WinTitle%, %_WinText%, %_ExcludeTitle%, %_ExcludeText%
		Return, v
	}
; 	End:WinGetClass ;}
;{ 	WinGetText						- Static - Method
/*
	Method: WinGetText()

	OutputVar := Mfunc.WinGetText([WinTitle, WinText, ExcludeTitle, ExcludeText])

	Mfunc.WinGetText([WinTitle, WinText, ExcludeTitle, ExcludeText])
		Retrieves the text from the specified window.
	Parameters:
		WinTitle
			A window title or other criteria identifying the target window. See WinTitle.
			Can be MfString instance or var containing string.
		WinText
			If present, this parameter must be a substring from a single text element of the target window (as
			revealed by the included Window Spy utility). Hidden text elements are detected if DetectHiddenText
			is ON.
			Can be MfString instance or var containing string.
		ExcludeTitle
			Windows whose titles include this value will not be considered.
			Can be MfString instance or var containing string.
		ExcludeText
			Windows whose text include this value will not be considered.
			Can be MfString instance or var containing string.
	Returns:
		Returns the retrieved text.
	Throws:
		Throws MfException throw any errors with InnerException set to the Autohotkey - WinGetText error
		message.
		Throws MfException any other general error occurs.
	Remarks:
		Wrapper for AutoHotkey - WinGetText.
		Static method.
		
		The text retrieved is generally the same as what Window Spy shows for that window. However, if
		DetectHiddenText has been turned off, hidden text is omitted from OutputVar.
		
		Each text element ends with a carriage return and linefeed (CR+LF), which can be represented in the
		script as `r`n. To extract individual lines or substrings, use commands such as Mfunc.StringGetPos
		and Mfunc.StringMid. A parsing loop can also be used to examine each line or word one by one.
		
		If the retrieved text appears to be truncated (incomplete), try using VarSetCapacity(OutputVar, 55)
		prior to WinGetText [replace 55 with a size that is considerably longer than the truncated text].
		This is necessary because some applications do not respond properly to the WM_GETTEXTLENGTH message,
		which causes AutoHotkey to make the output variable too small to fit all the text.
		
		The amount of text retrieved is limited to a variable's maximum capacity (which can be changed via
		the #MaxMem directive). As a result, this command might use a large amount of RAM if the target
		window (e.g. an editor with a large document open) contains a large quantity of text. To avoid this,
		it might be possible to retrieve only portions of the window's text by using ControlGetText instead.
		In any case, a variable's memory can be freed later by assigning it to nothing, i.e. OutputVar =.
		To retrieve a list of all controls in a window, follow this example: WinGet, OutputVar, ControlList,
		WinTitle
		
		Window titles and text are case sensitive. Hidden windows are not detected unless
		DetectHiddenWindows has been turned on
*/
	WinGetText(WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "") {
		try {
			_WinTitle := MfString.Getvalue(WinTitle), _WinText := MfString.Getvalue(WinText)
			_ExcludeTitle := MfString.Getvalue(ExcludeTitle), _ExcludeText := MfString.Getvalue(ExcludeText)
			WinGetText, v, %_WinTitle%, %_WinText%, %_ExcludeTitle%, %_ExcludeText%
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (ErrorLevel) {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Return, v
	}
; 	End:WinGetText ;}
;{ 	WinGetTitle						- Static - Method
/*
	Method: WinGetTitle()

	OutputVar := Mfunc.WinGetTitle([WinTitle, WinText, ExcludeTitle, ExcludeText])

	Mfunc.WinGetTitle([WinTitle, WinText, ExcludeTitle, ExcludeText])
		Retrieves the title of the specified window.
	Parameters:
		WinTitle
			A window title or other criteria identifying the target window. See WinTitle.
			Can be MfString instance or var containing string.
		WinText
			If present, this parameter must be a substring from a single text element of the targe
			 window (as revealed by the included Window Spy utility). Hidden text elements are detected
			 if DetectHiddenText is ON.
			Can be MfString instance or var containing string.
		ExcludeTitle
			Windows whose titles include this value will not be considered.
			Can be MfString instance or var containing string.
		ExcludeText
			Windows whose text include this value will not be considered.
			Can be MfString instance or var containing string.
	Returns:
		Returns the retrieved title.
	Remarks:
		Wrapper for AutoHotkey Docs - WinGetTitle.
		Static method.
		To discover the name of the window that the mouse is currently hovering over, use Mfunc.MouseGetPos.
		Window titles and text are case sensitive. Hidden windows are not detected unless DetectHiddenWindows
		has been turned on.
*/
	WinGetTitle(WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "") {
		_WinTitle := MfString.Getvalue(WinTitle), _WinText := MfString.Getvalue(WinText)
		_ExcludeTitle := MfString.Getvalue(ExcludeTitle), _ExcludeText := MfString.Getvalue(ExcludeText)
		WinGetTitle, v, %_WinTitle%, %_WinText%, %_ExcludeTitle%, %_ExcludeText%
		Return, v
	}
; 	End:WinGetTitle ;}
;{ 	_SetObjValue
	; internal method
	_SetObjValue(byref obj, value) {
			if (IsObject(obj)) {
				if (MfObject.IsObjInstance(obj, "MfPrimitive")) {
					obj.Value := value
				}
				else obj := value
			} else {
				obj := value
			}
		}
; 	End:_SetObjValue ;}
;{ 	_GetStringFromVarOrObj
	; Gets a var string from var or MfObject
	; internal method.
	; returns empty string of objects that are not derived from MfObject
	_GetStringFromVarOrObj(InputVar)
	{
		if(MfNull.IsNull(InputVar))
		{
			return ""
		}
		if (MfObject.IsObjInstance(InputVar, MfObject))
		{
			if (MfObject.IsObjInstance(InputVar, MfString))
			{
				Return InputVar.Value
			}
			else
			{
				str := InputVar.ToString()
				return str
			}
		}
		if(IsObject(InputVar))
		{
			return ""
		}
		return InputVar . ""

	}
; 	End:_GetStringFromVarOrObj ;}
;{ 	Number Validation
;{ 		IsNumeric(num)
/*
	Method: IsNumeric()

	OutputVar := Mfunc.IsNumeric(num)

	Mfunc.IsNumeric(num)
		Checks to see if a param num is numeric.
	Parameters:
		num
			A var to check to see if it contains a number
	Returns:
		Returns true if num is numeric; Otherwise false.
	Remarks:
		String Values containing numbers such as "100" and "0x100A" will return true However "100a" will return false.
		Static method.
*/
	IsNumeric(num) {
		If num is number 
		  Return true
		Return false
	}
; 	End:IsNumeric(x) ;}	
;{		IsInteger(num)
/*
	Method: IsInteger()

	OutputVar := Mfunc.IsInteger(num)

	Mfunc.IsInteger(num)
		Checks to see if a param num is Integer.
	Parameters:
		num
			A var to check to see if it contains an integer
	Returns:
		Returns true if num is non-empty and contains a purely numeric string (decimal or hexadecimal)
		without a decimal point. Leading and trailing spaces and tabs are allowed. The string may start
		with a plus or minus sign; Otherwise false is returned
	Remarks:
		Static method.
		String Values containing numbers such as "100" and "0" will return true However "100.2" will return false
*/
	IsInteger(num) {
		if num is Integer
			return true
		return false
	}
;	End:IsInteger(x) ;}	
;{		IsFloat(num)
/*
	Method: IsFloat()

	OutputVar := Mfunc.IsFloat(num)

	Mfunc.IsFloat(num)
		Checks to see if a param num is Float.
	Parameters:
		num
			A var to check to see if it contains a float
	Returns:
		Returns true if num is non-empty and contains a floating point number; that is, a purely numeric string
		containing a decimal point. Leading and trailing spaces and tabs are allowed. The string may start with
		a plus sign, minus sign, or decimal point; Otherwise false is returned.
	Remarks:
		Static method
		String Values containing numbers such as "100.0" and "0.0" will return true However "100" will return false.
*/
	IsFloat(num) {
		if num is Float
			return true
		return false
	}
;	End:IsFloat(num) ;}
; End:Number Validation ;}
;{ 	SecondsPassed()
/*
	Method: SecondsPassed()

	OutputVar := Mfunc.SecondsPassed(StartTicks)
	OutputVar := Mfunc.SecondsPassed(StartTicks, EndTicks)

	Mfunc.SecondsPassed(StartTicks)
		Gets the number of seconds from StartTicks until Now

	Mfunc.SecondsPassed(StartTicks, EndTicks)
		Gets the number of seconds between StartTicks and EndTicks
	Parameters:
		StartTicks
			The number of Ticks to start the calculation from.
		EndTicks
			The Number of Ticks to End the calculation.
	Remarks:
		SecondsPassed can be useful when debugging.
*/
	SecondsPassed(StartTicks, EndTicks := "") {
		if ((!StartTicks) || (!Mfunc.IsNumeric(StartTicks))) {
			return 0
		}
		tcount := A_TickCount
		if(Mfunc.IsNumeric(EndTicks)) {
			tcount := EndTicks
		}
		ElapsedTime := ((tcount - StartTime) / 1000)
		return ElapsedTime
	}
; End:SecondsPassed() ;}	
}
/*!
	End of class
*/