class iniex{
	static ini := {}
	
	create(sections){
		for sectionName, section in sections{
			iniex.ini[sectionName] := {}
			for key, iniKey in section
				iniex.ini[sectionName][iniKey] := ''
			}
		}
	get(file := "settings.ini"){
		global
		loop parse iniRead(file), '`n'
			getSection(a_loopField, file)
		getSection(iniex_section, iniex_file := "settings.ini"){
			global
			local iniex_sectionLines, iniex_iniLine
			loop parse iniRead(iniex_file, iniex_section), '`n'{
				regExMatch(a_loopField, "(?P<key>[^=]+)=", iniex_iniLine)
				%iniex_iniLine.key% := iniRead(iniex_file, iniex_section, iniex_iniLine.key)
				iniex.ini[iniex_section][iniex_iniLine.key] := %iniex_iniLine.key%
				}
			}
		}
	put(file := 'settings.ini', delete := true){
		iniex.update()
		for sectionName, section in iniex.ini
			for key, value in section
				if value != ''
					iniWrite value, file , sectionName, key
				else
					if delete
						iniDelete file, sectionName, key
		}
	update()
		{
		global
		local iniex_secName, iniex_section, iniex_key
		for iniex_secName, iniex_section in iniex.ini
			for iniex_key in iniex_section
				iniex.ini[iniex_secName][iniex_key] := %iniex_key%
		}
	}