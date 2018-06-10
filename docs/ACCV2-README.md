# AccV2.ahk - Standard Library
## Created by Sean
## Updated by jethrow:
*	Modified ComObjEnwrap params from (9,pacc) --> (9,pacc,1)
* 	Changed ComObjUnwrap to ComObjValue in order to avoid AddRef (thanks fincs)
* 	Added Acc_GetRoleText & Acc_GetStateText
* 	Added additional functions - commented below
* 	Removed original Acc_Children function

last updated: 2/19/2012

## Updated by Sancarn:
*	Added all relevant enumerations
* Added IAccessible walking functionality e.g.

```ahk
   acc_childrenFilter(oAcc, ACC_FILTERS.byDescription, "Amazing button")
   
   acc_childrenFilter(oAcc, Func("myAwesomeFunction"), true)
   myAwesomeFunction(oAcc,val){
       return val
   }
```
* Modified Acc_Children function and added ACC_ChildProxy class. If accChild returns a VT_I4 value in ACC_Children, ACC_ChildProxy is used instead of IAccessible. I still don't have a good way of retrieving the hwnd or position for these elements.

* Added acc_childrenFilter. This should be intergrated into `Acc_Children()` like `Acc_Children(oAcc,ACC_FILTER.byName, "CoolButton",true,ACC_FILTER)`

* Preperation for move to a fully class based system.
