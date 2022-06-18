SetBatchLines, -1
#SingleInstance, force
#NoTrayIcon
#Include %A_ScriptDir%\..\export.ahk
#Include %A_ScriptDir%\..\node_modules
#Include unit-testing.ahk\export.ahk

stringSimilarity := new stringsimilarity()
assert := new unittesting()


;; Test compareTwoStrings()
assert.category := "compareTwoStrings"
assert.label("check functional")
assert.test((stringSimilarity.compareTwoStrings("The eturn of the king", "The Return of the King") > 0.90 ), true)
assert.test((stringSimilarity.compareTwoStrings("set", "ste") = 0 ), true)

assert.label("Check if case matters")
assert.test((stringSimilarity.compareTwoStrings("The Mask", "the mask") = 1 ), true)
assert.test(stringSimilarity.compareTwoStrings("thereturnoftheking", "TheReturnoftheKing"), 1)
StringCaseSense, On
assert.test(stringSimilarity.compareTwoStrings("thereturnoftheking", "TheReturnoftheKing"), 1)
StringCaseSense, Off


;; Test findBestMatch()
assert.category := "findBestMatch"
assert.label("ratings object")
testVar := stringSimilarity.findBestMatch("similar", ["levenshtein","matching","similarity"])
assert.test(testVar.ratings.count(), 3)
assert.test(testVar.ratings[1].target, "similarity")
assert.test(testVar.ratings[1].rating, 0.80)
assert.test(testVar.ratings[2].target, "matching")
assert.test(testVar.ratings[2].rating, 0)
assert.test(testVar.ratings[3].target, "levenshtein")
assert.test(testVar.ratings[3].rating, 0)

assert.label("bestMatch object")
assert.test(testVar.bestMatch.target, "similarity")
assert.test(testVar.bestMatch.rating, 0.80)
testVar2 := stringSimilarity.findBestMatch("Hard to", [" hard to    ","hard to","Hard 2"])
assert.test(testVar2.bestMatch.target, "hard to")
assert.test(testVar2.bestMatch.rating, 1)


;; Test simpleBestMatch()
assert.category := "simpleBestMatch"
assert.label("basic usage")
assert.test(stringSimilarity.simpleBestMatch("setting", ["ste","one","set"]), "set")
assert.test(stringSimilarity.simpleBestMatch("Smart", ["smarts","smrt","clip-art"]), "smarts")
assert.test(stringSimilarity.simpleBestMatch("Olive-green table", ["green Subaru Impreza","table in very good","mountain bike with"]), "table in very good")

assert.test(stringSimilarity.simpleBestMatch("Olive-green table for sale, in extremely good condition."
    , ["For sale: green Subaru Impreza, 210,000 miles"
    , "For sale: table in very good condition, olive green in colour."
    , "Wanted: mountain bike with at least 21 gears."])
, "For sale: table in very good condition, olive green in colour.")


;; Display test results in GUI
assert.fullReport()
assert.writeTestResultsToFile()

ExitApp
