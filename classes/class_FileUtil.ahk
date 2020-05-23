class FileUtil {

	static void := FileUtil._init()

	_init() {
	}

	__New() {
		throw Exception( "FileUtil is a static class, dont instante it!", -1 )
	}

	getDir( path ) {
		path := RegExReplace( path, "^(.*?)\\$", "$1" )
		if( this.isDir(path) )
			return path
		return this.getParentDir( path )
	}

	getParentDir( path ) {
		path := RegExReplace( path, "^(.*?)\\$", "$1" )
		path := RegExReplace( path, "^(.*)\\.+?$", "$1" )
		return path
	}

	getExt( filePath ) {
		SplitPath, % filePath, fileName, fileDir, fileExtention, fileNameWithoutExtension, DriveName
		StringLower, fileExtention, fileExtention
		return fileExtention
	}

  /**
  * File extention is matched width extentionPattern
  *
  * @param {string} filePath
  * @param {string} extentionPattern 
  * @exmaple
  *   FileUtil.isExt("cue|mdx")
  */
	isExt( filePath, extentionPattern ) {

		IfNotExist %filePath%
			return false

		if ( RegExMatch( filePath, "i).*\.(" extentionPattern ")$" ) ) {
			return true
		} else {
			return false
		}

	}
	
	getFileName( filePath, withExt:=true ) {
		filePath := RegExReplace( filePath, "^(.*?)\\$", "$1" )
		SplitPath, filePath, fileName, fileDir, fileExtention, fileNameWithoutExtension, DriveName
		if( withExt == true )
			return fileName
		return fileNameWithoutExtension
	}
	
	getFiles( path, pattern=".*", includeDir=false, recursive=false ) {
		
		files := []

		if ( this.isFile(path) ) {
			if RegExMatch( path, pattern )
				files.Insert( path )

		} else {

		currDir := this.getDir( path )
			Loop, %currDir%\*, % includeDir, % recursive
			{
					if not RegExMatch( A_LoopFileFullPath, pattern )
						continue
					files.Insert( A_LoopFileFullPath )        	
			}

			this._sortArray( files )

		}
		
		return files
		
	}

	getFile( pathDirOrFile, pattern=".*" ) {

		if ( pathDirOrFile == "" or this.isFile(pathDirOrFile) )  {
			return pathDirOrFile
		}

        files := this.getFiles( pathDirOrFile, pattern )

        if ( files.MaxIndex() > 0 ) {
        	return files[ 1 ]
        }

        return ""

	}
	
	isDir( path ) {
		if( ! this.exist(path) )
			return false
		FileGetAttrib, attr, %path%
		Return InStr( attr, "D" )
	}
	
	isFile( path ) {
		if( ! this.exist(path) )
			return false
		FileGetAttrib, attr, %path%
		Return ! InStr( attr, "D" )
	}

	readProperties( path ) {

		prop := []

		Loop, Read, %path%
		{

			If RegExMatch(A_LoopReadLine, "^#.*" )
				continue

			splitPosition := InStr(A_LoopReadLine, "=" )

			If ( splitPosition = 0 ) {
				key := A_LoopReadLine
				val := ""
			} else {
				key := SubStr( A_LoopReadLine, 1, splitPosition - 1 )
				val := SubStr( A_LoopReadLine, splitPosition + 1 )
			}
			
			prop[ Trim(key) ] := Trim(val)

		}

		return prop

	}

	makeDir( path ) {
		FileCreateDir, %path%
	}

	makeParentDir( path, forDirectory=true ) {
		if ( forDirectory == true ) {
			parentDir := this.getParentDir( path )
		} else {
			parentDir := this.getDir( path )
		}
		FileCreateDir, % parentDir
	}

	exist( path ) {
		return FileExist( path )
	}

	delete( path, recursive=1 ) {
		if ( this.isFile(path) ) {
			FileDelete, % path
		} else if( this.isDir(path) ) {
			FileRemoveDir, % path, % recursive
		}
	}

	move( src, trg, overwrite=1 ) {
		if ( ! this.exist(src) )
			return
		this.makeParentDir( trg, this.isDir(src) )
		FileMove, % src, % trg, % overwrite
	}

	copy( src, trg, overwrite=1 ) {
		if ( ! this.exist(src) )
			return
		this.makeParentDir( trg, this.isDir(src) )
		if ( this.isDir(src) ) {
			FileCopyDir, % src, % trg, % overwrite
		} else {
			FileCopy, % src, % trg, % overwrite
		}
	}

  /**
  * get file size
  *
  * @param {path} filePath
  * @return size (byte)
  */
	getSize( path ) {
		FileGetSize, size, % path
		return size
	}

  /**
  * get time
  *
  * @param {path} file path
  * @param {witchTime} M: modification time (default), C: creation time, A: last access time
  * @return YYYYMMDDHH24MISS
  */
	getTime( path, whichTime="M" ) {
		FileGetTime, var, % path, % whichTime
		return var
	}

    /**
    * Get Symbolic Link Information
    *
    * @param  filePath   path to check if it is symbolic link
    * @param  srcPath    path to linked by filePath
    * @param  linkType   link type ( file or directory )
    * @return true if filepath is symbolic link
    */
	isSymlink( filePath, ByRef srcPath="", ByRef linkType="" ) {

		IfNotExist, % filePath
			return false

		if RegExMatch(filePath,"^\w:\\?$") ; false if it is a root directory
			return false

		SplitPath, filePath, fn, parentDir

		result := this.cli( "/c dir /al """ (InStr(FileExist(filePath),"D") ? parentDir "\" : filePath) """" )

		if RegExMatch(result,"<(.+?)>.*?\b" fn "\b.*?\[(.+?)\]",m) {
			linkType:= m1, srcPath := m2
			if ( linkType == "SYMLINK" )
  			linkType := "file"
			else if ( linkType == "SYMLINKD" )
  			linkType := "directory"
			return true
		} else {
			return false
		}
	
	}

  /**
  * make symbolic link
  *
  * @param src  source path (real file)
  * @param trg  target path (path to used as link)
  */
  makeLink( src, trg ) {

  	if this.isSymlink( trg ) {
  		this.delete( trg )
  	}

		this.makeParentDir( trg, this.isDir(src) )
		if ( this.isDir(src) ) {
			cmd := "/c mklink /d """ trg """ """ src """"
		} else {
			cmd := "/c mklink /f """ trg """ """ src """"
		}
		this.cli( cmd )

  }

  /**
  * run command and return result
  *
  * @param  command	 command
  * @return command execution result
  */
	cli( command ) {

		dhw := A_DetectHiddenWindows
		DetectHiddenWindows,On
		Run, %ComSpec% /k,,Hide UseErrorLevel, pid
		if not ErrorLevel
		{
			while ! WinExist("ahk_pid" pid)
				Sleep,100
			DllCall( "AttachConsole","UInt",pid )
		}
		DetectHiddenWindows, % dhw

		; debug( "command :`n`t" command )
		shell := ComObjCreate("WScript.Shell")
		try {
			exec := shell.Exec( comspec " " command )
			While ! exec.Status
				sleep, 100
			result := exec.StdOut.readAll()
		}
		catch e
		{
			debug( "error`n" e.what "`n" e.message )
		}
		; debug( "result :`n`t" result )
		DllCall("FreeConsole")
		Process Close, %pid%

		return result

	}

	_sortArray( Array ) {
	  t := Object()
	  for k, v in Array
	    t[RegExReplace(v,"\s")]:=v
	  for k, v in t
	    Array[A_Index] := v
	  return Array
	}

}