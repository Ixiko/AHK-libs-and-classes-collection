; A simple function to compare OS version in a flexible and easy way
; © Drugwash, June 2015-Nov2016 v1.1

; EXAMPLE (uncomment to run)
/*
r := OSTest("ME", "L") ? "true" : "false"
msgbox, OS version comparison is %r%
return
*/
;================================================================
OSTest(nm, cin="E")
;================================================================
{
Static t="NT4,95,98,ME,2000,XP,2003,VISTA,7,8,8.1,10"
StringLeft, cond, cin, 2
StringUpper, name, nm
if name not in %t%
	{
	MsgBox, 0x2010, %A_ThisFunc%() error,
		(LTrim
		Bad version name: %nm%
		Allowed are:
		%t%
		)
	return
	}
Loop, Parse, t, CSV
	{
	if (name=A_LoopField)
		m := A_Index
	if (A_OSVersion="WIN_" A_LoopField)
		c := A_Index
	}
if (!c && A_OSVersion >= 6.4)
	c := 12
if cond in E,Eq,=					; Equal
	return (m=c ? 1 : 0)
else if cond in EL,LE,<=				; Equal or Lower
	return (c<=m ? 1 : 0)
else if cond in L,Lo,<				; Lower
	return (c<m ? 1 : 0)
else if cond in EH,HE,>=				; Equal or Higher
	return (c>=m ? 1 : 0)
else if cond in H,Hi,>				; Higher
	return (c>m ? 1 : 0)
else MsgBox, 0x2010, %A_ThisFunc%() error,
	(LTrim
	Bad condition string: %cin%
	Allowed are:
	=	or E(qual`)
	<	or L(ower`)
	>	or H(igher`)
	<=	or EL/LE (equal or lower`)
	>=	or EH/HE (equal or higher`)
	)
return
}
;================================================================
