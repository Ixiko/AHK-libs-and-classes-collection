; ahk: console
#Warn All, MsgBox

#Include <ansi>
#Include <arrays>
#Include <console>
#Include <datatable>
#Include <math>
#Include <string>
#Include <object>

#Include %A_ScriptDir%\..\testcase.ahk

class Money {
	fAmount := 0
	strCurrency := ""

	__New(amount, currency) {
		this.fAmount := amount
		this.strCurrency := currency
	}

	add(poMoney) {
		return new Money(this.fAmount + poMoney.fAmount, this.strCurrency)
	}

	equals(poMoney) {
		if (poMoney != "" && poMoney.__Class = this.__Class) {
			return this.strCurrency = poMoney.strCurrency
					&& this.fAmount = poMoney.fAmount
		}

		return false
	}
}


class MoneyBag {
	fMonies := []

	__New(poMonies*) {
		for i, _money in poMonies {
			this.fMonies.push(_money)
		}
	}

	equals(poMoneyBag) {
		if (this.fMonies.maxIndex() != poMoneyBag.fMonies.maxIndex()) {
			return false
		}

		for i, _money in this.fMonies {
			bFound := false
			loop % poMoneyBag.fMonies.maxIndex() {
				if (_money.equals(poMoneyBag.fMonies[A_Index])) {
					bFound := true
					break
				}
			}
			if (!bFound) {
				return false
			}
		}

		return true
	}
}


class MoneyTest extends TestCase {

	@Before_Setup() {
		global
		f12CHF := new Money(12, "CHF")
		f14CHF := new Money(14, "CHF")
		f7USD  := new Money( 7, "USD")
		f21USD := new Money(21, "USD")
		fMB1 := new MoneyBag(f12CHF, f7USD)
		fMB2 := new MoneyBag(f14CHF, f21USD)
	}

	@Test_MoneyClass() {
		_res := MoneyTest.assertTrue(IsFunc(Money.add))
		MoneyTest.assertEquals(_res, 3)
		_res := MoneyTest.assertTrue(IsFunc(Money.equals))
		MoneyTest.assertEquals(_res, 3)
	}

	@Depend_@Test_SimpleAdd() {
		return "@Test_MoneyClass"
	}

	@Test_SimpleAdd() {
		global f12CHF, f14CHF
		expected := new Money(26, "CHF")
		_res := MoneyTest.assertTrue(expected.equals(f12CHF.add(f14CHF)))
		MoneyTest.assertEquals(_res, true)

	}

	@Test_Equals() {
		global f12CHF, f14CHF
		_res := MoneyTest.assertFalse(f12CHF.equals(""))
		MoneyTest.assertEquals(_res, false)
		_res := MoneyTest.assertSame(f12CHF, f12CHF)
		MoneyTest.assertEquals(_res, true)
		_res := MoneyTest.assertTrue(f12CHF.equals(new Money(12, "CHF")))
		MoneyTest.assertEquals(_res, true)
		_res := MoneyTest.assertFalse(f12CHF.equals(f14CHF))
		MoneyTest.assertEquals(_res, false)
	}

	@Test_Equals_With_Length() {
		this.assertEquals("13", "13")
		this.assertException(this, "AssertEquals", "", "", "13.1", " 13.0")
		this.assertEquals("13", "013")
	}

	@Test_MoneyBagClass() {
		_res := MoneyTest.assertTrue(IsFunc(MoneyBag.equals))
		MoneyTest.assertEquals(_res, 3)
	}

	@Test_BagEquals() {
		global fMB1, fMB2, f12CHF
		_res := MoneyTest.assertFalse(fMB1.equals(""))
		MoneyTest.assertEquals(_res, false)
		_res := MoneyTest.assertSame(fMB1, fMB1)
		MoneyTest.assertEquals(_res, true)
		_res := MoneyTest.assertFalse(fMB1.equals(f12CHF))
		MoneyTest.assertEquals(_res, false)
		_res := MoneyTest.assertFalse(f12CHF.equals(fMB1))
		MoneyTest.assertEquals(_res, false)
		_res := MoneyTest.assertTrue(fMB1.equals(fMB1))
		MoneyTest.assertEquals(_res, true)
		_res := MoneyTest.assertTrue(fMB1.equals(fMB1))
		MoneyTest.assertEquals(_res, true)
	}

	@Depend_@Test_Equals_With_Length() {
		return "@Test_MoneyClass, @Test_SimpleAdd, @Test_Equals"
	}

	@Test_Assertion() {
		if (TestCase.didNotRun("@Test_MoneyClass")) {
			this.fail("@Test_MoneyClass must run")
		}
		x := 0
		this.assertTrue(this.assert(x = 0))
		this.assertException(TestCase, "Assert", "", "", (x != 0))
		this.assertException(TestCase, "Assert", "", "Not valid!", (x != 0)
				, "Not valid!")
	}

	@Test_AssertEqual() {
		this.assertEquals("0123", "0123")
	}
}

exitapp MoneyTest.runTests()
