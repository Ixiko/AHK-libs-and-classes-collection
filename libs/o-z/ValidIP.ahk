ValidIP(ByRef IPAddress)
{
	if (StrLen(IPAddress) > 15)
		Valid=0

	IfInString, IPAddress, %A_Space%
		Valid=0

	StringSplit, Octets, IPAddress, .
	if (Octets0 <> 4)
		Valid=0
	else if (Octets1 < 1 || Octets1 > 255)
		Valid=0
	else if (Octets2 < 0 || Octets2 > 255)
		Valid=0
	else if (Octets3 < 0 || Octets3 > 255)
		Valid=0
	else if (Octets4 < 0 || Octets4 > 255)
		Valid=0
	else Valid=1

	Oct1:=Octets1*0
	Oct2:=Octets2*0
	Oct3:=Octets3*0
	Oct4:=Octets4*0

	if (Oct1 <> 0 || Oct2 <> 0 || Oct3 <> 0 || Oct4 <> 0)
		Valid=0

	return %Valid%
}

ValidIP(IPAddress)
{
	fp := RegExMatch(IPAddress, "^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$", octet)
	If (fp = 0)
		Return 0	; Not matching: something is wrong
	Loop 4
	{
		If (octet%A_Index% > 255)
			Return 0
	}

	return 1
}

ValidIP(a) {
	Loop, Parse, a, .
		e += 1 + (A_LoopField < 0 or A_LoopField > 255 or (0 . A_LoopField . 0) + 0 = "")
	Return, e = 4
}