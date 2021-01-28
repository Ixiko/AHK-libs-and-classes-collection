/*
    Extended Methods for Indexed arrays
    Copyright © 2013 Robert Ryan

    Released under the MIT licence
    http://opensource.org/licenses/MIT

    Inspired by Lexikos
    http://www.autohotkey.com/board/topic/83081-ahk-l-customizing-object-and-array/?p=529022

    Method List:
    Concat(array2,array3,...,arrayX)          - join two or more arrays
    IndexOf(Item, Start := "")                - searches the array for item, front to back
    Join(Sep := ",")                          - joins the elements of an array into a string
    LastIndexOf(Item, Start := "")            - searches the array for item, back to front
    Length()                                  - returns the number of elements
    Pop()                                     - returns and removes last element of array
    Push(item1, item2, ..., itemX)            - adds new items to the end of the array
    Reverse()                                 - reverses the order of the elements
    Shift()                                   - returns and removes first element of array
    Slice(Start, End := "")                   - returns the selected elements as a new array
    Sort(Options := "")                       - sorts the items of the array
    Splice(Start, HowMany, item1, ..., itemX) - adds/removes items to/from the array
    Unshift(item1,item2, ..., itemX)          - adds new items to the beginning of the array
*/
class _Array
{
/*!
    Method: Concat(Item2,Item3,...,ItemX)
        The concat() method is used Add items to end of the array. The items
        can be individual values or arrays of values.

    Parameters
        Item2,Item3,...,ItemX - Required. The items to be added

    Remarks:
        This method does not change the existing arrays, but returns a new
        array, containing the values of the joined arrays and elements.

    Returns
        The joined array object.
*/
    Concat(prm*)
    {
        NewArr := this.clone()
        for k, Item in prm
            if IsObject(Item)
                for k, v in Item
                    NewArr.Insert(v)
            else
                NewArr.Insert(Item)
        return NewArr
    }

/*!
    Method: IndexOf(Item, Start := "")
        The indexOf() method searches the array for the specified item, and
        returns its position.

        The search will start at the specified position, or at the MinIndex()
        if no start position is specified, and end the search at the MaxIndex()
        of the array. If the item is present more than once, the indexOf method
        returns the position of the first occurence.

    Parameters
        Item  - Required. The item to search for
        Start - Optional. Where to start the search.

    Returns
        If the item is not found, returns "" and sets ErrorLevel to 1.
        Otherwise, returns the position of the specified item and sets
        ErrorLevel to 0.
*/
    IndexOf(Item, Start := "")
    {
        ErrorLevel := 0
        if Start is not integer
            Start := Round(this.MinIndex())
        End := Round(this.MaxIndex())
        Loop
            if (this[Start] == Item)
                return Start
        until ++Start > End
        ErrorLevel := 1
    }

/*!
    Method: Join(Sep := ",")
        This method joins the elements of an array into a string, and returns
        the string. The elements will be separated by a specified separator.
        The default separator is comma (,).

    Parameters
        Sep - Optional. The separator to be used. If omitted, the elements are
        separated with a comma.

    Returns
        The array values, separated by the specified separator.
        If any of the array's values contain the separator, ErrorLevel is set
        to 1. Otherwise ErrorLevel is set to 0.
*/
    Join(Sep := ",")
    {
        ErrorLevel := 0
        Start := Round(this.MinIndex())
        Loop % this.Length() {
            Value := this[Start++]
            Res .= Value . Sep
            if InStr(Value, Sep)
                ErrorLevel := 1
        }
        return SubStr(Res, 1, -StrLen(Sep))
    }

/*!
    Method: LastIndexOf(Item, Start := "")
        The lastIndexOf() method searches the array for the specified item,
        and returns it's position. The search will start at the specified
        position, or at MaxIndex() if no start position is specified, and end
        the search at the MinIndex() of the array.

    Parameters
        Item  - Required. The item to search for.
        Start - Optional. Where to start the search.

    Returns
        If the item is not found, returns "" and sets ErrorLevel to 1.
        Otherwise, returns the position of the specified item and sets
        ErrorLevel to 0.
*/
    LastIndexOf(Item, Start := "")
    {
        ErrorLevel := 0
        if Start is not integer
            Start := Round(this.MaxIndex())
        End := Round(this.MinIndex())
        Loop
            if (this[Start] == Item)
                return Start
        until --Start < End
        ErrorLevel := 1
    }

/*!
    Method: Length(NewLength := "")
        Length returns the number of elements in the array that have integer keys.
        Length can also change the size of the array. If NewLength is less than
        the current length, elements will be removed the end of the array. If
        NewLength is greater than Length, new elements will be added to the end
        of the array.

    Parameters
        NewLength - Optional. The new length of the array

    Returns
        The number of elements in the array.
*/
    Length(NewLength := "")
    {
        Length := (this.MaxIndex() = "") ? 0 : (this.MaxIndex() - this.MinIndex() + 1)

        if NewLength is not integer
            return Length

        if (NewLength < 0)
            return Length

        if (NewLength < Length)
            this.Splice(NewLength + Round(this.MinIndex()), Length - NewLength)
        else
            Loop % NewLength - Length
                this.Insert("")
        return Length
    }

/*!
    Method: Pop()
        This method removes the last element of an array, and returns that
        element.

    Parameters
        None

    Returns
        The element that was removed.
*/
    Pop()
    {
        return this.Remove()
    }

/*!
    Method: Push(item1, item2, ..., itemX)
        This method adds new items to the end of an array

    Parameters
        item1, item2, ..., itemX - Required. The Items to be added.

    Returns
        The array after the items have been added
*/
    Push(Item*)
    {
        this.Insert(Round(this.MaxIndex()) + 1, Item*)
        return this
    }

/*!
    Method: Reverse()
        This method reverses the order of the elements in an array.

    Parameters
        None

    Returns
        The array after it has been reversed
*/
    Reverse()
    {
        Start := Round(this.MinIndex())
        End := Round(this.MaxIndex())
        while Start < End
              Temp := this[Start]
            , this[Start] := this[End]
            , this[End] := Temp
            , Start++, End--
        return this
    }

/*!
    Method: Shift()
        This method removes the first item of an array, and returns that
        element.

    Parameters
        None

    Returns
        The element that was removed
*/
    Shift()
    {
        return this.Remove(1)
    }

/*!
    Method: Slice(Start, End := "")
        This method returns the selected elements in an array, as a new array
        object. The new array will contain the elements from index Start to
        index End, inclusive.

    Parameters
        Start - Required. An integer that specifies where to start the selection
        End   - Optional. An integer that specifies where to end the selection.
                If omitted, all elements from the start position and to the end
                of the array will be selected.

    Returns
        A new array, containing the selected elements
*/
    Slice(Start, End := "")
    {
        if Start is not integer
            return

        NewArr := []
        if End is not integer
            End := Round(this.MaxIndex())
        Loop % End - Start + 1
            NewArr.Insert(this[Start++])
        return NewArr
    }

/*!
    Method: Sort(Options := "")
        This method sorts the items of the array.

    Parameters
        Options - A string that defines how the elements are to be sorted.
                  For the possible values of this parameter, see the Sort
                  command in the AutoHotkey help file.

    Returns
        The sorted array
*/
    Sort(Options := "")
    {
        static Delims := "¤¦§«¬¶·»!#$%&"

;_______Remove any supplied delimiter and substitute our own from the list above
        Options := RegExReplace(Options, "i)(?<!ran)d.")
        Loop Parse, Delims
        {
            Sep := A_LoopField
            String := this.Join(Sep)
            if not ErrorLevel
                break
        }

;_______If no suitable delimiter could be found leave ErrorLevel = 1 and return ""
        if (ErrorLevel)
            return
        Options .= "D" Sep
        Sort String, % Options

;_______If the "U" option removed any items, reduce the size of the array to match.
        if (ErrorLevel)
            this.Splice(this.MaxIndex() - ErrorLevel + 1, ErrorLevel)

        Start := this.MinIndex()
        Loop Parse, String, % Sep
            this[Start++] := A_LoopField
        return this
    }

/*!
    Method: Splice(Start, HowMany, item1, ....., itemX)
        This method adds/removes items to/from the array

    Parameters
        Start   - Required. An integer that specifies at what position to
                  add/remove items
        HowMany - Required. The number of items to be removed. If set to 0,
                  no items will be removed
        item1, ....., itemX - Optional. The new item(s) to be added to the array

    Returns
        A new array containing the removed items, if any
*/
    Splice(Start, HowMany, prm*)
    {
        if Start is not integer
            return
        if HowMany is not integer
            return

        NewArr := []
        Loop %HowMany%
            NewArr.Insert(this.Remove(Start))
        if prm.MaxIndex() <> ""
            this.Insert(Start, prm*)
        return NewArr
    }

/*!
    Method: Unshift(item1,item2, ..., itemX)
        This method adds new items to the beginning of the array

    Parameters
        item1,item2, ..., itemX - The items to be added

    Returns
        The array, after the items are added.
*/
    Unshift(Item*)
    {
        if Item.MaxIndex() <> ""
            this.Insert(1, Item*)
        return this
    }
}

; Redefine Array().
Array(prm*)
{
    ; Since prm is already an array of the parameters, just give it a
    ; new base object and return it. Using this method, _Array.__New()
    ; is not called and any instance variables are not initialized.
    prm.base := _Array
    return prm
}
