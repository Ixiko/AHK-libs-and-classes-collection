group := tester.newGroup("lastIndexOf(searchElement, fromIndex:=0)")

array := ["a", "b", "c", "d", "d", "d", "e", "e", "f"]


group.newTest("Get matching last index"
	, Assert.equal(6, array.lastIndexOf("d")))

group.newTest("Get matching last index with bad starting index"
	, Assert.equal(-1, array.lastIndexOf("d", 999)))

group.newTest("Get matching last index with positive starting index"
	, Assert.equal(6, array.lastIndexOf("d", 3)))

group.newTest("Get matching last index with negative starting index"
	, Assert.equal(6, array.lastIndexOf("d", -5)))