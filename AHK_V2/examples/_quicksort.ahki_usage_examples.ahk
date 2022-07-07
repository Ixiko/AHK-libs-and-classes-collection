#include _quick_sort.ahki

; Simple integer array sorting example

simpleArray := [ 5,10,3,12,8,7,7,7 ]
sortedSimpleArray := QuickSort(simpleArray)
MsgBox(Array2String(sortedSimpleArray))


; Simple string array sorting example

stringArray := [ "this", "is", "just", "a", "simple", "test", "of", "quick", "sort" ]
sortedStringArray := QuickSort(stringArray, StrCompare)	; AHKv2 built in StrCompare function
MsgBox(Array2String(sortedStringArray))


; Array of objects sorted by property of integer type

objectArray := [ Apple(19), Apple(3), Apple(17), Apple(1), Apple(21), Apple(123456), Apple(-221) ]
sortedStringArray := QuickSortByProperty(objectArray, "size")
MsgBox(Array2String(sortedStringArray))


; Example of how to use custom comparison function for sorting

rectangleArray := [ Rectangle(7, 1), Rectangle(1, 122), Rectangle(532, 0.0009), Rectangle(17, -1), Rectangle(-12, -12) ]

CompareSurface(rectangle1, rectangle2) {
	return rectangle1.Surface() - rectangle2.Surface()
}

sortedRectangleArray := QuickSort(rectangleArray, CompareSurface)
MsgBox(Array2String(sortedRectangleArray))


; Testing helper codes part

Array2String(arr) {
	output := "[ "
	for (it in arr) {
		output .= String(it) " "
	}
	return output "]"
}

class Apple {
	__New(size) {
		this.size := size
	}

	ToString() {
		return "{" this.size " size apple}"
	}
}

class Rectangle {
	__New(w, h) {
		this.w := w
		this.h := h
	}

	Surface() {
		return this.w * this.h
	}

	ToString() {
		return "(" this.w " x " this.h ")"
	}
}
