class PrimeFactorProduct {

	factorList := []
	numberOfFactors := 0

	__new(factor="") {
		if (factor != "") {
			this.factorList.push(factor)
			this.numberOfFactors := 1
		}
		return this
	}

	count() {
		return this.numberOfFactors
	}

	add(piFactor) {
		this.factorList.push(piFactor)
		this.numberOfFactors++
		return this.factorList.maxIndex()
	}

	getList() {
		return this.factorList
	}

	toString(compactStyle=false, powerSymbol="**") {
		factorListAsString := ""
		if (!compactStyle) {
			while (A_Index <= this.factorList.maxIndex()) {
				factorListAsString .= (factorListAsString = "" ? "" : "*")
						. this.factorList[A_Index]
			}
		} else {
			numberOfSameFactors := 0
			previousFactor := this.factorList[1]
			while (A_Index <= this.factorList.maxIndex()) {
				factor := this.factorList[A_Index]
				if (A_Index == 1 || factor == previousFactor) {
					numberOfSameFactors++
				} else {
					factorListAsString .= PrimeFactorProduct
							.factorGroupAsString(factorListAsString
							, previousFactor, numberOfSameFactors, powerSymbol)
					previousFactor := factor
					numberOfSameFactors := 1
				}
			}
			factorListAsString .= PrimeFactorProduct
					.factorGroupAsString(factorListAsString
					, previousFactor, numberOfSameFactors, powerSymbol)
		}
		return factorListAsString
	}

	factorGroupAsString(factorListAsString, previousFactor, numberOfSameFactors
			, powerSymbol) {
		return (factorListAsString == "" ? "" : "*")
				. previousFactor
				. (numberOfSameFactors > 1
				? powerSymbol numberOfSameFactors : "")
	}
}

