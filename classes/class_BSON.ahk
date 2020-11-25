class BSONTypes {
	static None := 0x00
	static Double := 0x01
	static String := 0x02
	static Object := 0x03
	static Boolean := 0x08
	static Null := 0x0A
	static Int := 0x10
	static Int64 := 0x12
}

class BSON {
	class Functor {
		; Allows for BSON.Method() alongside BSON.Method.SubMethod()
		
		__Call(Key, Params*) {
			if (Key.__Class = "BSON") {
				return this.Call(Params*)
			}
		}
	}

	class Load extends BSON.Functor {
		FromHexString(String) {
			Bytes := StrSplit(String, " ")
			return this.Call(Bytes)
		}
		FromFile(FilePath) {
			Scanner := FileOpen(FilePath, "r")
		
			Object := this.FromScanner(Scanner)
			
			Scanner.Close()
			
			return Object
		}
		FromScanner(Scanner) {
			return BSON.ParseDocument(Scanner)
		}
	
		Call(ByteArray) {
			
			if !(IsObject(ByteArray)) 
				Throw, Exception("BSON.Load() requires an array of bytes as input.")
		
			ByteCount := ByteArray.Count()
			Scanner := new ManagedScanningBuffer(ByteCount + 1) ; Loads a hex BSON object into memory, and then passes the buffer to the normal Load method
			
			for k, Byte in ByteArray 
				Scanner.WriteChar(Conversions.HexToInt("0x" Byte))
			
			Scanner.SeekStart(0)
			return this.FromScanner(Scanner)
			
		}
	}
	ParseDocument(Scanner) {
		DocumentLength := Scanner.ReadUInt()
		
		DocumentObject := {}
		
		try {
			loop {
				Element := this.ParseElement(Scanner)
				DocumentObject[Element.Key] := Element.Value
			} until (Scanner.Tell() = DocumentLength)
		}
		catch E {
			if (E.Message = "EOF") {
				return DocumentObject
			}
			else {
				Throw, E
			}
		}
		
		return DocumentObject
	}
	ParseElement(Scanner) {
		ElementType := Scanner.ReadChar()
		
		if (ElementType = BSONTypes.None) {
			Throw, Exception("EOF")
		}
	
		Key := this.ParseKeyName(Scanner)
	
		Switch (ElementType) {
			Case BSONTypes.Double: {
				Value := Scanner.ReadDouble()
			}
			Case BSONTypes.String: {
				Value := this.ParseString(Scanner)
			}
			Case BSONTypes.Object: {
				Value := this.ParseDocument(Scanner)
			}
			Case BSONTypes.Boolean: {
				Value := Scanner.ReadChar()
			}
			Case BSONTypes.Null: {
				Value := ""
			}
			Case BSONTypes.Int: {
				Value := Scanner.ReadInt()
			}
			Case BSONTypes.Int64: {
				Value := Scanner.ReadInt64()
			}
			Default: {
				Throw, Exception("Un-supported value-type: " ElementType)
			}
		}
		
		return {"Key": Key, "Value": Value}
	}
	ParseKeyName(Scanner) {
		; Reads a cstring
		String := ""
		
		loop {
			NextCharacter := Scanner.ReadChar()
			
			if (NextCharacter = 0) {
				return String
			}
		
			String .= Chr(NextCharacter)
		}
	}
	ParseString(Scanner) {
		; Reads a string length, then a cstring
		StringLength := Scanner.ReadUInt()
		StringValue := this.ParseKeyName(Scanner)
		
		return StringValue
	}
	
	
	class Dump extends BSON.Functor {
		ToFile(FilePath, Object) {
			F := FileOpen(FilePath, "w")
			
			for k, Byte in this.Call(Object) {
				F.WriteChar(Byte)
			}
			
			F.Close()
			
			return 1
		}
		ToHexString(Object) {
			String := ""
			
			for k, Byte in this.Call(Object) {
				String .= Conversions.IntToHex(Byte) " "
			}
			
			return String
		}
		Call(Object) {
			return BSON.DumpObject(Object)
		}
	}
	DumpObject(Object) {
		ObjectBytes := [] ; An object starts with a uint32 of how big it is, but we can insert that at the end
		
		for Key, Value in Object {
			KeyValueBytes := this.DumpElement(Key, Value) ; then a list of elements
			BSON.Merge(ObjectBytes, KeyValueBytes)
		}
		
		ObjectBytes.Push(0) ; And ends with a null terminator
		
		return BSON.Merge(Conversions.SplitIntoBytes32(ObjectBytes.Count() + 4), ObjectBytes) ; BSON.Merge the elements/null terminator onto the size of the object
	}
	DumpElement(Key, Value) {
		ElementBytes := []
		
		if (IsObject(Key)) {
			Throw, Exception("The BSON format does not support using objects as keys.")
		}
		
		BSON.Merge(ElementBytes, this.DumpString(Key))
		
		if (Conversions.IsFloat(Value)) {
			ElementType := BSONTypes.Double
			BSON.Merge(ElementBytes, Conversions.SplitIntoBytes64(Conversions.FloatToBinaryInt(Value)))
		}
		else if (Value = 0 || Value = 1) {
			ElementType := BSONTypes.Boolean
			BSON.Merge(ElementBytes, [Value]) ; For a boolean, it's just 0x08 NAME (0x00|0x01) so we can just push the value (which is either 0 or 1)
		}
		else if (Value = "") {
			ElementType := BSONTypes.Null ; For the null type, there is no value
		}
		else if (IsObject(Value)) {
			ElementType := BSONTypes.Object
			BSON.Merge(ElementBytes, this.DumpObject(Value))
		}
		else if (Conversions.IsNumber(Value)) {
			ValueLength := Conversions.NumberSizeOf(Value)
			
			if (ValueLength <= 32) {
				ElementType := BSONTypes.Int
				BSON.Merge(ElementBytes, Conversions.SplitIntoBytes32(Value))
			}
			else {
				ElementType := BSONTypes.Int64
				BSON.Merge(ElementBytes, Conversions.SplitIntoBytes64(Value))
			}
		}
		else {
			ElementType := BSONTypes.String
			BSON.Merge(ElementBytes, Conversions.SplitIntoBytes32(StrLen(Value) + 1)) ; When an element is a string, first you have to dump it's length
			BSON.Merge(ElementBytes, this.DumpString(Value))
		}
		
		return BSON.Merge([ElementType], ElementBytes) ; Prepend the element type onto the key/value
	}
	DumpString(String) {
		StringBytes := [] ; A string is just a null-terminated string
		
		for k, Character in StrSplit(String) {
			StringBytes.Push(Asc(Character))
		}
			
		StringBytes.Push(0) ; null terminator
		
		return StringBytes 
	}
	
	Merge(ArrayOne, ArrayTwo) {
		for k, v in ArrayTwo {
			ArrayOne.Push(v)
		}
		
		return ArrayOne
	}
}

#Include <class_ScanningBuffer>
#Include <class_Conversions>