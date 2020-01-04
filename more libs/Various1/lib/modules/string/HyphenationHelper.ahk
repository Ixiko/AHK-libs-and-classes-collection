class HyphenationHelper {

	static CONSONANTS  := "bcdfghjklmnpqrstvwxz"
	static VOCALS  := "aeiouyäöü"
	static CLUSTERED_CONSONANTS := "(sch|ch|ck|ph|rf|sh|th)"
	static CLUSTERED_VOCALS := "(au|eu|ie|ei|äu)"

	static MIDDLE_DOT := "·" ; Chr(183)
	static HYPHEN_LINE := "-"

	static hyphen := HyphenationHelper.MIDDLE_DOT

	static wordToBeHyphenated := ""
	static consonantAtLeft := 0
	static consonantAt := 0
	static vocalAt := 0

	hyphenate(wordToBeHyphenated, hyphenateAt=-1, hyphenChar="") {
		HyphenationHelper.wordToBeHyphenated := wordToBeHyphenated
		startAt := (hyphenateAt > 0 ? hyphenateAt : 1)
		HyphenationHelper.setHyphen(hyphenateAt, hyphenChar)
		loop {
			startAt := HyphenationHelper.findPositionOfNextVocal(startAt)
			HyphenationHelper.findPositionOfConsonantAtLeft()
			if (HyphenationHelper.distanceToConsonantIsGreaterThanTwo()) {
				startAt := HyphenationHelper.hasClusteredConsonants(startAt)
			} else if (HyphenationHelper.distanceToVocalIsGreaterThanThree()) {
				startAt := HyphenationHelper.hasClusteredVocals(startAt)
			}
			if (A_Index >= StrLen(wordToBeHyphenated)) {
				throw Exception("Infinite hyphenation loop: "
						. wordToBeHyphenated)
			}
		} until (hyphenateAt > 0
				|| startAt >= StrLen(HyphenationHelper.wordToBeHyphenated))
		if (hyphenateAt > 0
				&& HyphenationHelper.wordToBeHyphenated = wordToBeHyphenated) {
			throw Exception("Could not be hyphenated up to position "
					. hyphenateAt ": " wordToBeHyphenated)
		}
		return HyphenationHelper.wordToBeHyphenated
	}

	setHyphen(hyphenateAt, hyphenChar) {
		HyphenationHelper.hyphen := (hyphenChar != "" ? hyphenChar
				: (hyphenateAt > 0 ? HyphenationHelper.HYPHEN_LINE
				: HyphenationHelper.MIDDLE_DOT))
	}

	findPositionOfNextVocal(startAt) {
		HyphenationHelper.vocalAt
				:= RegExMatch(HyphenationHelper.wordToBeHyphenated
				, "[" HyphenationHelper.VOCALS "]",, startAt)
		return HyphenationHelper.vocalAt + 1
	}

	findPositionOfConsonantAtLeft() {
		HyphenationHelper.consonantAt := HyphenationHelper.vocalAt
		loop {
			HyphenationHelper.consonantAtLeft
					:= SubStr(HyphenationHelper.wordToBeHyphenated
					, HyphenationHelper.consonantAt-=1, 1)
		} until (InStr(HyphenationHelper.CONSONANTS
				, HyphenationHelper.consonantAtLeft))
	}

	hasClusteredConsonants(startAt) {
		c2 := SubStr(HyphenationHelper.wordToBeHyphenated
				, HyphenationHelper.consonantAt-1, 1)
		if (c2 != HyphenationHelper.hyphen
				&& c2 != HyphenationHelper.HYPHEN_LINE) {
			c3 := (c2 HyphenationHelper.consonantAtLeft = "ch"
					&& SubStr(HyphenationHelper.wordToBeHyphenated
					, HyphenationHelper.consonantAt-2, 1) = "s"
					? "s"
					: "") ; check for 'sch'
			syllable := c3 c2 HyphenationHelper.consonantAtLeft
			if (RegExMatch(syllable, HyphenationHelper.CLUSTERED_CONSONANTS)) {
				HyphenationHelper.consonantAt-=StrLen(syllable)-1
			}
			HyphenationHelper.wordToBeHyphenated
					:= SubStr(HyphenationHelper.wordToBeHyphenated
					, 1, HyphenationHelper.consonantAt-1)
					. HyphenationHelper.hyphen
					. SubStr(HyphenationHelper.wordToBeHyphenated
					, HyphenationHelper.consonantAt)
		}
		return startAt + 1
	}

	hasClusteredVocals(startAt) {
		v1 := SubStr(HyphenationHelper.wordToBeHyphenated
				, HyphenationHelper.vocalAt-1, 1)
		v2 := SubStr(HyphenationHelper.wordToBeHyphenated
				, HyphenationHelper.vocalAt-2, 1)
		if (RegExMatch(v2 v1, HyphenationHelper.CLUSTERED_VOCALS)) {
			HyphenationHelper.wordToBeHyphenated
					:= SubStr(HyphenationHelper.wordToBeHyphenated
					, 1, HyphenationHelper.vocalAt-1)
					. HyphenationHelper.hyphen
					. SubStr(HyphenationHelper.wordToBeHyphenated
					, HyphenationHelper.vocalAt)
		}
		return startAt + 1
	}

	distanceToConsonantIsGreaterThanTwo() {
		return HyphenationHelper.consonantAt > 2
	}

	distanceToVocalIsGreaterThanThree() {
		return HyphenationHelper.vocalAt > 3
	}

	getVocalAt() {
		return HyphenationHelper.vocalAt
	}

	getConsonantAt() {
		return HyphenationHelper.consonantAt
	}
}
; vim:tw=0:ts=4:sts=4:sw=4:noet:ft=autohotkey:nobomb
