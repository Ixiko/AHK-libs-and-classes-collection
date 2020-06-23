; Link:   	https://gist.github.com/tmplinshi/573accc5844c76f18810ae6fbdcca0dd
; Author:	tmplinshi
; Date:
; for:     	AHK_L


/*
	ParseCmdline - parse command line to object
	Example:
		cmdline = "a test.ahk" -from gbk /to utf-8 /a /b --delete-top 2 --delete-end=5 "in file.txt" out.txt
		o := ParseCmdline(cmdline)
		MsgBox, % obj_print(o)
		Return:
			{
				"$" : [
					"a test.ahk",
					"in file.txt",
					"out.txt"
				],
				"a" : 1,
				"b" : 1,
				"delete-end" : 5,
				"delete-top" : 2,
				"from" : "gbk",
				"to" : "utf-8"
			}
*/


ParseCmdline(ByRef cmdline, StrName := "$", NoValueArgs*) {
	pos := 1, args := []
	while, pos := RegExMatch(cmdline " ", "(\S*"".*?""|\S+)\s+", m, pos+StrLen(m))
		args.push( StrReplace(m1, """") )

	obj := { (StrName):[] }

	KeyOnly := {}
	for i, k in NoValueArgs
		KeyOnly[k] := true

	for i, arg in args
	{
		if KeyOnly[arg]
			obj[arg] := true
		else if RegExMatch(arg, "^--(.*?)=(.*)", m)
			obj[m1] := m2
		else if RegExMatch(arg, "^(?:/|--|-)\K.*", m)
			obj[m] := true, key := m
		else if (key != "")
			obj[key] := arg, key := ""
		else
			obj[StrName].push(arg)
	}
	return obj
}