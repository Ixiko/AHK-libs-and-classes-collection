class App {

	requires() {
		return []
	}

	; TODO: Handly cyclic dependencies
	checkRequiredClasses(forClass="") {
		forClass := (forClass != "" ? forClass : this)
		requiredClasses := forClass.requires()
		while (A_Index <= requiredClasses.maxIndex()) {
			requiredClass := requiredClasses[A_Index]
			if (IsObject(requiredClass)) {
				OutputDebug % forClass.__Class " uses " requiredClass.__Class
				App.checkRequiredClasses(requiredClass)
			} else {
				OutputDebug % "Misses requirement #" A_Index
						. " for " forClass.__Class
				MsgBox % "Missing requirement #" A_Index
						. " for " forClass.__Class
				exitapp -1
			}
		}
		return forClass
	}
}
