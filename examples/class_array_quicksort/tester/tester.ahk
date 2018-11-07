class TestRunner {

	groups := []

	__New(title) {
		this.title := title
	}

	newGroup(title) {

		group := new TestRunner.TestGroup(title)
		this.groups.push(group)

		return group
	}

	getAllTestResults() {

		FormatTime, CurrentDateTime,, MM/dd/yy - HH:mm:ss
		results := [CurrentDateTime, this.title, ""]

		for i, group in this.groups
			results.push(group.getTestResults())

		return results.join("`n")
	}



	class TestGroup {

		tests := []

		__New(title) {
			this.title := title
		}

		newTest(desc, result) {

			this.tests.push(new TestRunner.Test(desc, result))
		}

		getTestResults() {

			results := [this.title]

			for i, test in this.tests
				results.push(test.getResult())
			
			return results.join("`n") "`n"
		}
	}


	class Test {

		__New(desc, result) {
			this.desc := desc
			this.result := result
		}

		getResult() {

			return "[" (this.result ? "PASS" : "----") "] " this.desc
		}
	}
}
