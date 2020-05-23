group := tester.newGroup("array_lastIndexOf(array, searchElement, fromIndex:=0)")

array := ["a", "b", "c", "d", "d", "d", "e", "e", "f"]


group.newTest("Get matching last index"
	, Assert.equal(6, array_lastIndexOf(array, "d")))

group.newTest("Get matching last index with bad starting index"
	, Assert.equal(-1, array_lastIndexOf(array, "d", 999)))

group.newTest("Get matching last index with positive starting index"
	, Assert.equal(6, array_lastIndexOf(array, "d", 3)))

group.newTest("Get matching last index with negative starting index"
	, Assert.equal(6, array_lastIndexOf(array, "d", -5)))