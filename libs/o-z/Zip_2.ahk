Zip(FilesToZip,sZip) {
 (!FileExist(sZip)) && CreateZipFile(sZip)
 psh := ComObjCreate("Shell.Application"), pzip := psh.Namespace(sZip)
 For fileNum, file in StrSplit(FilesToZip, "`n")
  If (fileNum > 1) {
   zipped++
   ToolTip, Zipping %file%
   pzip.CopyHere(dir "\" file, 4|16)
   Loop
    If (zipped = done := pzip.items().Count)
     Break
   done := -1
  } Else dir := file
 ToolTip
}
