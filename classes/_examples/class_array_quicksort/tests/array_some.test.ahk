group := tester.newGroup("array_some(array, callback)")

array := [1,2,3,4,5]


group.newTest("Detect one even number"
	, Assert.true(array_some(array, objBindMethod(Assert, "isEven"))))

group.newTest("Detect one odd number"
	, Assert.true(array_some(array, objBindMethod(Assert, "isOdd"))))

group.newTest("Fails to find large enough number"
	, Assert.true(array_some(array, objBindMethod(Assert, "greaterThan", 6))))