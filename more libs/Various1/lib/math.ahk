#Include %A_LineFile%\..\modules\math
#Include MathHelper.ahk
#Include PrimeFactorProduct.ahk

class Math {

	requires() {
		return [Arrays]
	}

	static MIN_LONG  := -0x8000000000000000
	static MAX_LONG  :=  0x7FFFFFFFFFFFFFFF
	static MIN_INT   := -0x80000000
	static MAX_INT   :=  0x7FFFFFFF
	static MIN_SHORT := -0x8000
	static MAX_SHORT :=  0x7fff

	__new() {
		throw Exception("Instatiation of class '" this.__Class
				. "' is not allowed")
	}

	swap(ByRef firstElement, ByRef secondElement) {
		tempElement := firstElement
		firstElement := secondElement
		secondElement := tempElement
	}

	floor(elements*) {
		OutputDebug %A_ThisFunc% is deprecated. Use Math.min() instead
		return MathHelper.floorCeil("floor", Math.MAX_INT, elements)
	}

	ceil(elements*) {
		OutputDebug %A_ThisFunc% is deprecated. Use Math.max() instead
		return MathHelper.floorCeil("ceil", Math.MIN_INT, elements)
	}

	min(elements*) {
		flatElements := Arrays.flatten([elements])
		return Arrays.reduce(flatElements, Func("min")
				, flatElements[flatElements.minIndex()])
	}

	max(elements*) {
		flatElements := Arrays.flatten([elements])
		return Arrays.reduce(flatElements, Func("max")
				, flatElements[flatElements.minIndex()])
	}

	limitTo(number, minimum, maximum) {
		if (number >= minimum && number <= maximum) {
			return number
		}
		if (number > maximum) {
			return maximum
		} else {
			return minimum
		}
	}

	isEven(number) {
		if number is not integer
		{
			throw Exception("Invalid data type, integer expected"
					, -1, "<" number ">")
		}
		return Mod(number, 2) = 0
	}

	isOdd(number) {
		if number is not integer
		{
			throw Exception("Invalid data type, integer expected"
					, -1, "<" number ">")
		}
		return Mod(number, 2) != 0
	}

	isFractional(number) {
		tempFloatFormat := A_FormatFloat
		SetFormat Float, 0.0
		integerShare := number + 0
		SetFormat Float, %tempFloatFormat%
		return number - integerShare != 0
	}

	root(degreeOfRoot, number) {
		if degreeOfRoot is not integer
		{
			throw Exception("Invalid data type, integer excpected"
					, -1, "<" degreeOfRoot ">")
		}
		if number is not number
		{
			throw Exception("Invalid data type, number expected"
					, -1, "<" number ">")
		}
		tempFloatFormat := A_FormatFloat
		SetFormat Float, 0.14 						; FIXME: with 0.15 Math.Root(5, 2476099) returns 19.000000000000004
		rootOfNumber := number**(1 / degreeOfRoot)
		SetFormat Float, %tempFloatFormat%
		return rootOfNumber
	}

	log(base, exponent) {
		if base is not integer
		{
			throw Exception("Invalid data type, integer excpected"
					, -1, "<" base ">")
		}
		if exponent is not number
		{
			throw Exception("Invalid data type, number excpected"
					, -1, "<" exponent ">")
		}
		tempFloatFormat := A_FormatFloat
		SetFormat Float, 0.16
		logarithm := Log(exponent) / Log(base)
		SetFormat Float, %tempFloatFormat%
		return logarithm
	}

	isPrime(number) {
		if number is not integer
		{
			throw Exception("Invalid data type, integer excpected"
					, -1, "<" number ">")
		}
		if (number == 1) {
			return false
		}
		if (number >= 10) {
			cLastDigit := SubStr(number, 0)
			if cLastDigit not in 1,3,7,9
			{
				return false
			}
		}
		i := 2
		while (i * i <= number) {
			if (Mod(number, i) = 0) {
				return false
			}
			i++
		}
		return true
	}

	integerFactorization(number) {
		if number is not number
		{
			throw Exception("Invalid data type, number expected"
					, -1, "<" number ">")
		}
		if number is not integer
		{
			return new PrimeFactorProduct(number)
		}
		if (Math.isPrime(number)) {
			return new PrimeFactorProduct(number)
		}
		listOfPrimeFactors := new PrimeFactorProduct()
		i := 2
		while (number > 1 && number / i != 1) {
			while (Mod(number, i) = 0) {
				listOfPrimeFactors.add(i)
				number //= i
			}
			if (number > 1) {
				loop {
					i++
				} until (Math.isPrime(i))
			}
		}
		if (number > 1) {
			listOfPrimeFactors.add(i)
		}
		return listOfPrimeFactors
	}

	greatestCommonDivisor(firstNumber="", secondNumber=""
			, useEuklidsAlgorithm=true) {
		if firstNumber is not number
		{
			throw Exception("Invalid data type, number expected"
					, -1, "<" firstNumber ">")
		}
		if secondNumber is not number
		{
			throw Exception("Invalid data type, number expected"
					, -1, "<" secondNumber ">")
		}
		if (useEuklidsAlgorithm) {
			return MathHelper.GCDEuklid(firstNumber, secondNumber)
		}
		greatestCommonDivisor := 1
		listOfPrimeFactorsForFirstNumber
				:= Math.integerFactorization(firstNumber).getList()
		listOfPrimeFactorsForSecondNumber
				:= Math.integerFactorization(secondNumber).getList()
		intersectionOfPrimeFactors := Arrays.distinct(Arrays
				.intersection(listOfPrimeFactorsForFirstNumber
				, listOfPrimeFactorsForSecondNumber))
		while (A_Index <= intersectionOfPrimeFactors.maxIndex()) {
			greatestCommonDivisor *= intersectionOfPrimeFactors[A_Index]
		}
		return greatestCommonDivisor
	}

	lowestCommonMultiple(firstNumber="", secondNumber="") {
		if firstNumber is not number
		{
			throw Exception("Invalid data type, number expected"
					, -1, "<" firstNumber ">")
		}
		if secondNumber is not number
		{
			throw Exception("Invalid data type, number expected"
					, -1, "<" secondNumber ">")
		}
		lowestCommonMultiple := 1
		listOfPrimeFactorsForFirstNumber
				:= Math.integerFactorization(firstNumber).getList()
		listOfPrimeFactorsForSecondNumber
				:= Math.integerFactorization(secondNumber).getList()
		listOfDistinctPrimeFactorsForFirstNumber
				:= Arrays.distinct(listOfPrimeFactorsForFirstNumber)
		occurenceOfFactorOfFirstNumber := 0
		occurenceOfFactorOfSecondNumber := 0
		while (A_Index <= listOfDistinctPrimeFactorsForFirstNumber.maxIndex()) {
			factor := listOfDistinctPrimeFactorsForFirstNumber[A_Index]
			occurenceOfFactorOfFirstNumber := Arrays
					.countOccurences(listOfPrimeFactorsForFirstNumber, factor)
			occurenceOfFactorOfSecondNumber := Arrays
					.countOccurences(listOfPrimeFactorsForSecondNumber, factor)
			if (occurenceOfFactorOfFirstNumber
					>= occurenceOfFactorOfSecondNumber) {
				lowestCommonMultiple *= factor**occurenceOfFactorOfFirstNumber
				Arrays.removeValue(listOfPrimeFactorsForSecondNumber, factor)
			} else {
				lowestCommonMultiple *= factor**occurenceOfFactorOfSecondNumber
				Arrays.removeValue(listOfPrimeFactorsForSecondNumber, factor)
			}
		}
		while (A_Index <= listOfPrimeFactorsForSecondNumber.maxIndex()) {
			lowestCommonMultiple *= listOfPrimeFactorsForSecondNumber[A_Index]
		}
		return lowestCommonMultiple
	}

	; see also: https://docs.oracle.com/javase/specs/jls/se8/html/jls-15.html#jls-15.19
	zeroFillShiftR(number, shift) {
		if (number == 0) {
			return 0
		}
		if (number > 0x7fffffffffffffff) {
			number := (number & ~0x7fffffffffffffff) - 1
		}
		if (number > 0) {
			return number >> shift
		}
		return (number >> shift) + (2 << ~shift)
	}

	numberOfLeadingZeros(number) {
		if (number = 0) {
			return 64
		}
		n := 1
		x := UI(Math.zeroFillShiftR(number, 32))
		if (x = 0) {
			n += 32, x := I(number)
		}
		if (Math.zeroFillShiftR(x, 16) = 0) {
			n += 16, I(x <<= 16)
		}
		if (Math.zeroFillShiftR(x, 24) = 0) {
			n += 8, I(x <<= 8)
		}
		if (Math.zeroFillShiftR(x, 28) = 0) {
			n += 4, I(x <<= 4)
		}
		if (Math.zeroFillShiftR(x, 30) = 0) {
			n += 2, I(x <<= 2)
		}
		n -= I(Math.zeroFillShiftR(x, 31))
		return n
	}

	bitCount(number) {
		number := number - (Math.zeroFillShiftR(number, 1) & 0x5555555555555555)
		number := (number & 0x3333333333333333)
				+ (Math.zeroFillShiftR(number, 2) & 0x3333333333333333)
		number := number + Math.zeroFillShiftR(number, 4) & 0x0f0f0f0f0f0f0f0f
		number := number + Math.zeroFillShiftR(number, 8)
		number := number + Math.zeroFillShiftR(number, 16)
		number := number + Math.zeroFillShiftR(number, 32)
		return I(number & 0x7f)
	}

	numberOfTrailingZeros(number) {
		if (number = 0) {
			return 64
		}
		n := 63
		y := I(number)
		if (y != 0) {
			n := n -32, x := y
		} else {
			x := I(Math.zeroFillShiftR(number, 32))
		}
		y := I(x <<16)
		if (y != 0) {
			n := n -16, x := y
		}
		y := I(x << 8)
		if (y != 0) {
			n := n - 8, x := y
		}
		y := I(x << 4)
		if (y != 0) {
			n := n - 4, x := y
		}
		y := I(x << 2)
		if (y != 0) {
			n := n - 2, x := y
		}
		_x := UI(x << 1)
		return n - (Math.zeroFillShiftR(UI(x << 1), 31))
	}
}

; ahklint-ignore-begin: W007
I(i) {
	return i << 32 >> 32
}

S(s) {
	return s << 48 >> 48
}

L(l) {
	return l << 64 >> 64
}

UI(i) {
	return i & 0xffffffff
}

US(s) {
	return s & 0xffff
}

UL(l) {
	return l & 0xffffffffffffffff
}

SI(i) {
	if (i < 0) {
		return i
	}
	return i-(0xffffffff+1)
}

SS(s) {
	if (s < 0) {
		return s
	}
	return s-(0xffff+1)
}

SL(l) {
	if (l < 0) {
		return l
	}
	return l-(0xffffffffffffffff+1)
}
; ahklint-ignore-end
