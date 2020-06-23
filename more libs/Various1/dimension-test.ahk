; ahk: console
#NoEnv
#Warn All, StdOut

#Include <testcase-libs>
#Include %A_ScriptDir%\..\dimension.ahk

class DimensionTest extends TestCase {

	requires() {
		return [TestCase, Dimension]
	}

	@Test_class() {
		this.assertEquals()
	}

	@Test_memory() {
		this.assertEquals(Dimension.Memory.Proper(11240526), "10.7MB")
		this.assertEquals(Dimension.Memory.Proper(11240526, "B", 0.0), "11MB")
	}

	@Test_customUnitsMemory() {
		Dimension.Memory.Units := ["b", "KiB", "MeB", "GiB", "TeB"]
		this.assertEquals(Dimension.Memory.Proper(11240526), "10.7MeB")
		this.assertEquals(Dimension.Memory.Proper(11240526, "B", 0.0), "11MeB")
	}

	@Test_time() {
		d := Dimension.Time.Proper(5, "Min")
		this.assertEquals(d.value, 5)
		this.assertEquals(d.dimension, "Min")
		this.assertEquals(Dimension.Time.ProperString(5, "Min",, "0.0")
				, "5 Min")
		this.assertEquals(Dimension.Time.ProperString(300, "Sek"), "5.0 Min")
	}
}

exitapp DimensionTest.runTests()
