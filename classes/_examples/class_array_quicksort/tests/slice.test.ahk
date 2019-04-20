group := tester.newGroup("slice(start:=0, end:=0)")

array := [1,2,3,4,5]


group.newTest("No args"
	, Assert.arrayEqual(array, array.slice()))

group.newTest("Positive start"
	, Assert.arrayEqual([3,4,5], array.slice(3)))

group.newTest("Positive start & end"
	, Assert.arrayEqual([2,3], array.slice(2, 4)))

group.newTest("Negative start"
	, Assert.arrayEqual([3,4,5], array.slice(-3)))

group.newTest("Negative start & end"
	, Assert.arrayEqual([4], array.slice(-2, -1)))

group.newTest("Positive start & negative end"
	, Assert.arrayEqual([2,3], array.slice(2, -2)))

group.newTest("Negative start & positive end"
	, Assert.arrayEqual([2], array.slice(-4, 3)))