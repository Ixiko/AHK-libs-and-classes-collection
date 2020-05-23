; Link		: https://www.autohotkey.com/boards/viewtopic.php?f=10&t=76288
; Author	: BNOLI
; Date   	: 05-22-2020

/*
#NoEnv
#SingleInstance, Force

StdL := "22,50 €"					            			        	; amount with decimal places and € sign ("string")
MsgBox % €(StdL)								                	; amount transferred via variable (var)
MsgBox % €("23.544,98")							        	; amount with "thousand point" and decimal places ("string")
MsgBox % €("12,23")								            	; amount with decimal places ("string")
MsgBox % €(9 €)							        		        	; voller betrag ohne nachkofull amount without decimal places (number)mmastellen (number)
MsgBox % Round(€(StdL) + €("2,55€"),2)	        	; invoice with amounts converted in advance, result rounded to two decimal places

array:= ["23.000,99","10000,99","-9.000",15000]		; array of mixed amounts
For each, figure in array
	MsgBox % €(figure)
	Return
*/

€(figure) {
	Return Round(StrReplace(StrReplace(StrReplace(figure,"€",""),".",""),",","."),2) ; Adjust amount by "thousand point (s)", angled point to point.
}