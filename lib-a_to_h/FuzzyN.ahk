Fuzzy(input, arr){ ; magic happens here
	if !(input := RegExReplace(input, " ", "")).length { ; return the array if input is empty
		for a, b in arr, list:=[]
			list[a] := {name:b}
		return list
	} t:=[]
	for index, word in arr { ; loop the array word for word
		m:=[], i:=0, ws := word.split()
		for z, a in input.split() ; split in the input
			for v, b in ws
				if (a = b) && !m[a, v] { ; figure out how many matching letters we have
					m[a, v] := true, i++
					continue 2
				}
		if (i = input.length) { ; all letters from input is in word
			outline := ws[1]
			for x, v in ws
				if v.equals(" ", ".")
					outline .= ws[A_Index+1]
			for g, h in m, n := ""
				if (h.MaxIndex() > n)
					n := h.MaxIndex()
			item := {   name:word
					, score:(n - input.length)*(1/log((ItemList.Lists[Settings.List].Freq[word])**3+9))
					, contains:!!word.find(input)
					, outline:!!RegExReplace(word, "[^A-Z0-9]").find(input) || outline.find(input)
					, start:(word.find(input) = 1) || (ws[word.find(input) - 1] = " ")}
			if t.MaxIndex() {
				for a, b in t, added:=false
					if (b.score >= item.score) {
						t.InsertAt(A_Index, item), added:=true
						break
					}
			} if !added
				t.Insert(item)
		}
	} for n, p in (list:=t)[1] ; get all attribute names
		for a, b in t, i:=0 ; loop the list for all items
			if b[n] && n.equals("contains", "outline", "start") ; if the attribute is true and is either contains, outline or start then..
				list.Remove(a), list.InsertAt(++i, b) ; remove it from the list and insert it at the top
	return list
}

FuzzyWrap(input, arr) {
	static fuzzy_func
	Main.Control("-Redraw", "SysListView321")
	LV_Delete()
	if !fuzzy_func {
		if IsFunc("CustomFuzzy")
			fuzzy_func := "CustomFuzzy"
		else
			fuzzy_func := "Fuzzy"
	} for a, b in %fuzzy_func%(input, arr)
		LV_Add("Icon" . ItemList.Lists[Settings.List].Icon[b.name], b.name, ItemList.Lists[Settings.List].Freq[b.name], b.score)
	if !LV_GetCount()
		LV_Add("Icon1", "No results!")
	if !input.length {
		if ((Settings.List = "items") && Settings.FreqSort) || (ItemList.Lists[Settings.List].FreqSort = true)
			LV_ModifyCol(2, "SortDesc")
	} LV_Modify(1, "Select")
	Main.SizeGui()
	Main.Control("+Redraw", "SysListView321")
}

; move the score index to score attribute

/*
	; CODE EXAMPLE
	
	list := []
	for a, b in xml.get("//item")
		list[A_Index] := b.name
	
	Gui Margin, 5, 5
	Gui Add, ListView, vMyListView Count50 -TabStop -Multi +AltSubmit w790 h365, Result|Score|Contains?|Abbreviation?|Beginning?
	Gui Add, Edit, vInput h20 w790 gfuzzytest
	Gui Show, h400 w800, Fuzzy sort algorithm
	LV_ModifyCol(1, 400)
	Loop 4
		LV_ModifyCol(A_Index+1, 80)
	gosub fuzzytest
	return
	
	fuzzytest:
	Gui Submit, NoHide
	GuiControl -Redraw, MyListView
	LV_Delete()
	for a, b in Fuzzy(input, list)
		LV_Add(, b.name, b.score, b.contains ? "yes" : "no", b.outline ? "yes" : "no", b.start ? "yes" : "no")
	LV_Modify(1, "Select")
	GuiControl +Redraw, MyListView
	return
	
	GuiEscape:
	GuiClose:
	ExitApp
	return
	
	Fuzzy(input, arr){ ; magic happens here
		if !(input := RegExReplace(input, " ", "")).length { ; return the array if input is empty
			for a, b in arr, list:=[]
				list[a] := {name:b}
			return list
		} t:=[]
		for index, word in arr { ; loop the array word for word
			m:=[], i:=0, ws := word.split()
			for z, a in input.split() ; split in the input
				for v, b in ws
					if (a = b) && !m[a, v] { ; figure out how many matching letters we have
						m[a, v] := true, i++
						continue 2
					}
			if (i = input.length) { ; all letters from input is in word
				outline := ws[1]
				for x, v in ws
					if v.equals(" ", ".")
						outline .= ws[A_Index+1]
				for g, h in m, n := ""
					if (h.MaxIndex() > n)
						n := h.MaxIndex()
				item := {   name:word
					, score:(n - input.length)*(1/log((ItemList.Lists[Settings.List].Freq[word])**3+9))
					, contains:!!word.find(input)
					, outline:!!RegExReplace(word, "[^A-Z0-9]").find(input) || outline.find(input)
					, start:(word.find(input) = 1) || (ws[word.find(input) - 1] = " ")}
				if t.MaxIndex() {
					for a, b in t, added:=false
						if (b.score >= item.score) {
							t.InsertAt(A_Index, item), added:=true
							break
						}
				} if !added
					t.Insert(item)
			}
		} for n, p in (list:=t)[1] ; get all attribute names
			for a, b in t, i:=0 ; loop the list for all items
				if b[n] && n.equals("contains", "outline", "start") ; if the attribute is true and is either contains, outline or start then..
					list.Remove(a), list.InsertAt(++i, b) ; remove it from the list and insert it at the top
		return list
	}
	
*/