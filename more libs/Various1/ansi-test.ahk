; ahk: console
#NoEnv
#Warn All, StdOut

#Include <arrays>
#Include <console>
#Include <datatable>
#Include <math>
#Include <object>
#Include <string>
#Include <testcase>

#Include %A_ScriptDir%\..\ansi.ahk

class AnsiTest extends TestCase {

	@Test_PlainStrReplaceStr() {
		testString := "iVGVBDfMHMdkjmglRfzUjZrNqHruIqcTxKCJtlmdGrzcwUFrGgzw"
		this.assertEquals(Ansi.plainStrReplaceStr(testString, -1, "|")
				, "|" SubStr(testString, 2))
		this.assertEquals(Ansi.plainStrReplaceStr(testString, 0, "|")
				, "|" SubStr(testString, 2))
		this.assertEquals(Ansi.plainStrReplaceStr(testString, 1, "|")
				, "|" SubStr(testString, 2))
		this.assertEquals(Ansi.plainStrReplaceStr(testString, 20, "|")
				, SubStr(testString, 1, 19) "|" SubStr(testString, 21))
		this.assertEquals(Ansi.plainStrReplaceStr(testString, 21, "|")
				, SubStr(testString, 1, 20) "|" SubStr(testString, 22))
		this.assertEquals(Ansi.plainStrReplaceStr(testString, 999, "|")
				, SubStr(testString, 1, StrLen(testString)-1) "|")
		; ahklint-ignore-begin: W002
		this.assertEquals(Ansi.plainStrReplaceStr("iVGVBD[35;40mfMHMdkjmglRfz[0mUjZrNqHruIqcTxKCJtlmdGrzcwUFrGgzw", 2, "|")
				, "i|GVBD[35;40mfMHMdkjmglRfz[0mUjZrNqHruIqcTxKCJtlmdGrzcwUFrGgzw")
		this.assertEquals(Ansi.plainStrReplaceStr("[35;40miVGVBDfMHMdkjmglRfz[0mUjZrNqHruIqcTxKCJtlmdGrzcwUFrGgzw", 2, "|")
				, "[35;40mi|GVBDfMHMdkjmglRfz[0mUjZrNqHruIqcTxKCJtlmdGrzcwUFrGgzw")
		this.assertEquals(Ansi.plainStrReplaceStr("[35;40maaa bbbbb cc ddddddddd eeee fff ggggg[0m hhhhhhhhh iiiiiii jjj kk", 48, "@")
				, "[35;40maaa bbbbb cc ddddddddd eeee fff ggggg[0m hhhhhhhhh@iiiiiii jjj kk")
		; ahklint-ignore-end
	}

	@Test_PlainStrInsert() {
		this.assertEquals(Ansi.plainStrInsert("asdfjklö", 1, "|")
				, "|asdfjklö")
		this.assertEquals(Ansi.plainStrInsert("asdfjklö", 2, "|")
				, "a|sdfjklö")
		this.assertEquals(Ansi.plainStrInsert("asdfjklö", 4, "|")
				, "asd|fjklö")
		this.assertEquals(Ansi.plainStrInsert("asdfjklö", 0, "|")
				, "|asdfjklö")
		this.assertEquals(Ansi.plainStrInsert("asdfjklö", 99, "|")
				, "asdfjklö|")
		this.assertEquals(Ansi.plainStrInsert("[1masdf[0mjklö", 4, "|")
				, "[1masd|f[0mjklö")
		this.assertEquals(Ansi.plainStrInsert("[35;40masdf[0mjklö", 4, "|")
				, "[35;40masd|f[0mjklö")
		st := "abcdefghijklmnopqrstuvwxyz"
		this.assertEquals(st := Ansi.plainStrInsert(st, 3, "-")
				, "ab-cdefghijklmnopqrstuvwxyz")
		this.assertEquals(st := Ansi.plainStrInsert(st, 10, "-")
				, "ab-cdefgh-ijklmnopqrstuvwxyz")
		this.assertEquals(st := Ansi.plainStrInsert(st, 23, "-")
				, "ab-cdefgh-ijklmnopqrst-uvwxyz")
	}


	@Test_WordWrap() {
		this.assertEquals(Ansi.wordWrap("12345", 20), "12345")
		; ahklint-ignore-begin: W002
		this.assertEquals(Ansi.wordWrap("aaa bbbbb cc ddddddddd eeee fff ggggg hhhhhhhhh iiiiiii jjj kk lll mmmmm nnnnnnnnnnnn oooo ppppp qqq rr ssss tt uuuu vv www xxxxxxxxxxxxxxxxxxx+-xxxxxxxxxxxxX yyY zz.", 20), "aaa bbbbb cc`nddddddddd eeee fff`nggggg hhhhhhhhh`niiiiiii jjj kk lll`nmmmmm nnnnnnnnnnnn`noooo ppppp qqq rr`nssss tt uuuu vv www`nxxxxxxxxxxxxxxxxxxx+`n-xxxxxxxxxxxxX yyY`nzz.")
		this.assertEquals(Ansi.wordWrap("aaa bbbbb cc ddddddddd eeee fff ggggg hhhhhhhhh iiiiiii jjj kk`nlll mmmmm nnnnnnnnnnnn oooo ppppp qqq rr ssss tt uuuu vv www xxxxxxxxxxxxxxxxxxx+-xxxxxxxxxxxxX yyY zz.", 20), "aaa bbbbb cc`nddddddddd eeee fff`nggggg hhhhhhhhh`niiiiiii jjj kk`nlll mmmmm`nnnnnnnnnnnnn oooo`nppppp qqq rr ssss tt`nuuuu vv www`nxxxxxxxxxxxxxxxxxxx+`n-xxxxxxxxxxxxX yyY`nzz.")
		this.assertEquals(Ansi.wordWrap("aaa bbbbb cc ddddddddd eeee fff ggggg hhhhhhhhh iiiiiii jjj kk`n`nlll mmmmm nnnnnnnnnnnn oooo ppppp qqq rr ssss tt uuuu vv www xxxxxxxxxxxxxxxxxxx+-xxxxxxxxxxxxX yyY zz.", 20), "aaa bbbbb cc`nddddddddd eeee fff`nggggg hhhhhhhhh`niiiiiii jjj kk`n`nlll mmmmm`nnnnnnnnnnnnn oooo`nppppp qqq rr ssss tt`nuuuu vv www`nxxxxxxxxxxxxxxxxxxx+`n-xxxxxxxxxxxxX yyY`nzz.")
		this.assertEquals(Ansi.wordWrap("[35;40maaa bbbbb cc ddddddddd eeee fff ggggg[0m hhhhhhhhh iiiiiii jjj kk`n`nlll mmmmm nnnnnnnnnnnn oooo ppppp qqq rr ssss tt uuuu vv www xxxxxxxxxxxxxxxxxxx+-xxxxxxxxxxxxX yyY zz.", 20), "[35;40maaa bbbbb cc`nddddddddd eeee fff`nggggg[0m hhhhhhhhh`niiiiiii jjj kk`n`nlll mmmmm`nnnnnnnnnnnnn oooo`nppppp qqq rr ssss tt`nuuuu vv www`nxxxxxxxxxxxxxxxxxxx+`n-xxxxxxxxxxxxX yyY`nzz.")
		this.assertEquals(Ansi.wordWrap("1: At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, At accusam aliquyam diam diam dolore dolores duo eirmod eos erat, et nonumy sed tempor et et invidunt justo labore Stet clita ea et gubergren, kasd magna no rebum. Sanctus sea sed takimata ut vero voluptua. Est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat.", 86), "1: At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren,`nno sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet,`nconsetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et`ndolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo`ndolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem`nipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, At`naccusam aliquyam diam diam dolore dolores duo eirmod eos erat, et nonumy sed tempor et`net invidunt justo labore Stet clita ea et gubergren, kasd magna no rebum. Sanctus sea`nsed takimata ut vero voluptua. Est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit`namet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et`ndolore magna aliquyam erat.")
		; ahklint-ignore-end
	}

	@Test_Wrap() {
		; this.AssertEquals(Ansi.Wrap("", 5), "")
		this.assertEquals(Ansi.wrap("12345", 5), "12345")
		this.assertEquals(Ansi.wrap("123456", 5), "12345`n6")
		; ahklint-ignore-begin: W002
		this.assertEquals(Ansi.wrap("aaa bbbbb cc ddddddddd eeee fff ggggg hhhhhhhhh iiiiiii jjj kk lll mmmmm nnnnnnnnnnnn oooo ppppp qqq rr ssss tt uuuu vv www xxxxxxxxxxxxxxxxxxx+-xxxxxxxxxxxxX yyY zz.", 20)
				, "aaa bbbbb cc ddddddd`n"
				. "dd eeee fff ggggg hh`n"
				. "hhhhhhh iiiiiii jjj `n"
				. "kk lll mmmmm nnnnnnn`n"
				. "nnnnn oooo ppppp qqq`n"
				. " rr ssss tt uuuu vv `n"
				. "www xxxxxxxxxxxxxxxx`n"
				. "xxx+-xxxxxxxxxxxxX y`n"
				. "yY zz.")
		this.assertEquals(Ansi.wrap(".\mack.ahk:815:103:    op.Add(new OptParser.String(0, ""color-filename"", _color_filename, ""color"", """", OptParser.OPT_ARG, G_opts[""color_filename""], G_opts[""color_filename""]))", 100)
				, ".\mack.ahk:815:103:    op.Add(new OptParser.String(0, ""color-filename"", _color_filename, ""color"", """"`n"
				. ", OptParser.OPT_ARG, G_opts[""color_filename""], G_opts[""color_filename""]))")
		this.assertEquals(Ansi.wrap("[37;43maaa bbbbb cc ddddddddd [0meeee fff ggggg hhhhhhhhh iiiiiii jjj kk lll [1mmmmmm nnnnnnnnnnnn oooo ppppp qqq rr ssss tt uuuu vv www xxxxxxxxxxxxxxxxxxx+-xxxxxxxxxxxxX yyY zz.", 20)
				, "[37;43maaa bbbbb cc ddddddd`n"
				. "dd [0meeee fff ggggg hh`n"
				. "hhhhhhh iiiiiii jjj `n"
				. "kk lll [1mmmmmm nnnnnnn`n"
				. "nnnnn oooo ppppp qqq`n"
				. " rr ssss tt uuuu vv `n"
				. "www xxxxxxxxxxxxxxxx`n"
				. "xxx+-xxxxxxxxxxxxX y`n"
				. "yY zz.")
		this.assertEquals(Ansi.wrap(" 30;40m   30;41m   30;42m   30;43m   30;44m   30;45m   30;46m   30;47m  `n"
				. " 31;40m   31;41m   31;42m   31;43m   31;44m   31;45m   31;46m   31;47m  `n", 80)
				, " 30;40m   30;41m   30;42m   30;43m   30;44m   30;45m   30;46m   30;47m  `n"
				. " 31;40m   31;41m   31;42m   31;43m   31;44m   31;45m   31;46m   31;47m  `n")
		; ahklint-ignore-end
	}

	@Test_Readable() {
		; ahklint-ignore-begin: W002
		this.assertEquals(Ansi.readable("Warum Ã¼berhaupt sind die ldapai_extensions nicht korrekt gefÃ¼llt?")
				, "Warum [7m<c3>[27m[7m<bc>[27mberhaupt sind die ldapai_extensions nicht korrekt gef[7m<c3>[27m[7m<bc>[27mllt?")
		this.assertEquals(Ansi.readable("Warum sind die ldapai_extensions nicht korrekt gefÃ¼llt?", false)
				, "Warum sind die ldapai_extensions nicht korrekt gef<c3><bc>llt?")
		; ahklint-ignore-end
	}

	@Test_setGraphic() {
		this.assertEquals(Ansi.setGraphic(1,2,3), Ansi.ESC "[1;2;3m")
		this.assertEquals(Ansi.setGraphic(94), Ansi.ESC "[94m")
		this.assertEquals(Ansi.setGraphic([93,101]), Ansi.ESC "[93;101m")
	}

	@Test_writeToStdErr() {
		Ansi.stdErr := FileOpen(A_Temp "\ansi-test-err.txt", "w `n")
		Ansi.writeLine("TEST,1,2,3",, Ansi.stdErr)
		Ansi.stdErr.close()
		this.assertEquals(TestCase.fileContent(A_Temp "\ansi-test-err.txt")
				, "TEST,1,2,3`r`n")
		Ansi.stdErr := Ansi.__InitStdErr()
		FileDelete %A_Temp%\ansi-test-err.txt
	}

	@Test_readLine() {
		saveStdIn := Ansi.stdIn
		Ansi.stdIn := FileOpen(A_ScriptDir "\testdata\input.txt", "r")
		this.assertEquals(Ansi.readLine(), "Das ist ein Test!")
		Ansi.stdIn.close()
		Ansi.stdIn := saveStdIn
	}
}

exitapp AnsiTest.runTests()

; vim: ts=4:sts=4:sw=4:tw=0:noet
