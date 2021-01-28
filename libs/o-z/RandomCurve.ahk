; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=83048
; Author:	heathen
; Date:   	09.11.2020
; for:     	AHK_L

/*



*/

; It might be the case that you want to generate a random value that is not distributed evenly.
; The RandomCurve function takes AHK Random number as input and outputs a new value based on a nonlinear curve formula.
; Where a normal random number generator might produce a evenly distributed set of results,
; this function will produce results that *clump* toward the middle, high or low end of a given number range.
; Included here are methods that will produce a variety of results.


RandomCurve(min,max) {
	pi:=4 * ATan(1)
	min += 0.0
	max += 0.0
	z := max-min
	x := Rand(0,z) + 0.0
	;y := -x**2/(z/4.0) + 4.0*x + min  ;Quadratic High Range
	;y := (x-z)**2/(z/4.0) + 4.0*x - 3*z + min ;Quadratic Low Range
	y := -cos(x/(z/pi))**3 * (z/2.0) + (z/2.0) + min ; Mid Range
	;y := Sqrt(z*x) + min ; Algebraic high range
	;y := -Sqrt(z*x)+ z + min ; Algebraic low range
	return round(y) ;Round will cause non-uniform results with min and max numbers. Just expect your lowest and highest numbers to be represented more or less than one might expect.
}

Rand(min,max) {
	Random,y,%min%,%max%
	Return y
}