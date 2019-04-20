class Assert {

	true(value) {
		return (value == true)
	}

	false(value) {
		return (value == false)
	}

	equal(value1, value2) {
		return (value1 == value2)
	}

	notEqual(value1, value2) {
		return (value1 != value2)
	}

	arrayEqual(array1, array2) {

		result := true
		for index, value in array1 {
			if (value != array2[index]) {
				result := false
				break
			}
		}

		return result
	}

	isEven(num) {
		return (mod(num, 2) == 0)
	}

	isOdd(num) {
		return (mod(num, 2) == 1)
	}

	greaterThan(a, b) {
		return a > b
	}

	lessThan(a, b) {
		return a < b
	}
}