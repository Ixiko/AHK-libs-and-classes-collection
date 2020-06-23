class Dimension {

	static units := ""
	static type := 0

	proper(instance, ByRef number, initialDimension="", factor=0) {
		start := 1
		if (initialDimension != "") {
			loop {
				start := A_Index
			} until (A_Index > instance.Units.MaxIndex()
					|| instance.units[A_Index] = initialDimension)
		}
		return Dimension.recalc(instance, number, factor, start)
	}

	recalc(instance, ByRef number, factor, startAtDimension) {
		n := startAtDimension
		if (instance.Factor.MaxIndex() != "") {
			n := Dimension.recalcFactorList(instance, number, factor, n)
		} else if (instance.type = 1) {
			n := Dimension.recalcExponential(instance, number, factor, n)
		} else {
			n := Dimension.recalcLinear(instance, number, factor, n)
		}
		return n
	}

	recalcFactorList(instance, ByRef number, factor, n) {
		while (number / instance.factor[n] >= 1
				&& n < instance.Factor.maxIndex()) {
			number := number / instance.factor[n]
			n++
		}
		return n
	}

	recalcExponential(instance, ByRef number, factor, n) {
		while (v / factor ** n >= 1) {
			v := v / factor ** n
			n++
		}
		return n
	}

	recalcLinear(instance, ByRef number, factor, n) {
		while (number / factor >= 1 && n < instance.Units.maxIndex()) {
			number := number / factor
			n++
		}
		return n
	}

	class MetricLength {

		static units := ["mm", "cm", "dm", "m", "km"]
		static factor := [1000, 60, 60, 24]
		static type := 2
	}

	class Memory  {

		static units := ["B", "KB", "MB", "GB", "TB"]
		static factor := 1024

		proper(pValue, initialDimension="", pfPrecision="0.1") {
			currentFormat := A_FormatFloat
			SetFormat Float, %pfPrecision%
			n := Dimension.proper(this, pValue, initialDimension, 1024)
			SetFormat Float, %currentFormat%
			return pValue this.units[n]
		}
	}

	class Time {

		static units := ["MSec", "Sek", "Min", "Std", "Tg"]
		static factor := [1000, 60, 60, 24]

		proper(pValue, pstStartDimension="", pfPrecision="0.1") {
			n := Dimension.proper(this, pValue, pstStartDimension)
			currentFormat := A_FormatFloat
			SetFormat Float, %pfPrecision%
			d := {Value: pValue+=0.0, Dimension:  this.units[n]}
			SetFormat Float, %currentFormat%
			return d
		}

		properString(pValue, pstStartDimension="", pstSeparate=" "
				, pfPrecision="0.1") {
			d := this.proper(pValue+0.0, pstStartDimension, pfPrecision)
			return d.value pstSeparate d.dimension
		}
	}
}
