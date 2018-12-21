; This is just for convenience because the function library is included when any its function is called.
#include <Encoding>

class CFile
{
;
; Function: Create
; Description:
;		Creates a file with the specified path and encoding.
; Syntax: CFile.Create(fileName [, encoding])
; Parameters:
;		fileName - The path of the file to open, which is assumed to be in A_WorkingDir if an absolute path isn't specified.
;		encoding - (Optional) The code page to use for text I/O if the file does not contain a UTF-8 or UTF-16 byte order mark. If omitted, the current value of A_FileEncoding is used.
; Return Value:
; 		Returns a file object on success (see FileOpen in AutoHotkey documentation) or false on failure.
; Remarks:
;		On success, the file remains open for writing (the "w" flag is used to create the file).
;       The directory tree is created too if necessary.
;       Uses Encoding_IsValid, CDirectory.Exists, CDirectory.Create.
;
  Create(fileName, encoding="")
  {
    global CDirectory
    
  	if(!Encoding_IsValid(encoding))
  		encoding := A_FileEncoding
  	
  	SplitPath, fileName, fname, dir, ext, nnoext, drv
  	if(!CDirectory.Exists(dir))
  	{
  		CDirectory.Create(dir)
  		if ErrorLevel
      {
  			return false
      }
  	}
  	file := FileOpen(fileName, "w", encoding)
  	return file
  }
}
