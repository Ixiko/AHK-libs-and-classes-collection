#Include <app>

#Include %A_LineFile%\..\modules\testcase\
#Include TestData.ahk
#Include LoggingHelper.ahk

class TestCase {

	requires() {
		return [DataTable, App]
	}

	static lAPIOverhead := TestCase.initAPIOverhead()
	static lFrequency := TestCase.initFrequency()
	static testOut := TestCase.openTestOutForOutput()

	static duration := 0.0
	static allSuccessfulTestsDuration := 0.0
	static stopOnFirstError := false

	static SUCCESSFUL := 1
	static SUCCESSFUL_SYMBOL := Chr(0x2714)
	static FAILED := 0
	static FAILED_SYMBOL := Chr(0x274c)
	static UNKNOWN := ""
	static NOT_RUN := -1

	static IGNORE_CASE := 1
	static AS_STRING := 2

	static GREEN := "[32m"
	static RED := "[31m"
	static BLUE := "[34m"
	static YELLOW := "[93m"
	static MAGENTA := "[35m"
	static CYAN := "[36m"
	static WHITE := "[97m"
	static RESET := "[0m"

	__new() {
		throw Exception("Instantiation of class '" this.__Class
				. "' ist not allowed", -1)
	}

	openTestOutForOutput() {
		testOut := FileOpen("*", "w `n", "utf-8")
		testOut.read(0)
		return testOut
	}

	initAPIOverhead() {
		DllCall("QueryPerformanceCounter", "Int64 *", start := 0)
		DllCall("QueryPerformanceCounter", "Int64 *", end := 0)
		return end - start
	}

	initFrequency() {
		DllCall("QueryPerformanceFrequency", "Int64 *", freqency := 0)
		return freqency
	}

	runTests(selectedTestNames*) {
		App.checkRequiredClasses(this)
		TestData.testClass := this
		TestCase.handleStopOnFirstError()
		selectedTestNames.push(A_Args*)
		TestCase.selectTests(selectedTestNames*)
		if (TestCase.findTestsAndFixtures(TestData.testClass)) {
			TestCase.runBeforeClassFixtures()
			TestCase.runSelectedTests()
			TestCase.runAfterClassFixtures()
			TestCase.writeTestSummary()
		} else {
			TestCase.writeLine("No tests found")
		}
		TestCase.writeLine("`n")
		TestCase.logTestResultSummaryToDebugOut()
		return TestData.numberOfFailingTests
	}

	handleStopOnFirstError() {
		if (A_Args.maxIndex() != "" && A_Args[A_Args.maxIndex()] == "-S") {
			OutputDebug Halt on first error
			TestCase.stopOnFirstError := true
			A_Args.removeAt(A_Args.length())
		}
	}

	selectTests(selectedTestNames*) {
		while (A_Index <= selectedTestNames.maxIndex()) {
			selectedTestName := selectedTestNames[A_Index]
			OutputDebug Select %selectedTestName%
			TestData.selectedTestNames[selectedTestName] := ""
		}
	}

	findTestsAndFixtures(classToTest) {
		if (classToTest.base) {
			TestCase.findTestsAndFixtures(classToTest.base)
		}
		for classPropertyName, classProperty in classToTest {
			if (IsFunc(classProperty) == 2
					&& RegExMatch(classPropertyName, "i)^@Test.+")) {
				TestCase.addTest(classPropertyName, classProperty)
			} else if (IsFunc(classProperty) == 2
					&& RegExMatch(classPropertyName, "i)^@BeforeClass.+")) {
				TestCase.addBeforeClassFixture(classPropertyName, classProperty)
			} else if (IsFunc(classProperty) = 2
					&& RegExMatch(classPropertyName, "i)^@Before(?!Class).+")) {
				TestCase.addBeforeFixture(classPropertyName, classProperty)
			} else if (IsFunc(classProperty) = 2
					&& RegExMatch(classPropertyName, "i)^@AfterClass.+")) {
				TestCase.addAfterClassFixture(classPropertyName, classProperty)
			} else if (IsFunc(classProperty) = 2
					&& RegExMatch(classPropertyName, "i)^@After(?!Class).+")) {
				TestCase.addAfterFixture(classPropertyName, classProperty)
			} else if (IsObject(classProperty)) {
				TestCase.findTestsAndFixtures(classProperty)
			}
		}
		return TestData.testNames.count()
	}

	runBeforeClassFixtures() {
		for iFixture, _fixture in TestData.beforeClassFixtureNames {
			OutputDebug Run  %_fixture%
			TestData.testClass[_fixture].(TestData.testClass)
		}
	}

	runAfterClassFixtures() {
		for iFixture, _fixture in TestData.afterClassFixtureNames {
			OutputDebug Run  %_fixture%
			TestData.testClass[_fixture].(TestData.testClass)
		}
	}

	runSelectedTests() {
		TestCase.writeLine("`n" TestCase.WHITE
				. "Running " A_ScriptName
				. TestCase.RESET)
		for objectReference, testName in TestData.testNames {
			if (TestData.selectedTestNames.count() == 0
					|| TestData.selectedTestNames.hasKey(testName)) {
				TestCase.runBeforeFixtures()
				try {
					TestCase.performTestFunction(testName, TestData.testClass)
				} catch gotException {
					TestCase.testFailed(testName, gotException)
					if (TestCase.stopOnFirstError) {
						break
					}
				}
				TestCase.runAfterFixtures()
			}
		}
	}

	runBeforeFixtures() {
		for iFixture, _fixture in TestData.beforeFixtureNames {
			OutputDebug Run  %_fixture%
			TestData.testClass[_fixture].(TestData.testClass)
		}
	}

	runAfterFixtures() {
		for iFixture, _fixture in TestData.afterFixtureNames {
			OutputDebug Run  %_fixture%
			TestData.testClass[_fixture].(TestData.testClass)
		}
	}

	performTestFunction(testName, testClass) {
		OutputDebug Run  %testName%
		TestCase.write("     " testName "...")
		TestData.assertionCounter := 0
		TestCase.performDependencies(testName, testClass)
		TestData.performedTestNames[testName] := true
		testStartTime := TestCase.clock()
		res := testClass[testName].(testClass)
		testEndTime := TestCase.clock()
		TestCase.duration := TestCase.testDuration(testStartTime, testEndTime)
		OutputDebug % testName " (" TestCase.duration * 1000 "ms)"
		TestCase.allSuccessfulTestsDuration += TestCase.duration
		durationInMSec := Round(TestCase.duration * 1000, 0)
		TestCase.writeLine("[1G  "
				. TestCase.GREEN
				. TestCase.SUCCESSFUL_SYMBOL
				. TestCase.RESET
				. " " testName
				. TestCase.YELLOW
				. (durationInMSec == 0 ? "" : " (" durationInMSec "ms)")
				. TestCase.RESET "[K")
		TestData.testState[testName] := TestCase.SUCCESSFUL
		TestData.numberOfPassingTests++
		return res
	}

	performDependencies(testName, testClass) {
		if (testClass.hasKey("@Depend_" testName)) {
			dependendTestsNames := testClass["@Depend_" testName]()
			dependendTests := StrSplit(dependendTestsNames, ",", " `t`r`n")
			while (A_Index <= dependendTests.maxIndex()) {
				dependendTestName := dependendTests[A_Index]
				OutputDebug Run  %dependendTestName%  <-%testName%
				if (!TestData.performedTestNames.hasKey(dependendTestName)) {
					TestData.performedTestNames[testName] := true
					try {
						TestCase.performTestFunction(dependendTestName
								, testClass)
						TestData.testState[dependendTestName] := true
					} catch _ex {
						TestData.testState[dependendTestName] := false
						throw Exception("Depending test failed: "
								. dependendTestName ": "
								. _ex.message ": " _ex.extra)
					}
				} else {
					OutputDebug Skip %dependendTestName%  <-%testName%
				}
			}
		}
	}

	testFailed(testName, exceptionReceived) {
		TestCase.writeLine("[1G  "
				. TestCase.RED
				. TestCase.FAILED_SYMBOL
				. TestCase.RESET
				. " " testName
				. TestCase.RESET
				. "[K")
		TestData.numberOfFailingTests++
		TestData.failedTests.push(Object("strTest", testName
				, "ex", exceptionReceived
				, "failedAtAssertion", TestData.assertionCounter))
		TestData.testState[testName] := TestCase.FAILED
		TestCase.failedAssertionSource[testName]
				:= TestCase.getAssertionSource(testName
				, TestData.assertionCounter)
	}

	testDuration(startTime, endTime) {
		return (endTime - startTime - TestCase.lAPIOverhead)
				/ TestCase.lFrequency
	}

	addTest(classPropertyName, classProperty) {
		TestData.testNames[Object(classProperty)] := classPropertyName
		TestCase.registerTest(classPropertyName)
		OutputDebug % "Add Test " classPropertyName
	}

	addBeforeClassFixture(classPropertyName, classProperty) {
		TestData.beforeClassFixtureNames[Object(classProperty)]
				:= classPropertyName
		OutputDebug % "Add BeforeClass fixture " classPropertyName
	}

	addBeforeFixture(classPropertyName, classProperty) {
		TestData.beforeFixtureNames[Object(classProperty)] := classPropertyName
		OutputDebug % "Add Before fixture " classPropertyName
	}

	addAfterClassFixture(classPropertyName, classProperty) {
		TestData.afterClassFixtureNames[Object(classProperty)]
				:= classPropertyName
		OutputDebug % "Add AfterClass fixture " classPropertyName
	}

	addAfterFixture(classPropertyName, classProperty) {
		TestData.afterFixtureNames[Object(classProperty)] := classPropertyName
		OutputDebug % "Add After fixture " classPropertyName
	}

	write(text="") {
		TestCase.testOut.write(text)
		TestCase.testOut.read(0)
	}

	writeLine(text="") {
		TestCase.testOut.writeLine(text)
		TestCase.testOut.read(0)
	}

	writeTestSummary() {
		TestCase.writeLine("`n`n" TestCase.GREEN
				. TestData.numberOfPassingTests " passing"
				. TestCase.RESET
				. " ("
				. Round(TestCase.allSuccessfulTestsDuration * 1000, 0)
				. "ms)")
		TestCase.writeLine(TestCase.RED
				. TestData.numberOfFailingTests " failing"
				. TestCase.RESET)
		for i, failedTest in TestData.failedTests {
			TestCase.writeLine()
			TestCase.writeLine(TestCase.WHITE
					. i ") " failedTest.strTest
					. " fails when executing assertion #"
					. failedTest.failedAtAssertion
					. failedTest.ex.extra
					. TestCase.RESET
					. "`n")
			TestCase.writeLine("`t"
					. TestCase.RED
					. failedTest.ex.message
					. TestCase.RESET
					. "`n")
			TestCase.writeLine("`t"
					. TestCase.failedAssertionSource[failedTest.strTest]
					. "`n")
		}
	}

	clock() {
		DllCall("QueryPerformanceCounter", "Int64 *", currentTime := 0)
		return currentTime
	}

	assert(expression, messageText="AssertionError") {
		TestData.assertionCounter++
		if (expression == true) {
			return true
		}
		TestCase.reportError(expression == true, true, messageText)
	}

	assertSame(actualValue, expectedValue, messageText="AssertionError") {
		TestData.assertionCounter++
		if (!IsObject(actualValue)) {
			TestCase.reportError(actualValue, "<An object>"
					, "First argument has to be an object")
		}
		if (!IsObject(expectedValue)) {
			TestCase.reportError(expectedValue, "<An object>"
					, "Second argument has to be an object")
		}
		if (!(Object(expectedValue) = Object(actualValue))) {
			TestCase.reportError("@" Object(actualValue)
					, "@" Object(expectedValue), messageText)
		}
		return true
	}

	assertEquals(actualValue, expectedValue, messageText="AssertionError") {
		TestData.assertionCounter++
		areBothValuesFromTheSameType := ((actualValue + 0) == actualValue)
				== ((expectedValue + 0) == expectedValue)
		if (!areBothValuesFromTheSameType || !(actualValue == expectedValue)) {
			TestCase.reportError(actualValue, expectedValue, messageText)
		}
		return actualValue
	}

	assertEqualsIgnoreCase(actualValue, expectedValue
			, messageText="AssertionError") {
		StringUpper actualValueUpCase, actualValue
		StringUpper expectedValueUpCase, expectedValue
		if (TestCase.assertEquals(actualValueUpCase, expectedValueUpCase
				, messageText)) {
			return actualValue
		}
	}

	assertTrue(expression="", messageText="AssertionError") {
		TestData.assertionCounter++
		if (expression == "" || !expression) {
			TestCase.reportError(expression, true, messageText)
		}
		return expression
	}

	assertFalse(expression, messageText="AssertionError") {
		TestData.assertionCounter++
		if (expression == "" || !(expression == false)) {
			TestCase.reportError(expression, true, messageText)
		}
		return expression
	}

	assertEmpty(actualValue, messageText="AssertionError") {
		TestData.assertionCounter++
		if (actualValue != "") {
			TestCase.reportError(IsObject(actualValue)
					? "@" Object(actualValue)
					: actualValue
					, "<Empty>", messageText)
		}
		return actualValue
	}

	assertNotEmpty(actualValue, messageText="AssertionError") {
		TestData.assertionCounter++
		if (actualValue == "") {
			TestCase.reportError(actualValue, "<Non-Empty>", messageText)
		}
		return actualValue
	}

	assertException(baseObject, methodName, messageText="AssertionException"
			, expectedExceptionRegEx="", parms*) {
		TestData.assertionCounter++
		gotAnException := false
		caughtException := ""
		try {
			methodQualifier := ""
			if (IsObject(baseObject)) {
				functionObject := baseObject[methodName]
				if (baseObject.__Class = "") {
					methodQualifier := """"".base."
					functionObject.(parms*)
				} else {
					methodQualifier := baseObject.__Class "."
					functionObject.(baseObject, parms*)
				}
			} else {
				functionObject := Func(methodName)
				functionObject.(parms*)
			}
			gotAnException := false
		} catch caughtException {
			gotAnException := RegExMatch(caughtException.message
					, expectedExceptionRegEx)
		}
		if (!gotAnException) {
			testee := methodQualifier methodName
			TestCase.processException(messageText, caughtException, testee
					, parms*)
		}
	}

	processException(messageText, caughtException, testee, parms*) {
		if (messageText = "") {
			messageText := "AssertionError"
		}
		strParmList := ""
		for i, _parm in parms {
			strParmList .= (strParmList = "" ? "" : ";")
					. i "=" (IsObject(_parm)
					? "@" Object(_parm)
					: _parm)
		}
		throw Exception(messageText, -1
				, (caughtException.message == ""
				? "" : caughtException.message ": ")
				. "Expected " testee
				. " to throw an exception but didn't get one; " strParmList)
	}

	fileContent(fileName) {
		FileRead content, %fileName%
		return content
	}

	fail(messageText, extraInfo="", terminateProgram=false) {
		if (!terminateProgram) {
			throw Exception(messageText, -1, extraInfo)
		} else {
			TestCase.write("`n`n" messageText ":" extraInfo "`n`n")
			exitapp -1
		}
	}

	stateName(state) {
		if (state = TestCase.UNKNOWN) {
			return "Unknown test"
		} else if (state = TestCase.NOT_RUN) {
			return "Did not run"
		} else if (state = TestCase.SUCCESSFUL) {
			return "Successfull"
		} else if (state = TestCase.FAILED) {
			return "Failed"
		}
		return "Unknown state: " state
	}

	visibleCtrls(st, compareTo="") {
		StringReplace st, st, `r,, All
		StringReplace st, st, `n, ¶`n, All
		StringReplace st, st, %A_Space%, ·, All
		if (compareTo) {
			_st := st
			StringReplace compareTo, compareTo, `r,, All
			StringReplace compareTo, compareTo, `n, ¶`n, All
			StringReplace compareTo, compareTo, %A_Space%, ·, All
			res := ""
			l_st := StrLen(st)
			l_ct := StrLen(compareTo)
			p := 1
			diff := false
			while (p <= l_st && p <= l_ct) {
				c_st := SubStr(st, p, 1)
				c_ct := SubStr(compareTo, p, 1)
				if (Asc(c_st) != Asc(c_ct)) {
					if (diff = false) {
						res .= "[1;40;33;7m"
						diff := true
					}
				} else if (diff) {
					res .= "[0m[1m"
					diff := false
				}
				res .= c_st
				p++
			}
			st := res "[0m"
			if (p <= l_st) {
				st .= "[1;40;33;7m" SubStr(_st, p) "[0m"
			}
		}
		return  st
	}

	registerTest(test) {
		TestData.testState[test] := TestCase.NOT_RUN
		if (StrLen(test) > TestCase.longestTestName) {
			TestCase.longestTestName := StrLen(test)
		}
	}

	didNotRun(test) {
		return (TestData.testState[test] = TestCase.NOT_RUN)
	}

	didRun(test) {
		return !TestCase.didNotRun(test)
	}

	wasSuccessful(test) {
		return TestData.testState[test] = TestCase.SUCCESSFUL
	}

	hasFailed(test) {
		return TestData.testState[test] = TestCase.FAILED
	}

	isUnknwon(test) {
		return TestData.testState[test] = TestCase.UNKNOWN
	}

	isKnown(test) {
		return !TestCase.isUnknwon(test)
	}

	reportError(actualValue, expectedValue, messageText) {
		throw Exception(messageText, -1
				, "`n" TestCase.GREEN "Expected:`n"
				. TestCase.RESET expectedValue
				. TestCase.RED
				. "`nbut got:`n"
				. TestCase.RESET
				. TestCase.visibleCtrls(actualValue, expectedValue))
	}

	getAssertionSource(testName, assertionNumber) {
		static testSourceCode := ""

		if (testSourceCode) == "" {
			testSourceCode := TestCase.loadTestSourceFile()
		}
		testAt := RegExMatch(testSourceCode, "im`a)" testName "\(.*\)\s+\{", $)
		findAssertionAt := testAt + StrLen($)
		loop {
			findAssertionAt := RegExMatch(testSourceCode
					, "im`a)assert(Same|Equals(IgnoreCase)?|"
					. "True|False|(Not)?Empty|Exception)?"
					, assertion, findAssertionAt)
			findAssertionAt += StrLen(assertion) + 1
		} until (A_Index >= assertionNumber)
		loop {
			char := SubStr(testSourceCode, --findAssertionAt, 1)
		} until (char == "`n" || char == "`r")
		RegExMatch(testSourceCode, "m`a)\s*(?P<Source>.*?)\s*?$"
				, assertion, findAssertionAt+1)
		lines := StrSplit(SubStr(testSourceCode, 1, findAssertionAt)
				, "`n", "`r")
		return lines.maxIndex() ": " assertionSource
	}

	loadTestSourceFile() {
		FileRead testSourceCode, %A_ScriptFullPath%
		startAt := 1
		while (foundAt := (RegExMatch(testSourceCode
				, "ms`a)(?<=\/\*)(.*?)(?=\*\/)|(`;.*?$)", pattern, startAt))) {
			testSourceCode := SubStr(testSourceCode, 1, foundAt - 1)
					. RegExReplace(pattern, "\w", "X")
					. SubStr(testSourceCode, foundAt + StrLen(pattern))
			startAt := foundAt + StrLen(pattern) + 1
		}
		return testSourceCode
	}

	logTestResultSummaryToDebugOut() {
		summaryTable := new DataTable()
		summaryTable.defineColumn(new DataTable.Column(
				, DataTable.COL_RESIZE_USE_LARGEST_DATA))
		summaryTable.defineColumn(new DataTable.Column(
				, DataTable.COL_RESIZE_USE_LARGEST_DATA))
		summaryTable.addData(["TESTNAME", "RESULT"])
		for testName, testState in TestData.testState {
			summaryTable.addData([testName, TestCase.stateName(testState)])
		}
		OutputDebug % "`n" summaryTable.getTableAsString("| ", " | ", " |")
	}
}
