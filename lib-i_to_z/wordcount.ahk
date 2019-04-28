
/*
TestText := "
(Join`r`n
Has anyone seen a function/script that I can borrow from for counting the frequency words show up in a string?

I'm trying to write something that will read a webpage and (with the text from the page)
1) identify the top-10 words that exist
2) display the count of those 10 words
)"

MyCount := WordCount(TestText)
for k, v in MyCount.Count
	Res1 .= v "`t" k "`r`n"
MsgBox, % Res1	; Shows each word's number of occurrences

n := 0
Loop, {
	Max := MyCount.Order.MaxIndex()
	for k, v in MyCount.Order[Max] {
		Res2 .= Max "`t" v "`r`n"
		if (++n = 10)
			break, 2
	}
	MyCount.Order.Remove(Max)
	if (!MyCount.Order.MaxIndex())
		break
}
MsgBox, % Res2	; Shows the ten most frequent words
*/

WordCount(String) {
	Cnt := {}, Odr := {}
	while p := RegexMatch(String, "\b[\w']+\b", m) {
		String := RegExReplace(String, "i)\b" m "(?!')\b", "", c)
		Cnt[m] := c
		Odr[c] ? Odr[c].Insert(m) : Odr[c] := [m]
	}
	return {Count: Cnt, Order: Odr}
}