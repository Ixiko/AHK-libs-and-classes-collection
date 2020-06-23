; ahk: console
#NoEnv
#Warn All, StdOut

#Include <lib>
#Include <random>
#Include <calendar>

#Include %A_ScriptDir%\..\flimsydata.ahk

class FlimsyDataTestClass extends TestCase {

	requires() {
		return [TestCase, FlimsyData, Calendar, Random]
	}

	@Test_getNumber() {
		fd := new FlimsyData.Simple(123)
		this.assertEquals(fd.getInt(), 3)
		this.assertEquals(fd.getInt(50, 100), 75)
		this.assertEquals(fd.getInt(200, 2000), 1927)
		this.assertEquals(fd.getInt(, 2000), 611)
		this.assertEquals(fd.getFloat(), 3.041659)
		this.assertEquals(fd.getFloat(0.0, 999.9), 690.815911)
		this.assertEquals(fd.getFloat(0.0, 999.99, 06.1), "0551.3")
	}

	@Test_getFloat() {
		fd := new FlimsyData.Simple(123)
		this.AssertEquals(fd.GetFloat(), 7.268221)
		this.AssertEquals(fd.GetFloat(0.0, 999.9), 712.883705)
		this.AssertEquals(fd.GetFloat(0.0, 999.99, 06.1), "0286.1")
	}

	@Test_getString() {
		fd := new FlimsyData.Simple(1342)
		this.assertEquals(fd.getMixedString(1), "w")
		this.assertEquals(fd.getMixedString(3), "KDo")
		this.assertEquals(fd.getUpperCaseString(3), "XJB")
		this.assertEquals(fd.getLowerCaseString(3), "ers")
		this.assertEquals(fd.getMixedString(5), "rKMvw")
		this.assertEquals(fd.getMixedString(3, 8), "sIxxi")
		this.assertEquals(fd.getUpperCaseString(4, 10), "PQTHR")
		this.assertEquals(fd.getLowerCaseString(8, 12), "gsynttrjz")
	}
	@Test_getTimeStamp() {
		fd := new FlimsyData.Simple(211215)
		this.assertEquals(fd.getTimeStamp(1601, 9999), 16610721040435)
		this.assertEquals(fd.getTimeStamp(19950501, 9999), 19960727124807)
		this.assertEquals(fd.getTimeStamp(1601, 19690313), 16830519133542)
		this.assertEquals(fd.getTimeStamp(19690313, 19950501), 19800403034719)
	}

	@Test_getDate() {
		fd := new FlimsyData.Simple(1046)
		this.assertEquals(fd.getDate(1601, 9999), 16010329)
		this.assertEquals(fd.getDate(1969, 1995), 19740124)
	}

	@Test_getTime() {
		fd := new FlimsyData.Simple(22122015)
		this.assertEquals(fd.getTime(000000, 235959), 234415)
		this.assertEquals(fd.getTime(100000, 120000), 100230)
	}

	@Test_patternSubSetOfElements() {
		fd4p := new FlimsyData.Pattern(0x0a1b2c)
		fd4p.pattern := "%[Mo,Di,Mi,Do,Fr,Sa,So]"
		fd4p.findSubSetsOfElements()
		this.assertTrue(Arrays.Equal(fd4p.patternGroup[1]
				, ["Mo","Di","Mi","Do","Fr","Sa","So"]))
		fd4p.pattern := "%[a,b,c]%[x,y,z]"
		fd4p.findSubSetsOfElements()
		this.assertTrue(Arrays.Equal(fd4p.patternGroup[2], ["x", "y", "z"]))
	}

	@Test_randomPattern() {
		fd4p := new FlimsyData.Pattern(0x0a1b2c)
		this.assertEquals(fd4p.getPattern("v%[Mo,Di,Mi,Do,Fr,Sa,So]AA%[Jan,Feb,Mar,Apr,Mai,Jun,Jul,Aug,Sep,Okt,Nov,Dez]C.#%[PHd,BatJ,HosB,KnoA,TsA,SrP]"), "oDi3,JunP-7HosB") ; ahklint-ignore: W002
		this.assertEquals(fd4p.getPattern(["CvccVcv##$", "xxx%[&,$,%,@]"])
				, "DehlIpi14<")
		this.assertEquals(fd4p.getPattern(["CvccVcv##$", "xxx%[&,$,%,@]"])
				, "JaxyIya79|")
		this.assertEquals(fd4p.getPattern(["CvccVcv##$", "xxx%[&,$,%,@]"])
				, "LjL@")
		this.assertEquals(fd4p.getPattern(["L##\ ##L", "LL#\ L#"]), "B17 89P")
		this.assertEquals(fd4p.getPattern(["L##\ ##L", "LL#\ L#"]), "ZG8 A4")
		this.assertEquals(fd4p.getPattern(["Cv\-cc\-Vcv##$", "xx\:x%[&,$,%,@]"])
				, "Uo:Z&")
		this.assertEquals(fd4p.getPattern(["XXXXXXXXXXX"]), "noyXepbePUN")
		this.assertEquals(fd4p.getPattern(["Cv\-cc\-Vcv##$", "xx\:x%[&,$,%,@]"])
				, "Le-xj-Aqo39%")
		this.assertEquals(fd4p.getPattern("cvcvcv##%[!,§,$,%,(,),=]")
				, "goliru51$")
		this.assertException(fd4p, "getPattern",,, "abc")
	}

	@Test_getCountry() {
		this.assertEquals(FlimsyData.getCountry("de_DE"), "DE")
		this.assertEquals(FlimsyData.getCountry("de"), "DE")
		this.assertEquals(FlimsyData.getCountry("en_US"), "US")
		this.assertException(FlimsyData, "getCountry",,, "abc")
	}

	@Test_getLanguage() {
		this.assertEquals(FlimsyData.getLanguage("de_DE"), "de")
		this.assertEquals(FlimsyData.getLanguage("de"), "de")
		this.assertEquals(FlimsyData.getLanguage("en_US"), "en")
		this.assertException(FlimsyData, "getLanguage",,, "abc")
	}

	@Test_givenname() {
		fd4gn := new FlimsyData.Givenname(4002)
		this.assertEquals(fd4gn.get("PGivenname"), "Axel")
		this.assertEquals(fd4gn.get("PGivenname"), "Axel")
		this.assertEquals(fd4gn.get("PGivenname"), "Jochen")
	}

	@Test_postalcode() {
		fd4pc := new Flimsydata.Postalcode(13)
		this.assertEquals(fd4pc.get("PPostalcode"), 86152)
		this.assertEquals(fd4pc.get("PPostalcode", "en_UK"), "TF66 9PH")
		this.assertEquals(fd4pc.get("PPostalcode", "en_UK"), "W06 4CH")
		this.assertEquals(fd4pc.get("PPostalcode", "nl"), 3909)
	}

	@Test_Lorem() {
		fd := new FlimsyData.Lorem(10595)
		this.assertEquals(fd.getSentence("PLorem"), "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.") ; ahklint-ignore: W002
		this.assertEquals(fd.getWord("PLorem"), "in")
		this.assertEquals(fd.getWord("PLorem"), "wisi")
		this.assertEquals(fd.getWord("PLorem"), "tation")
	}

	@Test_TextWithOwnProvider() {
		fd := new FlimsyData.Lorem(135910)
		this.assertEquals(fd.getWord("PTestText"), "Kapitel")
		this.assertEquals(fd.getWord("PTestText"), "besteht")
		this.assertEquals(fd.getSentence("PTestText"), "Wie man hier sieht!")
		this.assertEquals(fd.getSentence("PTestText")
				, "Und schließlich der zweite Satz des dritten Absatzes.")
		this.assertTrue(Arrays.Equal(fd.getChapter("PTestText")
				, PTestText.data[1]))
		this.assertEquals(fd.getWord("PTEstText", 3), "Satz zum diesem")
	}

	@Test_Metasyntax() {
		fd := new FlimsyData.Lorem(22917155)
		this.AssertEquals(fd.getWord("PMetasyntax"), "Quux")
		this.AssertEquals(fd.getWord("PMetasyntax"), "bar")
		this.AssertEquals(fd.getWord("PMetasyntax"), "qux")
		this.AssertEquals(fd.getWord("PMetasyntax", 15)
				, "corge Waldo corge <cr> plugh <cr> qux <tab> corge "
				. "bar qux Fred foo bar Waldo")
	}

	@Test_Fileext() {
		fd := new FlimsyData.Lorem(12345)
		this.AssertEquals(fd.getWord("PFileext"), "ahk")
	}
}

FlimsyDataTestClass.RunTests()
exitapp

class PTestText extends FlimsyData.Provider {

	; ahklint-ignore-begin: W002,W003
	static data := [ [ "Das ist der erste Satz des ersten Absatzes. Und das der Zweite."
				     , "Dies hier ist der erste und einzige Satz des zweiten Absatzes."
				     , "Als nächstes der erste Satz des dritten Absatzes. Und schließlich der zweite Satz des dritten Absatzes. Abschließend noch der dritte und letzte Satz des dritten Absatzes." ]
				   , [ "Hier fängt das zweite Kapitel an. Somit ist dies der zweite Satz im ersten Absatz des zweiten Kapitels. Der erste Absatz des zweiten Kapitels endet mit diesem Satz!"
					 , "Auch das zweite Kapitel hat mehrere Absätze. Wie man hier sieht!"
					 , "Das sollte zum testen genügen." ]
				   , [ "Dieser Testtext besteht aus drei Kapiteln:"
				     , "Das erste hat drei Absätze."
					 , "Das zweite hat nur einen Absatz."
					 , "Und das dritte hat vier Absätze." ] ]
	; ahklint-ignore-end
}

