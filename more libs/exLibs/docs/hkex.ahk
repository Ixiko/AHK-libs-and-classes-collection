class hkex
	{
	sendSingle(key, replace*){
		static organizer := {}
		organizer[key] := {count: 1, replace: replace}
		hotkey '$' key, 'SSSend', 'on'
		SSSend(){
			ref := organizer[subStr(a_thisHotkey, 2)]
			;msgBox ref.count
			if ref.count <= ref.replace.length()
				send ref.replace[ref.count++]
			if ref.count > ref.replace.length()
				hotkey key, 'off'
			}
		}
	}