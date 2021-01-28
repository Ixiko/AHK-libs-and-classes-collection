; Link:   	; src from http://sites.google.com/site/ahkref/custom-functions/invokeverb
; Author:
; Date:
; for:     	AHK_L

/*


*/

InvokeVerb(path, menu) {
  objShell := ComObjCreate("Shell.Application")
  if InStr(FileExist(path), "D") || InStr(path, "::{") {
      objFolder := objShell.NameSpace(path)
      objFolderItem := objFolder.Self
  } else {
      SplitPath, path, name, dir
      objFolder := objShell.NameSpace(dir)
      objFolderItem := objFolder.ParseName(name)
  }
  objFolderItem.InvokeVerbEx(Menu)
}