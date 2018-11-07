/*
	Class JSONFile
	Written by Runar "RUNIE" Borge
	
	Dependencies:
	JSON loader/dumper by cocobelgica: https://github.com/cocobelgica/AutoHotkey-JSON
	However the class can easily be modified to use another JSON dump/load lib.
	
	To create a new JSON file wrapper:
	MyJSON := new JSONFile(filepath)
	
	And to destroy it:
	MyJSON := ""
	
	Methods:
		.Save(Prettify := false) - save object to file
		.JSON(Prettify := false) - Get JSON text
		.Fill(Object) - fill keys in from another object into the instance object
		
	Instance variables:
		.File() - get file path
		.Object() - get data object
*/

Class JSONFile {
	static Instances := []
	
	__New(File) {
		FileExist := FileExist(File)
		JSONFile.Instances[this] := {File: File, Object: {}}
		ObjRelease(&this)
		FileObj := FileOpen(File, "rw")
		if !IsObject(FileObj)
			throw Exception("Can't access file for JSONFile instance: " File, -1)
		if FileExist {
			try
				JSONFile.Instances[this].Object := JSON.Load(FileObj.Read())
			catch e {
				this.__Delete()
				throw e
			} if (JSONFile.Instances[this].Object = "")
				JSONFile.Instances[this].Object := {}
		} else
			JSONFile.Instances[this].IsNew := true
		return this
	}
	
	__Delete() {
		if JSONFile.Instances.HasKey(this) {
			ObjAddRef(&this)
			JSONFile.Instances.Delete(this)
		}
	}
	
	__Call(Func, Param*) {
		; return instance value (File, Object, FileObj, IsNew)
		if JSONFile.Instances[this].HasKey(Func)
			return JSONFile.Instances[this][Func]
		
		; return formatted json
		if (Func = "JSON")
			return StrReplace(JSON.Dump(this.Object(),, Param.1 ? A_Tab : ""), "`n", "`r`n")
		
		; save the json file
		if (Func = "Save") {
			try
				New := this.JSON(Param.1)
			catch e
				return false
			FileObj := FileOpen(this.File(), "w")
			FileObj.Length := 0
			FileObj.Write(New)
			FileObj.__Handle
			return true
		}
		
		; fill from specified array into the JSON array
		if (Func = "Fill") {
			if !IsObject(Param.2)
				Param.2 := []
			for Key, Val in Param.1 {
				if (A_Index > 1)
					Param.2.Pop()
				HasKey := Param.2.MaxIndex()
						? this.Object()[Param.2*].HasKey(Key) 
						: this.Object().HasKey(Key)
				Param.2.Push(Key)
				if IsObject(Val) && HasKey
					this.Fill(Val, Param.2), Param.2.Pop()
				else if !HasKey
					this.Object()[Param.2*] := Val
			} return
		}
		
		return Obj%Func%(this.Object(), Param*)
	}
	
	__Set(Key, Val) {
		return this.Object()[Key] := Val
	}
	
	__Get(Key) {
		return this.Object()[Key]
	}
}