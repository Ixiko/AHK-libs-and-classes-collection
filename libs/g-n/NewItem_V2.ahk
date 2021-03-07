; Title:
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=86090
; Author:
; Date:
; for:     	AHK_L

/*


*/

FileExtensions := ["txt", "ahk", "docx", "xlsx", "pptx"]
CreateMenu(MyMenu := Menu.New(), "MyMenuFunc", FileExtensions)
return

#HotIf WinActive("ahk_class CabinetWClass") OR WinActive("ahk_class Progman") OR WinActive("ahk_class WorkerW")
^n::
{
   global hwnd, MyMenu
   hwnd := WinExist("A")
   MyMenu.Show
}
#HotIf

CreateMenu(MyMenu, FunctionName, Extensions) {
   Item := RegRead("HKEY_CLASSES_ROOT\Folder")
   IconInfo := RegRead("HKEY_CLASSES_ROOT\Folder\DefaultIcon")
   if RegExMatch(IconInfo, "(.*),(\d+)", Match) {
      IconFile := StrReplace(Match[1], "%SystemRoot%", A_WinDir)
      IconNo := Match[2] + 1
   } else
      throw Exception("Unable to extract folder icon information.", -1, IconInfo)
   MyMenu.Add("New &" Item, FunctionName)
   MyMenu.SetIcon("New &" Item, IconFile, IconNo)
   MyMenu.Add

   for , Extension in Extensions {
      try
         Key := RegRead("HKEY_CLASSES_ROOT\." Extension)
      catch
         throw Exception("Invalid extension.", -1, Extension)
      Item := RegRead("HKEY_CLASSES_ROOT\" Key)
      OpenCommand := RegRead("HKEY_CLASSES_ROOT\" Key "\shell\Open\command")
      if (Instr(OpenCommand, '"') = 1)
         if RegExMatch(OpenCommand, '"(.*?)".*', Match)
            IconFile := Match[1]
         else
            throw Exception("Unable to extract executable from open command line.", -1, Extension)
      else
         if RegExMatch(OpenCommand, '(.*?) .*', Match)
            IconFile := StrReplace(Match[1], "%SystemRoot%", A_WinDir)
         else
            throw Exception("Unable to extract executable from open command line.", -1, Extension)
      Item := InStr(Item, "Microsoft") ? SubStr(Item, 1, 10) "&" SubStr(Item, 11) : "&" Item
      MyMenu.Add("New " Item, FunctionName)
      MyMenu.SetIcon("New " Item, IconFile)
   }
}

MyMenuFunc(ItemName, ItemPos, MenuName) {
   global FileExtensions, hwnd
   Name := StrReplace(ItemName, "&") (ItemPos > 2 ? "." FileExtensions[ItemPos - 2] : "")
   DestinationFolder := GetWindowPath(hwnd)
   TemplateName := ItemPos > 2 ? GetTemplateName(Name) : ""
   FileAttributes := ItemPos = 1 ? 0x10 : 0x20  ; FILE_ATTRIBUTE_DIRECTORY = 0x10, FILE_ATTRIBUTE_ARCHIVE = 0x20
   if (NewItemPath := New.Item(Name, DestinationFolder, TemplateName, FileAttributes)) {
      Sleep 100
      SelectItem(hwnd, NewItemPath, 3|4|8)
   } else
      MsgBox('Unable to create "' Name '" in the active window.', , "Iconx")
}

; Gets the path of the window defined by a window handle.

GetWindowPath(hwnd) {
   WinClass := WinGetClass(hwnd)
   if (WinClass = "CabinetWClass") {
      for Window in ComObjCreate("Shell.Application").Windows
         if (Window.hwnd = hwnd)
            return Window.Document.Folder.Self.Path
   } else if (WinClass = "Progman" || WinClass = "WorkerW") {
      return A_Desktop
   } else
      throw Exception("Window must be an Explorer window or the desktop.", -1)
}

; Gets the path of the template, if any, associated with a filename or path.

GetTemplateName(FilenameOrPath) {
   SplitPath FilenameOrPath, , , Extension
   Loop Files, A_AppData "\Microsoft\Windows\Templates\*." Extension
      return A_LoopFilePath
   Loop Files, A_AppDataCommon "\Microsoft\Windows\Templates\*." Extension
      return A_LoopFilePath
   Loop Files, A_WinDir "\shellnew\*." Extension
      return A_LoopFilePath
   try {
      Key := RegRead("HKEY_CLASSES_ROOT\." Extension)
      return RegRead("HKEY_CLASSES_ROOT\." Extension "\" Key "\ShellNew", "FileName")
   }
}

; Select a file on the dekstop or in an Explorer window given the specified name or path.
; References: https://docs.microsoft.com/en-us/windows/win32/shell/folderitem
;             https://docs.microsoft.com/en-us/windows/win32/shell/shellfolderview-selectitem

SelectItem(hwnd, NameOrPath, Flags) {
   WinClass := WinGetClass(hwnd)
   if (WinClass = "CabinetWClass") {
      for Win in ComObjCreate("Shell.Application").Windows {
         if (Win.hwnd = hwnd) {
            Window := Win
            break
         }
      }
   } else if (WinClass = "Progman" || WinClass = "WorkerW") {
      hwnd := BufferAlloc(4)
      ShellWindows := ComObjCreate("Shell.Application").Windows
      Window := ShellWindows.FindWindowSW(0, "", 0x8, ComObject(0x4003, hwnd.ptr), 0x1)
   } else
      throw Exception("Window must be an Explorer window or the desktop.", -1)
   for Item in Window.Document.Folder.Items
      if InStr(Item.Path, NameOrPath)
         return Window.Document.SelectItem(Item, Flags)
}

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
; Requirements:   Windows Vista+ and AHK v2.0-a122-f595abc2+
; Tested with:    AHK 2.0-a122-f595abc2 (U32/U64)
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
   static Item(Name, DestinationFolder := "", TemplateName := "", FileAttributes := 0x20, OperationFlags := 0x0440) {
      static IID_IShellItem := this.IIDFromString("{43826d1e-e718-42ee-bc55-a1e261c37bfe}")  ; ShObjIdl_core.h
      static CLSID_FileOperation := "{3ad05575-8857-4850-9277-11b85bdb8e09}"  ; ShObjIdl_core.h
      static IID_IFileOperation := "{947aab5f-0a5c-4c13-b4d6-4bf7836fc9f8}"  ; ShObjIdl_core.h
      static SetOperationFlags := 5, NewItem := 20, PerformOperations := 21  ; ShObjIdl_core.h
      static IFileOperationProgressSink := this.CreateIFileOperationProgressSink()

      this.Name := "", pIShellItem := 0, DestinationFolderPath := DestinationFolder ? DestinationFolder : A_WorkingDir
      if DllCall("Shell32\SHCreateItemFromParsingName", "WStr", DestinationFolderPath, "Ptr", 0, "Ptr", IID_IShellItem, "Ptr*", pIShellItem, "UInt")
         throw Exception("Destination folder does not exist.", -1, DestinationFolderPath)

      IFileOperation := ComObjCreate(CLSID_FileOperation, IID_IFileOperation)
      ComCall(SetOperationFlags, IFileOperation, "UInt", OperationFlags)
      ComCall(NewItem, IFileOperation, "Ptr", pIShellItem, "UInt", FileAttributes, "WStr", Name, "WStr", TemplateName, "Ptr", IFileOperationProgressSink)
      ComCall(PerformOperations, IFileOperation)
      ObjRelease(pIShellItem)

      return this.Name ? DestinationFolderPath "\" this.Name : ""
   }

   ; Helper methods

   static IIDFromString(String) {
      IID := BufferAlloc(16)
      DllCall("Ole32\IIDFromString", "WStr", String, "Ptr", IID, "UInt")
      return IID
   }

   static CreateIFileOperationProgressSink() {
      IFileOperationProgressSink := BufferAlloc(20 * A_PtrSize)
      NumPut("Ptr", IFileOperationProgressSink.ptr + A_PtrSize, IFileOperationProgressSink)
      Loop Parse, "3111246575735483111"
         NumPut("Ptr", CallbackCreate(ObjBindMethod(this, "IFileOperationProgressMonitor", A_Index), "Fast &", A_LoopField), IFileOperationProgressSink, A_Index * A_PtrSize)
      return IFileOperationProgressSink
   }

   static IFileOperationProgressMonitor(Index, params) {
      if (Index = 15)  ; IFileOperationProgressSink::PostNewItem
         if !NumGet(params, 6 * A_PtrSize, "UInt")  ; hrNew
            this.Name := StrGet(NumGet(params, 3 * A_PtrSize, "Ptr"), "UTF-16")  ; pszNewName
   }
}