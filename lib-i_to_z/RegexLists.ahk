; Written by AHK_User 2019-09-26
; Updated by AHK_User 2019-10-11
; Added Header parameter, if Header is "0", the parameter [parameter] will be interpreted as the number of the column you want to use in the filter
; Added List_DifferentValues(List1, List2)

/*
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.


List1 =
(
Fruit,Price, Number
Apple,10,15
Banana,10,1
Kiwi,20,9
Pineapple,20,10
Avocado,30,20
Blackberry,10,10
Blueberry,40,10
Cherry,50,10
Cucumber,10,10
Guava,15,10
)

List2 =
(
Fruit,Price,Number
Apple,10,15
Pineapple,20,20
Mango, 30,10
Avocado,30,10
Blackberry,10 ,30
Cherry,50,10
Guava, 15, 15
Honeyberry,20,10
Lemon,10,20
Melon,20,10
)

MsgBox,  % "DifferentValues:`n" List_DifferentValues(List1, List2)
MsgBox,  % "List_Filter:`n" List_Filter(List1, "erry,")
MsgBox,  % "List_FilterByParameter:`n" List_FilterByParameter(List1, "Price", "10")
MsgBox,  % "List_CommonValues:`n" List_CommonValues(List1, List2)
MsgBox,  % "List_CommonValuesByParameter:`n" List_CommonValuesByParameter(List1, List2, "Fruit")
return
*/

List_Filter(List1, SearchString, Type:="InStr", Header:="1"){
	loop, Parse,List1,  `n, `r
	{
		if (A_Index=Header){
			List_Result := A_LoopField
			Continue
		}
		if (Type="InStr"){
			if (InStr(A_LoopField, SearchString)){
				List_Result .= (List_Result="") ? (A_LoopField) : ("`n" A_LoopField)
			}
		}
		else if (Type="!InStr"){
			if (!InStr(A_LoopField, SearchString)){
				List_Result .= (List_Result="") ? (A_LoopField) : ("`n" A_LoopField)
			}
		}
		else if (Type="RegExMatch"){
			if (RegExMatch(A_LoopField, SearchString)){
				List_Result .= (List_Result="") ? (A_LoopField) : ("`n" A_LoopField)
			}
		}
		else if (Type="!RegExMatch"){
			if (!RegExMatch(A_LoopField, SearchString)){
				List_Result .= (List_Result="") ? (A_LoopField) : ("`n" A_LoopField)
			}
		}
		else {
			return false
		}
	}
	return List_Result
}

List_FilterByParameter(List1, Parameter, SearchString, Type:="equal", Delimiter:="`,", OmitChars=" ", Header:="1"){
	if(Header:="0"){
		Parameter_Index := Parameter
	}
	loop, Parse,List1,  `n, `r
	{
		if (A_Index=Header){
			List_Result := A_LoopField
			loop, Parse,A_LoopField,  %Delimiter%, %OmitChars%
			{
				if (A_LoopField=Parameter){
					Parameter_Index :=A_Index
					Continue
				}
			}
		}
		Arr_Value := StrSplit(A_LoopField, Delimiter, OmitChars)
		if (Type="equal"){
			if (Arr_Value[Parameter_Index]=SearchString){
				List_Result .= (List_Result="") ? (A_LoopField) : ("`n" A_LoopField)
			}
		}
		else if (Type="InStr"){
			if (InStr(Arr_Value[Parameter_Index], SearchString)){
				List_Result .= (List_Result="") ? (A_LoopField) : ("`n" A_LoopField)
			}
		}
		else if (Type="!InStr"){
			if (!InStr(Arr_Value[Parameter_Index], SearchString)){
				List_Result .= (List_Result="") ? (A_LoopField) : ("`n" A_LoopField)
			}
		}
		else if (Type="RegExMatch"){
			if (RegExMatch(Arr_Value[Parameter_Index], SearchString)){
				List_Result .= (List_Result="") ? (A_LoopField) : ("`n" A_LoopField)
			}
		}
		else if (Type="!RegExMatch"){
			if (!RegExMatch(Arr_Value[Parameter_Index], SearchString)){
				List_Result .= (List_Result="") ? (A_LoopField) : ("`n" A_LoopField)
			}
		}
		else {
			return false
		}
	}
	return List_Result
}

List_CommonValues(List1, List2, Header:="1"){
	Arr_list1 := {}
	loop, Parse,List1,  `n, `r
	{
		if (A_LoopField=""){
			Continue
		}
		Arr_list1[A_LoopField]:=1
	}
	List_Result :=""
	loop, Parse,List2, `n, `r
	{
		if (A_Index=Header){
			if(Arr_list1[A_LoopField]=1){
				List_Result .= A_LoopField
			}
			Continue
		}
		if(Arr_list1[A_LoopField]=1){
			List_Result .= (List_Result="") ? (A_LoopField) : ("`n" A_LoopField)
		}
	}
	return List_Result
}

List_CommonValuesByParameter(List1, List2, Parameter, Delimiter:="`,", OmitChars=" ", Header:="1"){
	Arr_list1 := {}
	Arr_list2 := {}
	if(Header:="0"){
		Parameter_Index := Parameter
	}
	loop, Parse,List1,  `n, `r
	{
		if (A_Index=Header){
			loop, Parse,A_LoopField, %Delimiter%, %OmitChars%
			{
				if (A_LoopField=Parameter){
					Parameter_Index :=A_Index
					List_Result := Parameter
					Continue
				}
			}
			Continue
		}
		Arr_Value := StrSplit(A_LoopField, Delimiter, OmitChars=" ")
		if (Arr_Value[Parameter_Index]=""){
			Continue
		}
		Arr_list1[Arr_Value[Parameter_Index]]:=1
	}
	loop, Parse,List2,  `n, `r
	{
		if (A_Index=Header){
			loop, Parse,A_LoopField,  %Delimiter% ,
			{
				if (A_LoopField=Parameter){
					Parameter_Index :=A_Index
					Continue
				}
			}
		}
		Arr_Value2 := StrSplit(A_LoopField, Delimiter)
		if (Arr_Value2[Parameter_Index]=""){
			Continue
		}
		if(Arr_list1[Arr_Value2[Parameter_Index]]=1){
			List_Result .= "`n" Arr_Value2[Parameter_Index]
		}
	}
	return List_Result
}

List_DifferentValues(List1, List2, Header:="1"){
	Arr_list1 := {}
	loop, Parse,List1,  `n, `r
	{
		if (A_LoopField=""){
			Continue
		}
		Arr_list1[A_LoopField]:=1
	}

	Arr_list2 := {}
	loop, Parse,List2,  `n, `r
	{
		if (A_LoopField=""){
			Continue
		}
		Arr_list2[A_LoopField]:=1
	}
	List_Result :=""

	loop, Parse,List2,  `n, `r
	{
		if (A_Index=Header){
			List_Result .= A_LoopField
			Continue
		}
		if(Arr_list1[A_LoopField]!=1){
			List_Result .= (List_Result="") ? (A_LoopField) : ("`n" A_LoopField)
		}
	}

	loop, Parse,List1,  `n, `r
	{
		if (A_Index=Header){
			Continue
		}
		if(Arr_list2[A_LoopField]!=1){
			List_Result .= (List_Result="") ? (A_LoopField) : ("`n" A_LoopField)
		}
	}
	return List_Result
}