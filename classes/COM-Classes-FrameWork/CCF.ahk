/*
HEADER: CCF.ahk
This file is the main file for the framework. It includes all the other files and has some more nice additions. However, it's not strictly required to include it. You might also only include the files you need.

Remarks:
	If you include this, make sure to set the #Include working directory properly before:
	(start code)
	#include %A_ScriptDir%\CCF ; set working dir for #includes
	#include CCF.ahk ; include this file
	(end code)
*/

/*
class: _CCF_Error_Handler_
the base class that includes error handling
*/
#include _CCF_Error_Handler_.ahk

/*
class: CCFramework
the main class
*/
#include CCFramework.ahk

/*
class: Unknown
the base class for all other CCF interface classes
*/
#include Unknown\Unknown.ahk

/*
class: StructBase
a base class for all structure classes
*/
#include Structure Classes\StructBase.ahk

/*
class: CustomDestinationList
a class for managing custom jump lists in Windows7
*/
#include CustomDestinationList\CustomDestinationList.ahk

/*
class: KDC
a constant class containing system-defined jump list categories
*/
#include Constant Classes\KDC.ahk

/*
class: FILE_ATTRIBUTE
a constant class representing file attributes
*/
#include Constant Classes\FILE_ATTRIBUTE.ahk

/*
class: SFGAO
a constant class containing attributes that can be retrieved on a file or folder
*/
#include Constant Classes\SFGAO.ahk

/*
class: SW
a constant class containing flags specifying the show-behaviour of a window
*/
#include Constant Classes\SW.ahk

/*
class: CF
a constant class containing clipboard formats
*/
#include Constant Classes\CF.ahk

/*
class: CLR
a constant class containing special values for COLORREF variables
*/
#include Constant Classes\CLR.ahk

/*
class: DVASPECT
a constant class containing flags used to the desired data r view aspect
*/
#include Constant Classes\DVASPECT.ahk

/*
class: VARENUM
a constant class specifying the type of a variable
*/
#include Constant Classes\VARENUM.ahk

/*
class: FILETIME
a structure class representing the number of 100-nanosecond-intervals since 1601
*/
#Include Structure Classes\FILETIME.ahk

/*
class: POINT
a structure class holding the x- and y-coordinate for a point
*/
#Include Structure Classes\POINT.ahk

/*
class: RECT
a structure class describing a rectangle
*/
#Include Structure Classes\RECT.ahk

/*
class: SIZE
a structure class specifying the size of a rectangle
*/
#Include Structure Classes\SIZE.ahk

/*
class: SYSTEMTIME
a structure class specifying date and time
*/
#Include Structure Classes\SYSTEMTIME.ahk

/*
group: RichEdit management
*/
/*
class: RichEditOLE
class for managing a RichEdit control
*/
#include RichEditOLE\RichEditOLE.ahk

/*
class: RECO
a constant class containing RichEdit clipboard operations
*/
#include Constant Classes\RECO.ahk

/*
class: REO
a constant class containing flags that control a REOBJECT structure
*/
#include Constant Classes\REO.ahk

/*
class: CHARRANGE
a structure class describing a range of characters in the RichEdit control
*/
#Include Structure Classes\CHARRANGE.ahk

/*
class: REOBJECT
a structure class describing an object in a RichEdit control
*/
#Include Structure Classes\REOBJECT.ahk

/*
class: SAFEARRAYBOUND
a structure class describing a COM SafeArray
*/
#Include Structure Classes\SAFEARRAYBOUND.ahk

/*
group: Images
*/
/*
class: ImageList
a class for managing image lists
*/
#include ImageList\ImageList.ahk

/*
class: ImageList2
provides more methods for image lists
*/
#include ImageList2\ImageList2.ahk

/*
class: Picture
a class for managing a picture
*/
#include Picture\Picture.ahk

/*
class: IMAGEINFO
a structure class containing information about an image in an image list
*/
#Include Structure Classes\IMAGEINFO.ahk

/*
class: IMAGELISTDRAWPARAMS
a structure class containing information about an image list draw operation
*/
#Include Structure Classes\IMAGELISTDRAWPARAMS.ahk

/*
class: IMAGELISTSTATS
a structure class containing information about an image list statistics
*/
#Include Structure Classes\IMAGELISTSTATS.ahk

/*
class: PICTDESC
a structure class describing a picture object
*/
#Include Structure Classes\PICTDESC.ahk

/*
class: IDC
a constant class containing system-defined cursors
*/
#include Constant Classes\IDC.ahk

/*
class: IDI
a constant class containing system-defined icons
*/
#include Constant Classes\IDI.ahk

/*
class: OBM
a constant class containing system-defined bitmaps
*/
#include Constant Classes\OBM.ahk

/*
class: ILC
a constant class containing image list creation flags
*/
#include Constant Classes\ILC.ahk

/*
class: ILCF
a constant class containing image list copy flags
*/
#include Constant Classes\ILCF.ahk

/*
class: ILD
a constant class containing image list draw flags
*/
#include Constant Classes\ILD.ahk

/*
class: ILDI
a constant class containing flags for discarding images from an image list
*/
#include Constant Classes\ILDI.ahk

/*
class: ILFIP
a constant class containing flags for setting an image as "current" in an image list
*/
#include Constant Classes\ILFIP.ahk

/*
class: ILGOS
a constant class containing flags for retrieving an image's size
*/
#include Constant Classes\ILGOS.ahk

/*
class: ILIF
a constant class containing constants indicating an image's quality
*/
#include Constant Classes\ILIF.ahk

/*
class: ILR
a constant class containing flags specifying how to apply a mask to an image
*/
#include Constant Classes\ILR.ahk

/*
class: ILS
a constant class containing image list state flags
*/
#include Constant Classes\ILS.ahk

/*
class: PICTUREATTRIBUTES
a constant class containing picture attributes
*/
#include Constant Classes\PICTUREATTRIBUTES.ahk

/*
class: PICTYPE
a constant class indicating the type of a picture
*/
#include Constant Classes\PICTYPE.ahk

/*
group: Audio
*/
/*
class: MMDeviceEnumerator
a class for enumerating devices
*/
#include MMDeviceEnumerator\MMDeviceEnumerator.ahk

/*
class: MMDeviceCollection
represents a collection of devices
*/
#include MMDeviceCollection\MMDeviceCollection.ahk

/*
class: MMDevice
represents an audio device
*/
#include MMDevice\MMDevice.ahk

/*
class: DEVICE_STATE
a constant class indicating the current state of an audio device
*/
#include Constant Classes\DEVICE_STATE.ahk

/*
class: EDataFlow
a constant class indicating the direction in which audio data flows
*/
#include Constant Classes\EDataFlow.ahk

/*
class: ERole
a constant class indicating the role the system has assigned to an audio device
*/
#include Constant Classes\ERole.ahk

/*
group: collections
*/
/*
class: ObjectArray
represents an extensible array of IUnknown-derived instances
*/
#include ObjectArray\ObjectArray.ahk

/*
class: ObjectCollection
provides more methods for IUnknown-derived instance arrays
*/
#include ObjectCollection\ObjectCollection.ahk

/*
group: progress dialogs
*/
/*
class: OperationsProgressDialog
a class for displaying standard system progress dialogs (copy, move, upload, ...)
*/
#include OperationsProgressDialog\OperationsProgressDialog.ahk

/*
class: ProgressDialog
a class for displaying a customized progress dialog
*/
#include ProgressDialog\ProgressDialog.ahk

/*
class: PDOPSTATUS
a constant class containing operation progress dialog's status flags
*/
#include Constant Classes\PDOPSTATUS.ahk

/*
class: PDTIMER
a constant class containing progress dialog timer flags
*/
#include Constant Classes\PDTIMER.ahk

/*
class: PMODE
a constant class containing progress dialog modes
*/
#include Constant Classes\PMODE.ahk

/*
class: PROGDLG
a constant class containing progress dialog flags
*/
#include Constant Classes\PROGDLG.ahk

/*
class: SPACTION
a constant class a progress dialog action
*/
#include Constant Classes\SPACTION.ahk

/*
group: persistent storage
*/
/*
class: Persist
a base class for classes that provide the CLSID of an object that can be stored persistently in the system
*/
#include Persist\Persist.ahk

/*
class: PersistFile
represents a file to be stored on disk
*/
#include PersistFile\PersistFile.ahk

/*
group: property system
*/
/*
class: PropertyStore
manages property values
*/
#include PropertyStore\PropertyStore.ahk

/*
class: PropertyStoreCache
manages property values and states
*/
#include PropertyStoreCache\PropertyStoreCache.ahk

/*
class: PSC
a constant class containing property state flags
*/
#include Constant Classes\PSC.ahk

/*
class: PROPERTYKEY
a structure class identifying a property
*/
#Include Structure Classes\PROPERTYKEY.ahk

/*
group: streams
*/
/*
class: SequentialStream
base class for stream classes
*/
#include SequentialStream\SequentialStream.ahk

/*
class: Stream
a class for managing a stream
*/
#include Stream\Stream.ahk

/*
class: Storage
represents a storage, aka "filesystem in a file"
*/
#include Storage\Storage.ahk

/*
class: EnumSTATSTG
enumerates storage or stream descriptions
*/
#include EnumSTATSTG\EnumSTATSTG.ahk

/*
class: LOCKTYPE
a constant class containing flags that indicate the type of locking requested for a range of bytes
*/
#include Constant Classes\LOCKTYPE.ahk

/*
class: STATFLAG
a constant class controlling a STATSTG structure
*/
#include Constant Classes\STATFLAG.ahk

/*
class: STGC
a constant class containing storage / stream commit flags
*/
#include Constant Classes\STGC.ahk

/*
class: STGM
a constant class specifying storage modes
*/
#include Constant Classes\STGM.ahk

/*
class: STGMOVE
a constant class containing storage move flags
*/
#include Constant Classes\STGMOVE.ahk

/*
class: STGTY
a constant class specifying a storage type
*/
#include Constant Classes\STGTY.ahk

/*
class: STREAM_SEEK
a constant class used to calculate the new seek-pointer location in a stream
*/
#include Constant Classes\STREAM_SEEK.ahk

/*
class: STATSTG
a structure class holdign statistics about a Stream or Storage
*/
#Include Structure Classes\STATSTG.ahk

/*
group: shell
*/
/*
class: ShellItem
represents an "Shell item", such as a file
*/
#include ShellItem\ShellItem.ahk

/*
class: EnumShellItems
enumerates a collection of IShellItems
*/
#include EnumShellItems\EnumShellItems.ahk

/*
class: ShellLinkW
manages shell links (*.lnk files) (Unicode version)
*/
#include ShellLinkW\ShellLinkW.ahk

/*
class: ShellLinkA
manages shell links (*.lnk files) (ANSI version)
*/
#include ShellLinkA\ShellLinkA.ahk

/*
typedef: ShellLink
defines "ShellLink" as the encoding-specific version

Remarks:
	- In v2, this is always ShellLinkW
*/
global ShellLink := ShellLinkW

/*
class: KNOWNFOLDERID
a constant class representing GUIDs (constants) that identify standard folders registered with the system as Known Folders.
*/
#include Constant Classes\KNOWNFOLDERID.ahk

/*
class: SICHINT
a constant class containing ShellItem compare flags
*/
#include Constant Classes\SICHINT.ahk

/*
class: SIGDN
a constant class containing ShellItem display name flags
*/
#include Constant Classes\SIGDN.ahk

/*
class: SLGP
a constant class containing path retrieval flags
*/
#include Constant Classes\SLGP.ahk

/*
class: SLR
a constant class containing flags on how to find a ShellLink's target
*/
#include Constant Classes\SLR.ahk

/*
class: WIN32_FIND_DATA
a structure class containing information about a file found by an API
*/
#Include Structure Classes\WIN32_FIND_DATA.ahk

/*
group: Taskbar
*/
/*
class: TaskbarList
manages some taskbar properties
*/
#include TaskbarList\TaskbarList.ahk

/*
class: TaskbarList2
provides a method for marking a window as full-screen for the shell
*/
#include TaskbarList2\TaskbarList2.ahk

/*
class: TaskbarList3
provides more methods for managing taskbar properties (Win7 features)
*/
#include TaskbarList3\TaskbarList3.ahk

/*
class: TaskbarList4
provides even more methods for the taskbar
*/
#include TaskbarList4\TaskbarList4.ahk

/*
class: STPFLAG
a constant class specifying taskbar tab properties
*/
#include Constant Classes\STPFLAG.ahk

/*
class: TBPFLAG
a constant clas specifying taskbar progress flags
*/
#include Constant Classes\TBPFLAG.ahk

/*
class: THUMBBUTTONFLAGS
a constant class specifying flags for a taskbar thumbnail toolbar button
*/
#include Constant Classes\THUMBBUTTONFLAGS.ahk

/*
class: THUMBBUTTONMASK
a constant class containing flags htat indicate the valid parts of a THUMNNUTTON structure
*/
#include Constant Classes\THUMBBUTTONMASK.ahk

/*
class: THUMBBUTTON
a structure class describing a taskbar thumbnail toolbar button
*/
#Include Structure Classes\THUMBBUTTON.ahk

/*
group: type information
*/
/*
class: Dispatch
implements the IDispatch interface and provides its dynamic-call functionality
*/
#include Dispatch\Dispatch.ahk

/*
class: ProvideClassInfo
provides type information interfaces for a class
*/
#include ProvideClassInfo\ProvideClassInfo.ahk

/*
class: TypeComp
provides type functionality for compilers
*/
#include TypeComp\TypeComp.ahk

/*
class: TypeInfo
provides detailed information on a type
*/
#include TypeInfo\TypeInfo.ahk

/*
class: TypeInfo2
provides even more information on a type
*/
#include TypeInfo2\TypeInfo2.ahk

/*
class: TypeLib
provides functionality for loading type information from a library
*/
#include TypeLib\TypeLib.ahk

/*
class: TypeLib2
provides even more functionality for type libraries
*/
#include TypeLib2\TypeLib2.ahk

/*
class: CALLCONV
a constant class identifying the calling convention used by a member function
*/
#include Constant Classes\CALLCONV.ahk

/*
class: CLSCTX
a constant class indicating execution context
*/
#include Constant Classes\CLSCTX.ahk

/*
class: DESCKIND
a constant class specifying the kind of a type description
*/
#include Constant Classes\DESCKIND.ahk

/*
class: DISPATCHF
a constant class containing invoke flags
*/
#include Constant Classes\DISPATCHF.ahk

/*
class: DISPID
a constant class containing special values used to identify methods, properties etc.
*/
#include Constant Classes\DISPID.ahk

/*
class: MEMBERID
a constant class containing more special values for members
*/
#include Constant Classes\MEMBERID.ahk

/*
class: FUNCFLAG
a constant class containing function attrributes
*/
#include Constant Classes\FUNCFLAG.ahk

/*
class: FUNCKIND
a constant class indicating the kind of a function
*/
#include Constant Classes\FUNCKIND.ahk

/*
class: IDLFLAG
a constant class containing parameter flags
*/
#include Constant Classes\IDLFLAG.ahk

/*
class: IMPLTYPEFLAG
a constant class specifying implementation type flags
*/
#include Constant Classes\IMPLTYPEFLAG.ahk

/*
class: INVOKEKIND
a constant class that specifies the way a function is invoked
*/
#include Constant Classes\INVOKEKIND.ahk

/*
class: LIBFLAGS
a constant class containing type library flags
*/
#include Constant Classes\LIBFLAGS.ahk

/*
class: PARAMFLAGS
a constant class containing parameter flags
*/
#include Constant Classes\PARAMFLAG.ahk

/*
class: REGKIND
a constant class that controls how a type is registered
*/
#include Constant Classes\REGKIND.ahk

/*
class: SYSKIND
a constant class identifying a target operating system
*/
#include Constant Classes\SYSKIND.ahk

/*
class: TYPEFLAG
a constant class holding type flags
*/
#include Constant Classes\TYPEFLAG.ahk

/*
class: TYPEKIND
a constant class specifying the kind of a type
*/
#include Constant Classes\TYPEKIND.ahk

/*
class: VARFLAG
a constant class containing variable flags
*/
#include Constant Classes\VARFLAG.ahk

/*
class: VARKIND
a constant class specifying a variable's kind
*/
#include Constant Classes\VARKIND.ahk

/*
class: ARRAYDESC
a structure class describing an array
*/
#include Structure Classes\ARRAYDESC.ahk

/*
class: CUSTDATA
a structure class representing custom data
*/
#Include Structure Classes\CUSTDATA.ahk

/*
class: CUSTDATAITEM
a structure class representing a custom data item
*/
#Include Structure Classes\CUSTDATAITEM.ahk

/*
class: DISPPARAMS
a structure class containing arguments passed to a method or property
*/
#Include Structure Classes\DISPPARAMS.ahk

/*
class: ELEMDESC
a structure class containing data for a variable, function or function parameter
*/
#Include Structure Classes\ELEMDESC.ahk

/*
class: EXCEPINFO
a structure class containing data about an exception
*/
#Include Structure Classes\EXCEPINFO.ahk

/*
class: FUNCDESC
a structure class describing a function
*/
#Include Structure Classes\FUNCDESC.ahk

/*
class: IDLDESC
a structure class used for transferring s structure element, parameter or return value
*/
#Include Structure Classes\IDLDESC.ahk

/*
class: INTERFACEDATA
a structure class that describes an interface
*/
#Include Structure Classes\INTERFACEDATA.ahk

/*
class: METHODDATA
a structure class describing a method
*/
#Include Structure Classes\METHODDATA.ahk

/*
class: PARAMDATA
a structure class describing a parameter
*/
#Include Structure Classes\PARAMDATA.ahk

/*
class: PARAMDESC
a structure class used for transferring a parameter
*/
#Include Structure Classes\PARAMDESC.ahk

/*
class: PARAMDESCEX
a structure class containing information about a parameter default value
*/
#Include Structure Classes\PARAMDESCEX.ahk

/*
class: TLIBATTR
a structure class containing information about a type library
*/
#Include Structure Classes\TLIBATTR.ahk

/*
class: TYPEATTR
a structure class containing information about a type
*/
#Include Structure Classes\TYPEATTR.ahk

/*
class: TYPEDESC
a structure class describing a type
*/
#Include Structure Classes\TYPEDESC.ahk

/*
class: VARDESC
a structure class describing a variable
*/
#Include Structure Classes\VARDESC.ahk

/*
group: UIAutomation
*/
/*
class: UIAutomationCondition
base interface for conditions
*/
#Include UIAutomationCondition\UIAutomationCondition.ahk

/*
class: UIAutomationNotCondition
represents the negative of another condition
*/
#Include UIAutomationNotCondition\UIAutomationNotCondition.ahk

/*
class: UIAutomationBoolCondition
represents a condition that can either be true or false
*/
#Include UIAutomationBoolCondition\UIAutomationBoolCondition.ahk

/*
class: UIAutomationElementArray
represents an array of UIAutomation elements
*/
#include UIAutomationElementArray\UIAutomationElementArray.ahk