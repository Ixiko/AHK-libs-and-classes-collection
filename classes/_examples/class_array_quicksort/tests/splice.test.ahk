group := tester.newGroup("splice(start, deleteCount:=-1, args*)")


; test subgroup 1
desc := "Starting position only"
array := ["a","b","c","d","e","f"]
spliced := array.splice(3)

group.newTest(desc ": array"
	, Assert.arrayEqual(["a","b"], array))

group.newTest(desc ": spliced"
	, Assert.arrayEqual(["c","d","e","f"], spliced))


; test subgroup 2
desc := "Starting position with delete"
array := ["a","b","c","d","e","f"]
spliced := array.splice(3, 2)

group.newTest(desc ": array"
	, Assert.arrayEqual(["a","b","e","f"], array))

group.newTest(desc ": spliced"
	, Assert.arrayEqual(["c","d"], spliced))


; test subgroup 3
desc := "Starting position no delete"
array := ["a","b","c","d","e","f"]
spliced := array.splice(3, 0)

group.newTest(desc ": array"
	, Assert.arrayEqual(["a","b","c","d","e","f"], array))

group.newTest(desc ": spliced"
	, Assert.arrayEqual([], spliced))


; test subgroup 4
desc := "Starting position with delete and args"
array := ["a","b","c","d","e","f"]
spliced := array.splice(3, 2, "g", "h")

group.newTest(desc ": array"
	, Assert.arrayEqual(["a","b","g","h","e","f"], array))

group.newTest(desc ": spliced"
	, Assert.arrayEqual(["c","d"], spliced))


; test subgroup 5
desc := "Starting position no delete and args"
array := ["a","b","c","d","e","f"]
spliced := array.splice(3, 0, "g", "h")

group.newTest(desc ": array"
	, Assert.arrayEqual(["a","b","g","h","c","d","e","f"], array))

group.newTest(desc ": spliced"
	, Assert.arrayEqual([], spliced))