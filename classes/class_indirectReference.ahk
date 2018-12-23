	/*
		CLASS indirectReference
		author:			nnnik
		
		description:	A class that is able to create safe indirect references that allow access to an object without creating a reference.
		This allows AutoHotkey to perform deletion of Object once all direct references are freed.
		You can use this to avoid circular references.
		
		usage:				newIndirectReference := new indirectReference( object, modes := { __Set:0, __Get:0, __Delete:0 } )
		
		newIndirectReference:	The indirect reference towards the objects passed to the constructor
		
		object:				The object you want to refer to indirectly
		
		modeOrModeStr:			Controls how the indirectReference is connected to the object directly
							e.g. with a __Call mode all method calls towards the indirectReference will end up calling the same method with the same parameters in the object
*/

class indirectReference
{
	
	static relationStorage    := {}
	static performanceStorage := {}
	static accessStorage      := {}
	static modeStorage        := {}
	static baseModes          := { __Call:indirectReference.Call, __Set:indirectReference.Set, __Get:indirectReference.Get, __New:indirectReference.New, __Delete:indirectReference.Delete, _NewEnum:"" }
	
	__New( obj, modeOrModeStr := "__Call" )
	{
		if !isObject( obj )
			return
		if isObject( modeOrModeStr )
		{
			str := ""
			For modeName, val in modeOrModeStr
				str .= modeName . "|"
			modeOrModeStr := subStr( str, 1, -1 )
		}
		if !indirectReference.performanceStorage.hasKey( &obj )
		{
			indirectReference.performanceStorage[ &obj ] := []
			indirectReference.accessStorage[ &obj ] := []
			obj.base := { __Delete: indirectReference.DeleteObject, base: obj.base }
		}
		if ( !indirectReference.performanceStorage[ &obj ].hasKey( modeOrModeStr ) | deleteMode := inStr( modeOrModeStr, "__Delete" ) )
		{
			if !indirectReference.modeStorage.hasKey( modeOrModeStr )
			{
				newMode := {}
				for each, mode in strSplit( modeOrModeStr, "|" )
				{
					newMode[ mode ] := indirectReference.baseModes[ mode ]
					indirectReference.baseModes[ mode ]
				}
				indirectReference.modeStorage[ modeOrModeStr ] := newMode
			}
			newReference := { base: indirectReference.modeStorage[ modeOrModeStr ] }
			indirectReference.accessStorage[ &obj ].Push( &newReference )
			indirectReference.relationStorage[ &newReference ] := &obj
			if !deleteMode
				indirectReference.performanceStorage[ &obj, modeOrModeStr ] := newReference
			else
				return newReference
		}
		return indirectReference.performanceStorage[ &obj, modeOrModeStr ]
	}
	
	DeleteObject()
	{
		for each, reference in indirectReference.accessStorage[ &This ]
		{
			indirectReference.relationStorage.delete( reference )
			Object( reference ).base := ""
		}
		indirectReference.accessStorage.Delete( &This )
		indirectReference.performanceStorage.Delete( &This )
		if ( isFunc( This.base.base.__Delete ) && This.base.base.__Delete.name != indirectReference.DeleteObject.name )
		{
			This.base := This.base.base
			This.__Delete()
		}
	}
	
	Call( functionName = "", parameters* )
	{
		if !( indirectReference.baseModes.hasKey( functionName ) && !This.base.hasKey( functionName ) )
			return ( new directReference( This ) )[ functionName ]( parameters* )
	}
	
	Set( keyAndValue* )
	{
		Value := keyAndValue.Pop()
		return ( new directReference( This ) )[ keyAndValue* ] := Value 
	}
	
	Get( key* )
	{
		return ( new directReference( This ) )[ key* ]
	}
	
	New( parameters* )
	{
		newIndirectReference := This.base
		This.base := ""
		__class := new directReference( newIndirectReference )
		return new __class( parameters* )
	}
	
	Delete()
	{
		return ( new directReference( This ) ).__Delete()
	}
	
}

/*
	CLASS directReference
	description:			creates direct References from indirect ones.
	
	usage:				object := new directReference( newIndirectReference )
	
	newIndirectReference:	A indirectReference created by calling new indirectReference( object )  
	
	object:				The object that is refered to by the indirectReference
*/

class directReference
{
	__New( reference )
	{
		return Object( indirectReference.relationStorage[ &reference ] )
	}
}