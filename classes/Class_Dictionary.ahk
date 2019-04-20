/*
	Dictionary CLASS

	Link: https://msdn.microsoft.com/en-us/library/x4k5wbx4.
	
	Descripción:
		Un objeto Dictionary es el equivalente de un 'array' asociativo de PERL.
		Los elementos pueden ser cualquier forma de datos y se almacenan en el 'array'.
		Cada elemento está asociado con una clave única.
		La clave se utiliza para recuperar un elemento individual y suele ser un número entero o una cadena, pero puede ser cualquier cosa excepto un 'array'.
		
	Notas:
		Por defecto, Los nombres de las claves distinguen entre mayúsculas y minúsculas, por lo que 'KeyA' no es igual a 'KEYA". Esto se puede cambiar mediante la propiedad 'CompareMode'.
		Las claves conservar el orden en que fueron añadidas.
		Los métodos InsertAt() y RemoveAt() son muy lentos. Considere usar Remove(Key).
*/
Class Dictionary
{
	; ===================================================================================================================
	; INSTANCE VARIABLES
	; ===================================================================================================================
	oDictionary															:= 0
	
	
	; ===================================================================================================================
	; CONSTRUCTOR
	; ===================================================================================================================
	/*
	Parámetros:
		KeyValues: las claves con sus respectivos valores iniciales en el objeto Dictionary.
			Parámetro 1: La clave asociada al elemento que se agrega.
			Parámetro 2: El elemento asociado con la clave a añadir. Se repite el mismo orden en los siguientes parámetros.
	*/
	__New(KeysValues*)
	{
		Try
			this.oDictionary		:= ComObjCreate("Scripting.Dictionary")
		Catch 
			Return (FALSE)
		
		Loop(KeysValues.MaxIndex())
			If (Mod(A_Index, 2) == 0)
				this.oDictionary.Add(Key, KeysValues[A_Index])
			Else
				Key						:= KeysValues[A_Index]
		
		if (Mod(KeysValues.MaxIndex(), 2) == 1)
			this.oDictionary.Add(KeysValues[KeysValues.MaxIndex()], "")
	}
	
	
	; ===================================================================================================================
	; DESTRUCTOR
	; ===================================================================================================================
	__Delete()
	{
		this.oDictionary		:= 0
	}
	
	
	; ===================================================================================================================
	; META-FUNCTIONS
	; ===================================================================================================================
	__Get(KeyName)
	{
		If (KeyName != "Count" && KeyName != "CompareMode" && KeyName != "Keys" && KeyName != "Items")
		{
			If (this.oDictionary.Exists(KeyName))
				Return (this.oDictionary.Item(KeyName))
			
			Else
				Return ("")
		}
	}
	
	__Set(KeyName, Value)
	{
		If (KeyName != "Count" && KeyName != "CompareMode" && KeyName != "Keys" && KeyName != "Items")
		{
			this.oDictionary.Item(KeyName) := Value
		}
	}
	
	
	; ===================================================================================================================
	; PUBLIC METHODS
	; ===================================================================================================================
	/*
	Agrega claves con sus valores al final de este objeto Dictionary.
	Parámetros:
		KeysValues: claves a añadir al objeto con sus respectivos valores.
			Parámetro 1: La clave asociada al elemento que se agrega.
			Parámetro 2: El elemento asociado con la clave a añadir. Se repite el mismo orden en los siguientes parámetros.
	*/
	Push(KeysValues*) {
		Loop(KeysValues.MaxIndex())
			If (Mod(A_Index, 2) == 0)
				this.oDictionary.Add(Key, KeysValues[A_Index])
			Else Key			:= KeysValues[A_Index]
		
		if (Mod(KeysValues.MaxIndex(), 2) == 1)
			this.oDictionary.Add(KeysValues[KeysValues.MaxIndex()], "")
	} ;https://msdn.microsoft.com/en-us/library/5h92h863

	/*
	Elimina la última clave en este objeto Dictionary.
	*/
	Pop() {
		this.RemoveAt(this.Count)
	}
	
	/*
	Añade una clave en la posición espesificada de este objeto Dictionary.
	Parámetros:
		Pos: Posición en la que añadir el elemento.
		KeyName: La clave asociada al elemento que se agrega.
		Value: El elemento asociado con la clave a añadir.
	*/
	InsertAt(Pos, KeyName, Value := "") {
		oDictionary			:= ComObjCreate("Scripting.Dictionary")
		
		For KeyName2 in this.oDictionary.Keys()
		{
			If (A_Index == Pos)
				oDictionary.Add(KeyName, Value)
			oDictionary.Add(KeyName2, this.oDictionary.Item(KeyName2))
		}
		
		this.oDictionary	:= oDictionary
	}
	
	/*
	Elimina una clave en este objeto Dictionary.
	Parámetros:
		KeyName: El nombre de la clave a remover en este objeto Dictionary.
	*/
	Remove(KeyName) {
		this.oDictionary.Remove(KeyName)
	} ;https://msdn.microsoft.com/en-us/library/ywyayk03
	
	/*
	Elimina todas las claves en este objeto Dictionary.
	*/
	RemoveAll()
	{
		this.oDictionary.RemoveAll()
	} ;https://msdn.microsoft.com/en-us/library/45731e2w
	
	/*
	Relimina las claves desde la posición espesificada hasta tantas posiciónes siguientes espesificadas en este objeto Dictionary.
	Parámetros:
		Pos: La posición del primer elemento a eliminar.
		Length: La cantidad de posiciónes a eliminar a partir de Pos. Por defecto es 1, lo que quiere decir que solo elimina el elemento espesificado en Pos.
	*/
	RemoveAt(Pos, Length := 1) {
		PosM		:= Pos + Length
		For KeyName in this.oDictionary.Keys()
		{
			If (A_Index == PosM)
				Break
			
			If (A_Index >= Pos)
				this.oDictionary.Remove(KeyName)
		}
	}
	
	/*
	Establece / Renombra una clave en este objeto Dictionary.
	Parámetros:
		KeyName: El nombre de la clave a renombrar en este objeto Dictionary.
		NewKeyName: El nuevo nombre de la clave en este objeto Dictionary.
	*/
	Rename(KeyName, NewKeyName)
	{
		this.oDictionary.Key(KeyName) := NewKeyName
	}
	
	/*
	Recupera o establece el elemento asociado con la clave espesificada en este objeto Dictionary.
	Parámetros:
		KeyName: El nombre de la clave en este objeto Dictionary.
		NewValue: Opcional. El nuevo elemento asociado con la clave espesificada.
	*/
	Item(KeyName, NewValue*)
	{
		If (NewValue.MaxIndex() == "")
			Return (this.oDictionary.Exists(KeyName) ? this.oDictionary.Item(KeyName) : "")
		
		Else
			this.oDictionary.Item(KeyName) := NewValue[1]
	}
	
	/*
	Comprueba si existe una clave especificada en este objeto Dictionary.
	Parámetros:
		KeyName: El nombre de la clave a comprobar su existencia en este objeto Dictionary.
	Return: 0 = La clave no existe. 1 = La clave existe.
	*/
	HasKey(KeyName) {
		Return (this.oDictionary.Exists(KeyName) ? TRUE : FALSE)
	} ;https://msdn.microsoft.com/en-us/library/57hdf10z
	
	/*
	Devuelve una copia exacta de este objeto Dictionary.
	Return: devuelve un nuevo objeto Dictionary con los mismos elementos que este objeto Dictionary.
	*/
	Clone()
	{
		oCloneDictionary												:= new Dictionary()
		oCloneDictionary.oDictionary.CompareMode		:= this.oDictionary.CompareMode
		
		For KeyName in this.oDictionary.Keys()
			oCloneDictionary.oDictionary.Add(KeyName, this.oDictionary.Item(KeyName))
		
		Return (oCloneDictionary)
	}
	
	
	; ===================================================================================================================
	; PROPERTIES
	; ===================================================================================================================
	/*
	Devuelve el número de claves en el objeto Dictionary.
	*/
	Count[]
	{
		Get
		{
			return this.oDictionary.Count
		}
	} ;https://msdn.microsoft.com/en-us/library/5t9h9579
	
	/*
	Devuelve un 'array' que contiene todas las claves de este objeto Dictionary.
	Modo de uso: For KeyName in oDictionary.Keys.
	*/
	Keys[]
	{
		Get
		{
			Return (this.oDictionary.Keys())
		}
	} ;https://msdn.microsoft.com/en-us/library/8aet97f2
	
	/*
	Devuelve un 'array' que contiene todos los elementos de este objeto Dictionary.
	Modo de uso: For Value in oDictionary.Items.
	*/
	Items[]
	{
		Get
		{
			Return (this.oDictionary.Items())
		}
	} ;https://msdn.microsoft.com/en-us/library/8aet97f2
	
	/*
	Establece y devuelve el modo de comparación para comparar las claves de cadena en este objeto Dictionary.
	CompareMode debe ser uno de los siguientes valores:
		0		= Comparación binaria.
		1		= Comparación de texto.
		2		= Comparación de base de datos.
		N		= Pueden utilizarse valores superiores a 2 para referirse a comparaciones utilizando ID de localización específicos (LCID).
	*/
	CompareMode[]
	{
		Get
		{
			Return (this.oDictionary.CompareMode)
		}
		
		Set
		{
			this.oDictionary.CompareMode := Value
		}
	} ;https://msdn.microsoft.com/en-us/library/a14xez73
}