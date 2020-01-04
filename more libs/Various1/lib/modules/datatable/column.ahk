class Column {

	width := 40
	flags := 0
	attributes := []

	__new(width=40, flags=0, attributes*) {
		this.width := width
		this.flags := flags
		this.attributes := attributes
	}

	class Wrapped extends DataTable.Column {

		width := 40
		attributes := ""

		__new(width=40, attributes*) {
			this.width := width
			this.attributes := attributes
			return this
		}
	}
}
