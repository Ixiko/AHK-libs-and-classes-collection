/*
  callstack()
  by SALZKARTOFFEEEL
  at https://github.com/SALZKARTOFFEEEL/callstack


  callstack() returns an array of maps that represents the callstack.

  Each map has three keys: file, line, func.
  The length of the array can be used to determine the stack size.
  You can limit the amount of array entries returned by passing limit.


  This was written for AHK v2.0-a106 and may not work in other versions.
*/


callstack(limit := -1) {
  stack := array()
  if (limit >= 0)
    stack.capacity := limit

  loop {
    e := exception("", -A_Index)
    stack.push(
      map(
        "file", e.file,
        "line", e.line,
        "func", e.what
      )
    )
  } until (A_Index-1 == limit || string(-A_Index) == e.what)
  stack.pop()

  stack.defineMethod("toString", func("toString"))

  return stack

  toString(callstack) {
    str := ""
    for (frame in callstack) {
      if (A_Index != 1)
        str .= "`n"
      str .= (
        "File: `"" frame["file"] "`"; "
        "line: " frame["line"] "; "
        "func: " frame["func"] "."
      )
    }
    return str
  }
}