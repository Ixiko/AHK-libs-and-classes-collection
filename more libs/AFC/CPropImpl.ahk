;
; AutoHotkey OOP default __Get/__Set implementation
; Taken from the help file
;

/*!
	Class: CPropImpl
		Property metafunction implementation proxy. Use this class in order to implement
		property getters/setters. This class is taken from the AutoHotkey documentation.
		
	Example:
		> class SomeClass
		> {
		>     class __Get extends CPropImpl
		>     {
		>         SomeProp()
		>         {
		>             return "Something"
		>         }
		>     }
		> }
	@UseShortForm
*/

class CPropImpl
{
	__Call(aTarget, aName, aParams*)
	{
		; If this Properties object contains a definition for this half-property, call it.
		; Take care not to use this.HasKey(aName), since that would recurse into __Call.
		if IsObject(aTarget) && ObjHasKey(this, aName)
			return this[aName].(aTarget, aParams*)
	}
}

/*!
	End of class
*/
