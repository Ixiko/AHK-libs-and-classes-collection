group := tester.newGroup("fill(value, start:=0, end:=0)")

array := [0,0,0,0]


array.fill(1)
group.newTest("No args"
	, Assert.arrayEqual([1, 1, 1, 1], array))

array.fill(5, 2)
group.newTest("Positive start"
	, Assert.arrayEqual([1, 5, 5, 5], array))

array.fill("A", 1, 2)
group.newTest("Positive start & end"
	, Assert.arrayEqual(["A", "A", 5, 5], array))

array.fill(":D", -2)
group.newTest("Negative start"
	, Assert.arrayEqual(["A", "A", ":D", ":D"], array))

array.fill(1, -4, -2)
group.newTest("Negative start & end"
	, Assert.arrayEqual([1, 1, ":D", ":D"], array))