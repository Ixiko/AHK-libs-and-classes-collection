group := tester.newGroup("func(arg1, arg2)")

; Setup data structures here
array := [1,2]

; Setup tests
group.newTest("test 1", Assert.true(1))

group.newTest("test 2", Assert.false(0))

group.newTest("test 3", Assert.equals(1, 1))

group.newTest("test 4", Assert.arrayEquals([1,2], array)