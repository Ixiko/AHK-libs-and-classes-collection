; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=76&t=85035
; Author:
; Date:
; for:     	AHK_L

/*


*/

currencyToDecimal(currency, decsign := ".", dec := 2, decExist := "y") {	; Version 04a
	; @mikeyww on 11 October 2020, revised 12 October 2020 @Albireo
	; 16 January 2021: fixed: comma could not be used as a decimal sign
	; 03 January 2021: added: decimal places
	; https://www.autohotkey.com/boards/viewtopic.php?f=76&t=81983
	if !(decExist = "y")
		currency := currency ".0"
	currency := Trim(currency), RegExMatch(currency, ".*[.,]\K\d{1,2}$", cents)
	If (cents = "")
		currency .= ".", cents := "00"
	RegExMatch(currency, ".+(?=[.,])", dollars)
	Return StrReplace(Format("{:0." dec "f}", RegExReplace(dollars, "[ .,]") "." cents), ".", decsign)
}