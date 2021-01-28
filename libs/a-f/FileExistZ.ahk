; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=75519
; Author:	SKAN
; Date:   	05-05-2020
; for:     	AHK_L

/* Description

	Returns file attributes as Hex when successful or false (0x000000) when parameter conditions are not met.

	FileExist() works like a combo of FileExist() function and FileSetAttrib command.
	Unlike FileExist() which returns file attributes as a string, this function returns the flags in Hexadecimal format.
	A basic call would look like nAttr := FileExistZ("C:\SomeFile.txt") where nAttr would contain one or combination of following 19 flags:

	READONLY                          	:=      0x1     	;       1
	HIDDEN                               	:=      0x2     	;       2
	SYSTEM                               	:=      0x4     	;       4
	DIRECTORY                          	:=     0x10    	;      16
	ARCHIVE                              	:=     0x20    	;      32
	DEVICE                                	:=     0x40    	;      64
	NORMAL                             	:=     0x80    	;     128
	TEMPORARY                        	:=    0x100   	;     256
	SPARSE_FILE                        	:=    0x200   	;     512
	REPARSE_POINT                  	:=    0x400   	;    1024
	COMPRESSED                      	:=    0x800   	;    2048
	OFFLINE                               	:=   0x1000  	;    4096
	NOT_CONTENT_INDEXED    	:=   0x2000  	;    8192
	ENCRYPTED                         	:=   0x4000  	;   16384
	INTEGRITY_STREAM            	:=   0x8000  	;   32768
	VIRTUAL                              	:=  0x10000 	;   65536
	NO_SCRUB_DATA                	:=  0x20000 	;  131072
	RECALL_ON_OPEN              	:=  0x40000 	;  262144
	RECALL_ON_DATA_ACCESS	:= 0x400000	; 4194304


*/

/* Examples

	; To check the existence of a file or folder
	If FileExistZ("D:\")
		MsgBox, The drive exists.

	; Use second parameter to check if the file has a particular attribute:
	If FileExistZ("C:\My File.txt", 0x2 ) ; HIDDEN := 0x2
		MsgBox The file is hidden.

	; Similarily, to check if a path is an existing folder:
	If FileExistZ("C:\My Folder", 0x10) ; DIRECTORY := 0x10
		MsgBox Folder exists.

	; Ofcourse, you may do a combined check:
	If FileExistZ("C:\My Folder", 0x12)    ; DIRECTORY + HIDDEN := 0x12
		MsgBox Folder exists, but is hidden

	; The following example was picked from @jeeswg 's IsRedirected("C:\Documents and Settings\")
	MsgBox % FileExistZ("C:\Documents and Settings\", 0x400)

	; Changing the attributes of a File (or folder)
	;
	;  The variadic parameters of FileExistZ() are meant for changing the attributes of a file (or folder).
	; Note: Attributes will be set only if Check parameter is omitted or 0
	; FileExistZ() can Add, Remove, Toggle a file attribute or completely replace existing attributes (when possible).
	;
	; To add an attribute, prefix the attribute with +=, for eg.: to hide a file: FileExistZ("D:\SomeFile.exe",,"+=0x2"). In same logic, -=
	; will remove an attribute and ^= will toggle the attribute to its opposite state. To replace attributes, prefix attribute with assignment operator :=.
	; For eg. FileExistZ("D:\SomeFile.exe",,":=0x2") would try to replace all existing attributes with 0x2 (hidden). Assignment is useful
	; for resetting file attributes to Normal.. like in :=0x80

	; FileSetAttrib command can operate on multiple files (its file parameter accepts wildcard), but with FileExistZ() you should call it from File Loop.
	; Here follows few examples for FileSetAttrib.

	FileSetAttrib, -R+A, C:\New Text File.txt
	FileSetAttrib, +RH,  C:\New Text File.txt
	FileSetAttrib, ^H,   C:\MyFiles

	; .. and equivalent FileExist() calls:

	newAttr := FileExistZ("C:\New Text File.txt",,"-=0x1","+=0x20")
	newAttr := FileExistZ("C:\New Text File.txt",,"+=0x3")
	newAttr := FileExistZ("C:\MyFiles",,"^=0x2")

*/

FileExistZ(File, C:=0, P*) {  ; FileExistZ v0.91, By SKAN on D353/D355 @ tiny.cc/fileexistz
Local K,V,N,A, M := A := DllCall("GetFileAttributes", "Str",File, "Int")

  If (P.Count() and A != -1 and not C)
      For K,V in P
          N := StrSplit(V,"="," ",2), K := N[1], V := Round(N[2])
        , M := K="+" ? M|V : K="-" ? M&~V : K="^" ? M^V : K=":" ? V : M|V

  If (A != -1  and A != M)
    A := DllCall("SetFileAttributes", "Str",File, "Int",M)
      ?  DllCall("GetFileAttributes", "Str",File, "Int")
      :  -1

  If (A != -1 and C)
    A := A & C = C ? A : -1

Return Format("0x{1:06X}", A=0 ? 8 : A=-1 ? 0 : A)
}