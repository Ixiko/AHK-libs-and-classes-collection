; http://www.autohotkey.com/board/topic/15951-base-10-to-base-36-conversion/#entry103624
ToBase(n,b) { ; n >= 0, 1 < b <= 36
	Loop {
		d := Mod(n,b), n //= b
		m := (d < 10 ? d : Chr(d+55)) . m
		IfLess, n, 1, Break
	}
	Return m
}

/* ; testing
MsgBox, % ToBase(73,36)

MsgBox, % ToBase(36*36+35,36)

MsgBox, % ToBase(9,8)

MsgBox, % ToBase(66,8)

MsgBox, % ToBase(100,16)

MsgBox, % ToBase(255,16)
*/