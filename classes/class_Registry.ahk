#NoEnv

; MsgBox, % Registry.prop[ "cd" ]
; ExitApp

/**
 * Window Registry
 */
class Registry {

	static prop := []
	static void := Registry._init()

	__New() {
	  throw Exception( "Registry is a static class, don't instant it!", -1 )
	}

	_init() {
		Registry.prop[ "cd"     ]  := A_ScriptDir
		Registry.prop[ "cdWin"  ]  := RegExReplace( A_ScriptDir, "\\", "\\" )
		Registry.prop[ "cdUnix" ]  := RegExReplace( A_ScriptDir, "\\", "/" )
	}

	getProp( key ) {
		return Registry.prop[ key ]
	}

	setProp( key, value ) {
		Registry.prop[ key ] := value
	}

	/**
	* Write Registry from file 
	*
	* @param file {String} filePath contains data formatted Windows Registry
	*/
	write( file ) {
		SetRegView 32
		Registry._setRegistry( file, prop )
		SetRegView 64
		Registry._setRegistry( file, prop )
	}

	/**
	* Write Registry from file 
	*
	* @param file       {String} filePath contains data formatted Windows Registry
	* @param properties {Array}  properties to bind
	*/
	_setRegistry( file, properties ) {

		regKey       := ""
		readNextLine := false
		isHex        := true

		Loop, Read, %file%
		{

			line := Trim( A_LoopReadLine )

			if RegExMatch(line, "^Windows Registry Editor" ) {
				continue
			} else if ( StrLen(line) == 0 ) {
				Continue
			} else if RegExMatch(line, "^\[.*\]" ) {
				regKey := RegExReplace( line, "^\[(.*)\]", "$1" )
				continue
			} else if ( regKey == "" ) {
				continue
			}

			if ( readNextLine == true ) {
				regVal := regVal line
			} else {
		
				regName := RegExReplace( line, "^(@|"".+?"")=.*$", "$1" )
				regName := RegExReplace( regName, "^""(.+?)""$","$1" )
				regName := RegExReplace( regName, "\\""", """" )
				regName := Registry._bindValue( regName, properties )
				regVal  := RegExReplace( line, "^(@|"".*?"")=(.*)$", "$2" )
				regVal  := RegExReplace( regVal, "\\""", """" )
				regType := "REG_SZ"

	      if ( regName == "@" ) {
	      	regName := ""
	      }

				if RegExMatch( regVal, "^"".*""$" ) {
					regType := "REG_SZ"
					regVal  := Registry._bindValue( RegExReplace( regVal, "^""(.*)""$", "$1" ), properties )
					isHex   := false
				} else if RegExMatch( regVal, "^dword:" ) {
					regType := "REG_DWORD"
					regVal  := RegExReplace( regVal, "^dword:(.*)$", "$1" )
					isHex   := false
				} else if RegExMatch( regVal, "^hex\(b\):" ) {
					regType := "REG_QWORD"
					regVal  := RegExReplace( regVal, "^hex\(b\):(.*)$", "$1" )
					isHex   := true
				} else if RegExMatch( regVal, "^hex\(7\):" ) {
					regType := "REG_MULTI_SZ"
					regVal  := RegExReplace( regVal, "^hex\(7\):(.*)$", "$1" )
					isHex   := true
				} else if RegExMatch( regVal, "^hex\(2\):" ) {
					regType := "REG_EXPAND_SZ"
					regVal  := RegExReplace( regVal, "^hex\(2\):(.*)$", "$1" )
					isHex   := true
				} else if RegExMatch( regVal, "^hex:" ) {
					regType := "REG_BINARY"
					regVal  := RegExReplace( regVal, "^hex:(.*)$", "$1" )
					isHex   := true
				}
				
			}

			if ( RegExMatch(line, "^.*\\$") ) {
    		readNextLine := true
    		continue
			} else {
				readNextLine := false
			}

			if ( isHex == true ) {
				regVal := RegExReplace( regVal, "[\\\t ]", "" )
			}

			if ( regType == "REG_DWORD" ) {
				regVal := "0x" regVal
			} else if ( regType == "REG_QWORD" ) {
				regVal := "0x" Registry._toNumberFromHex( regVal )
			} else if( regType == "REG_MULTI_SZ" ) {
				regVal := Registry._toStringFromHex( regVal )
			} else if( regType == "REG_EXPAND_SZ" ) {
				regVal := Registry._toStringFromHex( regVal )
			} else if( regType == "REG_BINARY" ) {
				StringReplace, regVal, regVal, % ",", , All
			}
			
			regName := Registry._bindValue( regName, properties )

			; debug( "[" regKey "] " regName " - " regType ":" regVal )

			; if it needs to run as admin, restart itself
			if ( ! RegExMatch(regKey, "^(HKEY_CURRENT_USER|HKEY_USERS)\\.*$") ) {
				Registry._restartAsAdmin()
			}

			RegWrite, % regType, % regKey, % regName, % regVal

		}

	}

	_bindValue( value, properties ) {

		For key, val in properties
			value := StrReplace( value, "#{" key "}", val )

		return value

	}

	_toStringFromHex( hexValue ) {

	  if ! hexValue
	    return 0

	  array := StrSplit( hexValue, "," )

	  if ( mod( array.MaxIndex(), 2 ) != 0 ) {
	  	array.Insert( "00" )
	  }

	  result := ""

	  for i, element in array
	  {
	  	if ( mod(i,2) == 0 )
	  		Continue

	  	result := result chr( "0x" array[i + 1] array[i] )
	  }

	  return result

	}

	_toNumberFromHex( hexValue ) {

	  if ! hexValue
	    return 0

	  array := StrSplit( hexValue, "," )

	  if ( mod( array.MaxIndex(), 2 ) != 0 ) {
	  	array.Insert( "00" )
	  }

	  result := ""

	  for i, element in array
	  {
	  	if ( mod(i,2) == 0 )
	  		Continue

	  	result := array[i + 1] array[i] result

	  }

	  ;return "0x" result
	  return "0x0000000c"

	}

	_convertBase( fromBase, toBase, number ) {
    static u := A_IsUnicode ? "_wcstoui64" : "_strtoui64"
    static v := A_IsUnicode ? "_i64tow"    : "_i64toa"
    VarSetCapacity(s, 65, 0)
    value := DllCall("msvcrt.dll\" u, "Str", number, "UInt", 0, "UInt", fromBase, "CDECL Int64")
    DllCall("msvcrt.dll\" v, "Int64", value, "Str", s, "UInt", toBase, "CDECL")
    return s
  }

  _restartAsAdmin() {
		if not (A_IsAdmin) {
		    try ; leads to having the script re-launching itself as administrator
		    {
		        if A_IsCompiled
		            Run *RunAs "%A_ScriptFullPath%" /restart
		        else
		            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
		    }
		    ExitApp
		}
	}

}