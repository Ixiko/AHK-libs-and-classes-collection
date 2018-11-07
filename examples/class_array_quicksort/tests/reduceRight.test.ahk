group := tester.newGroup("reduceRight(callback, initialValue:='__NULL__')")

names := ["tom", "jerry", "morty", "rick"]
myArray := [1,2,3,6,4,5]
nested_arrays := [[1,2], [3,4], [4,5]]
complex_array := [new Person(names[4], 22)
    , new Person(names[3], 51)
    , new Person(names[2], 15)
    , new Person(names[1], 55)]


group.newTest("Add all values of array"
	, Assert.equal(21, myArray.reduceRight(func("addition"))))

group.newTest("Find maximum value of array"
	, Assert.equal(6, myArray.reduceRight(func("maximum"))))

group.newTest("Add all values of array to initial value"
	, Assert.equal(41, myArray.reduceRight(func("addition"), 20)))

group.newTest("Sum a property of all objects"
	, Assert.equal(143, complex_array.reduceRight(func("objProp_addition").bind("age"), 0)))

group.newTest("Copy a string property of all objects into an array"
	, Assert.arrayEqual(names, complex_array.reduceRight(func("objProp_arrayPush").bind("name"), [])))

group.newTest("Concat nested arrays"
    , Assert.arrayEqual([4, 5, 3, 4, 1, 2], nested_arrays.reduceRight(func("reduce_nestedArray"))))
