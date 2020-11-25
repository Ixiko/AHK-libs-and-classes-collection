;#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
;SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
;SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


/**
	* Class: IntShortening
	*	This class should implement a highly modifyable integer shortening into ahk
	* Usage:
	*	Callable - NO
	*	Instantiable - YES
	*	Subclassable - YES
	* Attributes:
	*	accuracy		- integer
	*		number of fractional digits
	*	[1 - x]			- strings
	*		the suffixes for each positiv Floor(Log(num)/3) step till x
	*		every value higher than x will use the the value of x as suffixe
	* Methods:
	*	__New(accuracy, suffixes*)
	*		creates a new instance of the IntShortening class
	*	stdFloor(int)
	*		shortens the given integer using the standard format, floored to the instances accuracy
	*	stdRound(int)
	*		shortens the given integer using the standard format, rounded to the instances accuracy
	*	__Get(vKey)
	*		method to allow overflow protection
	* Shortening Formats:
	*	std		- standard format
	*		e.g. 123456 == 123.5k
*/
class IntShortening {


	/**
		* Method: __New(accuracy, suffixes*)
		*	creates a new IntShortening class object with its own suffixes and accuracy
		* Params:
		*	accuracy		- the number of fractional digits
		*	suffixes		- The strings to be appended for each positiv Floor(Log(num)/3) step
		* Return:
		*	IntShortening		- the newly created class instance of the IntShortening class
		* Throws:
		*	IllegalType		- the handed accuracy is not of type integer
		*		Message	- IllegalType
		*		What	- Line of the calling function
		*		Extra	- the handed value for accuracy
	*/
	__New(accuracy, suffixes*){
		if accuracy is not Integer
			Throw, Exception("Illegal type", -1, accuracy)
		this.accuracy := Abs(accuracy)
		for k, i in suffixes
			this[k] := i
	}


	/**
		* Method: stdFloor(int)
		*	shortens the given integer using the standard format, floored to the instances accuracy
		* Params:
		*	int				- the integer to be shortened
		* Return:
		*	shortened int	- the shortened version of the handed integer
		* Throws:
		*	IllegalType		- the handed integer is not of type integer
		*		Message	- IllegalType
		*		What	- Line of the calling function
		*		Extra	- the handed value for int
	*/
	stdFloor(int){
		if int is not Integer
			Throw, Exception("Illegal type", -1, int)

		if(int < 1000)
			return, Format("{1:d}{2:s}", int, (this.0) ? this.0 : "")

		size := Floor(Floor(Log(int)) / 3)
		While(size > 0){
			Try {
				ending := this[size]
				break
			}
			Catch e {
				size--
			}
		}

		return, Round(Floor(int / (10 ** (size * 3 - this.accuracy))) / (10 ** this.accuracy), this.accuracy) . ending
		
	}


	/**
		* Method: stdRound(int)
		*	shortens the given integer using the standard format, rounded to the instances accuracy
		* Params:
		*	int				- the integer to be shortened
		* Return:
		*	shortened int	- the shortened version of the handed integer
		* Throws:
		*	IllegalType		- the handed accuracy is not of type integer
		*		Message	- IllegalType
		*		What	- Line of the calling function
		*		Extra	- the handed value for accuracy
	*/
	stdRound(int){
		if int is not Integer
			Throw, Exception("Illegal type", -1, int)

		if(int < 1000)
			return, Format("{1:d}{2:s}", int, (this.0) ? this.0 : "")

		size := Floor(Floor(Log(int)) / 3)
		While(size > 0){
			Try {
				ending := this[size]
				break
			}
			Catch e {
				size--
			}
		}

		return, Round(int / (10 ** (size * 3)), this.accuracy) . ending
		
	}


	/**
		* Method: __Get(vKey)
		*	this method handles the retrieval of keys not set before
		*	it plays a crucial part in the overflow protection system
		*	Do not modify this method unless you really know what you're doing
		* Params:
		*	vKey	- the undefined key that should be evaluated
		* Return:
		*	value for prefined keys
		* Throws:
		*	IntKeyNonexistent	- the handed integer key does not exist
		*		Message	- IntKeyNonexistent
		*		What	- Line of the calling function
		*		Extra	- the handed key
	*/
	__Get(vKey){
		if(vKey == "accuracy")
			return, 1
		if vKey is Integer
		{
			if(vKey)
				Throw, Exception("IntKeyNonexistent", -1, vKey)
			else
				return, 0
		} else 
			return, ""
   	}


}