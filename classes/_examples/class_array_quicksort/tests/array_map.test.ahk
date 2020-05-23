group := tester.newGroup("array_map(array, callback)")

arrayInt := [1, 5, 10]
arrayObj := [{"name": "bob", "age": 22}, {"name": "tom", "age": 51}]


group.newTest("Double integer values"
	, Assert.arrayEqual([2, 10, 20], array_map(arrayInt, func("multiply").bind(2))))

group.newTest("Strip object down to single property"
	, Assert.arrayEqual(["bob", "tom"], array_map(arrayObj, func("objProp_get").bind("name"))))