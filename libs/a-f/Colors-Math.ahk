; https://www.autohotkey.com/boards/viewtopic.php?f=76&t=90209&sid=aa87141794f30bfd0c6483956e3bce5e

Brightness(c) {
	r := "0x" SubStr(c, 1, 2), r += 0
	g := "0x" SubStr(c, 3, 2), g += 0
	b := "0x" SubStr(c, 5, 2), b += 0
	return Sqrt(0.241 * r ** 2 + 0.691 * g ** 2 + 0.068 * b ** 2)
}

ColorCompare(c1, c2) {
	ColorRGBToHLS("0x" c1, h1, l1, s1)
	ColorRGBToHLS("0x" c2, h2, l2, s2)

	if h1 < h2
		return -1
	if h1 > h2
		return 1

	if l1 < l2
		return -1
	if l1 > l2
		return 1

	if s1 < s2
		return -1
	if s1 > s2
		return 1

	return 0 ; both HSL are equal
}

ColorRGBToHLS(rgb, ByRef h, ByRef l, ByRef s) {
	static Shlwapi := DllCall("LoadLibrary", "Str", "Shlwapi.dll", "Ptr")
	static ColorRGBToHLS := DllCall("GetProcAddress", "Ptr", Shlwapi, "AStr", "ColorRGBToHLS", "Ptr")

	r := (rgb & 0xFF0000) >> 16
	g := (rgb & 0x00FF00)
	b := (rgb & 0x0000FF) << 16
	bgr := r | b | g ; COLORREF format is 0x00BBGGRR

	DllCall(ColorRGBToHLS, "UInt", bgr, "UShort*", h := 0, "UShort*", l := 0, "UShort*", s := 0)
}