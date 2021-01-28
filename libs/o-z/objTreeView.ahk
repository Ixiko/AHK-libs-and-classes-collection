; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=64611
; Author:	justAnotherUser
; Date:   	16.05.2019
; for:     	AHK_L

/*


*/

; A function to print deeply structured objects.
  objTreeView(key, node, indent := "") { ; parens are used to actually
  ; display something, if key or node are null
    if (isObject(node)) {
      if (isEmpty(node))
        fileAppend, % indent "(" key "): ([])`n", *
      else {
        fileAppend, % indent "(" key ")`n", *
        for k, v in node
          objTreeView(k, v, indent ".  ")
      }
    }
    else if (node = "")
      fileAppend, % indent "(" key "): ()`n", *
    else ; node is string or number
      fileAppend, % indent "(" key "): (" node ")`n", *
  }

  isEmpty(obj) { ; There is surprisingly no builtin option to check an
  ; object for emptiness, i. e. absence of keys. The length() method
  ; only works with proper arrays -- objects indexed with 1, 2, 3, ...
    for k in obj
      return false
    return true ; Also returns true if obj is null, so the check is
    ; non-strict -- a non existent object is "empty" in this context.
  }