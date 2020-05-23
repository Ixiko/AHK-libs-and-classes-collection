/*
CopyDirStructure()

Copies a directory structure
(copies a folder along with all its subfolders - but not files)

parameters:
   _inpath - absolute path to the folder that will be copied
   _outpath - absolute path to the destination folder
   _i - whether to include the top folder (true/false)

return:
   1 if there was a problem, none otherwise

gahks - 2011 - GNU GPL v3
*/
CopyDirStructure(_inpath,_outpath,_i=true) {
   if (_i) {
      SplitPath, _inpath,,_indir
      _indir := SubStr(_indir, Instr(_indir,"\",false,0)+1,(StrLen(_indir)-Instr(_indir,"\",false,0)))
      _outpath := _outpath (SubStr(_outpath,0,1)="\" ? "" : "\") _indir
      FileCreateDir, %_outdir%
      if errorlevel
         return errorlevel
   }
   Loop, %_inpath%\*.*, 2, 1
   {
      StringReplace, _temp, A_LoopFileLongPath, %_inpath%,,All
      FileCreateDir, %_outpath%\%_temp%
      if errorlevel
         _problem = 1
   }
   return _problem
}   