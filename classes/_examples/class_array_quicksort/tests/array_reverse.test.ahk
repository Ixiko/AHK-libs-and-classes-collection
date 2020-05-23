group := tester.newGroup("array_reverse(array)")


group.newTest("Reverse even sized int array"
	, Assert.arrayEqual([5,6,4,3,2,1], array_reverse([1,2,3,4,6,5])))

group.newTest("Reverse odd sized int array"
	, Assert.arrayEqual([5,4,3,2,1], array_reverse([1,2,3,4,5])))