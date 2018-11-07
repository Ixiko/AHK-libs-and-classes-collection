group := tester.newGroup("reverse(array)")


group.newTest("Reverse even sized int array"
	, Assert.arrayEqual([5,6,4,3,2,1], [1,2,3,4,6,5].reverse()))

group.newTest("Reverse odd sized int array"
	, Assert.arrayEqual([5,4,3,2,1], [1,2,3,4,5].reverse()))