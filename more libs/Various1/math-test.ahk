; ahk: console
#NoEnv
#Warn All, StdOut

#Include <ansi>
#Include <arrays>
#Include <console>
#Include <datatable>
#Include <object>
#Include <string>
#Include <testcase>

#Include %A_ScriptDir%\..\math.ahk

class MathTest extends TestCase {

	@Test_mathClass() {
		this.assertTrue(IsFunc(Math.swap))
		this.assertTrue(IsFunc(Math.floor))
		this.assertTrue(IsFunc(Math.ceil))
		this.assertTrue(IsFunc(Math.limitTo))
		this.assertTrue(IsFunc(Math.isEven))
		this.assertTrue(IsFunc(Math.isOdd))
		this.assertTrue(IsFunc(Math.root))
		this.assertTrue(IsFunc(Math.log))
		this.assertTrue(IsFunc(Math.isPrime))
		this.assertTrue(IsFunc(Math.integerFactorization))
		this.assertTrue(IsFunc(Math.greatestCommonDivisor))
		this.assertTrue(IsFunc(Math.lowestCommonMultiple))
		this.assertTrue(IsFunc(Math.isFractional))
		this.assertTrue(IsFunc(Math.zeroFillShiftR))
		this.assertTrue(IsFunc(Math.numberOfTrailingZeros))
		this.assertTrue(IsFunc(Math.numberOfLeadingZeros))
		this.assertTrue(IsFunc(Math.bitCount))
		this.assertTrue(IsFunc("S"))
		this.assertTrue(IsFunc("I"))
		this.assertTrue(IsFunc("L"))
	}

	@Test_new() {
		this.assertException(Math, "__new")
		this.assertException(MathHelper, "__new")
	}

	@Test_constants() {
		this.assertEquals(Math.MIN_LONG, -0x8000000000000000)
		this.assertEquals(Math.MAX_LONG,  0x7FFFFFFFFFFFFFFF)
		this.assertEquals(Math.MIN_INT, -0x80000000)
		this.assertEquals(Math.MAX_INT,  0x7FFFFFFF)
		this.assertEquals(Math.MIN_SHORT, -0x8000)
		this.assertEquals(Math.MAX_SHORT, 0x7FFF)
	}

	@Test_swap() {
		Math.swap(a := "a", b := "b")
		this.assertTrue(a == "b" && b == "a")
		Math.swap(a := -5, b := 133)
		this.assertTrue(a = 133 && b = -5)
		Math.swap(a := 15, b := 15)
		this.assertTrue(a = 15 && b = 15)
		Math.swap(a := 123, b := 123)
		this.assertTrue(a = 123 && b = 123)
	}

	@Test_ceilAndFloor() {
		this.assertException(Math , "floor")
		this.assertException(Math , "ceil")
		this.assertEquals(Math.floor(13, 3), 3)
		this.assertEquals(Math.floor(-50, 0), -50)
		this.assertEquals(Math.floor(-50, 0, -50.01), -50.01)
		this.assertEquals(Math.ceil(-50, 0, -50.01), 0)
		this.assertEquals(Math.floor(1.3, 2.1, 1.1, 2.9), 1.1)
		this.assertEquals(Math.ceil(1.3, 2.1, 1.1, 2.9), 2.9)
		this.assertEquals(Math.floor([13, 3]), 3)
		this.assertEquals(Math.floor(69, [13, 3], 19), 3)
		this.assertEquals(Math.floor([11,[21,22,23,[24,75,26],9],31]), 9)
		this.assertEquals(Math.ceil([11,[21,22,23,[24,75,26],29],31]), 75)
		this.assertEquals(Math.ceil(x := 5), 5)
		this.assertEquals(Math.floor(x := 4), 4)
		this.assertException(Math, "floor",,, [13, "vier", 3])
		this.assertEquals(MathHelper.floorCeil("floor", 100, 99), 99)
		this.assertEquals(MathHelper.floorCeil("ceil", 99, 100), 100)
	}

	@Test_min() {
		this.assertEquals(Math.min(), "")
		this.assertEquals(Math.min(5), 5)
		this.assertEquals(Math.min(13, 3), 3)
		this.assertEquals(Math.min(-50, 0), -50)
		this.assertEquals(Math.min(-50, 0, -50.01), -50.01)
		this.assertEquals(Math.min(1.3, 2.1, 1.1, 2.9), 1.1)
		this.assertEquals(Math.min([13, 3]), 3)
		this.assertEquals(Math.min(69, [13, 3], 19), 3)
		this.assertEquals(Math.min([11,[21,22,23,[24,75,26],9],31]), 9)
		this.assertEquals(Math.min(x := 4), 4)
	}

	@Test_max() {
		this.assertEquals(Math.max(-50, 0, -50.01), 0)
		this.assertEquals(Math.max(1.3, 2.1, 1.1, 2.9), 2.9)
		this.assertEquals(Math.max([11,[21,22,23,[24,75,26],29],31]), 75)
		this.assertEquals(Math.max(x := 5), 5)
	}

	@Test_limitTo() {
		this.assertEquals(Math.limitTo(7, 3, 13), 7)
		this.assertEquals(Math.limitTo(0, 3, 13), 3)
		this.assertEquals(Math.limitTo(100, 3, 13), 13)
	}

	@Test_oddEven() {
		this.assertException(Math, "isEven", "", "", "text")
		this.assertException(Math, "isOdd", "", "", "text")
		this.assertTrue(Math.isEven(2))
		this.assertFalse(Math.isEven(3))
		this.assertFalse(Math.isOdd(2))
		this.assertTrue(Math.isOdd(3))
	}

	@Test_root() {
		this.assertException(Math, "root", "", "", 5, "text")
		this.assertException(Math, "root", "", "", "text", 2476099)
		this.assertException(Math, "root", "", "", "text", "text")
		; this.assertEquals(Math.root(5, 2476099), 19.000000000000004)
		this.assertEquals(Math.root(5, 2476099), 19.0)
		this.assertEquals(Math.root(3, 27), 3)
	}

	@Test_log() {
		this.assertException(Math, "log", "", "", 2, "text")
		this.assertException(Math, "log", "", "", "text", 52)
		this.assertException(Math, "log", "", "", "text", "text")
		this.assertEquals(Math.log(2, 8), 3)
		this.assertEquals(Math.log(2, 52), 5.7004397181410926)
	}

	@Test_prime() {
		this.assertException(Math, "isPrime", "", "", "")
		this.assertException(Math, "isPrime", "", "", "text")
		this.assertFalse(Math.isPrime(1))
		this.assertTrue(Math.isPrime(2))
		this.assertTrue(Math.isPrime(3))
		this.assertTrue(Math.isPrime(7))
		this.assertFalse(Math.isPrime(9))
		this.assertTrue(Math.isPrime(31))
		this.assertTrue(Math.isPrime("31"))
		this.assertFalse(Math.isPrime(469))
		this.assertFalse(Math.isPrime(2047))
		this.assertTrue(Math.isPrime(5987))
		this.assertTrue(Math.isPrime(524287))
		this.assertTrue(Math.isPrime(420618259))
		this.assertTrue(Math.isPrime(2147483647))
	}

	@Test_integerFactorization() {
		this.assertException(Math, "IntegerFactorization", "", "", "text")
		pf := Math.integerFactorization(765).getList()
		this.assertTrue(pf[1] = 3 && pf[2] = 3 && pf[3] = 5 && pf[4] = 17)
		this.assertTrue(IsObject(Math.integerFactorization(3.14)))
		this.assertEquals(Math.integerFactorization(3.14).toString(), 3.14)
		this.assertTrue(IsObject(Math.integerFactorization(3)))
		this.assertEquals(Math.integerFactorization(3).toString(), 3)
		this.assertEquals(Math.integerFactorization(3).count(), 1)
		this.assertEquals(Math.integerFactorization(765).toString(), "3*3*5*17")
		this.assertEquals(Math.integerFactorization(765).count(), 4)
		this.assertEquals(Math.integerFactorization(12).toString(), "2*2*3")
		this.assertEquals(Math.integerFactorization(18).toString(), "2*3*3")
		this.assertEquals(Math.integerFactorization(5986).toString(), "2*41*73")
		this.assertEquals(Math.integerFactorization(6936).toString(true)
				, "2**3*3*17**2")
		this.assertEquals(Math.integerFactorization(420618259).toString()
				, 420618259)
		this.assertEquals(Math.integerFactorization(420618258).toString()
				, "2*3*3*3*3*509*5101")
		this.assertEquals(Math.integerFactorization(420618258)
				.toString(true, "^"), "2*3^4*509*5101")
		this.assertEquals(Math.integerFactorization(420618258).count(), 7)
	}

	@Test_GCD() {
		this.assertException(Math, "greatestCommonDivisor", "", "", "text", 1)
		this.assertException(Math, "greatestCommonDivisor", "", "", 1, "text")
		this.assertEquals(Math.greatestCommonDivisor(12, 18), 6)
		this.assertEquals(Math.greatestCommonDivisor(53667, 459486), 603)
		this.assertEquals(Math.greatestCommonDivisor(643126, 1034922), 82)
		this.assertEquals(Math.greatestCommonDivisor(643126, 1034922, false)
				, 82)
	}

	@Test_LCM() {
		this.assertException(Math, "lowestCommonMultiple", "", "", "text", 1)
		this.assertException(Math, "lowestCommonMultiple", "", "", 1, "text")
		this.assertEquals(Math.lowestCommonMultiple(12, 18), 36)
		this.assertEquals(Math.lowestCommonMultiple(24, 60), 120)
		this.assertEquals(Math.lowestCommonMultiple(1820, 6825), 27300)
	}

	@Test_isFractional() {
		this.assertTrue(Math.isFractional(0.1))
		this.assertTrue(Math.isFractional(1.1))
		this.assertTrue(Math.isFractional(3.1415))
		this.assertTrue(Math.isFractional(-0.1))
		this.assertTrue(Math.isFractional(-3.50))
		this.assertFalse(Math.isFractional(0))
		this.assertFalse(Math.isFractional(1))
		this.assertFalse(Math.isFractional(0.0))
		this.assertFalse(Math.isFractional(130369))
	}

	@Test_I() {
		this.assertEquals(I(0), 0)
		this.assertEquals(I(1), 1)
		this.assertEquals(I(2), 2)
		this.assertEquals(I(-1), -1)
		this.assertEquals(I(-2), -2)
		this.assertEquals(I(Math.MAX_INT), 2147483647)
		this.assertEquals(I(Math.MIN_INT), -2147483648)
		this.assertEquals(I(Math.MIN_INT - 1), Math.MAX_INT)
		this.assertEquals(I(Math.MIN_INT - 1005), 2147482643)
		this.assertEquals(I(-2147484653), 2147482643)
		this.assertEquals(I(Math.MAX_INT + 1), Math.MIN_INT)
		this.assertEquals(I(Math.MAX_INT + 1009), -2147482640)
		this.assertEquals(I(1711276032), 1711276032)
		this.assertEquals(I(3422552064), -872415232)
	}

	@Test_S() {
		this.assertEquals(S(0), 0)
		this.assertEquals(S(1), 1)
		this.assertEquals(S(2), 2)
		this.assertEquals(S(-1), -1)
		this.assertEquals(S(-2), -2)
		this.assertEquals(S(Math.MAX_SHORT + 1), Math.MIN_SHORT)
		this.assertEquals(S(Math.MIN_SHORT - 1), Math.MAX_SHORT)
		this.assertEquals(S(66666), 1130)
	}

	@Test_L() {
		this.assertEquals(L(0), 0)
		this.assertEquals(L(1), 1)
		this.assertEquals(L(2), 2)
		this.assertEquals(L(-1), -1)
		this.assertEquals(L(-2), -2)
		this.assertEquals(L(Math.MAX_LONG + 1), Math.MIN_LONG)
		this.assertEquals(L(Math.MIN_LONG - 1), Math.MAX_LONG)
	}

	@Test_UL() {
		this.assertEquals(UL(-1), Math.MAX_LONG)
	}

	@Test_US() {
		this.assertEquals(US(-1), 0xffff)
	}

	@Test_SL() {
		this.assertEquals(SL(0xffffffffffffffff << -2), -4611686018427387904)
		this.assertEquals(SL(0xffffffffffffffff << -1), -9223372036854775808)
		this.assertEquals(SL(0xffffffffffffffff << 0), -1)
		this.assertEquals(SL(0xffffffffffffffff << 1), -2)
		this.assertEquals(SL(0xffffffffffffffff << 2), -4)
	}

	@Test_zeroFillShiftR() {
		this.assertEquals(Math.zeroFillShiftR(SL(0xffffffffffffffff), -7), 127)
		this.assertEquals(Math.zeroFillShiftR(9223372036854775807, -321), 0)
		this.assertEquals(Math.zeroFillShiftR(9223372036854775807, -320)
				, 9223372036854775807)
		this.assertEquals(Math.zeroFillShiftR(9223372036854775807, -319)
				, 4611686018427387903)
		this.assertEquals(Math.zeroFillShiftR(9223372036854775807, -129), 0)
		this.assertEquals(Math.zeroFillShiftR(9223372036854775807, -128)
				, 9223372036854775807)
		this.assertEquals(Math.zeroFillShiftR(9223372036854775807, -127)
				, 4611686018427387903)
		this.assertEquals(Math.zeroFillShiftR(9223372036854775807, -126)
				, 2305843009213693951)
		this.assertEquals(Math.zeroFillShiftR(9223372036854775807, -66), 1)
		this.assertEquals(Math.zeroFillShiftR(9223372036854775807, -65), 0)
		this.assertEquals(Math.zeroFillShiftR(9223372036854775807, -64)
				, 9223372036854775807)
		this.assertEquals(Math.zeroFillShiftR(5, 1), 2)
		this.assertEquals(Math.zeroFillShiftR(UI(-1), 30), 3)
		this.assertEquals(Math.zeroFillShiftR(UI(-1), 31), 1)
		this.assertEquals(Math.zeroFillShiftR(UI(-2147483648), 31), 1)
		this.assertEquals(Math.zeroFillShiftR(-1, -1), 1)
		this.assertEquals(Math.zeroFillShiftR(-1, -7), 127)
		this.assertEquals(Math.zeroFillShiftR(130369, 0), 130369)
		this.assertEquals(Math.zeroFillShiftR(SL(0xffffffffffffffff), -63)
				, 0xffffffffffffffff)
		this.assertEquals(Math.zeroFillShiftR(SL(0xffffffffffffffff), -64), -1)
		this.assertEquals(Math.zeroFillShiftR(SL(0xffffffffffffffff), -65), 1)
		this.assertEquals(Math.zeroFillShiftR(UL(-1), 47), 65535)
		this.assertEquals(Math.zeroFillShiftR(-1, 48), 65535)
		this.assertEquals(Math.zeroFillShiftR((0 << 1), 31), 0)
	}

	@Test_numberOfTrailingZeros() {
		this.assertEquals(Math.numberOfTrailingZeros(0), 64)
		this.assertEquals(Math.numberOfTrailingZeros(102), 1)
		this.assertEquals(Math.numberOfTrailingZeros(100), 2)
		this.assertEquals(Math.numberOfTrailingZeros(-4294967296), 32)
	}

	@Test_numberOfLeadingZeros() {
		this.assertEquals(Math.numberOfLeadingZeros(0), 64)
		this.assertEquals(Math.numberOfLeadingZeros(102), 57)
		this.assertEquals(Math.numberOfLeadingZeros(1 << 127), 0)
		this.assertEquals(Math.numberOfLeadingZeros(4), 61)
		this.assertEquals(Math.numberOfLeadingZeros(30), 59)
	}

	@Test_bitCount() {
		this.assertEquals(Math.bitCount(0), 0)
		this.assertEquals(Math.bitCount(1), 1)
		this.assertEquals(Math.bitCount(2), 1)
		this.assertEquals(Math.bitCount(3), 2)
		this.assertEquals(Math.bitCount(34809348508034), 23)
	}
}

exitapp MathTest.runTests()
