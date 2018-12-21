#include cmp.ahk
msgbox cmp_self([1,1,1]) 	; true
msgbox cmp_self([1,1,1,2])	; false

; cmp(x, op, y)
test [1,1,1], '=', [1,1], 'since all in x equals all in y'
test [1,2], '=', [1,2], 'since 1 != 2'
     
test [1,2,3], '<', [100, 200], 'since all in x are less than all in y'
test [1,2,3], '>=', [-1,1], 'since all in x are greater or equal to all in y'

test(x,op,y,text){
	local
	r := cmp(x, op, y)
	out := 'cmp(x, "' . op . '", y) == ' . (r ? 'true ' : 'false') . '`n' . text . '.`n`n'
	out .= 'x`ty:`n`n'
	disp x,y
	msgbox out
	disp(a,b){		
		if a.length() < b.length()
			swap a,b
		for k, v in a
			out .= v '`t' b[k] '`n' 
	}
	swap(byref a, byref b){
		local
		c := a, a := b, b := c
	}
	
}
