class CDirectory
{

;
; Function: Exists
; Description:
;		Determines if a directory exists and is a directory.
; Syntax: CDirectory.Exists(DirName)
; Parameters:
;		DirName - Name of the directory, which is assumed to be in %A_WorkingDir% if an absolute path isn't specified.
; Return Value:
;   Returns true if the specified directory exists or false otherwise.
;

  Exists(DirName)
  {
    result := FileExist(DirName)
  	return result <> "" && InStr(result, "D") > 0
  }

;
; Function: Create
; Description:
;		Creates a directory and its parent directories if necessary.
; Syntax: CDirectory.Create(DirName)
; Parameters:
;		DirName - Name of the directory to create, which is assumed to be in %A_WorkingDir% if an absolute path isn't specified.
; Return Value:
; 		Returns DirName on success or false on failure.
; Remarks:
;		ErrorLevel is set to 1 if there was a problem or 0 otherwise.
;       A_LastError is set to the result of the operating system's GetLastError() function.
;

  Create(DirName)
  {
    FileCreateDir, %DirName%
  	if ErrorLevel
  		return false
    else
      return DirName
  }
}
