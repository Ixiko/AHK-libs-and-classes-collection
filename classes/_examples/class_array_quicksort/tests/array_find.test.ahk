group := tester.newGroup("array_find(array, callback)")

find_fn := objBindMethod(Assert, "equal", 5)


group.newTest("Successful item lookup"
	, Assert.equal(5, array_find([1,2,3,4,5,6], find_fn)))

group.newTest("Unsuccessful item lookup"
	, Assert.equal(0, array_find([1,2,3], find_fn)))
