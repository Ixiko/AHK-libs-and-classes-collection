; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=56259
; Author:	buttshark
; Date:   	25.09.2018
; for:     	AHK_L

/*


*/

gamma(n) {

	static pi := 3.14159265358979323846
	static g := 5.2421875
	static coeffs := [	.99999999999999709182       	, 57.156235665862923517         	, -59.597960355475491248    	, 14.136097974741747174
						,   	-0.49191381609762019978    	, .000033994649984811888699  	, .000046523628927048575665	, -.000098374475304879564677
						,   	.00015808870322491248884 	, -.00021026444172410488319  	, .00021743961811521264320	, -.00016431810653676389022
						,   	.000084418223983852743293	, -.000026190838401581408670	, .0000036899182659531622704]

	if(Mod(n, 1)) 	{
		if(n < 0) 		{
			denom := n
			loop % -floor(n) - 1
				denom *= n + A_Index
			return gamma(Mod(n + 1, 1)) / denom
		}
		else 		{
			n1 := coeffs[1]
			loop % coeffs.length() - 1
				n1 += coeffs[A_Index + 1] / (n + A_Index)
			return n1 * sqrt(2 * pi) / n * n3 := (n + g) ** (n + 0.5) * exp(-n - g)
		}
	}
	else 	{
		if(n > 0) 		{
			ret := 1
			loop % n - 2
				ret *= A_Index + 1
			return ret
		}
	}

}