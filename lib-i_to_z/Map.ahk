
/*!
    Library: Map, version 2.0
        Call a function over sets of parameters.
        
        Suports AutoHotkey_L and AutoHotkey v2 Alpha
        
        [Forum topic](http://www.autohotkey.com/forum/viewtopic.php?t=76136)
        
        [Concept (Wikipedia)](http://en.wikipedia.org/wiki/Map_%28higher-order_function%29)
    Author: infogulch
    Version: 2.0
*/

/*!
    Function: Map(func, arr_arg1 [, ...arr_argN])

    Parameters:
        func - The function to call
        arr_arg1..arr_argN - *Must* be an array. Arrays of args to pass to `func`. The position of the arr_arg passed to Map() 
            is the same position passed to `func`.

    Returns:
        An array of the results.

    Extra:
        ### Examples
            > ;TODO
        
        ### See also
            Map() behaves identically to [Python's map()](http://docs.python.org/library/functions.html#map)
        
        ### License
            > Copyright (c) 2011, infogulch
            > All rights reserved.
            > 
            > Redistribution and use in source and binary forms, with or without modification, are permitted 
            > provided that the following conditions are met:
            > 
            >     * Redistributions of source code must retain the above copyright notice, this list of 
            >       conditions and the following disclaimer.
            >     * Redistributions in binary form must reproduce the above copyright notice, this list 
            >       of conditions and the following disclaimer in the documentation and/or other materials 
            >       provided with the distribution.
            > 
            > THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR 
            > IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY 
            > AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
            > CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
            > CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
            > SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY 
            > THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
            > OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
            > POSSIBILITY OF SUCH DAMAGE.
*/

Map(func, args*) {
    try return Map_Z(func, Zip("all", args*))
    catch e
        throw Exception("All args after func passed to " A_ThisFunc "() must be arrays.", -1)

}

Map_C(func, args*) {
    try return Map_Z(func, Zip("copy", args*))
    catch e
        throw Exception("All args after func passed to " A_ThisFunc "() must be arrays.", -1)

}

Map_Z(func, args) {
    ret := []
    ret.SetCapacity(args.MaxIndex())
    loop % args.MaxIndex()
        ret[A_Index] := func.(args[A_Index]*)
    return ret
}
