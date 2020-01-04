class Union extends Arrays.Venn {
	processOperation() {
		base.retrieveElementsInSetA()
		base.retrieveElementsInSetB()
		base.retrieveElementsContainedInBothSets()
	}
}

class Intersection extends Arrays.Venn {
	processOperation() {
		base.catchUpSetA()
		base.catchUpSetB()
		base.retrieveElementsContainedInBothSets()
	}
}

class SymmetricDifference extends Arrays.Venn {
	processOperation() {
		base.retrieveElementsInSetA()
		base.retrieveElementsInSetB()
		base.catchUpBothSets()
	}
}

class RelativeComplement extends Arrays.Venn {
	processOperation() {
		base.retrieveElementsInSetA()
		base.catchUpSetB()
		base.catchUpSetAForElementsContainedInBothSets()
	}
}

class Venn {
	setA := []
	setB := []
	indexA := 0
	indexB := 0
	compareFunc := Arrays.Quicksort.compareStrings.bind(this)					; TODO: Use a method from String class
	printSource := false
	resultSet := []

	__new(setA, setB, compareFunc="", printSource=false) {
		Arrays.isArray(setA)
		Arrays.isArray(setB)
		this.compareFunc := (compareFunc != ""
				? compareFunc
				: Arrays.Quicksort.compareStrings.bind(this))
		Arrays.isCallbackFunction(this.compareFunc)
		this.setA := setA.clone()
		this.setB := setB.clone()
		this.indexA := this.setA.minIndex()
		this.indexB := this.setB.minIndex()
		VarSetCapacity(HIGH, 64, 0xff)
		this.setA.push(HIGH)
		this.setB.push(HIGH)
		this.printSource := printSource
		this.processSetAAndSetB()
	}

	result() {
		return this.resultSet
	}

	processSetAAndSetB() {
		while ((this.indexA != "" && this.indexB != "")
				&& (this.indexA < this.setA.maxIndex()
				|| this.indexB < this.setB.maxIndex())) {
			this.processOperation()
		}
	}

	catchUpSetA() {
		while (this.indexA < this.setA.maxIndex()
				&& (this.compareFunc.call(this.setA[this.indexA]
				, this.setB[this.indexB])) < 0) {
			this.indexA++
		}
	}

	retrieveElementsInSetA() {
		while (this.indexA < this.setA.maxIndex()
				&& (this.compareFunc.call(this.setA[this.indexA]
				, this.setB[this.indexB])) < 0) {
			this.pushToResultSet(this.setA[this.indexA], "A")
			this.indexA++
		}
	}

	catchUpSetB() {
		while (this.indexB < this.setB.maxIndex()
				&& (this.compareFunc.call(this.setB[this.indexB]
				, this.setA[this.indexA])) < 0) {
			this.indexB++
		}
	}

	retrieveElementsInSetB() {
		while (this.indexB < this.setB.maxIndex()
				&& (this.compareFunc.call(this.setB[this.indexB]
				, this.setA[this.indexA])) < 0) {
			this.pushToResultSet(this.setB[this.indexB], "B")
			this.indexB++
		}
	}

	catchUpBothSets() {
		while ((this.indexA < this.setA.maxIndex()
				|| this.indexB < this.setB.maxIndex())
				&& (this.compareFunc.call(this.setA[this.indexA]
				, this.setB[this.indexB])) == 0) {
			this.indexB++
			this.indexA++
		}
	}

	retrieveElementsContainedInBothSets() {
		while ((this.indexA < this.setA.maxIndex()
				|| this.indexB < this.setB.maxIndex())
				&& (this.compareFunc.call(this.setA[this.indexA]
				, this.setB[this.indexB])) == 0) {
			this.pushToResultSet(this.setA[this.indexA], "A")
			this.indexA++
			this.pushToResultSet(this.setB[this.indexB], "B")
			this.indexB++
		}
	}

	catchUpSetAForElementsContainedInBothSets() {
		while ((this.indexA < this.setA.maxIndex()
				|| this.indexB < this.setB.maxIndex())
				&& (this.compareFunc.call(this.setA[this.indexA]
				, this.setB[this.indexB])) == 0) {
			this.indexA++
		}
	}

	pushToResultSet(element, source="") {
		this.resultSet.push((this.printSource
				? "(" source ") " : "")
				. element)
	}
}
