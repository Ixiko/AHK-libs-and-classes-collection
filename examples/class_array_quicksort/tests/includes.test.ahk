group := tester.newGroup("includes(searchElement, fromIndex:=0)")

array := [1,2,3,4,5]


group.newTest("No args"
	, Assert.true(array.includes(3)))

group.newTest("Positive fromIndex"
	, Assert.true(array.includes(3, 2)))

group.newTest("Negative fromIndex"
	, Assert.true(array.includes(3, -4)))

group.newTest("Negative fromIndex"
	, Assert.false(array.includes(3, -1)))