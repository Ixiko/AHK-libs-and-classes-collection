; https://en.wikipedia.org/wiki/Digest_access_authentication
class DigestAuth
{
	Build(username, password, method, uri, ByRef WWWAuthenticate) {
		Loop, Parse, % "realm|qop|algorithm|nonce|opaque", |
			RegExMatch(WWWAuthenticate, A_LoopField "=""?\K[^,""]+", %A_LoopField%)

		cnonce := this.create_cnonce()
		nonceCount := "00000001"

		ha1 := this.StrMD5(username ":" realm ":" password)
		ha2 := this.StrMD5(method ":" uri)
		response := this.StrMD5(ha1 ":" nonce ":" nonceCount ":" cnonce ":" qop ":" ha2)

		return "
		(Join, LTrim
			Digest username=""" username """
			realm=""" realm """
			nonce=""" nonce """
			uri=""" uri """
			algorithm=""" algorithm """
			cnonce=""" cnonce """
			nc=" nonceCount "
			qop=""" qop """
			response=""" response """
			opaque=""" opaque """
		)"
	}

	StrMD5( V ) { ; www.autohotkey.com/forum/viewtopic.php?p=376840#376840
		VarSetCapacity( MD5_CTX,104,0 ), DllCall( "advapi32\MD5Init", UInt,&MD5_CTX ) 
		DllCall( "advapi32\MD5Update", UInt,&MD5_CTX, A_IsUnicode ? "AStr" : "Str",V 
		, UInt,StrLen(V) ), DllCall( "advapi32\MD5Final", UInt,&MD5_CTX ) 
		Loop % StrLen( Hex:="123456789abcdef0" ) 
			N := NumGet( MD5_CTX,87+A_Index,"Char"), MD5 .= SubStr(Hex,N>>4,1) . SubStr(Hex,N&15,1)
		Return MD5 
	}

	CreateGUID() { ; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=4732
		VarSetCapacity(pguid, 16, 0)
		if !(DllCall("ole32.dll\CoCreateGuid", "ptr", &pguid)) {
			size := VarSetCapacity(sguid, (38 << !!A_IsUnicode) + 1, 0)
			if (DllCall("ole32.dll\StringFromGUID2", "ptr", &pguid, "ptr", &sguid, "int", size))
				return StrGet(&sguid)
		}
		return ""
	}

	create_cnonce() {
		guid := this.CreateGUID()
		StringLower, guid, guid
		return RegExReplace(guid, "[{}-]")
	}
}