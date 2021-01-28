capitalizeString(input) {
	StringLower, input, input ; make entire string lower case
	
	StringUpper, firstLetter, % SubStr(input, 1, 1) ; get first letter from string and capitalize it
	
	return firstLetter . SubStr(input, 2) ; build new string by starting with first letter and adding the rest
}