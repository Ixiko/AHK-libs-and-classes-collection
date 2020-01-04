; ahk: console
#NoEnv
#Warn All, StdOut

#Include <ansi>
#Include <arrays>
#Include <console>
#Include <datatable>
#Include <math>
#Include <object>
#Include <testcase>

#Include %A_ScriptDir%\..\string.ahk

class StringTest extends TestCase {

	@Test_Constants() {
		this.assertEquals(String.PAD_LEFT,   0)
		this.assertEquals(String.PAD_CENTER, 1)
		this.assertEquals(String.PAD_RIGHT,  2)
		this.assertEquals(String.PAD_NUMBER, 3)

		this.assertEquals(String.TRIM_LEFT,  -1)
		this.assertEquals(String.TRIM_RIGHT, +1)
		this.assertEquals(String.TRIM_ALL,    0)

		this.assertEquals(String.ASHEX_LOWER, 	 0)
		this.assertEquals(String.ASHEX_UPPER, 	 1)
		this.assertEquals(String.ASHEX_NOPREFIX, 2)
		this.assertEquals(String.ASHEX_2DIGITS,  4)

		this.assertEquals(String.EXTRACT_NOBOUNDARY,    0)
		this.assertEquals(String.EXTRACT_LEFTBOUNDARY,  1)
		this.assertEquals(String.EXTRACT_RIGHTBOUNDARY, 2)
		this.assertEquals(String.EXTRACT_WITHBOUNDARY,  3)

		this.assertEquals(HyphenationHelper.MIDDLE_DOT, "·")
		this.assertEquals(HyphenationHelper.HYPHEN_LINE, "-")

		this.assertEquals(String.COMPARE_DETERMINE, 0)
		this.assertEquals(String.COMPARE_AS_STRING, 1)
		this.assertEquals(String.COMPARE_AS_CASE_SENSITIVE_STRING, 2)
	}

	@Test_new() {
		this.assertException(String, "__new")
	}

	@Test_repeat() {
		this.assertEquals("*".repeat(10), "**********")
		this.assertEquals("* ".repeat(5), "* * * * * ")
		this.assertEquals(" test".repeat(3), " test test test")
		this.assertEquals(" test".repeat(""), "")
		this.assertEquals(" test".repeat(0), "")
		this.assertEquals(" test".repeat(-1), "")
		this.assertEquals("x".repeat(), "x")
	}

	@Test_pad() {
		this.assertException("".base, "pad", "", "", "test", 99, 10)
		this.assertException("".base, "pad", "", ""
				, "test", String.PAD_LEFT, -1)
		this.assertException("".base, "padLeft", "", "", "test", -1)
		this.assertException("".base, "padRight", "", "", "test", -1)
		this.assertException("".base, "padCenter", "", "", "test", -1)
		this.assertException("".base, "padNumber", "", "", "test", -1)
		this.assertEquals("test".pad(String.PAD_RIGHT, 4), "test")
		this.assertEquals("test".padRight(4), "test")
		this.assertEquals("test".pad(String.PAD_LEFT, 4), "test")
		this.assertEquals("test".padLeft(4), "test")
		this.assertEquals("test".pad(String.PAD_LEFT, 10, "."), "......test")
		this.assertEquals("test".padLeft(10, "."), "......test")
		this.assertEquals("test".pad(String.PAD_RIGHT, 10, "_"), "test______")
		this.assertEquals("test".padRight(10, "_"), "test______")
		this.assertEquals(" test ".pad(String.PAD_CENTER, 12, "+")
				, "+++ test +++")
		this.assertEquals(" test ".padCenter(12, "+"), "+++ test +++")
		this.assertEquals(" test ".pad(String.PAD_CENTER, 13, "#")
				, "#### test ###")
		this.assertEquals(" test ".padCenter(13, "#"), "#### test ###")
		this.assertEquals("test".pad(String.PAD_LEFT, 4, "."), "test")
		this.assertEquals("test".padLeft(4, "."), "test")
		this.assertEquals("test".pad(String.PAD_LEFT, 3, "."), "est")
		this.assertEquals("test".padLeft(3, "."), "est")
		this.assertEquals("test".pad(String.PAD_CENTER, 2, "."), "es")
		this.assertEquals("test".padCenter(2, "."), "es")
		this.assertEquals("testxtest".pad(String.PAD_CENTER, 5, "."), "stxte")
		this.assertEquals("testxtest".padCenter(5, "."), "stxte")
		this.assertEquals("testxtest".pad(String.PAD_CENTER, 4, "."), "stxt")
		this.assertEquals("testxtest".padCenter(4, "."), "stxt")
		this.assertEquals("testTesTtest".pad(String.PAD_CENTER, 4, "."), "TesT")
		this.assertEquals("testTesTtest".padCenter(4, "."), "TesT")
		this.assertEquals("test".pad(String.PAD_LEFT, 10, "xyz"), "xxxxxxtest")
		this.assertEquals("test".padLeft(10, "xyz"), "xxxxxxtest")
		this.assertEquals("123".pad(String.PAD_NUMBER, 5)
				, "00123", TestCase.AS_STRING)
		this.assertEquals("123".padNumber(5), "00123", TestCase.AS_STRING)
		this.assertEquals("123".pad(String.PAD_NUMBER, 5, " ")
				, "  123", TestCase.AS_STRING)
		this.assertEquals("123".padNumber(5, " "), "  123", TestCase.AS_STRING)
		this.assertEquals("-123".pad(String.PAD_NUMBER, 5)
				, "-0123", TestCase.AS_STRING)
		this.assertEquals("-123".padNumber(5), "-0123", TestCase.AS_STRING)
		this.assertEquals("+123".pad(String.PAD_NUMBER, 5)
				, "+0123", TestCase.AS_STRING)
		this.assertEquals("+123".padNumber(5), "+0123", TestCase.AS_STRING)
		this.assertEquals("123".pad(String.PAD_NUMBER, 2)
				, "123", TestCase.AS_STRING)
		this.assertEquals("123".padNumber(2), "123", TestCase.AS_STRING)
		this.assertEquals("+1".pad(String.PAD_NUMBER, 3, " ")
				, " +1", TestCase.AS_STRING)
		this.assertEquals("+1".padNumber(3, " "), " +1", TestCase.AS_STRING)
		this.assertEquals("1416".pad(String.PAD_RIGHT, 2, "0")
				, "14", TestCase.AS_STRING)
		this.assertEquals("1416".padRight(2, "0"), "14", TestCase.AS_STRING)
		x := 1
		this.assertEquals(x.padNumber(3), "  1")
	}

	@Test_trim() {
		this.assertEquals("`ttest`t".trim(String.TRIM_LEFT), "test`t")
		this.assertEquals("`ttest`t".trimLeft(), "test`t")
		this.assertEquals("`ttest`t".trim(String.TRIM_LEFT), "test`t")
		this.assertEquals("`ttest`t".trimLeft(), "test`t")
		this.assertEquals("`t   `t  `t test`t".trim(String.TRIM_LEFT), "test`t")
		this.assertEquals("`t   `t  `t test`t".trimLeft(), "test`t")
		this.assertEquals("`t  test `t `t  `t   `t ".trim(String.TRIM_RIGHT)
				, "`t  test")
		this.assertEquals("`t  test `t `t  `t   `t ".trimRight(), "`t  test")
		this.assertEquals("`ttest`t".trim(String.TRIM_RIGHT), "`ttest")
		this.assertEquals("`ttest`t".trimRight(), "`ttest")
		this.assertEquals("`ttest`t".trim(String.TRIM_ALL), "test")
		this.assertEquals("`ttest`t".trimAll(), "test")
		this.assertEquals("`ttest`t".trim(), "test")
		this.assertEquals("`t".trim(), "")
	}

	@Test_count() {
		this.assertEquals("T*E*S*T".count("\*"), 3)
		this.assertEquals("_Log_0217173832".count("\d"), 10)
		this.assertEquals("_Log_0217173832".count("^\d+"), 0)
		this.assertEquals("ABC".count("XYZ"), 0)
		this.assertEquals("TrueTypeFont".count("t"), 1)
		this.assertEquals("TrueTypeFont".count("T"), 2)
		this.assertEquals("TrueTypeFont".count("i)T", true), 3)
		this.assertEquals("test`t`t".count("\s$"), 1)
		this.assertEquals("test`t`t".count("\s+$"), 2)
		this.assertEquals("test".count(""), 0)
		this.assertEquals("TrendyTrickyTreat".count("Tr"), 3)
		this.assertEquals("Test".count("t"), 1)
		this.assertEquals("Test".count("i)t"), 2)
	}

	@Test_replaceAt() {
		this.assertEquals("Das ist ein Test".replaceAt(5, 3, "war")
				, "Das war ein Test")
		this.assertEquals("Das war ein Test".replaceAt(9, 3, "kein")
				, "Das war kein Test")
		this.assertException("".base, "replaceAt", "", ""
				, "Das ist ein Test", 0, 2, "XXX")
		this.assertException("".base, "replaceAt", "", ""
				, "Das ist ein Test", 17, 1, "XXX")
		this.assertEquals("Das ist ein Test".replaceAt(15, 2, "xt")
				, "Das ist ein Text")
		this.assertEquals("This is a test".replaceAt(6, 2, "was")
				, "This was a test")
	}

	@Test_insertAt() {
		this.assertEquals("Das ein Test".insertAt(5, "war ")
				, "Das war ein Test")
		this.assertEquals("This was a test".insertAt(12, "good ")
				, "This was a good test")
	}

	@Test_cutAt() {
		this.assertEquals("Das ist ein Test".cutAt(5, 4), "Das ein Test")
		this.assertEquals("Das ist ein Test".cutAt(1, 4), "ist ein Test")
		this.assertEquals("Das ist ein Test".cutAt(13, 4), "Das ist ein ")
		this.assertEquals("Das ist ein Test".cutAt(13, 99), "Das ist ein ")
	}

	@Test_Cases() {
		this.assertEquals("Das ist 1 Test".upper(), "DAS IST 1 TEST")
		this.assertEquals("Das ist 1 Test".lower(), "das ist 1 test")
	}

	@Test_asRegEx() {
		this.assertEquals("C:\usr\bin".asRegEx(), "C:\\usr\\bin")
	}

	@Test_subStr() {
		this.assertEquals("Das ist ein Test".subStr(5, 3), "ist")
		this.assertEquals("Das ist ein Test".subStr(5), "ist ein Test")
		this.assertEquals("Das ist noch ein Test".subStr(0), "t")
		this.assertEquals("Das ist noch ein Test!".subStr(0), "!")
		this.assertEquals("Das ist auch noch ein Test".subStr(-7), "ein Test")
		this.assertEquals("Das ist auch noch ein Test".subStr(-7, 3), "ein")
		this.assertEquals("This is a test".subStr(6, 2), "is")
		this.assertEquals("This is a test".subStr(-5, 1), "a")
	}

	@Test_swap() {
		str1 := "test1"
		str2 := "test2"
		this.assertEquals(str1.swap(str2), "test2")
		this.assertEquals(str2, "test1")
		this.assertEquals("test3".swap(str1), "test1")
		this.assertEquals(str1, "test3")
		this.assertEquals(str1.swap(str3 := "test4"), "test4")
		this.assertEquals(str3, "test3")

		z1 := 13
		z2 := 3
		this.assertEquals(z1.swap(z2), 3)
		this.assertEquals(z2, 13)
	}

	@Test_Reverse() {
		this.assertEquals("Reverse".reverse(), "esreveR")
		this.assertEquals("Rückwärts".reverse(), "sträwkcüR")
	}

	@Test_asHex() {
		this.assertException("".base, "asHex", "", "", "abc")
		this.assertEquals((x := 0).asHex(), "0x0", TestCase.AS_STRING)
		this.assertEquals((x := 13).asHex(String.ASHEX_UPPER), "0xD"
				, TestCase.AS_STRING)
		this.assertEquals((x := 14).asHex(String.ASHEX_UPPER
				|String.ASHEX_2DIGITS), "0x0E", TestCase.AS_STRING)
		this.assertEquals((x := 15).asHex(String.ASHEX_NOPREFIX)
				, "f", TestCase.AS_STRING)
		this.assertEquals((x := 15).asHex(String.ASHEX_NOPREFIX
				|String.ASHEX_2DIGITS), "0f", TestCase.AS_STRING)
		this.assertEquals((x := 10).asHex(String.ASHEX_UPPER
				|String.ASHEX_NOPREFIX
				|String.ASHEX_2DIGITS), "0A", TestCase.AS_STRING)
		this.assertEquals("-9223372036854775808".asHex()
				, "-0x8000000000000000", TestCase.AS_STRING)
		this.assertEquals("9223372036854775807".asHex(String.ASHEX_UPPER)
				, "0x7FFFFFFFFFFFFFFF", TestCase.AS_STRING)
		this.assertEquals("9223372036854775807".asHex(String.ASHEX_2DIGITS)
				, "0x7fffffffffffffff", TestCase.AS_STRING)
		this.assertEquals((x := 15).asHex(String.ASHEX_NOPREFIX, 7), "000000f")
	}

	@Test_asBinary() {
		this.assertException("".base, "AsBinary", "", "", "abc")
		this.assertEquals("0".asBinary(), "0000")
		this.assertEquals("9".asBinary(), "1001")
		this.assertEquals("10".asBinary(), "1010")
		this.assertEquals("127".asBinary(), "01111111")
		this.assertEquals("128".asBinary(), "10000000")
		this.assertEquals("255".asBinary(), "11111111")
		this.assertEquals("256".asBinary(), "000100000000")
		this.assertEquals("13".asBinary(), "1101")
		this.assertEquals("256".asBinary(0), "100000000")
		this.assertEquals("13".asBinary(8), "00001101")
		this.assertEquals("13".asBinary(8, 4), "0000 1101")
		this.assertEquals("256".asBinary(, 3), "000 100 000 000")
		this.assertEquals("127".asBinary(, 5), "01111 111")
		this.assertEquals("-1".asBinary(0), "-1")
		this.assertEquals("-1".asBinary(), "-0001")
		this.assertEquals("-62".asBinary(0), "-111110")
	}

	@Test_asNumber() {
		this.assertEquals("123,45".asNumber(), 123.45)
		this.assertEquals("9.876.543,21".asNumber(), 9876543.21)
		this.assertEquals("9'876'543|21".asNumber("|", "'"), 9876543.21)
		this.assertEquals("0,79 h".asNumber(), 0.79)
		this.assertEquals("-3zehn,5".asNumber(), -3.5)
	}

	@Test_len() {
		this.assertEquals("".len(), 0)
		this.assertEquals("1".len(), 1)
		this.assertEquals("abc".len(), 3)
	}

	@Test_put() {
		l := ("Test!!!").put(st)
		this.assertEquals(l, 7)
		l0 := ("öäüßÖÄÜ").put(st0)
		this.assertEquals(l0, 7)
		this.assertEquals(NumGet(&st0, 0, "uchar"), 0xf6)
		this.assertEquals(NumGet(&st0, 1, "uchar"), 0xe4)
		this.assertEquals(NumGet(&st0, 2, "uchar"), 0xfc)
		this.assertEquals(NumGet(&st0, 3, "uchar"), 0xdf)
		this.assertEquals(NumGet(&st0, 4, "uchar"), 0xd6)
		this.assertEquals(NumGet(&st0, 5, "uchar"), 0xc4)
		this.assertEquals(NumGet(&st0, 6, "uchar"), 0xdc)

		l850 := ("öäüßÖÄÜ").put(st850, "cp850")
		this.assertEquals(NumGet(&st850, 0, "uchar"), 0x94)
		this.assertEquals(NumGet(&st850, 1, "uchar"), 0x84)
		this.assertEquals(NumGet(&st850, 2, "uchar"), 0x81)
		this.assertEquals(NumGet(&st850, 3, "uchar"), 0xe1)
		this.assertEquals(NumGet(&st850, 4, "uchar"), 0x99)
		this.assertEquals(NumGet(&st850, 5, "uchar"), 0x8e)
		this.assertEquals(NumGet(&st850, 6, "uchar"), 0x9a)

		l1252 := ("öäüßÖÄÜ").put(st1252, "cp1252")
		this.assertEquals(NumGet(&st1252, 0, "uchar"), 0xf6)
		this.assertEquals(NumGet(&st1252, 1, "uchar"), 0xe4)
		this.assertEquals(NumGet(&st1252, 2, "uchar"), 0xfc)
		this.assertEquals(NumGet(&st1252, 3, "uchar"), 0xdf)
		this.assertEquals(NumGet(&st1252, 4, "uchar"), 0xd6)
		this.assertEquals(NumGet(&st1252, 5, "uchar"), 0xc4)
		this.assertEquals(NumGet(&st1252, 6, "uchar"), 0xdc)

		lutf8 := ("öäüßÖÄÜ").put(stutf8, "utf-8")
		this.assertEquals(lutf8, 14)
		this.assertEquals(NumGet(&stutf8, 0, "ushort"), 0xb6c3)
		this.assertEquals(NumGet(&stutf8, 2, "ushort"), 0xa4c3)
		this.assertEquals(NumGet(&stutf8, 4, "ushort"), 0xbcc3)
		this.assertEquals(NumGet(&stutf8, 6, "ushort"), 0x9fc3)
		this.assertEquals(NumGet(&stutf8, 8, "ushort"), 0x96c3)
		this.assertEquals(NumGet(&stutf8, 10, "ushort"), 0x84c3)
		this.assertEquals(NumGet(&stutf8, 12, "ushort"), 0x9cc3)
	}

	@Test_toArray() {
		a := "abc.def.ghi".toArray(".")
		this.assertTrue(a[1] == "abc" && a[2] == "def" && a[3] == "ghi")
		a := "<abc>.[def].{ghi}".toArray(".", "<>[]{}")
		this.assertTrue(a[1] == "abc" && a[2] == "def" && a[3] == "ghi")
		a := "h:\temp`n.git`n.CVSROOT`n".toArray("`n",, false)
		this.assertEquals(a.maxIndex(), 3)
		this.assertEquals(a[1], "h:\temp")
		this.assertEquals(a[2], ".git")
		this.assertEquals(a[3], ".CVSROOT")
		a := "h:\temp`n.git`n.CVSROOT`n".toArray("`n")
		this.assertEquals(a.maxIndex(), 4)
		this.assertEquals(a[1], "h:\temp")
		this.assertEquals(a[2], ".git")
		this.assertEquals(a[3], ".CVSROOT")
		this.assertEquals(a[4], "")
		a := "h:\temp`n`n.git`n.CVSROOT`n".toArray("`n")
		this.assertEquals(a.maxIndex(), 5)
		this.assertEquals(a[1], "h:\temp")
		this.assertEquals(a[2], "")
		this.assertEquals(a[3], ".git")
		this.assertEquals(a[4], ".CVSROOT")
		this.assertEquals(a[5], "")
		a := "-a -bc -m ""This is my very important message"" --test ""And another string""".toArray() ; ahklint-ignore: W002
		this.assertEquals(a.maxIndex(), 6)
		this.assertEquals(a[1], "-a")
		this.assertEquals(a[2], "-bc")
		this.assertEquals(a[3], "-m")
		this.assertEquals(a[4], "This is my very important message")
		this.assertEquals(a[5], "--test")
		this.assertEquals(a[6], "And another string")
		a := "-a`n-bc`n-m`n""This`nis`nmy`nvery`nimportant`nmessage""`n--test`n""And`nanother`nstring""".toArray("`n") ; ahklint-ignore: W002
		this.assertEquals(a.maxIndex(), 6)
		this.assertEquals(a[1], "-a")
		this.assertEquals(a[2], "-bc")
		this.assertEquals(a[3], "-m")
		this.assertEquals(a[4], "This is my very important message")
		this.assertEquals(a[5], "--test")
		this.assertEquals(a[6], "And another string")
	}

	@Test_formatNumber() {
		this.assertException("".base, "formatNumber", "", "", "keine_nummer")
		this.assertEquals("1".formatNumber(), "1")
		this.assertEquals("13".formatNumber(), "13")
		this.assertEquals("133".formatNumber(), "133")
		this.assertEquals("1303".formatNumber(), "1.303")
		this.assertEquals("130369".formatNumber(), "130.369")
		this.assertEquals("13031969".formatNumber(), "13.031.969")
		this.assertEquals("130319690720".formatNumber(), "130.319.690.720")
		this.assertEquals("13031969".formatNumber(".", ",", "'"), "13'031'969")
		this.assertEquals("1303.1969".formatNumber(), "1.303,1969")
		this.assertEquals("1303,1969".formatNumber(",", ".", ","), "1,303.1969")
	}

	@Test_replace() {
		this.assertEquals("a-b-c".Replace("-", ""), "abc")
		this.assertEquals("a-b-c".Replace("-",, false), "ab-c")
		this.assertEquals("a-b-c".Replace("-", "@"), "a@b@c")
		this.assertEquals("a-b-c".Replace("-", "#", false), "a#b-c")
	}

	@Test_in() {
		this.assertTrue("a".in("a", "b", "c"))
		this.assertFalse("x".in("a", "b", "c"))
		this.assertTrue("Fr".in("Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"))
	}

	@Test_wrap() {
		this.assertException("".base, "wrap", "", "", "Das ist ein Test", 2)
		this.assertEquals("Das ist ein Test".wrap(10), "Das ist`nein Test")
		this.assertEquals("Das ist ein Test".wrap(10,,,, true)
				, "Das ist   `nein Test  ")
		this.assertEquals(" Nichtsdestotrotz ist es ein Test".Wrap(10,,,, true)
				, " Nichtsdes`ntotrotz   `nist es ein`nTest      ")
		this.assertEquals("Das ist ein Test".wrap(10, "   ")
				, "   Das ist`n   ein Test")
		this.assertEquals("Das ist ein Test".wrap(10, " ", "  ")
				, "   Das ist`n ein Test")
		this.assertEquals("Das ist ein Test".wrap(10, " ", "  ", true)
				, "  Das ist`n ein Test")
		this.assertEquals("Das ist ein Test".wrap(5), "Das`nist`nein`nTest")
		this.assertEquals("Das ist ein schwerer Test".wrap(5)
				, "Das`nist`nein`nschwe`nrer`nTest")
		this.assertEquals("Lorem ipsum dolor sit amet".wrap(3)
				, "Lor`nem`nips`num`ndol`nor`nsit`name`nt")
		this.assertEquals("Das ist ein Test".wrap(3), "Das`nist`nein`nTes`nt")
		this.assertEquals("Das ist ein Test".wrap(40), "Das ist ein Test")
		lorem := "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet." ; ahklint-ignore: W002
		wrappedLorem =
		( LTrim
			Lorem ipsum dolor sit amet, consetetur
			sadipscing elitr, sed diam nonumy eirmod
			tempor invidunt ut labore et dolore
			magna aliquyam erat, sed diam voluptua.
			At vero eos et accusam et justo duo
			dolores et ea rebum. Stet clita kasd
			gubergren, no sea takimata sanctus est
			Lorem ipsum dolor sit amet. Lorem ipsum
			dolor sit amet, consetetur sadipscing
			elitr, sed diam nonumy eirmod tempor
			invidunt ut labore et dolore magna
			aliquyam erat, sed diam voluptua. At
			vero eos et accusam et justo duo dolores
			et ea rebum. Stet clita kasd gubergren,
			no sea takimata sanctus est Lorem ipsum
			dolor sit amet.
		)
		lorem := lorem.wrap(40)
		this.assertEquals(lorem, wrappedLorem)
	}

	@Test_compare() {
		this.assertEquals("test".compare("test"), 0)
		this.assertEquals("test".compareAsCaseSensitiveString("test"), 0)
		this.assertEquals("test".compare("Test"), 1)
		this.assertEquals("test".compareAsCaseSensitiveString("Test"), 1)
		this.assertEquals("A".compare("a"), -1)
		this.assertEquals("A".compareAsCaseSensitiveString("a"), -1)
		this.assertEquals("a".compare("A"), 1)
		this.assertEquals("a".compareAsCaseSensitiveString("A"), 1)
		this.assertEquals("test".compare("Test", String.COMPARE_AS_STRING), 0)
		this.assertEquals("test".compareAsString("Test"), 0)
		this.assertEquals("1".compare("1"), 0)
		this.assertEquals("1".compareAsNumber("1"), 0)
		this.assertEquals("2".compare("1"), 1)
		this.assertEquals("2".compareAsNumber("1"), 1)
		this.assertEquals("1".compare("2"), -1)
		this.assertEquals("1".compareAsNumber("2"), -1)
		this.assertEquals("1".compare("10"), -1)
		this.assertEquals("1".compareAsNumber("10"), -1)
		this.assertEquals("2".compare("10", String.COMPARE_AS_STRING), 1)
		this.assertEquals("2".compareAsString("10"), 1)
		this.assertEquals("b".compare("S"), 1)
		this.assertEquals("b".compareAsCaseSensitiveString("S"), 1)
		this.assertEquals("3".compare("11"), -1)
		this.assertEquals("3".compareAsNumber("11"), -1)
		this.assertEquals("11".compare("3"), 1)
		this.assertEquals("11".compareAsNumber("3"), 1)
	}

	@Test_equals() {
		this.assertTrue("test".equals("test"))
		this.assertTrue("test".equals("Test"))
		this.assertFalse("test".equals("Test"
				, String.COMPARE_AS_CASE_SENSITIVE_STRING))
		this.assertFalse("test".equalsCaseSensitiveString("Test"))
		this.assertTrue("Test".equalsCaseSensitiveString("Test"))
		this.assertFalse("test ".equals("test"))
		this.assertFalse("011".equals("11"))
		this.assertTrue("011".equalsNumber("11"))
		this.assertTrue("042.345".equalsNumber("00042.34500"))
		this.assertFalse("042.345".equalsString("00042.34500"))
	}

	@Test_extract() {
		this.assertEquals("abc >A test string< xyz".extract(">", "<")
				, "A test string")
		this.assertEquals(">A test string<".extract(">", "<"), "A test string")
		this.assertEquals(">A test string<".extract(">", "<"
				, String.EXTRACT_LEFTBOUNDARY), ">A test string")
		this.assertEquals(">A test string<".extract(">", "<"
				, String.EXTRACT_RIGHTBOUNDARY), "A test string<")
		this.assertEquals(">A test string<".extract(">", "<"
				, String.EXTRACT_LEFTBOUNDARY | String.EXTRACT_RIGHTBOUNDARY)
				, ">A test string<")
		this.assertEquals("abc>A test string<xyz".extract(">", "<"
				, String.EXTRACT_LEFTBOUNDARY | String.EXTRACT_RIGHTBOUNDARY)
				, ">A test string<")
		this.assertEquals("abc>A test string<xyz".extract(">", "<"
				, String.EXTRACT_WITHBOUNDARY), ">A test string<")
		this.assertEquals(">A test string<".extract(" ", " "), "test")
		this.assertEquals(">A test string<".extract("", " "), ">A")
		this.assertEquals(">A test string<".extract(" ", ""), "test string<")
	}

	@Test_filter() {
		this.assertTrue("This is a Test".filter("*Test"))
		this.assertFalse("This is a Test too".filter("*Test"))
		this.assertTrue("abc".filter("*b*"))
		this.assertFalse("abc".filter("*x*"))
		this.assertTrue("abc".filter("x|b", true))
		this.assertTrue("cn=WPA_App,ou=groups,dc=viessmann,dc=net"
				.filter("???WPA_*"))
		this.assertFalse("cn=WPA_App,ou=groups,dc=viessmann,dc=net"
				.filter("WPP_*"))
		this.assertFalse("cn=WPA_App,ou=groups,dc=viessmann,dc=net"
				.filter("WPA_"))
		this.assertTrue("cn=WPA_App,ou=groups,dc=viessmann,dc=net"
				.filter("*WP?_*"))
		this.assertTrue("cn=WPA_App,ou=groups,dc=viessmann,dc=net"
				.filter("WPA_|WPP_", true))
		this.assertTrue("cn=Bi)boxi,ou=groups,dc=viessmann,dc=net"
				.filter("cn=Bi)boxi,*"))
		this.assertTrue("cn=Bi)boxi,ou=groups,dc=viessmann,dc=net"
				.filter("cn=\QBi)boxi\E,.*", true))
		this.assertTrue("cn=WPS_SALES-TEST,ou=groups,dc=viessmann,dc=net"
				.filter("i)sales", true))
		this.assertFalse("cn=WPS_SALES-TEST,ou=groups,dc=viessmann,dc=net"
				.filter("i)sales", false))
		this.assertTrue("cn=VitOrga,ou=groups,dc=viessmann,dc=net"
				.filter("*vitorga*",, true))
		this.assertTrue("WPA_App".filter("i)^((wpa)(_))(.+?)$",true, false,, m))
		this.assertEquals(m.count, 4)
		this.assertEquals(m[1], "WPA_")
		this.assertEquals(m[2], "WPA")
		this.assertEquals(m[3], "_")
		this.assertEquals(m[4], "App")
		this.assertFalse("del_abc".filter("^del_", true,, true))
	}

	@Test_expand() {
		this.assertEquals("|".expand("`n|", 5), "|`n|`n|`n|`n|")
		this.assertEquals("|Das|`n|ist|`n".expand("|   |`n", 5)
				, "|Das|`n|ist|`n|   |`n|   |`n|   |`n")
		this.assertEquals("|Das|`n|ist|".expand("`n|   |", 5)
				, "|Das|`n|ist|`n|   |`n|   |`n|   |")
		this.assertEquals("Das ist".expand("`n" . "x".repeat(10), 3)
				, "Das ist`nxxxxxxxxxx`nxxxxxxxxxx")
		this.assertEquals("".expand(" ", 10), "          ")
		this.assertEquals("".expand(" ", 0), "")
	}

	@Test_subst() {
		this.assertEquals("%s".Subst("Test"), "Test")
		this.assertEquals("%s%s".Subst("Test", "Abc"), "TestAbc")
		this.assertEquals("%s%s%s".Subst("Test", "Abc", "xyZ"), "TestAbcxyZ")
		this.assertEquals("Das %s ein %s".Subst("ist", "Test")
				, "Das ist ein Test")
		this.assertEquals("Das %s %i %s".Subst("ist", 1, "Test")
				, "Das ist 1 Test")
		this.assertEquals("Das %s10 ein %s5".Subst("ist", "Test")
				, "Das ist        ein Test ")
		this.assertEquals("Das %s-10 ein %s5".Subst("ist", "Test")
				, "Das        ist ein Test ")
		this.assertEquals("Das %s %i03 %s".Subst("ist", 1, "Test")
				, "Das ist 001 Test")
		this.assertEquals("%s0".Subst("Test"), "Test")
	}

	@Test_split() {
		a := "Hallihallo [1mLorem[0m ippsum dolor [1msit amed[0m."
				.Split("\[[01]m")
		this.assertEquals(a.surround.maxIndex() + a.delimiter.maxIndex(), 9)
		this.assertEquals(a.surround[1], "Hallihallo ")
		this.assertEquals(a.surround[2], "Lorem")
		this.assertEquals(a.surround[3], " ippsum dolor ")
		this.assertEquals(a.surround[4], "sit amed")
		this.assertEquals(a.surround[5], ".")
		this.assertEquals(a.delimiter[1], "[1m")
		this.assertEquals(a.delimiter[2], "[0m")
		this.assertEquals(a.delimiter[3], "[1m")
		this.assertEquals(a.delimiter[4], "[0m")
		this.assertEquals(a.all[1], "Hallihallo ")
		this.assertEquals(a.all[2], "[1m")
		this.assertEquals(a.all[3], "Lorem")
		this.assertEquals(a.all[4], "[0m")
		this.assertEquals(a.all[5], " ippsum dolor ")
		this.assertEquals(a.all[6], "[1m")
		this.assertEquals(a.all[7], "sit amed")
		this.assertEquals(a.all[8], "[0m")
		this.assertEquals(a.all[9], ".")
		a := "Hallihallo".split("")
		this.assertEquals(a.surround.maxIndex(), 1)
		this.assertEquals(a.delimiter.maxIndex(), "")
		this.assertEquals(a.surround[1], "Hallihallo")
		this.assertEquals(a.all[1], "Hallihallo")
	}

	@Test_unSplit() {
		t := ",abc".split(",")
		this.assertEquals(String.unSplit(t), ",abc")
		t := "abc,".split(",")
		this.assertEquals(String.unSplit(t), "abc,")
		t := "abc,def,ghi,".split(",")
		this.assertEquals(String.unSplit(t), "abc,def,ghi,")
		t := "abc+def-ghi,".split("[+-]")
		this.assertEquals(String.unSplit(t), "abc+def-ghi,")
	}

	@Test_lastCharIsQuoteFailure() {
		a := "Das ist ""ein""`nbesonderer Test".toArray("`n")
		this.assertEquals(a[1], "Das ist ""ein""")
		this.assertEquals(a[2], "besonderer Test")
		st := "	op.Add(new OptParser.String(0, ""color-match"", _color_match, ""color"", """", OptParser.OPT_ARG, G_opts[""color_match""`n], G_opts[""color_match""])) }" ; ahklint-ignore: W002
		a := st.toArray("`n")
		this.assertEquals(a[1], "	op.Add(new OptParser.String(0, ""color-match"", _color_match, ""color"", """", OptParser.OPT_ARG, G_opts[""color_match""") ; ahklint-ignore: W002
		this.assertEquals(a[2], "], G_opts[""color_match""])) }")
	}

	@Test_Printf() {
		this.assertEquals("%i%%".printf(100), "100%")
		this.assertEquals("Lorem %s dolor".printf("ipsum"), "Lorem ipsum dolor")
		this.assertEquals("%s ipsum".printf("Lorem"), "Lorem ipsum")
		this.assertEquals("%s %s".printf("Lorem", "ipsum"), "Lorem ipsum")
		this.assertEquals("%10s %s".printf("Lorem", "ipsum")
				, "     Lorem ipsum")
		this.assertEquals("%-15s %s".printf("Lorem", "ipsum")
				, "Lorem           ipsum")
		this.assertEquals("Lorem %%s %s".printf("ipsum"), "Lorem %s ipsum")
		this.assertEquals("%s".printf("Test"), "Test")
		this.assertEquals("%s%s".printf("Test", "Abc"), "TestAbc")
		this.assertEquals("%s%s%s".printf("Test", "Abc", "xyZ"), "TestAbcxyZ")
		this.assertEquals("Das %s ein %s".printf("ist", "Test")
				, "Das ist ein Test")
		this.assertEquals("Das %s %i %s".printf("ist", 1, "Test")
				, "Das ist 1 Test")
		this.assertEquals("Das %-10s ein %-5s".printf("ist", "Test")
				, "Das ist        ein Test ")
		this.assertEquals("Das %10s ein %5s".printf("ist", "Test")
				, "Das        ist ein  Test")
		this.assertEquals("Das %s %03i %s".printf("ist", 1, "Test")
				, "Das ist 001 Test")
		this.assertEquals("Das %s %03i %s".printf(["ist", 1], "Test")
				, "Das ist 001 Test")
		this.assertEquals("%3s".printf("abcde"), "abcde")
		this.assertEquals("%i".printf(123), "123")
		this.assertEquals("%i".printf(-123), "-123")
		this.assertEquals("%+i".printf(123), "+123", TestCase.AS_STRING)
		this.assertEquals("% i".printf(123), "123", TestCase.AS_STRING)
		this.assertEquals("%0i".printf(123), "123", TestCase.AS_STRING)
		this.assertEquals("%05i".printf(123), "00123", TestCase.AS_STRING)
		this.assertEquals("%05i".printf(-123), "-0123", TestCase.AS_STRING)
		this.assertEquals("%+05i".printf(123), "+0123", TestCase.AS_STRING)
		this.assertEquals("% 05i".printf(123), "00123", TestCase.AS_STRING)
		this.assertEquals("% 05i".printf(-123), "00123", TestCase.AS_STRING)
		this.assertEquals("%+3i".printf(12345), "+12345", TestCase.AS_STRING)
		this.assertEquals("%+3i".printf(1234), "+1234", TestCase.AS_STRING)
		this.assertEquals("%+3i".printf(123), "+123", TestCase.AS_STRING)
		this.assertEquals("%+3i".printf(12), "+12", TestCase.AS_STRING)
		this.assertEquals("%+3i".printf(1), " +1", TestCase.AS_STRING)
		this.assertEquals("% 3i".printf(1), "  1", TestCase.AS_STRING)
		this.assertEquals("% 3i".printf(-1), "  1", TestCase.AS_STRING)
		this.assertEquals("%-5i".printf(123), "123  ", TestCase.AS_STRING)
		this.assertEquals("%c".printf("a"), "a")
		this.assertEquals("%c".printf("abc"), "a")
		this.assertEquals("%c".printf(65), "A")
		this.assertEquals("%5c".printf(65), "    A")
		this.assertEquals("%-5c".printf(65), "A    ")
		this.assertEquals("%10.5s".printf("abcdefghijklmnop"), "     abcde")
		this.assertEquals("%-10.5s".printf("abcdefghijklmnop"), "abcde     ")
		this.assertEquals("%7.5i".printf(123), "  00123", TestCase.AS_STRING)
		this.assertEquals("%7.5i".printf(-123), "  -0123", TestCase.AS_STRING)
		this.assertEquals("%+7.5i".printf(123), "  +0123", TestCase.AS_STRING)
		this.assertEquals("%+7.5i".printf(-123), "  -0123", TestCase.AS_STRING)
		this.assertEquals("% 7.5i".printf(-123), "  00123", TestCase.AS_STRING)
		this.assertEquals("%-7.5i".printf(-123), "-0123  ", TestCase.AS_STRING)
		this.assertEquals("%-7.6i".printf(-123), "-00123 ", TestCase.AS_STRING)
		this.assertEquals("%-7.0i".printf(-123), "-123   ", TestCase.AS_STRING)
		this.assertEquals("%-7.3i".printf(0), "000    ", TestCase.AS_STRING)
		this.assertEquals("%-7.1i".printf(0), "0      ", TestCase.AS_STRING)
		this.assertEquals("%-7.0i".printf(0), "       ", TestCase.AS_STRING)
		this.assertEquals("%4.2f".printf(3.1416), "3.14")
		this.assertEquals("%7.3f".printf(3.1416), "  3.141", TestCase.AS_STRING)
		this.assertEquals("%7.1f".printf(3.1416), "    3.1", TestCase.AS_STRING)
		this.assertEquals("%+7.1f".printf(3.1416), "   +3.1"
				, TestCase.AS_STRING)
		this.assertEquals("%+9.4f".printf(-3.1416), "  -3.1416"
				, TestCase.AS_STRING)
		this.assertEquals("%+09.4f".printf(-3.1416), "-003.1416"
				, TestCase.AS_STRING)
		this.assertEquals("%+09.2f".printf(-3.1416), "-00003.14"
				, TestCase.AS_STRING)
		this.assertEquals("% 09.2f".printf(-3.1416), "000003.14"
				, TestCase.AS_STRING)
		this.assertEquals("% 9.4f".printf(-3.1416), "   3.1416"
				, TestCase.AS_STRING)
		this.assertEquals("% 9.*f".printf(3, -3.1416), "    3.141"
				, TestCase.AS_STRING)
		this.assertEquals("% *.*f".printf(8, 2, -3.1416), "    3.14"
				, TestCase.AS_STRING)
		; this.assertEquals("% 9.*f".printf(8, 2, -3.1416), "    3.14", TestCase.AS_STRING) ; FIXME: -> enless-loop
		this.assertEquals("Mit was %+09.2f drum herum".printf(-3.1416)
				, "Mit was -00003.14 drum herum", TestCase.AS_STRING)
		; this.assertEquals("%+09.2f".printf("Mit"), "???", TestCase.AS_STRING) ; FIXME: Ungültiges format -> endless-loop
		this.assertEquals("%s was %+09.2f drum %s"
				.printf("Mit", -3.1416, "herum"), "Mit was -00003.14 drum herum"
				, TestCase.AS_STRING)
		this.assertEquals("Width trick: %*d".printf(5, 10), "Width trick:    10"
				, TestCase.AS_STRING)
		this.assertEquals("Width trick: %*d".printf([5, 10])
				, "Width trick:    10", TestCase.AS_STRING)
		this.assertEquals("Width trick: %*d".printf(5, [10])
				, "Width trick:    10", TestCase.AS_STRING)
		; this.assertEquals("%+.0e".Printf(3.1416), "+3e+000", TestCase.AS_STRING) ; TODO: FIXME "e" isn't supported yet
		; this.assertEquals("%+E".Printf(3.1416), "+3.1416E+000", TestCase.AS_STRING) ; TODO: FIXME "E" isn't supported yet
		; TODO: Add the following:
	}

	@Test_printf_20191009() {
		this.assertEquals("%i".printf(47.00)
				, "47", TestCase.AS_STRING)
		this.assertEquals("%-7.0i".printf(-47.00)
				, "-47    ", TestCase.AS_STRING)
		this.assertEquals("%-7.2i".printf(-47.00)
				, "-0047  ", TestCase.AS_STRING)
		this.assertEquals("You earned %i credits".printf(47.000)
				, "You earned 47 credits")
		this.assertEquals("Amount owed is $%.2f".printf(1730)
				, "Amount owed is $1730.00")
	}

	@Test_Hyphenate() {
		this.assertEquals("Maus".hyphenate(), "Maus")
		this.assertEquals("Esel".hyphenate(), "Esel")
		this.assertEquals("Treppe".hyphenate(), "Trep·pe")
		this.assertEquals("Hütte".hyphenate(), "Hüt·te")
		this.assertEquals("Jacke".hyphenate(), "Ja·cke")
		this.assertEquals("Dusche".hyphenate(), "Du·sche")
		this.assertEquals("Kasten".hyphenate(), "Kas·ten")
		this.assertEquals("Knospe".hyphenate(), "Knos·pe")
		this.assertEquals("Ruder".hyphenate(), "Ru·der")
		this.assertEquals("Paket".hyphenate(), "Pa·ket")
		this.assertEquals("Pakete".hyphenate(), "Pa·ke·te")
		this.assertEquals("Kellner".hyphenate(), "Kell·ner")
		this.assertEquals("Händler".hyphenate(), "Händ·ler")
		this.assertEquals("besuchen".hyphenate(), "be·su·chen")
		this.assertEquals("gewinnen".hyphenate(), "ge·win·nen")
		this.assertEquals("Bauer".hyphenate(), "Bau·er")
		this.assertEquals("Häuser".hyphenate(), "Häu·ser")
		this.assertEquals("Eule".hyphenate(), "Eu·le")
		this.assertEquals("Handtuch".hyphenate(), "Hand·tuch")
		this.assertEquals("Zahnpasta".hyphenate(), "Zahn·pas·ta")
		this.assertTrue(RegExMatch("Signal".hyphenate(), "Sig·nal|Si·gnal"))
		this.assertTrue(RegExMatch("Magnet".hyphenate(), "Mag·net|Ma·gnet"))
		this.assertEquals("Trapperhütte".hyphenate(), "Trap·per·hüt·te")
		this.assertEquals("Trapperhütte".hyphenate(4), "Trap-perhütte")
		this.assertEquals("Trapperhütte".hyphenate(5), "Trap-perhütte")
		this.assertEquals("Trapperhütte".hyphenate(6), "Trap-perhütte")
		this.assertEquals("Trapperhütte".hyphenate(7), "Trapper-hütte")
		this.assertEquals("Trapperhütte".hyphenate(8), "Trapper-hütte")
		this.assertEquals("Trapperhütte".hyphenate(9), "Trapper-hütte")
		this.assertEquals("Trapperhütte".hyphenate(10), "Trapperhüt-te")
		this.assertEquals("Trapperhütte".hyphenate(11), "Trapperhüt-te")
		this.assertException("".base, "hyphenate", "", "", "Trapperhütte", 3)
		this.assertException("".base, "hyphenate", "", "", "Trapperhütte", 99)
		this.assertEquals("Treppe".hyphenate(, "-"), "Trep-pe")
		this.assertEquals("Treppe".hyphenate(, "|"), "Trep|pe")
		this.assertEquals("Treppe".hyphenate(4, "|"), "Trep|pe")
		this.assertException("".base, "hyphenate", "", "", "Vorgartenzwerg-")
	}
}
;}}}

exitapp StringTest.runTests()

; vim: ts=4:sts=4:sw=4:tw=0:noet
