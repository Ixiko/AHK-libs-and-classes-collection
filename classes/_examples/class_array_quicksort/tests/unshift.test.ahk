group := tester.newGroup("unshift(args*)")

array := [1,2,3,4,5,6]

array.unshift("a", "b")
group.newTest("Add two elements to start of array"
	, Assert.arrayEqual(["a","b",1,2,3,4,5,6], array))
