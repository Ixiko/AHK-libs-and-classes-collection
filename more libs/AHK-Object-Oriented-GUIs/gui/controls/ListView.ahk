Class ListViewControl extends GuiBase.ControlType {
	Type := "ListView"
	
	RowCount {
		get {
			return this.GetCount()
		}
	}
	
	ColumnCount {
		get {
			return this.GetCount("Column")
		}
	}
	
	SelectedCount {
		get {
			return this.GetCount("Selected")
		}
	}
	
	Add(Options := "", Fields*) {
		this.SetDefault()
		return LV_Add(Options, Fields*)
	}
	
	Insert(Row, Options := "", Col*) {
		this.SetDefault()
		return LV_Insert(Row, Options, Col*)
	}
	
	Delete(Row := "") {
		this.SetDefault()
		if StrLen(Row)
			return LV_Delete(Row)
		else
			return LV_Delete()
	}
	
	GetSelected() {
		return this.GetRows()
	}
	
	GetChecked() {
		return this.GetRows("Checked")
	}
	
	GetNextSelected(Start := 0) {
		return this.GetNext(Start)
	}
	
	GetNextChecked(Start := 0) {
		return this.GetNext(Start, "Checked")
	}
	
	GetNextFocused(Start := 0) {
		return this.GetNext(Start, "Focused")
	}
	
	GetText(Row, Column := 1) {
		this.SetDefault()
		LV_GetText(Text, Row, Column)
		return Text
	}
	
	Modify(Row, Options := "", NewCol*) {
		this.SetDefault()
		return LV_Modify(Row, Options, NewCol*)
	}
	
	ModifyCol(Column := "", Options := "", Title := false) {
		this.SetDefault()
		if (Title != false)
			return LV_ModifyCol(Column, Options, Title)
		else
			return LV_ModifyCol(Column, Options)
	}
	
	Redraw(Toggle) {
		this.SetDefault()
		return this.Gui.Control((Toggle?"+":"-") "Redraw", this.hwnd)
	}
	
	SetImageList(ImageList) {
		this.SetDefault()
		if !IsInstance(ImageList, GuiBase.ImageList)
			throw "Provided ImageList is not of type GuiBase.ImageList"
		this.ImageList := ImageList
		return LV_SetImageList(this.ImageList.id, !ImageList.LargeIcons)
	}
	
	SetDefault() {
		this.Gui.SetDefault()
		this.Gui.SetDefaultListView(this)
	}
	
	IL {
		get {
			return this.ImageList
		}
	}
	
	; internal ?
	
	GetCount(Option := "") {
		this.SetDefault()
		return LV_GetCount(Option)
	}
	
	GetNext(Start := 0, Option := "") {
		this.SetDefault()
		return LV_GetNext(Start, Option)
	}
	
	GetRows(Option := "") {
		i := 0
		Rows := []
		while i := this.GetNext(i, Option)
			Rows.Push(i)
		return Rows
	}
}