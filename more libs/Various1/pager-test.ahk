; ahk: console
#NoEnv
#Warn All, StdOut
#SingleInstance off

#Include <testcase-libs>

#Include %A_ScriptDir%\..\pager.ahk

class PagerTest extends TestCase {

	static runInteractivePager := false
	static FIGURES_DIR := A_ScriptDir "\figures\pager\"

	@BeforeClass_setup() {
		Pager.runInTestMode := true
		Pager.breakMessage := "--break--"
	}

	@BeforeRedirStdOut() {
		Ansi.stdOut := FileOpen(A_Temp "\pager-test.txt", "w `n", "cp850")
	}

	@BeforeResetLineCounter() {
		Pager.lineCounter := 0
	}

	@AfterRedirStdOut() {
		Ansi.stdOut.close()
		Ansi.stdOut := Ansi.__InitStdOut()
		FileDelete %A_Temp%\pager-test.txt
	}

	@Test_oneLine() {
		Pager.writeHardWrapped("Das ist ein Einzeiler.")
        Ansi.flush()
		this.assertEquals(TestCase.fileContent(A_Temp "\pager-test.txt")
				, TestCase.fileContent(PagerTest.FIGURES_DIR "OneLine.txt"))
	}

	@Test_almostAPage() {
		loop % Pager.getConsoleHeight()-2 {
			testText := "Das ist Zeile #" A_Index "!"
			Pager.writeHardWrapped(testText)
		}
		Ansi.flush()
		this.assertEquals(TestCase.fileContent(A_Temp "\pager-test.txt")
				, TestCase.fileContent(PagerTest.FIGURES_DIR "AlmostAPage.txt"))
	}

	@Test_moreThanAPage() {
		loop % Pager.getConsoleHeight()+2 {
			testText := "Das ist Zeile #" A_Index "!"
			Pager.writeHardWrapped(testText)
		}
		Ansi.flush()
		this.assertEquals(TestCase.fileContent(A_Temp "\pager-test.txt")
				, TestCase.fileContent(PagerTest.FIGURES_DIR
				. "MoreThanAPage.txt"))
	}

	@Test_moreThanTwoPages() {
		loop % 50 {
			testText := "Das ist Zeile #" A_Index "!"
			Pager.writeHardWrapped(testText)
		}
		Ansi.flush()
		this.assertEquals(TestCase.fileContent(A_Temp "\pager-test.txt")
				, TestCase.fileContent(PagerTest.FIGURES_DIR
				. "MoreThanTwoPages.txt"))
	}

	@Test_moreThanThreePages() {
		loop % 100 {
			testText := "Das ist Zeile #" A_Index "!"
			Pager.writeHardWrapped(testText)
		}
		Ansi.flush()
		this.assertEquals(TestCase.fileContent(A_Temp "\pager-test.txt")
				, TestCase.fileContent(PagerTest.FIGURES_DIR
				. "MoreThanThreePages.txt"))
	}

	@Test_coloredOutput() {
		text := printBlindText()
		text := RegExReplace(text, "i)\b(\w*[öäüß]+\w*)", "[32m$0[0m")
		text := RegExReplace(text, "i)\b([,.!?:]+)", "[31m$0[0m")
		Pager.writeWordWrapped(text)
		Ansi.flush()
		this.assertEquals(TestCase.fileContent(A_Temp "\pager-test.txt")
				, TestCase.fileContent(PagerTest.FIGURES_DIR
				. "ColoredOutput.txt"))
	}

	@Test_longLines() {
		text := handleLongLines()
		Pager.writeHardWrapped(text)
		Ansi.flush()
	}

	@Test_interactivePager() {
		if (!PagerTest.runInteractivePager) {
			return
		}
		Pager.runInTestMode := false
		Pager.lineCounter := 0
		Ansi.stdOut.close()
		Ansi.stdOut := Ansi.__InitStdOut()
		text := printBlindText()
		text := RegExReplace(text, "i)\b(\w*[öäüß]+\w*)", "[32m$0[0m")
		text := RegExReplace(text, "i)\b([,.!?:]+)", "[31m$0[0m")
		Pager.writeWordWrapped(text)
		Ansi.flush()
	}
}

if (A_Args[1] = "@Test_interactivePager") {
	PagerTest.runInteractivePager := true
}
exitapp PagerTest.runTests()

printBlindText() {
	return "Er hörte leise Schritte hinter sich. Das bedeutete nichts Gutes. Wer würde ihm schon folgen, spät in der Nacht und dazu noch in dieser engen Gasse mitten im übel beleumundeten Hafenviertel? Gerade jetzt, wo er das Ding seines Lebens gedreht hatte und mit der Beute verschwinden wollte! Hatte einer seiner zahllosen Kollegen dieselbe Idee gehabt, ihn beobachtet und abgewartet, um ihn nun um die Früchte seiner Arbeit zu erleichtern? Oder gehörten die Schritte hinter ihm zu einem der unzähligen Gesetzeshüter dieser Stadt, und die stählerne Acht um seine Handgelenke würde gleich zuschnappen? Er konnte die Aufforderung stehen zu bleiben schon hören. Gehetzt sah er sich um. Plötzlich erblickte er den schmalen Durchgang. Blitzartig drehte er sich nach rechts und verschwand zwischen den beiden Gebäuden. Beinahe wäre er dabei über den umgestürzten Mülleimer gefallen, der mitten im Weg lag. Er versuchte, sich in der Dunkelheit seinen Weg zu ertasten und erstarrte: Anscheinend gab es keinen anderen Ausweg aus diesem kleinen Hof als den Durchgang, durch den er gekommen war. Die Schritte wurden lauter und lauter, er sah eine dunkle Gestalt um die Ecke biegen. Fieberhaft irrten seine Augen durch die nächtliche Dunkelheit und suchten einen Ausweg. War jetzt wirklich alles vorbei, waren alle Mühe und alle Vorbereitungen umsonst? Er presste sich ganz eng an die Wand hinter ihm und hoffte, der Verfolger würde ihn übersehen, als plötzlich neben ihm mit kaum wahrnehmbarem Quietschen eine Tür im nächtlichen Wind hin und her schwang. Könnte dieses der flehentlich herbeigesehnte Ausweg aus seinem Dilemma sein? Langsam bewegte er sich auf die offene Tür zu, immer dicht an die Mauer gepresst. Würde diese Tür seine Rettung werden?`n`n" ; ahklint-ignore: W002
	. "Eine wunderbare Heiterkeit hat meine ganze Seele eingenommen, gleich den süßen Frühlingsmorgen, die ich mit ganzem Herzen genieße. Ich bin allein und freue mich meines Lebens in dieser Gegend, die für solche Seelen geschaffen ist wie die meine. Ich bin so glücklich, mein Bester, so ganz in dem Gefühle von ruhigem Dasein versunken, daß meine Kunst darunter leidet. Ich könnte jetzt nicht zeichnen, nicht einen Strich, und bin nie ein größerer Maler gewesen als in diesen Augenblicken. Wenn das liebe Tal um mich dampft, und die hohe Sonne an der Oberfläche der undurchdringlichen Finsternis meines Waldes ruht, und nur einzelne Strahlen sich in das innere Heiligtum stehlen, ich dann im hohen Grase am fallenden Bache liege, und näher an der Erde tausend mannigfaltige Gräschen mir merkwürdig werden; wenn ich das Wimmeln der kleinen Welt zwischen Halmen, die unzähligen, unergründlichen Gestalten der Würmchen, der Mückchen näher an meinem Herzen fühle, und fühle die Gegenwart des Allmächtigen, der uns nach seinem Bilde schuf, das Wehen des Alliebenden, der uns in ewiger Wonne schwebend trägt und erhält; mein Freund! Wenn's dann um meine Augen dämmert, und die Welt um mich her und der Himmel ganz in meiner Seele ruhn wie die Gestalt einer Geliebten - dann sehne ich mich oft und denke : ach könntest du das wieder ausdrücken, könntest du dem Papiere das einhauchen, was so voll, so warm in dir lebt, daß es würde der Spiegel deiner Seele, wie deine Seele ist der Spiegel des unendlichen Gottes! - mein Freund - aber ich gehe darüber zugrunde, ich erliege unter der Gewalt der Herrlichkeit dieser Erscheinungen.`n`n" ; ahklint-ignore: W002,W003
	. "Jemand musste Josef K. verleumdet haben, denn ohne dass er etwas Böses getan hätte, wurde er eines Morgens verhaftet. »Wie ein Hund!« sagte er, es war, als sollte die Scham ihn überleben. Als Gregor Samsa eines Morgens aus unruhigen Träumen erwachte, fand er sich in seinem Bett zu einem ungeheueren Ungeziefer verwandelt. Und es war ihnen wie eine Bestätigung ihrer neuen Träume und guten Absichten, als am Ziele ihrer Fahrt die Tochter als erste sich erhob und ihren jungen Körper dehnte. »Es ist ein eigentümlicher Apparat«, sagte der Offizier zu dem Forschungsreisenden und überblickte mit einem gewissermaßen bewundernden Blick den ihm doch wohlbekannten Apparat. Sie hätten noch ins Boot springen können, aber der Reisende hob ein schweres, geknotetes Tau vom Boden, drohte ihnen damit und hielt sie dadurch von dem Sprunge ab. In den letzten Jahrzehnten ist das Interesse an Hungerkünstlern sehr zurückgegangen. Aber sie überwanden sich, umdrängten den Käfig und wollten sich gar nicht fortrühren. Jemand musste Josef K. verleumdet haben, denn ohne dass er etwas Böses getan hätte, wurde er eines Morgens verhaftet. »Wie ein Hund!« sagte er, es war, als sollte die Scham ihn überleben. Als Gregor Samsa eines Morgens aus unruhigen Träumen erwachte, fand er sich in seinem Bett zu einem ungeheueren Ungeziefer verwandelt. Und es war ihnen wie eine Bestätigung ihrer neuen Träume und guten Absichten, als am Ziele ihrer Fahrt die Tochter als erste sich erhob und ihren jungen Körper dehnte. »Es ist ein eigentümlicher Apparat«, sagte der Offizier zu dem Forschungsreisenden und überblickte mit einem gewissermaßen bewundernden Blick den ihm doch wohlbekannten Apparat. Sie hätten noch ins Boot springen können, aber der Reisende hob ein schweres, geknotetes Tau vom Boden, drohte ihnen damit und hielt sie dadurch von dem Sprunge ab. In den letzten Jahrzehnten ist das Interesse an Hungerkünstlern sehr zurückgegangen. Aber sie überwanden sich, umdrängten den Käfig und wollten sich gar nicht fortrühren.`n" ; ahklint-ignore: W002,W003
}

printAnsiColors() {
	return "Ansi Color Demo`n"
			. "`nnormal foreground color & normal background color`n`n"
			. swatches(30, 40)
			. "`nLight foreground color & normal background color`n`n"
			. swatches(90, 40)
			. "`nNormal foreground color & light background color`n`n"
			. swatches(30, 100)
			. "`nLight foreground color & light background color`n`n"
			. swatches(90, 100)
}

swatches(foregroundColorBase, backgroundColorBase) {
	if (backgroundColorBase < 100) {
		padWith := " "
	}
	textLine := ""
	loop 8 {
		foregroundColor := foregroundColorBase + (A_Index-1)
		loop 8 {
			backgroundColor := backgroundColorBase + (A_Index-1)
			ansiSequence := foregroundColor ";" backgroundColor "m"
			textLine .= "[" ansiSequence " " padWith ansiSequence " [0m "
		}
		textLine .= "`n"
	}
	return textLine
}

handleLongLines() {
	textLine := ""
	loop 50 {
		textLine .= A_Index ": Er hörte leise Schritte hinter sich. Das bedeutete nichts Gutes. Wer würde ihm schon folgen, spät in der Nacht und dazu noch in dieser engen Gasse mitten im übel beleumundeten Hafenviertel? Gerade jetzt, wo er das Ding seines Lebens gedreht hatte und mit der Beute verschwinden wollte!`n" ; ahklint-ignore: W002
	}
	return textLine
}
