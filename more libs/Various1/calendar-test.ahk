; ahk: console
#NoEnv
#Warn All, StdOut

#Include <testcase-libs>

#Include %A_ScriptDir%\..\calendar.ahk

class CalendarTest extends TestCase {

	@Test_class() {
		this.assertTrue(IsObject(Calendar))
		this.assertTrue(IsObject(Calendar.Units))
		this.assertTrue(IsFunc(Calendar.__New))
		this.assertTrue(IsFunc(Calendar.get))
		this.assertTrue(IsFunc(Calendar.isLeapYear))
		this.assertTrue(IsFunc(Calendar.long))
		this.assertTrue(IsFunc(Calendar.asLong))
		this.assertTrue(IsFunc(Calendar.setAsLong))
		this.assertTrue(IsFunc(Calendar.julian))
		this.assertTrue(IsFunc(Calendar.asJulian))
		this.assertTrue(IsFunc(Calendar.setAsJulian))
		this.assertTrue(IsFunc(Calendar.date))
		this.assertTrue(IsFunc(Calendar.asDate))
		this.assertTrue(IsFunc(Calendar.setAsDate))
		this.assertTrue(IsFunc(Calendar.time))
		this.assertTrue(IsFunc(Calendar.asTime))
		this.assertTrue(IsFunc(Calendar.setAsTime))
		this.assertTrue(IsFunc(Calendar.year))
		this.assertTrue(IsFunc(Calendar.asYear))
		this.assertTrue(IsFunc(Calendar.setAsYear))
		this.assertTrue(IsFunc(Calendar.month))
		this.assertTrue(IsFunc(Calendar.asMonth))
		this.assertTrue(IsFunc(Calendar.setAsMonth))
		this.assertTrue(IsFunc(Calendar.day))
		this.assertTrue(IsFunc(Calendar.asDay))
		this.assertTrue(IsFunc(Calendar.setAsDay))
		this.assertTrue(IsFunc(Calendar.hour))
		this.assertTrue(IsFunc(Calendar.asHour))
		this.assertTrue(IsFunc(Calendar.setAsHour))
		this.assertTrue(IsFunc(Calendar.minutes))
		this.assertTrue(IsFunc(Calendar.asMinutes))
		this.assertTrue(IsFunc(Calendar.setAsMinutes))
		this.assertTrue(IsFunc(Calendar.seconds))
		this.assertTrue(IsFunc(Calendar.asSeconds))
		this.assertTrue(IsFunc(Calendar.setAsSeconds))
		this.assertTrue(IsFunc(Calendar.easterSunday))
		this.assertTrue(IsFunc(Calendar.daysInMonth))
		this.assertTrue(IsFunc(Calendar.dayOfWeek))
		this.assertTrue(IsFunc(Calendar.week))
		this.assertTrue(IsFunc(Calendar.compare))
		this.assertTrue(IsFunc(Calendar.adjust))
		this.assertTrue(IsFunc(Calendar.findWeekDay))
		this.assertTrue(IsFunc(Calendar.formatTime))
		this.assertException(Calendar.Units, "__New")
	}

	@Test_constants() {
		this.assertTrue(Calendar.SUNDAY, 1)
		this.assertTrue(Calendar.MONDAY, 2)
		this.assertTrue(Calendar.TUESDAY, 3)
		this.assertTrue(Calendar.WEDNESDAY, 4)
		this.assertTrue(Calendar.THURSDAY, 5)
		this.assertTrue(Calendar.FRIDAY, 6)
		this.assertTrue(Calendar.SATURDAY, 7)

		this.assertTrue(Calendar.JANUARY, 1)
		this.assertTrue(Calendar.FEBRUARY, 2)
		this.assertTrue(Calendar.MARCH, 3)
		this.assertTrue(Calendar.APRIL, 4)
		this.assertTrue(Calendar.MAY, 5)
		this.assertTrue(Calendar.JUNE, 6)
		this.assertTrue(Calendar.JULY, 7)
		this.assertTrue(Calendar.AUGUST, 8)
		this.assertTrue(Calendar.SEPTEMBER, 9)
		this.assertTrue(Calendar.OCTOBER, 10)
		this.assertTrue(Calendar.NOVEMBER, 11)
		this.assertTrue(Calendar.DECEMBER, 12)
	}

	@Test_classUnits() {
		this.assertEquals(Calendar.Units.SECONDS, "s")
		this.assertEquals(Calendar.Units.SECOND, "s")
		this.assertEquals(Calendar.Units.MINUTES, "m")
		this.assertEquals(Calendar.Units.MINUTE, "m")
		this.assertEquals(Calendar.Units.HOURS, "h")
		this.assertEquals(Calendar.Units.HOUR, "h")
		this.assertEquals(Calendar.Units.DAYS, "D")
		this.assertEquals(Calendar.Units.DAY, "D")
		this.assertTrue(IsFunc(Calendar.Units.isValid))
	}

	@Test_isValidUnit() {
		this.assertTrue(Calendar.Units.isValid(Calendar.Units.SECOND))
		this.assertTrue(Calendar.Units.isValid(Calendar.Units.SECONDS))
		this.assertFalse(Calendar.Units.isValid("x"))
		this.assertFalse(Calendar.Units.isValid(Calendar.Units.isValid))
	}

	@Test_classTimeZone() {
		this.assertTrue(IsObject(TIME_ZONE_INFORMATION))
		this.assertTrue(IsObject(Calendar.TimeZone))
		this.assertTrue(Calendar.TimeZone.__Class = "Calendar.TimeZone")
		this.assertTrue(IsFunc(Calendar.TimeZone.getBias))
		this.assertEquals(new Calendar.TimeZone().bias, -60)
	}

	@Test_helperClass() {
		this.assertTrue(IsObject(CalendarHelper))
		this.assertException(CalendarHelper, "__New")
		this.assertTrue(IsFunc(CalendarHelper.validTime))
	}

	@Test_testForValidYear() {
		this.assertEquals(CalendarHelper.testForValidYear(A_Now), A_Now)
		this.assertException(CalendarHelper, "testForValidYear",,, 1600)
	}

	@Test_testForValidMonth() {
		this.assertEquals(CalendarHelper.testForValidMonth(A_Now), A_Now)
		this.assertEquals(CalendarHelper.testForValidMonth(2019), 201901)
		this.assertException(CalendarHelper, "testForValidMonth",,, 201900)
		this.assertException(CalendarHelper, "testForValidMonth",,, 201913)
	}

	@Test_testForValidDay() {
		this.assertEquals(CalendarHelper.testForValidDay(A_Now), A_Now)
		this.assertEquals(CalendarHelper.testForValidDay(20190812), 20190812)
		this.assertEquals(CalendarHelper.testForValidDay(201908), 20190801)
		this.assertException(CalendarHelper, "testForValidDay",,, 20190800)
		this.assertException(CalendarHelper, "testForValidDay",,, 20190631)
		this.assertException(CalendarHelper, "testForValidDay",,, 20191232)
		this.assertException(CalendarHelper, "testForValidDay",,, 20190229)
	}

	@Test_testForValidHour() {
		this.assertEquals(CalendarHelper.testForValidHour(A_Now), A_Now)
		this.assertEquals(CalendarHelper.testForValidHour(2019081208)
				, 2019081208)
		this.assertEquals(CalendarHelper.testForValidHour(2019081200)
				, 2019081200)
		this.assertEquals(CalendarHelper.testForValidHour(2019081223)
				, 2019081223)
		this.assertException(CalendarHelper, "testForValidHour",,, 2019081224)
	}

	@Test_testForValidMinutes() {
		this.assertEquals(CalendarHelper.testForValidMinutes(A_Now), A_Now)
		this.assertEquals(CalendarHelper.testForValidMinutes(201908120848)
				, 201908120848)
		this.assertEquals(CalendarHelper.testForValidMinutes(201908120859)
				, 201908120859)
		this.assertEquals(CalendarHelper.testForValidMinutes(2019081208)
				, 201908120800)
		this.assertException(CalendarHelper, "testForValidMinutes"
				,,, 201908120860)
	}

	@Test_testForValidSeconds() {
		this.assertEquals(CalendarHelper.testForValidSeconds(A_Now), A_Now)
		this.assertEquals(CalendarHelper.testForValidSeconds(20190812084836)
				, 20190812084836)
		this.assertEquals(CalendarHelper.testForValidSeconds(20190812085900)
				, 20190812085900)
		this.assertEquals(CalendarHelper.testForValidSeconds(20190812085959)
				, 20190812085959)
		this.assertEquals(CalendarHelper.testForValidSeconds(201908120859)
				, 20190812085900)
		this.assertException(CalendarHelper, "testForValidSeconds"
				,,, 20190812085160)
	}

	@Test_returnMaxDaysForFebruary() {
		this.assertEquals(CalendarHelper.returnMaxDaysForFebruary(2019), 28)
		this.assertEquals(CalendarHelper.returnMaxDaysForFebruary(2020), 29)
		this.assertEquals(CalendarHelper.returnMaxDaysForFebruary(2100), 28)
	}

	@Test_CalendarHelper_daysInMonth() {
		this.assertEquals(CalendarHelper.daysInMonth(201901, 01), 31)
		this.assertEquals(CalendarHelper.daysInMonth(201902, 02), 28)
		this.assertEquals(CalendarHelper.daysInMonth(201903, 03), 31)
		this.assertEquals(CalendarHelper.daysInMonth(201904, 04), 30)
		this.assertEquals(CalendarHelper.daysInMonth(201905, 05), 31)
		this.assertEquals(CalendarHelper.daysInMonth(201906, 06), 30)
		this.assertEquals(CalendarHelper.daysInMonth(201907, 07), 31)
		this.assertEquals(CalendarHelper.daysInMonth(201908, 08), 31)
		this.assertEquals(CalendarHelper.daysInMonth(201909, 09), 30)
		this.assertEquals(CalendarHelper.daysInMonth(201910, 10), 31)
		this.assertEquals(CalendarHelper.daysInMonth(201911, 11), 30)
		this.assertEquals(CalendarHelper.daysInMonth(201912, 12), 31)
		this.assertEquals(CalendarHelper.daysInMonth(202002, 02), 29)
		this.assertEquals(CalendarHelper.daysInMonth(210002, 02), 28)
	}

	@Test_testForValidInteger() {
		this.assertTrue(CalendarHelper.testForValidInteger(0))
		this.assertTrue(CalendarHelper.testForValidInteger(123))
		this.assertTrue(CalendarHelper.testForValidInteger(-123))
		this.assertException(CalendarHelper, "testForValidInteger",,, "abc")
	}

	@Test_testForValidNumber() {
		this.assertTrue(CalendarHelper.testForValidNumber(0))
		this.assertTrue(CalendarHelper.testForValidNumber(123))
		this.assertTrue(CalendarHelper.testForValidNumber(-123))
		this.assertTrue(CalendarHelper.testForValidNumber(123.))
		this.assertTrue(CalendarHelper.testForValidNumber(-123.))
		this.assertTrue(CalendarHelper.testForValidNumber(123.0))
		this.assertTrue(CalendarHelper.testForValidNumber(123.9))
		this.assertTrue(CalendarHelper.testForValidNumber(123.456))
		this.assertTrue(CalendarHelper.testForValidNumber(-123.456))
		this.assertTrue(CalendarHelper.testForValidNumber(.456))
		this.assertTrue(CalendarHelper.testForValidNumber(-.456))
		this.assertTrue(CalendarHelper.testForValidNumber(-0.456))
		this.assertTrue(CalendarHelper.testForValidNumber(+123.456))
		this.assertTrue(CalendarHelper.testForValidNumber(-.0))
		this.assertTrue(CalendarHelper.testForValidNumber(-0.))
		this.assertException(CalendarHelper, "testForValidNumber",,, "abc")
		this.assertException(CalendarHelper, "testForValidNumber",,, "-1,5")
	}

	@Test_testForValidWeekDay() {
		loop 7 {
			this.assertTrue(CalendarHelper.testForValidWeekDay(A_Index))
		}
		this.assertException(CalendarHelper, "testForValidWeekDay",,, 0)
		this.assertException(CalendarHelper, "testForValidWeekDay",,, 8)
	}

	@Test_adjustMonthAndHandleUnderFlowOrOverFlow() {
		ts := new Calendar("20190121")
		CalendarHelper.adjustMonthAndHandleUnderFlowOrOverFlow(ts, -1)
		this.assertEquals(ts.asDate(), "20181221")
		CalendarHelper.adjustMonthAndHandleUnderFlowOrOverFlow(ts, 1)
		this.assertEquals(ts.asDate(), "20190121")
		CalendarHelper.adjustMonthAndHandleUnderFlowOrOverFlow(ts, 1)
		this.assertEquals(ts.asDate(), "20190221")
		CalendarHelper.adjustMonthAndHandleUnderFlowOrOverFlow(ts, 6)
		this.assertEquals(ts.asDate(), "20190821")
		CalendarHelper.adjustMonthAndHandleUnderFlowOrOverFlow(ts, 10)
		this.assertEquals(ts.asDate(), "20200621")
	}

	@Test_findNextOrFirstOccurenceOfWeekDay() {
		this.assertTrue(CalendarHelper.findNextOrFirstOccurenceOfWeekDay(0))
		this.assertTrue(CalendarHelper.findNextOrFirstOccurenceOfWeekDay(0.1))
		this.assertTrue(CalendarHelper.findNextOrFirstOccurenceOfWeekDay(0.5))
		this.assertTrue(CalendarHelper.findNextOrFirstOccurenceOfWeekDay(1))
		this.assertTrue(CalendarHelper.findNextOrFirstOccurenceOfWeekDay(3))
		this.assertFalse(CalendarHelper.findNextOrFirstOccurenceOfWeekDay(-.1))
		this.assertFalse(CalendarHelper.findNextOrFirstOccurenceOfWeekDay(-.9))
		this.assertFalse(CalendarHelper.findNextOrFirstOccurenceOfWeekDay(-1))
		this.assertFalse(CalendarHelper.findNextOrFirstOccurenceOfWeekDay(-3))
	}

	@Test_new() {
		this.assertException(Calendar, "__new", "", "", "text")
		this.assertException(Calendar, "__new", "", "", "2012.05.31")
		this.assertException(Calendar, "__new", "", "", 123)
		this.assertException(Calendar, "__new", "", "", 1600)
		this.assertException(Calendar, "__new", "", "", 201200)
		this.assertException(Calendar, "__new", "", "", 201213)
		this.assertException(Calendar, "__new", "", "", 201299)
		this.assertException(Calendar, "__new", "", "", 20120100)
		this.assertException(Calendar, "__new", "", "", 2012010124)
		this.assertException(Calendar, "__new", "", "", 201201012360)
		this.assertException(Calendar, "__new", "", "", 20120101235960)
		this.assertEquals(new Calendar(1601).get(), 16010101000000)
		this.assertEquals(new Calendar(1969).get(), 19690101000000)
		this.assertEquals(new Calendar(196903).get(), 19690301000000)
		this.assertEquals(new Calendar(19690313).get(), 19690313000000)
		this.assertEquals(new Calendar(1969031307).get(), 19690313070000)
		this.assertEquals(new Calendar(196903130720).get(), 19690313072000)
		this.assertEquals(new Calendar(20120229).get(), 20120229000000)
		this.assertEquals(new Calendar(20000229).get(), 20000229000000)
		this.assertEquals(new Calendar(ts := A_Now).get(), ts)
	}

	@Test_isLeapYear() {
		this.assertTrue(new Calendar(2000).isLeapYear())
		this.assertFalse(new Calendar(2010).isLeapYear())
		this.assertFalse(new Calendar(2011).isLeapYear())
		this.assertTrue(new Calendar(2012).isLeapYear())
		this.assertFalse(new Calendar(2013).isLeapYear())
		this.assertFalse(new Calendar(2014).isLeapYear())
		this.assertFalse(new Calendar(2015).isLeapYear())
		this.assertTrue(new Calendar(2016).isLeapYear())
		this.assertFalse(new Calendar(2100).isLeapYear())
	}

	@Test_setAsLong() {
		this.assertEquals(new Calendar().setAsLong(-25377000).get()
				, 19690313065000)
		this.assertEquals(new Calendar().setAsLong(1271374609).get()
				, 20100415233649)
	}

	@Test_aslong() {
		this.assertEquals(new Calendar(19690313065000).asLong(), -25377000)
		this.assertEquals(new Calendar(20100415233649).asLong(), 1271374609)
	}

	@Test_asJulian() {
		this.assertEquals(new Calendar(20120612).asJulian(), 164)
	}

	@Test_setAsJulian() {
		this.assertEquals(new Calendar(20120101).setAsJulian(164).get()
				, 20120612000000)
		this.assertEquals(new Calendar(201201011724).setAsJulian(164).get()
				, 20120612172400)
		this.assertEquals(new Calendar(2013).setAsJulian(164).get()
				, 20130613000000)
		this.assertException(new Calendar(), "setAsJulian",,, "abc")
		this.assertException(new Calendar(), "setAsJulian",,, 999)
	}

	@Test_asDate() {
		this.assertEquals(new Calendar(196903130650).asDate(), 19690313)
	}

	@Test_setAsDate() {
		this.assertEquals(new Calendar(20100415233649).setAsDate(19690313).get()
				, 19690313233649)
		this.assertEquals(new Calendar(20100415233649).setAsDate(196903).get()
				, 19690301233649)
		this.assertEquals(new Calendar(20100415233649).setAsDate(1969).get()
				, 19690101233649)
		this.assertException(new Calendar(), "setAsDate",,, "abc")
	}

	@Test_asTime() {
		this.assertEquals(new Calendar(19690313065019).asTime(), 065019)
	}

	@Test_setAsTime() {
		this.assertEquals(new Calendar(19690313065019).setAsTime(123647).get()
				, 19690313123647)
		this.assertEquals(new Calendar(19690313065019).setAsTime(1236).get()
				, 19690313123600)
		this.assertEquals(new Calendar(19690313065019).setAsTime(12).get()
				, 19690313120000)
		this.assertException(new Calendar(), "setAsTime",,, "abc")
	}

	@Test_asYear() {
		this.assertEquals(new Calendar(19690313065019).asYear(), 1969)
	}

	@Test_setAsYear() {
		this.assertEquals(new Calendar(19690313065019).setAsYear(2012).get()
				, 20120313065019)
		this.assertException(new Calendar(), "setAsYear",,, "abc")
	}

	@Test_asMonth() {
		this.assertEquals(new Calendar(19690313065019).asMonth(), 3)
	}

	@Test_setAsMonth() {
		this.assertEquals(new Calendar(19690313065019).setAsMonth(12).get()
				, 19691213065019)
		this.assertEquals(new Calendar(19690313065019).setAsMonth(9).get()
				, 19690913065019)
		this.assertException(new Calendar(), "setAsMonth", "", "", 13)
	}

	@Test_asDay() {
		this.assertEquals(new Calendar(19690313065019).asDay(), 13)
		this.assertEquals(new Calendar(19690313065019).setAsDay(19).get()
				, 19690319065019)
		this.assertEquals(new Calendar(19690313065019).setAsDay(9).get()
				, 19690309065019)
		this.assertException(new Calendar(), "setAsDay",,, "abc")
	}

	@Test_setAsDay() {
		this.assertEquals(new Calendar(19690313065019).setAsDay(19).get()
				, 19690319065019)
		this.assertEquals(new Calendar(19690313065019).setAsDay(9).get()
				, 19690309065019)
		this.assertException(new Calendar(), "setAsDay",,, "abc")
	}

	@Test_asHour() {
		this.assertEquals(new Calendar(19690313065019).asHour(), 6)
	}

	@Test_setAsHour() {
		this.assertEquals(new Calendar(19690313065019).setAsHour(12).get()
				, 19690313125019)
		this.assertEquals(new Calendar(19690313065019).setAsHour(9).get()
				, 19690313095019)
		this.assertException(new Calendar(), "setAsHour",,, "abc")
	}

	@Test_asMinutes() {
		this.assertEquals(new Calendar(19690313065019).asMinutes(), 50)
	}

	@Test_setAsMinutes() {
		this.assertEquals(new Calendar(19690313065019).setAsMinutes(33).get()
				, 19690313063319)
		this.assertEquals(new Calendar(19690313065019).setAsMinutes(9).get()
				, 19690313060919)
		this.assertException(new Calendar(), "setAsMinutes",,, "abc")
	}

	@Test_asSeconds() {
		this.assertEquals(new Calendar(19690313065019).asSeconds(), 19)
	}

	@Test_setAsSeconds() {
		this.assertEquals(new Calendar(19690313065019).setAsSeconds(24).get()
				, 19690313065024)
		this.assertEquals(new Calendar(19690313065019).setAsSeconds(9).get()
				, 19690313065009)
		this.assertException(new Calendar(), "setAsSeconds",,, "abc")
	}

	@Test_SetDateAndTime() {
		this.assertEquals(new Calendar(19690313065019)
				.setAsYear(2006)
				.setAsMonth(12)
				.setAsDay(19)
				.setAsHour(12)
				.setAsMinutes(56)
				.setAsSeconds(38).get(), 20061219125638)
	}

	@Test_dayOfWeek() {
		this.assertEquals(new Calendar(20120611).dayOfWeek(), Calendar.MONDAY)
		this.assertEquals(new Calendar(19690313).dayOfWeek(), Calendar.THURSDAY)
	}

	@Test_week() {
		this.assertEquals(new Calendar(20120611).week(), 24)
		this.assertEquals(new Calendar(2012).week(), 52)
	}

	@Test_daysInMonth() {
		this.assertEquals(new Calendar(201201).daysInMonth(), 31)
		this.assertEquals(new Calendar(201202).daysInMonth(), 29)
		this.assertEquals(new Calendar(201203).daysInMonth(), 31)
		this.assertEquals(new Calendar(201204).daysInMonth(), 30)
		this.assertEquals(new Calendar(201205).daysInMonth(), 31)
		this.assertEquals(new Calendar(201206).daysInMonth(), 30)
		this.assertEquals(new Calendar(201207).daysInMonth(), 31)
		this.assertEquals(new Calendar(201208).daysInMonth(), 31)
		this.assertEquals(new Calendar(201209).daysInMonth(), 30)
		this.assertEquals(new Calendar(201210).daysInMonth(), 31)
		this.assertEquals(new Calendar(201211).daysInMonth(), 30)
		this.assertEquals(new Calendar(201212).daysInMonth(), 31)
		this.assertEquals(new Calendar(201102).daysInMonth(), 28)
		this.assertException(CalendarHelper, "daysInMonth",,, "abc")
	}

	@Test_easterSunday() {
		this.assertTrue(IsObject(new Calendar(1954).easterSunday()))
		this.assertEquals(new Calendar(1954).easterSunday().__Class, "Calendar")
		this.assertEquals(new Calendar(1954).easterSunday().get()
				, 19540418000000)
		this.assertEquals(new Calendar(1981).easterSunday().get()
				, 19810419000000)
		this.assertEquals(new Calendar(2009).easterSunday().get()
				, 20090412000000)
		this.assertEquals(new Calendar(2010).easterSunday().get()
				, 20100404000000)
		this.assertEquals(new Calendar(2011).easterSunday().get()
				, 20110424000000)
		this.assertEquals(new Calendar(2012).easterSunday().get()
				, 20120408000000)
		this.assertEquals(new Calendar(2013).easterSunday().get()
				, 20130331000000)
	}

	@Test_compare() {
		c1 := new Calendar()
		this.assertEquals(c1.compare(c1), 0)
		this.assertException(c1, "Compare", "", "", c1, "invalidunit")
		this.assertException(c1, "Compare", "", "", c1, Calendar.Units.SECONDS
				, "nonumber")
		this.assertEquals(new Calendar(20100413100703)
				.compare(new Calendar(20100413100711)), 8)
		this.assertEquals(new Calendar(20100413100711)
				.compare(new Calendar(20100413100703)), -8)
		this.assertEquals(new Calendar(20100413100703)
				.compare(new Calendar(20100413100711), Calendar.Units.SECONDS)
				, 8)
		this.assertEquals(new Calendar(20100413100711)
				.compare(new Calendar(20100413101503), Calendar.Units.MINUTES)
				, 7)
		this.assertEquals(new Calendar(20120606)
				.compare(new Calendar(20120605), Calendar.Units.DAYS), -1)
		this.assertEquals(new Calendar(2012060617)
				.compare(new Calendar(2012060513), Calendar.Units.DAYS), -1)
		this.assertEquals(new Calendar(2012060617)
				.compare(new Calendar(2012060513), Calendar.Units.DAYS, 0.2)
				, -1.17)
		this.assertEquals(new Calendar(20120606133600)
				.compare(new Calendar(20120606133630), Calendar.Units.MINUTES
				, 0.2), 0.5)
		this.assertEquals(new Calendar(20120606133600)
				.compare(new Calendar(20120606133645), Calendar.Units.MINUTES
				, 0.2), 0.75)
		this.assertEquals(new Calendar(201206061328)
				.compare(new Calendar(201206061333), Calendar.Units.HOURS, 0.2)
				, 0.08)
		this.assertEquals(new Calendar(201206061200)
				.compare(new Calendar(201206060000), Calendar.Units.DAYS, 0.2)
				, -0.5)
		this.assertEquals(new Calendar(201206061200)
				.compare(new Calendar(201206060000), Calendar.Units.DAYS, 0.2)
				, -0.5)
		this.assertEquals(new Calendar(201206061200)
				.compare(new Calendar(201206060000), Calendar.Units.DAYS, .2)
				, -.5)
		t1 := new Calendar().setAsDate(20171116).setAsTime(0706)
		t2 := new Calendar().setAsDate(20171116).setAsTime(1640)
		this.assertEquals(t1.compare(t2, Calendar.Units.MINUTES), 574)
	}

	@Test_duration() {
		d := Calendar.duration(0)
		this.assertEquals(d[1], 0)
		this.assertEquals(d[2], 0)
		this.assertEquals(d[3], 0)
		this.assertEquals(d[4], 0)
		d := Calendar.duration(1)
		this.assertEquals(d[1], 0)
		this.assertEquals(d[2], 0)
		this.assertEquals(d[3], 0)
		this.assertEquals(d[4], 1)
		d := Calendar.duration(60)
		this.assertEquals(d[1], 0)
		this.assertEquals(d[2], 0)
		this.assertEquals(d[3], 1)
		this.assertEquals(d[4], 0)
		d := Calendar.duration(1041)
		this.assertEquals(d[1], 0)
		this.assertEquals(d[2], 0)
		this.assertEquals(d[3], 17)
		this.assertEquals(d[4], 21)
		d := Calendar.duration(21122017)
		this.assertEquals(d[4] + d[3]*60 + d[2]*3600 + d[1]*86400, 21122017)
	}

	@Test_adjust() {
		this.assertEquals(new Calendar(20130214)
				.adjust(0, -1, 0, 0, 0, 0).get(), 20130114000000)
		this.assertEquals(new Calendar(20130218)
				.adjust(0, -2, 0, 0, 0, 0).get(), 20121218000000)
		this.assertEquals(new Calendar(20130218)
				.adjust(0, -12, 0, 0, 0, 0).get(), 20120218000000)
		this.assertEquals(new Calendar(20130218)
				.adjust(0, -15, 0, 0, 0, 0).get(), 20111118000000)
		this.assertEquals(new Calendar(20130218)
				.adjust(0, -24, 0, 0, 0, 0).get(), 20110218000000)
		this.assertEquals(new Calendar(20130218)
				.adjust(0, -30, 0, 0, 0, 0).get(), 20100818000000)
		this.assertEquals(new Calendar(20130218)
				.adjust(1, -30, 0, 0, 0, 0).get(), 20110818000000)
		this.assertEquals(new Calendar(20130218)
				.adjust(-1, -30, 0, 0, 0, 0).get(), 20090818000000)
		this.assertEquals(new Calendar(20130218)
				.adjust(2, 0, 0, 0, 0, 0).get(), 20150218000000)
		this.assertEquals(new Calendar(20130218)
				.adjust(0, 1, 0, 0, 0, 0).get(), 20130318000000)
		this.assertEquals(new Calendar(20130218)
				.adjust(0, 10, 0, 0, 0, 0).get(), 20131218000000)
		this.assertEquals(new Calendar(20130218)
				.adjust(0, 11, 0, 0, 0, 0).get(), 20140118000000)
		this.assertEquals(new Calendar(20110612093513)
				.adjust(0, 0, 0, 0, 0, 0).get(), 20110612093513)
		this.assertEquals(new Calendar(20110612093513)
				.adjust(0, 0, 0, 0, 0, 5).get(), 20110612093518)
		this.assertEquals(new Calendar(20110612093513)
				.adjust(0, 0, 0, 0, 0, 50).get(), 20110612093603)
		this.assertEquals(new Calendar(20110612093513)
				.adjust(0, 0, 0, 0, 4, 0).get(), 20110612093913)
		this.assertEquals(new Calendar(20110612093513)
				.adjust(0, 0, 0, 0, 133, 0).get(), 20110612114813)
		this.assertEquals(new Calendar(20110612093513)
				.adjust(0, 0, 30, 0, 0, 0).get(), 20110712093513)
		this.assertEquals(new Calendar(20110612093513)
				.adjust(0, 1, 0, 0, 0, 0).get(), 20110712093513)
		this.assertEquals(new Calendar(20110612093513)
				.adjust(1, 1, 1, 1, 1, 1).get(), 20120713103614)
		this.assertEquals(new Calendar(20110612093513)
				.adjust(0, 13, 0, 0, 0, 0).get(), 20120712093513)
		this.assertEquals(new Calendar(20120612)
				.adjust(0, 0, 28, 0, 0, 0).get(), 20120710000000)
		this.assertEquals(new Calendar(20120612)
				.adjust(0, 0, 0, 72, 0, 0).get(), 20120615000000)
		this.assertEquals(new Calendar(20120612)
				.adjust(0, 0, 1, 72, 0, 0).get(), 20120616000000)
		this.assertEquals(new Calendar(20110612)
				.adjust(0, 0, -1, 0, 0, 0).get(), 20110611000000)
		this.assertEquals(new Calendar(20120630)
				.adjust(0, 0, -34, 0, 0, 0).get(), 20120527000000)
		this.assertEquals(new Calendar(20120630)
				.adjust(0, -2, 0, 0, 0, 0).get(), 20120430000000)
		this.assertEquals(new Calendar(20110612)
				.adjust(-3, 0, 0, 0, 0, 0).get(), 20080612000000)
		this.assertEquals(new Calendar(20120630)
				.adjust(0, -2, -34, 0, 0, 0).get(), 20120327000000)
		this.assertEquals(new Calendar(20120327)
				.adjust(0, 2, 34, 0, 0, 0).get(), 20120630000000)
		this.assertEquals(new Calendar(20121231235959)
				.adjust(0, 0, 0, 0, 0, 1).get(), 20130101000000)
		this.assertEquals(new Calendar(20130101000000)
				.adjust(0, 0, 0, 0, 0, -1).get(), 20121231235959)
		this.assertEquals(new Calendar(20130131)
				.adjust(0, 2, 0, 0, 0, 0).get(), 20130331000000)
		this.assertEquals(new Calendar(20130128)
				.adjust(0, 2, 0, 0, 0, 0).get(), 20130328000000)
		this.assertEquals(new Calendar(20130130)
				.adjust(0, 1, 0, 0, 0, 0).get(), 20130228000000)
		this.assertEquals(new Calendar(20130430)
				.adjust(0, -1, 0, 0, 0, 0).get(), 20130330000000)
		this.assertEquals(new Calendar(20130430)
				.adjust(0, -2, 0, 0, 0, 0).get(), 20130228000000)
		this.assertEquals(new Calendar(20130218154534)
				.adjust(1, 2, 3, 4, 5, 6).get(), 20140421195040)
		this.assertEquals(new Calendar(20130218154534)
				.adjust(-1, -2, -3, -4, -5, -6).get(), 20111215114028)
		this.assertEquals(new Calendar(20130218154534)
				.adjust(-1, 2, -3, 4, -5, 6).get(), 20120415194040)
		; this.AssertEquals(new Calendar(20130218154534).adjust(-10, 20, -30, 40, -50, 60).get(), 20040921065634) ; Ergebnis gem. Notes-@adjust
		this.assertEquals(new Calendar(20130218154534)
				.adjust(-10, 20, 0, 0, 0, 0).get(), 20041018154534)
		cal := new Calendar()
		this.assertException(cal, "adjust",,, "abc")
		this.assertException(cal, "adjust",,, 0, "abc")
		this.assertException(cal, "adjust",,, 0, 0, "abc")
		this.assertException(cal, "adjust",,, 0, 0, 0, "abc")
		this.assertException(cal, "adjust",,, 0, 0, 0, 0, "abc")
		this.assertException(cal, "adjust",,, 0, 0, 0, 0, 0, "abc")
	}

	@Test_findWeekDay() {
		this.assertEquals(new Calendar(20120613)
				.findWeekDay(Calendar.THURSDAY).get(), 20120614000000)
		this.assertEquals(new Calendar(20120613)
				.findWeekDay(Calendar.SATURDAY).asDay(), 16)
		this.assertEquals(new Calendar(20120612)
				.findWeekDay().asDay(), 17)
		this.assertEquals(new Calendar(20120612)
				.findWeekDay(Calendar.MONDAY).asDay(), 18)
		this.assertEquals(new Calendar(20120613)
				.findWeekDay(Calendar.MONDAY).asDay(), 18)
		this.assertEquals(new Calendar(20120617)
				.findWeekDay(Calendar.MONDAY).asDay(), 18)
		this.assertEquals(new Calendar(20120613)
				.findWeekDay(Calendar.WEDNESDAY).get(), 20120620000000)
		this.assertEquals(new Calendar(20120613)
				.findWeekDay(Calendar.TUESDAY, Calendar.FIND_RECENT).get()
				, 20120612000000)
		this.assertEquals(new Calendar(20120613)
				.findWeekDay(Calendar.MONDAY, Calendar.FIND_RECENT).asDay(), 11)
		this.assertEquals(new Calendar(20120613)
				.findWeekDay(Calendar.SUNDAY, Calendar.FIND_RECENT).asDay(), 10)
		this.assertEquals(new Calendar(20120613)
				.findWeekDay(Calendar.WEDNESDAY, Calendar.FIND_RECENT).asDay()
				, 6)
		this.assertEquals(new Calendar(20120630)
				.findWeekDay(Calendar.SUNDAY, Calendar.FIND_RECENT).asDay(), 24)
		this.assertEquals(new Calendar(201206)
				.findWeekDay().asDay(), 3)										; Erster Sonntag im Juni 2012
		this.assertEquals(new Calendar(201206)
				.findWeekDay(Calendar.MONDAY).asDay(), 4)						; Erster Montag im Juni 2012
		this.assertEquals(new Calendar(201206)
				.findWeekDay(Calendar.SUNDAY, -1).asDay(), 24)					; Letzter Sonntag im Juni 2012
		this.assertEquals(new Calendar(201206)
				.findWeekDay(Calendar.SATURDAY, -1).asDay(), 30)				; Letzter Samstag im Juni 2012
		this.assertEquals(new Calendar(201206)
				.findWeekDay(Calendar.MONDAY, -1).asDay(), 25)					; Letzter Montag im Juni 2012
		this.assertEquals(new Calendar(201206)
				.findWeekDay(Calendar.SUNDAY, -2).asDay(), 17)					; Vorletzter Sonntag im Juni 2012
		this.assertEquals(new Calendar(201206)
				.findWeekDay(Calendar.SUNDAY, -3).asDay(), 10)					; Drittletzter Sonntag im Juni 2012
		this.assertEquals(new Calendar(201206)
				.findWeekDay(Calendar.SUNDAY, -4).asDay(), 3)					; Viertletzter Sonntag im Juni 2012
		this.assertEquals(new Calendar(201206)
				.findWeekDay(Calendar.SUNDAY, -5).asDate(), 20120527)			; Fünftletzter Sonntag im Juni 2012 (gibt es nicht!)
		this.assertEquals(new Calendar(201307)
				.findWeekDay(Calendar.MONDAY, 1).asDay(), 1)					; 1. Montag im Juli 2013
		this.assertEquals(new Calendar(201307)
				.findWeekDay(Calendar.MONDAY, 2).asDay(), 8)					; 2. Montag im Juli 2013
		this.assertEquals(new Calendar(201307)
				.findWeekDay(Calendar.MONDAY, 3).asDay(), 15)					; 3. Montag im Juli 2013
		this.assertEquals(new Calendar(201307)
				.findWeekDay(Calendar.MONDAY, 4).asDay(), 22)					; 4. Montag im Juli 2013
		this.assertEquals(new Calendar(201307)
				.findWeekDay(Calendar.MONDAY, 5).asDay(), 29)					; 5. Montag im Juli 2013
		this.assertEquals(new Calendar(201307)
				.findWeekDay(Calendar.MONDAY, 6).asDate(), 20130805)			; 6. Montag im Juli 2013 (gibt es nicht!)
		cal := new Calendar()
		this.assertException(cal, "findWeekDay",,, "abc")
		this.assertException(cal, "findWeekDay",,, 1, "abc")
		this.assertException(cal, "findWeekDay",,, 0)
		this.assertException(cal, "findWeekDay",,, 8)
	}

	@Test_formatTime() {
		this.assertEquals(new Calendar(201311151325)
				.formatTime(), "13:25 Freitag, 15. November 2013")
		this.assertEquals(new Calendar(201311151325)
				.formatTime("ShortDate"), "15.11.2013")
		this.assertEquals(new Calendar(201311151325)
				.formatTime("Time"), "13:25")
		this.assertEquals(new Calendar(20131115132517)
				.formatTime("Time"), "13:25")
		this.assertEquals(new Calendar(20131115132517)
				.formatTime("dd.MM.yyyy HH:mm:ss"), "15.11.2013 13:25:17")
	}
}

exitapp CalendarTest.runTests()
