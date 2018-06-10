COM operation ラ イ ブ リ ー by 流行 ら せ る ペ ー ジ 管理者
 Ver.

Specifications are subject to change without notice.



● Outline
Enable handling of COM objects used in WSH, for example


● How to use
You can copy the script to the Live folder (the "Lib" folder in the AutoHotkey.exe folder)
And execute the ActiveX () function in the script you want to use
However, if you enter the same folder as the script,
#include% A_ScriptDir% \ ActiveX.ahk
.

#include * i% A_ScriptDir% \ ActiveX.ahk
ActiveX ()
If they do, they will be able to work with any of them.

● About the sample

· Sample_IE.ahk
Start IE, write it on the page, and respond to the event

· Sample_JScript.ahk
Generate a script control and execute the embedded JScript code with the help command

· Sample_SpeechRecognition
The speech recognition component is called up and a word recognition event is performed to perform a word-


● Provided functions
ActiveX () ActiveX initialization
CreateObject (ProgID, IID = "", CLSCTX = 5) Create an object
inv (pIDisp, name [, p1, p2 ..., p10]) Execute the method of the object
gp (pIDisp, name [, p1, p2 ..., p10]) Get the properties of the object
pp (pIDisp, name, p1 [, p2, p3 ..., p10]) Sets the properties of the object
vNull () Get the null value to use for the inv / gp / pp argument
Convert the vObj () object to a value for the inv / gp / pp argument

Assign a function to the ConnectObject (pIDisp, prefix, itf) event
evArgc (prm) Get the number of elements in the argument structure of the event
evArgv (prm, index) Get the element of the argument's argument structure
evReturn (res, value) Sets the value to the return value structure of the event

CreateDispatchObject (prefix, exsize = 0) Creates an IDispatch object,
                                    Assign the function in the script

CoInitialize () Initialize COM
CoUninitialize () Release COM
Release (pObj) Decreases the reference counter
ReleaseL ([p1, p2 ..., p10]) Releasing multiple objects together
AddRef (pObj) Increases the reference count of the object
QueryInterface (pObj, strIID = "") Get the interface
Obtain the function pointer of the vTable of the M (pObj, index) object
CoTaskMemAlloc (size) Ensures COM working memory
CoTaskMemFree (ptr) Releases COM working memory


● Preparation function
ActiveX ()
Overview
Initialize ActiveX.ahk
Return value
No
Supplement
Since it is executed in CreateObject if necessary,
Do not use it if you use #include


● IDispatch related functions
CreateObject (strProgID, strIID = "", CLSCTX = 5)
Overview
Create a COM object to get the interface
Argument
strProgID
A string indicating the program ID of the object to be created.
(Eg "InternetExplorer.Application")
You can also specify a CLSID such as "{0002DF01-0000-0000-C000-000000000046}"
strIID
Specify the interface ID of the retrieved interface
(Example: "{00020400-0000-0000-C000-000000000046}")
If omitted, IDispatch is acquired.
CLSCTX
The context in which to execute the management code for the newly created object
Sum of the following
0x01 (CLSCTX_INPROC_SERVER)
0x02 (CLSCTX_INPROC_HANDLER)
0x04 (CLSCTX_LOCAL_SERVER)
0x16 (CLSCTX_REMOTE_SERVER)
Return value
The acquired interface (the pointer to the memory area in which the data is stored)
0 on failure

inv (pIDisp, name [, p1, p2 ..., p10])
Overview
Get the callback value of the method of the IDispatch type object
Argument
pIDisp
The IDispatch interface retrieved by CreateObject and so on
name
Method name
p1 ... p10
Arguments to the method.
Normally it is given as a character string and converted to an appropriate value on the method side.
The truth value may be given as "true" or "false".
The null and IDispatch objects are defined in vNull (), vObj ()
It is converted into a value for identification.
Return value
Method return value
In the case of an object, the pointer to the object
Supplement
For some processing reasons, the argument can not be given a 64-bit integer in some range,
Generally, integers of 32 bits or more are not used.

gp (pIDisp, name [, p1, p2 ..., p10])
Overview
Get properties from an IDispatch type object
Argument
pIDisp
A pointer to an IDispatch type object, such as CreateObject.
name
The name of the property
p1 ... p10
Specified if the property has an argument (such as an index).
Return value
The value of the acquired property
In the case of an object, the pointer to the object

pp (pIDisp, name, p1 [, p2, p3 ..., p10])
Overview
Setting the properties of an IDispatch type object
Argument
pIDisp
A pointer to an IDispatch type object, such as CreateObject.
p1 ... p10
Arguments.
The last argument is the value to set.
Otherwise, an array index, for example.
Example
To do something like obj.Item (row, col) = value;
Pp (obj, "Item", row, col, value) ".

vNull ()
Overview
get a value to specify null for the inv / pp / gp argument
Return value
0x7FFFFFFF00000000.
This value is treated as VT_NULL

vObj (pIDisp)
Overview
Gets the value to pass the IDispatch type object to the inv / pp / gp argument
Argument
pIDisp
A pointer to an IDispatch type object, such as CreateObject.
Return value
0x7FFFFFF00000000 | pIDisp.
The lower 32 bits of this value are treated as pointers to the object


● Event Related Functions
ConnectObject (pIDisp, prefix, itf = "")
Overview
Connect to the event of an IDispatch type object
Argument
pIDisp
The IDispatch interface retrieved by CreateObject and so on
prefix
Preface to the function name of the entity of the event
itf
Destination interface, usually not specified, defaults to default.
Return value
Successful "0"
Supplement
When the event occurs, the name of the function that concatenates the prefix and the event name is called
The function can be an event source, a parameter,
Receive three arguments to the return value
(For example, "ev_onunload (this, prm, res)")
EvArgc, evArgv, evReturn below can manipulate the parameter return value
If you want to register an event, set it to # resident by # Persistent, etc.

evArgc (prm)
Overview
Obtain the number of values ​​held by the parameter structure
Argument
prm
The structure address given to the second argument of the event function
Return value
Number of values

evArgv (prm, index)
Overview
Obtain the value held by the parameter structure
Argument
prm
The structure address given to the second argument of the event function
index
Value Indices
"0" at the beginning
Return value
The stored value

evReturn (res, value)
Overview
Return value Set the value in the structure
Argument
res
The structure address given to the third argument of the event function
value
Set value


● Creating a Dispatch Object
CreateDispatchObject (prefix, exsize = 0)
Overview
Create an IDispatch object and assign a method to the method that starts with prefix
Argument
prefix
Preface to the function that is the entity of the method
exsize
The additional capacity to be allocated to the structure of the object.
Within the assigned function, NumPut (100, this + 16) and
NumGet (this + 16) can be used to store arbitrary information.
The extension starts from offset 16.
Return value
The pointer to the created IDispatch object.
Supplement
Specify "MyObj_" as the prefix, and use the "MyMethod"
Is called, the MyObj_MyMethod function is called.
The function can be a pointer to the object itself, a parameter, a return value storage location,
Receive four arguments to the callout flags
(For example, "MyObj_MyMethod (this, prm, res, flag)")
Which of the following is a flag?
1 = method call
2 = Get property
3 = Properties settings
4 = Assign reference to property

● COM general functions
CoInitialize ()
Overview
Prepare to use COM
Supplement
It is called in ActiveX () and is usually unnecessary

CoUninitialize ()
Overview
When you finish using COM, do it later

AddRef (pOb