; Title:   	NewItem - Create new files or folders
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=86090
; Author:
; Date:
; for:     	AHK_L

/*
Below is a function and associated class that you can use to create new items or folders. It lets you access the functionality of the "ShellNew" menu (the menu you get if you right-click in a folder and select "New" from the context menu). It's designed to let you create a new folder, an empty file, or a new file from a pre-existing template. The function calls the Item method of the New class (included), which is an implementation of the IFileOperation::SetOperationFlags, IFileOperation::NewItem, and IFileOperation::PerformOperations methods combined with the IFileOperationProgressSink::PostNewItem method. This allows the function to return the path of the item that is actually created, which may be different than the path specified by the input parameters, depending on whether an item by the same name already exists. See the documentation in the function for more details.

*/

; ===============================================================================================================================
; NewItem(Name, DestinationFolder := "", TemplateName := "", FileAttributes := 0x20, OperationFlags := 0x0440)
; Function:       Creates a new item (file or folder) in the specified destination folder.
; Parameters:     - Name - String containing the name of the file or folder to be created, including the extension (if any).
;                 - DestinationFolder (Optional) - String containing the absolute path of the destrination folder. If blank or
;                   omitted, it defaults to A_WorkingDir. If the folder doesn't exist, an exception is thrown.
;                 - TemplateName (Optional) - String containing the name or path of a pre-existing template file. If only a name
;                   is specified, the function will look for the file in the following folders (in order of precedence):
;                      - A_AppData "\Microsoft\Windows\Templates"
;                      - A_AppDataCommon "\Microsoft\Windows\Templates"
;                      - A_WinDir "\shellnew"
;                   If blank, omitted, or non-existent, no template will be used.
;                 - FileAttributes (Optional) - A bitwise value that specifies the file system attributes for the file or folder.
;                   If omitted, a regular file will be created, i.e. a file with the FILE_ATTRIBUTE_ARCHIVE (0x20) attribute.
;                   When creating a folder, use 0x10 (FILE_ATTRIBUTE_DIRECTORY) instead. See [REF1] for more information.
;                 - OperationFlags (Optional) - Flags that controls the file operation. If omitted, it defaults to
;                   FOF_ALLOWUNDO (0x0040) | FOF_NOERRORUI (0x0400). See [REF2] for more information.
; Return values:  If the operation is successful, the function returns a string containing the path of the file that was created.
;                 The name of the new file may be different than the specified name depending on whether an item by the same name
;                 already exists. Otherwise, the function returns a blank, e.g. if the user doesn't have sufficient priviledges to
;                 create the item in the destination folder.
; Global vars:    None
; Dependencies:   New class (included)
; Requirements:   Windows Vista+ and AHK v1.0.47+
; Tested with:    AHK 1.1.33.02 (A32/U32/U64)
; Tested on:      Win 10 Pro (Build 18362)
; Written by:     iPhilip
; Forum link:     https://www.autohotkey.com/boards/viewtopic.php?f=6&t=86090
; References:     1. https://docs.microsoft.com/en-us/windows/win32/fileio/file-attribute-constants
;                 2. https://docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-ifileoperation-setoperationflags
;                 3. https://docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-ifileoperation-newitem
;                 4. https://docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-ifileoperation-performoperations
; ===============================================================================================================================

NewItem(Name, DestinationFolder := "", TemplateName := "", FileAttributes := 0x20, OperationFlags := 0x0440) {
   return New.Item(Name, DestinationFolder, TemplateName, FileAttributes, OperationFlags)
}

class New
{
   Item(Name, DestinationFolder := "", TemplateName := "", FileAttributes := 0x20, OperationFlags := 0x0440) {
      static pIID_IShellItem := New.IIDFromString("{43826d1e-e718-42ee-bc55-a1e261c37bfe}")  ; ShObjIdl_core.h
      static CLSID_FileOperation := "{3ad05575-8857-4850-9277-11b85bdb8e09}"  ; ShObjIdl_core.h
      static IID_IFileOperation := "{947aab5f-0a5c-4c13-b4d6-4bf7836fc9f8}"  ; ShObjIdl_core.h
      static pIFileOperationProgressSink := New.CreateIFileOperationProgressSink()

      New.Name := "", pIShellItem := 0, DestinationFolderPath := DestinationFolder ? DestinationFolder : A_WorkingDir
      if DllCall("Shell32\SHCreateItemFromParsingName", "WStr", DestinationFolderPath, "Ptr", 0, "Ptr", pIID_IShellItem, "Ptr*", pIShellItem, "UInt")
         throw Exception("Destination folder does not exist.", -1, DestinationFolderPath)

      pIFileOperation   := ComObjCreate(CLSID_FileOperation, IID_IFileOperation)
      VTable            := NumGet(pIFileOperation + 0, "Ptr")
      SetOperationFlags := NumGet(VTable +  5 * A_PtrSize, "Ptr")  ; IFileOperation::SetOperationFlags
      NewItem           := NumGet(VTable + 20 * A_PtrSize, "Ptr")  ; IFileOperation::NewItem
      PerformOperations := NumGet(VTable + 21 * A_PtrSize, "Ptr")  ; IFileOperation::PerformOperations

      DllCall(SetOperationFlags, "Ptr",  pIFileOperation, "UInt", OperationFlags, "UInt")
      DllCall(NewItem, "Ptr", pIFileOperation, "Ptr", pIShellItem, "UInt", FileAttributes, "WStr", Name, "WStr", TemplateName, "Ptr", pIFileOperationProgressSink, "UInt")
      DllCall(PerformOperations, "Ptr",  pIFileOperation, "UInt")

      ObjRelease(pIShellItem)
      ObjRelease(pIFileOperation)

      return New.Name ? DestinationFolderPath "\" New.Name : ""
   }

   ; Helper methods

   IIDFromString(String) {
      static IID
      VarSetCapacity(IID, 16)
      DllCall("Ole32\IIDFromString", "WStr", String, "Ptr", &IID, "UInt")
      return &IID
   }

   CreateIFileOperationProgressSink() {
      static IFileOperationProgressSink
      VarSetCapacity(IFileOperationProgressSink, 20 * A_PtrSize)
      NumPut(&IFileOperationProgressSink + A_PtrSize, IFileOperationProgressSink, "Ptr")
      Loop, Parse, % "3111246575735483111"
         NumPut(RegisterCallback(New.IFileOperationProgressMonitor, "Fast", A_LoopField, A_Index), IFileOperationProgressSink, A_Index * A_PtrSize, "Ptr")
      return &IFileOperationProgressSink
   }

   IFileOperationProgressMonitor(params*) {
      if (A_EventInfo = 15)  ; IFileOperationProgressSink::PostNewItem
         if !NumGet(params + 5 * A_PtrSize, "UInt")  ; hrNew
            New.Name := StrGet(NumGet(params + 2 * A_PtrSize, "Ptr"), "UTF-16")  ; pszNewName
   }
}