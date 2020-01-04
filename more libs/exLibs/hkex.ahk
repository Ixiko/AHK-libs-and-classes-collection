class hkex
	{
	sendSingle(key, replace*){
		hotkey '$' key, 'SSSend', 'on'
		SSSend(){
			thisHk := subStr(a_thisHotkey, 2)
			hotkey thisHk, ()=>
			send replace[1]
			loop replace.length() - 1{
				keyWait thisHk
				keyWait thisHk, 'd'
				send replace[a_index + 1]
				}
			hotkey thisHk, 'off'
			return
			}
		}
	}