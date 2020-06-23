; ahk: console
#NoEnv
#Warn All, StdOut
SetBatchLines -1

#Include <testcase-libs>

#Include %A_ScriptDir%\..\cron.ahk

class CronTest extends TestCase {

	requires() {
		return [TestCase, Cron]
	}

	cron_tab := []

	@Test_Class() {
		this.assertTrue(IsFunc(Cron.__New))
		this.assertException(Cron, "__New")
	}

	@Test_Value2Expr() {
		this.assertEquals(Cron.value2Expr(5), "0*5")
		this.assertEquals(Cron.value2Expr(15), "0*15")
		this.assertEquals(Cron.value2Expr("05"), "0*5")
	}

	@Test_Range2List() {
		this.assertEquals(Cron.range2List("*", 1, 7), "*")
		this.assertEquals(Cron.range2List("2-5", 1, 7), "2,3,4,5")
		this.assertEquals(Cron.range2List("0-12", 0, 23)
				, "0,1,2,3,4,5,6,7,8,9,10,11,12")
		this.assertEquals(Cron.range2List("1/2", 1, 12), "1,3,5,7,9,11")
	}

	@Test_ParseEntry() {
		this.assertEquals(Cron.parseEntry("* * * * *", "Dummy")
				, "* * * * * Dummy")
		this.assertEquals(Cron.parseEntry("0-59 0-23 1-31 1-12 1-7", "Dummy")
				, "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31 1,2,3,4,5,6,7,8,9,10,11,12 1,2,3,4,5,6,7 Dummy") ; ahklint-ignore: W002
		this.assertEquals(Cron.parseEntry("0/15 * * * *", "Dummy")
				, "0,15,30,45 * * * * Dummy")
		this.assertEquals(Cron.parseEntry("* * 5-31/10 * *", "Dummy")
				, "* * 5,15,25 * * Dummy")
		this.assertEquals(Cron.parseEntry("0/5 * * * *", "Dummy")
				, "0,5,10,15,20,25,30,35,40,45,50,55 * * * * Dummy")
		this.assertEquals(Cron.parseEntry("0/5 6-17 * * 2-6", "Dummy")
				, "0,5,10,15,20,25,30,35,40,45,50,55 6,7,8,9,10,11,12,13,14,15,16,17 * * 2,3,4,5,6 Dummy") ; ahklint-ignore: W002
		this.assertEquals(Cron.parseEntry("0/2 * * * *", "Dummy")
				, "0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58 * * * * Dummy") ; ahklint-ignore: W002
		this.assertEquals(Cron.parseEntry("1/2 * * * *", "Dummy")
				, "1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41,43,45,47,49,51,53,55,57,59 * * * * Dummy") ; ahklint-ignore: W002
		this.assertEquals(Cron.parseEntry("3/13 * * * *", "Dummy")
				, "3,16,29,42,55 * * * * Dummy")
		this.assertEquals(Cron.parseEntry("5,35 3/4 * * *", "Dummy")
				, "5,35 3,7,11,15,19,23 * * * Dummy")
		this.assertEquals(Cron.parseEntry("5/30 3/4 * * *", "Dummy")
				, "5,35 3,7,11,15,19,23 * * * Dummy")
		this.assertException(Cron, "ParseEntry", "", ""
				, "30 21 7 19 *", "Dummy")
	}

	@Test_AddScheduler() {
		Cron.reset()
		Cron.addScheduler("* * * * *", "Dummy")
		Cron.addScheduler("0/2 * * * *", "Dummy2")
		Cron.addScheduler("0/5 * * * *", "Dummy5")
		Cron.addScheduler("1/15 * * * *", "Dummy15")
		this.assertEquals(Cron.cron_tab, "`n1:* * * * * Dummy`n2:0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58 * * * * Dummy2`n3:0,5,10,15,20,25,30,35,40,45,50,55 * * * * Dummy5`n4:1,16,31,46 * * * * Dummy15`n") ; ahklint-ignore: W002
		this.assertEquals(Cron.cron_job_num, 4)
		Cron.start()
		Cron.stop()
	}

	@Test_PatternHelper() {
		this.assertEquals(PatternHelper(6, 10), "6,16,26,36,46,56")
		this.assertEquals(PatternHelper(7, 11), "7,18,29,40,51")
		this.assertEquals(PatternHelper(31, 30), "1,31")
		this.assertEquals(PatternHelper(48, 3)
				, "0,3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48,51,54,57")
		this.assertEquals(PatternHelper(0, 10), "0,10,20,30,40,50")
	}

	@Test_AddScheduler2() {
		Cron.reset()
		p1 := PatternHelper(m := A_Min, 10)
		Cron.addScheduler("*/10 * * * *", "Dummy")
		p2 := PatternHelper(m := A_Min, 7)
		Cron.addScheduler("*/7 * * * *", "Dummy")
		p3 := PatternHelper(m := A_Min, 30)
		Cron.addScheduler("*/30 * * * *", "Dummy")
		p4 := PatternHelper(h := A_Hour, 5, 24)
		Cron.addScheduler("0 */5 * * *", "Dummy")
		this.assertEquals(Cron.cron_tab, "`n1:"
				. p1 " * * * * Dummy`n2:"
				. p2 " * * * * Dummy`n3:"
				. p3 " * * * * Dummy`n4:0 "
				. p4 " * * * Dummy`n")
	}
}

dummy(n) {
	OutputDebug Dummy [%n%] %A_Min%'
}

dummy2(n) {
	OutputDebug Dummy 2 [%n%] %A_Min%'
}

dummy5(n) {
	OutputDebug Dummy 5 [%n%] %A_Min%'
}

patternHelper(m, i, max=60) {
	OutputDebug m=%m% i=%i% max=%max%
	m := Mod(m, i)
	; OutputDebug m=%m%
	list := ""
	while (m < max) {
		list .= (list = "" ? "" : ",") m
		m+=i
	}

	OutputDebug list=%list%
	return list
}

cronTetRetVal := CronTest.runTests()

; Sleep 120000

exitapp cronTetRetVal
