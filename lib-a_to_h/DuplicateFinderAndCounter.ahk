
/*
data=
(Join`n
Has anyone seen a function/script that I can borrow from for counting the frequency words show up in a string?

I'm trying to write something that will read a webpage and (with the text from the page)
1) identify the top-10 words that exist
2) display the count of those 10 words

I did some searching and didn't see anything that did this. I'm thinking for lack of finding something already out there I'll write code that does something like this
1) create a dictionary that has the word as key and count as value
2) Read text off page
3) use Regular expression to find each word then either:

    a) adds it to the dictionary and sets value to 1
    b) finds it in the dictionary and adds 1 to the value

4) after iterating through all words, take top 10 and drop the rest

Any help would be greatly appreciated!

)

MsgBox, % DuplicateFinderAndCounter(data)
*/

DuplicateFinderAndCounter(String, TopCounts:=10) {
	Needle := "[\W]+" ; this is the story, I beleive if you were to change someting it would be this regex, or you can use a simple split or StringReplace/RegExReplace every white space  with line feed
	String:=RegExReplace(String, Needle, "`n") ; replace all non word strings with new lines
	Sort, String ; sort the string
	p:=1, needle := "im`n)^(.*)(\n\1)+`n"
	while p:=RegExMatch(String, needle, duplicate, p+strlen(duplicate)){ ; search for consecutive same lines
		StringReplace, s, duplicate, `n,, UseErrorLevel ; get the count of existing lines by using UseErrorLevel
		Duplicates .= ErrorLevel A_Space duplicate1 "`n" ; add the count and the word
	}
	Duplicates:=trim(Duplicates, "`n")
	Sort, Duplicates, RF SortingWithRegEx ; here we sort numerically, each either that, or we do it some other way...
	if f := instr(Duplicates, "`n", false, 1, TopCounts) ; get for the tenth line feed, if there is at least 10
		Duplicates:=substr(Duplicates, 1, f) ; return the top ten, if....
	return, Duplicates
}
 
SortingWithRegEx(a1, a2) {
	RegExMatch(a1, "(^\d+)", f1)
	RegExMatch(a2, "(^\d+)", f2)
    return f1 > f2 ? -1 : 1
}
