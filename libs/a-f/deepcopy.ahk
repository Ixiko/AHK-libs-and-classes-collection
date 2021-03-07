; Title:
; Link:   	https://github.com/acmeism/RosettaCodeData/blob/master/Task/Deepcopy/AutoHotkey/deepcopy.ahk
; Author:
; Date:
; for:     	AHK_L

/*    Task

    Demonstrate how to copy data structures containing complex heterogeneous and cyclic semantics.
    This is often referred to as deep copying, and is normally required where structures are mutable and to ensure that independent copies can be manipulated without side-effects.
    If this facility is not built into the language, it is permissible to use functions from a common library, or a coded procedure.


    The task should show:
    Relevant semantics of structures, such as their homogeneous or heterogeneous properties, or containment of (self- or mutual-reference) cycles.
    Any limitations of the method.
    That the structure and its copy are different.
    Suitable links to external documentation for common libraries.


*/

DeepCopy(Array, Objs=0){
    If !Objs
        Objs := Object()
    Obj := Array.Clone() ; produces a shallow copy in that any sub-objects are not cloned
    Objs[&Array] := Obj ; Save this new array - & returns the address of Array in memory
    For Key, Val in Obj
        If (IsObject(Val)) ; If it is a subarray
            Obj[Key] := Objs[&Val] ; If we already know of a reference to this array
            ? Objs[&Val] ; Then point it to the new array (to prevent infinite recursion on self-references
            : DeepCopy(Val,Objs) ; Otherwise, clone this sub-array
    Return Obj
}