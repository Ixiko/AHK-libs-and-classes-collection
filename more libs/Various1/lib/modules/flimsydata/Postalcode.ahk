class Postalcode extends Flimsydata.Formatter {

	get(dataProvider, locale="de_DE") {
		country := Flimsydata.getCountry(locale)
		postalCodeForCountryFunc := %dataProvider%["get" country]
		if (!postalCodeForCountryFunc) {
			throw Exception("Provider '" dataProvider
					. "' missing function for country: " country)
		}
		return postalCodeForCountryFunc.(this, this.randomizer)
	}
}
