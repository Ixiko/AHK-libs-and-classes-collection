; ahk: console
; ahklint-ignore-begin: W002
#NoEnv
#Warn All, StdOut

#Include <testcase-libs>

#Include %A_ScriptDir%\..\base64.ahk

class Base64Test extends TestCase {

	@Test_Class() {
		this.assertEquals(Base64.CRYPT_STRING_BASE64, 0x00000001)
	}

	@Test_encode() {
		st := "Polyfon zwitschernd aßen Mäxchens Vögel Rüben, Joghurt und Quark"

		l_1252 := strPutVar(st, st_1252, "cp1252")
		this.assertEquals(Base64.encode(st_1252, l_1252)
				, "UG9seWZvbiB6d2l0c2NoZXJuZCBh32VuIE3keGNoZW5zIFb2Z2VsIFL8YmVuLCBKb2dodXJ0IHVuZCBRdWFyaw==")

		l_utf8 := strPutVar(st, st_utf8, "utf-8")
		this.assertEquals(Base64.encode(st_utf8, l_utf8)
				, "UG9seWZvbiB6d2l0c2NoZXJuZCBhw59lbiBNw6R4Y2hlbnMgVsO2Z2VsIFLDvGJlbiwgSm9naHVydCB1bmQgUXVhcms=")

		l := StrPutVar("aov", staov, "cp1252")
		OutputDebug % Base64.encode(staov, l)
	}

	@Test_Decode() {
		st := "Polyfon zwitschernd aßen Mäxchens Vögel Rüben, Joghurt und Quark"

		l_1252 := Base64.decode("UG9seWZvbiB6d2l0c2NoZXJuZCBh32VuIE3keGNoZW5zIFb2Z2VsIFL8YmVuLCBKb2dodXJ0IHVuZCBRdWFyaw=="
				, 0, Base64.CRYPT_STRING_BASE64, st_1252)
		this.assertEquals(StrGet(&st_1252, l_1252, "cp1252"), st)

		l_utf8 := Base64.decode("UG9seWZvbiB6d2l0c2NoZXJuZCBhw59lbiBNw6R4Y2hlbnMgVsO2Z2VsIFLDvGJlbiwgSm9naHVydCB1bmQgUXVhcms= "
				, 0, Base64.CRYPT_STRING_BASE64, st_utf8)
		this.assertEquals(StrGet(&st_utf8, l_utf8, "utf-8"), st)
	}
}

strPutVar(string, ByRef var, encoding) {
	VarSetCapacity(var, StrPut(string, encoding)
			* ((encoding="utf-16"||encoding="cp1200"||encoding="utf-8") ? 2 : 1))
	l := StrPut(string, &var, encoding)
	return l-1
}

exitapp Base64Test.runTests()
; vim: ts=4:sts=4:sw=4:tw=0:noet
