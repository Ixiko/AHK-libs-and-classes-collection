group := tester.newGroup("join(delim)")

array := [1,2,3,4,5]


group.newTest("Join elements with newlines"
	, Assert.equal("1`n2`n3`n4`n5", array.join("`n")))

group.newTest("Join elements with commas"
	, Assert.equal("1,2,3,4,5", array.join(",")))