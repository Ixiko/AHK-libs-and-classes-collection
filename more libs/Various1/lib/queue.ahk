class Queue {

	queueSize := 0
	content := []

	__new(queueSize=0) {
		if queueSize is not integer
		{
			throw Exception("Param 'queueSize' must be a number")
		}
		if (queueSize < 0) {
			throw Exception("Param 'queueSize' must not be less than 0")
		}
		this.queueSize := queueSize
		return this
	}

	push(newEntry) {
		index := this.content.minIndex()
		if (this.queueSize = 0 || index = ""
				|| this.content.maxIndex() - index < this.queueSize) {
			this.content.push(newEntry)
			if (this.queueSize != 0
					&& this.content.maxIndex() - index >= this.queueSize) {
				removedValue := this.content.remove(index)
			} else {
				removedValue := ""
			}
		}
		return removedValue
	}

	pop(keepEntry=false) {
		index := this.content.minIndex()
		if (index = "") {
			return ""
		}
		return keepEntry
				? this.content[this.content.minIndex()]
				: this.content.remove(this.content.minIndex())
	}

	length() {
		if (this.content.maxIndex() = "") {
			return 0
		}
		return this.content.maxIndex() - this.content.minIndex() + 1
	}

	clear() {
		if (this.content.maxIndex() = "") {
			return 0
		}
		size := this.length()
		this.content := []
		return size
	}
}
