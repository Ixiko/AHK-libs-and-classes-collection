FE_load(autobuild=false)
{
   Global FE_Autobuild

   FE_Autobuild := autobuild
   Run, regsvr32 "%A_ScriptDir%\FEShlExt.dll" /s
}

FE_unload()
{
   Run, regsvr32 "%A_ScriptDir%\FEShlExt.dll" /u /s
}

FE_addItem(id,parent,submenu,application,parameters,caption,hint,iconfile,iconindex,checked,filetype)
{
   Global

   itemCnt++

   item[%id%] := itemCnt
   item[%itemCnt%]ID := id

   if parent is not integer
   {
      parent := item[%parent%]
   }

   item[%itemCnt%]Parent := Parent
   item[%itemCnt%]Application := Application
   item[%itemCnt%]Parameters := Parameters
   item[%itemCnt%]Caption := Caption
   item[%itemCnt%]Hint := Hint
   item[%itemCnt%]IconFile := IconFile
   item[%itemCnt%]IconIndex := IconIndex
   item[%itemCnt%]Checked := Checked
   item[%itemCnt%]FileType := FileType
   item[%itemCnt%]SubMenu := SubMenu

   if FE_Autobuild
      FE_buildMenu()

   return % itemCnt
}

FE_deleteItem(id)
{
   Global

   no := item[%id%]
   if no !=
   {
      Loop, % itemCnt - no
      {
         i := A_Index + no
         j := i-1

         FE_int_copyItem(i,j)
      }

      itemCnt--
   }

   if FE_Autobuild
      FE_buildMenu()
}

FE_int_copyItem(from,to)
{
   Global
   local tList

   tList = ID,Parent,Application,Parameters,Caption,Hint,IconFile,IconIndex,Checked,FileType,SubMenu
   Loop, parse, tList, `,
   {
      it := item[%from%]%A_LoopField%
      item[%to%]%A_LoopField% := it
   }
}

FE_addCustomSetting(option,value)
{
   Global

   csCnt++

   cs[%csCnt%]Option := option
   cs[%csCnt%]Value := value

   if FE_Autobuild
      FE_buildMenu()
}

FE_addDebugSetting(option,value)
{
   Global

   dsCnt++

   ds[%dsCnt%]Option := option
   ds[%dsCnt%]Value := value

   if FE_Autobuild
      FE_buildMenu()
}

FE_buildMenu()
{
   Global
   local iniFile, i, section, tList, tOption, tValue

   iniFile = %A_ScriptDir%\FastExplorer.ini
   FileDelete, %iniFile%

   section = Dynamic Items
   Loop, %itemCnt%
   {
      i := A_Index
      tList = Parent,Application,Parameters,Caption,Hint,IconFile,IconIndex,Checked,FileType,SubMenu
      Loop, parse, tList, `,
      {
         it := item[%i%]%A_LoopField%

         IniWrite, %it%, %iniFile%, %section%, %A_LoopField%%i%
      }
   }
   IniWrite, %itemCnt%, %iniFile%, %section%, Count
   section = Custom-drawn Menu Properties
   Loop, %csCnt%
   {
      i := A_Index

      tOption := cs[%i%]Option
      tValue := cs[%i%]Value

      IniWrite, %tValue%, %iniFile%, %section%, %tOption%
   }

   section = Debug Options
   Loop, %dsCnt%
   {
      i := A_Index

      tOption := ds[%i%]Option
      tValue := ds[%i%]Value

      IniWrite, %tValue%, %iniFile%, %section%, %tOption%
   }

}