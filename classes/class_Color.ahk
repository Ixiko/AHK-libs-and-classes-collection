;==============  Include  ======================================================;

#Include, %A_LineFile%\..\..\Core.ahk

;===============  Class  =======================================================;

Class Color {  ;: https://docs.microsoft.com/en-us/dotnet/api/system.windows.media.colors?redirectedfrom=MSDN&view=netframework-4.8
	Static AliceBlue := 0xF0F8FF
	Static AntiqueWhite := 0xFAEBD7
	Static Aqua := 0x00FFFF
	Static Aquamarine := 0x7FFFD4
	Static Azure := 0xF0FFFF
	Static Beige := 0xF5F5DC
	Static Bisque := 0xFFE4C4
	Static Black := 0x000000
	Static BlanchedAlmond := 0xFFEBCD
	Static Blue := 0x0000FF
	Static BlueViolet := 0x8A2BE2
	Static Brown := 0xA52A2A
	Static BurlyWood := 0xDEB887
	Static CadetBlue := 0x5F9EA0
	Static Chartreuse := 0x7FFF00
	Static Chocolate := 0xD2691E
	Static Coral := 0xFF7F50
	Static CornflowerBlue := 0x6495ED
	Static Cornsilk := 0xFFF8DC
	Static Crimson := 0xDC143C
	Static Cyan := 0x00FFFF
	Static DarkBlue := 0x00008B
	Static DarkCyan := 0x008B8B
	Static DarkGoldenrod := 0xB8860B
	Static DarkGray := 0xA9A9A9
	Static DarkGreen := 0x006400
	Static DarkKhaki := 0xBDB76B
	Static DarkMagenta := 0x8B008B
	Static DarkOliveGreen := 0x556B2F
	Static DarkOrange := 0xFF8C00
	Static DarkOrchid := 0x9932CC
	Static DarkRed := 0x8B0000
	Static DarkSalmon := 0xE9967A
	Static DarkSeaGreen := 0x8FBC8F
	Static DarkSlateBlue := 0x483D8B
	Static DarkSlateGray := 0x2F4F4F
	Static DarkTurquoise := 0x00CED1
	Static DarkViolet := 0x9400D3
	Static DeepPink := 0xFF1493
	Static DeepSkyBlue := 0x00BFFF
	Static DimGray := 0x696969
	Static DodgerBlue := 0x1E90FF
	Static Firebrick := 0xB22222
	Static FloralWhite := 0xFFFAF0
	Static ForestGreen := 0x228B22
	Static Fuchsia := 0xFF00FF
	Static Gainsboro := 0xDCDCDC
	Static GhostWhite := 0xF8F8FF
	Static Gold := 0xFFD700
	Static Goldenrod := 0xDAA520
	Static Gray := 0x808080
	Static Green := 0x008000
	Static GreenYellow := 0xADFF2F
	Static Honeydew := 0xF0FFF0
	Static HotPink := 0xFF69B4
	Static IndianRed := 0xCD5C5C
	Static Indigo := 0x4B0082
	Static Ivory := 0xFFFFF0
	Static Khaki := 0xF0E68C
	Static Lavender := 0xE6E6FA
	Static LavenderBlush := 0xFFF0F5
	Static LawnGreen := 0x7CFC00
	Static LemonChiffon := 0xFFFACD
	Static LightBlue := 0xADD8E6
	Static LightCoral := 0xF08080
	Static LightCyan := 0xE0FFFF
	Static LightGoldenrodYellow := 0xFAFAD2
	Static LightGray := 0xD3D3D3
	Static LightGreen := 0x90EE90
	Static LightPink := 0xFFB6C1
	Static LightSalmon := 0xFFA07A
	Static LightSeaGreen := 0x20B2AA
	Static LightSkyBlue := 0x87CEFA
	Static LightSlateGray := 0x778899
	Static LightSteelBlue := 0xB0C4DE
	Static LightYellow := 0xFFFFE0
	Static Lime := 0x00FF00
	Static LimeGreen := 0x32CD32
	Static Linen := 0xFAF0E6
	Static Magenta := 0xFF00FF
	Static Maroon := 0x800000
	Static MediumAquamarine := 0x66CDAA
	Static MediumBlue := 0x0000CD
	Static MediumOrchid := 0xBA55D3
	Static MediumPurple := 0x9370DB
	Static MediumSeaGreen := 0x3CB371
	Static MediumSlateBlue := 0x7B68EE
	Static MediumSpringGreen := 0x00FA9A
	Static MediumTurquoise := 0x48D1CC
	Static MediumVioletRed := 0xC71585
	Static MidnightBlue := 0x191970
	Static MintCream := 0xF5FFFA
	Static MistyRose := 0xFFE4E1
	Static Moccasin := 0xFFE4B5
	Static NavajoWhite := 0xFFDEAD
	Static Navy := 0x000080
	Static OldLace := 0xFDF5E6
	Static Olive := 0x808000
	Static OliveDrab := 0x6B8E23
	Static Orange := 0xFFA500
	Static OrangeRed := 0xFF4500
	Static Orchid := 0xDA70D6
	Static PaleGoldenrod := 0xEEE8AA
	Static PaleGreen := 0x98FB98
	Static PaleTurquoise := 0xAFEEEE
	Static PaleVioletRed := 0xDB7093
	Static PapayaWhip := 0xFFEFD5
	Static PeachPuff := 0xFFDAB9
	Static Peru := 0xCD853F
	Static Pink := 0xFFC0CB
	Static Plum := 0xDDA0DD
	Static PowderBlue := 0xB0E0E6
	Static Purple := 0x800080
	Static Red := 0xFF0000
	Static RosyBrown := 0xBC8F8F
	Static RoyalBlue := 0x4169E1
	Static SaddleBrown := 0x8B4513
	Static Salmon := 0xFA8072
	Static SandyBrown := 0xF4A460
	Static SeaGreen := 0x2E8B57
	Static SeaShell := 0xFFF5EE
	Static Sienna := 0xA0522D
	Static Silver := 0xC0C0C0
	Static SkyBlue := 0x87CEEB
	Static SlateBlue := 0x6A5ACD
	Static SlateGray := 0x708090
	Static Snow := 0xFFFAFA
	Static SpringGreen := 0x00FF7F
	Static SteelBlue := 0x4682B4
	Static Tan := 0xD2B48C
	Static Teal := 0x008080
	Static Thistle := 0xD8BFD8
	Static Tomato := 0xFF6347
	Static Turquoise := 0x40E0D0
	Static Violet := 0xEE82EE
	Static Wheat := 0xF5DEB3
	Static White := 0xFFFFFF
	Static WhiteSmoke := 0xF5F5F5
	Static Yellow := 0xFFFF00
	Static YellowGreen := 0x9ACD32

	;* Color.ToHSL(rgb)
	ToHSL(rgb) {
		DllCall("Shlwapi\ColorRGBToHLS", "UInt", (rgb & 0xFF0000) >> 16 | rgb & 0xFF00 | (rgb & 0xFF) << 16, "UShort*", h := 0, "UShort*", l := 0, "UShort*", s := 0)

		return ([h*1.5, s/240, l/240])
	}

	;* Color.ToRGB(hue[, saturation, luminosity])
	ToRGB(hue, saturation := 1.0, luminosity := .5) {
		c := DllCall("Shlwapi\ColorHLSToRGB", "UShort", Math.Clamp(hue, 0, 1)*240, "UShort", Math.Clamp(luminosity, 0, 1)*240, "UShort", Math.Clamp(saturation, 0, 1)*240)

		return (Format("{:#08X}", 255 << 24 | (c & 0xFF0000) >> 16 | c & 0xFF00 | (c & 0xFF) << 16))
	}

	;* Color.Random([alpha])
	Random(alpha := "") {
		Static colors := [0xF0F8FF, 0xFAEBD7, 0x00FFFF, 0x7FFFD4, 0xF0FFFF, 0xF5F5DC, 0xFFE4C4, 0x000000, 0xFFEBCD, 0x0000FF, 0x8A2BE2, 0xA52A2A, 0xDEB887, 0x5F9EA0, 0x7FFF00, 0xD2691E, 0xFF7F50, 0x6495ED, 0xFFF8DC, 0xDC143C, 0x00FFFF, 0x00008B, 0x008B8B, 0xB8860B, 0xA9A9A9, 0x006400, 0xBDB76B, 0x8B008B, 0x556B2F, 0xFF8C00, 0x9932CC, 0x8B0000, 0xE9967A, 0x8FBC8F, 0x483D8B, 0x2F4F4F, 0x00CED1, 0x9400D3, 0xFF1493, 0x00BFFF, 0x696969, 0x1E90FF, 0xB22222, 0xFFFAF0, 0x228B22, 0xFF00FF, 0xDCDCDC, 0xF8F8FF, 0xFFD700, 0xDAA520, 0x808080, 0x008000, 0xADFF2F, 0xF0FFF0, 0xFF69B4, 0xCD5C5C, 0x4B0082, 0xFFFFF0, 0xF0E68C, 0xE6E6FA, 0xFFF0F5, 0x7CFC00, 0xFFFACD, 0xADD8E6, 0xF08080, 0xE0FFFF, 0xFAFAD2, 0xD3D3D3, 0x90EE90, 0xFFB6C1, 0xFFA07A, 0x20B2AA, 0x87CEFA, 0x778899, 0xB0C4DE, 0xFFFFE0, 0x00FF00, 0x32CD32, 0xFAF0E6, 0xFF00FF, 0x800000, 0x66CDAA, 0x0000CD, 0xBA55D3, 0x9370DB, 0x3CB371, 0x7B68EE, 0x00FA9A, 0x48D1CC, 0xC71585, 0x191970, 0xF5FFFA, 0xFFE4E1, 0xFFE4B5, 0xFFDEAD, 0x000080, 0xFDF5E6, 0x808000, 0x6B8E23, 0xFFA500, 0xFF4500, 0xDA70D6, 0xEEE8AA, 0x98FB98, 0xAFEEEE, 0xDB7093, 0xFFEFD5, 0xFFDAB9, 0xCD853F, 0xFFC0CB, 0xDDA0DD, 0xB0E0E6, 0x800080, 0xFF0000, 0xBC8F8F, 0x4169E1, 0x8B4513, 0xFA8072, 0xF4A460, 0x2E8B57, 0xFFF5EE, 0xA0522D, 0xC0C0C0, 0x87CEEB, 0x6A5ACD, 0x708090, 0xFFFAFA, 0x00FF7F, 0x4682B4, 0xD2B48C, 0x008080, 0xD8BFD8, 0xFF6347, 0x40E0D0, 0xEE82EE, 0xF5DEB3, 0xFFFFFF, 0xF5F5F5, 0xFFFF00, 0x9ACD32]

		return ((alpha == "") ? (colors[Math.Random.Uniform(0, 139)]) : (alpha << 24 | colors[Math.Random.Uniform(0, 139)]))
	}
}