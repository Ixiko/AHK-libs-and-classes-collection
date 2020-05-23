; Include lib to test
#Include, array_quicksort.ahk
#Include, array_.ahk
#Include, array_base.ahk


; Include test classes
#Include, tester\assert.ahk
#Include, tester\tester.ahk

; Setup Gui
Gui, add, text, Section center w400, Conversion of JavaScript's Array methods to AutoHotkey
gui, add, tab3, xs w400, Array_|Array_Base


; Create test object
tester := new TestRunner("-explicit array_<fn> functions from 'array_.ahk'-")

; Include 'array_' test cases
#Include, tests\
#Include, _common.ahk
#Include, array_concat.test.ahk
#Include, array_every.test.ahk
#Include, array_fill.test.ahk
#Include, array_filter.test.ahk
#Include, array_find.test.ahk
#Include, array_findIndex.test.ahk
#Include, array_forEach.test.ahk
#Include, array_includes.test.ahk
#Include, array_join.test.ahk
#Include, array_lastIndexOf.test.ahk
#Include, array_map.test.ahk
#Include, array_reduce.test.ahk
#Include, array_reduceRight.test.ahk
#Include, array_reverse.test.ahk
#Include, array_slice.test.ahk
#Include, array_some.test.ahk
#Include, array_sort.test.ahk
#Include, array_splice.test.ahk
#Include, array_toString.test.ahk
#Include, array_unshift.test.ahk

; Setup 'array_' results
Gui, Tab, array_
gui, add, edit, r30 w375, % tester.getAllTestResults()


; Create test object
tester := new TestRunner("-Array object extension from 'array_base.ahk'-")

; Extend base Array
Array(prms*) {
    ; Since prms is already an array of the parameters, just give it a
    ; new base object and return it. Using this method, _Array.__New()
    ; is not called and any instance variables are not initialized.
    prms.base := _Array
    return prms
}

; Include 'array_base' test cases
#Include, concat.test.ahk
#Include, every.test.ahk
#Include, fill.test.ahk
#Include, filter.test.ahk
#Include, find.test.ahk
#Include, findIndex.test.ahk
#Include, forEach.test.ahk
#Include, includes.test.ahk
#Include, join.test.ahk
#Include, lastIndexOf.test.ahk 
#Include, map.test.ahk
#Include, reduce.test.ahk
#Include, reduceRight.test.ahk
#Include, reverse.test.ahk
#Include, slice.test.ahk
#Include, some.test.ahk
#Include, sort.test.ahk
#Include, splice.test.ahk
#Include, unshift.test.ahk

; Setup 'array_base' results
Gui, Tab, array_base
gui, add, edit, r30 w375, % tester.getAllTestResults()


; Show Gui
gui, show

return

GuiClose:
	ExitApp
Return