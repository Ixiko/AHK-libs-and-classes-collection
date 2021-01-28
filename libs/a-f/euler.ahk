; #### ENVIRONMENT SETTINGS ####
SetBatchLines -1	; let the damn thing actually use the processor

; #### Function Definitions ####

SumMultsToLimit(baseNum, limit) {
	loop {
		mult := baseNum * A_Index
		if (mult >= limit) 
			 break
		sum += mult
	}
	return sum
}

SumEvenFibsToLimit(limit) {
	nMinus1 := 1
	n := 1
	iterations := 0
	loop {
		nextN := nMinus1 + n
		if (nextN > limit)
			break

		if (Mod(nextN,2) = 0)
			sum += nextN

		nMinus1 := n
		n := nextN
		iterations++
	}
	MsgBox, %iterations%
	return sum
}

isPrime(number) {
	if (number < 2)
		return FALSE
	if (number = 2)
		return TRUE
	loop % floor(sqrt(number))
	{
		if (Mod(number,A_Index + 1) == 0)
			return FALSE
	}
	return TRUE
}

findLargestPrimeFactor(number) {
	upperBound := floor(sqrt(number))
	largest := 1
	
	loop % upperBound - 1
	{
		curVal := A_Index + 1
		if (mod(number, curVal) = 0) {
			; this is a factor
			if (isPrime(curVal) = TRUE && curVal > largest) {
				largest := curVal
			} else if (isPrime(number / curval) && curval > largest) {
				largest := number / curval
			}
		}
	}
	return largest
}

sumPrimesUnderLimit(number) {
	current := 1
	end := floor(sqrt(number))
	loop, % number - 1
	{
		numbers%A_Index% := ++current
	}

	currentPrime := 2
	currentIndex := 1
	number--
	loop
	{
		if (currentPrime > end)
			break
		loop
		{
			if (currentIndex > number)
				break
			if (numbers%currentIndex% != 0 && numbers%currentIndex% != currentPrime && mod(numbers%currentIndex%, currentPrime) = 0) {
				numbers%currentIndex% := 0
			}
			currentIndex += currentPrime
		}

		loop, %number%
		{
			;MsgBox, %A_Index%
			if (numbers%A_Index% != 0 && numbers%A_Index% > currentPrime) {
				currentPrime := numbers%A_Index%
				currentIndex := numbers%A_Index% - 1
				break
			}
		}
	}

	primeIndex := 1
	loop, %number%
	{
		if (numbers%A_Index% != 0) {
			primes%primeIndex% := numbers%A_Index%
			primeIndex++
		}
	}	

	sum := 0
	loop, %primeIndex%
	{

		sum += primes%A_Index%
	}
	return sum
}
	
	
isPallendromic(number) {
	StringSplit, digits, number
	lPos := 1
	rpos := digits0
	loop % digits0 // 2
	{
		if (digits%lpos% != digits%rpos%)
			return false
		lpos++
		rpos--
		
	}
	return true	
}
	

FindLargestPallendromicNumber(numDigits) {
	startVal := (10**(numDigits)) - 1
	endVal := (10**(numDigits-1))
	largest := 1
	Loop
	{
		current := startVal ; - A_Index
		loop
		{
			
			if (current < endVal)   
				break
			product := startVal * current
			
			if (product < largest)
				break

			if (isPallendromic(product)) {
				if (product > largest) {
					;MsgBox, %product% = %startVal% * %current%
					largest := product
				}
			}
			current--
		}
		startVal--
		if (startVal < endVal)
			break
	}
	return largest
}

FindSmallestNumberDivisibleByMax(max) {
	min := 2
	testVal := 1
	loop
	{
		if (testVal > max)
			break
		if (isPrime(testVal)) {
			min *= testVal
		}
		testVal += 2
	}
	prodPrimes := min
	loop
	{
		if (Mod(min, prodprimes) = 0)
		{
			works := TRUE
			loop, %max%
			{
				if(Mod(min, A_Index) != 0) {
					works := FALSE
					break
				}
			}
		}
		if (works = TRUE)
			return min
		min += 2
	}
			
}

SumOfSquaresUpTo(number) {
	return 	(number*(number+1)*((2*number) + 1)) // 6
}

SquareOfSumUpTo(number) {
	return (((2*number) + (number * (number - 1))) // 2)**2
}

FindNthPrime(n) {
	found := 0
	current := 1
	Loop 
	{
		if (IsPrime(current)) {
			found++
		}
		if (found = n) {
			return current
		}
		current += 2
	}
}

FindLargestProductOfConsecutiveDigits(numDigits, number) {
	index := 1
	largest := 0
	len := StrLen(number)
	if numDigits > len
		return -1
	loop
	{
		currentBlock := SubStr(number, index, numDigits)
		StringSplit, numbers, currentBlock
		product := 1
		;MsgBox, %numbers0%
		loop, %numbers0%
		{
			;foo = numbers%A_Index%
			;MsgBox, %foo%
			product *= numbers%A_Index%
		}
		if (product > largest)
			largest := product
		index++
		if (index + numDigits > len)
			return largest
	}
}

GridMaxProductSearch(inputFile, gridSize, numFactors) {
	currentRow := 1
	currentCol := 1

	; read input in to grid...
	loop, Read, %inputFile%
	{
		currentReadRow := A_LoopReadLine
		StringSplit, thisRow, currentReadRow, %A_Space%
		if (thisRow0 != gridSize) {
			MsgBox, Malformed grid! Exiting...
			return -1
		}

		loop, %gridSize%
		{
			grid%currentRow%_%currentCol% := thisRow%currentCol%
			currentCol++
		}
		currentRow++
		currentCol := 1
	}

	largestProduct := 0

	; scan rows
	loop, %gridSize%
	{
		currentRow := A_Index

		loop, %gridSize%
		{
			startCol := A_Index
			currentProduct := 1

			if ((startCol + numFactors) - 1 > gridSize)
				break

			loop, %numFactors%
			{
				currentCol := (startCol + A_Index) - 1
				;MsgBox, working with grid%currentRow%_%currentCol%
				currentProduct *= grid%currentRow%_%currentCol%
			}

			if (currentProduct > largestProduct)
				largestProduct := currentProduct
				
		}
	}

	; scan cols
	loop, %gridSize%
	{
		currentCol := A_Index

		loop, %gridSize%
		{
			startRow := A_Index
			currentProduct := 1
			if ((startRow + numFactors) - 1 > gridSize)
				break

			loop, %numFactors%
			{
				currentRow := (startRow + A_Index) - 1
				;MsgBox, working with grid%currentRow%_%currentCol%
				currentProduct *= grid%currentRow%_%currentCol%
			}
			if (currentProduct > largestProduct)
				largestProduct := currentProduct
		}
	}

	; scan L-->R diags
	loop, % (gridSize - numFactors) + 1
	{
		startRow := A_Index
		loop
		{
			startCol := A_Index
			currentProduct := 1
			if ((startRow + numFactors) - 1 > gridSize || (startCol + numFactors) - 1 > gridSize)
				break
			loop, %numFactors%
			{
				currentOffset := A_Index - 1
				thisRow := startRow + currentOffset
				thisCol := startCol + currentOffset
				currentProduct *= grid%thisRow%_%thisCol%

			}
			if (currentProduct > largestProduct)
				largestProduct := currentProduct
		}
	}

	; scan R-->L diags
	loop, % (gridSize - numFactors) + 1
	{
		startRow := A_Index + 1
		loop
		{
			startCol := A_Index
			currentProduct := 1

			if ((startCol + numFactors) - 1 > gridSize || (startRow + numFactors) - 1 > gridSize)
				break
			loop, %numFactors%
			{	
				currentOffset := A_Index - 1
				thisRow := startRow - currentOffset
				thisCol := startCol + currentOffset
				if (thisRow < 1 || thisCol < 1)
					break
				currentProduct *= grid%thisRow%_%thisCol%
			}
			if (currentProduct > largestProduct)
				largestProduct := currentProduct
		}
	}
			
	return largestProduct
}

getNthTriangularNumber(n) {
	return ((2*n) + (n*(n-1))) // 2
}

findNumberWithNDivisors(n, start) {
	currentMax := 0
	maxTri := 0
	loop
	{
		 check := A_Index + start
		; generate triangular number
		triangular := getNthTriangularNumber(Check)
		numDivisors := 1	; count the number itself
		loop, % triangular ** .5
		{
			if (mod(triangular, A_Index) == 0)
				numDivisors += 2
		}
		if (numDivisors > currentMax) {
			currentMax := numDivisors
			maxTri := triangular
		}
		if (numDivisors > n)
			break
		;MsgBox, %triangular% has %numDivisors% divisors
	}
	return triangular
}

FirstXDigitsOfSum(inFile, numDigits, x) {
	numNums := 0
	loop, Read, %inFile%
	{
		numNums++
		numbers%numNums% := A_LoopReadLine	
	}

	carryIn := 0
	loop, % numDigits - x
	{
		currentOffsetFromEnd := (A_Index - 1) * - 1
		currentColSum := carryIn
		loop, %numNums%
		{
			currentColSum += SubStr(numbers%A_Index%, currentOffsetFromEnd, 1)
		}
		sumLen := StrLen(currentColSum)
		carryIn := SubStr(currentColSum, 1, sumLen - 1)
	}

	; should have the final carry-in now...
	
	sum := 0
	loop, %numNums%
	{
		sum += SubStr(numbers%A_Index%, 1, x)
	}
	sum += carryIn

	return SubStr(sum, 1, x)
}

LongestSequenceUnderLimit(limit) {

	magicNumber := 0

	Loop, %limit%
	{
		chainLen := 0
		current := A_Index
		n := A_Index
		Loop
		{

			if (n = 1)
				break

			if (mod(n, 2) = 0) {
				; number is even
				n := n // 2
			} else {
				; number is odd
				n := (3 * n) + 1
			}
			chainLen++
		}

		if (chainLen > maxChainLen) {
			;MsgBox, New max: for starting value %current%, chain length = %chainLen%
			magicNumber := current
			maxChainLen := chainLen
		}
	}
	
	return maxChainLen
}

sumDigitsInTwoToNthPower(n) {
	currentProd := 2
	carryIn := 0

	loop, % n - 1
	{
		digitsMultiplied := 0
		carryIn := 0
		prodLen := StrLen(currentProd)
		currentPower := A_Index + 1
		nextProd := ""

		loop
		{
			currentOffsetFromEnd := (A_Index - 1) * -1
			currentDigit := SubStr(currentProd, currentOffsetFromEnd, 1)
			multiple := 2 * currentDigit
			multiple += carryIn
			carryIn := 0
			
			if (multiple > 9) {
				carryIn := SubStr(multiple, 1, 1)
				multiple := SubStr(multiple, 0, 1)
			} 

			nextProd := multiple . nextProd
			digitsMultiplied++

			if (digitsMultiplied = prodLen) {
				if (carryIn != 0)
					nextProd := carryIn . nextProd
				break
			}
		}
		
		currentProd := nextProd
	}
	listvars
	msgbox		
	; sum the digits
	StringSplit, digits, currentProd
	sum := 0
	loop, %digits0%
	{
		sum+= digits%A_Index%
	}

	return sum	
}

countCharactersInSpokenNumber(number) {
	characterCount := 0

	dig1 := "one"
	dig2 := "two"
	dig3 := "three"
	dig4 := "four"
	dig5 := "five"
	dig6 := "six"
	dig7 := "seven"
	dig8 := "eight"
	dig9 := "nine"
	dig10 := "ten"
	dig11 := "eleven"
	dig12 := "twelve"
	dig13 := "thirteen"
	dig14 := "fourteen"
	dig15 := "fifteen"
	dig16 := "sixteen"
	dig17 := "seventeen"
	dig18 := "eighteen"
	dig19 := "nineteen"
	dig20 := "twenty"
	dig30 := "thirty"
	dig40 := "forty"
	dig50 := "fifty"
	dig60 := "sixty"
	dig70 := "seventy"
	dig80 := "eighty"
	dig90 := "ninety"
	dig100 := "hundred"
	dig1000 := "thousand"
	and := "and"

	StringSplit, digits, number
	len := StrLen(number)
	if (len = 3) {
		if (digits2 = 0 && digits3 = 0) {
			characterCount += StrLen(dig100)	; hundred + and
		} else {
			characterCount += StrLen(dig100 . "and")		; hundred
		}
		characterCount += StrLen(dig%digits1%)			; hundreds word
		if (digits2 = 0)
			digits2 := ""
		check := digits2 . digits3
		if (check < 20)	{
			charactercount += StrLen(dig%check%)
		} else {
			tens := digits2 . "0"
			characterCount += StrLen(dig%tens%)
			characterCount += StrLen(dig%digits3%)
		}
	}
	if (len = 2) {
		if (number < 21) {
			characterCount += StrLen(dig%number%)
		} else {
			tens := digits1 . "0"
			characterCount += StrLen(dig%tens%)
			characterCount += StrLen(dig%digits2%)
		}
	}

	if (len = 1) {
		characterCount += StrLen(dig%number%)
	}

	return characterCount			
}

sumCharsInSpokenNumbersToLimit(limit) {
	loop, % limit
	{
		sum += countCharactersInSpokenNumber(A_Index)
	}
	return sum
}

max(a, b) {
	if (a > b)
		return a
	return b
}

maxSumOverPathThroughTriangle(inputFile) {
	depth := 0
	loop, read, %inputFile%,
	{
		depth++
		curRow := A_Index
		inTriangle%A_Index% := A_Index
		loop, parse, A_LoopReadLine, %A_Space%
		{
			thisCoord := curRow . "_" . A_Index
			inTriangle%thisCoord% := A_LoopField
		}
	}

	outTriangle1_1 := inTriangle1_1
	loop % depth - 1
 	{
		thisRow := A_Index + 1
		loop % inTriangle%A_Index% + 1
		{
			myCoord := thisRow . "_" . A_Index
			lparentCoord := thisRow - 1 . "_" . A_Index - 1
			rparentCoord := thisRow - 1 . "_" . A_Index
			lParentVal := outTriangle%lparentCoord%
			rParentVal := outTriangle%rparentCoord%
			myVal := inTriangle%myCoord%
			outTriangle%myCoord% := max(myVal + lParentVal, myVal + rParentVal)
		}
	}

	max := 0
	loop % inTriangle%depth% {
		if (outTriangle%depth%_%A_Index% > max)
			max := outTriangle%depth%_%A_Index%
	}
	return max
}

leftZeroPad(string, toLength) {
	; pads string with zeroes to the left until it's of length b
	numZeroes := toLength - (StrLen(string))
	loop % numZeroes
	{
		string := 0 . string
	}
	return string
}

bigGt(a,b) {
	if (StrLen(a) > StrLen(b))
		return TRUE
	if (StrLen(b) > StrLen(a))
		return FALSE

	; the numbers are of the same length..... do it digit-wise..
	StringSplit, aDigs, a
	StringSplit, bDigs, b

	loop % StrLen(a) {
		if (aDigs%A_index% > bDigs%A_Index%)
			return TRUE
	}
	return FALSE ; they were equal....
}

bigDiff(a,b) {	; doesn't handle ops that result in a negative result properly...
	if (bigGt(a,b) = FALSE) {
		; b was bigger than a -- swap them
		temp := a
		a := b
		b := temp
	}
	; A is now the bigger of the two...
	if (StrLen(a) > StrLen(b))
		b := leftZeroPad(b, StrLen(a))

	StringSplit, aDigs, a
	StringSplit, bDigs, b
	ops := StrLen(a)

	loop % ops {
		curIndex := (ops - A_Index) + 1
		if (aDigs%curIndex% < bDigs%curIndex%) {
			; we'll have to borrow
			bIndex := curIndex - 1
			if (aDigs%bIndex% = 0) {
				aDigs%bIndex% := 10
				nBIndex := bIndex
				loop {
					nBIndex--
					if (aDigs%nBIndex% != 0) {
						aDigs%nBIndex%--
						break
					}
					aDigs%nBIndex% := 9
				}
			}
			aDigs%bIndex%--
			aDigs%curIndex% := 10 + aDigs%curIndex%
		}
		digDiff := aDigs%curIndex% - bDigs%curIndex%
		diff := digDiff . diff
	}
	RegexMatch(diff, "^0*(\d+)$", rdiff)
	
	return rdiff1
}	

bigSum(a,b) {
	; make numbers the same length
	if (StrLen(a) > StrLen(b)) {
		b := leftZeroPad(b, StrLen(a))
	} else if (StrLen(b) > StrLen(a)) {
		a := leftZeroPad(a, StrLen(b))
	}

	numDigs := StrLen(a)
	StringSplit, aDigits, a
	StringSplit, bDigits, b
	sum := ""
	carryIn := 0

	loop % numDigs
	{
		offset := (numDigs - A_Index) + 1
		if (offSet < 1)
			break
		; add the two digits
		aCol := aDigits%offset%
		bCol := bDigits%offset%
		columnSum := aDigits%offset% + bDigits%offset% + carryIn
		carryIn := 0

		if (StrLen(columnSum) > 1) {
			carryIn := SubStr(columnSum,1,1)
			columnSum := SubStr(columnSum,2,1)
		}
		sum := columnSum . sum
	}
	
	if (carryIn != 0)
		sum := carryIn . sum
	return sum
}

bigMult(a,b) {
	if (a > b) {
		top := a
		bot := b
	} else {
		top := b
		bot := a
	}

	topLen := Strlen(top)
	botLen := Strlen(bot)
	StringSplit, topDigits, top
	StringSplit, botDigits, bot
	currentSum := ""

	loop % botLen
	{
		botOffset := (botLen - A_Index) + 1
		numZeroes := A_Index - 1
		botDigit := botDigits%botOffset%
		thisRow := ""
		carryIn := 0

		loop % topLen
		{
			topOffset := (topLen - A_Index) + 1
			if (topOffset < 1)
				break
			topDigit := topDigits%topOffset%
			colProd := (botDigit * topDigit) + carryIn
			;MsgBox, %botDigit% * %topDigit% + %carryIn% = %colProd%
			carryIn := 0

			if (StrLen(colProd) > 1) {
				carryIn := SubStr(colProd,1,1)
				colProd := SubStr(colProd,2,1)
			}

			thisRow := colProd . thisRow
		}
		
		if (carryIn != 0)
			thisRow := carryIn . thisRow
		; add our zeros
		loop % numZeroes
		{
			thisRow .= 0
		}
		;MsgBox, adding %thisRow% + %currentSum%
		currentSum := bigSum(thisRow, currentSum)
	}
		
	return currentSum
}

bigFactorial(n) {
	prod := 1
	loop % n
	{
		prod := bigMult(prod, A_Index)
	}
	return prod
}

sumDigitsInBigFactorial(number) {
	product := bigFactorial(number)
	
	StringSplit, digits, product
	sum := 0

	loop % digits0
	{
		sum += digits%A_Index%
	}
	return sum
}

choose(x, y) {
	a := bigFactorial(x)
	b := bigFactorial(y)
	ab := bigFactorial(x - y)
	
	return (a / (b * (ab)))
}

sumOfProperDivisors(number) {
	upperBound := floor(sqrt(number))
	sum := 0

	loop % upperBound
	{
		if (mod(number, A_Index) = 0) {
			;MsgBox, %A_Index% is a proper divisor of %number%
			sum += A_Index
			if (number // A_Index != A_Index)	; don't want to count perfect square factors twice
				sum += number // A_Index
		}
	}
	; since these are PROPER divisors, subtract out the number itself
	sum -= number
	return sum
}

findSumOfAmicableNumbersUnderLimit(limit) {
	loop % limit
	{
		if (numbers%A_Index% = TRUE)
			continue
		numbers%A_Index% := FALSE
		dA := sumOfProperDivisors(A_Index)
		dB := sumOfProperDivisors(dA)
		if (dB = A_Index && dA != dB) {
			numbers%A_Index% := TRUE
			numbers%dB% := TRUE
		}
	}
	; we now have a list of all the abundant numbers under limit
	sum := 0
	loop % limit
	{
		if (numbers%A_Index% = TRUE)
			sum += A_Index
	}
	return sum
}

isAbundant(number) {
	return number < sumOfProperDivisors(number) ? TRUE : FALSE
}

sumOfNumbersNotSumOfAbundants(limit) {
	
	loop % limit
	{
		abundants%A_Index% := FALSE
		if (isAbundant(A_Index) = TRUE)
			abundants%A_Index% := TRUE
	}

	total := 0

	loop % limit
	{
		isSumOfTwoAbundants := FALSE
		checkNum := A_Index
		if (checkNum < 24) {
			total += checkNum
			continue
		}

		loop % limit
		{
			if (abundants%A_Index% = FALSE)
				continue
			abIndex := checkNum - A_Index
			if (abIndex < 0)
				break
			if (abundants%abIndex% = TRUE ) {
				isSumOfTwoAbundants := TRUE
				break
			}
		}

		if (isSumOfTwoAbundants = FALSE) {
			total += checkNum
		}
	}
		
	return total
}	

scoreString(string) {
	score := 0
	StringUpper, string, string
	StringSplit, chars, string,

	loop %chars0%
	{
		score += Asc(chars%A_Index%) - 64
	}
	return score
}	

totalNameScores(nameFile) {
	FileRead, names, %nameFile%
	if not ErrorLevel
	{
		needle = "
		foo := RegexReplace(names, needle)
		Sort, foo, D,
		StringSplit, namesA, foo,`,
		total := 0
		
		loop % namesA0
		{
			total += scoreString(namesA%A_Index%) * A_Index
		}
		return total
	}
	MsgBox, Error reading %nameFile%
	return
}

fibDigits() {
	term := 2
	nminus1 := 1
	n := 1
	loop {
		term++
		oldN := n
		oldNm1 := nminus1
		n := BigSum(n, nminus1)
		nminus1 := oldN
		if (StrLen(n) > 999)
			return term
	}
}

spiralSumDiagnonals(n) {
	sum := 0
	count := 3
	if (n = 1)
		return 2
	loop
	{
		if (count > n)
			break
		uL := ((count - 1) * count) + 1
		uR := count ** 2
		bL := ((count - 1) ** 2) + 1
		bR := (count * (count - 2)) - (count - 3)
		sum += uL + uR + bL + bR
		count += 2
	}
	return sum + 1
}

findLongestRecurringCycle(d) {
	SetFormat, float, 10.30
	loop % d - 1
	{
		numbers%A_Index% := 1/A_Index
	}
	MsgBox, %numbers3%
	return garbage
}

evalQuadratic(x,a,b) {
	return (x**2) + (a * x) + b
}

testQuadraticPrimeSequence(a, b)
{
	seqLen := 0
	test := 0
	loop
	{
		test := evalQuadratic(A_Index - 1,a,b)
		;MsgBox, Testing %test%
		if (isPrime(test) = FALSE)
			break
		seqLen++
	}
	return seqLen
}
	

quadraticPrimeGenerator(limitA, limitB) {
	a := -1 * limitA
	b := -1 * limitB
	longest := 0
	aLongest := 0
	bLongest := 0

	loop
	{
		numPrimes := 0
		if (a > abs(limitA))
			break
		loop
		{
			if (b > abs(limitB))
				break
			if (isPrime(b) == FALSE) {
				b++
				continue
			}
			n := A_Index - 1
			test := evalQuadratic(n,a,b)
			if (test < 2) {
				b++
				continue
			}

			length := testQuadraticPrimeSequence(a,b)

			if (length > longest) {
				;MsgBox, New Longest! (%a%, %b% produces %length%)
				longest := length
				aLongest := a
				bLongest := b
			}
			length := 0
			b++
		}
		a++
		b := a + 1
	}
	MsgBox, y = x^2 + %aLongest%x + %bLongest% produced %longest% consecutive primes
	return aLongest * bLongest

}

Permute(set,delimeter="",trim="", presc="") 
{ 
	; function by [VxE], returns a newline-seperated list of 
	; all unique permutations of the input set. 
	; Note that the length of the list will be O(N!) 
	
	d := SubStr(delimeter,1,1) 
	StringSplit, m, set, %d%, %trim%

	; Base Case 
	IfEqual, m0, 1, return m1 d presc 
	
	Loop %m0% 
	{ 
		remains := m1 
		Loop % m0 - 2
		{
			x := A_Index + 1, remains .= d m%x%
		}
		list .= Permute(remains, d, trim, m%m0% d presc)"`n" 
		mx := m1 
		Loop % m0 - 1
		{
			x := A_Index + 1, m%A_Index% := m%x% 
		}
		m%m0% := mx 
	} 
	return substr(list, 1, -1) 
}		

findNthLexPermutation(n, input) {
	if (n > bigFactorial(StrLen(input)))
		return ERROR

	permutations := permute(input)
	Sort, permutations
	StringSplit, permArray, permutations, `n
	return permArray%n%
}

bigPow(base, exp) {
	final := base
	loop % exp - 1 {
		final := bigMult(final, base)
	}
	return final
}

Euler29(minA,maxA,minB,maxB) {
	powersList := ""
	currBase := minA
	
	loop {
		if (currBase > maxA)
			break
		currExp := minB
		loop {
			
			if (currExp > maxB)
				break
			thisVal := bigPow(currBase, currExp)
			powersList .= ","thisVal
			currExp++
		}
		currBase ++
	}
	Sort, powersList, UND,
	len := StrLen(powersList)
	powersList := SubStr(powersList, 2, len - 1)
	StringSplit, powers, powersList,`,
	return powers0
}

cheapEuler29(inputFile) {
	FileRead, powerFile, %inputFile%
	StringReplace, powerFile, powerFile, `r`n,, All
	Sort, powerFile, UND,
	StringSplit, garbage, powerFile, `,
	return garbage0
}

sumPowersOfDigits(number, power)
{
	if (number = 1)
		return 0
	StringSplit, digits, number
	sum := 0
	loop % digits0
	{
		sum += digits%A_Index% ** power
	}
	return sum
}		
		

Euler30(power) {
	sum := 0
	limit := power * (9 ** power)
	loop % limit {
		if (A_Index = sumPowersOfDigits(A_Index,power))
			sum += A_Index
	}
	return sum
}

hasCommonDigit(a, b) {
	StringSplit, aDigs, a
	if (InStr(b, aDigs1) != FALSE || InStr(b, aDigs2) != FALSE)
		return TRUE
	return FALSE
}

removeCommonDigit(a,b) {
	StringSplit, aDigs, a
	StringSplit, bDigs, b
	if (aDigs1 = bdigs1)
		return aDigs2/bDigs2
	if (aDigs1 = bDigs2)
		return aDigs2/bDigs1
	if (aDigs2 = bDigs1)
		return aDigs1/bDigs2
	if (aDigs2 = bDigs2)
		return aDigs1/bDigs1
	return 0
}

gcd(a, b) {
	if (b = 0)
		return a
	a := gcd (b, mod(a, b))
}

Euler33() {
	totalNumer := 1
	totalDenom := 1
	loop % 89 {
		curNumer := A_Index + 10
		if (mod(curNumer, 10) = 0)
			continue	; this will only generate trivial examples
		;MsgBox, %curNumer%
		loop % 89 {
			curDenom := A_Index + 10
			if (mod(curDenom, 10) = 0)
				continue
			if ((curNumer / curDenom) > 1)
				continue
			if (curNumer = curDenom)
				continue
			;MsgBox, checking %curNumer%/%curDenom%
			if (hasCommonDigit(curNumer, curDenom) = TRUE) {
				; they have exactly 1 common digit
				thisFrac := removeCommonDigit(curNumer, curDenom)
				if (thisFrac = (curNumer/curDenom)) {
					;MsgBox, %curNumer% / %curDenom% is one of the magic ones
					totalNumer *= curNumer
					totalDenom *= curDenom
				}
			}
		}
	}
	thisGcd := gcd (totalNumer, totalDenom)
	redDenom := totalDenom // thisGcd
	return redDenom
}
			
isPandigital(number) {
	loop % StrLen(number)
	{
		if (InStr(number, A_Index) = FALSE)
			return FALSE
	}
	return TRUE
}

Euler32() {
	panList := ""
	loop {
		thisIndex := A_Index
		if (StrLen(thisIndex) >= 9 || thisIndex > 499999 )
			break
		loop {
			dummy := A_Index

			product := thisIndex * A_Index
			if (StrLen(product) + StrLen(thisIndex) + StrLen(A_Index) > 9)
				break
			if (StrLen(product) + StrLen(thisIndex) + StrLen(A_Index) < 9)
				continue
			string := thisIndex . A_Index . product
			if (isPandigital(string)) {
				;MsgBox, found pandigital: %product% (%thisIndex% * %dummy%)
				panList .= ","product
			}
			
		}
	}
	Sort, panList, UND,
	len := StrLen(panList)
	panList := SubStr(panList, 2, len - 1)
	StringSplit, pans, panList,`,
	sum := 0
	loop % pans0 {
		sum += pans%A_Index%
	}
	return sum
}

getDoomsDay(year) {
	if (year < 2000 && year > 1899)
		magic := 3
	if (year < 2100 && year > 1999)
		magic := 2

	digits := SubStr(year, 3, 2)
	Q := digits // 12
	R := mod(digits, 12)
	S := R // 4
	x := Q + R + S
	doomsDay := mod(x + magic, 7)
	return doomsDay

}

isLeapYear(year) {
	if (mod(year, 100) = 0) {
		;.. a century
		if (mod(year, 400) = 0)
			return TRUE
		return FALSE
	}
	if (mod(year, 4) = 0)
		return TRUE	
	return FALSE
}
				
getDayOfWeek(month, day, year) {
	doomsDay := getDoomsDay(year)
	leap := isLeapYear(year)
	
	month1 := 3 + leap
	month2 := 0 + leap
	month3 := 0
	month4 := 4
	month5 := 9
	month6 := 6
	month7 := 11
	month8 := 8
	month9 := 5
	month10 := 10
	month11 := 7
	month12 := 12
	
	dayNum := mod(day - month%month% + doomsDay + 14, 7)
	return dayNum

}

Euler19() {
	count := 0
	loop % 100 {
		if (A_Index < 10) {
			year := "190" . A_Index
		} else if (A_Index = 100) {
			year := "2000"
		} else {
			year := "19" . A_Index
		}
		loop % 12 {
			;listvars
			;msgbox
			test := getDayOfWeek(A_Index, 1, year)
			if (test = 0)
				count++
		}
	}
	return count
}

sieveEra(limit) {
	; initialize sieve

	current := 1
	end := floor(sqrt(limit))

	loop, % (limit - 1) // 2 {
		current += 2
		numbers%A_Index% := current
	}

	; sift out non-primes

	currentPrime := 2
	currentIndex := 1
	number--
	loop {
		if (currentPrime > end)
			break
		loop {
			if (currentIndex > limit)
				break
			if (numbers%currentIndex% != 0 && numbers%currentIndex% != currentPrime && mod(numbers%currentIndex%, currentPrime) = 0)
				numbers%currentIndex% := ""

			currentIndex += currentPrime
		}

		loop, %limit% {
			if (numbers%A_Index% != "" && numbers%A_Index% > currentPrime) {
				currentPrime := numbers%A_Index%
				currentIndex := (numbers%A_Index% - 1) // 2
				break
			}
		}
	}

	; build concise list of primes

	primeIndex := 1
	loop, %limit% {
		if (numbers%A_Index% != "")
			primeList .= numbers%A_Index% . ","
	}	

	needle := ",+$"
	primeList := "2," . RegexReplace(primeList, needle)
	return primeList
}

checkSieve(limit) {
	primeList := sieveEra(limit)
	StringSplit, primes, primeList, `,
	loop % primes0 {
		if (isPrime(primes%A_Index%) = FALSE)
			return "Your sieve said " . primes%A_Index% . " was prime, it's not..."
	}
	return TRUE
}

cycleNumber(number) {
	cycledNumbers := number . ","
	numberLen := StrLen(number)
	loop % numberLen - 1 {
		number := SubStr(number, 2, numberLen - 1) . SubStr(number,1,1)
		cycledNumbers .= number . ","
	}
	needle := ",+$"
	cycledNumbers := RegexReplace(cycledNumbers, needle)
	return cycledNumbers
}

containsEvenDigitsOrFive(number) {
	return RegexMatch(number, "[24568]") != 0 ? TRUE : FALSE
}

Euler35(limit) {
	primeString := sieveEra(limit)
	StringSplit, primes, primeString, `,
	count := 2	; count 2 and 5, they get left out because of an optimization later....

	loop % primes0 {
		if (containsEvenDigitsOrFive(primes%A_Index%) = TRUE)
			continue	; at least one cyclic permutation will be non-prime
		isCyclic := TRUE
		currentIndex := A_Index
		debug := primes%currentIndex%
		cycleString := cycleNumber(primes%currentIndex%)
		StringSplit, cycle, cycleString, `,
		loop % cycle0 {
			; missing if statement goes here
				isCyclic = FALSE
				break
				
			;needle := "," . cycle%A_Index% . "(,|)"

			;isPrime := RegExMatch(primeString, needle)
			if (isPrime(cycle%A_Index%) = FALSE) {
				; this cycling is NOT prime
				isCyclic := FALSE
				break
			}
		}
		if (isCyclic = TRUE) {
			MsgBox, %debug% is prime through all cycles (%cycleString%)
			count++
		}
	}
	return count
}

listTruncates(string, lr) {
	if (StrLen(string) < 1)
		return string
	if (!(lr = 0 || lr = 1))
		return 0
	outString := string
	loop % StrLen(string) {
		len = StrLen(string)
		if (lr = 0) {
			StringTrimLeft, string, string, 1
		} else {
			StringTrimRight, string, string, 1
		}
		outString .= "," . string
	}
	StringTrimRight, outString, outString, 1
	return outString
}

Euler37() {
	primesList := sieveEra(1000000)
	StringSplit, primes, primesList, `,
	count := 0
	sum := 0
	loop % primes0 - 4	; ignore 2,3,5,7
	{
		works := TRUE
		index := A_Index + 4
		rightOnes := listTruncates(primes%index%, 0)
		leftOnes := listTruncates(primes%index%, 1)
		;MsgBox, %leftOnes%, %rightOnes%
		all := rightOnes . "," . leftOnes
		StringSplit, candidates, all, `,
		loop % candidates0 {
			if (isPrime(candidates%A_Index%) = FALSE)
				works := FALSE
		}
		if (works = TRUE) {
			magic := primes%index%
			MsgBox, %magic% works, (%leftOnes%, %rightOnes%)
			sum += magic
			count++
		}
		if (count = 11)
			break
	}
	MsgBox, %sum% (%count% found)
	return sum
}

Euler40() {
	string := ""
	loop {
		if (StrLen(string) > 1000000)
			break
		String .= A_Index
	}
	product := 1
	loop % 7
	{
		power := A_Index - 1
		digit := SubStr(string, 10 ** power, 1)
		product *= digit
		MsgBox, %digit%
	}
	return product
}

convertToBinary(number) {
	string := ""
	loop {
		if (number = 0)
			break
		remainder := mod(number, 2)
		number := number // 2
		string := remainder . string
	}
	return string
}

Euler36() {
	sum := 0
	loop % 1000000 {
		if (isPallendromic(A_Index) = TRUE && isPallendromic(convertToBinary(A_Index)) = TRUE)
			sum += A_Index
	}
	return sum
}

Euler38() {
	; the answer is > 918273645
	; the first digit of the number that leads to it is a 9
	; that number has no more than 4 digits?
	; that number has no duplicate digits
	largestNFound := 0
	maxPandFound := 0
	loop
	{
		current := A_Index + 1
		if (StrLen(current) > 4)
			break
		curPandStr := ""
		loop {
			if (StrLen(curPandStr) > 9)
				break
			curPandStr .= current * A_Index
			if (StrLen(curPandStr) = 9) {
				if (isPandigital(curPandStr)) {
					;MsgBox, %curPandStr% came from %current% %A_Index% times
					if (A_Index > largestNFound)
						largestNFound := A_Index
					if (curPandStr > maxPandFound)
						maxPandFound := curPandStr
				}
			}
		}
	}
	return maxPandFound
}

Factorial(number)
{
	finalValue := 1

	loop, %number%
	{
		finalValue *= %A_Index%	
	}

	return finalValue
}

sumFactorialOfDigits(number) {
	sum := 0
	StringSplit, digits, number,
	loop % digits0
	{
		sum += factorial(digits%A_Index%)	
	}
	return sum
}

Euler34() {
	sum := 0
	loop {
		current := A_Index + 2 ;(skip 1 and 2...)
		check := sumFactorialOfDigits(current) ; so I can watch it...
		if (current = check) {
			MsgBox, %current% works
			sum += current
		}
	}
	return sum
}

nthTriangular(n) {
	return floor((.5 * n) * (n+1))
}

testWordFile(inFile) {
	FileRead, words, %inFile%
	needle = "
	words := RegexReplace(words, needle)
	StringSplit, wordList, words, `,
	maxScore := 0
	loop % wordList0 {
		thisScore := scoreString(wordList%A_Index%)
		if (thisScore > maxScore)
			maxScore := thisScore
	}
	return maxScore
}
		

Euler42() {
	loop % 20 {
		thisTriangular := nthTriangular(A_Index)
		triangularCheck%thisTriangular% := TRUE
	}

	FileRead, words, words.txt
	needle = "
	words := RegexReplace(words, needle)
	StringSplit, wordList, words, `,

	numTriangulars := 0

	loop % wordList0 {
		thisScore := scoreString(wordList%A_Index%)

		if (triangularCheck%thisScore% = TRUE) 
			numTriangulars++
	}

	return numTriangulars			
}	
	
hasFactor(number, factor) {
	return mod(number, factor) = 0 ? TRUE : FALSE
}

permuteTest(string) {
	permutations := permute(string)
	return "DONE"
}

Euler43() {
	primes0 := 7	; length of list....
	primes1 := 2
	primes2 := 3
	primes3 := 5
	primes4 := 7
	primes5 := 11
	primes6 := 13
	primes7 := 17

	; poor man's memoization
	ifNotExist, Euler43.txt
	{
		permutations := permute("1234567890")
		FileAppend, %permutations%, Euler43.txt
	}
	else
		FileRead, permutations, Euler43.txt

	StringSplit, perms, permutations, `n
	
	sum := 0

	loop % perms0 {
		thisPerm := perms%A_Index% ; candidate number
		works := TRUE

		loop % 7 {
			currentIndex := A_Index + 1
			thisSub := SubStr(thisPerm, currentIndex, 3)
			if (hasFactor(thisSub, primes%A_Index%) = FALSE) {
				works := FALSE
				break
			}
		}

		if (works = TRUE) {
			;MsgBox, %thisPerm% works
			sum += thisPerm
		}
	}

	return sum
}

Euler41() {
	finalPermSet := FALSE
	largest := 2143
	loop % 6 {
		numDigits := 10 - A_Index
		
		; generate base string
		bString := ""
		loop % numDigits {
			bString .= A_Index
		}
		permutations := permute(bString)
		StringSplit, perms, permutations, `n
		loop % perms0 {
			if (isPrime(perms%A_Index%) = TRUE) {
				; the largest prime has at least this many digits... once we're done
				; checking this length, we're done checking
				if (perms%A_Index% > largest) {
					largest := perms%A_Index%
					finalPermSet := TRUE
				}
			}
		}
		if (finalPermSet = TRUE)
			break
	}
	return largest
}

isInt(number) {
	;MsgBox, %number%
	if number is integer
		return TRUE

	StringSplit, test, number, .

	return test2 = 0 ? TRUE : FALSE ; dumb dumb dumb dumb dumb
}

isSquare(number) {
	return isInt(sqrt(number)) ? TRUE : FALSE
}

isTriangular(number) {
	return isSquare((8 * number) + 1) ? TRUE : FALSE
}

isPentagonal(number) {
	return isInt((sqrt((24 * number) + 1) + 1) / 6) ? TRUE : FALSE
}	

isHexagonal(number) {
	return isInt((sqrt((8 * number) + 1) + 1) / 4) ? TRUE : FALSE
}

Euler45() {
	n := 285
	loop {
		candidate := nthTriangular(++n)
		if (isPentagonal(candidate) = TRUE && isHexagonal(candidate) = TRUE)
			return candidate
	}
}


; use this when you've already made your sieve
smartIsPrime(number, ByRef sieve = "") {
	if (number = 1)
		return FALSE
	if (number = 2)
		return TRUE

	needle := "," . number . ","
	test := RegexMatch(sieve, needle)

	if (test != 0)
		return TRUE

	; just in case.....
	needle := ",(\d+)$"
	test := RegexMatch(sieve, needle, magic)
	if (magic1 = number)
		return true
	
	return FALSE
}

getDistinctPrimeFactors(number, Byref sieve = "") {
	upperBound := number // 2
	if (sieve = "")
		sieve := sieveEra(upperBound)

	StringSplit, primes, sieve, `,

	factors := ""

	loop {
		if (primes%A_Index% > upperBound)
			break
		if (mod(number, primes%A_Index%) = 0) {
			factors .= primes%A_Index% . ","
		}
	}
	needle := ",+$"
	factors := RegexReplace(factors, needle)
	return factors
}

countDistinctPrimeFactors(number, ByRef sieve = "") {
	factorList := getDistinctPrimeFactors(number, sieve)
	StringSplit, factors, factorList, `,
	return factors0
}

Euler472(numFactors) {
	MAXSIEVESIZE := 1000000
	sieve := sieveEra(MAXSIEVESIZE)

	StringSplit, primes, sieve, `,

	loop % primes0 {
		foo := primes%A_Index%
		cands%foo% := 1
		cur := 2
		loop {
			x := cur * foo
			if (x > MAXSIEVESIZE)
				break
			cands%x%++
			cur++
		}
	}

	loop {
		base := A_index
		if (cands%base% = numFactors) {
			final := TRUE
			loop % numFactors - 1 {
				next := base + A_Index
				if (cands%next% != numFactors) {
					final := FALSE
					break
				}
			}
			if (final = TRUE)
				return base
		}
	}
}


			
		

Euler47(numFactors) {
	MAXSIEVESIZE := 10000
	sieve := sieveEra(MAXSIEVESIZE)	; do this nasty business once

	loop {
		if (A_Index > MAXSIEVESIZE)
			return "Emptied Sieve -- try increasing MAXSIEVESIZE (" . MAXSIEVESIZE . "currently)"
		if (smartIsPrime(A_Index, sieve) = TRUE)
			continue	; this number is prime, don't bother...
		if (countDistinctPrimeFactors(A_Index, sieve) = numFactors) {
			; this number has the correct number of factors for us...
			candidate := A_Index
			correctNum := TRUE

			loop % numFactors - 1 {
				; check the next howevermany
				plusCand := candidate + A_Index
				facts := countDistinctPrimeFactors(plusCand, sieve)
				if (facts != numFactors) {
					correctNum := FALSE
					break
				}
				MsgBox, so does %plusCand% (%facts%)
			}
			if (correctNum = TRUE)
				return candidate
		}
	}
}

isInSet(val, set) {
	set := "," . set . ","
	needle := "," . val . ","
	return RegexMatch(set, needle) != 0 ? TRUE : FALSE
}

findProgression(numString, ByRef startVal = "") {
	StringSplit, numbers, numString, `,
	numItems := numbers0

	loop % numItems {
		currentItemIndex := (numItems - A_Index) + 1

		loop % numItems - 1 {
			currentSubTractorIndex := currentItemIndex - A_Index
			if (currentSubtractorIndex < 1)
				break
			currentItem := numbers%currentItemIndex%
			currentSubtractor := numbers%currentSubtractorIndex%
			diff := currentItem - currentSubtractor
			check := currentSubtractor - diff
			;MsgBox, %currentItem% - %currentSubtractor% = %diff% -- %currentSubtractor% - %diff% = %check%

			if (isInSet(check, numString) = TRUE) {
				;MsgBox, %check% + %diff% = %currentSubtractor% + %diff% = %currentItem%
				startVal := check
				return diff
			}
		}
	}
	return -1
}

Euler49() {
	sieve := sieveEra(10000)
	StringSplit, primes, sieve, `,
	n := 1

	loop % primes0 {
		if (primes%A_Index% > 999) {
			cands%n% := primes%A_Index%
			n++
		}
	}


	n--
	outStr := ""
	baseNums := ""
	loop % n {
		perms := permute(cands%A_Index%)
		foo := cands%A_Index%
		Sort, perms, UD`n
		StringSplit, per, perms, `n
		baseNums .= "," . foo
		pCount := 1
		pString := foo
		loop % per0 {
			if (per%A_Index% != foo && smartIsPrime(per%A_Index%, sieve) = TRUE) {
				pCount++
				pstring .= "," . per%A_Index%
			}
		}
		if (pCount > 2) {
			;MsgBox, testing %pString%
			test := 0
			incVal := findProgression(pString, test)
			if (incVal != -1) {
				;MsgBox, start with %test%, add %incVal%
				first := test
				second := test + incVal
				third := second + incVal
				outStr .= first . second . third . "`n"
			}
		}
	}
	Sort, outStr, UD`n
	return outStr		
}


Euler48() {
	loop % 10 {
		sum := bigSum(sum, bigPow(A_Index, A_Index))
	}
	return SubStr(sum, -9)
}

generatePentagonalNumbers(n) {
	loop % n {
		pent := (A_Index * ((3 * A_Index) - 1)) // 2
		list .= pent . ","
	}
	needle := ",+$"
	list := RegexReplace(list, needle)
	return list
}

Euler44() {
	RANGE := 100000
	MAXDIST := 10
	pentList := generatePentagonalNumbers(RANGE)
	zneedle := ",(\d+)$"
	z := RegexMatch(pentList, zneedle, zmatches)
	largestKnownPent := zmatches1
	
	pentList := "," . pentList . ","
	StringSplit, xPents, PentList, `,
	
	loop % MAXDIST {	; i'm guessing they'll be less than MAXDIST indicies apart...
		dist := A_Index
		loop % xPents0 {
			firstIndex := A_Index
			nextIndex := A_Index + dist
			if (nextIndex > xPents0)
				break
			pentOne := xPents%firstIndex%
			pentTwo := xPents%nextIndex%
			;MsgBox, %pentOne% %pentTwo%
			sum := pentOne + pentTwo
			if (sum > largestKnownPent)
				break
			diff := pentTwo - pentOne

			if (InStr(pentList, "," . sum . ",") != 0) {
				MsgBox, %pentOne% + %pentTwo% = a pent
				if (InStr(pentList, "," . diff . ",") != 0)
					return abs(pentTwo - pentOne)
			}
		}
	}
	return "Not found"
}

check46(number, ByRef sieve) {
	StringSplit, primes, sieve, `,
	loop {
		if (primes%A_Index% > number)
			return FALSE
		thisPrime := primes%A_Index%
		check := isInt(sqrt((number - thisPrime) / 2))
		if (check = TRUE)
			return TRUE
	}
}

Euler46() {
	MAXSEARCH := 10000
	sieve := sieveEra(MAXSEARCH)
	i := 35
	loop % MAXSEARCH {
		if (InStr("," . sieve . ",","," . i . ",") = 0) {
			; odd composite
			test := check46(i, sieve)
			if (test = FALSE)
				return i
		}
		i += 2
	}
	return "Max depth reached, increase MAXSEARCH (" . MAXSEARCH . " currently)"
}

Euler50() {
	SEARCHSPACE := 1000000
	sieve := sieveEra(SEARCHSPACE)
	StringSplit, zPrimes, sieve, `,
	sieve := "," . sieve . ","
	largest := 0
	longestStartP := 0
	numConsec := 0
	start := 0
	
	loop {
		bPoint := zPrimes0 - numConsec
		start := zPrimes%A_Index%
		if (start > bPoint)
			break
		foo := A_Index + 1
		sum := start
		loop % zPrimes0 - foo {
			sum += zPrimes%foo%
			if (sum > SEARCHSPACE)
				break
			if (InStr(sieve, "," . sum . ",") != 0) {
				if (A_Index > numConsec) {
					largest := sum
					numConsec := A_Index + 1
					longestStartP := start	
				}
			}
			foo++
		}
	}

	MsgBox, %largest% can be written as the sum of %numConsec% primes starting at %longestStartP%
	return largest
}

maskDigits(number, mask, ByRef sameDigRep ="") {
	if (StrLen(number) != StrLen(mask))
		return "0x455833F"
	StringSplit, digit, number,
	StringSplit, maskC, mask

	loop % maskC0 {
		if (maskC%A_Index% != "-") {
			digsRep .= digit%A_Index%
			digit%A_Index% := maskC%A_Index%
		}
	}
	sameDigRep = TRUE
	magicDig := SubStr(digsRep,1,1)
	StringSplit, magDigs, digsRep
	loop % magDigs0 {
		if (magDigs%A_Index% != magicDig) {
			sameDigRep = FALSE
			break
		}
	}
	loop % digit0 {
		outStr .= digit%A_Index%
	}
	return outStr
}

Euler51(famSize) {
	MAXSIEVESIZE := 1000000
	MAXDIGS := 6
	MINDIGS := 3
	sieve := sieveEra(MAXSIEVESIZE)
	sieve := "," . sieve . ","
	StringSplit, zPrimes, sieve, `,
	digsToReplace := 2

	loop % MAXDIGS - 1 {
		if (digsToReplace > MAXDIGS - 2)
			break
		maskStr := ""

		loop % digsToReplace {
			maskStr .= "."
		}

		loop % MAXDIGS - digsToReplace {
			maskStr .= "-"
		}

		masks := permute(maskStr)

		loop % zPrimes0 {
			thisCand := zPrimes%A_Index%
			len := StrLen(thisCand)
			if (len < MINDIGS)
				continue
			if (len > MAXDIGS)
				break

			Sort, masks, UD`n
			StringSplit, zMasks, masks, `n
			
			loop % zMasks0 {
				thisMask := zMasks%A_Index%
				if (SubStr(thisMask, 0) = ".")
					continue
				sameDigs := FALSE
				maskedVal := maskDigits(thisCand, zMasks%A_Index%, sameDigs)
				if (sameDigs = FALSE)
					continue

				familySize := 0
				familyStr := "" ;thisCand . ","
				loop % 10 {
					repDigit := A_Index - 1
					StringReplace, currentTest, maskedVal, ., %repDigit%, A
					if (InStr(sieve, "," . currentTest . ",") != 0) {
						familySize++
						familyStr .= currentTest . ","
					}
				}	
				if (familySize = famSize)
					return %familyStr%
			}
		}
		digsToReplace++
	}
	return "no families of " . famSize . " found w/less than " . MAXDIGS . " digits"
}

Euler51w(famSize) {
	MAXSIEVESIZE := 100000
	sieve := sieveEra(MAXSIEVESIZE)
	StringSplit, zPrimes, sieve, `,
	numPrimes := zPrimes0
	masks := permute("..   ")
	StringSplit, zMask, masks, `n
	sieve := "," . sieve . ","
	checkedKeys := ""
	loop % numPrimes {
		if (StrLen(zPrimes%A_Index%) < 5)
			continue
		thisPrime := zPrimes%A_Index%

		loop % zMask0 {
			needle := maskDigits(thisPrime, zMask%A_Index%)
			if (InStr(checkedKeys, needle) != 0)
				continue
			checkedKeys .= "," . needle . ","
			;theseMatches := findMatches(sieve, needle)
			if (theseMatches != "")
				StringSplit, zReps, theseMatches, `,
				if (zReps0 = famSize)
					return SubStr(theseMatches, 1, 5) . "(" . zMask%A_Index% . ")"
		}
	}
}

reverse(string) {
	StringSplit, chars, string
	loop % chars0 {
		curIndex := (chars0 - A_Index) + 1
		outStr .= chars%curIndex%
	}
	return outStr
}

Euler53() {
}	

Euler55() {
	lychCount := 0

	loop % 10000 {
		isLychrel := TRUE
		baseNum := A_Index + 9
		thisCand := A_Index + 9
		num := thisCand
		loop % 50 {
			foo := reverse(num)
			if (A_Index < 30)
				num := thisCand + foo
			if (A_Index > 30) ; the overflow gods demand tribute....
				num := bigSum(thisCand, foo)

			if (isPallendromic(num) = TRUE) {
				isLychrel := FALSE
				break
			}
			thisCand := num
		}
		if (isLychrel = TRUE) {
			lychCount++
		}
	}
	return lychCount
}

hasSameDigits(a, b) {
	if (StrLen(a) != StrLen(b))
		return FALSE

	StringSplit, aDigits, a
	StringSplit, bDigits, b

	aDigStr := ","
	bDigStr := ","

	loop % aDigits0 {
		aDigStr .= aDigits%A_Index% . ","
		bDigStr .= bDigits%A_Index% . ","
	}
	Sort, aDigStr, aDigStr, D,
	Sort, bDigStr, bDigStr, D,

	if (aDigStr = bDigStr)
		return TRUE
	return FALSE
}


arbDivide(divisor, dividend) {
	ans := "0."
	loop {
		if (divisor > dividend)
			dividend .= "0"
		digit := dividend // divisor
		ans .= digit
		test := mod(dividend, divisor)
		if (test = 0)
			break
		
	}
	return ans
}

Euler52() {
	MAXTEST := 1000000
	NUMMULTS := 6
	loop % MAXTEST {
		sameDigs := TRUE
		thisX := A_Index
		
		loop % NUMMULTS - 1 {
			mult := A_Index + 1
			test := thisX * mult
			if (hasSameDigits(test, thisX) = FALSE) {
				sameDigs := FALSE
				break
			}
		}
		if (sameDigs = TRUE) {
			return thisX
		}
	}
	return "didn't find an x with this property below " . MAXTEST
}

convertHand(ByRef hand) {
	StringReplace, hand, hand, T, 10, A
	StringReplace, hand, hand, J, 11, A
	StringReplace, hand, hand, Q, 12, A
	StringReplace, hand, hand, K, 13, A
	StringReplace, hand, hand, A, 14, A
	StringReplace, hand, hand, H,,A
	StringReplace, hand, hand, D,,A
	StringReplace, hand, hand, C,,A
	StringReplace, hand, hand, S,,A
	StringReplace, hand, hand, %A_Space%,,A

	return
}


hasFlush(hand) {
	needle1 := ".+H.+H.+H.+H.+H"
	needle2 := ".+D.+D.+D.+D.+D"
	needle3 := ".+C.+C.+C.+C.+C"
	needle4 := ".+S.+S.+S.+S.+S"

	loop % 4 {
		if (RegexMatch(hand, needle%A_IndeX%) != 0) {
			out := getHighCard(hand)
			return out
		}
	}
	return FALSE
}

hasStraight(hand, ByRef hC = "") {
	convertHand(hand)
	Sort, hand, ND,
	needle := "(\d+),(\d+),(\d+),(\d+),(\d+)"
	foo := RegexMatch(hand, needle, highLow)
	hC := 0

	firstVal := highLow1

	loop % 4 {
		i := A_Index + 1
		if (firstVal + A_Index != highLow%i%)
			return 0
		highest := highLow%i%
	}
	hC := highest
	return highest
}

hasRoyalFlush(hand) {
	if (hasFlush(hand) && hasStraight(hand, hC) && hC = 14)
		return hC
	return FALSE
}

hasStraightFlush(hand) {
	if (hasFlush(hand) && hasStraight(hand, hC))
		return hC
	return FALSE
}

hasFourOfAKind(hand) {
	convertHand(hand)

	StringSplit, zCards, hand, `,

	loop % zCards0 {
		thisCard := zCards%A_Index%
		cards%thisCard%++
	}

	loop % 14 {
		if (cards%A_Index% = 4)
			return A_Index
	}
	return FALSE
}



getHighCard(hand, exclude = "") {
	convertHand(hand)
	StringSplit, zCards, hand, `,
	highest := -1
	loop % zCards0 {
		if (zCards%A_Index% > highest && zCards%A_Index% != exclude)
			highest := zCards%A_Index%
	}
	return highest
}

hasPairs(hand, ByRef highPair, ByRef exclude = "") {
	convertHand(hand)
	StringSplit, zCards, hand, `,

	loop % zCards0 {
		thisCard := zCards%A_Index%
		cards%thisCard%++
	}

	highPair := -1
	pCount := 0

	loop % 14 {
		if (pCount = 2)
			break
		if (cards%A_Index% = 2 && cards%A_Index% != exclude) {
			pCount++
			if (A_Index > highPair)
				highPair := A_Index
		}
	}
	return pCount
}

hasThreeOfAKind(hand) {
	convertHand(hand)
	StringSplit, zCards, hand, `,
	
	loop % zCards0 {
		thisCard := zCards%A_Index%
		cards%thisCard%++
	}

	loop % 14 {
		if (cards%A_Index% = 3)
			return A_Index
	}
	return 0
}

hasFullHouse(hand) {
	test := hasThreeOfAKind(hand)
	if (test != 0 && hasPairs(hand, foo ,test) != 0)
		return test
	return 0
}

scoreHand(hand, ByRef special) {
	if (hasRoyalFlush(hand) != 0)
		return 10

	special := hasStraightFlush(hand)

	if (special != 0)
		return 9

	special := hasFourOfAKind(hand)

	if (special != 0)
		return 8

	special := hasFullHouse(hand)

	if(special != 0)
		return 7

	special := hasFlush(hand)

	if (special != 0)
		return 6

	special := hasStraight(hand)
	if (special != 0)
		return 5

	special := hasThreeOfAKind(hand)
	if (special != 0)
		return 4

	special := hasPairs(hand, high)
	if (special = 2) {
		special := high
		return 3
	} else if (special = 1) {
		special := high
		return 2
	}

	special := getHighCard(hand)
	return 1

}
		
Euler54() {
	1final := 0
	2final := 0

	loop, read, poker.txt 
	{
		p1Hand := SubStr(A_LoopReadLine, 1, 14)
		p2Hand := SubStr(A_LoopReadLine, 16)
		StringReplace, p1Hand, p1Hand, %A_Space%, `,, A
		StringReplace, p2Hand, p2Hand, %A_Space%, `,, A
		p1Score := scoreHand(p1Hand, special1)
		p2Score := scoreHand(p2Hand, special2)
	
		winner := 2

		if (p1Score > p2Score)
			winner := 1
		if (p1Score = p2Score) {
			if (special1 > special2)
				winner := 1
		}

		%winner%final++
	}
	return 1final
}			

getSpiralDiagonalVals(sideLen) {
	back := sideLen - 1
	bR := sideLen ** 2
	bL := bR - back
	tL := bL - back
	tR := tL - back
	return tR . "," . tL . "," . bL . "," . bR	
}

calcPrimeDensity(sideLen) { ;, ByRef sieve = "") {
	; only works for odd sideLen > 5
	;RegexMatch(sieve, ",(\d+),$", last)
	static pCount := 5
	static numDiags := 9
	numDiags += 4
	newDiagVals := getSpiralDiagonalVals(sideLen)
	StringSplit, nDiags, newDiagVals, `,
	loop % nDiags0 {
		;if (nDiags%A_Index% > last1) {
		;	MsgBox, emptied sieve
		;	exitapp
		;}
		if (isPrime(nDiags%A_Index%) = TRUE)
			pCount++
	}
	;MsgBox, w/sidelen %sideLen% : %pCount% primes out of %numDiags% 
	return pCount / numDiags
}
	

Euler58() {
	sideLen := 5
	;sieve := sieveEra(10000000)
	;sieve := "," . sieve . ","
	loop {
		sideLen += 2
		;diags := getSpiralDiagonalVals(sideLen)
		density := calcPrimeDensity(sideLen) ;, sieve)

		if (density < 0.1)
			return sideLen

		if (density < 0)
			return "Emptied sieve"
	}
}

chop(str) {
	return SubStr(str, 1, StrLen(outStr) - 1)
}

chomp(str) {
	RegexMatch(str, "(.*\S)\s*$", chompr)
	return chompr1
}

gen57Denoms(limit) {
	denoms1 := 2
	denoms2 := 5
	denoms3 := 12
	current := 3

	loop % limit - 3 {
		current++
		prev := current - 1
		2prev := current - 2
		denoms%current% := BigSum(BigMult(2, denoms%prev%), denoms%2prev%)
		;denoms%current% := (2 * denoms%prev%) + denoms%2prev%
	}
 
	loop % current {
		outStr .= denoms%A_Index% . ","
	}
	return chop(outStr)
}

gen57Numers(limit) {
	numers1 := 3
	numers2 := 7
	numers3 := 17
	current := 3

	loop % limit - 3 {
		current++
		prev := current - 1
		2prev := current - 2
		3prev := current - 3
		; poor man's RPN
		numers%current% := BigDiff(BigMult(3, numers%prev%), BigSum(numers%2prev%, numers%3prev%))
		;numers%current% := BigSum(numers%prev%,BigSum(BigDiff(numers%2prev%, numers%3prev%),BigMult(2,BigDiff(numers%prev%, numers%2prev%))))
	}

	loop % current {
		outStr .= numers%A_Index% . ","
	}
	return chop(outStr)
}

Euler57() {
	BOUND := 1000
	numerStr := gen57Numers(BOUND)
	denomStr := gen57Denoms(BOUND)

	StringSplit, numer, numerStr, `,
	StringSplit, denom, denomStr, `,

	gCount := 0

	loop % BOUND {
		if (StrLen(numer%A_Index%) > StrLen(denom%A_Index%)) {
			gCount++
		}
	}
	return gCount
}

; #### Timer Start ####
startTime := A_TickCount
		
; #### Output section ####

;threes := SumMultsToLimit(3,1000)
;fives := SumMultsToLimit(5,1000)
;fifteens := SumMultsToLimit(15,1000)
;final := (threes + fives) - fifteens
;final := SumEvenFibsToLimit(4000000)
;final := FindLargestPrimeFactor(600851475143)
;final := FindLargestPallendromicNumber(3)
;ltest := isPrime(71)
;final := FindSmallestNumberDivisibleByMax(20)
;final := SquareOfSumUpTo(100) - SumOfSquaresUpTo(100)
;final := FindNthPrime(10001)
;final := FindLargestProductOfConsecutiveDigits(5,"731")
;final := sumPrimesUnderLimit(2000000)
;final := GridMaxProductSearch("prodgridinput.txt", 20, 4)
;final := findNumberWithNDivisors(500, 4000)
;final := FirstXDigitsofSum("50dignums.txt", 50, 10)
;final := LongestSequenceUnderLimit(1000000)
;final := sumDigitsInTwoToNthPower(1000)
;final := sumCharsInSpokenNumbersToLimit(999)
;final := maxSumOverPathThroughTriangle("triangle.txt")
;final := sumDigitsInBigFactorial(100)
;final := choose(40,20)
;final := findSumOfAmicableNumbersUnderLimit(10000)
;final := sumOfProperDivisors(284)
;final := sumOfProperDivisors(4)
;final := isAbundant(1)
;final := sumOfNumbersNotSumOfAbundants(20162)
;final := totalNameScores("names.txt")
;final := fibDigits()
;final := spiralSumDiagnonals(1001)
;final := findLongestRecurringCycle(1000)
;final := evalQuadratic(2,1,41)
;final := testQuadraticPrimeSequence(-79,1601)
;final := quadraticPrimeGenerator(999,999)
;final := findNthLexPermutation(1000000, "0123456789")
;final := sumPowersOfDigits(1634,4)
;final := bigPow(3,3)
;final := Euler29(2,2,2,2)
;final := cheapEuler29("powers.csv")
;final := Euler30(5)
;final := hasCommonDigit(33, 13)
;final := removeCommonDigit(13, 33)
;final := Euler33()
;final := isPandigital(1543)
;final := Euler32()
;final := Euler19()
;final := sieveEra(1000000)
;final := checkSieve(1000000)
;final := cycleNumber(1234)
;final := containsEvenDigitsOrFive(15379)
;final := Euler35(100)
;final := listTruncates(1234, 0)
;final := Euler37()
;final := Euler40()
;final := isPrime(793)
;final := convertToBinary(5687)
;final := Euler36()
;final := Euler38()
;final := Euler34()
;final := sumFactorialOfDigits(888111)
;final := nthTriangular(20)
;final := testWordFile("words.txt")
;final := Euler42()
;final := hasFactor(4,2)
;final := permuteTest("123456789")
;final := Euler43()
;final := Euler41()
;final := isPandigital(123455)
;final := nthTriangular(285)
;final := isInt(3.000000)
;final := isPentagonal(40755) . " " . isHexagonal(40755)
;final := Euler45()
;final := Euler50()
;final := getDistinctPrimeFactors(15)
;final := countPrimeFactors(15)
;final := Euler472(4)
;final := testExtendSieve()
;final := Euler49()
;pString := "2,3,5,6,11"
;final := smartIsPrime(11, pString)
;final := Euler49()
;final := isInSet(8, "2,4,6,8")
;final := findProgression("1487,1847,4817,4871,7481,7841,8147,8741")
;final := sieveEra(1000000)
;final := isPrime(2969) . " " . isPrime(2969 + 3330) . " " . isPrime(2969 + 6660)
;final := Euler48()
;final := generatePentagonalNumbers(30)
;final := Euler44()
;final := Euler46()
;final := bigPow(1000,1000)
;final := choose(6,3)
;final := permute("***   ")
;qq := FALSE
;final := maskDigits(505, ".-.", qq)
;final := findMatches("12345,16785,52345,18985", "1...5")
;final := Euler51(8)
;final := reverse("garbage")
;final := Euler55()
;final := choose(5,4)
;final := hasSameDigits(12345, 54326)
;final := Euler52()
;final := Euler54()
final := Euler58()
;final := gen57Numers(7) . "`n" . gen57Denoms(7)
;final := gen57Numers(7)
;final := bigDiff(17,7)
;final := bigDiff(1034,672)
;final := Euler57()
timeElapsed := Round((A_TickCount - startTime) / 1000 , 6)
MsgBox, %final% (%timeElapsed% seconds)
;MsgBox, %timeElapsed% seconds
return