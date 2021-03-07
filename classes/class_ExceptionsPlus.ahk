#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%


/**
	* Class: ExceptionsPlus
	*	This class is an attempt to implement Java alike Exception Objects
	* Usage:
	*	Callable - NO
	*	Instantiable - YES
	*	Subclassable - YES
	* Attributes:
	*	description		- string
	*	DEBUGLEVEL		- integer
	* Methods:
	*	__New(depth, additionalInfo := "")
	*	printDebug()
	*	toStr()
	*	toLongStr()
	*	toShortStr()
	*	_extraToStr(extra)
*/
class ExceptionsPlus {

	
	/*
		* Attribute: description
		*	A description message to be set by the derived classes
		*	This message is what will be embedded by this.toLongStr()
	*/
	static description := "This class has no description yet"


	/*
		* Attribute: DEBUGLEVEL
		*	Standard debuglevel used by this.printDebug() and other debugging features
		*	value < 0: reduced
		*	value = 0: standard
		*	value >	0: enhanced
	*/
	static DEBUGLEVEL := 0


	/*
		* Method: __New(depth, additionalInfo := "")
		*	constructor method for ExceptionsPlus object
		* Params:
		*	depth			- number of steps to go back in the callstack
		*	additionalInfo	- what additional info you want to return for debugging purpose
		* Return:
		*	ExceptionsPlus		- New object of the class ExceptionsPlus
	*/
	__New(depth, additionalInfo := ""){
		e := Exception("just retrieve a specific point in the callstack", -1 * (Abs(depth) + 1))
		this.What := e.What
		this.Line := e.Line
		this.File := e.File

		this.Message := this.__Class
		this.Extra := additionalInfo
	}


	/*
		* Method: toShortStr()
		*	creates a short string version of the contained error data
		* Returns:
		*	string
	*/
	toShortStr(){
		return, Format("Exception: {1:s} in {2:s}, line {3:s} in {4:s}.", this.Message, this.What, this.Line, this.File)
	}


	/*
		* Method: toStr()
		*	creates a string version of the contained error data, including a stringifyed version of object, handed as extra information
		* Returns:
		*	string
	*/
	toStr(){
		return, Format("{1:s}`nProblem assist object:`n{2:s}", this.toShortStr(), this._extraToStr(this.Extra))
	}

	/*
		* Method: toShortStr()
		*	creates a string version of the contained error data, including a stringifyed version of object, handed as extra information, and the exceptions description
		* Returns:
		*	string
	*/
	toLongStr(){
		return, Format("{1:s}`nDescription: {2:s}`nProblem assist object:`n{3:s}", this.toShortStr(), this.description, this._extraToStr(this.Extra))
	}


	/*
		* Method: printDebug()
		*	prints a debug message according to the objects DEBUGLEVEL
		*	for more information on how this message is send, look of OutputDebug within the AutoHotkey Documentation
	*/
	printDebug(){
		OutputDebug, % (!this.DEBUGLEVEL) ? this.toStr() : (this.DEBUGLEVEL < 0) ? this.toShortStr() : this.toLongStr()
	}


	/*
		* Method: _extraToStr(extra)
		*	helper method to convert the handed object to string
		* Params:
		*	extra	- the object to be converted to string
		* Return
		*	string	- the created string
	*/
	_extraToStr(extra){
		if(!IsObject(extra))
			return, extra
		result := "{"
		for index, element in extra {
			result .= (A_Index < 2) ? "" : "; "
			result .= Format("{1:s}: {2:s}", index, (IsObject(element)) ? this._extraToStr(element) : element)
		}
		return, result . "}"
	}


}