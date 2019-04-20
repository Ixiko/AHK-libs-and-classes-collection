group := tester.newGroup("some(callback)")

array := [1,2,3,4,5]


group.newTest("Detect one even number"
	, Assert.true(array.some(objBindMethod(Assert, "isEven"))))

group.newTest("Detect one odd number"
	, Assert.true(array.some(objBindMethod(Assert, "isOdd"))))

group.newTest("Fails to find large enough number"
	, Assert.true(array.some(objBindMethod(Assert, "greaterThan", 6))))