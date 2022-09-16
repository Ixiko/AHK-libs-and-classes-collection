; Title:   	[Class] string-similarity.ahk
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?p=381831#p381831
; Author:	burque505
; Date:
; for:     	AHK_L

/*


*/

asm  	:= Clr_LoadLibrary(A_ScriptDir "\F23.StringSimilarity.dll")
dam 		:= Clr_CreateObject(asm, "F23.StringSimilarity.Damerau")
cosi   	:= Clr_CreateObject(asm, "F23.StringSimilarity.Cosine")
ngram 	:= Clr_CreateObject(asm, "F23.StringSimilarity.NGram")
jacc  	:= Clr_CreateObject(asm, "F23.StringSimilarity.Jaccard")
dice  	:= Clr_CreateObject(asm, "F23.StringSimilarity.SorensenDice")
lcs     	:= Clr_CreateObject(asm, "F23.StringSimilarity.LongestCommonSubsequence")

str1 := "Big fat monkeys eat too many coconuts for breakfast"
;str2 := "Large obese monkeys eat too many coconuts for lunch in the summertime"
str2 := "Large obese monkeys are common in Western zoos"

msgbox % "str1: " 									str1
			. "`nstr2: " 								str2
			. "`nDamerau distance: " 			dam.Distance(str1, str2)
			. "`nCosine similarity: " 				cosi.Similarity(str1, str2)
			. "`nCosine distance: " 				cosi.Distance(str1, str2)
			. "`nNGram similarity: " 			ngram.Distance(str1, str2)
			. "`nJaccard distance: " 				jacc.Distance(str1, str2)
			. "`nJaccard similarity: " 			jacc.Similarity(str1, str2)
			. "`nSorensenDice similarity: " 	dice.Similarity(str1, str2)
			. "`nSorensenDice distance: " 	dice.Distance(str1, str2)
			. "`nLCS distance: " 					lcs.Distance(str1, str2)
			. "`nLCS length: " 						lcs.Length(str1, str2)
asm := dam := cosi := ngram := jacc := dice := lcs := ""


ExitApp

#include D:\Autohotkey\GitHub\AHK-libs-and-classes-collection\libs\a-f\CLR.ahk
#include D:\Autohotkey\GitHub\AHK-libs-and-classes-collection\libs\a-f\com.ahk