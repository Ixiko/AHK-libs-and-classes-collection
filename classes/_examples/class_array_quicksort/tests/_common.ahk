addition(a, b) {
	return a + b
}

subtract(a, b) {
	return a - b
}

multiply(a, b) {
	return a * b
}

isEven(num, prms*) {
	return (mod(num, 2) = 0)
}

isOdd(num, prms*) {
	return (mod(num, 2) = 1)
}

maximum(a, b) {
	return ((a > b) ? a : b)
}

complex_sort(get_fn, a, b) {
    aVal := get_fn.Call(a)
    bval := get_fn.Call(b)
    return aVal > bval ? 1 : aVal < bval ? -1 : 0
}

objProp_addition(prop, total, obj) {
	return total + obj[prop]
}

objProp_arrayPush(prop, array, obj) {
	array.push(obj[prop])
	return array
}

objProp_get(key, obj, prms*) {
	return obj[key]
}

reduce_nestedArray(previousValue, currentValue) {
     return previousValue.concat(currentValue)
}


class Person {

	__New(name, age) {
		this.name := name
		this.age := age
	}

	getName() {
		return this.name
	}
	
	getAge() {
		return this.age
	}
}

class ConditionalCompare {

	all_true := true

	__New(state) {
		this.all_true := state
	}

	setAllTrue(state) {
		this.all_true := state
	}

	isEvenConditional(num, prms*) {

		if this.all_true
			return true

		return isEven(num)
	}
}