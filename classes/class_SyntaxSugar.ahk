
; ========== Customizing Object() and Array() ==========
; https://autohotkey.com/board/topic/83081-ahk-l-customizing-object-and-array/
;
; Caveats:
;     It may stop working in a future version (but not until a better alternative is provided).
;     It doesn't apply to "parameter arrays" created by calling a variadic function.
;     Additional lines will show in ListLines each time you create an object if ListLines is enabled.
;     User-defined classes will not automatically inherit behaviour defined by Object(). However, they can explicitly inherit behaviour via the extends keyword.

#Include, <ObjectToString>

Class _SyntaxSugar {
	IsSilent := []
	AlwaysSilent := False
	GenerateStack( offset := -1 ) { ;returns the stack as an Array of exception objects - the first array is the function most recently called.  https://www.autohotkey.com/boards/viewtopic.php?t=48740
		if ( A_IsCompiled )
			Return exception( "Cannot access stack with the exception function, because script is compiled." )
		stack := []
		While ( exData := exception("", -(A_Index-offset)) ).what != -(A_Index-offset)
			stack.push( exData )
		return stack
	}
	ErrorCallstack(ExceptionObject) {
		; Msgbox % "(ExceptionObject:)`n" ObjectToString(ExceptionObject)
		If IsObject(ExceptionObject)
		    Return ExceptionObject.Message .= "`n`nCallstack:`n`n" _SyntaxSugar.StringifyCallstack(8)
		Else Return ExceptionObject .= "`n`nCallstack:`n`n" _SyntaxSugar.StringifyCallstack(8)
	}
	StringifyCallstack(Limit := 1) {
	    Stack := _SyntaxSugar.GetCallstack(Limit)
	    ; Stack.RemoveAt(1), Stack.RemoveAt(1)
	    String := ""
	    
	    for k, v in Stack {
	        String .= v.File ", line " v.Line ": " v.Func "`n`n"
	    }
	    
	    return String
	}

	GetCallstack(Limit := -1) {
	    Stack := []
	        
	    loop {
	        E := Exception("", -A_Index)
	        Stack.Push({"File": E.File, "Line": E.line, "Func": E.What})
	    } until ((A_Index - 1 == Limit) || ((-A_Index . "") = E.What))
	    
	    Stack.Pop()
	    Stack.RemoveAt(1)
	    
	    return stack
	}

	Silent(ByRef Input, Active=True) {
		; Msgbox % "(P:)`n" ObjectToString(P)
		If Active  in off,disable,disabled
			Active := False
		Else if Active in on,enable,enabled
			Active := True
		Else Active := True
		For Key, Value in _SyntaxSugar.GenerateStack()
		{
			If Instr(Value.File, A_ScriptFullPath)
			{
				LastSyntaxSugarCall := Value
				Break
			}
		}
		If not _SyntaxSugar.IsSilent[LastSyntaxSugarCall.File]
			_SyntaxSugar.IsSilent[LastSyntaxSugarCall.File] := {}
		_SyntaxSugar.IsSilent[LastSyntaxSugarCall.File][LastSyntaxSugarCall.Line] := Active			
		; Msgbox % "Active: " Active "`n`nInput: " ObjectToString(Input) "`n(_SyntaxSugar.IsSilent:)`n" ObjectToString(_SyntaxSugar.IsSilent)
		Return Input
	}
	IsBuiltInMethod(Method) {
		If Method in InsertAt,RemoveAt,Push,Pop,Delete,MinIndex,MaxIndex,Length,Count,SetCapacity,GetCapacity,GetAddress,_NewEnum,HasKey,Clone
			Return True
		Else return False
	}
	LineText(File, LineNumber) {
		If FileExist(File)
		{
			FileReadLine, LineText, % File, % LineNumber
			LineText := RegExReplace(LineText, "\s+;.*|^\s+(?!;)|\s+$")
			Loop
			{
				LineNumber += 1
				FileReadLine, ExtraLineText, % File, % LineNumber
				If (ExtraLineText ~= "^\s*/\*|^\s*\(")
				{
					LineText .= " (Line continues...)"
					Break
				}
				ExtraLineText := RegExReplace(ExtraLineText, "^\s+(?!;)|\s+;.*|\s+$")							
				If (ExtraLineText ~= "^(\+\+|--|\*\*|-|!|~|&|\*|\*|/|//|\+|-|<<|>>|&|\^|\||\.|~=|>|<|>=|<=|=|==|<>|!=|and\b|or\b|not\b|&&|\|\||\?|:|:=|\+=|-=|\*=|/=|//=|\.=|\|=|&=|\^=|>>=|<<=|,)")
					LineText .= "`n" ExtraLineText
				Else if not (ExtraLineText ~= "^\s*$")
					Break
			}
		}
		If (LineText != "")
			Return LineText
		Else Return "(Could not get line text.)"
	}

	class ObjectOrArray {
		__Get(ByRef Method, ByRef P*) {

			; If (not This.__Class == "_SyntaxSugar"
			;     and not This.__Class == "_SyntaxSugar.ObjectOrArray"
			;     and not This.__Class == "_SyntaxSugar.ObjectOrArray.Object"
			;     and not This.__Class == "_SyntaxSugar.ObjectOrArray.Array")
			; {
			If _SyntaxSugar.IsBuiltInMethod(Method)
				Return This[Method](P*)
			Else
			{
				If Method in ToString,Msgbox ; The down-side of adding more methods here is that they could be called when an actual property of an object was intended and the property is not defined (yet). So we add only methods here that seem unlikely to be used as normal properties.
					Return This[Method](P*)
				Else if Method in Length
					Return This.Length()

				Else if Method in Silent
				{
					Return _SyntaxSugar.Silent(This, P*)
				}			
				Else if IsObject(This)
					and ObjGetBase(This).HasKey("__Class")
					and Instr(This.__Class, ".RegExMatchObject")
					; and not _SyntaxSugar.ObjectOrArray.HasKey(Method)
					; and not _SyntaxSugar.IsBuiltInMethod(Method)
					; and (NumGet(&{}) == NumGet(&This))  ; Test if this is a normal Autohotkey object.
				{				
					; MsgBox, % "_SyntaxSugar.ObjectOrArray __Get`nMethod: " Method "`nThis.__Class: " This.__Class "`n`n(Stack:)`n" ObjectToString(_SyntaxSugar.GenerateStack()) ;"`n`nP:`n " ObjectToString(P)
					If Instr(This.__Class, ".SingleMatch")
						_SyntaxSugar.StringObject.RegExMatchObject.WarnGroup(This, Method) 
					Else _SyntaxSugar.StringObject.RegExMatchObject.WarnArray(This, Method) 
				}
			}
			; }
		}
		__Call(ByRef Method, ByRef P*) {
			; If (not This.__Class == "_SyntaxSugar"
			;     and not This.__Class == "_SyntaxSugar.ObjectOrArray"
			;     and not This.__Class == "_SyntaxSugar.ObjectOrArray.Object"
			;     and not This.__Class == "_SyntaxSugar.ObjectOrArray.Array")
			; {
				; Msgbox % "(IsObject(This):)`n" ObjectToString(IsObject(This))
				; Msgbox % "(This.HasKey(""__Class""):)`n" ObjectToString(This.HasKey("__Class"))
			If not _SyntaxSugar.IsBuiltInMethod(Method)
			{
				If Method in Silent
				{
					Return _SyntaxSugar.Silent(This, P*)
				}
				Else if IsObject(This)
					and ObjGetBase(This).HasKey("__Class")
					and Instr(This.__Class, ".RegExMatchObject")
					and not _SyntaxSugar.ObjectOrArray.HasKey(Method)
					; and not _SyntaxSugar.IsBuiltInMethod(Method)
					; and (NumGet(&{}) == NumGet(&This))
				{				
					; MsgBox, % "_SyntaxSugar.ObjectOrArray __Call`nMethod: " Method "`nThis: " This.__Class "`n`n(Stack:)`n" ObjectToString(_SyntaxSugar.GenerateStack()) ;"`n`nP:`n " ObjectToString(P)
					If Instr(This.__Class, ".SingleMatch")
						_SyntaxSugar.StringObject.RegExMatchObject.WarnGroup(This, Method) 
					Else _SyntaxSugar.StringObject.RegExMatchObject.WarnArray(This, Method) 
				}
			}
			; }
		}
		Add(ByRef P*) {  ; Adds a number of variables as properties to an object. Supply the names of the variables, either in a comma-separated string or in an array of names. The name of each variable will become the name of a property (a key of the object); the value of each variable will become the value of the new property. If the properties already exist, they will be overwritten.
		
		; WORKS ONLY WHEN THE INPUT VARIABLES ARE GLOBAL
			If not P.2 and not P.MaxIndex() > 1
			{
				If IsObject(P.1)
					P := P.1
				Else P := StrSplit(P.1, ",")
			}
			For Key, Value in P
			{
				If not Value ~= "^[\w#@$]+$"
					Throw "`nInvalid variable name used in .Add(...) method: [" Value "]"
				This[Value] := %Value%
			}
			Return This
		}
		; String() {  ; Disabling any 'String' methods or properties, because it is inconsistent (we don't want it as a property on objects), and it might be confusing and lead to bad habits.
		; 	; Msgbox % "Array: " ObjectToString(This)
		; 	Return ObjectToString(This)
		; }
		ToString() {
			; Msgbox % "Array: " ObjectToString(This)
			Return ObjectToString(This)
		}
		;print,show,msgbox,alert
		Msgbox() {
			Msgbox % "(Msgbox:)`n" ObjectToString(This)
			Return This
		}
		Join(Separator="", AddKeys=False, Initialiser="") {
			For Key, Value in This
			{
				Index += 1
				String .= (Index > 1 ? Separator : "") (AddKeys ? Key Initialiser : "") Value
			}
			Return String
		}

		; Define the base class.
		class Array extends _SyntaxSugar.ObjectOrArray {
		}

		; Define the base class.
		class Object extends _SyntaxSugar.ObjectOrArray {			
		}
	}


	class StringObject {

		__Get(ByRef Method, ByRef P*) {
			; MsgBox, % "_SyntaxSugar.StringObject __Get`nMethod: " Method "`nThis: " ObjectToString(This) "`n`nP:`n " ObjectToString(P) 
			Return This[Method](P*)
		}
		__Call(ByRef Method, ByRef P*) {
			; If not (Method = "Match")
				; MsgBox, % "_SyntaxSugar.StringObject __Call`nMethod: " Method "`nThis: " ObjectToString(This) "`n`nP:`n " ObjectToString(P)
			String := This
			Name := Method
			If Name in length,len,ln  ; Methods such as this one are defined in __Call(), because otherwise there'd need to be several methods (Length, Len, Ln) defined separately in StringObject.
				Name := "StrLen"
			Else if Name in tostring,objecttostring,flatten,explode  ; We are not enabling any methods or properties named 'String', because that would be inconsistent (we don't want 'String' as a property of objects), and it might be confusing and lead to bad habits.
			{
				Name := "ObjectToString"
			}

			If Name in split,stringsplit  ; This one needs to be recreated because StrSplit() otherwise returns a standard array, bypassing Array() and thus all syntax sugar.
			{
				Array := StrSplit(String, P*)
				Output := []
				For Key, Value in Array
				{
					Output[Key] := Value
				}
				Return Output
			}

			Else if Name in match,regexmatch  
			{
				Return New _SyntaxSugar.StringObject.RegExMatchObject(String, P*)
			}
			Else if Name in replace,regexreplace  ; Leave out out the parameter "OutputVarCount" (it cannot be used here)
			{
				; OutputVarCount is normally the parameter after Replacement (so the fourth parameter to the function), but it is skipped here (cannot be used in the method).
				Return _SyntaxSugar.StringObject.Replace(String, P*)
			}
			Else if Name in in,inlist
			{
				List := P.1
				If String in %List%
					Result := True
				Return Result
			}
			Else if Name in contains
			{
				List := P.1
				If String contains %List%
					Result := True
				Return Result
			}
			Else if Name in is,istype
			{
				Type := P.1
				If Name is %Type%
					Return True
				Else Return 
			}
			Else if Name in print,show,msgbox,alert
			{
				Msgbox % "(Msgbox:)`n" This  ;"`n" ObjectToString(_SyntaxSugar.GenerateStack()) 
				Return String
			}
			Else if Name in silent
			{
				Return _SyntaxSugar.Silent(String, P*)
			}
			; Else if Name is digit  ; This would make it harder to spot errors when trying to access subpatterns of a non-object Regex match, so disable it for now.
			; {
			; 	If (Name != 0 and Name <= StrLen(String))
			; 		Return SubStr(This, Name, 1)
			; }
			Else 
			{
				; Msgbox % "String method: " Name "`nString: " String
				If not IsFunc(Name)
					Name := "Str" Name
				If IsFunc(Name)
				{
					Function := Func(Name)
					NumberOfParams := P.MaxIndex() ? P.MaxIndex() : 0
					If (not Function.IsVariadic and 1 + NumberOfParams > Function.MaxParams) or (1 + NumberOfParams < Function.MinParams)
					{
						Message := "Passed " NumberOfParams " parameters to method ." Method ", which only accepts between " Function.MinParams - 1 " and " Function.MaxParams - 1 " parameters.`n`nThe function " Name "( ) is indirectly called with the string as its first (implicit) parameter, so " Name "( ) is now given " 1 + NumberOfParams " parameters including the string; but it only acccepts between " Function.MinParams " and " Function.MaxParams " parameters.`n`nMethod parameters:`n" ObjectToString(P)
				           
						For Key, Value in _SyntaxSugar.GenerateStack()
						{
							If Instr(Value.File, A_ScriptFullPath)
							{
								LastSyntaxSugarCall := Value
								Break
							}
						}
						If not _SyntaxSugar.AlwaysSilent
							and (not _SyntaxSugar.IsSilent[LastSyntaxSugarCall.File]
							or not _SyntaxSugar.IsSilent[LastSyntaxSugarCall.File][LastSyntaxSugarCall.Line])
						{
							Msgbox % "Error in line " LastSyntaxSugarCall.Line ", file [" LastSyntaxSugarCall.File "]:`n`n" Message
							ErrorLevel := LastSyntaxSugarCall.Line "`n" LastSyntaxSugarCall.Message
							_SyntaxSugar.Silent(This)
						}
					}
					Return Function.Call(String, P*)
				}
				Else
				{

					; Msgbox % "(_SyntaxSugar.GenerateStack():)`n" ObjectToString(_SyntaxSugar.GenerateStack())

					For Key, Value in _SyntaxSugar.GenerateStack()
					{
						If Instr(Value.File, A_ScriptFullPath)
						{
							LastSyntaxSugarCall := Value
							Break
						}
					}
					LineText := _SyntaxSugar.LineText(LastSyntaxSugarCall.File, LastSyntaxSugarCall.Line)					
					If (String = "")
						Message := "Tried to call non-existent method or property [" Method "] on empty variable."
					Else Message := "Tried to call non-existent method or property [" Method "] on non-object """ String """."
					Message := "Error in line " LastSyntaxSugarCall.Line ":`n[" Trim(LineText) "]`nFile: [" LastSyntaxSugarCall.File "]:`n`n" Message
					 ; Msgbox % "(_SyntaxSugar.IsSilent:)`n" ObjectToString(_SyntaxSugar.IsSilent) "`n`nLastSyntaxSugarCall.File: " LastSyntaxSugarCall.File " = " LastSyntaxSugarCall.Line
					
					If not _SyntaxSugar.AlwaysSilent
						and (not _SyntaxSugar.IsSilent[LastSyntaxSugarCall.File]
						or not _SyntaxSugar.IsSilent[LastSyntaxSugarCall.File][LastSyntaxSugarCall.Line])
					{
						; Msgbox % "(_SyntaxSugar.IsSilent:)`n" ObjectToString(_SyntaxSugar.IsSilent)
						Msgbox % Message "`n`nCallstack:`n" _SyntaxSugar.StringifyCallstack(8)
						ErrorLevel := LastSyntaxSugarCall.Line "`n" LastSyntaxSugarCall.Message
						_SyntaxSugar.Silent(This)
					}
				}
			}
		}

		Replace(ByRef String, ByRef P*) {
			Regex := P.1
			Replacement := P.2
			Limit := P.3
			PosFound := ""
			For Key, Value in P  ; A loop is required in order to distinguish between an empty starting position (becomes 0) and no starting-position parameter supplied at all (defaults to 1)
				If (A_Index = 4)
				{
					PosFound := True
					StartingPos := Value
					Break
				}
			If not PosFound
				StartingPos := 1
			If not Limit and Limit != 0
				Limit := -1  ; -1 replaces all occurrences.
			If IsFunc(Replacement)  ; Replacement function always receives matches as objects.
			{
				; Make sure the Regex has the O and g options:
				RegexParts := StrSplit(Regex, ")", , 2)
				; Msgbox % "(RegexParts:)`n" ObjectToString(RegexParts)
				If RegexParts.Length() > 1
					RegexParts.2 := ")" RegexParts.2
				If not InStr(RegexParts.1, "(") and RegexParts.Length() > 1
				{
					If (RegexParts.1 ~= "^[\w\a\n\r]*$")
					{
						If not InStr(RegexParts.1, "g", True)
							RegexParts.1 := "g" RegexParts.1
						If not InStr(RegexParts.1, "O", True)
							RegexParts.1 := "O" RegexParts.1, NotO := True
					}
					Else _SyntaxSugar.StringObject.RegExMatchObject.WarnError(This, "Error in Regex options: [" RegexParts.1 "]", Regex)
				}
				Else RegexParts.1 := "Og)" RegexParts.1, NotO := True
				Regex := RegexParts.1 RegexParts.2
				; Msgbox % "(Regex:)`n" ObjectToString(Regex)

				Matches := New _SyntaxSugar.StringObject.RegExMatchObject(String, Regex, StartingPos, Limit)
				If Matches
				{
					If (Matches.1.Position > 1)
						Output .= SubStr(String, 1, Matches.1.Position - 1)

					Loop, % Matches.Length()
					{
						; Msgbox % "(NotO:)`n" ObjectToString(NotO)
						Match := NotO ? Matches[A_Index].0 : Matches[A_Index]  ; If the Regex did not originally contain the O option, send the match as a plain string to the replacement function, otherwise as an object.
						Output .= Replacement.Call(Match, Matches, String)

						AfterMatchEnd := Matches[A_Index].Position + Matches[A_Index].Length
						If (A_Index < Matches.Length())
							SubLength := Matches[A_Index+1].Position - AfterMatchEnd
						Else SubLength := StrLen(String) - AfterMatchEnd + 1
						Output .= SubStr(String, AfterMatchEnd, SubLength)
					}
					Return Output
				}
				Else Return String
			}
			Else
			{
				RegexParts := StrSplit(Regex, ")", , 2)
				GlobalSearch := False
				If not InStr(RegexParts.1, "(") and RegexParts.Length() > 1
				{
					If (RegexParts.1 ~= "^[\w\a\n\r]*$")
						RegexParts.1 := StrReplace(RegexParts.1, "g", , GlobalSearch)
					Else _SyntaxSugar.StringObject.RegExMatchObject.WarnError(This, "Error in Regex options: [" RegexParts.1 "]", Regex)
				}
				If GlobalSearch
					Regex := RegexParts.1 ")" RegexParts.2					
				Output := RegExReplace(String, Regex, Replacement, , Limit, StartingPos)  ; .Replace(NeedleRegEx, Replacement = "", Limit = -1, StartingPos = 1)
				If ErrorLevel
					_SyntaxSugar.StringObject.RegExMatchObject.WarnError(This, ErrorLevel, Regex)
					; Msgbox % "(Regex:)`n" String "`n" Regex "`n[" RegExReplace(String, Regex, Replacement, , Limit, StartingPos) "]`n" ErrorLevel
				Return Output
			}

		}

		Class RegExMatchObject extends _SyntaxSugar.ObjectOrArray.Object {
			; RegExMatchObject := True
			__New(ByRef String, ByRef P*) {
				PosFound := False
				For Key, Value in P  ; A loop is required in order to distinguish between an empty starting position (=> 0) and no starting-position parameter supplied at all (defaults to 1)
					If (A_Index = 2)
					{
						PosFound := True
						Pos := Value
						Break
					}
				If not PosFound
					Pos := 1
				Limit := P.3
				; Msgbox % "Limit: " ObjectToString(Limit)
				Regex := P.1
				RegexParts := StrSplit(Regex, ")", , 2)  ; When the delimiter is not found, the entire string is returned, in a single-length array.
				GlobalSearch := False
				If not InStr(RegexParts.1, "(") and RegexParts.HasKey(2) ;.Length() > 1
				{
					If (RegexParts.1 ~= "^[\w\a\n\r]*$")
						RegexParts.1 := StrReplace(RegexParts.1, "g", , GlobalSearch)
					Else _SyntaxSugar.StringObject.RegExMatchObject.WarnError(This, "Error in Regex options: [" RegexParts.1 "]", Regex)
				}
				If GlobalSearch
				{
					/* If flag "g" is used, return an array of all RegEx matches in the given string.
					Each match can be a string or an object, depending on whether the option `O` was used in the Regex needle.
					If an object, length and position can be accessed (as with any Autohotkey RegEx object) by doing, e.g., 'Matches.1.Len' and 'Matches.1.Pos'.
					*/
					Regex := RegexParts.1 ")" RegexParts.2
					Loop
					{
					    If (Limit >= 0 and A_Index > Limit)
					    	Break
					    Pos := RegexMatch(String, Regex, Match, Pos)
	    				If (ErrorLevel and A_Index = 1)
							_SyntaxSugar.StringObject.RegExMatchObject.WarnError(This, ErrorLevel, Regex)
					    If ( Pos and Pos <= StrLen(String)) {
					        If IsObject(Match)
					            Length := StrLen(Match.0)
					        Else
					            Length := StrLen(Match)
					        ; This[A_Index] := New This.Base.SingleMatch(Match)  ; This works as well
					        This[A_Index] := New _SyntaxSugar.StringObject.RegExMatchObject.SingleMatch(Match)
					        
					        ; In case the match has zero length, we need to move the parser forward by 1 character, lest we should be caught in an infinite loop:
					        Pos += Length ? Length : 1
					    }
					    Else Break

					}
					If IsObject(This) and not This.HasKey(1)
						This := ""
					Return This
				}
				Else
				{
					; Msgbox % "Non-global Regex:`n" ObjectToString(Regex)
					RegExMatch(String, Regex, Match, Pos)  ; Haystack, NeedleRegEx [, OutputVar, StartingPosition := 1]
					If ErrorLevel
						_SyntaxSugar.StringObject.RegExMatchObject.WarnError(This, ErrorLevel, Regex)
					Return New _SyntaxSugar.StringObject.RegExMatchObject.SingleMatch(Match)
				}
			}

			WarnGroup(Instance, Group) {
				For Key, Value in _SyntaxSugar.GenerateStack()
				{
					If Instr(Value.File, A_ScriptFullPath)
					{
						LastSyntaxSugarCall := Value
						Break
					}
				}
				If not _SyntaxSugar.AlwaysSilent
					and (not _SyntaxSugar.IsSilent[LastSyntaxSugarCall.File]
					or not _SyntaxSugar.IsSilent[LastSyntaxSugarCall.File][LastSyntaxSugarCall.Line])
				{
					LineText := _SyntaxSugar.LineText(LastSyntaxSugarCall.File, LastSyntaxSugarCall.Line)
					If Group is digit
						Message := "Tried to call non-existent group [" Group "] on Regex match object. Regex contains only " Instance.Count " group(s). `n"
					Else Message := "Tried to call non-existent group [" Group "] on Regex match object. Valid groups:`n" ObjectToString(Instance.HasKey("_Name") ? Instance._Name : "NO NAMED GROUPS") "`n"

					Message := "Error in line " LastSyntaxSugarCall.Line ":`n[" Trim(LineText) "]`n`nFile: [" LastSyntaxSugarCall.File "]:`n`n" Message
					Msgbox % Message "`nCallstack:`n" _SyntaxSugar.StringifyCallstack(8)
					ErrorLevel := LastSyntaxSugarCall.Line "`n" LastSyntaxSugarCall.Message
					_SyntaxSugar.Silent(Instance)
				}
			}
			WarnArray(Instance, Property) {
				; Msgbox % "(WarnArray Property:)`n" ObjectToString(Property)
				; Msgbox % "(WarnArray Instance:)`n" ObjectToString(Instance)
				For Key, Value in _SyntaxSugar.GenerateStack()
				{
					If Instr(Value.File, A_ScriptFullPath)
					{
						LastSyntaxSugarCall := Value
						Break
					}
				}
				If not _SyntaxSugar.AlwaysSilent
					and (not _SyntaxSugar.IsSilent[LastSyntaxSugarCall.File]
					or not _SyntaxSugar.IsSilent[LastSyntaxSugarCall.File][LastSyntaxSugarCall.Line])
				{
					LineText := _SyntaxSugar.LineText(LastSyntaxSugarCall.File, LastSyntaxSugarCall.Line)					
					Message := "Tried to call property or method [" Property "] on array, which only contains a numbered series of " Instance.Length " Regex matches (from global Regex search)."
					Message := "Error in line " LastSyntaxSugarCall.Line ":`n[" Trim(LineText) "]`n`nFile: [" LastSyntaxSugarCall.File "]:`n`n" Message
					Msgbox % Message "`n`nCallstack:`n" _SyntaxSugar.StringifyCallstack(8)
					ErrorLevel := LastSyntaxSugarCall.Line "`n" LastSyntaxSugarCall.Message
					_SyntaxSugar.Silent(Instance)
				}

			}
			WarnError(Instance, Message, Regex) {
				; Msgbox % "(WarnArray Property:)`n" ObjectToString(Property)
				; Msgbox % "(WarnArray Instance:)`n" ObjectToString(Instance)
				For Key, Value in _SyntaxSugar.GenerateStack()
				{
					If Instr(Value.File, A_ScriptFullPath)
					{
						LastSyntaxSugarCall := Value
						Break
					}
				}
				If not _SyntaxSugar.AlwaysSilent
					and (not _SyntaxSugar.IsSilent[LastSyntaxSugarCall.File]
					or not _SyntaxSugar.IsSilent[LastSyntaxSugarCall.File][LastSyntaxSugarCall.Line])
				{
					LineText := _SyntaxSugar.LineText(LastSyntaxSugarCall.File, LastSyntaxSugarCall.Line)					
					Message := "Error in line " LastSyntaxSugarCall.Line ":`n[" Trim(LineText) "]`n`nFile: [" LastSyntaxSugarCall.File "]:`n`nRegex error: " Message "`nRegex: [" Regex "]"
					Msgbox % Message "`n`nCallstack:`n" _SyntaxSugar.StringifyCallstack(8)
					; ErrorLevel := LastSyntaxSugarCall.Line "`n" LastSyntaxSugarCall.Message
					_SyntaxSugar.Silent(Instance)
				}

			}

			Class SingleMatch extends _SyntaxSugar.ObjectOrArray.Object {
				; SingleMatch := True
				__New(ByRef Match) {
				    If IsObject(Match)			    
				    {			        	
						; This := {}
						Loop, % Match.Count + 1  ; Number of subpatterns + 1 for the full match.
						{
							Group := A_Index - 1  ; Start at 0 because that is the full match.
							This[Group]           := Match[Group]
							If Match.Name(Group)
								This     ._Name[Group] := Match.Name(Group)
							This._Position[Group] := Match .Pos(Group)
							This  ._Length[Group] := Match .Len(Group)
						}
						This .Mark := Match.Mark()
						This.Count := Match.Count()
				    }
				    Else Return Match
				}
				__Get(Property, Group="") {
					; Msgbox % "__Get:`n  Instance is object: " IsObject(This) "`n  Property: " property "`n  Group: " Group
					For Key, Value in _SyntaxSugar.GenerateStack()
					{
						If Instr(Value.File, A_ScriptFullPath)
						{
							LastSyntaxSugarCall := Value
							Break
						}
					}
					; Msgbox % "__Get:`n  Instance is object: " IsObject(This) "`n  Property: " property "`n  Group: " Group "`n`n(_SyntaxSugar.GenerateStack():)`n" ObjectToString(_SyntaxSugar.GenerateStack())
					; . "`n  Instance:`n" ObjectToString(This)
					If Property in len
					{
						If Group is digit
							Return This.Length[Group]
						Else if (Group = "")
							Return This._Length
					}
					Else if Property in pos
					{
						If Group is digit
							Return This.Position[Group]
						Else if (Group = "")
							Return This._Position
					}
					Else if Property in silent
					{
						Return _SyntaxSugar.Silent(This, Group)
					}
					Else if not _SyntaxSugar.IsBuiltInMethod(Property)
					{
						Index := ObjGetBase(This)._GroupNameToNumber(This, Property)
						; Msgbox % "Property: " Property "`nIndex: " Index "`nGroup: " Group
						If (Group = "" and Index)
							Return This[Index]
						Else if Index
						{
							; Return This.Call(P.1, Index)
							Value := This[Group][Index]
							; Msgbox % "(Value:)`n" ObjectToString(Value)
							If (Value != "")
								Return Value
						}
					}
					; Msgbox End of __Get

				}
				__Call(Method, P*) {
					; Msgbox % "__Call: " Method "`nP.1: " P.1 "`nThis is object: " IsObject(This)
					If Method in len
						Return This.Length[P.1]
					Else if Method in pos
						Return This.Position[P.1]
					Else if Method in val,value
					{
						; Msgbox % "Value: " P.1
						If (P.1 != "")
							Return This[P.1]
						Else
							Return This.0
					}
					Else if Method in silent
					{
						Return _SyntaxSugar.Silent(This, P*)
					}
					Else if not _SyntaxSugar.IsBuiltInMethod(Method)
					{
						Index := ObjGetBase(This)._GroupNameToNumber(This, Method)
						; Msgbox % "__Call Method: " Method "`nIndex: " Index "`nP.1: " P.1
						If (P.1 = "" and Index)
							Return This[Index]
						Else if Index
						{
							; Return This.Call(P.1, Index)
							Value := This[P.1][Index]
							; Msgbox % "(Value:)`n" ObjectToString(Value)
							If (Value != "")
								Return Value
						}

					}
					; Msgbox End of __Call
				}
				_GroupNameToNumber(Instance, GroupName) {
					; Msgbox % "_GroupNameToNumber:`n- GroupName: "  GroupName "`n- Instance.Count: " Instance.Count
					If (GroupName = "") or not IsObject(Instance)
					{
						; MsgBox, % "Instance is no object: " Instance
						Return
					}
					Loop % Instance.Count
					{					
						; Msgbox % "_GroupNameToNumber: __Call`n" Instance._Name[A_Index]
					    ; Msgbox % "(Instance.HasKey(""_Name""):)`n" (Instance.HasKey("_Name"))
						; . "`n`n" "(Instance._Name.HasKey(A_Index):)`n" (Instance._Name.HasKey(A_Index))
						; . "`n`n" "(GroupName = Instance._Name[A_Index]:)`n" (GroupName = Instance._Name[A_Index])
						If ( Instance.HasKey("_Name")
						    and Instance._Name.HasKey(A_Index)
							and GroupName = Instance._Name[A_Index])
						{
							; Msgbox % "GroupName found: " GroupName
							Return A_Index
						}
					}
				}

				Position[Group=""] {
					Get {
						; Msgbox % "Group: " Group
						; Msgbox % "(This._Position:)`n" ObjectToString(This._Position) "`n`nGroup: " Group
						If (Group = "")
							Return This._Position[0]
						Else if This._Position[Group]
							Return This._Position[Group]
						Else
						{						 
							Index := ObjGetBase(This)._GroupNameToNumber(This, Group)
							If Index
								Return This._Position[Index]
							Else _SyntaxSugar.StringObject.RegExMatchObject.WarnGroup(This, Group)	

						}
					}
				}

				Length[Group=""] {
					Get {
						; Msgbox % "Length[]:`n  Instance is object: " IsObject(This) "`n  Group: " Group
						; . "`n  Instance:`n" ObjectToString(This)
						If (Group = "")
							Return This._Length[0]
						Else if This._Length[Group]
							Return This._Length[Group]
						Else
						{						 
							Index := ObjGetBase(This)._GroupNameToNumber(This, Group)
							If Index
								Return This._Length[Index]
							Else _SyntaxSugar.StringObject.RegExMatchObject.WarnGroup(This, Group)
						}

					}
				}

			}
		}

	}

}


; Redefine Array().
Array(ByRef prm*) {
    ; Since prm is already an array of the parameters, just give it a
    ; new base object and return it. Using this method, Array.__New()
    ; is not called and any instance variables are not initialized.
    prm.base := _SyntaxSugar.ObjectOrArray.Array
    return prm
}
; Redefine Object().
Object(ByRef prm*) {
    ; Create a new object derived from Object.
    obj := new _SyntaxSugar.ObjectOrArray.Object
    ; For each pair of parameters, store a key-value pair.
    Loop % prm.MaxIndex()//2
        obj[prm[A_Index*2-1]] := prm[A_Index*2]
    ; Return the new object.
    return obj
}


OnError(ObjBindMethod(_SyntaxSugar, "ErrorCallstack"), -1)

"".Base.Base := _SyntaxSugar.StringObject
; "".Base.__Get := "".Base.__Call := Func("_StringMethods")
; "".Base.__Call := Func("_StringMethods")

; 1.Base.Base.ToString := Func("ObjectToString")  ; Superfluous: "".Base.Base already assigns to the base of all non-objects, including numbers and strings.




/* ; Demonstration:

String = Mr X1 Y2
Regex = Ogi)(?<Name>x|Y).
Match := String.Match(Regex)
Match.Msgbox()

*/