/*
Class: CEnumerator
Generic enumerator object that can be used for dynamically generated array members. It requires that the object defines a MaxIndex() function.
To make an object iterable, make sure to define the MaxIndex() function and insert this function in the class definition:
|_NewEnum()
|{
|	global CEnumerator
|	return new CEnumerator(this)
|}
*/
Class CEnumerator
{
	__New(Object)
	{
		this.Object := Object
	}
	Next(byref key, byref value)
	{
		if(!key)
			key := 1
		else
			key++
		if(key <= this.Object.MaxIndex())
			value := this.Object[key]
		else
			key := ""
		return key > 0
	}
}