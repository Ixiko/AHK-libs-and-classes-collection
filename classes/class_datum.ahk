class Datum {

	cardinalPoint := ""
	decimalDegrees := 0.0

	__new(cardinalPoint=0, decimalDegrees=0.0) {
		this.cardinalPoint := cardinalPoint
		this.decimalDegrees := decimalDegrees
		this.checkValidity()
	}

	getDegrees() {
		return Format("{:i}", this.decimalDegrees)
	}

	getMinutes() {
		return Format("{:i}", Mod(Abs(this.decimalDegrees) * 60, 60))
	}

	getSeconds() {
		return Format("{:f}", Mod(Abs(this.decimalDegrees) * 3600, 60))
	}

	getCardinalPoint() {
		return Geo.CARDINAL_POINTS[this.cardinalPoint == Geo.HORIZONTAL
				, this.decimalDegrees > 0]
	}

	setDegrees(degrees) {
		this.decimalDegrees := (this.decimalDegrees - this.getDegrees())
				+ degrees
		this.checkValidity()
		return this
	}

	setMinutes(minutes) {
		this.decimalDegrees := (this.decimalDegrees - this.getMinutes() / 60.0)
				+ minutes / 60.0
		this.checkValidity()
		return this
	}

	setSeconds(seconds) {
		this.decimalDegrees
				:= (this.decimalDegrees - this.getSeconds() / 3600.0)
				+ seconds / 3600.0
		this.checkValidity()
		return this
	}

	setCardinalPoint(cardinalPoint) {
		switch cardinalPoint {
		case "N", "S", 1:
			this.cardinalPoint := Geo.HORIZONTAL
		case "E", "O", "W", 0:
			this.cardinalPoint := Geo.VERTICAL
		default:
			throw Exception("Invalid value for 'cardinalPoint': "
					. cardinalPoint)
		}
		return this
	}

	parseDMS(dmsString, parsingExpressions="") {
		if (parsingExpressions == "") {
			parsingExpressions := new Geo.Datum.ParsingExpressions()
		}
		this.setDegrees(this.parseDegrees(dmsString, parsingExpressions))
		this.setMinutes(this.parseMinutes(dmsString, parsingExpressions))
		this.setSeconds(this.parseSeconds(dmsString, parsingExpressions))
		this.setCardinalPoint(this.parseCardinalPoint(dmsString
				, parsingExpressions))
		this.checkValidity()
		return this
	}

	parseDegrees(dmsString, parsingExpressions) {
		currentDegrees := this.getDegrees()
		result := this.parseByExpr(dmsString, parsingExpressions.degreesExpr)
		if (result != "") {
			return 0 + result
		}
		return currentDegrees
	}

	parseMinutes(dmsString, parsingExpressions) {
		currentMinutes := this.getMinutes()
		result := this.parseByExpr(dmsString, parsingExpressions.minutesExpr)
		if (result != "") {
			return 0 + result
		}
		return currentMinutes
	}

	parseSeconds(dmsString, parsingExpressions) {
		currentSeconds := this.getSeconds()
		result := this.parseByExpr(dmsString, parsingExpressions.secondsExpr)
		if (result != "") {
			return 0 + result
		}
		return currentSeconds
	}

	parseCardinalPoint(dmsString, parsingExpressions) {
		result := this.parseByExpr(dmsString
				, parsingExpressions.cardinalPointExpr)
		if (result) {
			if (InStr("NS", result)) {
				return Geo.HORIZONTAL
			} else {
				return Geo.VERTICAL
			}
		}
		return ""
	}

	parseByExpr(dmsString, parsingExpression) {
		if (RegExMatch(parsingExpression
				, "^\/(?<Pattern>.+?(?<!\\))\/(?<Options>.*)$", regex)) {
			if (!RegExMatch(regexOptions, "\d+", regexGroup)) {
				regexGroup := 0
			}
			regexOptions := RegExReplace(regexOptions, "\d", "")
			if (RegExMatch(dmsString, regexOptions "O)" regexPattern, result)) {
				return result[regexGroup]
			}
		}
		return ""
	}

	asDMS(formatString) {
		return Format(formatString
				, this.getDegrees(), this.getMinutes()
				, this.getSeconds(), this.getCardinalPoint())
	}

	checkValidity() {
		if (!this.isValid()) {
			throw "Invalid Geo.Datum: "
					. this.cardinalPoint "/ " this.decimalDegrees
		}
	}

	isValid() {
		return (this.cardinalPoint == Geo.HORIZONTAL
				&& this.decimalDegrees >= -90.0
				&& this.decimalDegrees <= +90.0)
				|| (this.cardinalPoint == Geo.VERTICAL
				&& this.decimalDegrees >= -180.0
				&& this.decimalDegrees <= +180.0)
	}

	class ParsingExpressions {
		degreesExpr := "/([+-]?\d+)°/1"
		minutesExpr := "/(\d+)'/1"
		secondsExpr := "/(\d+(\.\d+)?)""/1"
		elevationExpr := "/([+-]?\d+(\.\d+)?)m/1"
		cardinalPointExpr := "/[NSWEO]/i"
	}
}
