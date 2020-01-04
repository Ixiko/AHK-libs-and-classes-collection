class Givenname extends Flimsydata.Formatter {

	get(dataProvider, locale="de") {
		if (!Object.InstanceOf(%dataProvider%, "Flimsydata.Provider")) {
			throw Exception("Provider class must "
					. "extend 'Flimsydata.Provider': " dataProvider)
		}
		return Flimsydata.getRandomListElement(this.randomizer
				, %dataProvider%.data[locale])
	}
}
