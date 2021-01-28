; Link:   	https://gist.github.com/tmplinshi/ae2fae633489cfef28d3a86a4bfd3940
; Author:	tmplinshi
; Date:
; for:     	AHK_L


GetBitrate(FileName) {
	if !InStr(FileName, ":") {
		FileName := A_WorkingDir "\" FileName
	}
	RegExMatch(FileName, "^(.*\\)(.*)$", m)

	oShell := ComObjCreate("Shell.Application")
	oFolder := oShell.Namespace(m1)
	return oFolder.GetDetailsOf( oFolder.Parsename(m2), 28 )
}