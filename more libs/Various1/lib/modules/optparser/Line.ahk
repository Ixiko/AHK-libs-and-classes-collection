class Line {
	leftText := ""
	rightText := ""
	leftMargin := 0
	rightMargin := 0
	indentWidth := 0

	__new(leftText, rightText
			, leftMargin=26, rightMargin=60, indentWidth=4) {
		this.leftText := leftText
		this.rightText := rightText
		this.leftMargin := leftMargin
		this.rightMargin := rightMargin
		this.indentWidth := indentWidth
		return this
	}

	usage() {
		leftText := " ".repeat(this.indentWidth) this.leftText
		rightText := this.rightText
		usage := ""
		if (StrLen(leftText) > this.leftMargin-1) {
			usage := this.leftTextDoesNotFitInMargin(leftText, rightText)
		} else {
			usage := this.leftTextFitsInMargin(leftText, rightText)
		}
		return usage
	}

	leftTextDoesNotFitInMargin(leftText, rightText) {
		if (rightText != "") {
			if (rightText.minIndex() == "") {
				usage := leftText "`n"
						. rightText.wrap(this.rightMargin
						, " ".repeat(this.leftMargin))
			} else {
				usage := leftText "`n"
						. Arrays.wrap(rightText, this.rightMargin
						, " ".repeat(this.leftMargin))
			}
		} else {
			usage := leftText
		}
		return usage
	}

	leftTextFitsInMargin(leftText, rightText) {
		if (rightText.minIndex() == "") {
			usage := leftText.padRight(this.leftMargin-1)
					. rightText.wrap(this.rightMargin
					, " ".repeat(this.leftMargin), " ", true)
		} else {
			usage := leftText.padRight(this.leftMargin-1)
					. Arrays.wrap(rightText, this.rightMargin
					, " ".repeat(this.leftMargin), " ", true)
		}
		return usage
	}
}
