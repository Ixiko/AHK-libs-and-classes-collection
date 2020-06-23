; Link:   	https://gist.github.com/tmplinshi/d995be35f98cdf57f5648388613246f5
; Author:	tmplinshi
; Date:
; for:     	AHK_L


/*
	ArgsToObj - Convert command line parameters to object
	Example:
	---------------------------------------------------------------------
	Command line parameters:
		-from gbk /to utf-8 /a /b --delete-top 2 --delete-end=5 in.txt out.txt
	Return:
		{
			"$" : [
				"in.txt",
				"out.txt"
			],
			"a" : 1,
			"b" : 1,
			"delete-end" : 5,
			"delete-top" : 2,
			"from" : "gbk",
			"to" : "utf-8"
		}
	---------------------------------------------------------------------
*/
ArgsToObj(StrName := "$", NoValueArgs*) {
	obj := { (StrName):[] }

	KeyOnly := {}
	for i, k in NoValueArgs
		KeyOnly[k] := true

	for i, arg in A_Args
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