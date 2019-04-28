;DahkX.ahk by burque505
;Easter Sunday, 2019
;first (and probably last) version 0.0.1
;

csharp=
(


    using System;
    using Novacode;
    using System.Drawing;
     
    namespace FeedTheMonkey
    {
        class Program
        {
            static void Main(string[] args)
            {
                using (DocX document = DocX.Create("FeedTheMonkey.docx"))
                {
                    // Add a new Paragraph to the document.
                    Paragraph p = document.InsertParagraph();
                    
                    // Append some text.
                    p.Append("Please feed the monkey . . . ").Font(new FontFamily("Arial Black"));                 
                    p.InsertParagraphAfterSelf("Okay, gimme a recipe!!!").Font(new FontFamily("Times New Roman")).Bold().FontSize(30).Color(Color.Red);
                    Paragraph p2 = document.InsertParagraph();
                    p2.Append("Gee whiz - you're a bad zookeeper. (sigh..)").Font(new FontFamily("Algerian")).Bold().FontSize(15).Color(Color.Blue);
                    
                    p2.AppendLine();
                    var bulletsList = document.AddList( "2 cups of flour", 0, ListItemType.Bulleted );
                    document.AddListItem( bulletsList, "3/4 cup of sugar" );
                    document.AddListItem( bulletsList, "1/2 cup of butter" );
                    document.AddListItem( bulletsList, "2 eggs" );
                    document.AddListItem( bulletsList, "1 cup of milk" );
                    document.AddListItem( bulletsList, "2 teaspoons of baking powder" );
                    document.AddListItem( bulletsList, "1/2 teaspoon of salt" );
                    document.AddListItem( bulletsList, "1 teaspoon of vanilla essence" );
                    
                    document.InsertList(bulletsList);
                    
                    // Save the document.
                    
                    document.Save();
                }
            }
        }
    }


)

; "0" for the AppDomain, "DahkX.exe" for the temporary executable, and "/target:winexe" so a console window doesn't open.
asm := CLR_CompileC#(CSharp,"System.dll|System.Drawing.dll|Microsoft.CSharp.dll|DocX.dll", 0, "DahkX.exe", "/target:winexe")

; Run what you just compiled
RunWait, DahkX.exe

; Delay because sometimes it hiccups - not often
sleep, 100

; Get rid of the executable and .pdb file, comment this out if you want to keep them for some reason.
FileDelete, DahkX.exe
FileDelete, DahkX.pdb

; e finito tutto!
ExitApp