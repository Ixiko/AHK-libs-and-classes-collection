/*
	Provides access to Windows’ built-in file operation system 
	(move / copy / rename / delete files or folders with the standard Windows dialog and error UI).  
	Utilizes the SHFileOperation shell function in Windows.

	For online documentation
	See http://www.autohotkey.net/~Rapte_Of_Suzaku/Documentation/files/ShellFileOperation-ahk.html
	
	Release #3
	
	Joshua A. Kinnison
	2010-09-29, 15:12
*/
ShellFileOperation( fileO=0x0, fSource="", fTarget="", flags=0x0, ghwnd=0x0 )     
{ ;dout_f(A_THisFunc)
	
	; AVAILABLE OPERATIONS
	static FO_MOVE                   = 0x1
	static FO_COPY                   = 0x2
	static FO_DELETE                 = 0x3
	static FO_RENAME                 = 0x4
	
	; AVAILABLE FLAGS
	static FOF_MULTIDESTFILES        = 0x1     ; Indicates that the to member specifies multiple destination files (one for each source file) rather than one directory where all source files are to be deposited.
	static FOF_CONFIRMMOUSE          = 0x2     ; ?
	static FOF_SILENT                = 0x4     ; Does not display a progress dialog box.
	static FOF_RENAMEONCOLLISION     = 0x8     ; Gives the file being operated on a new name (such as "Copy #1 of...") in a move, copy, or rename operation if a file of the target name already exists.
	static FOF_NOCONFIRMATION        = 0x10    ; Responds with "yes to all" for any dialog box that is displayed.
	static FOF_WANTMAPPINGHANDLE     = 0x20    ; returns info about the actual result of the operation
	static FOF_ALLOWUNDO             = 0x40    ; Preserves undo information, if possible. With del, uses recycle bin.
	static FOF_FILESONLY             = 0x80    ; Performs the operation only on files if a wildcard filename (*.*) is specified.
	static FOF_SIMPLEPROGRESS        = 0x100   ; Displays a progress dialog box, but does not show the filenames.
	static FOF_NOCONFIRMMKDIR        = 0x200   ; Does not confirm the creation of a new directory if the operation requires one to be created.
	static FOF_NOERRORUI             = 0x400   ; don't put up error UI
	static FOF_NOCOPYSECURITYATTRIBS = 0x800   ; dont copy file security attributes
	static FOF_NORECURSION           = 0x1000  ; Only operate in the specified directory. Don't operate recursively into subdirectories.
	static FOF_NO_CONNECTED_ELEMENTS = 0x2000  ; Do not move connected files as a group (e.g. html file together with images). Only move the specified files.
	static FOF_WANTNUKEWARNING       = 0x4000  ; Send a warning if a file is being destroyed during a delete operation rather than recycled. This flag partially overrides FOF_NOCONFIRMATION.
	static FOF_NORECURSEREPARSE      = 0x8000  ; treat reparse points as objects, not containers ?
	
	; static items for builds without objects
	static _mappings                 = "mappings"
	static _error                    = "error"
	static _aborted                  = "aborted"
	static _num_mappings             = "num_mappings"
	static make_object               = "Object"
	
	fileO := %fileO% ? %fileO% : fileO
	
	If ( SubStr(flags,0) == "|" )
		flags := SubStr(flags,1,-1)
	
	_flags := 0
	Loop Parse, flags, |
		_flags |= %A_LoopField%	
	flags := _flags ? _flags : (%flags% ? %flags% : flags)
	
	If ( SubStr(fSource,0) != "|" )
		fSource := fSource . "|"

	If ( SubStr(fTarget,0) != "|" )
		fTarget := fTarget . "|"
	
	char_size := A_IsUnicode ? 2 : 1
	char_type := A_IsUnicode ? "UShort" : "Char"
	
	fsPtr := &fSource
	Loop % StrLen(fSource)
		if NumGet(fSource, (A_Index-1)*char_size, char_type) = 124
			NumPut(0, fSource, (A_Index-1)*char_size, char_type)

	ftPtr := &fTarget
	Loop % StrLen(fTarget)
		if NumGet(fTarget, (A_Index-1)*char_size, char_type) = 124
			NumPut(0, fTarget, (A_Index-1)*char_size, char_type)
	
	VarSetCapacity( SHFILEOPSTRUCT, 60, 0 )                 ; Encoding SHFILEOPSTRUCT
	NextOffset := NumPut( ghwnd, &SHFILEOPSTRUCT )          ; hWnd of calling GUI
	NextOffset := NumPut( fileO, NextOffset+0    )          ; File operation
	NextOffset := NumPut( fsPtr, NextOffset+0    )          ; Source file / pattern
	NextOffset := NumPut( ftPtr, NextOffset+0    )          ; Target file / folder
	NextOffset := NumPut( flags, NextOffset+0, 0, "Short" ) ; options

	code    := DllCall( "Shell32\SHFileOperation" . (A_IsUnicode ? "W" : "A"), UInt,&SHFILEOPSTRUCT )
	aborted := NumGet(NextOffset+0)
	H2M_ptr := NumGet(NextOffset+4)
	
	if !IsFunc(make_object)
		ret := aborted	; if build doesn't support object, just return the aborted flag
	else
	{	
		ret             := %make_object%()
		ret[_mappings]  := %make_object%()
		ret[_error]     := ErrorLevel := code
		ret[_aborted]   := aborted

		if (FOF_WANTMAPPINGHANDLE & flags)
		{
			; HANDLETOMAPPINGS 
			ret[_num_mappings]  := NumGet( H2M_ptr+0 )
			map_ptr             := NumGet( H2M_ptr+4 )
			
			Loop % ret[_num_mappings]
			{
				; _SHNAMEMAPPING
				addr := map_ptr+(A_Index-1)*16 ;
				old  := StrGet(NumGet(addr+0))
				new  := StrGet(NumGet(addr+4))
				
				ret[_mappings][old] := new
			}
		}
	}
	
	; free mappings handle if it was requested
	if (FOF_WANTMAPPINGHANDLE & flags)
		DllCall("Shell32\SHFreeNameMappings", int, H2M_ptr)
	
	Return ret
}