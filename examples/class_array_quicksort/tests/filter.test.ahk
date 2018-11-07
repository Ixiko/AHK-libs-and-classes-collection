group := tester.newGroup("filter(callback)")

array := [1,2,3,4,5,6]


group.newTest("Collect even numbers"
	, Assert.arrayEqual([2,4,6], array.filter(objBindMethod(Assert, "isEven"))))


group.newTest("Collect odd numbers"
	, Assert.arrayEqual([1,3,5], array.filter(objBindMethod(Assert, "isOdd"))))
