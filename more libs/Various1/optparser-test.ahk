; ahk: console
#Warn All, StdOut
#NoEnv
SetBatchLines -1

#Include <testcase-libs>

#Include %A_ScriptDir%\..\optparser.ahk

class OptParserTest extends TestCase {

	@Test_class() {
		this.assertTrue(IsObject(new OptParser()))
		this.assertTrue(IsObject(new OptParser.Group))
		this.assertTrue(IsObject(new OptParser.Option))
		this.assertTrue(IsObject(new OptParser.Boolean))
		this.assertTrue(IsObject(new OptParser.String))
		this.assertTrue(IsObject(new OptParser.Callback))
		this.assertTrue(IsObject(new OptParser.Generic))
	}

	@Test_constants() {
		this.assertEquals(OptParser.OPT_ARG, 1)
		this.assertEquals(OptParser.OPT_OPTARG, 2)
		this.assertEquals(OptParser.OPT_NOARG, 4)
		this.assertEquals(OptParser.OPT_HIDDEN, 8)
		this.assertEquals(OptParser.OPT_MULTIPLE, 16)
		this.assertEquals(OptParser.OPT_NEG, 32)
		this.assertEquals(OptParser.OPT_NEG_USAGE, 64)
		this.assertEquals(OptParser.OPT_ALLOW_SINGLE_DASH, 128)
		this.assertEquals(OptParser.PARSER_ALLOW_DASHED_ARGS, 1)
	}

	@Test_lineClass() {
		; ahklint-ignore-begin: W002
		this.assertEquals(new OptParser.Line("abc", "defghi").usage()
				, "    abc                   defghi")
		this.assertEquals(new OptParser.Line("abc-def-ghi-jkl-mno-pqr-stu"
				, "defghi").usage()
				, "    abc-def-ghi-jkl-mno-pqr-stu`n"
				. "                          defghi")
		this.assertEquals(new OptParser.Line("abc"
				, "foo bar buzz bar buzz bar foo bar foo buzz bar buzz foo bar buzz bar foo").usage()
				, "    abc                   foo bar buzz bar buzz bar foo bar foo buzz bar buzz foo bar`n"
				. "                          buzz bar foo")
		this.assertEquals(new OptParser.Line("abc-def-ghi-jkl-mno-pqr-stu"
				, "foo bar buzz bar buzz bar foo bar foo buzz bar buzz foo bar buzz bar foo").usage()
				, "    abc-def-ghi-jkl-mno-pqr-stu`n"
				. "                          foo bar buzz bar buzz bar foo bar foo buzz bar buzz foo bar`n"
				. "                          buzz bar foo")
		this.assertEquals(new OptParser.Line("abc"
				, "foo bar buzz bar buzz bar foo bar", 10, 20, 2).usage()
				, "  abc     foo bar buzz bar`n"
				. "          buzz bar foo bar")
		this.assertEquals(new OptParser.Line("abc-def-ghi", "foo bar buzz bar foo bar foo", 10, 20, 2).usage()
				, "  abc-def-ghi`n"
				. "          foo bar buzz bar foo`n"
				. "          bar foo")
		; ahklint-ignore-end
	}

	@Test_parse() {
		op := new OptParser("Test")
		this.assertException(op, "Parse", "", "", "string")
		_args := op.parse(["asdf"])
		this.assertEquals(_args[1], "asdf")
	}

	@Test_noArgs() {
		op := new OptParser("Test")
		_args := op.parse([])
		this.assertEmpty(_args.minIndex())
		this.assertEmpty(_args.maxIndex())
	}

	@Test_simple() {
		op := new OptParser("A Test Option Parser")
		this.assertEquals(op.usageText.maxIndex(), 1)
		this.assertEquals(op.usageText[1], "A Test Option Parser")

		op.add(new OptParser.Group("Test options"))
		this.assertEquals(op.optionList.maxIndex(), 1)
		this.assertEquals(op.optionList[1].__Class, "OptParser.Group")
		this.assertEquals(op.optionList[1].description, "Test options")

		opt := {}
		op.add(new OptParser.Boolean("v", "verbose", opt
				, "bVerbose", "Be more verbose"))
		this.assertEquals(op.optionList.maxIndex(), 2)
		this.assertEquals(op.optionList[2].__Class, "OptParser.Boolean")
		this.assertEquals(op.optionList[2].option1Dash, "-v")
		this.assertEquals(op.optionList[2].option2Dashes, "--verbose")
		this.assertEmpty(op.optionList[2].argumentDescription)
		this.assertEquals(op.optionList[2].description, "Be more verbose")
		this.assertEquals(op.optionList[2].flags, OptParser.OPT_NOARG)
		this.assertEquals(op.optionList[2].value, true)
		this.assertEquals(opt.bVerbose, false)
		this.assertEquals(op.usage()
				, "usage: A Test Option Parser`n`nTest options`n    -v, --verbose         Be more verbose`n`n") ; ahklint-ignore: W002

		args := op.parse(["--verbose", "asdf"])
		this.assertEquals(args.maxIndex(), 1)
		this.assertEquals(opt.bVerbose, true)
		this.assertEquals(args[1], "asdf")

		opt.bVerbose := false
		args := op.parse(["-v", "asdf"])
		this.assertEquals(args.maxIndex(), 1)
		this.assertEquals(opt.bVerbose, true)
		this.assertEquals(args[1], "asdf")
	}

	@Test_booleanWithInit() {
		opt := {}
		op := new OptParser("Test")
		op.add(new OptParser.Boolean("v", "verbose", opt
				, "v", "Verbose output",, true))
		op.add(new OptParser.Boolean("q", "quiet", opt
				, "q", "Quiet output"))
		op.parse(["-q"])
		this.assertEquals(opt.v, true)
		this.assertEquals(opt.q, true)
	}

	@Test_stringWithInit() {
		opts := {}
		op := new OptParser("Test")
		op.add(new OptParser.String("s", "string", opts
				, "s", "string", "A string"
				, OptParser.OPT_OPTARG, "123", "123"))
		op.parse([""])
		; op.TrimArg(s)
		this.assertEquals(opts.s, "123")
		op2 := new OptParser("Test")
		op2.add(new OptParser.String("s", "string", opts
				, "s2", "string", "A string"
				, OptParser.OPT_OPTARG, "456", "456"))
		op2.parse(["-s", "abcdefg"])
		; op2.TrimArg(s2)
		this.assertEquals(opts.s2, "abcdefg")
	}

	@Test_multiUsages() {
		op := new OptParser(["The first usage"
				, "The second usage"
				, "The third usage"])
		this.assertEquals(op.usageText.maxIndex(), 3)
		this.assertEquals(op.usageText[1], "The first usage")
		this.assertEquals(op.usageText[2], "The second usage")
		this.assertEquals(op.usageText[3], "The third usage")
		this.assertEquals(op
				.usage(), "usage: The first usage`n   or: The second usage`n   or: The third usage`n`n`n") ; ahklint-ignore: W002
	}

	@Test_bundeledOptions() {
		opts := {}
		op := new OptParser("Test [-a] [-s] [-d] [-f] [<arg>]...")
		op.add(new OptParser.Boolean("a", "", opts
				, "a", "", OptParser.OPT_HIDDEN))
		op.add(new OptParser.Boolean("s", "", opts
				, "s", "", OptParser.OPT_HIDDEN))
		op.add(new OptParser.Boolean("d", "", opts
				, "d", "", OptParser.OPT_HIDDEN))
		op.add(new OptParser.Boolean("f", "", opts
				, "f", "", OptParser.OPT_HIDDEN))
		this.assertEquals(op.optionList.maxIndex(), 4)
		opts.a := false, opts.s := false, opts.d := false, opts.f := false
		op.parse(["-a"])
		this.assertTrue(opts.a = true && opts.s = false
				&& opts.d = false && opts.f = false)
		opts.a := false, opts.s := false, opts.d := false, opts.f := false
		op.parse(["-as"])
		this.assertTrue(opts.a = true && opts.s = true
				&& opts.d = false && opts.f = false)
		opts.a := false, opts.s := false, opts.d := false, opts.f := false
		op.parse(["-asd"])
		this.assertTrue(opts.a = true && opts.s = true
				&& opts.d = true && opts.f = false)
		opts.a := false, opts.s := false, opts.d := false, opts.f := false
		op.parse(["-asdf"])
		this.assertTrue(opts.a = true && opts.s = true
				&& opts.d = true && opts.f = true)
		opts.a := false, opts.s := false, opts.d := false, opts.f := false
		op.parse(["-adfs"])
		this.assertTrue(opts.a = true && opts.s = true
				&& opts.d = true && opts.f = true)
		opts.a := false, opts.s := false, opts.d := false, opts.f := false
		op.parse(["-af"])
		this.assertTrue(opts.a = true && opts.s = false
				&& opts.d = false && opts.f = true)
		opts.a := false, opts.s := false, opts.d := false, opts.f := false
		op.parse(["-af", "-sd"])
		this.assertTrue(opts.a = true && opts.s = true
				&& opts.d = true && opts.f = true)
		opts.a := false, opts.s := false, opts.d := false, opts.f := false
		op.parse(["-s", "-d", "-f", "-a"])
		this.assertTrue(opts.a = true && opts.s = true
				&& opts.d = true && opts.f = true)
		opts.a := false, opts.s := false, opts.d := false, opts.f := false
		args := op.parse(["-asf", "one", "two"])
		this.assertTrue(opts.a = true && opts.s = true
				&& opts.d = false && opts.f = true)
		this.assertTrue(args[1] = "one" && args[2] = "two")
	}

	@Test_bundeledOptions2() {
		opts := {}
		op := new OptParser("Test [-k] [-C[<num>]] arg")
		op.add(new OptParser.Boolean("k", "", opts, "k", ""))
		op.add(new OptParser.String("C", "", opts
				, "C", "", OptParser.OPT_OPTARG, 2, 2))
		op.parse(["-kC"])
		this.assertEquals(opts.k, true)
		this.assertEquals(opts.C, 2)
	}

	@Test_counter() {
		opts := {}
		op := new OptParser("Test <-n>")
		op.add(new OptParser.Counter(opts, "n", "Counter", 0))
		this.assertException(op, "add", "", ""
				, new OptParser.Counter(x := "", "Another Counter", 0))
		op.parse(["-12345"])
		this.assertEquals(opts.n, 12345)
		op.parse(["-12345", "-9876"])
		this.assertEquals(opts.n, 9876)

		opts2 := {}
		op2 := new OptParser("Test 2 <-x>")
		op2.add(new OptParser.Counter(opts2, "x", "Counter", 1))
		op2.parse([-1303])
		this.assertEquals(opts2.x, 1303)

		this.assertException(op2, "add", "", ""
				, new OptParser.Counter(opts2, "n", "Counter", 1))
	}

	@Test_optionalArg() {
		opts := {}
		op := new OptParser("Test [option]")
		op.add(new OptParser.String("s", "test-string", opts
				, "st", "string", "A test string", OptParser.OPT_OPTARG))
		op.parse(["-sasdf"])
		this.assertEquals(opts.st, "asdf")
		op.parse(["-s", "jkloe"])
		this.assertEquals(opts.st, "jkloe")
		op.parse(["-s", "asdf"])
		this.assertEquals(opts.st, "asdf")
		op.parse(["--test-string", "jkloe"])
		this.assertEquals(opts.st, "jkloe")
		op.parse(["--test-string=asdf"])
		this.assertEquals(opts.st, "asdf")
	}

	@Test_requiredArg() {
		opts := {}
		op := new OptParser("Test [option]")
		op.add(new OptParser.String("s", "test-string", opts
				, "st", "string", "A test string", OptParser.OPT_ARG))
		op.parse(["-sasdf"])
		this.assertEquals(opts.st, "asdf")
		op.parse(["-s", "jkloe"])
		this.assertEquals(opts.st, "jkloe")
		op.parse(["-s", "asdf"])
		this.assertEquals(opts.st, "asdf")
		op.parse(["--test-string", "jkloe"])
		this.assertEquals(opts.st, "jkloe")
		op.parse(["--test-string=asdfx"])
		this.assertEquals(opts.st, "asdfx")
		opts.st := ""
		this.assertException(op, "Parse", "", "Missing argument 'string'"
				, ["-s"])
		this.assertException(op, "Parse", "", "Missing argument 'string'"
				, ["--test-string"])
	}

	@Test_invalidArgument() {
		opts := {}
		op := new OptParser("Test [-x]")
		op.add(new OptParser.Boolean("x", "", opts
				, "x", "An X marks the place"))
		op.parse(["-x"])
		this.assertTrue(opts.x)
		this.assertException(op, "Parse", "", "Invalid argument: -y", ["-y"])
	}

	; ahklint-ignore-begin: E001,W002,W003,W004
	@Test_realWorldExample1() {
		stExpectedUsage =
(
usage: git branch [options] [-r | -a] [--merged | --no-merged]
   or: git branch [options] [-l] [-f] <branchname> [<start-point>]
   or: git branch [options] [-r] (-d | -D) <branchname>...
   or: git branch [options] (-m | -M) [<oldbranch>] <newbranch>

Generic options
    -v, --verbose         show hash and subject, give twice for upstream branch
    -q, --quiet           suppress informational messages
    -t, --track           set up tracking mode (see git-pull(1))
    --set-upstream        change upstream info
    -u, --set-upstream-to <upstream>
                          change the upstream info
    --unset-upstream      Unset the upstream info
    --color[=<when>]      use colored output
    -r, --remotes         act on remote-tracking branches
    --contains <commit>   print only branches that contain the commit
    --abbrev[=<n>]        use <n> digits to display SHA-1s

Specific git-branch actions:
    -a, --all             list both remote-tracking and local branches
    -d, --delete          delete fully merged branch
    -D                    delete branch (even if not merged)
    -m, --move            move/rename a branch and its reflog
    -M                    move/rename a branch, even if target exists
    --list                list branch names
    -l, --create-reflog   create the branch's reflog
    --edit-description    edit the description for the branch
    -f, --force           force creation (when already exists)
    --no-merged <commit>  print only not merged branches
    --merged <commit>     print only merged branches
    --column[=<style>]    list branches in columns


)
		opts := {}
		op := new OptParser(["git branch [options] [-r | -a] [--merged | --no-merged]"
						   , "git branch [options] [-l] [-f] <branchname> [<start-point>]"
						   , "git branch [options] [-r] (-d | -D) <branchname>..."
						   , "git branch [options] (-m | -M) [<oldbranch>] <newbranch>"])
		; ahklint-ignore-end
		op.add(new OptParser.Group("Generic options"))
		; TODO: Change here to new implementation requirements by adding an object to hold the cli settings...
		op.add(new OptParser.Boolean("v", "verbose", opts, "v"
				, "show hash and subject, give twice for upstream branch"))
		op.add(new OptParser.Boolean("q", "quiet", opts, "q"
				, "suppress informational messages"))
		op.add(new OptParser.Boolean("t", "track", opts, "t"
				, "set up tracking mode (see git-pull(1))"))
		op.add(new OptParser.Boolean(0, "set-upstream", opts, "su"
				, "change upstream info"))
		op.add(new OptParser.String("u", "set-upstream-to", opts, "suto"
				, "upstream", "change the upstream info"))
		op.add(new OptParser.Boolean(0, "unset-upstream", opts, "usu"
				, "Unset the upstream info"))
		op.add(new OptParser.String(0, "color", opts, "colr", "when"
				, "use colored output", OptParser.OPT_OPTARG))
		op.add(new OptParser.Boolean("r", "remotes", opts, "r"
				, "act on remote-tracking branches"))
		op.add(new OptParser.String(0, "contains", opts, "cnts"
				, "commit", "print only branches that contain the commit"))
		op.add(new OptParser.String(0, "abbrev", opts, "n"
				, "n", "use <n> digits to display SHA-1s"
				, OptParser.OPT_OPTARG))
		op.add(new OptParser.Group("`nSpecific git-branch actions:"))
		op.add(new OptParser.Boolean("a", "all", opts, "a"
				, "list both remote-tracking and local branches"))
		op.add(new OptParser.Boolean("d", "delete", opts, "d"
				, "delete fully merged branch"))
		op.add(new OptParser.Boolean("D", "", opts, "dnm"
				, "delete branch (even if not merged)"))
		op.add(new OptParser.Boolean("m", "move", opts, "m"
				, "move/rename a branch and its reflog"))
		op.add(new OptParser.Boolean("M", "", opts, "mte"
				, "move/rename a branch, even if target exists"))
		op.add(new OptParser.Boolean(0, "list", opts, "l"
				, "list branch names"))
		op.add(new OptParser.Boolean("l", "create-reflog", opts, "crl"
				, "create the branch's reflog"))
		op.add(new OptParser.Boolean(0, "edit-description", opts, "ed"
				, "edit the description for the branch"))
		op.add(new OptParser.Boolean("f", "force", opts, "f"
				, "force creation (when already exists)"))
		op.add(new OptParser.String(0, "no-merged", opts, "nmd"
				, "commit", "print only not merged branches"))
		op.add(new OptParser.String(0, "merged", opts, "md"
				, "commit", "print only merged branches"))
		op.add(new OptParser.String(0, "column", opts, "coln"
				, "style", "list branches in columns", OptParser.OPT_OPTARG))
		this.assertEquals(op.usage(), stExpectedUsage)
		this.assertEquals(op.optionList.maxIndex(), 24)

		op.parse(["-v", "-f", "-D"])
		this.assertEquals(opts.v, true)
		this.assertEquals(opts.q, false)
		this.assertEquals(opts.f, true)
		this.assertEquals(opts.dnm, true)
		this.assertEquals(opts.suto.trimAll(), "")

		gosub #Reset_Fields#
		op.parse(["-Dvf"])
		this.assertEquals(opts.v, true)
		this.assertEquals(opts.q, false)
		this.assertEquals(opts.f, true)
		this.assertEquals(opts.dnm, true)
		this.assertEquals(opts.suto.trimAll(), "")

		gosub #Reset_Fields#
		_args := op.parse(["-uTest", "--merged", "987654", "--color=auto"
				, "--contains", "abcdef", "--abbrev=42", "livebranch"
				, "develbranch"])
		this.assertEquals(opts.suto, "Test")
		this.assertEquals(opts.colr, "auto")
		this.assertEquals(opts.cnts, "abcdef")
		this.assertEquals(opts.n, 42)
		this.assertEquals(opts.md, "987654")
		this.assertEquals(opts.f, false)
		this.assertEquals(opts.coln, "")
		this.assertEquals(_args.maxIndex(), 2)
		this.assertEquals(_args[1], "livebranch")
		this.assertEquals(_args[2], "develbranch")

		gosub #Reset_Fields#
		_args := op.parse(["-v", "--color=auto", "--contains", "abcdef"
				, "abbrev=42", "livebranch", "develbranch"])
		this.assertTrue(opts.v)
		this.assertEquals(opts.colr, "auto")
		this.assertEquals(opts.cnts, "abcdef")
		this.assertEquals(_args.maxIndex(), 3)
		this.assertEquals(_args[1], "abbrev=42")
		this.assertEquals(_args[2], "livebranch")
		this.assertEquals(_args[3], "develbranch")

		return

		; ahklint-ignore-begin: W002
		#Reset_Fields#:
			opts.v := opts.q := opts.su := opts.usu := opts.r := opts.a := opts.d := opts.dnm := opts.m := opts.mte := opts.l := opts.crl := opts.ed := opts.f := false
			opts.suto := opts.colr := opts.cnts := opts.n := opts.nmd := opts.md := opts.coln := ""
		; ahklint-ignore-end
		return
	}

	@Test_optionUsage() {
		; ahklint-ignore-begin: W003,W010
		stExpectedUsage =
(
usage: Test

    -o, --a-very-long-option-string
                          Explanation number one
                          and number two

    -x, --long-self-explaining-option


)
		; ahklint-ignore-end
		opts := {}
		op := new OptParser("Test")
		op.add(new OptParser.Boolean("o", "a-very-long-option-string"
				, opts, "long-opt"
				, ["Explanation number one", "and number two"]))
		op.add(new OptParser.Boolean("x", "long-self-explaining-option"
				, opts))
		op.add(new OptParser.Boolean(0, "hidden", opts, "hidden"
				, "Will not be displayed", OptParser.OPT_HIDDEN))
		this.assertEquals(op.usage(), stExpectedUsage)
	}

	@Test_dashedArgs() {
		op := new OptParser("Test")
		this.assertEquals(op.flags, 0)
		this.assertException(op, "Parse", ""
				, "A remainig argument starts with a dash: -y", ["-y"])
		op := new OptParser("Test 2", OptParser.PARSER_ALLOW_DASHED_ARGS)
		this.assertEquals(op.flags, OptParser.PARSER_ALLOW_DASHED_ARGS)
		ra := op.parse(["-y"])
		this.assertEquals(ra[1], "-y")
	}

	@Test_dashedArgsSingleDash() {
		opts := {}
		op := new OptParser("Test", OptParser.PARSER_ALLOW_DASHED_ARGS)
		op.add(new OptParser.Boolean("h", "help", opts, "_h", "Help"))
		ra := op.parse(["--", "-"])
		this.assertEquals(ra[1], "-")
	}

	@Test_dashedOptionArgsSingleDash() {
		opts := {}
		op := new OptParser("Test", OptParser.PARSER_ALLOW_DASHED_ARGS)
		op.add(new OptParser.String("f", "", opts, "f", "string", "Test"
				, OptParser.OPT_ARGREQ|OptParser.OPT_ALLOW_SINGLE_DASH))
		ra := op.parse(["-f", "-", "--"])
		this.assertEquals(opts.f, "-")
	}

	@Test_callbacks() {
		opts := {}
		op := new OptParser("Test")
		op.add(new OptParser.callback("P", "priority", opts
				, "x", "Test_Func", "Prio", "A priority test", 1))
		this.assertEquals(op.optionList.maxIndex(), 1)
		this.assertEquals(op.optionList[1].__Class, "OptParser.Callback")
		this.assertEquals(op.optionList[1].option1Dash, "-P")
		this.assertEquals(op.optionList[1].option2Dashes, "--priority")
		this.assertEquals(op.optionList[1].pVarRef, opts.getAddress())
		this.assertEquals(op.optionList[1].optionProperty, "x")
		this.assertEquals(op.optionList[1].argumentDescription, "Prio")
		this.assertEquals(op.optionList[1].description, "A priority test")
		this.assertEquals(op.optionList[1].flags, 1)
		this.assertEmpty(op.optionList[1].value)
		this.assertNotEmpty(op.optionList[1].pFunc)
		this.assertEquals(opts.x, "")
		op.parse(["--priority", "high"])
		this.assertEquals(opts.x, 2)
		op.parse(["--priority", "low"])
		this.assertEquals(opts.x, 0)
		op.parse(["--priority", "normal"])
		this.assertEquals(opts.x, 1)
		op.parse(["--priority", "severe"])
		this.assertEquals(opts.x, 1)
		op.parse(["-P", "high"])
		this.assertEquals(opts.x, 2)

		opts := {}
		op := new OptParser("Test")
		this.assertException(OptParser.callback, "__new", "", "", "x", "", opts
				, "x", "Does_not_exist")
	}

	@Test_noOption() {
		opts := {}
		op := new OptParser("Test")
		op.add(new OptParser.Boolean("v", "verbose", opts
				, "v", "show verbose output", OptParser.OPT_NEG, true))
		op.add(new OptParser.Boolean("q", "quiet", opts
				, "q", "quiet output",, true))
		op.parse(["--no-verbose"])
		this.assertEquals(opts.v, false)
		this.assertEquals(opts.q, true)
		opts.v := true
		opts.q := true
		op.parse(["--noverbose"])
		this.assertEquals(opts.v, false)
		this.assertEquals(opts.q, true)
	}

	@Test_noOptionUsage() {
		stExpectedUsage =
		; ahklint-ignore-begin: W010,W003
( Comments
usage: Test

    --[no]env             Ignore environment variable ; ahklint-ignore: W003


)
		; ahklint-ignore-end
		opts := {}
		op := new OptParser("Test")
		op.add(new OptParser.Boolean(0, "env", opts
				, "env", "Ignore environment variable"
				, OptParser.OPT_NEG|OptParser.OPT_NEG_USAGE))
		this.assertEquals(op.usage(), stExpectedUsage)
	}

	@Test_doubleNoOption() {
		opts := {}
		op := new OptParser("Test")
		op.add(new OptParser.Boolean("v", "verbose", opts
				, "v", "show verbose output", OptParser.OPT_NEG, true))
		op.parse(["--no-verbose", "--verbose"])
		this.assertEquals(opts.v, true)
		op.parse(["--no-verbose"])
		this.assertEquals(opts.v, false)
	}

	@Test_list() {
		opts := {}
		op := new OptParser("Test")
		op.add(new OptParser.String(0, "ignore-dir", opts
				, "dir_list", "dirname", "List of ignored dirs"
				, OptParser.OPT_ARG | OptParser.OPT_MULTIPLE))
		op.add(new OptParser.String(0, "no-ignore-dir", opts
				, "no_dir_list", "dirname", "List of not ignored dirs"
				, OptParser.OPT_ARG | OptParser.OPT_MULTIPLE))
		op.parse(["--ignore-dir", "h:\temp", "--ignore-dir", ".git"
				, "--ignore-dir", ".CVSROOT", "--no-ignore-dir=\asdf"])
		this.assertEquals(opts.dir_list[1], "h:\temp")
		this.assertEquals(opts.dir_list[2], ".git")
		this.assertEquals(opts.dir_list[3], ".CVSROOT")
		this.assertEquals(opts.no_dir_list[1], "\asdf")
	}

	@Test_selectOption() {
		opts := {}
		op := new OptParser("Test")
		op.add(new OptParser.Callback(0, "color", opts
				, "c", "Colors_Func", "color", "Set a color"))
		op.parse(["--color", "black"])
		this.assertEquals(opts.c, "black")
		op.parse(["--color", "yellow"])
		this.assertEquals(opts.c, "yellow")
		op.parse(["--color", "white"])
		this.assertEquals(opts.c, "white")
		this.assertException(op, "Parse", "", "Invalid color: orange"
				, ["--color", "orange"])
	}

	@Test_multilineOptionDesc() {
		opts := {}
		op := new OptParser("Test")
		op.add(new OptParser.String(0, "term", opts
				, "term", "term"
				, ["term can have one of the following values"
				, ". a - Means a"
				, ". b - B represents a very long description which has to be wrapped at the end of the line" ; ahklint-ignore: W002
				, ". c - Use C if you're not sure what to choose"]))
		this.assertEquals(op.usage()
				, "usage: Test`n`n    --term <term>         term can have one of the following values`n                          . a - Means a`n                          . b - B represents a very long description which has to be`n                          wrapped at the end of the line`n                          . c - Use C if you're not sure what to choose`n`n`n") ; ahklint-ignore: W002
	}

	@Test_invalidSpecialCharBundeledArgument() {
		opts := {}
		op := new OptParser("Test")
		op.add(new OptParser.Boolean("e", "ee", opts, "e", "e option"))
		this.assertException(op, "Parse", "Invalid argument: -eö"
				, "", ["-eö", "test"])
	}

	@Test_envVarOptions() {
		op := new OptParser("Test")
		this.assertTrue(op.hasKey("envVarName"))
		this.assertEquals(op.envVarName, "")
		opt_var_name := "TEST_OPTS"
		opts := {}
		op := new OptParser("Test",, opt_var_name)
		this.assertEquals(op.envVarName, opt_var_name)
		op.add(new OptParser.Boolean("a", "", opts, "a", "Option a"))
		op.add(new OptParser.Boolean("b", "", opts, "b", "Option b"))
		op.add(new OptParser.Boolean("c", "", opts, "c", "Option c"))
		op.add(new OptParser.Boolean("d", "", opts, "d", "Option d"))
		op.add(new OptParser.Boolean(0, "first", opts, "first", "First Option"))
		op.add(new OptParser.Boolean(0, "second", opts
				, "second", "Second option"))
		EnvSet %opt_var_name%, -bc --second
		EnvGet test_opts, %opt_var_name%
		this.assertEquals(test_opts, "-bc --second")
		args := op.parse(["-a", "--first", "-d", "--no-env", "--env", "value1"])
		this.assertTrue(opts.a)
		this.assertTrue(opts.b)
		this.assertTrue(opts.c)
		this.assertTrue(opts.d)
		this.assertTrue(opts.first)
		this.assertTrue(opts.second)
		this.assertEquals(args[1], "value1")
	}

	@Test_emptyEnvVar_Options() {
		op := new OptParser("Test")
		this.assertTrue(op.hasKey("envVarName"))
		this.assertEquals(op.envVarName, "")
		opt_var_name := "TEST_OPTS"
		opts := {}
		op := new OptParser("Test",, opt_var_name)
		this.assertEquals(op.envVarName, opt_var_name)
		op.add(new OptParser.Boolean("a", "", opts, "a", "Option a"))
		op.add(new OptParser.Boolean("b", "", opts, "b", "Option b"))
		op.add(new OptParser.Boolean("c", "", opts, "c", "Option c"))
		op.add(new OptParser.Boolean("d", "", opts, "d", "Option d"))
		op.add(new OptParser.Boolean(0, "first", opts
				, "first", "First Option"))
		op.add(new OptParser.Boolean(0, "second", opts
				, "second", "Second option"))
		EnvSet %opt_var_name%,
		EnvGet test_opts, %opt_var_name%
		this.assertEquals(test_opts, "")
		args := op.parse(["-a", "--first", "-d", "--no-env", "--env", "value1"])
		this.assertTrue(opts.a)
		this.assertTrue(opts.d)
		this.assertTrue(opts.first)
		this.assertEquals(args[1], "value1")
	}

	@Test_genericOption() {
		opts := {}
		op := new OptParser("Test")
		op.add(new OptParser.Generic("(batch|json|text)", opts, "type"))
		args := op.parse(["--batch"])
		this.assertEquals(opts.type, "batch")
		this.assertEmpty(args.maxIndex())
		args := op.parse(["--text"])
		this.assertEquals(opts.type, "text")
		this.assertEmpty(args.maxIndex())
		this.assertException(op, "Parse","Invalid argument: --nojson"
				,"", ["--nojson"])

		opts := {}
		op2 := new OptParser("Test")
		op2.add(new OptParser.Generic("(batch|json|text)", opts
				, "type2", OptParser.OPT_NEG))
		args2 := op2.parse(["--nojson"])
		this.assertEquals(opts.type2, "!json")

		opts := {}
		op3 := new OptParser("Test")
		op3.add(new OptParser.Generic("i)(batch|json|text)", opts
				, "type3", OptParser.OPT_MULTIPLE|OptParser.OPT_NEG))
		args3 := op3.parse(["--batch", "--no-text", "--NOJSON"])
		this.assertEquals(opts.type3[1], "batch")
		this.assertEquals(opts.type3[2], "!text")
		this.assertEquals(opts.type3[3], "!JSON")
	}

	@Test_line() {
		stExpectedUsage =
(
usage: Test

    Das ist               ein Test
    Das sind jede Menge Zeichen
                          Um genau zu sein sind es siebenundzwanzig Zeichen
    Das sind auf jeden Fall Mal jede Menge Zeichen
    Das sind jede Menge Zeichen
                          Das hier ist die erste Beschreibung
                          und das hier dann die Zweite

    Das ist kurz          Das hier ist die erste kurze Beschreibung
                          und die Zweite



)
		op := new OptParser("Test")
		op.add(new OptParser.Line("Das ist", "ein Test"))
		op.add(new OptParser.Line("Das sind jede Menge Zeichen"
				, "Um genau zu sein sind es siebenundzwanzig Zeichen"))
		op.add(new OptParser
				.Line("Das sind auf jeden Fall Mal jede Menge Zeichen", ""))
		op.add(new OptParser.Line("Das sind jede Menge Zeichen"
				, ["Das hier ist die erste Beschreibung"
				, "und das hier dann die Zweite"]))
		op.add(new OptParser.Line("Das ist kurz"
				, ["Das hier ist die erste kurze Beschreibung"
				, "und die Zweite"]))
		this.assertEquals(op.usage(), stExpectedUsage)
	}

	@Test_optionalArg2() {
		opts := {}
		op := new OptParser("Test")
		op.add(new OptParser.Boolean("a", "", opts, "a", "Set an option"))
		op.add(new OptParser.String("b", "", opts
				, "b", "text", "Set a text", OptParser.OPT_ARG))

		this.assertException(op, "Parse", "", "", ["-ab", "text"])
	}

	@Test_rcFiles() {
		if (FileExist(A_Temp "\.testrc")) {
			FileDelete %A_Temp%\.testrc
		}
		; ahklint-ignore-begin: W010,W003
		FileAppend,
			( LTrim Comments
			--foo
			), %A_Temp%\.testrc
		; ahklint-ignore-end
		opts := {}
		op := new OptParser("Test",,,".testrc")
		op.add(new OptParser.Boolean(0, "foo", opts, "foo", "foo"))
		OptParser.rcPathGlobal := A_TEMP
		op.parse([])
		this.assertTrue(opts.foo)
		FileDelete %A_Temp%\.testrc
	}

	@Test_rcFileOption() {
		if (FileExist(A_Temp "\mytestrc")) {
			FileDelete %A_Temp%\mytestrc
		}
		FileAppend,
			; ahklint-ignore-begin: W003,W010
			( LTrim
			--foo
			#--text dummy
			--text foobar
			), %A_Temp%\mytestrc
			; ahklint-ignore-end
		opts := {}
		op := new OptParser("Test")
		op.add(new OptParser.Boolean(0, "foo", opts, "foo", "foo"))
		op.add(new OptParser.Boolean(0, "bar", opts, "bar", "bar"))
		op.add(new OptParser.String(0, "text", opts, "text", "text"))
		op.add(new Optparser.RcFile(0, "myrc", opts, "myrc", "myrc file"))
		args := op.parse(["--myrc", A_Temp "\mytestrc", "--bar", "--text"
				, "fizz", "buzz"])
		this.assertEquals(opts.myrc, A_Temp "\mytestrc")
		this.assertTrue(opts.foo)
		this.assertTrue(opts.bar)
		this.assertEquals(opts.text, "fizz")
		this.assertEquals(args.maxIndex(), 1)
		this.assertEquals(args[1], "buzz")
		FileDelete %A_Temp%\mytestrc
	}

	@Test_rcFileOptionWithNoEnv() {
		if (FileExist(A_Temp "\mytestrc")) {
			FileDelete %A_Temp%\mytestrc
		}
		FileAppend,
			; ahklint-ignore-begin: W003,W010
			( LTrim
			--foo
			#--text dummy
			--text foobar
			), %A_Temp%\mytestrc
			; ahklint-ignore-end
		opts := {}
		op := new OptParser("Test")
		op.add(new OptParser.Boolean(0, "foo", opts, "foo", "foo"))
		op.add(new OptParser.Boolean(0, "bar", opts, "bar", "bar"))
		op.add(new OptParser.String(0, "text", opts, "text", "text"))
		op.add(new Optparser.RcFile(0, "myrc", opts, "myrc", "myrc file"))
		args := op.parse(["--myrc", A_Temp "\mytestrc", "--bar", "--text"
				, "fizz", "--no-env", "buzz"])
		this.assertEquals(opts.myrc, A_Temp "\mytestrc")
		this.assertFalse(opts.foo)
		this.assertTrue(opts.bar)
		this.assertEquals(opts.text, "fizz")
		this.assertEquals(args.maxIndex(), 1)
		this.assertEquals(args[1], "buzz")
		FileDelete %A_Temp%\mytestrc
	}

	@Test_handleEnvNoEnvOptions() {
		op := new OptParser("Test")
		argumentList := ["--foo", "--no-env", "--bar"
				, "--env", "--noenv", "--buzz"]
		newArgumentList := op.handleEnvNoEnvOptions(argumentList)
		this.assertEquals(newArgumentList.maxIndex(), 3)
		this.assertEquals(newArgumentList[1], "--foo")
		this.assertEquals(newArgumentList[2], "--bar")
		this.assertEquals(newArgumentList[3], "--buzz")
		this.assertFalse(op.useEnvVar)
	}

	@Test_isBundlingOfThisOptionPossible() {
		opts := {}
		op := new OptParser("Test")
		op.add(new OptParser.Boolean("a", "", opts, "a"))
		op.add(new OptParser.Boolean("b", "", opts, "b"))
		op.add(new OptParser.String("c", "", opts, "c", "x" ""))
		op.add(new OptParser.String("d", "", opts
				, "d", "x","", OptParser.OPT_ARGREQ))
		op.add(new OptParser.String("e", "", opts
				, "e", "x","", OptParser.OPT_NOARG))
		this.assertTrue(op.isBundlingOfThisOptionPossible("a"))
		this.assertTrue(op.isBundlingOfThisOptionPossible("b"))
		this.assertFalse(op.isBundlingOfThisOptionPossible("c"))
		this.assertFalse(op.isBundlingOfThisOptionPossible("d"))
		this.assertTrue(op.isBundlingOfThisOptionPossible("e"))
	}

	@Test_ifValidOption() {
		opts := {}
		op := new OptParser("Test")
		op.add(new OptParser.Boolean("a", "", opts, "a"))
		op.add(new OptParser.Boolean("b", "", opts, "b"))
		op.add(new OptParser.Boolean("c", "", opts, "c"))
		op.add(new OptParser.Boolean("d", "", opts, "d"))
		op.add(new OptParser.Boolean("e", "", opts, "e"))
		this.assertEquals(op.testIfValidLongOrShortOption("-a"), 1)
		this.assertEquals(op.testIfValidLongOrShortOption("--"), -1)
		this.assertEquals(op.iPtr, 2)
		this.assertEquals(op.testIfValidLongOrShortOption("foo"), -1)
		this.assertEquals(op.iPtr, 2)
	}
}

test_func(value, no_opt="") {
	if (value = "high") {
		value := 2
	} else if (value = "low") {
		value := 0
	} else {
		value := 1
	}
	return value
}

colors_func(value) {
	if (RegExMatch(value
			, "i)(black|red|green|yellow|blue|purple|cyan|white)", $)) {
		return $
	} else {
		throw Exception("Invalid color: " value)
	}
}

exitapp OptParserTest.runTests()

