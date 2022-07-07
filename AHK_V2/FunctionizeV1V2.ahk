AhkVer(Len:=1) {
	return SubStr(A_AhkVersion,1,Len)
}

ClipWait(Timeout:="_", WaitForAnyData:=0) { ; AHK v1 v2
	param1 := "Timeout", param2 := "WaitForAnyData"
	If (Timeout = "_")
		ClipWait
	Else
		ClipWait %param1%, %param2%
}