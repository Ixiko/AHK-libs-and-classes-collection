group := tester.newGroup("array_slice(array, start:=0, end:=0)")

array := [1,2,3,4,5]


group.newTest("No args"
	, Assert.arrayEqual(array, array_slice(array)))

group.newTest("Positive start"
	, Assert.arrayEqual([3,4,5], array_slice(array, 3)))

group.newTest("Positive start & end"
	, Assert.arrayEqual([2,3], array_slice(array, 2, 4)))

group.newTest("Negative start"
	, Assert.arrayEqual([3,4,5], array_slice(array, -3)))

group.newTest("Negative start & end"
	, Assert.arrayEqual([4], array_slice(array, -2, -1)))

group.newTest("Positive start & negative end"
	, Assert.arrayEqual([2,3], array_slice(array, 2, -2)))

group.newTest("Negative start & positive end"
	, Assert.arrayEqual([2], array_slice(array, -4, 3)))