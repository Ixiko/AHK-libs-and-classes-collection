group := tester.newGroup("find(callback)")

find_fn := objBindMethod(Assert, "equal", 5)


group.newTest("Successful item lookup"
	, Assert.equal(5, [1,2,3,4,5,6].find(find_fn)))

group.newTest("Unsuccessful item lookup"
	, Assert.equal(0, [1,2,3].find(find_fn)))
