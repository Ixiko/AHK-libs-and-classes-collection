//WindowSystemObject (WSO) sample
//Copyright (C) Veretennikov A. B. 2004-2015

o = new ActiveXObject("Scripting.WindowSystemObject")

o.EnableVisualStyles = true

f = o.CreateForm(0,0,0,0)

f.ClientWidth = 600
f.ClientHeight = 400
f.CenterControl()
f.Text = "Docking framework example"
var Panels = new Array()
f.Docking.UniqueId = "Form1"
f.Docking.DropTarget = true
f.AutoSplit = true

function CreateDocument(Name)
{
        var Doc = f.CreateFrame(10,10,100,100)
        Doc.Text = Name
        var Edit = Doc.CreateEdit(0,0,0,0,o.translate("ES_MULTILINE"))
        Edit.Align = o.Translate("AL_CLIENT")
        Doc.Align = o.Translate("AL_CLIENT")
        Doc.Docking.AlwaysDockTab = true
        Doc.Docking.DropTarget = true
        Doc.Docking.UniqueId = Name
        // Edit.Text = "Some text where"
        Panels[Name]=Doc
        return Doc      
}

function CreatePanel(Name)
{
        var Panel = f.CreateFrame(10,10,150,100)
        Panel.Text = Name
        Panel.Align = o.Translate("AL_LEFT")
        Panel.Docking.AlwaysDockPage = true
        Panel.Docking.DropTarget = true
        Panel.Docking.UniqueId = Name
        Panels[Name]=Panel
        return Panel
}

function CreateBottomPanel(Name)
{
        var Panel = f.CreateFrame(10,10,100,100)
        Panel.Text = Name
        Panel.Align = o.Translate("AL_BOTTOM")
        Panel.Docking.AlwaysDockPage = true
        Panel.Docking.DropTarget = true
        Panel.Docking.UniqueId = Name
        Panels[Name]=Panel
        return Panel
}

Doc1 = CreateDocument("Doc1")

for (i = 2; i<4; i++)
{
        Doc = CreateDocument("Doc"+i)
        Doc1.Docking.DockAsNeighbour(Doc,o.Translate("AL_CLIENT"))
}
Doc1.Parent.Visible = true

SearchPanel = CreateBottomPanel("Search")
ConsolePanel = CreateBottomPanel("Console")
with (ConsolePanel)
{
        with (CreateEdit(0,0,0,0,o.Translate("ES_MULTILINE | ES_READONLY")))
        {
                Align = o.Translate("AL_CLIENT")        
                Add("Line 1")
                Add("Line 2")
                Add("Line 3")
        }
}
with (SearchPanel)
{
        with (CreateEdit(0,0,0,0,o.Translate("ES_MULTILINE | ES_READONLY")))
        {
                Align = o.Translate("AL_CLIENT")        
                Add("Search result 1")
                Add("Search result 2")
                Add("Search result 3")
        }
}


SearchPanel.Docking.DockAsNeighbour(ConsolePanel,o.Translate("AL_CLIENT"))


ContextPanel = CreatePanel("Context")
var TreeView = ContextPanel.CreateTreeView(0,0,0,0)
TreeView.Align = o.Translate("AL_CLIENT")
var Root = TreeView.Items.Add("Item 1")
for (i = 1; i<5; i++)
{
        Root.Add("Item 1."+i)
}
Root.Expand()


IndexPanel = CreatePanel("Index")
var ListBox = IndexPanel.CreateListBox(0,0,0,0)
ListBox.Align = o.Translate("AL_CLIENT")
for (i = 1; i<5; i++)
{
        ListBox.Add("Item 1."+i)
}

ContextPanel.Docking.DockAsNeighbour(IndexPanel,o.Translate("AL_CLIENT"))
HelpPanel = CreatePanel("Help")
ContextPanel.Docking.DockAsNeighbour(HelpPanel,o.Translate("AL_CLIENT"))
ContextPanel.Parent.Visible = true
HelpPanel.TextOut(10,10,"Some Help can be there")

File = f.Menu.Add("File")
File.Add("Exit").OnExecute = CloseFormHandler

Windows = f.Menu.Add("Windows")
for (Name in Panels)
{
        Item = Windows.Add(Name)
        Item.OnExecute = ShowPanel
}

function ShowPanel(Sender)
{
        Panel = Panels[Sender.Text]
        while (true)
        {
                Panel.Visible = true
                if (Panel.Type == "Form")
                        break
                Panel = Panel.Parent
        }
}

Layout = f.Menu.Add("Layout")
Layout.Add("Save").OnExecute = SaveLayout
Layout.Add("Load").OnExecute = LoadLayout

f.Show()

o.Run()

function CloseFormHandler(Sender)
{
        Sender.Form.Close()
}



function SaveLayout()
{
        Text = o.SaveLayout()
        FSO = new ActiveXObject("Scripting.FileSystemObject")
        var File = FSO.CreateTextFile(LayoutFile())
        File.WriteLine(Text)
        File.Close()
}


function LoadLayout()
{
        var File = LayoutFile()
        FSO = new ActiveXObject("Scripting.FileSystemObject")
        if (!FSO.FileExists(File))
        {
                f.MessageBox("File "+File+" does not exists")
                return
        }
        var File = FSO.OpenTextFile(File)
        Text = File.ReadAll()
        File.Close()
        o.LoadLayout(Text)
}



function CurrentDir() 
{
        var s = WScript.ScriptFullName; 
        s = s.substring(0,s.lastIndexOf("\\") + 1); 
        return s; 
};

function LayoutFile()
{
        return ConfigurationFolder() + "Docking.txt"
}

function ConfigurationFolder()
{
        FSO = new ActiveXObject("Scripting.FileSystemObject")
        var Path = FSO.GetSpecialFolder(TemporaryFolder = 2)+"\\WSOExamples"
        if (!FSO.FolderExists(Path))
                FSO.CreateFolder(Path)
        return Path+"\\"
}