; ahk: console
#include <logging>
#include <testcase>
#include <string>
#include <object>
#include <arrays>
#include <flimsydata>

class RCopyTest extends TestCase
{

	@BeforeClass_Setup() {
		if (!FileExist(A_Scriptdir "\Testdata")) {
            OutputDebug *** Create Testdata ***
			FileCreateDir %A_ScriptDir%\Testdata\DCIM\100OLYMP\
			SetWorkingDir %A_ScriptDir%\Testdata\DCIM\100OLYMP\
			fd := new FlimsyData.Simple(1450)
			; Create test files
			loop 20 {
                date := fd.GetDate(2001,20190113)
                time := fd.GetTime()
                m := SubStr(date, 5, 2)
                m := (m = 10 ? "A"
                    : m = 11 ? "B"
                    : m = 12 ? "C"
                    : m+0)
                d := SubStr(date, 7, 2)
                x := SubStr("0000" A_Index, -3)
                fn := fd.GetPattern("%[P,_]") m d x
                ts := date time
                data := fd.GetString(20)
                FileAppend, %data%, %fn%.orf
                FileSetTime %ts%, %fn%.orf, C
                FileSetTime %ts%, %fn%.orf, M
                data := fd.GetString(20)
                FileAppend, %data%, %fn%.jpg
                FileSetTime %ts%, %fn%.jpg, C
                FileSetTime %ts%, %fn%.jpg, M
			}
            FileAppend,, a_culprit.txt
		}
	}

	@BeforeRedirStdOut()
    {
		Ansi.StdOut := FileOpen(A_Temp "\rcopy-test.txt", "w")
	}

    @BeforeReInit()
    {
        RCopy.options := RCopy.set_defaults()
        RCopy.context_vars := RCopy.set_context_vars()
    }

	@AfterRedirStdOut()
    {
		Ansi.StdOut.Close()
		Ansi.StdOut := Ansi.__InitStdOut()
		FileDelete %A_Temp%\rcopy-test.txt
	}

	@Test_Class()
	{
		this.AssertTrue(RCopy.HasKey("options"))
		this.AssertTrue(RCopy.HasKey("context_vars"))
        this.AssertTrue(RCopy.options.HasKey("file_types"))
		this.AssertTrue(IsFunc(RCopy.set_defaults))
		this.AssertTrue(IsFunc(RCopy.set_context_vars))
		this.AssertTrue(IsFunc(RCopy.SetupSourcePath))
		this.AssertTrue(IsFunc(RCopy.SetupTargetPath))
		this.AssertTrue(IsFunc(RCopy.CopyAndRename))
		this.AssertTrue(IsFunc(RCopy.FillFileContext))
		this.AssertTrue(IsFunc(RCopy.IncreaseSequenceContext))
	}

    @Test_SetDefaults()
	{
        this.AssertEquals(RCopy.options.rename_as, "")
        this.AssertEquals(RCopy.options.source, "")
        this.AssertEquals(RCopy.options.start_with, 1)
        this.AssertEquals(RCopy.options.dry_run, false)
        this.AssertEquals(RCopy.options.help_context_vars, false)
        this.AssertEquals(RCopy.options.help_file_types, false)
        this.AssertEquals(RCopy.options.help, false)
    }

    @Test_SetContextVars()
    {
        this.AssertTrue(RCopy.context_vars.HasKey(RCopy.CV_YEAR4))
        this.AssertTrue(RCopy.context_vars.HasKey(RCopy.CV_YEAR2))
        this.AssertTrue(RCopy.context_vars.HasKey(RCopy.CV_MONTH))
        this.AssertTrue(RCopy.context_vars.HasKey(RCopy.CV_DAY))
        this.AssertTrue(RCopy.context_vars.HasKey(RCopy.CV_X))
        this.AssertTrue(RCopy.context_vars.HasKey(RCopy.CV_Y))
        this.AssertTrue(RCopy.context_vars.HasKey(RCopy.CV_PCT))
    }

    @Test_SetupSourcePath()
    {
        this.AssertException(RCopy, "SetupSourcePath", "", "Specify source", "")
        RCopy.SetupSourcePath("c:\work\temp")
        this.AssertEquals(RCopy.options.source, "c:\work\temp\*.*")
        RCopy.SetupSourcePath("*.jpg")
        this.AssertEquals(RCopy.options.source, "*.jpg")
        RCopy.SetupSourcePath("x*.jpg")
        this.AssertEquals(RCopy.options.source, "x*.jpg")
        RCopy.SetupSourcePath(".")
        this.AssertEquals(RCopy.options.source, ".")
        RCopy.SetupSourcePath("*.*")
        this.AssertEquals(RCopy.options.source, "*.*")
        RCopy.SetupSourcePath("*.")
        this.AssertEquals(RCopy.options.source, "*.")
        RCopy.SetupSourcePath(".\*")
        this.AssertEquals(RCopy.options.source, ".\*")
        RCopy.SetupSourcePath("c:\work\t*")
        this.AssertEquals(RCopy.options.source, "c:\work\t*")
        RCopy.SetupSourcePath("c:\work\t*.jpg")
        this.AssertEquals(RCopy.options.source, "c:\work\t*.jpg")
    }

    @Test_FillFileContext()
    {
        RCopy.FillFileContext("test.jpg", 20190114090807)
        this.AssertEquals(RCopy.context_vars[RCopy.CV_DAY].value, "14")
        this.AssertEquals(RCopy.context_vars[RCopy.CV_MONTH].value, "01")
        this.AssertEquals(RCopy.context_vars[RCopy.CV_YEAR4].value, "2019")
        this.AssertEquals(RCopy.context_vars[RCopy.CV_YEAR2].value, "19")
    }

    @Test_IncreaseSequenceContext()
    {
        this.AssertEquals(RCopy.context_vars[RCopy.CV_X].value, 1)
        RCopy.IncreaseSequenceContext()
        this.AssertEquals(RCopy.context_vars[RCopy.CV_X].value, 2)
        RCopy.IncreaseSequenceContext()
        this.AssertEquals(RCopy.context_vars[RCopy.CV_X].value, 3)
    }

    @Test_UseContext()
    {
        this.AssertEquals(RCopy.UseContext("My_Image-%y4%-%m%-%d%_%00x%")
            , "My_Image-YYYY-MM-DD_001")

        RCopy.FillFileContext("test.jpg", 20190114094815)
        RCopy.context_vars[RCopy.CV_X].value := 13
        this.AssertEquals(RCopy.UseContext("%y4%"), "2019")
        this.AssertEquals(RCopy.UseContext("%y2%"), "19")
        this.AssertEquals(RCopy.UseContext("%m%"), "01")
        this.AssertEquals(RCopy.UseContext("%m%"), "01")
        this.AssertEquals(RCopy.UseContext("%d%"), "14")
        this.AssertEquals(RCopy.UseContext("%x%"), "13", TestCase.AS_STRING)
        this.AssertEquals(RCopy.UseContext("%0x%"), "13", TestCase.AS_STRING)
        this.AssertEquals(RCopy.UseContext("%00x%"), "013", TestCase.AS_STRING)
        this.AssertEquals(RCopy.UseContext("%000x%")
            , "0013", TestCase.AS_STRING)
    }

    @Test_SetupTargetPath()
    {
        RCopy.options.dest := "c:\temp"
        this.AssertEquals(RCopy.SetupTargetPath(), "c:\temp\")
    }

    @Test_SetupTargetPath2()
    {
        RCopy.options.dest := "c:\temp\%y4%\%m%\%d%"
        RCopy.FillFileContext("test.jpg", 20190114113819, 1)
        this.AssertEquals(RCopy.SetupTargetPath(), "c:\temp\2019\01\14\")
    }

    @Test_FtExpr()
    {
        this.AssertEquals(RCopy.FtExpr()
            , "i)^(.*\.jpe?g|.*\.tiff?|.*\.orf|.*\.dng)$")
    }

    @Test_CollectFilenames()
    {
        RCopy.SetupSourcePath(A_ScriptDir "\Testdata\DCIM\100OLYMP")
        RCopy.CollectFilenames(good, bad)
        this.AssertEquals(good.MaxIndex(), 40)
        this.AssertEquals(bad.MaxIndex(), 1)
    }

    @Test_CollectFilenames1()
    {
        RCopy.SetupSourcePath(A_ScriptDir "\Testdata\DCIM\100OLYMP\x*")
        RCopy.CollectFilenames(good)
        this.AssertEquals(good.MaxIndex(), "")
    }

    @Test_FileMD5()
    {
        this.AssertEquals(RCopy.FileMD5(A_ScriptDir
            . "\Testdata\DCIM\100OLYMP\_4110007.jpg")
            , "c43ebad6b674a87a78b2fabfb677e8ca")
    }
}

exitapp RCopyTest.RunTests()

#include %A_ScriptDir%\..\rcopy.ahk
