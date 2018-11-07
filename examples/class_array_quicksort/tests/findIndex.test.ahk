group := tester.newGroup("findIndex(callback)")

array := [10,22,"ca",334,45,"d"]
array2 := [10,22,123,334,45,"d"]


group.newTest("Successful item lookup"
	, Assert.equal(3, array.findIndex(objBindMethod(Assert, "equal", "ca"))))

group.newTest("Unsuccessful item lookup"
	, Assert.equal(0, array2.findIndex(objBindMethod(Assert, "equal", "ca"))))
