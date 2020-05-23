group := tester.newGroup("array_unshift(array, args*)")

array := [1,2,3,4,5,6]

array_unshift(array, "a", "b")
group.newTest("Add two elements to start of array"
	, Assert.arrayEqual(["a","b",1,2,3,4,5,6], array))

