; Function: ITL_AbstractClassConstructor
; This is simply a wrapper for "abstract classes", i.e. an exception is thrown when it is called.
; "Abstract" classes set this as their constructor.
ITL_AbstractClassConstructor(this, p*)
{
	throw Exception(ITL_FormatException("An instance of the class """ this.base.__class """ must not be created."
										, "The class is abstract."
										, 0)*)
}