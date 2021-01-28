; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=76&t=71786&sid=489e40d94f85686040c5a8b61b2ed202
; Author:
; Date:
; for:     	AHK_L

/*


*/

obj := new ScriptingDictionary
obj[3] := 1
obj[2] := 2
obj.B  := 3
obj.b  := 4
obj.a  := 5
obj.A  := 6

for k, v in obj
   MsgBox,, Pairs, % k . ": " . v

keys := obj.Keys
for k, v in keys
   MsgBox,, Keys, % v

values := obj.Items
for k, v in values
   MsgBox,, Values, % v

obj.Delete("a")
MsgBox, % obj.HasKey("a")
MsgBox, % obj.HasKey("A")

class ScriptingDictionary
{
   __New() {
      this._dict_ := ComObjCreate("Scripting.Dictionary")
   }

   __Delete() {
      this._dict_.RemoveAll()
      this.SetCapacity("_dict_", 0)
      this._dict_ := ""
   }

   __Set(key, value) {
      if !(key == "_dict_") {
         if !this._dict_.Exists(key)
            this._dict_.Add(key, value)
         else
            this._dict_.Item(key) := value
         Return value
      }
   }

   __Get(key) {
      if (key == "_dict_")
         Return
      if (key == "Keys" || key == "Items") {
         keys := this._dict_[key]
         arr := []
         Loop % this._dict_.Count
            arr.Push(keys[A_Index - 1])
         Return arr
      }
      else
         Return this._dict_.Item(key)
   }

   _NewEnum() {
      Return new ScriptingDictionary._CustomEnum_(this._dict_)
   }

   class _CustomEnum_
   {
      __New(dict) {
         this.i := -1
         this.dict := dict
         this.keys := this.dict.Keys()
         this.items := this.dict.Items()
      }

      Next(ByRef k, ByRef v) {
         if ( ++this.i = this.dict.Count() )
            Return false
         k := this.keys[this.i]
         v := this.items[this.i]
         Return true
      }
   }

   Delete(key) {
      if this._dict_.Exists(key) {
         value := this._dict_.Item(key)
         this._dict_.Remove(key)
      }
      Return value
   }

   HasKey(key) {
      Return !!this._dict_.Exists(key)
   }
}