; Title:
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?p=335405#p335405
; Author:
; Date:
; for:     	AHK_L

/*


*/

ChromeSavePDF(ProfileFolder,Link,FileName,Open:=False)
{
  ; huge thanks to GeekDude! (https://www.autohotkey.com/boards/memberlist.php?mode=viewprofile&u=161)
  ; https://github.com/G33kDude/Chrome.ahk
  ; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=42890
  ; function by JoeW based on GeekDude's example: ExportPDF.ahk
  RetCode:=0
  ChromeInst:=new Chrome(ProfileFolder,Link,"--headless")
  If !(PageInst:=ChromeInst.GetPage())
  {
    ChromeInst.Kill()
    Return 1
  }
  Else
  {
    PageInst.WaitForLoad()
    Base64PDF:=PageInst.Call("Page.printToPDF").data
    Size:=Base64_Decode(BinaryPDF, Base64PDF)
    FileOpen(FileName,"w").RawWrite(BinaryPDF,Size)
    If (Open)
    {
      Try Run,%FileName%
      Catch
        RetCode:=2
    }
    Try PageInst.Call("Browser.close") ; Fails when running headless
    Catch
      ChromeInst.Kill()
    PageInst.Disconnect()
  }
  Return RetCode
}
#Include Chrome.ahk
#Include Base64EncodeDecode.ahk