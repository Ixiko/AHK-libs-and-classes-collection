; ahk: console
#NoEnv
SetBatchLines -1
#Warn All, StdOut

#Include <testcase-libs>

#Include %A_ScriptDir%\..\long.ahk

class LongTest extends TestCase {

	@Test_ToUnsignedString() {
		this.assertEquals(Long.toUnsignedString(-102, 1)
				, 18446744073709551514)
		this.assertEquals(Long.toUnsignedString(UL(-102), 1)
				, 18446744073709551514)
	}

	@Test_ToBinaryString() {
		; ahklint-ignore-begin: W002
		this.assertEquals(Long.toBinaryString(102), "1100110")
		this.assertEquals(Long.toBinaryString(0x7fffffffffffffff)
				, "111111111111111111111111111111111111111111111111111111111111111")
		this.assertEquals(Long.toBinaryString(-0x8000000000000000)
				, "1000000000000000000000000000000000000000000000000000000000000000")
		this.assertEquals(Long.toBinaryString(UL(-102))
				, "1111111111111111111111111111111111111111111111111111111110011010")
		; ahklint-ignore-end
	}

	@Test_ToHexString() {
		this.assertEquals(Long.toHexString(102), "66")
		this.assertEquals(Long.toHexString(UL(-102)), "7fffffffffffff9a")
	}

	@Test_ToOctalString() {
		this.assertEquals(Long.toOctalString(102), "146")
		this.assertEquals(Long.toOctalString(UL(-102))
				, "1777777777777777777632")
	}
}

exitapp LongTest.runTests()
