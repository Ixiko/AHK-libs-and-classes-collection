; ahk: console
class RCopy
{
    static CV_YEAR4 := "%y4%"
    static CV_YEAR2 := "%y2%"
    static CV_MONTH := "%m%"
    static CV_DAY := "%d%"
    static CV_X := "%x%"
    static CV_Y := "%y%"
    static CV_PCT := "%%"

	static options := RCopy.set_defaults()
    static context_vars := RCopy.set_context_vars()

	set_defaults() ; IDEA: Rename to InitDefaults()
    {
		return { dest: RegExReplace(A_MyDocuments
                , "\\Documents$"
                , "\Pictures\Camera Roll")
            , rename_as: ""
            , source: ""
            , start_with: 1
            , dry_run: false
            , file_types: [".*\.jpe?g"
                , ".*\.tiff?"
                , ".*\.orf"
                , ".*\.dng"]
            , verify: false
            , help_context_vars: false
            , help_file_types: false
            , help: false }
	}

    set_context_vars() ; IDEA: Rename to InitCtxVars()
    {
        return { RCopy.CV_YEAR4: { value: "YYYY"
                , desc: "4-digit year of creation date of the source file" }
            , RCopy.CV_YEAR2:  { value: "YY"
                , desc: "2-digit year of creation date of the source file" }
            , RCopy.CV_MONTH: { value: "MM"
                , desc: "2-digit month of creation date of the source file" }
            , RCopy.CV_DAY: { value: "DD"
                , desc: "2-digit day of creation date of the source file" }
            , RCopy.CV_X: { value: 1
                , desc: "Sequence number which will be increased by every file "
                . "processed (use e.g. %00x% to create 3 digits with leadings "
                . "zeroes). Start value is 1 but can be changed by "
                . "'--start-with' option" }
            , RCopy.CV_Y: { value: 0
                , desc: "Number of files to import (use e.g. %00y% to create "
                . "3 digits with leading zeroes)."}
            , RCopy.CV_PCT: { value: "%"
                , desc: "Insert a single `%` character" } }
    }

    SetupSourcePath(source_path)
    {
        _log := new Logger("class." A_ThisFunc)

        TestCase.Assert(source_path <> "", "Specify source", "error")

        if (RegExMatch(source_path, "(\.|\*|\*\.|\*\.\*|\.\\\*)$"))
        {
            RCopy.options.source := source_path
        }
        else
        {
            is_dir := InStr(FileExist(source_path), "D") > 0
            if (is_dir)
            {
                RCopy.options.source := source_path "\*.*"
            }
            else
            {
                SplitPath source_path, name, dir
                RCopy.options.source := (dir <> "" ? dir "\" : "")
                    . (name <> "" ? name : "*.*")
            }
        }

        return _log.Exit()
    }

    SetupTargetPath()
    {
        _log := new Logger("class." A_ThisFunc)

        if (RCopy.options.dest)
        {
            dest_dir := RCopy.UseContext(RCopy.options.dest)
            target_path := dest_dir . (SubStr(dest_dir, 0) = "\" ? "" : "\")
        }

        return _log.Exit(target_path)
    }

    CopyAndRename()
    {
        _log := new Logger("class." A_ThisFunc)

        Ansi.WriteLine("Copy from: " RCopy.options.source)
        Ansi.WriteLine("       to: " RCopy.options.dest)

        fn_list := [], fn_discarded := []
        RCopy.CollectFilenames(fn_list, fn_discarded)
        Ansi.Write("`nFound %s %s, "
            .printf((fn_list.MaxIndex() = "" ? ["no", "files"]
                : fn_list.MaxIndex() = 1 ? ["1", "file"]
                : [fn_list.MaxIndex(), "files"])))
        Ansi.Write("discarded %s %s."
            .printf((fn_discarded.MaxIndex() = "" ? ["no", "files"]
                : fn_discarded.MaxIndex() = 1 ? ["1", "file"]
                : [fn_discarded.MaxIndex(), "files"])))

        Ansi.WriteLine("", true)
        for i, file in fn_list
        {
            RCopy.FillFileContext(file.name, file.create_time)
            target_dir := RCopy.SetupTargetPath()

            if (RCopy.options.rename_as)
            {
                pattern := RCopy.UseContext(RCopy.options.rename_as)
                    . "." file.ext
            }
            else
            {
                pattern := file.name
            }
            Ansi.WriteLine(file.name " ... " target_dir pattern, true)
            RCopy.IncreaseSequenceContext()
        }

        return _log.Exit()
    }

    CollectFilenames(ByRef passed_files, ByRef discarded_files)
    {
        _log := new Logger("class." A_ThisFunc)

        md5sum := ""
        passed_files := [], discarded_files := []
        loop files, % RCopy.options.source
        {
            if (RegExMatch(A_LoopFileName, RCopy.FtExpr()))
            {
                if (RCopy.options.verify)
                {
                    md5sum := RCopy.FileMD5(A_LoopFileFullPath)
                }
                passed_files.Push({ name: A_LoopFileName
                    , create_time: A_LoopFileTimeCreated
                    , ext: A_LoopFileExt
                    , csum: md5sum })
            }
            else
            {
                discarded_files.Push(A_LoopFileName)
            }
        }
        RCopy.context_vars[RCopy.CV_Y].value := passed_files.MaxIndex()

        return _log.Exit()
    }

    FileMD5(file_name)
    {
        _log := new Logger("class." A_ThisFunc)

        file := FileOpen(file_name, "r")
        FileGetSize size, %file_name%
        size := file.RawRead(content, size)
        file.Close()

        return _log.Exit(Crypto.MD5.Encode(content, size))
    }

    UseContext(name) ; IDEA: Rename to UseCtx
    {
        _log := new Logger("class." A_ThisFunc)

        p := 1
        loop
        {
            if (p := RegExMatch(name, "%(d|m|y[24])%", $, p))
            {
                name := name.ReplaceAt(p, StrLen($)
                    , RCopy.context_vars[$].value)
                p += StrLen($)
            }
        }
        until (p = 0)

        p := 1
        loop
        {
            if (p := RegExMatch(name, "%0*([xy])%", $, p))
            {
                name := name.ReplaceAt(p, StrLen($)
                    , (RCopy.context_vars["%"
                    . $1
                    . "%"].value).Pad(String.PAD_NUMBER
                    , StrLen($)-2))
                p += StrLen($)-2
            }
        }
        until (p = 0)

        name := StrReplace(name, RCopy.CV_PCT
            , RCopy.context_vars[RCopy.CV_PCT].value)

        return _log.Exit(name)
    }

    IncreaseSequenceContext() ; IDEA: Rename to IncSeqCtx
    {
        _log := new Logger("class." A_ThisFunc)

        RCopy.context_vars[RCopy.CV_X].value += 1

        return _log.Exit()
    }

    FillFileContext(filename, create_timstamp) ; IDEA: Rename to FillFileCtx
    {
        _log := new Logger("class." A_ThisFunc)

        FormatTime year, %create_timstamp%, yyyy
        FormatTime year2, %create_timstamp%, yy
        FormatTime month, %create_timstamp%, MM
        FormatTime day, %create_timstamp%, dd

        RCopy.context_vars[RCopy.CV_YEAR4].value := year
        RCopy.context_vars[RCopy.CV_YEAR2].value := year2
        RCopy.context_vars[RCopy.CV_MONTH].value := month
        RCopy.context_vars[RCopy.CV_DAY].value := day

        return _log.Exit()
    }

    ListContextVars() ; IDEA: Rename to ListCtxVars()
    {
        _log := new Logger("class." A_ThisFunc)

        dt := new DataTable()
        dt.DefineColumn(new DataTable.Column(10))
        dt.DefineColumn(new DataTable.Column.Wrapped(60))
        for pattern, context_var in RCopy.context_vars
        {
            dt.AddData([ pattern, context_var.desc ])
        }
        Ansi.WriteLine("`n" dt.GetTableAsString(), true)

        return _log.Exit()
    }

    ListFileTypes()
    {
        _log := new Logger("class." A_ThisFunc)

        Ansi.WriteLine()
        for i, file_type_expr in RCopy.options.file_types
        {
            Ansi.WriteLine(file_type_expr)
        }
        Ansi.WriteLine(,true)

        return _log.Exit()
    }

    FtExpr()
    {
        _log := new Logger("class." A_ThisFunc)

        ft_expr := ""
        for i, file_type in RCopy.options.file_types
        {
            ft_expr .= (ft_expr = "" ? "" : "|") file_type
        }

        return _log.Exit("i)^(" ft_expr ")$")
    }

	CLI()
    {
		_log := new Logger("class." A_ThisFunc)

        op := new OptParser("RCopy: [options] <source>",, "RCOPY_OPTS")
        op.Add(new OptParser.Line("source"
            , "Path and/or file pattern. Only supported file types will be "
            . "copied, regardless of a given file pattern`n"))
        op.Add(new OptParser.Group("Available options"))
        op.Add(new OptParser.String("d", "dest", RCopy.options
            , "dest", "dir"
            , "Destination directory. Context variables my be used"
            , OptParser.OPT_ARG, RCopy.options.dest, RCopy.options.dest))
        op.Add(new OptParser.Line("", "(Default: " RCopy.options.dest ")"))
        op.Add(new OptParser.String("r", "rename-as", RCopy.options
            , "rename_as", "pattern"
            , "Define a pattern to create the file name for the copied file. "
            . "Context variables may be used (Default: name of the original "
            . "file)"))
        op.Add(new OptParser.String(0, "start-with", RCopy.options
            , "start_with", "number"
            , "Number to begin numbering with"
            , OptParser.OPT_ARG
            , RCopy.options.start_with, RCopy.options.start_with))
        op.Add(new OptParser.String(0, "add-ft-expr", RCopy.options
            , "file_types", "expr"
            , "Add expression to select more file types"
            , OptParser.OPT_ARG | OptParser.OPT_MULTIPLE
            , RCopy.options.file_types, RCopy.options.file_types))
        op.Add(new OptParser.Boolean("v", "verify", RCopy.options
            , "verify"
            , "Verify if the files have been properly copied"))
        op.Add(new OptParser.Boolean(0, "dry-run", RCopy.options
            , "dry_run"
            , "Run without performing any file operation"))
        op.Add(new OptParser.Boolean(0, "help-context-vars", RCopy.options
            , "help_context_vars"
            , "Show available context variables"))
        op.Add(new OptParser.Boolean(0, "help-file-types", RCopy.options
            , "help_file_types"
            , "Show supported file types"))
        op.Add(new OptParser.Line("--[no]env", "Ignore environment variable "
            . op.stEnvVarName))
		op.Add(new OptParser.Boolean("h", "help", RCopy.options
            , "help"
            , "Display usage", OptParser.OPT_HIDDEN))

		return _log.Exit(op)
	}

	Run(args)
    {
		_log := new Logger("class." A_ThisFunc)

		if (_log.Logs(Logger.Input))
        {
			_log.Input("args", args)
            _log.Logs(Logger.Finest, "args:`n" LoggingHelper.Dump(args))
		}

		try
        {
			rc := 1
			op := RCopy.CLI()
			args := op.Parse(args)
			if (RCopy.options.help)
            {
				Ansi.WriteLine(op.Usage())
				rc := ""
            }
            else if (RCopy.options.help_context_vars)
            {
                RCopy.ListContextVars()
                rc := ""
            } else if (RCopy.options.help_file_types)
            {
                RCopy.ListFileTypes()
                rc := ""
            }
            else
            {
                if (args.MaxIndex() > 1)
                {
                    throw _log.Exit(Exception("Too many arguments"))
                }
                RCopy.SetupSourcePath(args[1])
                RCopy.context_vars[RCopy.CV_X].value := RCopy.options.start_with
                RCopy.CopyAndRename()
            }
		}
        catch e
        {
			_log.Fatal(e.message)
			Ansi.WriteLine(e.message)
			Ansi.WriteLine(op.Usage())
			rc := 0
		}

		return _log.Exit(rc)
	}
}

#NoEnv                                      ; NOTEST-BEGIN
#include <logging>
#include <system>
#include <ansi>
#include <datatable>
#include <string>
#include <optparser>
#include <testcase>
#include <crypto>

Main:
_main := new Logger("app.RCopy.label.main")
exitapp _main.Exit(RCopy.Run(System.vArgs))	; NOTEST-END
