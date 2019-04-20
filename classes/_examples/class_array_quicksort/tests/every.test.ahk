group := tester.newGroup("every(callback)")

array_even := [2,4,6]
array_odd := [1,2,4,6]

compare_obj := new ConditionalCompare(false)
isEvenCond_fn := objBindMethod(compare_obj, "isEvenConditional")


group.newTest("Function object"
	, Assert.true(array_even.every(func("isEven"))))

group.newTest("Bound function object"
	, Assert.false(array_odd.every(isEvenCond_fn)))

compare_obj.setAllTrue(true)
group.newTest("Bound function object #2"
	, Assert.true(array_odd.every(isEvenCond_fn)))
