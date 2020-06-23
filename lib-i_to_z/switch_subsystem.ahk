; Link:   	https://gist.github.com/tmplinshi/d1e0f72d8cc3ee27d34a
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

/*
	Modified from http://www.autohotkey.com/board/topic/21189-compile-ahk-ii-for-those-who-compile/?p=316030
	Args:
		filename  - bin/exe file to switch
		subsystem - "C" (console) or "G" (gui). if omitted, switches between the two.
*/
switch_subsystem(filename, subsystem := "") {
	static IMAGE_DOS_SIGNATURE := 0x5A4D
	     , IMAGE_NT_SIGNATURE := 0x4550
	     , IMAGE_SIZEOF_FILE_HEADER := 20
	     , IMAGE_SUBSYSTEM_WINDOWS_GUI := 2
	     , IMAGE_SUBSYSTEM_WINDOWS_CUI := 3

	; Open file for read/write.
	If !f := FileOpen(filename, "rw")
		Return "CreateFile failed"

	; Verify EXE signature.
	e_magic := f.ReadUShort()
	If (e_magic != IMAGE_DOS_SIGNATURE)
		Return "Bad exe file: no DOS sig", f.Close()

	; Get offset of IMAGE_NT_HEADERS.
	f.Pos := 60
	e_lfanew := f.ReadInt()

	; Verify NT signature.
	f.Pos := e_lfanew
	ntSignature := f.ReadUInt()
	If (ntSignature != IMAGE_NT_SIGNATURE)
		Return "Bad exe file: no NT sig", f.Close()

	; Calculate offset of IMAGE_OPTIONAL_HEADER and its Subsystem field.
	offset_optional_header := e_lfanew + 4 + IMAGE_SIZEOF_FILE_HEADER
	offset_Subsystem := offset_optional_header + 68

	; Read current subsystem.
	f.Pos := offset_Subsystem
	Cur_Subsystem := f.ReadUShort()

	; Write new subsystem.
	Subsystem := (Subsystem = "C")                             ? IMAGE_SUBSYSTEM_WINDOWS_CUI
	           : (Subsystem = "G")                             ? IMAGE_SUBSYSTEM_WINDOWS_GUI
	           : (Cur_Subsystem = IMAGE_SUBSYSTEM_WINDOWS_CUI) ? IMAGE_SUBSYSTEM_WINDOWS_GUI
	           : IMAGE_SUBSYSTEM_WINDOWS_CUI
	f.Pos := offset_Subsystem
	f.WriteUShort(Subsystem)

	f.Close()
}