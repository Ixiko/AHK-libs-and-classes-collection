/*
Func: newestFile
    Retrieve latest modified file path in a folder

Parameters:
    folder		- Path to folder

Returns:
	Path to latest modified file
	
Examples:
    > msgbox % newestFile(A_Temp)
    =	Latest modified file
	
Required libs:
	-
*/
newestFile(folder) {
	If !( InStr( FileExist(folder), "D") )
		return ""
	
	folder := RTrim(folder, "\")
	
	; build var containing modify dates of files
	loop, % folder "\*.*", 0, 0
		If (time = "")
			time := A_LoopFileTimeModified
		else
			time := time "`n" A_LoopFileTimeModified

	Sort, time, N ; sort var lowest number first

	; count files in var
	loop, parse, time, `n
		timeIndex := A_Index
	
	; save last (newest) file
	loop, parse, time, `n
		If (A_Index = timeIndex)
			newestDate := A_LoopField

	; return newest file
	loop, % folder "\*.*", 0, 0
		If (A_LoopFileTimeModified = newestDate)
			return A_LoopFileFullPath
}