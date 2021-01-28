RgbToHex(input) {
	; Format:
	; RGB(255, 0, 125)
	; RGBA(255, 0, 125, 0.5)

	RegExMatch(Trim(input), "RGBA?\s*\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*(,\s*\d*\.?\d*\s*)?\s*\)", colors)

	SetFormat Integer, H
	red := RemoveHexPart(colors1)
	green := RemoveHexPart(colors2)
	blue := RemoveHexPart(colors3)
	; msgbox % red ", " green ", " blue

	SetFormat Integer, D
	return "#" red green blue
}


HexToRgb(input) {
	; Format: #FF007D

	input := Trim(input, "# ")

	red := "0x" Substr(input, 1, 2)
	green := "0x" Substr(input, 3, 2)
	blue := "0x" Substr(input, 5, 2)

	SetFormat Integer, D
	red := red + 0
	green := green + 0
	blue := blue + 0

	; msgbox % red ", " green ", " blue
	return "RGB(" red ", " green ", " blue ")"
}


RemoveHexPart(input) {
	; Input: 0xFF, Output: FF
	return SubStr("0" SubStr(input + 0, 3), -1)
}
