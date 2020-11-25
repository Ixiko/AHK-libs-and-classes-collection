; Link:   	https://www.autohotkey.com/boards/viewtopic.php?t=78120
; Author:	boiler
; Date:   	03.07.2020
; for:     	AHK_L

/*


*/

/*
	Gdip_ExpandColor grows the specified color by one pixel in all directions.
	Helps remove fringe that can result when using a transparent color.

	pBitMap is the pointer to your bitmap which will be modified directly

	color parameter can be RGB or BGR and can include alpha channel or not.
	Alpha channel will be added/changed to be 0xFF.

	Example: Gdip_ExpandColor(pBitmap, 0xA024BA)

	by boiler
	2020-07-03
*/

Gdip_ExpandColor(pBitmap, color) {
	if (A_PtrSize = 4)
		expandColorMCodeBase64 := ""
		. "2,x86:VYnlg+wQgU0MAAAA/8dF+AAAAADrWcdF/AEAAADrRItF"
		. "+A+vRRCJwotF/AHQiUX0i0X0jRSFAAAAAItFCAHQiwA7RQx1GY"
		. "tF9AX///8/jRSFAAAAAItFCAHCi0UMiQKDRfwBi0X8O0UQfLSD"
		. "RfgBi0X4O0UUfJ/HRfgAAAAA61/HRfwAAAAA60eLRRArRfyJwo"
		. "tF+A+vRRAB0IlF9ItF9AX///8/jRSFAAAAAItFCAHQiwA7RQx1"
		. "FItF9I0UhQAAAACLRQgBwotFDIkCg0X8AYtFEIPoATtF/H+ug0"
		. "X4AYtF+DtFFHyZx0X4AAAAAOtcx0X8AAAAAOtHi0UUK0X4D69F"
		. "EInCi0X8AdCJRfSLRfSNFIUAAAAAi0UIAdCLADtFDHUZi1UQi0"
		. "X0AdCNFIUAAAAAi0UIAcKLRQyJAoNF/AGLRfw7RRB8sYNF+AGL"
		. "RRSD6AE7Rfh/mcdF+AEAAADrW8dF/AAAAADrRotF+A+vRRCJwo"
		. "tF/AHQiUX0i0X0jRSFAAAAAItFCAHQiwA7RQx1G4tFEItV9CnC"
		. "idCNFIUAAAAAi0UIAcKLRQyJAoNF/AGLRfw7RRB8soNF+AGLRf"
		. "g7RRR8nZDJww=="
	else
		expandColorMCodeBase64 := ""
		. "2,x64:VUiJ5UiD7BBIiU0QiVUYRIlFIESJTSiBTRgAAAD/x0X4"
		. "AAAAAOtfx0X8AQAAAOtKi0X4D69FIInCi0X8AdCJRfSLRfRIjR"
		. "SFAAAAAEiLRRBIAdCLADtFGHUci0X0g+gBicBIjRSFAAAAAEiL"
		. "RRBIAcKLRRiJAoNF/AGLRfw7RSB8roNF+AGLRfg7RSh8mcdF+A"
		. "AAAADrZcdF/AAAAADrTYtFICtF/InCi0X4D69FIAHQiUX0i0X0"
		. "g+gBicBIjRSFAAAAAEiLRRBIAdCLADtFGHUXi0X0SI0UhQAAAA"
		. "BIi0UQSAHCi0UYiQKDRfwBi0Ugg+gBO0X8f6iDRfgBi0X4O0Uo"
		. "fJPHRfgAAAAA62THRfwAAAAA60+LRSgrRfgPr0UgicKLRfwB0I"
		. "lF9ItF9EiNFIUAAAAASItFEEgB0IsAO0UYdR6LVSCLRfQB0InA"
		. "SI0UhQAAAABIi0UQSAHCi0UYiQKDRfwBi0X8O0UgfKmDRfgBi0"
		. "Uog+gBO0X4f5HHRfgBAAAA62PHRfwAAAAA606LRfgPr0UgicKL"
		. "RfwB0IlF9ItF9EiNFIUAAAAASItFEEgB0IsAO0UYdSCLRSCLVf"
		. "QpwonQicBIjRSFAAAAAEiLRRBIAcKLRRiJAoNF/AGLRfw7RSB8"
		. "qoNF+AGLRfg7RSh8lZBIg8QQXcOQ"

	expandColorMCode := BentschiMCode(expandColorMCodeBase64)
	Gdip_GetImageDimensions(pBitmap, w, h)
	Gdip_LockBits(pBitmap, 0, 0, w, h, stride, scan, bitmapData)
	DllCall(expandColorMCode, "uint", scan, "uint", color, "int", w, "int", h, "cdecl")
	Gdip_UnlockBits(pBitmap, bitmapData)
}

BentschiMCode(mcode)
{
  static e := {1:4, 2:1}, c := (A_PtrSize=8) ? "x64" : "x86"
  if (!regexmatch(mcode, "^([0-9]+),(" c ":|.*?," c ":)([^,]+)", m))
    return
  if (!DllCall("crypt32\CryptStringToBinary", "str", m3, "uint", 0, "uint", e[m1], "ptr", 0, "uint*", s, "ptr", 0, "ptr", 0))
    return
  p := DllCall("GlobalAlloc", "uint", 0, "ptr", s, "ptr")
  if (c="x64")
    DllCall("VirtualProtect", "ptr", p, "ptr", s, "uint", 0x40, "uint*", op)
  if (DllCall("crypt32\CryptStringToBinary", "str", m3, "uint", 0, "uint", e[m1], "ptr", p, "uint*", s, "ptr", 0, "ptr", 0))
    return p
  DllCall("GlobalFree", "ptr", p)
}