; Title:
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?t=3352
; Author:
; Date:
; for:     	AHK_L

/*


*/

dayOfweek(y, m, d) { ;any date gregorian calendar
	;0,7 - sunday
	;1 - monday // 2 - tuesday // 3 - wednesday // 4 - thursday // 5 - friday // 6 - saturday
	;y - (all digits format) 14 will be fourteen year AD
	y -= (a:= (14 - m) // 12)
  return mod(d + y + y//4 - y//100 + y//400 + 31*(m + 12*a - 2)//12, 7)
}