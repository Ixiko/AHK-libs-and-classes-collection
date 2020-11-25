; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=83208
; Author:	Xtra
; Date:   	13.11.2020
; for:     	AHK_L

/*	Example use

	pBitmap := Gdip_CreateBitmapFromFile(sFile)
	Gdip_GrayScale(pBitmap)
	Gdip_SaveBitmapToFile(pBitmap, outputFile)
	Gdip_DisposeImage(pBitmap)

*/

;
; Grayscale done with machine code. Requires Gdip bitmap as input.
; Source based on: https://www.codeproject.com/Questions/327689/how-to-convert-coloured-image-to-grayscale-in-C-or
; See solution #2
; -----------------------------------------------------------------------------------------------------
; 	unsigned int Convert_GrayScale(unsigned int * bitmap, int w, int h, int Stride)
; 	{
; 		unsigned int a, r, g, b, gray, ARGB;
; 		int x, y, offset = Stride/4;
; 		for (y = 0; y < h; ++y) {
; 			for (x = 0; x < w; ++x) {
; 				ARGB = bitmap[x+(y*offset)];
; 				a = (ARGB & 0xFF000000) >> 24;
; 				r = (ARGB & 0x00FF0000) >> 16;
; 				g = (ARGB & 0x0000FF00) >> 8;
; 				b = (ARGB & 0x000000FF);
; 				gray = ((217 * r) + (733 * g) + (74 * b)) >> 10;
; 				bitmap[x+(y*offset)] = (gray << 16) | (gray << 8) | gray | (a << 24);
; 			}
; 		}
; 		return 0;
; 	}
; -----------------------------------------------------------------------------------------------------
; Compiled with: https://www.autohotkey.com/boards/viewtopic.php?t=73099
; Thanks Bentchi and Plorence!
;
;
Gdip_GrayScale(pBitmap) {

	static GrayScaleMCode
	if (GrayScaleMCode = "")	{
		if (A_PtrSize = 4) { ; (32bit)
            MCode := ""
			. "2,x86:VVdWU4PsCItMJCiLVCQgjUEDhckPScGLTCQkwfgChcl+"
			. "f4XSfnvB4AKLfCQcMe2JRCQEjQSVAAAAAIkEJI12AIsEJIn7jT"
			. "Q4kI20JgAAAACLE4PDBInQD7bOwegQD7bAacndAgAAacDZAAAA"
			. "AcgPtsqB4gAAAP9ryUoByMHoConBCcLB4AjB4RAJygnQiUP8Od"
			. "51vIPFAQN8JAQ5bCQkdZ+DxAgxwFteX13D"
        }
        else  { ; A_PtrSize = 8 (64bit)
            mCode := ""
			. "2,x64:QVdBVkFVQVRVV1ZTSIPsOA8pdCQgQY1BA0WFyUEPScHB"
			. "+AJFhcCJRCQYD46ABAAAhdIPjngEAABIY0QkGEiJzkUx5EG7Aw"
			. "AAADHtSImMJIAAAABmD28dAAAAAEiJRCQQSMHgAkiJRCQIjUL/"
			. "Zg9vJRAAAACJRCQcZg9vLSAAAADp+QMAAEGJ0oseidgPts/B6B"
			. "APtsBEacndAgAAacDZAAAARAHIRA+2y4HjAAAA/0VryUpEAcjB"
			. "6ApBicEJw8HgCEHB4RBECcsJw0GD+gG4AQAAAIkeD4Q5AQAASI"
			. "uMJIAAAABBjUP+SJhIjRyBRIsLRInIRInJwegQD7bND7bARGnp"
			. "3QIAAGnA2QAAAEQB6EUPtulBgeEAAAD/RWvtSkQB6MHoCkGJxU"
			. "EJwcHgCEHB5RBFCelBCcFBg/oCuAIAAABEiQsPhMsAAABIi4wk"
			. "gAAAAEGNQ/9ImEiNHIFEiwtEichEicnB6BAPts0PtsBEaendAg"
			. "AAacDZAAAARAHoRQ+26UGB4QAAAP9Fa+1KRAHowegKQYnFQQnB"
			. "weAIQcHlEEUJ6UEJwUGD+gS4AwAAAESJC3VhSIuMJIAAAABJY8"
			. "NIjRyBRIsLRInID7bERGno3QIAAESJyMHoEA+2wGnA2QAAAEQB"
			. "6EUPtulBgeEAAAD/RWvtSkQB6MHoCkGJxUEJwcHgCEHB5RBFCe"
			. "lBCcG4BAAAAESJC0Q50g+ESgIAAEGJ1otMJBxEidNFKdZFjU78"
			. "RCnRQcHpAkGDwQGD+QJGjTyNAAAAAA+G6gAAAEiLjCSAAAAATA"
			. "HjRTHSTI0smTHbZkMPb0QVAIPDAWYPb8hmD2/wZg9y0RBmD9vL"
			. "Zg9y1ghmD9vzZg9v0WYPcvIDZg/60WYPb8pmD3LxBWYP+spmD2"
			. "/RZg9vzmYPc9YgZg/09GYPcPYIZg/0zGYPcMkIZg9izmYP/spm"
			. "D2/QZg/bxWYP29NmD2/yZg9y9gNmD/7yZg9y9gJmD/7WZg9y8g"
			. "FmD/7KZg9y0QpmD+vBZg9v0WYPcvEIZg9y8hBmD+vCZg/ryEMP"
			. "KUwVAEmDwhBEOcsPgj7///9EAfhFOfdIiYwkgAAAAA+EMwEAAE"
			. "iLjCSAAAAARI0MOE1jyUqNHIlEixNFidFEidFBwekQD7bNRQ+2"
			. "yURp6d0CAABFacnZAAAARQHpRQ+26kGB4gAAAP9Fa+1KRQHpQc"
			. "HpCkWJzUUJykHB4QhBweUQRQnqRQnKRI1IAUSJE0Q5yg+OwQAA"
			. "AEiLjCSAAAAAQQH5g8ACTWPJSo0ciUSLE0WJ0USJ0UHB6RAPts"
			. "1FD7bJRGnp3QIAAEVpydkAAABFAelFD7bqQYHiAAAA/0Vr7UpF"
			. "AelBwekKRYnNRQnKQcHhCEHB5RBFCepFCco5wkSJE35WAfhIi7"
			. "wkgAAAAEiYTI0Mh0GLGQ+2x0Rp0N0CAACJ2MHoEA+2wGnA2QAA"
			. "AEQB0EQPttOB4wAAAP9Fa9JKRAHQwegKQYnCCcPB4AhBweIQRA"
			. "nTCdhBiQGDxQFIA3QkCEQDXCQYTANkJBBBOeh0MkmJ8kGNe/1J"
			. "weoCSffaQYPiA0E50kQPR9KD+gQPjuX7//9FhdIPhd/7//8xwO"
			. "lt/f//Dyh0JCAxwEiDxDhbXl9dQVxBXUFeQV/DkJCQkJCQkJD/"
			. "AAAA/wAAAP8AAAD/AAAA3QIAAN0CAADdAgAA3QIAAAAAAP8AAA"
			. "D/AAAA/wAAAP8="
        }
		GrayScaleMCode := MCode(mCode)
    }

    Gdip_GetImageDimensions(pBitmap, w, h)
	if !(w && h)
		return -1

	if (E1 := Gdip_LockBits(pBitmap, 0, 0, w, h, stride, scan, bitmapData))
		return -2

	E := DllCall(GrayScaleMCode, "uint", scan, "int", w, "int", h, "int", stride, "cdecl")

	Gdip_UnlockBits(pBitmap, bitmapData)

	return (E = "") ? -3 : E
}

MCode(mcode) {   ; <Bentchi function>
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