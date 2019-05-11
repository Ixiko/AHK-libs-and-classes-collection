/*
 Function:	Parse
 			Options parser.

			O	- String with options.
			pQ	- Query parameter. It is space separated list of option names you want to extract from the options string. See bellow for
				  details of extraction.  
			o1..o10 - Variables to receive requested options. Their number should match the number of variables you want to extract from the option string plus
					  1 more if you want to get non-consumed options.

 Query:
			Query is space separated list of variables you want to extract with optional settings prefix .
			The query syntax is:

 >			Query :: [Settings)][Name=]Value {Query}
 >			Settings :: sC|aC|qC|eC|c01{Settings}
 >			Value   :: SentenceWithoutSpace | 'SentenceWithSpace'


 Examples:
 >			options =  x20 y40 w0 h0 red HWNDvar gLabel
 >			options =  w800 h600 style='Resize ToolWindow' font='s12 bold, Courier New' 'show' dummy=dummy=5

 Extracting:
			To extract variables from the option string you first use query parameter to specify how to do extraction
			then you supply variables to hold the results:

 >		    Parse(O, "x# y# h# red? HWND* style font 1 3", x, y, h, bRed, HWND, style, font, p1, p3)

			name	- Get the option by the name (style, font). In option string, option must be followed by assignment char (= by default).
			N		- Get option by its position in the options string, (1 3).
			str*	- Get option that has str prefix (HWND*). 
			str#	- Get option that holds the number and have str prefix (x# y# h#).
			str?	- Boolean option, output is true if str exists in the option string or false otherwise (red?).

 Settings:
			You can change separator(s), assignment(a), escape(e) and quote(q) character and case sensitivity (c) using syntax similar to RegExMatch.
			Option value follows the option name without any separator character.

 >			Parse("x25|y27|Style:FLAT TOOLTIP", "s|a:c1)x# y# style", x, y, style)
			
			In above example, | is used as separator, : is used as assignment char and case sensitivity is turned on (style wont be found as it starts with S in options string).

			sC	- Set separator char to C (default is space)
			aC  - Set assignment char to C (default is =)
			qE	- Set quote char to C	(default is ')
			eE	- Set escape char to C  (default is	`)

 Remarks:
			Currently you can extract maximum 10 options at a time, but this restriction can be removed for up to 29 options.
			You can specify one more reference variable in addition to those you want to extract to get all extra options in the option string.

 Returns:
			Number of options in the string.

 About:
			o v 1.0 by majkinetor
			o Licenced under BSD <http://creativecommons.org/licenses/BSD/> 
 */
Parse(O, pQ, ByRef o1="",ByRef o2="",ByRef o3="",ByRef o4="",ByRef o5="",ByRef o6="",ByRef o7="",ByRef o8="", ByRef o9="", ByRef o10=""){
	cS := " ", cA := "=", cQ := """", cE := "\", cC := 0
	if (j := InStr(pQ, ")")) && (opts := SubStr(pQ, 1, j-1), pQ := SubStr(pQ, j+1))
		Loop, parse, opts
			  mod(A_Index, 2) ? f:=A_LoopField : c%f%:=A_LoopField

	p__0 := 0, st := "n"
	loop, parse, O						;  states: normal(n), separator(s), quote(q), escape(e)
	{
		c := A_LoopField
		if (c = cS) {
			if !InStr("qs", st)	
				p__0++,  p__%p__0% := token,  token := "",  st := "s"			
		}
		else if (c = cE)
			st := "e"
		else if (c = cQ) && (st != "e") 
			 ifNotEqual, st, q, SetEnv, st, q				 
			else st := "n"
		else ifNotEqual, st, q, SetEnv, st, n
		if st not in s,e
			 token .= c		
	}
	if (token != "")
		p__0++, p__%p__0% := token
	
	loop, parse, pQ, %A_Space%
	{
		c := SubStr(f := A_LoopField, 0),  n := InStr("?#*", c) ? SubStr(f, 1, -1) : f,  j := A_Index, o := ""
		if n is integer
			o := p__%n%,  p__%n% := ""
		else  {	
			l := StrLen(n)
			loop, %p__0% {
				p := p__%A_Index%
				if (!cC && !(SubStr(p, 1, l) = n)) || (cC & !(SubStr(p, 1, l) == n))
					continue				
				v := SubStr(p,l+1,1) = cA  ? SubStr(p,l+2) : SubStr(p, l+1)
				ifEqual, c, ?, SetEnv, v, 1
				if (c="#") && (v+0 = "")
					continue
				o := v,  p__%A_Index% := ""
				break
			}
		}
		o%j% := SubStr(o, 1, 1) = cQ ? SubStr(o, 2, -1) : o
	}
	j++
	loop, %p__0%
		o%j% .= p__%A_Index% != "" ? p__%A_Index% cS : ""
	o%j% := SubStr(o%j%, 1, -1)
	return p__0
}