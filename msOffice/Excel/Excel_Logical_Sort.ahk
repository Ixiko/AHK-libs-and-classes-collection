; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=105107

; sort using logical / natural sorting algorithm

/* Example
xl := ComObjActive("excel.application")
for c in obj := xl.activesheet.usedrange.columns(1).cells 	{
	cols := strsplit(c.value,[",",";"]," ")
	loop % cols.maxindex()
		c.offset(0,a_index).value := SortObj(cols)[a_index]
}
*/

SortObj(Arr)	{
	nArr := []
	for x,y in Arr
		lst .= (x=1?"":"`n") . y
	Sort, lst, F logical_cmp
	for k,l in strsplit(lst, "`n")
		nArr.push(l)
	return nArr
}

logical_cmp(a,b,o) {
	return dllcall("Shlwapi.dll\StrCmpLogicalW", "wstr", a, "wstr", b, "int")
	}  ; https://docs.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-strcmplogicalw