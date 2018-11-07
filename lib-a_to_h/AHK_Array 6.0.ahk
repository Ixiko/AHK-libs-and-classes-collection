/*
======================================================================================================================================================
==[ Information ]=====================================================================================================================================
======================================================================================================================================================
	File		AHKA.ahk
	Name		AHKArray - AutoHotkey Array
	Type		AutoHotkey Library
	Version		6.00
	Make		2008:0730:1530
	Author		Oleg Lokhvitsky
	License		MIT Style
	Web-Site	http://www.autohotkey.com/forum/viewtopic.php?t=14881
	Documentation	http://www.autohotkey.com/forum/viewtopic.php?t=14881
			http://olegl.com/AHKArray/Documentation/Default.html
	Compatibility	Since Version 6.00
======================================================================================================================================================
==[ License - MIT Style ]=============================================================================================================================
======================================================================================================================================================
	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files
	(the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge,
	publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
	subject to the following conditions:
	
	This permission notice shall be included in all copies or substantial portions of the Software. Except as contained in this notice,
	the name(s) of the above copyright holders shall not be used in advertising or otherwise to promote the sale, use or other dealings
	in this Software without prior written authorization.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
	FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
	WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
======================================================================================================================================================
==[ Outline - Development Checklist ]=================================================================================================================
======================================================================================================================================================
	[ General Functions ]
		01. [X] NewArray		[0 bugs known]	[0 bugs fixed]
		02. [X] Size			[0 bugs known]	[1 bugs fixed]
		03. [X] Add			[0 bugs known]	[2 bugs fixed]	[overloaded]
		04. [X] Get			[0 bugs known]	[1 bugs fixed]	[overloaded]
		05. [X] Remove			[0 bugs known]	[2 bugs fixed]	[overloaded]
		06. [X] Set			[0 bugs known]	[0 bugs fixed]	[overloaded]
		07. [X] Split			[0 bugs known]	[2 bugs fixed]
		08. [X] Convert			[0 bugs known]	[1 bugs fixed]
		09. [X] Sort			[0 bugs known]	[6 bugs fixed]
		10. [X] Swap			[0 bugs known]	[0 bugs fixed]
		11. [X] Find			[0 bugs known]	[0 bugs fixed]
		12. [X] Minimum			[0 bugs known]	[0 bugs fixed]
		13. [X] Maximum			[0 bugs known]	[0 bugs fixed]
		14. [X] Reverse			[0 bugs known]	[1 bugs fixed]
		15. [X] Trim			[0 bugs known]	[0 bugs fixed]
		16. [X] Merge			[0 bugs known]	[1 bugs fixed]	[overloaded]
		17. [X] String			[0 bugs known]	[1 bugs fixed]
		18. [X] Move			[0 bugs known]	[0 bugs fixed]
	[ Utility Functions ]
		01. [X] Open			[0 bugs known]	[0 bugs fixed]
		02. [X] Close			[0 bugs known]	[0 bugs fixed]
		03. [X] GetFirstDimension	[0 bugs known]	[4 bugs fixed]
		04. [X] GetDimension		[0 bugs known]	[2 bugs fixed]
		05. [X] ParseFirst		[0 bugs known]	[4 bugs fixed]
		06. [X] Parse			[0 bugs known]	[0 bugs fixed]
		07. [X] Unparse			[0 bugs known]	[2 bugs fixed]
		08. [X] Floor			[0 bugs known]	[0 bugs fixed]
		09. [X] Abs			[0 bugs known]	[0 bugs fixed]
		10. [X] CharToHex		[0 bugs known]	[0 bugs fixed]
		11. [X] CharFromHex		[0 bugs known]	[0 bugs fixed]
		12. [X] Hex			[0 bugs known]	[2 bugs fixed]
		13. [X] HexArray		[0 bugs known]	[0 bugs fixed]
		14. [X] CheckDebug		[0 bugs known]	[0 bugs fixed]
		15. [X] SetDebug		[0 bugs known]	[0 bugs fixed]
		16. [X] GetSimple		[0 bugs known]	[2 bugs fixed]	[subloaded]
		17. [X] SetSimple		[0 bugs known]	[0 bugs fixed]	[subloaded]
		18. [X] MergeSimple		[0 bugs known]	[1 bugs fixed]	[subloaded]
		19. [X] AddSimple		[0 bugs known]	[6 bugs fixed]	[subloaded]
		20. [X] RemoveSimple		[0 bugs known]	[2 bugs fixed]	[subloaded]
	[ Debug Functions ]
		01. [X] Error			[0 bugs known]	[0 bugs fixed]
		02. [X] IsArray			[0 bugs known]	[0 bugs fixed]
	[ To-Do List By Priority ]
		* Fix Bugs
		* Add Error Support (Ex: Index Out Of Bounds)
		* Add More Functions
		* Change All If's To If() Format
		* Upkeep Minimized & Debug Versions, Where Debug Version Has Lots Of Comments
======================================================================================================================================================
==[ Error & Debug Functions ]=========================================================================================================================
======================================================================================================================================================
*/
	; Reports errors occuring in AHKA functions
	AHKA_Error(Err="")
	{
		if (Err = "")
			Err := "Unspecified Error"
		MsgBox, 16, AHKArray - Error!, An error occured while working with an AHKArray!`r`n%Err%
	}
	AHKA_IsArray(Array)
	{
		return (SubStr(Array,1,1) == "[" && SubStr(Array,0,1) == "]")
	}
/*
======================================================================================================================================================
==[ Dimensionality Functions ]========================================================================================================================
======================================================================================================================================================
*/
	AHKA_Open(Array)
	{
		if (!AHKA_IsArray(Array))
			AHKA_Error("Invalid AHKArray format!`r`nDoes not satisfy AHKA_IsArray(Array)!")
		else
			return SubStr(Array,2,-1)
	}
	AHKA_Close(Array)
	{
		return "[" . Array . "]"
	}
	AHKA_ParseFirst(Array)
	{
		TArray := AHKA_Open(Array)
		IndexA := InStr(TArray, "[")
		if (IndexA = 0)
			return Array
		IndexT := InStr(TArray, "[", false, IndexA+1)
		IndexB := InStr(TArray, "]")
		Loop
		{
			if (IndexT > IndexB)
				break
			if (IndexT = 0)
				break
			if (IndexB = 0)
			{
				AHKA_Error("Invalid AHKArray format!`r`nInvalid amount of Start [ and End ] symbols!")
				return ""
			}
			IndexT := InStr(TArray, "[", false, IndexT+1)
			IndexB := InStr(TArray, "]", false, IndexB+1)
		}
		return "[" . SubStr(TArray,1,IndexA-1) . "|" . SubStr(TArray,IndexB+1) . "]"
	}
	AHKA_Parse(Array)
	{
		TArray := Array
		Loop
		{
			if (InStr(AHKA_Open(TArray), "[") = 0)
				break
			TArray := AHKA_ParseFirst(TArray)
		}
		return TArray
	}
	AHKA_Unparse(Array, OArray, skip="")
	{
		C := 1
		TArray := AHKA_Open(Array)
		NArray := AHKA_NewArray()
		Loop, Parse, TArray, `,
		{
			if (A_LoopField = "|")
			{
				if (A_Index != skip)
					NArray := AHKA_AddSimple(NArray,AHKA_GetDimension(OArray,C),0,0)
				C++
			}
			else
			{
				if (A_Index != skip)
					NArray := AHKA_AddSimple(NArray,A_LoopField,0,0)
			}
		}
		return NArray
	}
	AHKA_GetFirstDimension(Array)
	{
		TArray := AHKA_Open(Array)
		IndexA := InStr(TArray, "[")
		if (IndexA = 0)
			return Array
		IndexT := InStr(TArray, "[", false, IndexA+1)
		IndexB := InStr(TArray, "]")
		Loop
		{
			if (IndexT > IndexB)
				break
			if (IndexT = 0)
				break
			if (IndexB = 0)
			{
				AHKA_Error("Invalid AHKArray format!`r`nInvalid amount of Start [ and End ] symbols!")
				return ""
			}
			IndexT := InStr(TArray, "[", false, IndexT+1)
			IndexB := InStr(TArray, "]", false, IndexB+1)
		}
		Ret := SubStr(TArray,IndexA,IndexB-IndexA+1)
		return Ret
	}
	AHKA_GetDimension(Array, Index=0)
	{
		TArray := Array
		LastDimension := Array
		Loop
		{
			if (A_Index = Index)
				return AHKA_GetFirstDimension(TArray)
			if (InStr(AHKA_Open(TArray), "[") = false)
				return LastDimension
			LastDimension := AHKA_GetFirstDimension(TArray)
			TArray := AHKA_ParseFirst(TArray)
		}
	}
/*
======================================================================================================================================================
==[ Mathematics Functions ]===========================================================================================================================
======================================================================================================================================================
*/
	AHKA_Floor(number)
	{
		if number=0
			return 0
		newnumber := 0
		if number<0
		{
			Loop
			{
				if newnumber>%number%
					newnumber--
				else
					return newnumber
			}
		}
		if number>0
		{
			Loop
			{
				if newnumber<%number%
					newnumber++
				else
					return --newnumber
			}
		}
	}
	AHKA_Abs(number)
	{
		if number=0
			return 0
		if number<0
			return -number
		if number>0
			return number
	}
	AHKA_SetDebug(newDebug)
	{
		global
		AHKA_Debug := newDebug
	}
	AHKA_CheckDebug()
	{
		global
		if (AHKA_Debug)
			return false
		else
			return true
	}
	AHKA_Hex(String,Way,Enabled=true)
	{
		if (Enabled)
			Enabled := AHKA_CheckDebug()
		if (Enabled)
		{
			if Way=1	; TO HEX
			{
				String2 := ""
				Loop, Parse, String
				{
					String2 := String2 . AHKA_CharToHex(A_LoopField)
				}
				return String2
			}
			else if Way=0	; FROM HEX
			{
				String2 := ""
				a := 0
				b := ""
				Loop, Parse, String
				{
					if a=0
					{
						b := A_LoopField
						a := "1"
					}
					else if a=1
					{
						b := b . A_LoopField
						a := "0"
						String2 := String2 . AHKA_CharFromHex(b)
					}
				}
				return String2
			}
			else
			{
				return String
			}
		}
		else
		{
			return String
		}
	}
	AHKA_CharToHex(String)
	{
		length := StrLen(String)
		if length!=1
		{
			return ""
		}
		else
		{
			Transform, c1, Asc, %String%
			c3 := c1	;modulus
			c2 := "0"	;division
			Loop
			{
				if c3<16
					break
				else
				{
					c3-=16
					c2++
				}
			}
			if c2>15
				c2:="15"
			if c2<0
				c2:="0"
			if c3>15
				c3:="15"
			if c3<0
				c3:="0"
			if c2=10
				c2:="A"
			if c2=11
				c2:="B"
			if c2=12
				c2:="C"
			if c2=13
				c2:="D"
			if c2=14
				c2:="E"
			if c2=15
				c2:="F"
			if c3=10
				c3:="A"
			if c3=11
				c3:="B"
			if c3=12
				c3:="C"
			if c3=13
				c3:="D"
			if c3=14
				c3:="E"
			if c3=15
				c3:="F"
			ret := "" . c2 . "" . c3
			return ret
		}
	}
	AHKA_CharFromHex(String)
	{
		length := StrLen(String)
		if length!=2
		{
			return ""
		}
		else
		{
			c1 := SubStr(String,1,1)
			if c1=A
				c1:="10"
			if c1=B
				c1:="11"
			if c1=C
				c1:="12"
			if c1=D
				c1:="13"
			if c1=E
				c1:="14"
			if c1=F
				c1:="15"
			if c1>15
				c1:="15"
			if c1<0
				c1:="0"
				
			c2 := SubStr(String,2,1)
			if c2=A
				c2:="10"
			if c2=B
				c2:="11"
			if c2=C
				c2:="12"
			if c2=D
				c2:="13"
			if c2=E
				c2:="14"
			if c2=F
				c2:="15"
			if c2>15
				c2:="15"
			if c2<0
				c2:="0"
				
			c3 := c1*16+c2
			Transform, c4, Chr, %c3%
			return c4
		}
	}
/*
======================================================================================================================================================
==[ User & Utility Functions Support ]================================================================================================================
======================================================================================================================================================
*/
	AHKA_NewArray(String="")
	{
		if (String = "")
			return "[]"
		else if (AHKA_Debug)
			return String
		else
		{
			myArray := AHKA_HexArray(String)
			return myArray
		}
	}
	AHKA_HexArray(Array)
	{
		AHKA_SetDebug(true)
		mySize := AHKA_Size(Array)
		Loop, %mySize%
		{
			temp := AHKA_GetSimple(Array, A_Index)
			if (AHKA_IsArray(AHKA_GetSimple(Array, A_Index)))
				Array := AHKA_SetSimple(Array, AHKA_HexArray(AHKA_GetSimple(Array, A_Index)), A_Index)
			else
			{
				oldValue := AHKA_GetSimple(Array, A_Index)
				AHKA_SetDebug(false)
				newValue := AHKA_Hex(oldValue, 1, true)
				Array := AHKA_SetSimple(Array, newValue, A_Index)
				AHKA_SetDebug(true)
			}
		}
		AHKA_SetDebug(false)
		return Array
	}
	AHKA_Size(Array)
	{
		TArray := AHKA_Open(AHKA_Parse(Array))
		C := 0
		Loop, Parse, TArray, `,
		{
			C++
		}
		return C
	}
	AHKA_Add(Array,Value,Index1=0,Index2="",Index3="",Index4="",Index5="",Index6="",Index7="",Index8="",Index9="",Index10="")
	{
		IArray0 := Array
		Loop
		{
			cIndex := A_Index
			lIndex := A_Index - 1
			if (Index%cIndex% && AHKA_IsArray(AHKA_Get(IArray%lIndex%, Index%cIndex%)))
			{
				IArray%cIndex% := AHKA_GetSimple(IArray%lIndex%, Index%cIndex%)
			}
			else
			{
				IArray%lIndex% := AHKA_AddSimple(IArray%lIndex%, Value, Index%cIndex%)
				cIndex --
				Loop, %cIndex%
				{
					nIndex := cIndex - A_Index
					lIndex := nIndex + 1
					t1 := IArray%nIndex%
					t2 := IArray%lIndex%
					t3 := Index%nIndex%
					IArray%nIndex% := AHKA_Set(IArray%nIndex%, IArray%lIndex%, Index%lIndex%)
				}
				return IArray0
			}
		}
	}
	AHKA_AddSimple(Array,Value,Index=0,HexIt=1)
	{
		t := AHKA_IsArray(Value)
		if HexIt=1
			if not t
				Value := AHKA_Hex(Value,1)
		BArray := AHKA_NewArray()
		TArray := AHKA_Open(Array)
		if Array=%BArray%
		{
			return AHKA_Close(Value)
		}
		if Index=0
		{
			return AHKA_Close(TArray . "," . Value)
		}
		else if Index>0
		{
			TArray := AHKA_Open(AHKA_Parse(Array))
			NArray := AHKA_NewArray()
			Loop, Parse, TArray, `,
			{
				if A_Index=%Index%
				{
					NArray := AHKA_AddSimple(NArray,Value,0,0)
				}
				NArray := AHKA_AddSimple(NArray,A_LoopField,0,0)
			}
			return AHKA_Unparse(NArray,Array)
		}
		else if Index<0
		{
			TArray := AHKA_Open(AHKA_Parse(Array))
			NArray := AHKA_NewArray()
			Length := AHKA_Size(Array)
			NIndex := Length + Index + 1
			Loop, Parse, TArray, `,
			{
				if A_Index=%NIndex%
				{
					NArray := AHKA_AddSimple(NArray,Value,0,0)
				}
				NArray := AHKA_AddSimple(NArray,A_LoopField,0,0)
			}
			return AHKA_Unparse(NArray,Array)
		}
	}
	AHKA_Get(Array,Index1=0,Index2="",Index3="",Index4="",Index5="",Index6="",Index7="",Index8="",Index9="",Index10="")
	{
		Index := 1
		Loop
		{
			if (Index%Index% = "")
				break
			Array := AHKA_GetSimple(Array, Index%Index%)
			Index ++
		}
		return Array
	}
	AHKA_GetSimple(Array,Index=0)
	{
		TArray := AHKA_Open(AHKA_Parse(Array))
		Inners := 0
		if Index=0
		{
			Length := AHKA_Size(Array)
			Loop,Parse,TArray,`,
			{
				if A_LoopField=|
					Inners++
				if A_Index=%Length%
				{
					if A_LoopField=|
						return AHKA_GetDimension(Array,Inners)
					else
						return AHKA_Hex(A_LoopField,0)
				}
			}
		}
		else if Index>0
		{
			Loop,Parse,TArray,`,
			{
				if A_LoopField=|
					Inners++
				if A_Index=%Index%
				{
					if A_LoopField=|
						return AHKA_GetDimension(Array,Inners)
					else
						return AHKA_Hex(A_LoopField,0)
				}
			}
		}
		else if Index<0
		{
			Length := AHKA_Size(Array)
			NIndex := Length+Index
			Loop,Parse,TArray,`,
			{
				if A_LoopField=|
					Inners++
				if A_Index=%NIndex%
				{
					if A_LoopField=|
						return AHKA_GetDimension(Array,Inners)
					else
						return AHKA_Hex(A_LoopField,0)
				}
			}
		}
	}
	AHKA_Remove(Array,Index1=0,Index2="",Index3="",Index4="",Index5="",Index6="",Index7="",Index8="",Index9="",Index10="")
	{
		IArray0 := Array
		Loop
		{
			cIndex := A_Index
			lIndex := A_Index - 1
			if (Index%cIndex% && AHKA_IsArray(AHKA_GetSimple(IArray%lIndex%, Index%cIndex%)))
			{
				IArray%cIndex% := AHKA_GetSimple(IArray%lIndex%, Index%cIndex%)
			}
			else
			{
				IArray%lIndex% := AHKA_RemoveSimple(IArray%lIndex%, Index%cIndex%)
				cIndex --
				Loop, %cIndex%
				{
					nIndex := cIndex - A_Index
					lIndex := nIndex + 1
					IArray%nIndex% := AHKA_SetSimple(IArray%nIndex%, IArray%lIndex%, Index%lIndex%)
				}
				return IArray0
			}
		}
	}
	AHKA_RemoveSimple(Array,Index=0)
	{
		NArray := AHKA_Parse(Array)
		skip := ""
		if Index=0
			skip := AHKA_Size(Array)
		else if Index>0
			skip := Index
		else if Index<0
			skip := Index + AHKA_Size(Array)
		return AHKA_Unparse(NArray,Array,skip)
	}
	AHKA_Set(Array,Value,Index1=0,Index2="",Index3="",Index4="",Index5="",Index6="",Index7="",Index8="",Index9="",Index10="")
	{
		IArray0 := Array
		num := 0
		done := 0
		Loop
		{
			IArrayL := IArray%num%
			if done!=1
			{
				nnum := num + 1
				if Index%nnum%!=
				{
					if AHKA_IsArray(IArray%num%)
					{
						IArray%nnum% := AHKA_Get(IArray%num%, Index%nnum%)
						num := nnum
					}
					else
					{
						IArray%num% := Value
						done := 1
					}
				}
				else
				{
					IArray%num% := Value
					done := 1
				}
			}
			else
			{
				num := num - 1
				nnum := num + 1
				IArray%num% := AHKA_SetSimple(IArray%num%, IArray%nnum%, Index%nnum%)
				if num=0
					return IArray%num%
			}
		}
	}
	AHKA_SetSimple(Array,Value,Index=0)
	{
		NArray := AHKA_NewArray()
		TArray := AHKA_Open(AHKA_Parse(Array))
		SkipArray := 0
		if Index=0
		{
			Length := AHKA_Size(Array)
			Loop,Parse,TArray,`,
			{
				if not A_Index=Length
					NArray := AHKA_AddSimple(NArray,A_LoopField,0,0)
				else
					NArray := AHKA_AddSimple(NArray,Value)
			}
		}
		else if Index>0
		{
			Loop,Parse,TArray,`,
			{
				if not A_Index=Index
					NArray := AHKA_AddSimple(NArray,A_LoopField,0,0)
				else
					NArray := AHKA_AddSimple(NArray,Value)
			}
		}
		else if Index<0
		{
			Length := AHKA_Size(Array)
			NIndex := Length+Index
			Loop,Parse,TArray,`,
			{
				if not A_Index=NIndex
					NArray := AHKA_AddSimple(NArray,A_LoopField,0,0)
				else
					NArray := AHKA_AddSimple(NArray,Value)
			}
		}
		return AHKA_Unparse(NArray,AHKA_RemoveSimple(Array,Index))
	}
	AHKA_Split(String,Char="",CaseSensitive=false)
	{
		StartingPos := "1"
		Array := AHKA_NewArray()
		CharLength := StrLen(Char)
		SplitStart := StartingPos - CharLength
		Loop
		{
			OldStart := SplitStart
			Search := OldStart+CharLength
			if Search < 1
				Search = 1
			SplitStart := InStr(String, Char, CaseSensitive, Search)
			if SplitStart = 0
			{
				Array := AHKA_AddSimple(Array,SubStr(String, OldStart+CharLength))
				break
			}
			SplitString := SubStr(String, OldStart+CharLength, SplitStart-(OldStart+CharLength))
			Array := AHKA_AddSimple(Array,SplitString)
		}
		return Array
	}
	AHKA_Convert(Var)
	{
		global
		local Length := %Var%
		if Length =
			local Length := %Var%0
		local Array := AHKA_NewArray()
		Loop, %Length%
		{
			local TempVar := %Var%%A_Index%
			local Array  := AHKA_AddSimple(Array,TempVar)
		}
		return Array
	}
	AHKA_Sort(Array, First=1, Last=-1)
	{
		AHKA_Offset := 1
		if (Last = -1)
			Last := AHKA_Size(Array)
		First -= AHKA_Offset
		Last -= AHKA_Offset
		FHold := First
		LHold := Last
		Pivot := AHKA_Get(Array, First + AHKA_Offset)
		Loop
		{
			if (First >= Last)
				break
			StringArray := AHKA_String(Array)
			Loop
			{
				if (AHKA_Get(Array, Last + AHKA_Offset) < Pivot)
					break
				if (First >= Last)
					break
				Last --
			}
			if (First != Last)
			{
				Array := AHKA_Set(Array, AHKA_Get(Array, Last + AHKA_Offset), First + AHKA_Offset)
				First ++
			}
			Loop
			{
				if (AHKA_Get(Array, First + AHKA_Offset) > Pivot)
					break
				if (First >= Last)
					break
				Left ++
			}
			if (First != Last)
			{
				Array := AHKA_Set(Array, AHKA_Get(Array, First + AHKA_Offset), Last + AHKA_Offset)
				Last --
			}
		}
		Array := AHKA_Set(Array, Pivot, First + AHKA_Offset)
		Pivot := First
		First := FHold
		Last := LHold
		if (First < Pivot)
			Array := AHKA_Sort(Array, First + AHKA_Offset, Pivot - 1 + AHKA_Offset)
		if (Last > Pivot)
			Array := AHKA_Sort(Array, Pivot + 1 + AHKA_Offset, Last + AHKA_Offset)
		return Array
	}
	AHKA_Swap(Array,IndexA=1,IndexB=0)
	{
		TempA := AHKA_Get(Array,IndexA)
		TempB := AHKA_Get(Array,IndexB)
		Array := AHKA_Set(Array,TempA,IndexB)
		Array := AHKA_Set(Array,TempB,IndexA)
		return Array
	}
	AHKA_Move(Array,IndexA=1,IndexB=0)
	{
		Value := AHKA_Get(Array, IndexA)
		Array := AHKA_RemoveSimple(Array, IndexA)
		Array := AHKA_AddSimple(Array, Value, IndexB)
		return Array
	}
	AHKA_Find(Array,Value,Number=1)
	{
		FoundNum := 0
		len := AHKA_Size(Array)
		AbsNumber := AHKA_Abs(number)
		if Number<=0
			AbsNumber++
		Loop
		{
			if A_Index>%len%
				break
			if Number>0
				Temp := AHKA_Get(Array,A_Index)
			if Number<=0
				Temp := AHKA_Get(Array,len-A_Index+1)
			if Temp=%Value%
			{
				FoundNum++
				if FoundNum=%AbsNumber%
				{
					if Number<=0
						return len - A_Index + 1
					return A_Index
				}
			}
		}
		return 0
	}
	AHKA_Minimum(Array)
	{
		SortedArray := AHKA_Sort(Array)
		return AHKA_Get(SortedArray,1)
	}
	AHKA_Maximum(Array)
	{
		SortedArray := AHKA_Sort(Array)
		return AHKA_Get(SortedArray)
	}
	AHKA_Reverse(Array)
	{
		NewArray := AHKA_NewArray()
		len := AHKA_Size(Array)
		Loop, %len%
		{
			NewArray := AHKA_AddSimple(NewArray,AHKA_Get(Array,len-A_Index+1))
		}
		return NewArray
	}
	AHKA_Trim(Array,First=0,Last=0)
	{
		NewArray := AHKA_NewArray()
		len := AHKA_Size(Array)
		Last := len-Last
		Loop, %len%
		{
			if A_Index<=%First%
			{
				;DO NOTHING
			}
			else if A_Index>%Last%
			{
				;DO NOTHING
			}
			else
			{
				NewArray := AHKA_AddSimple(NewArray,AHKA_Get(Array,A_Index))
			}
		}
		return NewArray
	}
	AHKA_Merge(Array1, Array2, Array3="", Array4="", Array5="", Array6="", Array7="", Array8="", Array9="", Array10="")
	{
		NewArray := AHKA_MergeSimple(Array1, Array2)
		Counter := 3
		Loop
		{
			if (Array%Counter% = "" || AHKA_IsArray(Array%Counter%) = false)
				break
			NewArray := AHKA_MergeSimple(NewArray, Array%Counter%)
			Counter ++
		}
		return NewArray
	}
	AHKA_MergeSimple(Array1,Array2)
	{
		if (AHKA_Size(Array1) = 0)
			return Array2
		if (AHKA_Size(Array2) = 0)
			return Array1
		return AHKA_Close(AHKA_Open(Array1) . "," . AHKA_Open(Array2))
	}
	AHKA_String(Array, Delimeter="")
	{
		Output := ""
		Length := AHKA_Size(Array)
		Loop, %Length%
		{
			if (A_Index > 1)
				Output := Output . Delimeter
			Output := Output . AHKA_Get(Array,A_Index)
		}
		return Output
	}