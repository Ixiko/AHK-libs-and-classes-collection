;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Classes to stop inadvertent errors in AHK_L
;;  Copyright (C) 2012 Adrian Hawryluk
;;
;;  This program is free software: you can redistribute it and/or modify
;;  it under the terms of the GNU General Public License as published by
;;  the Free Software Foundation, either version 3 of the License, or
;;  (at your option) any later version.
;;
;;  This program is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;  GNU General Public License for more details.
;;
;;  You should have received a copy of the GNU General Public License
;;  along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Miscleanious Classes to Stop Inadvertent Errors
;;                                          - by Adrian Hawryluk November 2012
;;                                             - Tested under AHK_L v1.1.08.01
;;
;;  These classes are to make inadvertent errors a thing of the past.  These
;;  classes do not stop deliberate actions on the part of the programmer, they
;;  are to stop errors not intended by the programmer.
;;
;; const
;;  This class makes the member variables of the class constant by putting all
;;  members that are constant in a separate member called _vals.  Write attempts
;;  to the vars through the object will be caught so long as there is no member 
;;  variable by that name already in the object.
;;
;; checkExistence
;;  This class checks the existence of a member variable in the class and catch
;;  if there is an attempt to get or set a variable that isn't already in the
;;  object or in the object member _vals.
;;
;; checkExistenceConst
;;  This class allows the getting of members located in _vals, but doesn't allow
;;  the setting of them.  This doesn't stop the setting of vars that are 
;;  directly in the object.
;;
;; You can either inherit using extends or possibly assign the __Get/__Set to
;; the base class (which I am not going to show here).  I.e.
;;
;;    class foo extends const
;;    {
;;      __new()
;;      {
;;        _vals := {}
;;        _vals.bar := "foofoo"
;;        ObjInsert(this, "_vals", _vals) ; have to insert this way to avoid the __Set() function.
;;      }
;;    }
;;    
;;    x := new foo
;;    x.boo := 3 ; fails since constant
;;    x.bar := 4 ; fails since constant
;;    MsgBox % "x.boo: '" x.boo "'`nx.bar: '" x.bar "'"
;;    
;;    class foo2 extends checkExistence
;;    {
;;      __New()
;;      {
;;        _vals := {}
;;        _vals.bar := "foofoo"
;;        ObjInsert(this, "_vals", _vals) ; have to insert this way to avoid the __Set() function.
;;      }
;;    }
;;    x := new foo2
;;    x.boo := 3 ; fails since doesn't already exist
;;    x.bar := 4 ; succeeds
;;    MsgBox % "x.boo: '" x.boo "'`nx.bar: '" x.bar "'" ; x.boo warns since it checks existence
;;    
;;    class foo3 extends checkExistenceConst
;;    {
;;      __New()
;;      {
;;        _vals := {}
;;        _vals.bar := "foofoo"
;;        ObjInsert(this, "_vals", _vals) ; have to insert this way to avoid the __Set() function.
;;      }
;;    }
;;    x := new foo3
;;    x.boo := 3 ; fails since constant
;;    x.bar := 4 ; fails since constant
;;    MsgBox % "x.boo: '" x.boo "'`nx.bar: '" x.bar "'" ; x.boo warns since it checks existence
;;
;; LOG
;;  Nov 30/2012
;;   - Moved the inclusion of the object.ahk file to the bottom of the script
;;     as it caused an order problem.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
class const
{
  __Get(key)
  {
    if (ObjHasKey(this, "_vals") and ObjHasKey(this._vals, key))
      return this._vals[key]
    else if (ObjHasKey(object_getBase(this), "_vals"))
      return object_getBase(this).__Get(key)
  }
  __Set(key, val)
  {
    MsgBox Error: Attempt to set to key '%key%' to value '%val%' when object is a constant.
    return ; a return means not to let default __Set() handle call.
  }
}

class checkExistence
{
  __Get(key)
  {
    if (ObjHasKey(this, "_vals") and ObjHasKey(this._vals, key))
      return this._vals[key]
    else if (ObjHasKey(object_getBase(this), "_vals"))
      return object_getBase(this).__Get(key)
    else
      MsgBox Warning: Key '%key%' doesn't exist in object.
  }
  __Set(key, ByRef val)
  {
      if (ObjHasKey(this, "_vals") and ObjHasKey(this._vals, key))
        return this._vals[key] := val
      else
      {
        MsgBox Error: Attempt to assign to key '%key%', which doesn't exist in object, to value '%val%'.
        return
      }
  }
}

class checkExistenceConst extends const
{
  __Get(key)
  {
    if (ObjHasKey(this, "_vals") and ObjHasKey(this._vals, key))
      return this._vals[key]
    else if (ObjHasKey(object_getBase(this), "_vals"))
      return object_getBase(this).__Get(key)
    else
      MsgBox Warning: Key '%key%' doesn't exist in object.
  }
}

#include <object>
