group := tester.newGroup("array_join(array, delim)")

array := [1,2,3,4,5]


group.newTest("Join elements with newlines"
	, Assert.equal("1`n2`n3`n4`n5", array_join(array, "`n")))

group.newTest("Join elements with commas"
	, Assert.equal("1,2,3,4,5", array_join(array, ",")))