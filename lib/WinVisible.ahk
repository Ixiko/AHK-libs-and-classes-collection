WinVisible(Title) {
	DetectHiddenWindows Off ; Force to not detect hidden windows
	Return WinExist(Title) ; Return 0 for hidden windows or the ahk_id
	DetectHiddenWindows On ; Return to "normal" state
}