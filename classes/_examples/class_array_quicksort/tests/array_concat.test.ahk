group := tester.newGroup("array_concat(arrays*)")

arrays := [[1,2,3]
	, [4,5,6]
	, [7,8,9]]


group.newTest("Combine empty array and non empty array"
	, Assert.arrayEqual([1,2,3], array_concat([], arrays[1])))

group.newTest("Combine two non empty arrays"
	, Assert.arrayEqual([1,2,3,4,5,6], array_concat(arrays[1], arrays[2])))

group.newTest("Combine three non empty arrays"
	, Assert.arrayEqual([1,2,3,4,5,6,7,8,9], array_concat(arrays*)))