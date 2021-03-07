/**
    * Class: COMDict
    *   A classbased wrapper for working with com based dicts
    *   that mind the case of its keys
    * Attributes:
    *   dict:       the Scripting.Dictionary COM object
    *   Enum:       Class for enumeration within for loops
    * Methods:
    *   __New(keyvalArr := ""):     COMDict
    *       Creates a new instace of the dictionary class
    *   setAnew(keyvalArr):         Void
    *       sets the dict anew from the handed array
    *   invert():                   COMDict
    *       returns a new COMDict instance with inverted key/value pairs
    *   add(key, value):            Void
    *       adds a key value pair but will not update existing on
    *   item(key):                  key reference
    *       returns a specific reference to the given key and its value
    *   __Get(key):                 key reference
    *       convinience wrapper for the this.item(key) method
    *       CAN HAVE UNWANTED SIDEEFFECTS from not being called
    *   remove(key):                Void
    *       removes a specific key from the dictionary
    *   updateKey(key, newKey):     Void
    *       updates a key from the dictionary
    *   exists(key):                Boolean
    *       checks whether given key exists within the dict
    *   HasKey(key):                Boolean
    *       convinience wrapper for the this.exists(key) method
    *   count():                    Integer
    *       retrieves the number of key/value pairs within the dict
    *   items():                    Array
    *       retrieves all values present within the dictionary
    *   keys()
    *       retrieves all keys present within the dictionary
    *   items()
    *       removes all key/values pairs within the dictionary
    *   isCOMDict(subject)
    *       checks whether the handed subject is of class COMDict
    *   _setFromArr(keyvalArr)
    *       adds new key/value pairs from the handed array
    *   _NewEnum()
    *       enables enumerated though a for loop
    * Remarks:
    *   this class uses the Scripting.Dictionary COM Object
*/
Class COMDict {


    /**
        * Method: __New(keyvalArr := "")
        *   Creates a new instace of the dictionary class
        * Params:
        *   keyvalArr:  a dictionary creation formatted array
        *               defined below the definition of this class
        * Return:
        *   new dictionary instance
    */
    __New(keyvalArr := ""){
        this.dict := ComObjCreate("Scripting.Dictionary")
        this._setFromArr(keyvalArr)
    }


    /**
        * Method: setAnew(keyvalArr)
        *   sets the dict anew from the handed array
        * Params:
        *   keyvalArr:  a dictionary creation formatted array
        *               defined below the definition of this class
    */
    setAnew(keyvalArr){
        this.removeAll()
        this._setFromArr(keyvalArr)
    }


    /**
        * Method: invert()
        *   returns a new COMDict instance with inverted key/value pairs
        * Return:
        *   the inverted COMDict instance
    */
    invert(){
        r := new COMDict()
        for k in this.keys()
            Try {
                i := this.item(k)
                r.add(i, k)
            }
            Catch, e
                lol := ""
        return, r
    }


    /**
        * Method: add(key, value)
        *   adds a key value pair but will not update existing on
        * Params:
        *   key:    the key to be add
        *   value:  the value to be associated with the key
    */
    add(key, value){
        this.dict.Add(key, value)
    }


    /**
        * Method: item(key)
        *   returns a specific reference to the given key and its value
        *   equivalent to ahks object[key]
        * Params:
        *   key:    the key to be referenced
        * Return:
        *   a reference to the key value pair
    */
    item(key){
        return, this.dict.Item(key)
    }


    /**
        * Method: __Get(key)
        *   convinience wrapper for the this.item(key) method
        *   for reference, look at its documentation above
        * Params:
        *   key:    the key to be referenced
        * Return:
        *   a reference to the key value pair
        * Note:
        *   In case that any key within your map
        *   (or value in case you invert a map)
        *   is named like a method of this class, it would get cause unwanted sideeffects
    */
    /*
    __Get(key){
        return, this.item(key)
    }
    */


    /**
        * Method: remove(key)
        *   removes a specific key from the dictionary
        * Params:
        *   key:    the key to be removed
    */
    remove(key){
        this.dict.Remove(key)
    }


    /**
        * Method: updateKey(key, newKey)
        *   updates a key from the dictionary
        * Params:
        *   key:    the key to be updated
        *   newKey: the replacement key to be set
    */
    updateKey(key, newKey){
        this.dict.Key(key) := newKey
    }


    /**
        * Method: exists(key)
        *   checks whether given key exists within the dict
        * Params:
        *   key:    the key to be checked
        * Return:
        *   boolean, true when key exists
    */
    exists(key){
        return, this.dict.Exists(key)
    }


    /**
        * Method: HasKey(key)
        *   convinience wrapper for the this.exists(key) method
        *   for reference, look at its documentation above
        * Params:
        *   key:    the key to be checked
        * Return:
        *   true if key exists within the dictionary
    */
    HasKey(key){
        return, this.exists(key)
    }


    /**
        * Method: count()
        *   retrieves the number of key/value pairs within the dict
        * Return:
        *   the number of key/value pairs
    */
    count(){
        return, this.dict.count()
    }


    /**
        * Method: items()
        *   retrieves all values present within the dictionary
        * Return:
        *   an standard array of all values
    */
    items(){
        return, this.dict.Items()
    }


    /**
        * Method: keys()
        *   retrieves all keys present within the dictionary
        * Return:
        *   an standard array of all keys
    */
    keys(){
        return, this.dict.Keys()
    }


    /**
        * Method: items()
        *   removes all key/values pairs within the dictionary
        *   clears the hole dict
    */
    removeAll(){
        this.dict.RemoveAll()
    }


    /**
        * Method: isCOMDict(subject)
        *   checks whether the handed subject is of class COMDict
        * Params:
        *   subject:    the subject to check
        * Return:
        *   True if subject is of class COMDict
    */
    isCOMDict(subject){
        return, (!IsObject(subject))
                ? False
                : subject.base.__Class == "COMDict"
    }


    /**
        * Method: _setFromArr(keyvalArr)
        *   adds new key/value pairs from the handed array
        * Params:
        *   keyvalArr:  a dictionary creation formatted array
        *               defined below the definition of this class
    */
    _setFromArr(keyvalArr){
        if(!IsObject(keyvalArr))
            return
        
        for _, o in keyvalArr {
            if(!(IsObject(o)
                    && o.HasKey("key")
                    && o.HasKey("val")))
                continue
            this.add(o.key, o.val)
        }
    }


    /**
        * Method: _NewEnum()
        *   enables enumerated though a for loop
        * Params:
        * Return:
        *   COMDict.Enum instance
        * Note:
        *   Do not store this in a var and
        *   try to then use it for a for loop
        *   it does not work...
    */
    _NewEnum(){
        return, new COMDict.Enum(this)
    }


    /**
        * Class: COMDict.Enum
        *   provides COMDict enumerated though a for loop
        * Attributes:
        *   target:     the COMDict instance to enumerate
        *   key:        the keys yet to be enumerated
        * Methods:
    */
    Class Enum{

        /**
            * Method: __New(cd)
            *   creates a new instance of COMDict.Enum
            * Params:
            *   cd:     the COMDict instance to enumerate
            * Return:
            *   The COMDict.Enum instance for a for loop
            * Note:
            *   Do not store this in a var and
            *   try to then use it for a for loop
            *   it does not work...
        */
        __New(cd){
            if(!COMDict.isCOMDict(cd))
                return, ""
            
            this.target := cd
            this.keys := []
            for k in cd.keys()
                this.keys.push(k)
        }

        /**
            * Method: Next(ByRef k := "", ByRef v := "")
            *   sets k and v anew with each iteration of the for loop
            * Params:
            *   k:      the key to be set
            *   v:      the value to be set
            * Return:
            *   true if the loop should continue
        */
        Next(ByRef k := "", ByRef v := ""){
            if(!this.keys.count())
                return, False
            
            k := this.keys.RemoveAt(1)
            v := this.target.item(k)
            return, 1
        }

    }


}


/*
    * The dictionary creation formatted array (short DCFA):
    *   The COMDict class uses a specially formatted standard ahk array
    *   for easy creation of dictionarys, the DCFA.
    *   The DCFA is a normal array containing associative arrays.
    *   These associative arrays have two keys, "key" and "value"
    *   and should be assigned with their values.
    * Example:
        dcfa := []
        dcfa.Push({"key": "a", "val": "ᴀ"}
                , {"key": "b", "val": "ʙ"}
                , {"key": "c", "val": "ᴄ"}
                , {"key": "d", "val": "ᴅ"}
                , {"key": "e", "val": "ᴇ"}
                , {"key": "f", "val": "ꜰ"}
                , {"key": "g", "val": "ɢ"}
                , {"key": "h", "val": "ʜ"}
                , {"key": "i", "val": "ɪ"}
                , {"key": "j", "val": "ᴊ"}
                , {"key": "k", "val": "ᴋ"}
                , {"key": "l", "val": "ʟ"}
                , {"key": "m", "val": "ᴍ"}
                , {"key": "n", "val": "ɴ"}
                , {"key": "o", "val": "ᴏ"}
                , {"key": "p", "val": "ᴘ"}
                , {"key": "q", "val": "ǫ"}
                , {"key": "r", "val": "ʀ"}
                , {"key": "s", "val": "ꜱ"}
                , {"key": "t", "val": "ᴛ"}
                , {"key": "u", "val": "ᴜ"}
                , {"key": "v", "val": "ᴠ"}
                , {"key": "w", "val": "ᴡ"}
                , {"key": "x", "val": "ⅹ"}
                , {"key": "y", "val": "ʏ"}
                , {"key": "z", "val": "ᴢ"})
        dcfa.Push({"key": "A", "val": "ᴀ"}
                , {"key": "B", "val": "ʙ"}
                , {"key": "C", "val": "ᴄ"}
                , {"key": "D", "val": "ᴅ"}
                , {"key": "E", "val": "ᴇ"}
                , {"key": "F", "val": "ꜰ"}
                , {"key": "G", "val": "ɢ"}
                , {"key": "H", "val": "ʜ"}
                , {"key": "I", "val": "ɪ"}
                , {"key": "J", "val": "ᴊ"}
                , {"key": "K", "val": "ᴋ"}
                , {"key": "L", "val": "ʟ"}
                , {"key": "M", "val": "ᴍ"}
                , {"key": "N", "val": "ɴ"}
                , {"key": "O", "val": "ᴏ"}
                , {"key": "P", "val": "ᴘ"}
                , {"key": "Q", "val": "ǫ"}
                , {"key": "R", "val": "ʀ"}
                , {"key": "S", "val": "ꜱ"}
                , {"key": "T", "val": "ᴛ"}
                , {"key": "U", "val": "ᴜ"}
                , {"key": "V", "val": "ᴠ"}
                , {"key": "W", "val": "ᴡ"}
                , {"key": "X", "val": "ⅹ"}
                , {"key": "Y", "val": "ʏ"}
                , {"key": "Z", "val": "ᴢ"})
        SmallCapsDict := new COMDict(dcfa)

        for k in SmallCapsDict.Keys()
        	test .= k " = " SmallCapsDict.item(k) "`n"
        MsgBox, % test
        return
*/