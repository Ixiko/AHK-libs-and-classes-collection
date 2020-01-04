#include <strex>
class arr{
	contained(sub, sup){
		c := 0
		for k, v in sup
			if sub[c + 1] = v
				c++
		if c = sub.length()
			return 1
		else
			return 0
		}
	random(array){
		array := array.clone()
		len := array.length()
		newArray := {}
		while len > 0{
			spot := random(1, len--)
			newArray.push array[spot]
			array.removeAt spot
			}
		return newArray
		}
	sort(array, sortFuncs*){
		if sortFuncs.length() < 2{
			if sortFuncs.length() = 0
				sortFunc := (a, b) => a < b
			else
				sortFunc := sortFuncs.1
			if array.length() > 1{
				subArrs := split(array)
				return merge(arr.sort(subArrs.1, sortFunc), arr.sort(subArrs.2, sortFunc))
			}else
				return array
			split(array){
				splitVal := floor(array.length() / 2)
				return [arr.sub(array, 1, splitVal), arr.sub(array, splitVal + 1)]
				}
			merge(arr1, arr2){
				newArr := []
				while arr1.length() > 0 and arr2.length() > 0{
					a1 := arr1.1
					a2 := arr2.1
					if sortFunc.call(a1, a2){
						newArr.push(a1)
						arr1.removeAt(1)
					}else{
						newArr.push(a2)
						arr2.removeAt(1)
						}
					}
				if arr1.length() > 0
					newArr.push(arr1*)
				else
					newArr.push(arr2*)
				return newArr
				}
		}else{
			newArr := arr.sort(array, sortFuncs.1)
			same := [[newArr.1]]
			eq := 1
			c := 2
			while c <= newArr.length(){
				e1 := newArr[c - 1]
				e2 := newArr[c]
				ab := sortFuncs.1.call(e1, e2)
				ba := sortFuncs.1.call(e2, e1)
				if ab = ba
					same[eq].push(e2)
				else
					same[++eq] := [e2]
				c++
				}
			sortFuncs.removeAt 1
			for k, v in same
				for j, u in v
					print k, j, u.name, u.ct
			for k, v in same
				same[k] := arr.sort(v, sortFuncs*)
			newArr := []
			for k, v in same
				newArr := arr.union(newArr, v)
			return newArr
			}
		}
	sub(arr, start, end := -1){
		newArr := []
		if start < 0
			start := arr.length() + 1 + start
		if end < 0
			end := arr.length() + 1 + end
		loop end - start + 1
			newArr.push(arr[a_index + start - 1])
		return newArr
		}
	sum(array){
		sum := 0
		for k, v in array
			sum += v
		return sum
		}
	union(array1, arrays*){
		if arrays.length() = 0
			return array1
		else if arrays.length() = 1{
			newArray := array1.clone()
			for k, v in arrays.1
				newArray.push v
			return newArray
		}else
			return arr.union(array1, arr.union(arrays*))
		}
	}