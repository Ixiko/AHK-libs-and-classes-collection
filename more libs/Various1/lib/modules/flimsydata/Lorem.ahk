class Lorem extends Flimsydata.Formatter {

	getChapter(dataProvider, count=1) {
		numberOfChapter := Flimsydata.getRandomInt(this.randomizer
				, %dataProvider%.data.minIndex()
				, %dataProvider%.data.maxIndex())
		return %dataProvider%.data[numberOfChapter]
	}

	getParagraph(dataProvider, count=1) {
		paragraph := ""
		loop %count% {
			chapter := this.getChapter(dataProvider, 1)
			numberOfParagraph := Flimsydata.GetRandomInt(this.randomizer
					, chapter.minIndex()
					, chapter.maxIndex())
			paragraph .= (paragraph = "" ? "" : "`n")
					. chapter[numberOfParagraph]
		}
		return paragraph
	}

	getSentence(dataProvider, count=1) {
		sentence := ""
		loop %count% {
			paragraph := this.getParagraph(dataProvider, 1)
			paragraph := RegExReplace(paragraph, "\.(?=\s*?\w)", ".`n")
			paragraph := RegExReplace(paragraph, "!(?=\s*?\w)", "!`n")
			paragraph := RegExReplace(paragraph, "\?(?=\s*?\w)", "?`n")
			listOfSentences := StrSplit(paragraph, "`n", " `t")
			numberOfSentence := Flimsydata.GetRandomInt(this.randomizer
					, listOfSentences.minIndex()
					, listOfSentences.maxIndex())
			sentence .= (sentence = "" ? "" : " ")
					. listOfSentences[numberOfSentence]
		}
		return sentence
	}

	getWord(dataProvider, count=1) {
		word := ""
		loop %count% {
			sentence := this.getSentence(dataProvider, 1)
			listOfWords := StrSplit(sentence, " ", " !,.?-")
			numberOfWord := Flimsydata.GetRandomInt(this.randomizer
					, listOfWords.minIndex()
					, listOfWords.maxIndex())
			word .= (word = "" ? "" : " ") listOfWords[numberOfWord]
		}
		return word
	}

	dump(dataProvider) {
		chapterIndex := %dataProvider%.data.MinIndex()
		while (chapterIndex <= %dataProvider%.data.MaxIndex()) {
			par := %dataProvider%.data[chapterIndex].MinIndex()
			while (par <= %dataProvider%.data[chapterIndex].MaxIndex()) {
				partext := %dataProvider%.data[chapterIndex, par]
				partext := RegExReplace(partext, "\.(?=\s*?\w)", ".`n")
				partext := RegExReplace(partext, "!(?=\s*?\w)", "!`n")
				partext := RegExReplace(partext, "\?(?=\s*?\w)", "?`n")
				sent_list := StrSplit(partext, "`n", " `t")
				for i, sent in sent_list {
					OutputDebug % chapterIndex ".§" par "#" i ": " sent
				}
				par++
			}
			chapterIndex++
		}
	}
}
