; Title:
; Link:   	github.com/lintalist/lintalist/blob/master/include/LetterVariations.ahk
; Author:	Lintalist
; Date:
; for:     	AHK_L

/*

	; LintaList Include
	; Purpose: Return RegEx string to allow search for letter variations
	; 'e' will search for [eéèêěĕẽẻėëēęếềễểẹệæǣǽœᵫ]
	; Version: 1.7
	; Date:    20190130 - added ẹ
	;
	; Includes Diacritics and Ligatures (not all) - see link below
	; https://en.wiktionary.org/wiki/Appendix:Variations_of_%22a%22 ... ; etc
	; see also https://www.autohotkey.com/boards/viewtopic.php?p=47793#p47793 for OP
	;
	; For discussion and suggestions:
	; https://github.com/lintalist/lintalist/issues/33
	; (easy to expand to include braille or language specific variations or other glyphs
	; and Unicode artefacts)

*/

LetterVariations(text,c=0)	{

	 ; text : input text
	 ; c : case sensitive 0 no, 1 yes
	 static lower:="[abcdeghiklnopqrstuvwxyz]", upper:="[ABCDEGHIKLNOPQRSTUVWXYZ]", Array := { "a" : "áàâǎăãảạäåāąấầẫẩậắằẵẳặǻæᴁᴭǽǣᴂᵆ"
	 , "b" : "ȸ"
	 , "c" : "ćĉčċç"
	 , "d" : "ďđðȸǳǲǆǅ"
	 , "e" : "éèêěĕẽẻėëēęếềễểẹệæǣǽœᵫẹ"
	 , "g" : "ğĝġģǵǧǥ₲"
	 , "h" : "ȟĥħḩḫẖḣḥḧƕⱨⱶ"
	 , "i" : "íìĭîǐïĩįīỉịĵﬁĳ"
	 , "k" : "ķĸǩḱḲḵ₭"
	 , "l" : "ĺľļłŀﬂǉǈǇ"
	 , "n" : "ñńņňɲŋƞǹȵɳṅṇṉṋ"
	 , "o" : "óòŏôốồỗổǒöőõøǿōỏơớờỡởợọộᴔœɶȢȣᴕ"
	 , "p" : "ƥṕṗ"
	 , "q" : "ʠɊɋ"
	 , "r" : "ŕřȑȓɼɽɾṙṛṝṟ"
	 , "s" : "şŝșṩṥṡṧšśṣ"
	 , "t" : "ƫțţʈŧťṫṭẗṯ"
	 , "u" : "úùŭûǔůüǘǜǚǖűũųūủưứừữửựụᵫ"
	 , "v" : "ṽṿ"
	 , "w" : "ẃẁŵẅ"
	 , "x" : "ẍẋᶍ"
	 , "y" : "ýỳŷÿỹỷỵ"
	 , "z" : "źžż" }

	 if (c = 0) or (c = false) or (c = "")
		for k, v in Array
			text:=RegExReplace(text,"im)" k,"[" k v "]")

	 if (c = 1) or (c = true) {
		 for k, v in Array {
			 if RegExMatch(text,lower) {
				 StringLower, k, k
				 StringLower, v, v
				 text:=RegExReplace(text,"m)" k,"[" k v "]")
			}
			 if RegExMatch(text,upper)	{
				 StringUpper, k, k
				 StringUpper, v, v
				 text:=RegExReplace(text,"m)" k,"[" k v "]")
				}
			}
		}

Return text
}