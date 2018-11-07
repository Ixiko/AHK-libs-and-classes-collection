/*
class: CLSCTX
an enumeration class containing flags that values that are used in activation calls to indicate the execution contexts in which an object is to be run.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/CLSCTX)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms693716)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 2000 Professional / Windows 2000 Server or higher
*/
class CLSCTX
{
	/*
	Field: INPROC_SERVER
	The code that creates and manages objects of this class is a DLL that runs in the same process as the caller of the function specifying the class context.
	*/
	static INPROC_SERVER := 0x1

	/*
	Field: INPROC_HANDLER
	The code that manages objects of this class is an in-process handler. This is a DLL that runs in the client process and implements client-side structures of this class when instances of the class are accessed remotely.
	*/
	static INPROC_HANDLER := 0x2

	/*
	Field: LOCAL_SERVER
	The EXE code that creates and manages objects of this class runs on same machine but is loaded in a separate process space.
	*/
	static LOCAL_SERVER := 0x4

	/*
	Field: INPROC_SERVER16
	Obsolete.
	*/
	static INPROC_SERVER16 := 0x8

	/*
	Field: REMOTE_SERVER
	A remote context. The LocalServer32 or LocalService code that creates and manages objects of this class is run on a different computer.
	*/
	static REMOTE_SERVER := 0x10

	/*
	Field: INPROC_HANDLER16
	Obsolete.
	*/
	static INPROC_HANDLER16 := 0x20

	/*
	Field: RESERVED1
	Reserved.
	*/
	static RESERVED1 := 0x40

	/*
	Field: RESERVED2
	Reserved.
	*/
	static RESERVED2 := 0x80

	/*
	Field: RESERVED3
	Reserved.
	*/
	static RESERVED3 := 0x100

	/*
	Field: RESERVED4
	Reserved.
	*/
	static RESERVED4 := 0x100

	/*
	Field: NO_CODE_DOWNLOAD
	Disaables the downloading of code from the directory service or the Internet. This flag cannot be set at the same time as <ENABLE_CODE_DOWNLOAD>.
	*/
	static NO_CODE_DOWNLOAD := 0x400

	/*
	Field: RESERVED5
	Reserved.
	*/
	static RESERVED5 := 0x800

	/*
	Field: NO_CUSTOM_MARSHAL
	Specify if you want the activation to fail if it uses custom marshalling.
	*/
	static NO_CUSTOM_MARSHAL := 0x1000

	/*
	Field: ENABLE_CODE_DOWNLOAD
	Enables the downloading of code from the directory service or the Internet. This flag cannot be set at the same time as <NO_CODE_DOWNLOAD>.
	*/
	static ENABLE_CODE_DOWNLOAD := 0x2000

	/*
	Field: NO_FAILURE_LOG
	Can be used to override the logging of failures in CoCreateInstanceEx.
	*/
	static NO_FAILURE_LOG := 0x4000

	/*
	Field: DISABLE_AAA
	Disables activate-as-activator (AAA) activations for this activation only.
	*/
	static DISABLE_AAA := 0x8000

	/*
	Field: ENABLE_AAA
	Enables activate-as-activator (AAA) activations for this activation only.
	*/
	static ENABLE_AAA := 0x10000

	/*
	Field: FROM_DEFAULT_CONTEXT
	Begin this activation from the default context of the current apartment.
	*/
	static FROM_DEFAULT_CONTEXT := 0x20000

	/*
	Field: ACTIVATE_32_BIT_SERVER
	Activate or connect to a 32-bit version of the server; fail if one is not registered.
	*/
	static ACTIVATE_32_BIT_SERVER := 0x40000

	/*
	Field: ACTIVATE_64_BIT_SERVER
	Activate or connect to a 64 bit version of the server; fail if one is not registered.
	*/
	static ACTIVATE_64_BIT_SERVER := 0x80000

	/*
	Field: ENABLE_CLOAKING
	*Windows Vista or later:* When this flag is specified, COM uses the impersonation token of the thread, if one is present, for the activation request made by the thread. When this flag is not specified or if the thread does not have an impersonation token, COM uses the process token of the thread's process for the activation request made by the thread.
	*/
	static ENABLE_CLOAKING := 0x100000

	/*
	Field: PS_DLL
	*[TBD]*
	*/
	static PS_DLL := 0x80000000

	/*
	Field: VALID_MASK
	A combination of all (not reserved) flags.
	*/
	static VALID_MASK := CLSCTX.INPROC_SERVER
					| CLSCTX.INPROC_HANDLER
					| CLSCTX.LOCAL_SERVER
					| CLSCTX.INPROC_SERVER16
					| CLSCTX.REMOTE_SERVER
					| CLSCTX.NO_CODE_DOWNLOAD
					| CLSCTX.NO_CUSTOM_MARSHAL
					| CLSCTX.ENABLE_CODE_DOWNLOAD
					| CLSCTX.NO_FAILURE_LOG
					| CLSCTX.DISABLE_AAA
					| CLSCTX.ENABLE_AAA
					| CLSCTX.FROM_DEFAULT_CONTEXT
					| CLSCTX.ACTIVATE_32_BIT_SERVER
					| CLSCTX.ACTIVATE_64_BIT_SERVER
					| CLSCTX.ENABLE_CLOAKING
					| CLSCTX.PS_DLL

	/*
	Field: INPROC
	Combines <INPROC_SERVER> and <INPROC_HANDLER>.
	*/
	static INPROC := CLSCTX.INPROC_SERVER|CLSCTX.INPROC_HANDLER

	/*
	Field: ALL
	Indicates all class contexts. This is a combination of <INPROC_SERVER>, <INPROC_HANDLER>, <LOCAL_SERVER> and <REMOTE_SERVER>.
	*/
	static ALL := CLSCTX.INPROC_SERVER|CLSCTX.INPROC_HANDLER|CLSCTX.LOCAL_SERVER|CLSCTX.REMOTE_SERVER

	/*
	Field: SERVER
	Indicates server code, whether in-process, local, or remote. This is a combination of <INPROC_SERVER>, <LOCAL_SERVER> and <REMOTE_SERVER>.
	*/
	static SERVER := CLSCTX.INPROC_SERVER|CLSCTX.LOCAL_SERVER|CLSCTX.REMOTE_SERVER
}