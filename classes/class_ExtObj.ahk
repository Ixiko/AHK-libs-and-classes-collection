/*
    __      _                 _          _     ___ _     _           _       
   /__\_  _| |_ ___ _ __   __| | ___  __| |   /___\ |__ (_) ___  ___| |_ ___ 
  /_\ \ \/ / __/ _ \ '_ \ / _` |/ _ \/ _` |  //  // '_ \| |/ _ \/ __| __/ __|
 //__  >  <| ||  __/ | | | (_| |  __/ (_| | / \_//| |_) | |  __/ (__| |_\__ \
 \__/ /_/\_\\__\___|_| |_|\__,_|\___|\__,_| \___/ |_.__// |\___|\___|\__|___/
    Coded by errorseven @ 5-14-17                    |__/      v1.1.3         

Change Log:
----------- 
   v1.1.3 @ 6-4-17
           - Changed Count property to future proof implementation
           
   v1.1.2 @ 6-2-17:
           - Fixed Formating issue
           - Added Documention and Usage examples
           
   v1.1.1 @ 6-2-17:
           - Added default declaration of Options in Sort()
           - Fixed Sort() from returning array with new deliminator
           - Added override StrSplit() to intialize an Extended Object

    v1.1 @ 5-29-17:
           - Added Sort method to ease sorting Arrays/Objects
*/

;library ExtObj.AutoHotkey by ErrorSeven
{
Class _Object extends _str {

    Count[] {
        /* 
        Returns an actual Count of objects contained in Array
        
        Usage:
            Obj := {a:1, b:2, c:3}
            obj.count ; --> 3
        */
        
        get {
            return this.SetCapacity(0)
        }
    }    

    IsLinear[] {
        /*
        Deterimines if an Array is Linear 
        Intended for Internal use, but have at it if you find a use
        */
   
        Get {
            While (A_Index != this.MaxIndex()) 
                If !(this.hasKey(A_Index)) 
                    Return False
            Return True        
        }
    }
    
    Print[] { 
        /* 
        Returns an accurate Str representation of your Object/Array
        
        Usage: 
            obj := [1, 2, 3, {a: 1, b: 2}]
            obj.print ; --> [1, 2, 3, {a:1, b:2}]
        */
        
        Get {
        
            If this.IsCircle()
                Return "Error: Object contains a Circluar Reference"
                
            Linear := this.IsLinear
            
            For k, v in this {
                if (Linear == False) {
                    if (IsObject(v)) 
                       r .= k ":" this[k].print ", "        
                    else {                  
                        r .= k ":"  
                        if v is number 
                            r .= v ", "
                        else 
                            r .= """" v """, " 
                    }            
                } else {
                    if (IsObject(v)) 
                        r .= this[k].print ", "
                    else {          
                        if v is number 
                            r .= v ", "
                        else 
                            r .= """" v """, " 
                    }
                }
            }
            return Linear ? "[" trim(r, ", ") "]" 
                          : "{" trim(r, ", ") "}"
        }
    }

    Reverse[] {
        /*
        Returns a reverse ordered Array/Object
        
        Usage: 
            obj := [1, 2, 3].reverse
            obj.print ; --> [3, 2, 1]
        */
        
        get {
            x := []
            loop % this.count
                x.push(this.pop())
            return x
        }
    }
    
    
    IsCircle(Objs=0) {
        /*
        Function by GeekDude
        Returns True if Object contains a reference to itself
        Intended for internal use, but have at it if you find a use
        */
        
        if !Objs
            Objs := {}
        For Key, Val in this
            if (IsObject(Val)&&(Objs[&Val]||Val.IsCircle((Objs,Objs[&Val]:=1))))
                return 1
        return 0
    }
    
    Contains(x, y:="") {
        /*
        Returns a Str index (True) or False         
        Usage: 
            obj := [1, 3, 2, [5, 4]] 
            obj.contains(4) ; --> [4][2]
        */
        
        If this.IsCircle()
            return 0
    
        For k, v in this {         

            if (v == x)
                return y "[" k "]"

            if (IsObject(v) && v != this) 
                z := this[k].contains(x, y "[" k "]" )
        
            if (z)
                return z
        }

        return 0
    }   

    Sort(options:="", delim:="`n") {
        /*    
        Use Sort Command documentation to interpret options. The deliminator is 
        seperate for ease of implementation.
        
        Usage: 
            obj := [c, d, b, a].sort()
            obj.print ; --> [a, b, c, d]
        */
        
        For e, v in this
            r .= v delim
        Sort, r, % options "D" delim
        return StrSplit(trim(r, delim), delim)
    }
    
}

Class _Array Extends _Object {
    ; Just here to extend functions
}
    
Array(prm*) {
    /* 
       Since prm is already an array of the parameters, just give it a
       new base object and return it. Using this method, _Array.__New()
       is not called and any instance variables are not initialized.
    */
    x := {}
    loop % prm.length()
        x[A_Index] := prm[A_Index]
    x.base := _Array
    return x
} 

Object(prm*) {
    /*
        Create a new object derived from _Object.
    */
    obj := new _Object
    ; For each pair of parameters, store a key-value pair.
    Loop % prm.MaxIndex()//2 
        obj[prm[A_Index*2-1]] := prm[A_Index*2]
    ; Return the new object.
    return obj
}

StrSplit(x, dlm:="", opt:="") {
    /* 
    Use help documentation definition to determine options. This override 
    is here to properly intialize an Extended Object using Object Class.
    
    Usage:
        Obj := StrSplit("abc")
        Obj.print ; --> ["a", "b", "c"]
    */
    
    r := [], o:=""
    StringSplit, o, x, %dlm%, %opt%
    
    loop, %o0% 
        r.push(o%A_index%)
 
    return r
}
}

;library strObj
{
class CustomObject extends _str
{
    static _ := "".base.base := CustomObject
}

class _str {

    ; +-+-+-+- PROPERTIES +-+-+-+-
    
    ascii_letters[] {
        get {
            return "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        }
    }
    
    ascii_lowercase[] {
        get {
            return "abcdefghijklmnopqrstuvwxyz"
        }
    }
    
    ascii_uppercase[] {
        get {
            return "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        }
    }
    
    ascii_vowels[] {
        get {
            return "aeiouy"
        }
    }
    
    ascii_consonants[] {
        get {
            return "bcdfghjklmnpqrstvwxyz"
        }
    }
    ; +-+-+-+- Methods +-+-+-+-
    
    capitalize() {
        /* 
           Returns a copy of the string with 
           only its first character capitalized.
        */
        cap := false
        for e,v in this {
            if (cap == false) 
                r .= Format("{1:U}", v), cap := true
            else
                r .= v
         }      
        return r
    }
    
    center(width, fillchar:=" ") {
        /* 
           Returns centred in a string of length width.
           Padding is done using the specified fillchar. 
           Default filler is a space.
        */
        pad := round((width - this.length()) // 2)
        loop % pad 
            r .= fillchar
        return r this.toString() r
    }
          
    endswith(suffix, beg:=0, end:="") {
        /* 
           Returns True if the string ends with the specified suffix, 
           otherwise return False optionally restricting the matching 
           with the given indices start and end.
        */
        if (end == "")
            end := this.length()
        for e,v in range(beg, end)
            r .= this[v]
        return suffix == r
    }
    
    expandtabs(tabsize:=8) {
        /* 
           Returns a copy of the string in which tab characters ie. 
           '\t' are expanded using spaces, optionally using the given 
           tabsize (default 8)..
        */
        
        loop % tabsize 
            r .= " "
        return StrReplace(this.toString(), "`t", r)
    }
    
    isupper() {
        for e,v in this
            if ("".ascii_uppercase ~= v)
                return true
        return false
    }
    
    join(seq) {
        /* 
           Returns a string in which the string elements of sequence have been
           joined by string separator.
        */
        
        r := ""
        for e,v in seq {
            if (e == seq.MaxIndex()) {
                r .= v
                break
            }
            r .= v this.toString()
        }         
        return r
    }
    
    ljust(width, fillchar:=" ") {
        /* 
           Returns string padded on the left 
           with zeros to fill width.
        */
        
        pad := abs(width - this.length())
        loop % pad 
            r .= fillchar
        return this.toString() r
    }
    
    rjust(width, fillchar:=" ") {
        /* 
           Returns string padded on the left 
           with zeros to fill width.
        */
        
        pad := abs(width - this.length())
        loop % pad 
            r .= fillchar
        return r this.toString()
    }
    
    slice(start, stop:="", step:=1) {
        /*  
            Return a slice object representing the set of 
            indices specified by range(start, stop, step). 
        */
        
        if (stop == "") 
            stop := start, start := 1
        if (IsObject(this)) {
            for e,v in range(start, stop, step) {
                r .= this[v]
            }
        }
        return r
    } 
    
    swapcase() {
        /* 
           Returns a copy of the string in which all the case-based 
           characters have had their case swapped.
        */
        
        for e,v in this 
            if (this.ascii_letters ~= v)
                r .= (this.ascii_uppercase ~= v ? format("{1:L}", v) 
                                                : format("{1:U}", v))
            else 
                r .= v
        return r
    }
    
    toString() {
        ; Returns string from str() object
       
        for e,v in this
            r .= v
        return r
    }
    
    zfill(width) {
        /* Returns string padded on the left 
           with zeros to fill width.
        */
        
        loop % abs(this.length() - width)
            r .= 0
        return r . this.tostring()    
    }
}

str(prm) {
    /* 
        Initiates String Class Object / Array 
        granting access to a plethora of String Methods
        
        Returns: Class Object
        
        prm -> value or object
        
        example: str("abc") -> ["a", "b", "c"]
                 x := [1, 2, 3, [4, 5]]
                 str(x).ToString() -> [1, 2, 3, [4, 5]]
    */
    
    r := StrSplit(prm)
    return r
    
} 
}

;library stdfunc 
{
    
/*
         __  _____  ___     ___                 _   _                 
        / _\/__   \/   \   / __\   _ _ __   ___| |_(_) ___  _ __  ___ 
        \ \   / /\/ /\ /  / _\| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
        _\ \ / / / /_//  / /  | |_| | | | | (__| |_| | (_) | | | \__ \
        \__/ \/ /___,'   \/    \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
         Coded by errorseven @ 6-4-17                       v1.0                                                          

                 A useful collection of Standard Functions!
*/
    
Bin(x) {
    /*
        Convert an integer number to a binary string. 
        
        Return: binary str
        
        x -> int 
        
        example: bin(5) -> 0b101
                 bin(-2398892) -> -0b1001001001101010101100
    */
    
    if (x < 0)
        neg := True, x := abs(x)
       
    While(x != 0) {
        z := Mod(x, 2) z
        x := x // 2
    }
    
    return (neg?"-":_) "0b" ltrim(z, "0")


}

Hex(x) {
    /*
        Convert an integer number to a hexcidecimal string. 
        
        Return: hexcidecimal str
        
        x -> int 
        
        example: hex(22) -> 0x16
    */ 
    if (x < 0)
        neg := True, x := abs(x)
        
    return (neg?"-":_) format("0x{:x}", x)
    
}

Max(arr, index:=0) {
    /* 
        Returns Maximum value or index of the values contained in an array
        
        arr    ->   object
        index  ->   bool
        
        Examples: max([3, 2, 1], 1) ; -> 1
    */
    
    if !(IsObject(arr))
        return
    
    for e, v in arr {
        if (e == 1)
            cur:=Max:=v,key:=e
        else {
            max := v > Max ? v : Max
            key := v > Max ? e : key
        } 
    }
    
    return (index ? key : max)
}

Min(arr, index:=0) {
    /* 
        Returns Minimum value or index of the values contained in an array
        
        arr    ->   object
        index  ->   bool
        
        Examples: min([3, 2, 1], 1) ; -> 3
    */
    
    if !(IsObject(arr))
        return
    
    for e, v in arr {
        if (e == 1)
            cur:=min:=v,key:=e
        else {
            min := v < min ? v : min
            key := v < min ? e : key
        } 
    }
    
    return (index ? key : min)
}

Oct(x) {
    /*
        Convert an integer number to a octal string. 
        
        Return: octal str
        
        x -> int 
        
        example: oct(23) -> 0o27
    */ 
    if (x < 0)
        neg := True, x := abs(x)
     
    num := power := 0
 
    while (x > 0) {
        num += 10 ** power * (Mod(x, 8))
        x //= 8, power++
    }
    return (neg?"-":_) "0o" num
}

Random(x:=0, y:=9) {
    /*    
        Use Random Command documentation to interpret options.
        
        Examples: 
            var := Random()          ; --> var == 0 ... 9
            var := Random(100)       ; --> var == 0 ... 100
            var := Random(10, 50)    ; --> var == 10 ... 50
    */
    if(x > 0 && x > y)
        y:=x, x:=0
        
    o := ""
    Random, o, x, y
    return o
}

Range(start:="", stop:="", step:=1) {
    /* 
        Creates an array containing arithmetic progressions. It is most often 
        used in for loops. The arguments must be plain integers. If the step 
        argument is omitted, it defaults to 1. If the start argument is omitted,
        it defaults to 0.
        
        Return: Array
        
        start -> int
        stop  -> int
        step  -> int
        
        example: range(5) -> [0, 1, 2, 3, 4] || range(0, 7, 2) -> [0, 2, 4, 6]
    */

    r := []
    if (start == "")
        return 
        
    if (stop == "")
        stop:=start,start:=0
    
    if (step == 0) 
        return r
    
    while((step < 0 ? start >= stop : start <= stop))
        r.push(start), start += step
    
    return r
}

Sort(str, options:="", delim:="`n") {
    /*    
        Use Sort Command documentation to interpret options. The deliminator is 
        seperate for ease of implementation.
        
        str     ->   str
        options ->   str
        delim   ->   str
        
        Usage: 
            var := Sort("c d b a",," ") ; --> a b c d
    */
    Sort, str, % options "D" delim
    return str
}

Sum(iter, start:=1) {
    /* 
        Sums start and the items of an iterable from left to right and returns 
        the total. start defaults to 0. The iterable‘s items are normally 
        numbers, and the start value is not allowed to be a string.
        
        Return: int or float
        
        iter -> Array
        start -> int
        
        example: sum([1, 2 ,3]) -> 6 || sum([1.0, 2.0, 3.0], 2) -> 5.00000
    */   
    
    if !(isObject(iter))
        return
    r := 0
    for e,v in iter
        if (e >= start)
            r += v
    return r
}

Zip(x*) {
    /* 
        This function returns an array of arrays, where the i-th array contains 
        the i-th element from each of the argument sequences or iterables. The 
        returned array is truncated in length to the length of the shortest 
        argument sequence. When there are multiple arguments which are all of 
        the same length. 
        
        Return: array
        
        x -> varadic 
        
        example: zip([1, 2, 3], [4, 5, 6]) -> [[1, 4], [2, 5], [3, 6]]
    */
        
    z := [], i:=1
        for e,v in x {
            if !(IsObject(v))
                return
            if (e == 1)
                min := v.length()
            else
                min := min > v.length() ? v.length() : min
        }
        loop % min {
            newArr := []
            for e, v in x
                newArr.push(v[i])
            z[i] := newArr, i++
        }
    
    return z
}

}