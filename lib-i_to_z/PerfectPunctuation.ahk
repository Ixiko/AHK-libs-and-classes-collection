;Punctuate() v0.1
;	by Avi Aryan
;Perfect punctuations in sentences
;Suitable for Ahk_Basic

;msgbox % Punctuate("hi,how are you?i am fine and i know you are fine too.thank you!")
;msgbox,% Punctuate("hello.www.ahk.com.you're great,amazing...and ahk.net also is wonderful.")
;msgbox,% Punctuate("http://i.imgur.com/OZ0a4Ju.jpg")
;return

Punctuate(str){

	static puncs := ",}):;&~""" , capitals := ".?!" ,
	static ignorepatterns := ":/|"					;separate by |

	str := __StringUpper(Substr(str,1,1)) Substr(str,2) 		;First letter capital
	str := RegExReplace(str, "im)( |`t|\.|\?|\!)i([^a-z])", "$1I$2") 	;I

	sentence_start := 1

	outer:
	loop % Strlen(str)
	{
		A := Substr(str, A_index, 1) , B := Substr(str, A_index+1, 1)

		loop, parse, ignorepatterns,|  			;ignore patterns matching
			if ( A_LoopField == A B )
			{
				toret .= A
				Continue outer
			}

		if (A == A_space) 		;enable capital
			sentence_start := 0

		if capital 				;capitals
		{
			toret .= sentence_start ? A : __StringUpper(A) , capital := 0 , sentence_start := 1
			Continue
		}

		if Instr(capitals, A) and !Instr(puncs, B)		;Capital activated
			toret .= A , capital := 1
		else if Instr(puncs, A) and Instr(puncs, B) 	;Space [NO]
			toret .= A
		else if Instr(puncs, A) 						;Space
			toret .= A A_Space
		else toret .= A
	}

	return toret
}

__StringUpper(str){
	StringUpper, t, str
	return t
}