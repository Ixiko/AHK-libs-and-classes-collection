/*
Mode(Delimiter := ", ", Numbers*)
Returns the Mode of the Numbers passed to it.
Parameters:
	- delimiter: (Optional) The delimiter to separate the values, if there are more than 1.
	- numbers*: The numbers of which the mode wil be found.
Requires:
	- Join
	- inList
Examples:
	Mode(,1,2,3,3,3,4,5,6,7,8,9,10) ; returns '3'.
	Mode("|", -1,-2,-3,-3,-4,-4,-5,-10) ; returns'-3|-4
	
	NumberArray := [10,10,10,10,20,30,20] ;Initialize an array.
	Mode(,NumberArray*) ; returns '10'. The asterisk tells to pass the array off as the parameters. 
*/	
Mode(delimiter := ", ", numbers*){
	local matched := [], maxCountNumbers := [], maxCount := 0, allNumbers := Join(", ",numbers*)
	for index, num in numbers
	{
		if (inList(num,matched*)){
			continue
		}
		RegExReplace(allNumbers,"(?<=^|, )" . num . "(,|$)","",count)
		if (count>=maxCount){
			if (count > maxCount){
				maxCount := count
				maxCountNumbers := [num]
			} else {
				maxCount := count
				maxCountNumbers.Insert(num)
			}
			matched.Insert(num)
		}
		count := 0
	}
	return Join(delimiter,maxCountNumbers*)
}

/*
Average(numbers*)
Returns the Average of the numbers passed to it.
Parameters:
	- numbers*: The numbers of which the average wil be found.
Requires:
	- Sum
Examples:
	Average(4,6,12,19,20) ; returns '12.200000'.
	
	NumberArray := [10,10,10,10,20,30,20]
	Average(NumberArray*) ; returns '10'.
*/
Average(numbers*){
  return Sum(numbers*)/numbers.MaxIndex()
}

/*
Sum(Numbers*)
Returns the Sum of the numbers passed to it.
Parameters:
	- Numbers*: The numbers of which the Sum wil be found.
Examples:
	Sum(1,2,3,4,5) ; returns '15'
	
	numberArray := [10,20,30]
	Sum(numberArray); returns '60'
*/
Sum(Args*){
  total := 0
  for index, num in Args
    total += num
  return total
}

/*
foundPos := inList(searchItem, itemList*)
Returns if an item is in a list. The index is returned if found, false if not found.
Parameters:
	- searchItem: The Item to find in the list
	- itemList:   The List to search in.
Examples:
	itemArray := ["Apples", "Oranges", "Grapes"]
	if (foundPos := inList("Grapes", itemArray*)){
		Msgbox Grapes was found in the array! The index is %foundPos% 
	}
	
	if (foundPos := inList("Jon", "Katy", "Sarah", "Jeff")){
		Msgbox This won't appear as foundPos == 0
	}
*/
inList(searchItem, itemList*){
	for key,value in itemList
	{
		if (value == searchItem){
			return key
		}
	}
	return false
}

/*
Median(numbers*)
Returns the median of the numbers.
Parameters:
	- numbers: The numbers whose median is to be found.
Requires:
	- sortArray
Examples:
	Median(1) ; returns '1'
	Median(1,2,3,4,5,6,7,8,9,0) returns '5.500000'
*/
Median(numbers*){
	if (numbers.MaxIndex() == 1)
		return numbers[1]
	numbers := sortArray(numbers)
	return !Mod(numbers.MaxIndex(),2) ? (numbers[firstNum := Floor(numbers.MaxIndex()/2)]+numbers[firstNum+1])/2 : numbers[1+Floor(numbers.MaxIndex()/2)]
}

/*
Join(delimiter := "`n",items*)
Returns the items joined by the delimiter.
Parameters:
	- delimiter: The delimiter to separate the items.
	- items:	 The items to join together.
Examples:
	Join(", ", "Carrot", "Cabbage", "Lettuce") returns 'Carrot, Cabbage, Lettuce'
	
	fruitArray := ["Apples", "Oranges", "Mango", "Grapes"]
	Join("|", fruitArray*) ; Returns 'Apples|Oranges|Mango|Grapes'
*/
Join(delimiter := "`n",params*){
	ret := ""
	for index, param in params
		ret .= (index == 1 ? "" : delimiter) . param
	return ret
}

/*
sortedArray := sortArray(array,options := "")
Sorts an array.
Parameters:
	- Array:	The Array to sort.
	- Options:	The options for the 'sort' command.
Requires:
	- Join
Examples:
	sorted := sortList("Apples", "Oranges","Carrot") ; returns ["Apples", "Carrot", "Oranges"]
	for k,v in sorted
		Msgbox %v%
*/
sortArray(array,options := ""){
	array := Join("<-!-Delimeter-!->",array*)
	sort,array,%options%
	return StrSplit(array,"<-!-Delimeter-!->")
}

/*
hexToDecimal(str)
Converts hexadecimal strings to decimal numbers.
Parameters:
    - str: The hex value to convert to decimal. Optionally can have the 0x prefix. Any characters that do not fit the range 0-9, a-z are removed beforehand.

Examples:
    MsgBox % hexToDecimal("0xfffff") ; 1048575
    ; Notice that the case doesn't matter.
    MsgBox % hexToDecimal("DEADBEEF") ; 3735928559
*/  

hexToDecimal(str){
    local newStr := ""
    static comp := {0:0, 1:1, 2:2, 3:3, 4:4, 5:5, 6:6, 7:7, 8:8, 9:9, "a":10, "b":11, "c":12, "d":13, "e":14, "f":15}
    StringLower, str, str
    str := RegExReplace(str, "^0x|[^a-f0-9]+", "")
    Loop, % StrLen(str)
        newStr .= SubStr(str, (StrLen(str)-A_Index)+1, 1)
    newStr := StrSplit(newStr, "")
    local ret := 0
    for i,char in newStr
        ret += comp[char]*(16**(i-1))
    return ret
}