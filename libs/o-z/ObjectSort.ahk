/* ObjectSort() by bichlepa
*
* Description:
*    Reads content of an object and returns a sorted array
*
* Parameters:
*    obj:              Object which will be sorted
*    keyName:          [optional]
*                      Omit it if you want to sort a array of strings, numbers etc.
*                      If you have an array of objects, specify here the key by which contents the object will be sorted.
*    callBackFunction: [optional] Use it if you want to have custom sort rules.
*                      The function will be called once for each value. It must return a number or string.
*    reverse:          [optional] Pass true if the result array should be reversed
*/
objectSort(obj, keyName="", callbackFunc="", reverse=false) {

	temp := Object()
	sorted := Object() ;Return value

	for oneKey, oneValue in obj
	{
		;Get the value by which it will be sorted
		if keyname
			value := oneValue[keyName]
		else
			value := oneValue

		;If there is a callback function, call it. The value is the key of the temporary list.
		if (callbackFunc)
			tempKey := %callbackFunc%(value)
		else
			tempKey := value

		;Insert the value in the temporary object.
		;It may happen that some values are equal therefore we put the values in an array.
		if not isObject(temp[tempKey])
			temp[tempKey] := []
		temp[tempKey].push(oneValue)
	}

	;Now loop throuth the temporary list. AutoHotkey sorts them for us.
	for oneTempKey, oneValueList in temp
	{
		for oneValueIndex, oneValue in oneValueList
		{
			;And add the values to the result list
			if (reverse)
				sorted.insertAt(1,oneValue)
			else
				sorted.push(oneValue)
		}
	}

	return sorted
}