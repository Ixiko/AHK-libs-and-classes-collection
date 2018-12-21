; due to:
; https://autohotkey.com/boards/viewtopic.php?p=183090#p183090
; v2
g(byref str, del := "`n", omit := "`r", split := false){
	local 
	lens := []
	loop parse, str, del, omit
		lens[l := strlen(A_LoopField)] := "", __slen%l% .= A_LoopField . del
	varsetcapacity(str,varsetcapacity(str)+2)
	for l in lens
		str .= __slen%l%
	str := rtrim(str, del)
}