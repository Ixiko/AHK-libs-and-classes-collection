#Include, %A_LineFile%/../../ExceptionsPlus.ahk


class ExampleException extends ExceptionsPlus{


	static description := "This exception is an example how to implement your own derivertiv classes of ExceptionsPlus for your own error handling"


	__New(depth, additionalInfo := ""){
		base.__New(Abs(depth) + 1, additionalInfo)
	}


}