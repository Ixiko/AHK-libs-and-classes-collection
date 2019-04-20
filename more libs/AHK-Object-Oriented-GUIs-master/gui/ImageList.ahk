Class ImageList {
	
	List := {}
	Size := 0
	
	__New(InitialCount := 5, GrowCount := 2, LargeIcons := false) {
		this.id := IL_Create(InitialCount, GrowCount, LargeIcons)
		this.InitialCount := InitialCount
		this.GrowCount := GrowCount
		this.LargeIcons := LargeIcons
	}
	
	__Delete() {
		IL_Destroy(this.id)
	}
	
	Add(Resource, IconNumber := "", ResizeNonIcon := "") {
		if id := IL_Add(this.id, Resource, IconNumber, ResizeNonIcon) {
			this.Size++
			return this.List[Resource] := id
		}
	}
}