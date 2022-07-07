;
; cJson.ahk 0.4.0
; Copyright (c) 2021 Philip Taylor (known also as GeekDude, G33kDude)
; https://github.com/G33kDude/cJson.ahk
;
; MIT License
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;

class cJSON {
	static version := "0.4.0"

	BoolsAsInts[]	{
		get		{
			this._init()
			return NumGet(this.lib.bBoolsAsInts, "Int")
		}

		set		{
			this._init()
			NumPut(value, this.lib.bBoolsAsInts, "Int")
			return value
		}
	}

	_init()	{
		if (this.lib)
			return
		this.lib := this._LoadLib()

		; Populate globals
		NumPut(&this.True, this.lib.objTrue, "UPtr")
		NumPut(&this.False, this.lib.objFalse, "UPtr")
		NumPut(&this.Null, this.lib.objNull, "UPtr")

		this.fnGetObj := Func("Object")
		NumPut(&this.fnGetObj, this.lib.fnGetObj, "UPtr")

		this.fnCastString := Func("Format").Bind("{}")
		NumPut(&this.fnCastString, this.lib.fnCastString, "UPtr")
	}

	_LoadLib32Bit() {
		static CodeBase64 := ""
		. "FrYAAQAAAFWJ5VMIgey0AJCLRRSIAIV0////i0UIIIsQodwWAJAAORDCD4SkAHDHRfQBABQA6ziDfQwAgHQhi0X0BeQAgAAPthiLRQyLAACNSAKL"
		. "VQyJCgBmD77TZokQ65ANi0UQACpQAQAOYIkQg0X0ABAFYgAQhMB1uQDGmYlFEKCJVaQBIUQkCBMARgAGBI0AEwQk6FAmHAAAAmkUC17HKAAiAAxc"
		. "uAGX6a1ABwAAxkXzAMQIBItQAJMIi0AQOQjCdUcAEwHHRewFArspAhwMi0XswQDgBAHQiUWwiwEAAUAIi1Xsg8IAATnQD5TAiEUA84NF7AGAffMI"
		. "AHQLhCJF7HzGRYJFJAILB7tbASYFTLt7gpmJTokYjE2AAr2BpwB0UMdF6NELn+gF9Sif6AAEhRiRAp/HReQCe6kFgUEFg2rkhGqsg33kANgPjqmA"
		. "DxOhLA2hhSlQUsdF4Isp4Kop4KcAAkUMginrJ1MgIFUgEGXHRdxCIFTHRaLYiyLYBfioItgAAiNFDIIig0XcgAQYO0BF3H2kD7aAefDAAYTAD4Sf"
		. "wMDCeUAYOUXkfXzknIsMRazAjQCwmIlVnKUNsJgBsGUZRF8XDxNm6YE4yhPpykIEgCEcUYAhD42fQtzUC0DU9AX6KEDUAAJFDETcxCxQkIlVlM0s"
		. "kGEWsUoYmG4r6gvrHMMJizBVEIlU4AjgBFQk0gSBCGAalQg6rSh/Q4GHLQyD+AF1HkEByS4O+hcAYZwCASgDBVAGD4VewjqswJjgQyAgAIFVx0XQ"
		. "yynQ3AUDAAffKcMp0AABJQaJwinpKiQOEKHYRgxizEsMzAUIXwxGDMx3AAElBkMMx6YYgbFDDMixSwzIBQ5fDEYMyAABCyUGQwxkQgwYjUgBCA+2"
		. "lYO/rIsAiRRMJKEsDI8tzfn/GP/pL+QSgS0FdSBLQgZPBVbASekESAUCRHVpQAGNVYAlBNQqFMFcxCIaNyIaIIsAVYiLRcQBwI1EHAIqGg+3ExEa"
		. "xAIBBQYB0A+3AGZAhcB1t+mQomfAsQslwAUTHyXmCsAAAWclBqZnLhyAFb/URgrkAwAB48nkD4xI+v+i/2SeD4S14hW86xX2vD+viAu8AAElBgTE"
		. "4uK34ahh+wgLtP+oiAW0gAALFQN0VLggAbg7RRjUfKRacV1TcX1fcV1xAZIJi138ycOQkGexGgIAcIhXVpCIs1EMRTAUFHEAx0AI0QHHbEAMUgyA"
		. "BAiBBMAhCAeRQcAAYR+D+CB05RHYAAp019gADXTJEdgACXS72AB7D4VGcoI8aAXHRaAyB0UrgY9gAKhjAKxhAKGIQ/AI0C5AGIsVoQDHSEQkIOIB"
		. "RCQgiwAQAI1NkMAzGI1N6qBgABRQARBBlnAA8gsPcADjDEBXcQCJFCT/INCD7CSLQGNFsB/fDd8N3w3fDdcAfQ+EVlQEbhIBhRBvQwkBgyD4InQK"
		. "uGAo/+nivxAKjUWA8WDhB+AtAGn+//+FwHQX/fMBn/AB/wn/Cf8J/wnVADo6xQdCzwWSaZQI3/2rkgjEAhXCAoiDOAhjAv6wsmeAAU8UTwpPCk8K"
		. "1wBILHUSKgXpVHARkLNZFoUJfAtfDIAsCQIxoFWwiVAIw6pUdQJh8wNbD4XwRRk2KIVecMFBsSIyuZMAeJYAfGeUAP8o/CiNYJACIimNTxEFXylf"
		. "KVYphWgRA0X+tNCm8QKvFa8VrxWvFdcAsF0PhLaUj/YppQNAydgf4fvZHxcK9QHgi+rkYwK0YQK6UBUvCi8KNy8KLwrZHxYqBYFc6QHLgAgZIF3F"
		. "CXoJHyAXIBq0FiBSdQJEOA+FY6YD7zWAeEXgkgPgkAPhowQIAOnvBUsUb7QHhv6RIDcFXA+Fqp1NiykHcXvggAGJVeACa107Los5BsAE2wJc3AJd"
		. "VdsCL9sCL9wCL9sCYlXbAgjcAgHbAmbbAgxV3ALT201u2wIK3AKlVdsCctsCDdwCd9sCdBfbAjEe2QJJ2wJ1D4W+EU0+4AOAA7FlQs/pwddnMAEA"
		. "A6DcicLhATobL8R+MNgAOX8iwwKRAkFTAQHQg+gwhQPpgoCpNYP4QH4t2AAARn8fi8a3AEXgD7cAicKLEEUIiwAAkAHQgwToNwFw4GaJEOsCRQWw"
		. "ZoP4YH4tsQg0Zn8fAIwO6FcGdAgKuP8AAOltBgAiAAJAjVACAA6JEACDRdwBg33cAwgPjhYAPoNF4AIU6yYDKkIEKhCNSgUCKggASY1IAolNDQBm"
		. "EgBSCH0iD4X/APz//4tFDItICQEmKcgBdwyLQAgIg+gEASngZscAhQx4uAAQAOndBQQWEQNILXQkiAYvD46EsQOKDzkPj5+ACFDHRdgBgicMgCsU"
		. "EYEDx0AIgSfHQAzzAQOJKHUUgBYBaIo+iBCYMHUjEyCFFemOCykIMH51CUl/Z+tHBQF2UIF3a9oKa8ggAAHZuwqAGffjAAHRicqLTQiLAAmNcQKL"
		. "XQiJADMPtzEPv86JAMvB+x8ByBHaAIPA0IPS/4tNgAyJQQiJUQyJfSR+GgkZfp1FcKsECAAAkIgGLg+FpUNNLIYjZg9uwMAAygBmD2LBZg/WhTJQ"
		. "QBDfrUEBgAjdWCvAakFQBQBU1AFU60IAi1XUidDB4AKAAdABwIlF1EMVgEgCi1UIiQrAG4CYg+gwiYVMwA9C20MBRdTe+YESQFgI3sGFFMgwDsow"
		. "ohFIA2V0EkgDRQ+FjlUAIA0xAwcUdTEJNKrQwADaADTTADSVFTSoxkXTS4ETQAQByhfG60DMBggrdRGGDNCIK00yxGIfwqLMQYzrJyiLVcyHTsNR"
		. "TgHYCIlFzFgVvcdFyBGBYcdFxEIKE4tVQsioMciDRcRAGMQAO0XMfOWAfdOIAHQTQy/bRcijMNBYCOsRRwLJRiLlKAorJHRYIE3YmYnfAA+v+InW"
		. "D6/xgAH+9+GNDBZhVUkkUesdxgYFdWYK2JNwCkQuAwADegwCamVQdA+FqyIawCIaNwCLRcAFAxcAAIAPtgBmD77QJgUoOcJ0ZCrL7UCDRQbAoB7G"
		. "BoTAdboPyrbAhgBAAXQbpQ9DeBOiJ0N46yxDAwkAiwgV4BaChYlQCKEhQgEAi0AEowKJFEAk/9CD7ASDF08XZQ+EqoUXvIUXvAUI9ZoXDo8XvIAX"
		. "xgaaF+iPfYkX2IcXQgGDF0EBixeSQauUbnV/x0UiA+tANItFuAUOExcH6QIX61isFrigFmYGoBb6vecR3OcRQgHjEUEB6hEE6wUiC41l9FteGF9d"
		. "w0ECBQAiVW4Aa25vd25fT2IAamVjdF8ADQoFIAsipQF0cnVlAABmYWxzZQBudQRsbMcFVmFsdWUAXwAwMTIzNDUANjc4OUFCQ0QARUYAVYnlU4Mg"
		. "7FTHRfRmt4tAABSNVfSJVCQUEMdEJBAiK0QkDNHBQ41VDMACCMABAKmHoAXgc8MWGMdF5AIFVEXowwDswwDwgwoQOIlF5GAC484iDBiLVFX0wAgg"
		. "pAsc5AAYweEAjU3kiUyDD8EMb4EPxAPCPCAQBCcPYN4QaYM2CXVgQhBwTvEFCCCLVRCLUkUCBOtiaGYCA3VcYQISUbsJQBZ/uUEFOcMZ0RR8FYYB"
		. "PSABgInQIIPY/30u8BqNVRrgcQ+JcA8xHgQk6AKhAAKFwHQRi00C4EYDiQGJUQSQgItd/MnDkJBwFYCD7Fhmx0XuEx8URfAgFhQBEE0MugDNzMzM"
		. "icj34gjB6gM2SinBicqBEAfAMINt9AEhgMD0ZolURcawA+ICBPfikALoA4lFDACDfQwAdbmNVaGgAfQBwAGQAhCACQYIYhHDCSj+//+QQ0AIsx1g"
		. "x0X4Qi4aA+RFwApF+MHgBAEQ0IlF2AEBQBg5YEX4D41E8BkAC84FUQLY8QxF9MZF84AAg330AHkHkAAwAfdd9FAcQwz0ulBnZmZmQAzqcAn4QgJS"
		. "eSnYicL/DINUbezyDOzxDKaeA8Gg+R+JyimgCPSBBgB1pYB98wB0DoNBAyEDx0RFpi1wJw6mwADADmAC0MZF60OQJeImi0XkjSGM0BAB0A+3MGfk"
		. "jQxpwRYByAM6dZA5CAIAoGaFwHUZJQEMJgGyBhAFAesQobwCdFCEAbwCdAeDReQB6wCHkIB96wAPhDOhZuEfVdgwmdEt6crJJC5AHCEVjKPiAMMU"
		. "UNTGReOAC9yDC9z1ggXUhAvcjwsIAoULIwF9igvjggu8AoELvAKBC9whgwvjAHQPSgvrGEiDRfjyfUAQUgvX+P3//3JIuiy/PWIAckMJYCPoBYEP"
		. "3QDdXY2QLtizAbIOx0XgYwBxIhuNRehQJzABkQehdoQQPeNAFaEAHUEhdUzgJBiNTdgFQUJqDEH/5UgVQSELPws/C8ABMRIAMegEiwAAOokgSZ8L"
		. "nwu/nwufC58LnwufCzY7ZMAJnuaSCtI2NApXSXwYNQFBK0x9bo1FqGhK9hOQQFQP6zeBQ3QgiwBVsItF8AHAjaoc8GoMdJYMcZYTsc4uDaEhwGzw"
		. "IBDBbPABawUDZie3M3M+9HrTE+wAg33sAHlti00m7I9Bj0G4MBAEKdCdqk6+vgOmQcIFdaPhAoPBAkBBvi0A61vPBi/PBl9VrwavBqWEI+s+oUIT"
		. "J41VvtZW6L8Ts78TshPoAXwDJhSp6TU1syoYkgYXegVQgyIAzOl2ctyYBelkk90E5JR1VqIDFK0DXAAdCWsfBhMGEB4G/rNiEwZczx8GHwYfBmgC"
		. "6a7yBBkGepwZBggfBh8GHwZmAmIAAOlMAgBVsQAAi0UQiwCNUAIBAHCJEOk6AgABAIgID7cAZoP4AAx1VoN9DAB0EBSLRQwAjEgCiwBVDIkKZscA"
		. "XFgA6w0K3AJMFw1MZrAA6eoBAZ4JwtgCIoUEwgo8wm4A6YgOYQp2CWENPGFyAOkmFY4wFIkwCbwwdADpNMQAjTCyggiEMB9+YgyGBX5+b6k2DhN1"
		. "Aw0TQxYPt8CLVRAQiVQkCAEKVCQEIIkEJOhsACHrKyXCERjKEYtVwAwSZkSJEI0cRQgCRCqFgMAPhY38//9TIQIiTSGQycOQkFVAieVTg+wkQBBm"
		. "AIlF2MdF8CMXIAAAx0X4gCEA6wAtD7dF2IPgDwCJwotF8AHQDwC2AGYPvtCLRUD4ZolURegBB2YIwegEAQ6DRfgBAIN9+AN+zcdFFPQDwQ4zQiEc"
		. "i0VA9A+3XEXoSiOJEtrQMW30QBD0AHlEx7jBHotd/IEnkA=="
		static Code := false
		if ((A_PtrSize * 8) != 32) {
			Throw Exception("_LoadLib32Bit does not support " (A_PtrSize * 8) " bit AHK, please run using 32 bit AHK")
		}
		; MCL standalone loader https://github.com/G33kDude/MCLib.ahk
		; Copyright (c) 2021 G33kDude, CloakerSmoker (CC-BY-4.0)
		; https://creativecommons.org/licenses/by/4.0/
		if (!Code) {
			CompressedSize := VarSetCapacity(DecompressionBuffer, 3898, 0)
			if !DllCall("Crypt32\CryptStringToBinary", "Str", CodeBase64, "UInt", 0, "UInt", 1, "Ptr", &DecompressionBuffer, "UInt*", CompressedSize, "Ptr", 0, "Ptr", 0, "UInt")
				throw Exception("Failed to convert MCLib b64 to binary")
			if !(pCode := DllCall("GlobalAlloc", "UInt", 0, "Ptr", 9004, "Ptr"))
				throw Exception("Failed to reserve MCLib memory")
			if (DllCall("ntdll\RtlDecompressBuffer", "UShort", 0x102, "Ptr", pCode, "UInt", 9004, "Ptr", &DecompressionBuffer, "UInt", CompressedSize, "UInt*", DecompressedSize, "UInt"))
				throw Exception("Error calling RtlDecompressBuffer",, Format("0x{:08x}", r))
			for k, Offset in [29, 62, 112, 381, 431, 548, 598, 687, 737, 944, 994, 1252, 1279, 1329, 1351, 1378, 1428, 1450, 1477, 1527, 1774, 1824, 1950, 2000, 2039, 2089, 2356, 2367, 3012, 3023, 5347, 5402, 5416, 5461, 5472, 5483, 5536, 5591, 5605, 5650, 5661, 5672, 5721, 5773, 5794, 5805, 5816, 7090, 7101, 7276, 7287, 8861] {
				Old := NumGet(pCode + 0, Offset, "Ptr")
				NumPut(Old + pCode, pCode + 0, Offset, "Ptr")
			}
			if !DllCall("VirtualProtect", "Ptr", pCode, "Ptr", 9004, "UInt", 0x40, "UInt*", OldProtect, "UInt")
				Throw Exception("Failed to mark MCLib memory as executable")
			Exports := {}
			for ExportName, ExportOffset in {"bBoolsAsInts": 0, "dumps": 4, "fnCastString": 2180, "fnGetObj": 2184, "loads": 2188, "objFalse": 5848, "objNull": 5852, "objTrue": 5856} {
				Exports[ExportName] := pCode + ExportOffset
			}
			Code := Exports
		}
		return Code
	}
	_LoadLib64Bit() {
		static CodeBase64 := ""
		. "yLUEAQALAFVIieVICIHswABQSIlNEABIiVUYTIlFIABEiciIRShIixBFEEiLAAgFlR0BAHyLAEg5wg+EIrwAVsdF/AF660cASIN9GAB0LYsARfxI"
		. "mEiNFY0hAE5ED7YEAGZFGAEBYI1IAkiLVRgASIkKZkEPvtAgZokQ6w8AGyCLEACNUAEBCIkQg2hF/AEFP00APwE+hAjAdaUCfYlFoEgIi00gAkON"
		. "RaBJAInISInB6EYjCwCOAnkZEGjHACIABQ5luAGv6RYJAACYxkX7gGWBbFAwgwMkQCAAbHVbAAwBxxRF9AJsNYQQGItFAvSATMHgBUgB0E2ARrCA"
		. "C4ABUBCAC4MMwAEADQCJlMCIRQD7g0X0AYB9+0gAdBMBGWPQCC18CrIDViyCDwhBuFthATEGQbh7AbsPYEQCiY9fgH0oAHRkKMdF8Iy78IKbJhxN"
		. "sbvwwF3DD+Ybx13HZEXswkqlBgInREHsAUlBqIN97AAPjhbKgS+YYSyUMWbHRWrojDHogiFfgCGvMehLgDHDDx+IMesvmSYgIZQmecdF5IImaMeU"
		. "ReDMKODCGL4a8Sg24MAoww9+wA/FKINFAuTABTA7ReR9kAQPtsCQ8AGEwA9chOhA6UFcBpEwQZmNbomcW1C9QAGowA/B0ZilyNGY5Gj+HyUKHDQK"
		. "zOn+Q1SJCunqYALqE0Y44hNBbMdF3Kwm3NmiHooZvyavJtygI+MHrkrgBwiDhRqQiBqQhBqWKYYa1iQsLA3rG2YK0+QJZAm9IHsJOlAuv04BLTSL"
		. "QBiD+AF1J2EwgBAKEFweIHEXA8NiMOMEBg+Fn+BDYwUZYbMJGKAB4Jdpx0Xq2Gwv2GInFwAEfy9tLybYYC/jB9cXZy/pi1oCaQ9tQANkD9RsD9Td"
		. "YgegAAR/D20P1GAP4weqYGkPD2oPAWcP0GwP2tBiByp/D3AP0GAP4wcU6hZoD5NicjCNSJoBQApNQePAEABMgAYhQQqJTCQgwTWt+DD//+loxDPC"
		. "NQV1Vh9kBSw7YiE7PUkFAggPhYOjbahIjZVQcP///+EEimCaxxRFzCIcSCMcLkiLRJV4wAOLRcwAFQEwwEyNBAAbbRxBD3S3EFMczJAACgRQXQ8A"
		. "twBmhcB1nukqqlI8yBwVyBIR3RW3HxUfFe0GyBAV8wOd8AN7WzwqEW+gDu8zD07aBewH0AWoSPF2D4xE+f+i//FcD4Td4gzE7AxyxOII8BTvDO8M"
		. "DQfE+wAH8wOw8ANXczGUcmMBknXJBrzCAobPBs8Gzga8i8AG8wNGyAaDRcBwAUDAO0UwfJCshV0dpIV9r4WvhaiRSIHEcQEMXcOQCgDsog4AVYXA"
		. "ozBBLI2sJIBCpIqNs6SVESRIi4VhAIWgGxS1AEjHQAjyEe2QCYWiAgEKUAAK0wARUYN1ATEpg/ggdNUtAYgKdMItAQ10ry0BCAl0nC0Bew+FKUfC"
		. "VK8HogfHRVDCEMcURVh0AGByAIsFA0fhOAE/QaMF9f7QAMeIRCRAUwJEJDiCAACNVTBIiVQkMFWAAFCBACiQASAht0EqufEBQZIWuqICicGoQf/S"
		. "8Bc4UGxozxA/zxDPEM8QzxDPECcBfQ+shMLyR2kBhfCHrF4BQIP4InQKuCAQ/3jpZhGBDqG5YAfCHugA9/3//4XAdCL9AwJFAQLvDO8M7wzvDO8M"
		. "y+8MJAE6FQrEEA8ICAjbUijHCzrDC7QDiLIDsDKki40DLEVoxEkCYA1/fxqPDY8Njw2PDY8NJwEszHUdbwdjB+nC0AtAkHOMHdUMug+fEJwQsDkJ"
		. "AbY5i1VoSIlQCA2z0n3KA5MFWw+FZd9CeD8F9DPyyXAA+HQAUkJpEDPD+/kztdEA/zONdlXQxfMz8P8z/zPgGdjh8DNwx4WsMAGBAh8aPx8aHxof"
		. "Gh8aHxonAV0PNoRh45803kdQKCfH+pkpJxUOMQLiJouVcQz1UA1wRCftMBgvDS8NLw0DLw0iAQq2AGaD+A10r0iLAIXAAAAASIsAiA+3AACQCXSc"
		. "DZAILHUkB0hIjVACQQU0iRCDhawAEAFA6ar+//+QDW5dEHQKuP8AAOk+DRcBKhOCAAnIAAlmxwAGCQEjAQtIi1VwSBCJUAi4AAsA6QGDCjwDWSIP"
		. "hRMFGlOxBReJhaACCQRYlQINgwBbB3YIAOlZBA0xSIXAdYRdggwPP1wwD4X2AyE/hFZ1NLcACYI8gROJAkKAPCKWIFzpxwovhDoUI1wXI4BVECMv"
		. "FCMvlxE5kBFipZQRCJcR8gKPEWaUEaoMlxGrkBFulBEKlxGqZJARcpQRDZcRHZARTnSUEUK4kxHWAY8RdTgPhYWKBY6ZxBUAANjHhZwBy8HLO4MM"
		. "gQbBgBHB4ASJwkUKj6aIL35CTQI5fy/HB4NiB8cDAdCD6DDpCYzprqNrKghAfj9NAihGfyyaCjeJCutc1c0HYC8KZjwKVyoKhHkUtQjXKYNCKAGD"
		. "vSHBAAMPjrhAmkiDUSIIAus64wd16QcQuEiNSucHIYojPkggPpqNAxMSUC5gl5D7QAvFRZJIJgcpyEiCFuMCwEAISIPoBMs8dReJI6XXB28xLXQu"
		. "bj4YD44MiqfkPg+P9XHgoMeFmMEgh6YADxSZBqjHQCAgsAx1IuMG56Ek36KDBjB1ITjTCk1+IXAOMA+OidACOX8YdutMhigAvYnQSADB4AJIAdBI"
		. "ATDASYnAaQwgNYuVBWMMCqAHSA+/wEx0AcBgD9AFCCPFTGYfCW4Ofo4lTFMGAABhDuEuD4Xm2BtIPmaAD+/A8kgPKsEUsWEC8g8R4EAGMQXAM0KU"
		. "xDPrbIuVYQGJgtDAGwHQAcCJQgO9+BuYgHcCDOAL4ADScAABEgRmDyjI8g9eAso2BxBACPIPWJbBPAhcEBcPJI5q6h8JYwFldJ4CRQ+F+HePTf0Q"
		. "swIUVyL/Ef8RxqyFkw8qASohkwEBTweJQwfrMj0DK3Uf3gRbHy1LEROvIYQhOrI1jGFUWus6i5WxAMYbQXufKZwbRBEeMQNfB18HfhCgx4WIhCLH"
		. "hYRxVQcci5VRASgj4QCDKQICAYtiADsyBnzWZIC9og90Klkh4BfJnVAjjVEDECMaIusolwISSIMaDyryBfIPWS+9JPkdwaXVOotSREiYSEgPrzk4"
		. "6zg6AwW+db8GsAahA78GugYMtyIUAwBTU6EPfPh0D5SF35ITgJUTUouyABGQCY0V0hADD7YEMBBmD75BCpgDOcJ9Ja9LWgWdZqEE8BYWBYABFAWE"
		. "wHWXD7YFAGLk//+EwHQdn8kKqFLSPxURZIUVDgMHGVdLBfwiNkNQiwXuodEAicH/0lMPq/+GIPhmD4XTUQ9FfKEiD0yLRXzSCeewAhv/DvsOW/88"
		. "9w5FfAEttQSbtASQDqCQDnjjt58OTGGeDgSjBpgO8lQHLZMO5IIBlg7BLzP4bigPhaWSDngSBkmLtEV40gkDnw6XDgeSDmzrdG8OZQ54YA6DBLpr"
		. "MSdjDqPsC1X4yOMLQyXqCzXqC+sFUgdIgcTEMLAJXcOQBwCkKQcPAA8AAgAiVW5rbgBvd25fT2JqZUBjdF8ADQoQCSIB1QB0cnVlAGZhAGxzZQBu"
		. "dWxsAecCVmFsdWVfAAAwMTIzNDU2NwA4OUFCQ0RFRgAAVUiJ5UiDxACASIlNEEiJVQAYTIlFIMdF/A0DU0XAURFbKEiNTQAYSI1V/EiJVEAkKMdE"
		. "JCDxAUFiuTEsSYnIcRJgAk2AEP/QSMdF4NIAKMdF6HQA8LQEIEg4iUXg4ABTiaIFTItAUDCLRfxIEAVAUdMCRCQ4hQAwggCN/FXgRgfAV0AHogdi"
		. "FXGWYE0QQf/S0QWE73V+HqIGgZfCGGAG5ADRGOtiYKcCA3VTtQEBDICwSDnQfUBu1AK68Bqif0IbOdB/4FNF8Q8s2ElwiFMH6EE2hcC0dA+gAdiw"
		. "7lADUjAGwBCQSIPsgBge8xVs7GDxFeQVZrIREAWJFEX4oBYUgASLTRiAicq4zczMzDBTAMJIweggicLBBOoDJl4pwYnKiQDQg8Awg238AQSJwjET"
		. "mGaJVEUAwIuitABFGInCuM3MzADMSA+vwkjB6AAgwegDiUUYgwB9GAB1qUiNVQDAi0X8SJhIAQDASAHQSItVIABJidBIicJIiwBNEOgB/v//kIBI"
		. "g8RgXcOQBgAAVUiJ5UiD7HAASIlNEEiJVRgATIlFIMdF/AABAADprgIAAEiLQEUQSItQGAOswUTgBQFXiUXQAQ9jAwBhAR1AMEg5wg8AjZoBAABm"
		. "x0UWuAI0ABpAAFBF8MYARe8ASIN98AAEeQgACgFI913wMMdF6BQAXwCU8EgIumdmAwBIichICPfqSACuwfgCSQCJyEnB+D9MKWbAAbwBE+ACAXgA"
		. "1ikAwUiJyonQg8AAMINt6AGJwosARehImGaJVEVCkJgnSMH5PwAbSAopgV3wAkd1gIB9MO8AdBCBIoMhx0TQRZAtAIChkIIHhKEAiUXAxkXnAMdE"
		. "ReCBiYtF4IAMjUYUAXEBDw+3EAQJDAEBCRhIAcgPtwAgZjnCdW8PFQBmcIXAdR6JC4AXhQsGkYAyAes6kxp0IpMaAHQKg0XgAelmAv9AdoB95wAP"
		. "hDL2AlZFIMB+wC4QuLHAZADpAUABCmw4AWwMjMrDCoVqyMZF39XAOdjDOdiGG8jFOYIE39A5jQrFOccFyznfwjlRDRfBOVENwTnYxjnfAHSCEs04"
		. "6yCDRfwAcoUIOSACOTv9//+ApEFAOoPEcF3DwruBbOyQAQSEvEjEdsAB6E3EAfDBAcCy4AUCwPJADxAA8g8RQIXHVEXAhAjIxAHQwgGND4BnQIqA"
		. "AwEjSIsFhADm//9IiwBMixRQMEADdkEDx0QkokADDUQkOAICiwAfsIlUJDDB7QECKEAGUiABEEG5wQdBwi26AYIKicFB/9JIgfbEAS7wd0DpdwAX"
		. "ABmgeI+jbIEhAAjkXg+Jm39vCXlvuDDgBynQg21u/KJvwIKhb8C/b6lvDzyFemA5YQgjCGBvwC14AOmAXxPfgh8T2oLHJEXsIS7rUOABGAAsdDaL"
		. "qgAL7EIBTI3MBAJiVGArjUhAAWE5BApBAGVmiRDrD0HhU4sAjVABAQGJYBCDRewBFAlHY45t5VRAJzzkOyDpOwMTHAGvD2bHACIA6QjGBEOAyA/p"
		. "9AMjQSENoIP4InVmYwgZcghsXADuF1wOkMMLSg58nUoOXF8OXw7IBekdUA46CUoOCF8OXw7GBWIAbOmq4+FKDpZk5EMODIdfDl8OxgVmAOk3UA76"
		. "IyoHCi8HLwcvBy8H4gKwbgDpxABILQewMwF9JAcNLwcvBy8HLwfiAnJIAOlRLwfpPSoHCR8vBy8HLwcvB+ICdADpHt50cikH9HAkBx9+DfHHAH5+"
		. "fP8H/wf+B+8CzeECde8CpAYPt/FKkW1CGMBOicHojKFINN3DBB7PBGAAYAMSL0cBCAxFEBFKEgyFwA+FfPz7QGhfCXg8PgThoiAv6Wb2SGBU1WaJ"
		. "AGaNBRyS89AFUFTEo+syD8C3RRCD4A/Sp8BVwVBOtgBmD76So5JZwugRAmbB6AQRBNF7AIN9/AN+yMdFIvhgPADrP7MKJYsARfhImEQPt0Rj4Hdu"
		. "C0SJwr8P4FZtwvjQBPgAebslVVUM"
		static Code := false
		if ((A_PtrSize * 8) != 64) {
			Throw Exception("_LoadLib64Bit does not support " (A_PtrSize * 8) " bit AHK, please run using 64 bit AHK")
		}
		; MCL standalone loader https://github.com/G33kDude/MCLib.ahk
		; Copyright (c) 2021 G33kDude, CloakerSmoker (CC-BY-4.0)
		; https://creativecommons.org/licenses/by/4.0/
		if (!Code) {
			CompressedSize := VarSetCapacity(DecompressionBuffer, 4221, 0)
			if !DllCall("Crypt32\CryptStringToBinary", "Str", CodeBase64, "UInt", 0, "UInt", 1, "Ptr", &DecompressionBuffer, "UInt*", CompressedSize, "Ptr", 0, "Ptr", 0, "UInt")
				throw Exception("Failed to convert MCLib b64 to binary")
			if !(pCode := DllCall("GlobalAlloc", "UInt", 0, "Ptr", 11072, "Ptr"))
				throw Exception("Failed to reserve MCLib memory")
			if (DllCall("ntdll\RtlDecompressBuffer", "UShort", 0x102, "Ptr", pCode, "UInt", 11072, "Ptr", &DecompressionBuffer, "UInt", CompressedSize, "UInt*", DecompressedSize, "UInt"))
				throw Exception("Error calling RtlDecompressBuffer",, Format("0x{:08x}", r))
			if !DllCall("VirtualProtect", "Ptr", pCode, "Ptr", 11072, "UInt", 0x40, "UInt*", OldProtect, "UInt")
				Throw Exception("Failed to mark MCLib memory as executable")
			Exports := {}
			for ExportName, ExportOffset in {"bBoolsAsInts": 0, "dumps": 16, "fnCastString": 2608, "fnGetObj": 2624, "loads": 2640, "objFalse": 7616, "objNull": 7632, "objTrue": 7648} {
				Exports[ExportName] := pCode + ExportOffset
			}
			Code := Exports
		}
		return Code
	}
	_LoadLib() {
		return A_PtrSize = 4 ? this._LoadLib32Bit() : this._LoadLib64Bit()
	}

	Dump(obj, pretty := 0)	{
		this._init()
		if (!IsObject(obj))
			throw Exception("Input must be object")
		size := 0
		DllCall(this.lib.dumps, "Ptr", &obj, "Ptr", 0, "Int*", size
		, "Int", !!pretty, "Int", 0, "CDecl Ptr")
		VarSetCapacity(buf, size*2+2, 0)
		DllCall(this.lib.dumps, "Ptr", &obj, "Ptr*", &buf, "Int*", size
		, "Int", !!pretty, "Int", 0, "CDecl Ptr")
		return StrGet(&buf, size, "UTF-16")
	}

	Load(ByRef json)	{
		this._init()

		_json := " " json ; Prefix with a space to provide room for BSTR prefixes
		VarSetCapacity(pJson, A_PtrSize)
		NumPut(&_json, &pJson, 0, "Ptr")

		VarSetCapacity(pResult, 24)

		if (r := DllCall(this.lib.loads, "Ptr", &pJson, "Ptr", &pResult , "CDecl Int")) || ErrorLevel
		{
			throw Exception("Failed to parse JSON (" r "," ErrorLevel ")", -1
			, Format("Unexpected character at position {}: '{}'"
			, (NumGet(pJson)-&_json)//2, Chr(NumGet(NumGet(pJson), "short"))))
		}

		result := ComObject(0x400C, &pResult)[]
		if (IsObject(result))
			ObjRelease(&result)
		return result
	}

	True[]	{
		get
		{
			static _ := {"value": true, "name": "true"}
			return _
		}
	}

	False[]	{
		get
		{
			static _ := {"value": false, "name": "false"}
			return _
		}
	}

	Null[]	{
		get
		{
			static _ := {"value": "", "name": "null"}
			return _
		}
	}
}

