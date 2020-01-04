class PPostalcode extends Flimsydata.Provider {

	getDE(randomizer) {
		1stChar := Flimsydata.getRandomInt(randomizer, 0, 9)
		2ndTo4thChar := Flimsydata.getRandomInt(randomizer, 1000, 9999)
		return 1stChar . 2ndTo4thChar
	}

	getUK(randomizer) {
		return Flimsydata.getRandomPattern(randomizer, ["L#\ #LL"
			, "L##\ #LL"
			, "L#L\ #LL"
			, "LL#\ #LL"
			, "LL##\ #LL"
			, "LL#L\ #LL"])
	}

	getNL(randomizer) {
		return Flimsydata.getRandomInt(randomizer, 1000, 9999)
	}
}
