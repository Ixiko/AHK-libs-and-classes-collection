class CHotstringOptions
{
  static DefaultOptions := {"RequireEndChar":true, "CaseSensitive":false, "ConformToTypedCase":true, "OmitEndChar":true, "StartAnywhere":false, "DeleteHotstring":true, "Raw":true}
  
  static optionNameString := "StartAnywhere,DeleteHotstring,OmitEndChar,ConformToTypedCase,CaseSensitive,RequireEndChar,Raw"
  
  static StartAnywhere := 1
  static DeleteHotstring := 2
  static OmitEndChar := 4
  static ConformToTypedCase := 8
  static CaseSensitive := 16
  static RequireEndChar := 32
  static Raw := 64

  static Default := 110
		
		; Does x contain n: (x & n) = n
		; Include n into x: x |= n
		; Exclude n from x: x & n = n ? x ^= n 
		
		ToOptions(x)
		{
			y := 0
      
      optionString := CHotstringOptions.optionNameString
			
			for k, v in x
			{
        if k not in %optionString%
          continue
          
				if(v)
				{
					;~ OutputDebug, % "Append " CHotstringOptions[k]
					y |= CHotstringOptions[k]
				}
			}
			return y
		}
		
		ToHotstring(x)
		{
      
			if(x & 16 = 16 && x & 8 = 8) ; Exclude CaseSensitive if ConformToTypedCase is set
				x ^= 16
			
      if (x & 4 = 4 && x & 32 <> 32) ; Exclude OmitEndingCharacter if RequireEndingCharacter is not set
          x ^= 4
            
			y := {"RequireEndChar":false, "CaseSensitive":false, "ConformToTypedCase":false, "OmitEndChar":false, "StartAnywhere":false, "DeleteHotstring":false, "Raw":false}
			
			if(x & 1 = 1)
				y.StartAnywhere := true
			
			if(x & 2 = 2)
				y.DeleteHotstring := true
			
			if(x & 4 = 4)
				y.OmitEndChar := true
			
			if(x & 8 = 8)
				y.ConformToTypedCase := true
			
			if(x & 16 = 16)
				y.CaseSensitive := true
			
			if(x & 32 = 32)
				y.RequireEndChar := true
			
			if(x & 64 = 64)
				y.Raw := true
; 			OutputDebug % "HSC: OEC = " y.OmitEndChar
			return y
		}
}
