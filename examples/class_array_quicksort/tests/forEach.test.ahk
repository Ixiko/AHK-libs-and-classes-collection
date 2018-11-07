group := tester.newGroup("forEach(callback)")

global forEach_sum := 0

nums := [1,2,3,4,5]
nums.forEach(func("forEach_addToSum"))
group.newTest("Act on global variable for result"
	, Assert.equal(1+2+3+4+5, forEach_sum))

; object scenario
objs := [{msg: "bye"}, {msg: "nope"}]
objs.forEach(func("forEach_setMsgToHi"))
array := []

for i,obj in objs
	array.push(obj.msg)

group.newTest("Change property of each object"
	, Assert.arrayEqual(["hi", "hi"], array))


forEach_addToSum(int) {
	forEach_sum += int
}

forEach_setMsgToHi(element, index, array) {
	array[index].msg := "hi"
}
