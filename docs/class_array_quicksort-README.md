# array_
## Conversion of JavaScript's Array methods to AutoHotkey

AutoHotKey is an extremely versatile prototype-based language but lacks built-in iteration helper methods (as of 1.1.28) to perform many of the common behaviors found in other languages. This project ports most of JavaScript's Array object methods over to AutoHotKey.

### Ported Methods
* concat
* every
* fill
* filter
* find
* findIndex
* forEach
* includes
* indexOf
* join
* lastIndexOf
* map
* reduce
* reduceRight
* reverse
* shift
* slice
* some
* sort
* splice
* toString
* unshift

### Installation
There are two options for using these functions, either as global functions stored in **array_.ahk** or by extending the built-in Array object with the object stored in **array_base.ahk**. The sorting function in both files depend on the object defined in **array_quicksort.ahk**. This object must be present for sorting to work properly.

Some dislike extending built-in objects. For that reason **array_base.ahk**'s object does not automatically extend Array. Extending Array, or a custom collections object, is left to the implementer (See _**As Array Object Extension**_  below). Using this method based approach grants the ability to perform method-chaining syntax.

### Usage
_**As Global Functions**_  
**array_.ahk** contains each ported function as a global function declaration in the form of *array_\<func\>*. The input array is always located in the first parameter position.

Usage: `array_<fn>(array[, params*])`
```autohotkey
#include array_.ahk

arrayInt := [1, 5, 10]
arrayObj := [{"name": "bob", "age": 22}, {"name": "tom", "age": 51}]

; Map to doubled value
array_map(arrayInt, func("double_int")) ; Output: [2, 10, 20]

double_int(int) {
    return int * 2
}

; Map to object property
array_map(arrayObj, func("get_name")) ; Output: ["bob", "tom"]

get_name(obj) {
    return obj.name
}
```

_**As Array Object Extension**_  
**array_base.ahk** contains each ported function as a method of the object *_Array*. The most intuitive use case is extending the built-in Array object (assigning it's base object). Some environments avoid modifying built-ins and prefer using custom collection objects. This allows the familar method chaining many have become accustomed to in other languages.

Usage: `Array.<fn>([params*])` (Assuming Array's base object was extended)
```autohotkey
#include array_base.ahk

; Extend Array object, see array_base.ahk for more details
Array(prms*) {
    prms.base := _Array
    return prms
}

arrayInt := [1, 5, 10]
arrayObj := [{"name": "bob", "age": 22}, {"name": "tom", "age": 51}]

; Map to doubled value
arrayInt.map(func("double_int")) ; Output: [2, 10, 20]

double_int(int) {
    return int * 2
}

; Map to object property
arrayObj.map(func("get_name")) ; Output: ["bob", "tom"]

get_name(obj) {
    return obj.name
}

; Method chaining
arrayObj.map(func("get_prop").bind("age"))
    .map(func("double_int"))
    .join(",")

get_prop(prop, obj) {
    return obj[prop]
}
```

_**Sorting**_  
**array_quicksort.ahk** contains the sorting logic. The quicksort behavior is wrapped in a callable function object to avoid cluttering the global namespace.

Indirect Usage: `array_sort(Array, [params*])` or `Array.sort([params*])`  
Direct Usage: `Array_Quicksort.Call(Array, [params*])`
```autohotkey
arrayInt := [11,9,5,10,1,6,3,4,7,8,2]

; Indirect usage
array_sort(arrayInt) ; Output: [1,2,3,4,5,6,7,8,9,10,11]
arrayInt.sort()      ; Output: [1,2,3,4,5,6,7,8,9,10,11]

; Direct usage - each library function facades to the same invocation below
Array_Quicksort.Call(arrayInt)
```

JavaScript does not expose start/end or left/right parameters and neither does this sort function. Exposing them in these project files would be fairly easy, but doing so may produce unintuitive use cases when desiring the default comparator behavior.
The QuickSort object is outlined below:

```autohotkey
Class Array_QuickSort {
    ; Core sorting logic
    _compare_alphanum(a, b)
    _sort(array, compare_fn, left, right)
    _partition(array, compare_fn, left, right)
    _swap(array, idx1, idx2)

    ; AHK specific calling behavior for function object
    Call(array, compare_fn:=0)
    __Call(method, args*)
}
```

### Tests
A quick and dirty test suite was crafted to make sure these were functioning properly. Each function/method has a test case in the **/tests/** directory. The test runner UI has two tabs representing each library's test results:

![Tester Results Screenshot](tester/ui_preview.png)
