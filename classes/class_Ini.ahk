class Ini
{
        ; Loads ini file.
    __New(File, Default = "") {
        If (FileExist(File)) and (RegExMatch(File, "\.ini$"))
            FileRead, Info, % File
        Else
            Info := File
        Loop, Parse, Info, `n, `r
        {
            RegExMatch(A_LoopField, "^\[(.+?)\]$", Section) ; Get the section name.
            RegExMatch(A_LoopField, "(.+?)=(.*)", Key) ; Get the key and its value.
            If (Section1)
                Saved_Section := Trim(Section1), this[Saved_Section] := { }
            Key2 := (Key2) ? Key2 : Default
            If (Key1) and (Saved_Section)
                this[Saved_Section].Insert(Key1, Key2) ; Set the section name withs its keys and values.
        }
        this.File := File
    }

    __Get(Section) {
        If (!this.HasKey(Section)) and (Section)
            this[Section] := { }
    }

    ; Renames an entire section or just an individual key.
    Rename(Section, NewName, KeyName = "") { ; If KeyName is omited, rename the seciton, else rename key.
        Sections := this.Sections(",")
        If Section not in %Sections%
            Return 1
        else if ((this.HasKey(NewName)) and (!KeyName)) ; If the new section already exists.
            Return 1
        else if ((this[Section].HasKey(NewName)) and (KeyName)) ; If the section already contains the new key name.
            Return 1
        else if (!this[Section].HasKey(KeyName) and (KeyName)) ; If the section doesn't have the key to rename.
            Return 1
        else If (!KeyName)
        {
            this[NewName] := { }
            for key, value in this[Section]
                this[NewName].Insert(Key, Value)
            this.Remove(Section)
        }
        Else
        {
            KeyValue := this[Section][KeyName]
            this[Section].Insert(NewName, KeyValue)
            this[Section].Remove(KeyName)
        }
        Return 0
    }

    ; Delete a whole section or just a specific key within a section.
    Delete(Section, Key = "") { ; Omit "Key" to delete the whole section.
        If (Key)
            this[Section].Remove(Key)
        Else
            this.Remove(Section)
    }

    ; Returns a list of sections in the ini.
    Sections(Delimiter = "`n") {
        for Section, in this
            List .= (this.Keys(Section)) ? Section . Delimiter : ""
        Return SubStr(List, 1, -1)
    }

    ; Get all of the keys in the entire ini or just one section.
    Keys(Section = "") { ; Leave blank to retrieve all keys or specify a seciton to retrieve all of its keys.
        Sections := Section ? Section : this.Sections()
        Loop, Parse, Sections, `n
            for key, in this[A_LoopField]
                keys .= key . "`n"
        Return SubStr(keys, 1, -1)
    }

    ; Saves everything to a file.
    Save(File = "") {
        if (!File)
            File := this.File

        Sections := this.Sections()
        loop, Parse, Sections, `n
        {
            NewIni .= (A_LoopField) ? "[" . A_LoopField . "]`n" : ""
            For key, value in this[A_LoopField]
                NewIni .= key . "=" . value . "`n"
        }
        FileDelete, % File
        FileAppend, % SubStr(NewIni, 1, -1), % File
    }

}
