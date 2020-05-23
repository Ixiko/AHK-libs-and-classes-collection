group := tester.newGroup("array_toString(array)")

array := [1,2,3,4,5,6]

group.newTest("Sequential int array to string"
	, Assert.equal("[1,2,3,4,5,6]", array_toString(array)))