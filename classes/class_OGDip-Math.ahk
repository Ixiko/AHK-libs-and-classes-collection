;=====         Auto-execute         =========================;

Global Math := new Math

;* Dmax = 1.7976931348623157e+308 (largest double)
;* Dmin = 2.2250738585072014e-308 (least positive normalized double)
;* Deps = 1.1102230246251565e-016 (smallest double: 1 + Deps > 1)

;=====             Class            =========================;

Class Math {

	;-----          Constructor         -------------------------;

	Static __Precision := 0.16  ;* Maximum precise default AHK internal format.
		, ThrowException := 1

	__Init() {
		SetFormat, FloatFast, % this.__Precision
	}

	;-----           Property           -------------------------;

	__Get(vKey) {
		Switch (vKey) {
			Case "Precision":
				Return, (this.__Precision)

			;* Description:
				;* Euler"s exponential constant.
			Case "E":
				Return, (2.7182818284590452)  ;? ≈ Exp(1)

			;* Description:
				;* The smallest signficant differentiation between two floating point values. Useful as a tolerance when testing if two single precision real numbers approximate each other.
			;* Note:
				;* The smallest 32-bit integer greater than zero is `1/(2^32 - 1)`.
			Case "Epsilon":
				Return, (1.0e-15)

			;* Description:
				;* The angle subtended by the smaller arc when two arcs that make up a circle are in the golden ratio.
			Case "GoldenAngle":
				Return, (2.3999632297286533)  ;? ≈ (4 - 2*Phi)*Pi

			;* Description:
				;* The golden ratio (φ).
			Case "GoldenRatio":
				Return, (1.6180339887498948)  ;? ≈ (1 + Sqrt(5))/2

			;* Math.Log2[vNumber]
			;* Description:
				;* The natural logarithm of 2.
			Case "Log2":
				Return, (0.6931471805599453)

			;* Description:
				;* The base-2 logarithm of E.
			Case "Log2E":
				Return, (1.4426950408889634)

			;* Description:
				;* The natural logarithm of 10.
			Case "Log10":
				Return, (2.3025850929940457)

			;* Description:
				;* The base-10 logarithm of E.
			Case "Log10E":
				Return, (0.4342944819032518)

			;* Description:
				;* (π).
			Case "Pi":
				Return, (3.1415926535897932)  ;? ≈ ACos(-1)

			;* Description:
				;* The ratio of a circle's circumference to its diameter (τ).
			Case "Tau":
				Return, (6.2831853071795865)
		}
	}

	__Set(vKey, vValue) {
		Switch (vKey) {
			Case "Precision":
				ObjRawSet(Math, "__Precision", vValue)

				SetFormat, FloatFast, % vValue
		}
		Return
	}

	;-----            Method            -------------------------;
	;---------------          Comparison          ---------------;

	;* Math.IsBetween(Number, LowerLimit, UpperLimit, ExcludedNumber, ...)
	;* Description:
		;* Determine whether a number is within bounds (inclusive) and is not an excluded number.
	IsBetween(vNumber, vLower, vUpper, oExclude*) {
		For i, v in [oExclude*] {
			If (v == vNumber) {
				Return, (0)
			}
		}

		Return, ((!(vLower == "" || vUpper == "")) ? (vNumber >= vLower && vNumber <= vUpper) : ((vLower == "") ? (vNumber <= vUpper) : (vNumber <= vLower)))
	}

	;* Math.IsEven(Number)
	IsEven(vNumber) {
		Return, (Mod(vNumber, 2) == 0)
	}

	IsHex(vNumber) {
		If vNumber is xdigit
			Return, (1)
		Return, (0)
	}

	;* Math.IsInteger(Number)
	IsInteger(vNumber) {
		Return, (this.IsNumeric(vNumber) && vNumber == Round(vNumber))
	}

	;* Math.IsInteger(Number)
	IsNegativeInteger(vNumber) {
		Return, (vNumber < 0 && this.IsInteger(vNumber))
	}

	;* Math.IsInteger(Number)
	IsPositiveInteger(vNumber) {
		Return, (vNumber >= 0 && this.IsInteger(vNumber))
	}

	;* Math.IsNumeric(Number)
	IsNumeric(vNumber) {
		If vNumber is Number
			Return, (1)
		Return, (0)
	}

	;* Math.IsPrime(Number)
	IsPrime(vNumber) {
		If (vNumber < 2 || vNumber != Round(vNumber)) {
			Return, (0)
		}

		Loop, % Floor(this.Sqrt(vNumber)) {
			If (A_Index > 1 && Mod(vNumber, A_Index) == 0) {
				Return, (0)
			}
		}

		Return, (1)
	}

	;* Math.IsSquare(Number)
	IsSquare(vNumber) {
		Return, (this.IsInteger(this.Sqrt(vNumber)))
	}

	;---------------          Conversion          ---------------;
	;-------------------------             Angle            -----;

	;* Math.ToDegrees(Radians)
	ToDegrees(vTheta) {
		Return, (vTheta*57.2957795130823209)
	}

	;* Math.ToRadians(Degrees)
	ToRadians(vTheta) {
		Return, (vTheta*0.0174532925199433)
	}

	;-------------------------             Base             -----;

	;* Math.ToBase(Number, CurrentBase, TargetBase)
	ToBase(vNumber, vCurrentBase := 10, vTargetBase := 16) {
		Static __IsUnicode := A_IsUnicode ? ["_wcstoui64", "_i64tow"] : ["_strtoui64", "_i64toa"], __Result := VarSetCapacity(__Result, 66, 0)

		If (vNumber < 0) {
			s := "-", vNumber := Math.Abs(vNumber)
		}

		DllCall("msvcrt.dll\" . __IsUnicode[1], "Int64", DllCall("msvcrt.dll\" . __IsUnicode[0], "Str", vNumber, "UInt", 0, "UInt", vCurrentBase, "Int64"), "Str", __Result, "UInt", vTargetBase)

		If (vTargetBase > 10) {
			__Result := "0x" . __Result.ToUpperCase()
		}

		Return, (s . __Result)
	}

	;* Math.ToFloat(Number || [Number, ...])
	ToFloat(vNumber) {
		If (Type(vVariable) == "Array") {
			r := vNumber.Clone()

			For i, v in r {
				If (!this.IsNumeric(v)) {
					r[i]  += 0.0
				}
				Else If (Type(v) == "Array") {
					r[i] := this.ToFloat(v)
				}
			}

			Return, (r)
		}

		Return, (vNumber + 0.0)
	}

	;* Math.ToNumber(Number || [Number, ...])
	ToNumber(vVariable) {
		If (Type(vVariable) == "Array") {
			r := vNumber.Clone()

			For i, v in r {
				If (Type(v) == "Array") {
					r[i] := this.ToNumber(v)
				}
				Else {
					r[i] := Round(v)
				}
			}

			Return, (r)
		}

		Return, (Round(vVariable))
	}

	;---------------          Elementary          ---------------;
	;-------------------------          Exponential         -----;

	;* Math.Exp(Number || [Number, ...])
	;* Description:
		;* Calculate the exponent of a number.
	Exp(vNumber) {
		If (Type(vNumber) == "Array") {
			r := vNumber.Clone()

			For i, v in r {
				If (this.IsNumeric(v)) {
					r[i] := Exp(v)
				}
				Else If (Type(v) == "Array") {
					r[i] := this.Exp(v)
				}
			}

			Return, (r)
		}

		Return, (Exp(vNumber))
	}

	;* Math.Log(vNumber) || Math.Log(Base, Number)
	;* Description:
		;* Calculate the logarithm of a number.
	;* Note:
		;* In AutoHotkey `Ln()` is the natural logarithm and `Log()` is the decadic logarithm.
	Log(oParameters*) {
		vNumber := oParameters[1 + (oParameters.Length() > 1)], vBase := oParameters[(oParameters.Length() > 1)]

		If (Type(vNumber) == "Array") {
			r := vNumber.Clone()

			If (vBase == "") {
				For i, v in r {
					If (this.IsNumeric(v)) {
						If (v > 0) {
							r[i] := Ln(vNumber)
						}
						Else If (this.ThrowException) {
							Throw, (Exception("NaN.", -1, Format("Math.Log({}) is out of bounds.", vNumber.Print())))
						}
					}
					Else If (Type(v) == "Array") {
						r[i] := this.Log(v)
					}
				}
			}
			Else {
				For i, v in r {
					If (this.IsNumeric(v)) {
						If (v > 0) {
							r[i] := Ln(vNumber)/Ln(vBase)
						}
						Else If (this.ThrowException) {
							Throw, (Exception("NaN.", -1, Format("Math.Log({}) is out of bounds.", vNumber.Print())))
						}
					}
					Else If (Type(v) == "Array") {
						r[i] := this.Log(v)
					}
				}
			}

			Return, (r)
		}

		If (vNumber > 0) {
			Return, ((vBase != "") ? (Ln(vNumber)/Ln(vBase)) : (Ln(vNumber)))
		}

		If (this.ThrowException) {
			Throw, (Exception("NaN.", -1, Format("Math.Log({}) is out of bounds.", [oParameters*].Join(", "))))
		}
	}

	;* Math.Log2(Number)
	;* Description:
		;* Calculate the base-2 logarithm of a number.
	Log2(vNumber) {
		If (Type(vNumber) == "Array") {
			r := vNumber.Clone()

			For i, v in r {
				If (this.IsNumeric(v)) {
					If (v > 0) {
						r[i] := Ln(vNumber)/0.6931471805599453
					}
					Else If (this.ThrowException) {
						Throw, (Exception("NaN.", -1, Format("Math.Log2({}) is out of bounds.", vNumber.Print())))
					}
				}
				Else If (Type(v) == "Array") {
					r[i] := this.Log(v)
				}
			}

			Return, (r)
		}

		If (vNumber > 0) {
			Return, (Ln(vNumber)/0.6931471805599453)
		}

		If (this.ThrowException) {
			Throw, (Exception("NaN.", -1, Format("Math.Log2({}) is out of bounds.", vNumber)))
		}
	}

	;* Math.Log10(Number)
	;* Description:
		;* Calculate the base-10 logarithm of a number.
	Log10(vNumber) {
		If (Type(vNumber) == "Array") {
			r := vNumber.Clone()

			For i, v in r {
				If (this.IsNumeric(v)) {
					If (v > 0) {
						r[i] := Log(vNumber)
					}
					Else If (this.ThrowException) {
						Throw, (Exception("NaN.", -1, Format("Math.Log10({}) is out of bounds.", vNumber.Print())))
					}
				}
				Else If (Type(v) == "Array") {
					r[i] := this.Log(v)
				}
			}

			Return, (r)
		}

		If (vNumber > 0) {
			Return, (Log(vNumber))
		}

		If (this.ThrowException) {
			Throw, (Exception("NaN.", -1, Format("Math.Log10({}) is out of bounds.", vNumber)))
		}
	}

	;-------------------------             Root             -----;

	;* Math.CubeRoot(Number || [Number, ...])
	;* Description:
		;* Calculate the cubic root of a number.
	Cbrt(vNumber) {
		If (Type(vNumber) == "Array") {
			r := vNumber.Clone()

			For i, v in r {
				If (this.IsNumeric(v)) {
					r[i] := (v < 0) ? (-(-v)**(1/3)) : (v**(1/3))
				}
				Else If (Type(v) == "Array") {
					r[i] := this.Cbrt(v)
				}
			}

			Return, (r)
		}

		Return, ((vNumber < 0) ? (-(-vNumber)**(1/3)) : (vNumber**(1/3)))
	}

	;* Math.Sqrt(Number || [Number, ...])
	;* Description:
		;* Calculate the square root of a number.
	Sqrt(vNumber) {
		If (Type(vNumber) == "Array") {
			r := vNumber.Clone()

			For i, v in r {
				If (this.IsNumeric(v)) {
					If (v >= 0) {
						r[i] := Sqrt(v)
					}
					Else If (this.ThrowException) {
						Throw, (Exception("NaN.", -1, Format("Math.Sqrt({}) is out of bounds.", vNumber.Print())))
					}
				}
				Else If (Type(v) == "Array") {
					r[i] := this.Sqrt(v)
				}
			}

			Return, (r)
		}

		If (vNumber >= 0) {
			Return, (Sqrt(vNumber))
		}

		If (this.ThrowException) {
			Throw, (Exception("NaN.", -1, Format("Math.Sqrt({}) is out of bounds.", vNumber)))
		}
	}

	;* Math.Surd(Number || [Number, ...], N)
	;* Description:
		;* Calculate the nᵗʰ root of a number.
	Surd(vNumber, vN) {
		If (Type(vNumber) == "Array") {
			r := vNumber.Clone(), c := this.IsEven(vN)

			For i, v in r {
				If (this.IsNumeric(v)) {
					If (!c || v >= 0) {
						r[i] := this.Abs(v)**(1/vN)*((v > 0) - (v < 0))
					}
					Else If (this.ThrowException) {
						Throw, (Exception("NaN.", -1, Format("Math.Surd({}, {}) is out of bounds.", vNumber, vN)))
					}
				}
				Else If (Type(v) == "Array") {
					r[i] := this.Surd(v)
				}
			}

			Return, (r)
		}

		If (!this.IsEven(vN) || vNumber >= 0) {
			Return, (this.Abs(vNumber)**(1/vN)*((vNumber > 0) - (vNumber < 0)))
		}

		If (this.ThrowException) {
			Throw, (Exception("NaN.", -1, Format("Math.Surd({}, {}) is out of bounds.", vNumber, vN)))
		}
	}

	;-------------------------         Trigonometric        -----;

	Sin(vTheta) {
		Return, (DllCall("msvcrt\sin", "Double", vTheta, "Double"))
	}

	ASin(vTheta) {
		If (vTheta > -1 && vTheta < 1) {
			Return, (DllCall("msvcrt\asin", "Double", vTheta, "Double"))  ;* -1 < θ < 1
		}

		If (this.ThrowException) {
			Throw, (Exception("NaN.", -1, Format("Math.ASin({}) is out of bounds.", vTheta)))
		}
	}

	Cos(vTheta) {
		Return, (DllCall("msvcrt\cos", "Double", vTheta, "Double"))
	}

	ACos(vTheta) {
		If (vTheta > -1 && vTheta < 1) {
			Return, (DllCall("msvcrt\acos", "Double", vTheta, "Double"))  ;* -1 < θ < 1
		}

		If (this.ThrowException) {
			Throw, (Exception("NaN.", -1, Format("Math.ACos({}) is out of bounds.", vTheta)))
		}
	}

	Tan(vTheta) {
		Return, (DllCall("msvcrt\tan", "Double", vTheta, "Double"))
	}

	ATan(vTheta) {
		Return, (DllCall("msvcrt\atan", "Double", vTheta, "Double"))
	}

	ATan2(oPoint2) {
		Return, (DllCall("msvcrt\atan2", "Double", oPoint2.y, "Double", oPoint2.x, "Double"))
	}

	Csc(vTheta) {
		If (vTheta != 0) {
			Return, (1/DllCall("msvcrt\sin", "Double", vTheta, "Double"))  ;* θ != 0
		}

		If (this.ThrowException) {
			Throw, (Exception("NaN.", -1, Format("Math.Csc({}) is out of bounds.", vTheta)))
		}
	}

	ACsc(vTheta) {
		If (vTheta != 0) {
			Return, (DllCall("msvcrt\asin", "Double", 1/vTheta, "Double"))  ;* θ != 0
		}

		If (this.ThrowException) {
			Throw, (Exception("NaN.", -1, Format("Math.ACsc({}) is out of bounds.", vTheta)))
		}
	}

	Sec(vTheta) {
		Return, (1/DllCall("msvcrt\cos", "Double", vTheta, "Double"))
	}

	ASec(vTheta) {
		If (vTheta != 0) {
			Return, (DllCall("msvcrt\acos", "Double", 1/vTheta, "Double"))  ;* θ != 0
		}

		If (this.ThrowException) {
			Throw, (Exception("NaN.", -1, Format("Math.ASec({}) is out of bounds.", vTheta)))
		}
	}

	Cot(vTheta) {
		If (vTheta != 0) {
			Return, (1/DllCall("msvcrt\tan", "Double", vTheta, "Double"))  ;* θ != 0
		}

		If (this.ThrowException) {
			Throw, (Exception("NaN.", -1, Format("Math.Cot({}) is out of bounds.", vTheta)))
		}
	}

	ACot(vTheta) {
		If (vTheta != 0) {
			Return, (DllCall("msvcrt\atan", "Double", 1/vTheta, "Double"))  ;* θ != 0
		}

		If (this.ThrowException) {
			Throw, (Exception("NaN.", -1, Format("Math.ACot({}) is out of bounds.", vTheta)))
		}
	}

	;-------------------------          Hyperbolic          -----;

	SinH(vTheta) {
		Return, (DllCall("msvcrt\sinh", "Double", vTheta, "Double"))
	}

	ASinH(vTheta) {
		Return, (this.Log(vTheta + Sqrt(vTheta**2 + 1)))
	}

	CosH(vTheta) {
		Return, (DllCall("msvcrt\cosh", "Double", vTheta, "Double"))
	}

	ACosH(vTheta) {
		If (vTheta >= 1) {
			Return, (this.Log(vTheta + Sqrt(vTheta**2 - 1)))  ;* θ >= 1
		}

		If (this.ThrowException) {
			Throw, (Exception("NaN.", -1, Format("Math.ACosH({}) is out of bounds.", vTheta)))
		}
	}

	TanH(vTheta) {
		Return, (DllCall("msvcrt\tanh", "Double", vTheta, "Double"))
	}

	ATanH(vTheta) {
		If (this.Abs(vTheta) < 1) {
			Return, (0.5*this.Log((1 + vTheta)/(1 - vTheta)))  ;* |θ| < 1
		}

		If (this.ThrowException) {
			Throw, (Exception("NaN.", -1, Format("Math.ATanH({}) is out of bounds.", vTheta)))
		}
	}

	CscH(vTheta) {
		If (vTheta != 0) {
			Return, (1/DllCall("msvcrt\sinh", "Double", vTheta, "Double"))  ;* θ != 0
		}

		If (this.ThrowException) {
			Throw, (Exception("NaN.", -1, Format("Math.CscH({}) is out of bounds.", vTheta)))
		}
	}

	ACscH(vTheta) {
		If (vTheta != 0) {
			Return, (this.Log(1/vTheta + Sqrt(1 + vTheta**2)/Abs(vTheta))) ;* θ != 0
		}

		If (this.ThrowException) {
			Throw, (Exception("NaN.", -1, Format("Math.ACscH({}) is out of bounds.", vTheta)))
		}
	}

	SecH(vTheta) {
		Return, (1/DllCall("msvcrt\cosh", "Double", vTheta, "Double"))
	}

	ASecH(vTheta) {
		If (vTheta > 0 && vTheta <= 1) {
			Return, (this.Log(1/vTheta + Sqrt(1/vTheta**2 - 1)))  ;* 0 < θ <= 1
		}

		If (this.ThrowException) {
			Throw, (Exception("NaN.", -1, Format("Math.ASecH({}) is out of bounds.", vTheta)))
		}
	}

	CotH(vTheta) {
		If (vTheta != 0) {
			Return, (1/DllCall("msvcrt\tanh", "Double", vTheta, "Double"))  ;* θ != 0
		}

		If (this.ThrowException) {
			Throw, (Exception("NaN.", -1, Format("Math.CotH({}) is out of bounds.", vTheta)))
		}
	}

	ACotH(vTheta) {
		If (this.Abs(vTheta) > 1) {
			Return, (0.5*this.Log((vTheta + 1)/(vTheta - 1)))  ;* |θ| > 1
		}

		If (this.ThrowException) {
			Throw, (Exception("NaN.", -1, Format("Math.ACotH({}) is out of bounds.", vTheta)))
		}
	}

	;---------------            Integer           ---------------;
	;-------------------------       Division-related       -----;

	;* Math.GCD(Integer, ..., [Integer, ...])
	;* Description:
		;* Calculates the greatest common divisor of two or more integers.
	GCD(oNumbers*) {
		Static __MCode := [MCode("2,x64:QYnIiciJ0UHB+B/B+R9EMcAxykQpwCnKDx+EAAAAAAA50HQKOcJ9CCnQOdB19vPDKcLr7JCQkJA="), MCode("2,x64:iwGD+gF+V4PqAkyNQQRMjVSRCEGLEEGLCEGJwUHB+R9EMcjB+h8x0SnRicJEKcqJyDnRdRHrGWYPH4QAAAAAACnQOdB0CjnQf/YpwjnQdfaD+AF0CUmDwARNOdB1tfPD")]
		oNumbers := [oNumbers*]

		If (Type(oNumbers[0]) == "Array" || Type(oNumbers[1]) == "Array" || oNumbers.Count() > 2) {
			o := [].Concat(oNumbers*), VarSetCapacity(a, o.Count*4, 0), c := 0

			For i, v in o {
				If (this.IsInteger(v)) {
					NumPut(v, a, (c++)*4, "Int")
				}
				Else If (this.ThrowException) {
					Throw, (Exception("TypeError.", -1, Format("Math.GCD({}) may only contain integers.", oNumbers.Print())))
				}
			}

			Return, (DllCall(__MCode[1], "Int", &a, "Int", c, "Int"))
		}

		If (this.IsInteger(oNumbers[0]) && this.IsInteger(oNumbers[1])) {
			Return, (DllCall(__MCode[0], "Int", oNumbers[0], "Int", oNumbers[1], "Int"))
		}

		If (this.ThrowException) {
			Throw, (Exception("TypeError.", -1, Format("Math.GCD({}) may only contain integers.", oNumbers.Join(", "))))
		}
	}

	;* Math.LCM(Integer, ..., [Integer, ...])
	;* Description:
		;* Calculates the greatest common multiple of two or more integers.
	LCM(oNumbers*) {
		Static __MCode := MCode("2,x64:QYnIiciJ0UHB+B/B+R9EMcAxykQpwCnKDx+EAAAAAAA50HQKOcJ9CCnQOdB19vPDKcLr7JCQkJA=")
		oNumbers := [oNumbers*]

		If (Type(oNumbers[0]) == "Array" || Type(oNumbers[1]) == "Array" || oNumbers.Count() > 2) {
			r := (o := [].Concat(oNumbers*)).Shift()

			For i, v in o {
				If (this.IsInteger(r) && this.IsInteger(v)) {
					r := r*v/DllCall(__MCode, "Int", r, "Int", v, "Int")
				}
				Else If (this.ThrowException) {
					Throw, (Exception("TypeError.", -1, Format("Math.LCM({}) may only contain integers.", oNumbers.Print())))
				}
			}

			Return, (Floor(r))
		}

		If (this.IsInteger(oNumbers[0]) && this.IsInteger(oNumbers[1])) {
			Return, (Floor(oNumbers[0]*oNumbers[2]/DllCall(__MCode, "Int", oNumbers[1], "Int", oNumbers[1], "Int")))
		}

		If (this.ThrowException) {
			Throw, (Exception("TypeError.", -1, Format("Math.LCM({}) may only contain integers.", oNumbers.Join(", "))))
		}
	}

	;-------------------------      Recurrence and Sum      -----;

	;* Math.Factorial(Integer)
	;* Description:
		;* Calculate the factorial of an integer.
	Factorial(vNumber) {
		Static __MCode := MCode("2,x64:hcl+GYPBAboBAAAAuAEAAAAPr8KDwgE5ynX288O4AQAAAMOQkJCQ")

		If (this.IsInteger(vNumber) && vNumber >= 0) {
			Return, (DllCall(__MCode, "Int", vNumber, "Int"))
		}

		If (this.ThrowException) {
			Throw, (Exception("NaN.", -1, Format("Math.Factorial({}) is out of bounds.", vNumber)))
		}
	}

	;* Math.Fibonacci(N)
	;* Description:
		;* Calculate the nᵗʰ Fibonacci number.
	Fibonacci(vN) {
		Static __MCode := MCode("2,x64:hcl+L4PBAboBAAAAuAEAAABFMcDrDWYuDx+EAAAAAABEiciDwgFFjQwAQYnAOdF17/PDMcDDkJA=")

		If (this.IsInteger(vN) && vN >= 0) {
			Return, (DllCall(__MCode, "Int", vN, "Int"))
		}

		If (this.ThrowException) {
			Throw, (Exception("NaN.", -1, Format("Math.Fibonacci({}) is out of bounds.", vN)))
		}
	}

	;---------------       Number Theoretic       ---------------;

	;* Math.Prime(N)
	;* Description:
		;* Calculate the nᵗʰ prime number.
	Prime(vN) {
		Static __MCode := MCode("2,x64:QbkCAAAAg/kBfmJBugEAAABBuQEAAABBu1ZVVVUPHwBBg8ECQYP5A3Q6RInIQffrRInIwfgfKcKNBFJBOcF0KEG4AwAAAOsTDx+EAAAAAABEiciZQff4hdJ0DUGDwAJFOcF/7EGDwgFBOcp1s0SJyMOQkJCQ")

		If (this.IsInteger(vN) && vN > 0) {
			Return, (DllCall(__MCode, "Int", vN, "Int"))
		}

		If (this.ThrowException) {
			Throw, (Exception("NaN.", -1, Format("Math.Prime({}) is out of bounds.", vN)))
		}
	}

	;---------------           Numerical          ---------------;
	;-------------------------          Arithmetic          -----;

	;* Math.Abs(Number || [Number, ...])
	;* Description:
		;* Calculate the absolute value of a number.
	Abs(vNumber) {
		If (Type(vNumber) == "Array") {
			r := vNumber.Clone()

			For i, v in r {
				If (this.IsNumeric(v)) {
					r[i] := Abs(v)

					If (v == -9223372036854775808 && this.ThrowException) {
						Throw, (Exception("Overflow.", -1, Format("Math.Abs({}) has no 64-bit non-negative equal in magnitude.", vNumber.Print())))
					}
				}
				Else If (Type(v) == "Array") {
					r[i] := this.Abs(v)
				}
			}

			Return, (r)
		}

		If (this.IsNumeric(vNumber)) {
			Return, (Abs(vNumber))
		}

		If (vNumber == -9223372036854775808 && this.ThrowException) {
			Throw, (Exception("Overflow.", -1, Format("Math.Abs({}) has no 64-bit non-negative equal in magnitude.", vNumber)))
		}
	}

	;* Math.Clamp(Number || [Number, ...], LowerLimit, UpperLimit)
	;* Description:
		;* Limit a number to a upper and lower value.
	Clamp(vNumber, vLower := -1, vUpper := 1) {
		If (Type(vNumber) == "Array") {
			r := vNumber.Clone()

			If (!(vLower == "" || vUpper == "")) {
				For i, v in r {
					If (this.IsNumeric(v)) {
						r[i] := (v < vLower) ? (vLower) : ((v > vUpper) ? (vUpper) : (v))
					}
					Else If (Type(v) == "Array") {
						r[i] := this.Clamp(v)
					}
				}
			}
			Else If (vLower == "") {
				For i, v in r {
					If (this.IsNumeric(v)) {
						r[i] := (v > vUpper) ? (vUpper) : (v)
					}
					Else If (Type(v) == "Array") {
						r[i] := this.Clamp(v)
					}
				}
			}
			Else {
				For i, v in r {
					If (this.IsNumeric(v)) {
						r[i] := (v < vLower) ? (vLower) : (v)
					}
					Else If (Type(v) == "Array") {
						r[i] := this.Clamp(v)
					}
				}
			}

			Return, (r)
		}

		Return, ((!(vLower == "" || vUpper == "")) ? ((vNumber < vLower) ? (vLower) : ((vNumber > vUpper) ? (vUpper) : (vNumber))) : ((vLower == "") ? ((vNumber > vUpper) ? (vUpper) : (vNumber)) : ((vNumber < vLower) ? (vLower) : (vNumber))))
	}

	;* Math.CopySign(Number1, Number2)
	;* Description:
		;* Copy the sign of Number2 to Number1.
	CopySign(vNumber1, vNumber2) {
		Return, (Abs(vNumber1)*(vNumber2 < 0 ? -1 : 1))
	}

	;* Math.Mod(Number || [Number, ...], Divisor)
	Mod(vNumber, vDivisor) {
		If (Type(vNumber) == "Array") {
			r := vNumber.Clone()

			For i, v in r {
				If (this.IsNumeric(v)) {
					r[i] := Mod(v, vDivisor)
				}
				Else If (Type(v) == "Array") {
					r[i] := this.Mod(v)
				}
			}

			Return, (r)
		}

		Return, (Mod(vNumber, vDivisor))
	}

	;* Math.Sign(Number)
	;* Description:
		;* Calculate the sign of a number.
	Sign(vNumber) {
		Return, ((vNumber > 0) - (vNumber < 0))
	}

	;* Math.Wrap(Number, LowerLimit, UpperLimit)
	Wrap(vNumber, vLower, vUpper) {
		vUpper -= vLower

		Return, (vLower + Mod(vUpper + Mod(vNumber - vLower, vUpper), vUpper))  ;! Return, ((vLower + ((v := Mod(vNumber - vLower, vUpper)) == 0) ? (vUpper) : (Mod(vUpper + v, vUpper))))
	}

	;-------------------------       Integral Rounding      -----;

	;* Math.Ceil(Number || [Number, ...], DecimalPlace)
	;* Description:
		;* Round a number towards plus infinity.
	Ceil(vNumber, vDecimalPlace := 0) {
		p := 10**vDecimalPlace

		If (Type(vNumber) == "Array") {
			r := vNumber.Clone()

			For i, v in r {
				If (this.IsNumeric(v)) {
					r[i] := Ceil(v*p)/p, vDecimalPlace
				}
				Else If (Type(v) == "Array") {
					r[i] := this.Ceil(v, vDecimalPlace)
				}
			}

			Return, (r)
		}

		Return, (Ceil(vNumber*p)/p)
	}

	;* Math.Floor(Number || [Number, ...], DecimalPlace)
	;* Description:
		;* Round a number towards minus infinity.
	Floor(vNumber, vDecimalPlace := 0) {
		p := 10**vDecimalPlace

		If (Type(vNumber) == "Array") {
			r := vNumber.Clone()

			For i, v in r {
				If (this.IsNumeric(v)) {
					r[i] := Floor(v*p)/p
				}
				Else If (Type(v) == "Array") {
					r[i] := this.Floor(v, vDecimalPlace)
				}
			}

			Return, (r)
		}

		Return, (Floor(vNumber*p)/p)
	}

	;* Math.Fix(Number || [Number, ...], DecimalPlace)
	;* Description:
		;* Round a number towards zero.
	Fix(vNumber, vDecimalPlace := 0) {
		p := 10**vDecimalPlace

		If (Type(vNumber) == "Array") {
			r := vNumber.Clone()

			For i, v in r {
				If (this.IsNumeric(v)) {
					r[i] := v < 0 ? Ceil(v*p)/p : Floor(v*p)/p
				}
				Else If (Type(v) == "Array") {
					r[i] := this.Fix(v, vDecimalPlace)
				}
			}

			Return, (r)
		}

		Return, (vNumber < 0 ? Ceil(vNumber*p)/p : Floor(vNumber*p)/p)
	}

	;* Math.Round(Number || [Number, ...], DecimalPlace)
	;* Description:
		;* Round a number towards the nearest integer and strips trailing zeros.
	Round(vNumber, vDecimalPlace := 0) {
		If (Type(vNumber) == "Array") {
			r := vNumber.Clone()

			For i, v in r {
				If (this.IsNumeric(v)) {
					r[i] := Round(v, vDecimalPlace)
				}
				Else If (Type(v) == "Array") {
					r[i] := this.Round(v, vDecimalPlace)
				}
			}

			Return, (r)
		}

		Return, (Round(vNumber, vDecimalPlace))  ;! (RegExReplace(Round(vNumber, vDecimalPlace), "S)(?=\.).*?\K\.?0*$"))
	}

	;-------------------------          Statistical         -----;

	;* Math.Min(Number, [Number, ...], ...)
	;* Description:
		;* Calculate the numerically smallest of two or more numbers.
	Min(oNumbers*) {
		oNumbers := [oNumbers*]

		If (Type(oNumbers[0]) == "Array" || Type(oNumbers[1]) == "Array" || oNumbers.Count() > 2) {
			Return, (Min((oNumbers := oNumbers.Flat())[0], oNumbers*))
		}

		Return, (Min(oNumbers[0], oNumbers[1]))
	}

	;* Math.Max(Number, [Number, ...], ...)
	;* Description:
		;* Calculate the numerically largest of two or more numbers.
	Max(oNumbers*) {
		oNumbers := [oNumbers*]

		If (Type(oNumbers[0]) == "Array" || Type(oNumbers[1]) == "Array" || oNumbers.Count() > 2) {
			Return, (Max((oNumbers := oNumbers.Flat())[0], oNumbers*))
		}

		Return, (Max(oNumbers[0], oNumbers[1]))
	}

	;* Math.Mean(Number, [Number, ...], ...)
	;* Description:
		;* Calculate statistical mean of two or more numbers.
	Mean(oNumbers*) {
		t := c := 0

		For i, v in [].Concat(oNumbers*) {
			If (this.IsNumeric(v)) {
				t += v, c++
			}
		}

		Return, (t/c)
	}

	;* Percent(Number, Percentage)
	Percent(vNumber, vPercentage) {
		Return, (vNumber/100.0*vPercentage)
	}

	;* PercentChange(Number1, Number2)
	PercentChange(vNumber1, vNumber2) {
		n1 := this.Abs(vNumber1), n2 := this.Abs(vNumber2)

		Return, (n1 < n2 ? this.Abs((n1 - n2)/n2*100.0) : (n2 - n1)/n1*100.0)
	}

	;---------------          Probability         ---------------;
	;-------------------------            Normal            -----;

	RandomNormal(vMean := 0, vDeviation := 1.0, vMin := 0.0, vMax := 1.0) {
		Loop, 12 {
			u += Math.Random(-0x7FFFFFFF, 0x7FFFFFFF)*vDeviation + 0x7FFFFFFF  ;? 0x7FFFFFFF = 2**31 - 1
		}

		Return, (vMean/10 + vMin + (vMax - vMin)*u/(24*0x7FFFFFFF))
	}

	;-----      Rejection Sampling      -----;

	;* Math.Ziggurat(Mean, Deviation)
	;* Description:
		;* https://en.wikipedia.org/wiki/Ziggurat_algorithm.
	;* Note:
		;* This algorithm is ~3.5 times faster than the Box Muller transform.
	Ziggurat(vMean := 0, vDeviation := 1.0) {
		Static __K := (v := Math.__Ziggurat()).k, __W := v.w, __F := v.f  ;* Populate the lookup tables.

		Loop {
			u := Math.Random(-0x80000000, 0x7FFFFFFF), i := u & 0xFF

			If (Abs(u) < __K[i]) {  ;* Rectangle. This will be the case for 99.33% of values (512 rectangles would be 99.64%).
				Return, (u*__W[i]*vDeviation + vMean)
			}

			x := u*__W[i]

			If (i == 0) {  ;* Base segment. Sample using a ratio of uniforms.
				While (2*y <= x**2) {
					x := -Ln(Math.Random())*.27366123732975828, y := -Ln(Math.Random())  ;? .27366123732975828 = 1/r
				}

				Return, (((u > 0)*2 - 1)*(3.6541528853610088 + x)*vDeviation + vMean)
			}

			If ((__F[i - 1] - __F[i])*Math.Random() + __F[i] < Exp(-.5*x**2)) {  ;* Wedge.
				Return, (x*vDeviation + vMean)
			}

			;* The wedge was missed; start again.
		}
	}
	__Ziggurat() {
		r := 3.6541528853610088, v := 0.00492867323399, q := Exp(-.5*r**2)  ;? r = start of the tail, v = area of each rectangle
			, k := [(r*(q/v*2147483648.0)), 0], w := [(v/q)/2147483648.0], w[255] := r/2147483648.0, f := [1.0], f[255] := q  ;* Index zero is for the base segment, where Marsaglia and Tsang define this as k[0] = 2^31*r*f(r)/v, w[0] = .5^31*v/f(r), f[0] = 1.0.

		i := 255
		While (--i) {
			x := Sqrt(-2.0*Ln(v/r + f[i + 1]))

			k[i + 1] := ((x/r)*2147483648.0), w[i] := x/2147483648.0, f[i] := Exp(-.5*x**2)

			r := x
		}

		Return, ({"k": k, "w": w, "f": f})
	}

	;-----         Transformation       -----;

	;* Math.MarsagliaPolar(Mean, Deviation)
	;* Description:
		;* https://en.wikipedia.org/wiki/Marsaglia_polar_method.
	;* Note:
		;* This algorithm does not involve any approximations so it has the proper behavior even in the tail of the distribution.
		; It is however moderately expensive since the efficiency of the rejection method is `e = π/4 ≈ 0.785`,
		; so about 21.5% of the uniformly distributed points within the square are discarded.
		; The square root and the logarithm also contribute significantly to the computational cost.
	MarsagliaPolar(vMean := 0, vDeviation := 1.0) {
		Static __Spare

		If (!__Spare) {
			s := 0

			While (s >= 1.0 || s == 0) {  ;* r may not be 0 because log(0) will generate an error.
				u := 2.0*Math.Random() - 1, v := 2.0*Math.Random() - 1
					, s := u**2 + v**2
			}

			__Spare := (s := Sqrt(-2.0*Ln(s)/s))*v, s *= u
		}
		Else {
			Swap(s, __Spare)
		}

		Return, (vMean + vDeviation*s)
	}

	;-------------------------            Uniform           -----;

	;* Math.Random(Min, Max)
	Random(vMin := 0, vMax := 1.0) {
		Random, r, vMin, vMax

		Return, (r)
	}

	;* Description:
		;* Combines (if needed) two random numbers generated by `Random` to provide a random number in any range.
	;* Credit:
		;* Laszlo (https://autohotkey.com/board/topic/19233-64-bit-random-numbers/).
	Random64(vMin := -0x80000000, vMax := 0x7FFFFFFF) {
		d := vMax - vMin

		If (d > 0) {  ;* No overflow.
			If (d <= 0xFFFFFFFF) {  ;* 32-bit case.
				Random, u, -0x80000000, d - 0x80000000

				Return, (u + vMin + 0x80000000)
			}
			Else {
				Loop {  ;* Range < 2^63.
					Random, u1, 0, (1 << (1 + DllCall("ntdll\RtlFindMostSignificantBit", "Int64", d >> 32))) - 1
					Random, u2, -0x80000000, 0x7FFFFFFF
					r := (u1 << 32) | u2 + 0x80000000

					If (r <= d) {
						Return, (r + vMin)  ;! (Math.Random(0, 2147483647) & 0xFFFF << 16 | Math.Random(0, 2147483647) & 0xFFFF)
					}
				}
			}
		}

		Loop {  ;* Range >= 2^63.
			Random, u1, -0x80000000, 0x7FFFFFFF
			Random, u2, -0x80000000, 0x7FFFFFFF
			r := (u1 << 32) | u2 + 0x80000000

			If (vMin <= r && r <= vMax) {
				Return, (r)
			}
		}
	}

	;* Math.RandomBool(Probability)
	RandomBool(vProbability := 0.5) {
		Random, r, 0, 1.0

		Return, (r >= vProbability)
	}

	;* Math.RandomSeed(Seed)
	RandomSeed(vSeed) {
		Random, , vSeed
	}
}