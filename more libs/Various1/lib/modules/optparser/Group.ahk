class Group {
	description := ""

	__new(description) {
		this.description := description
		return this
	}

	usage() {
		return this.description
	}
}
