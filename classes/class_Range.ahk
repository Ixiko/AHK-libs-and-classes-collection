/**
    * Class: Range
    *   Aims to create some kind of implementation of Pythons Range function
    *   excludes the ending param from the range result
    * Attributs:
    *   start           the number to start the range with
    *   ending          the ending number
    *   step            the number by which to increase each step
    * Subclasses:
    *   _EnumProvider   actual provider for for loops
    * Methods:
    *   __New(start := 0, ending := 10, step := 1)
    *           creates a new Range instance
    *   toArray()
    *           creates a new array from the Range object instance
    *   _NewEnum()
    *           creates the new instance of the actual class to enumerate
    *   _pEval(now, max)
    *           evaluates whether the range is completed or not for increasing
    *   _nEval(now, min)
    *           evaluates whether the range is completed or not for decreasing
*/
Class Range{

    /**
        * Method: __New(start := 0, ending := 10, step := 1)
        *   creates a new Range instance
        *   Can either be used directly a enum for a for loop
        *   or to create a normal array through the toArray() method
        * Params:
        *   start       the number to start with, 0 by default
        *   ending      the number that should be greater/smaller
        *                   (depending on the step param) than any output
        *                   10 by default
        *   step        the amount to adjust the output by on each iteration
        * Return:
        *   A new instance of the Range class
        * Note:
        *   for included ending use the Range.IncludingEnd class
    */
    __New(start := 0, ending := 10, step := 1){
        this.start := start
        this.ending := ending
        this.step := step
    }

    /**
        * Method: toArray()
        *   creates a new array from the Range object instance
        *   Can either be used directly a enum for a for loop
        *   or to create a normal array through the toArray() method
        * Params:
        * Return:
        *   A new array based of the params of the range object
    */
    toArray(){
        arr := []
        if(!this.step)
            return, arr
        provider := (this.step < 0) ? this._nEval.Bind(this) : this._pEval.Bind(this)
        While(provider.Call((v := (A_Index - 1) * this.step + this.start), this.ending))
            arr.Push(v)
        return, arr
    }

    /**
        * Method: _NewEnum()
        *   creates the new instance of the actual class to enumerate
        * Params:
        * Return:
        *   The class to enumerate
        * Note:
        *   DOES ONLY WORK WENN CALLED BY THE FOR LOOP!
        *   DON'T STORE IT ANYWHERE SINCE IT WOULD NOT WORK
    */
    _NewEnum(){
        return, new Range._EnumProvider(this.start
                                        , this.ending
                                        , this.step
                                        , (this.step < 0)
                                            ? this._nEval.Bind(this)
                                            : this._pEval.Bind(this))
    }

    /**
        * Method: _pEval(now, max)
        *   evaluates whether the range is completed or not
        *   this version is used for ranges with a larger
        *   second param than the first
        * Params:
        *   now         the current number calculated by the range provider
        *   max         the number not to reach by the range provider
        * Return:
        *   Boolean, true if the range is not yet completed
    */
    _pEval(now, max){
        return, now < max
    }

    /**
        * Method: _nEval(now, min)
        *   evaluates whether the range is completed or not
        *   this version is used for ranges with a smaller
        *   second param than the first
        * Params:
        *   now         the current number calculated by the range provider
        *   min         the number not to reach by the range provider
        * Return:
        *   Boolean, true if the range is not yet completed
    */
    _nEval(now, min){
        return, now > min
    }

    /**
        * Class: Range._EnumProvider
        *   does all the magic on dynamically generating the range
        * Attributes:
        *   start       the number to start the range with
        *   ending      the ending number
        *   step        the number by which to increase each step
        *   provider    the evaluation provider function object
        *                   should return true as long as range is not complete
        *   index       the current index the range is at
        * Methods:
        *   __New(start, ending, step, provider)
        *           creates a new instance of the class for the for loop
        *   Next(ByRef k:="", ByRef v:="")
        *           is called by the for loop to get the next k/v pair
    */
    Class _EnumProvider{
        index := 0
        __New(start, ending, step, provider){
            this.start := start
            this.ending := ending
            this.step := step
            this.provider := provider
        }
        Next(ByRef k:="", ByRef v:=""){
            v := this.index * this.step + this.start
            k := this.index
            if(!this.step || !this.provider.Call(v, this.ending))
                return, 0
            this.index++
            return, 1
        }
    }
}

/**
    * Class: RangeE
    *   does the same as its Parent Class Range
    *   but includes the ending param in the range result
*/
Class RangeE extends Range{
    _pEval(now, max){
        return, now <= max
    }
    _nEval(now, min){
        return, now >= min
    }
}