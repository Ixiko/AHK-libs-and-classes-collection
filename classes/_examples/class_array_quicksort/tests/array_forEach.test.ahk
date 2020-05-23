group := tester.newGroup("array_forEach(array, callback)")

global forEach_sum := 0


array_forEach([1,2,3,4,5], func("array_forEach_addToSum"))
group.newTest("Act on global variable for result"
	, Assert.equal(1+2+3+4+5, forEach_sum))

; object scenario
objs := [{msg: "bye"}, {msg: "nope"}]
array_forEach(objs, func("array_forEach_setMsgToHi"))
array := []

for i,obj in objs
	array.push(obj.msg)

group.newTest("Change property of each object"
	, Assert.arrayEqual(["hi", "hi"], array))


array_forEach_addToSum(int) {
    forEach_sum += int
}

array_forEach_setMsgToHi(element, index, array) {
    array[index].msg := "hi"
}
