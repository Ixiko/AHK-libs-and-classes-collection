# HotVoice

Use your voice as a Hotkey in AutoHotkey!  

[Discussion Thread](https://autohotkey.com/boards/viewtopic.php?f=6&t=34288)

## Using HotVoice in your scripts
### Initial Setup
1. Install the [Microsoft Speech Platform Runtime](https://www.microsoft.com/en-us/download/details.aspx?id=27225)  
You will need either x86 or x64, depending on what version of AHK you run. No harm in installing both, just to be sure.  
2. Install at least one [Language Pack](https://www.microsoft.com/en-us/download/details.aspx?id=27224)  
eg `MSSpeech_SR_en-US_TELE.msi`  
3. Download a release of HotVoice from the [Releases Page](https://github.com/evilC/HotVoice/releases) and unzip it to a folder of your choice (This shall be referred to as the "HotVoice folder" from now on).    
**DO NOT** use the "Clone or Download" button on the main GitHub page, this is for developers.  
4. Ensure the DLLs that are in the HotVoice Folder are not blocked.  
Right-click `unblock.ps1` in the HotVoice Folder and select "Run as Administrator".  
5. Run the Demo script and make sure it works for you.  
It should look something like this:  
![](https://i.imgur.com/TLzzvTF.png) 

"Recognizers" are basically Language Packs. Ordering seems to be based on installation order, with the "Lightweight" pack always present and at the end of the list. Therefore, if you only install one language pack, it should always be `ID 0`, so everything in HotVoice defaults to using ID 0. 
The `Mic Volume` slider should move when you speak.  
HotVoice uses the "Default Recording Device" that is configured in Windows.  

### Using the Library
#### Grammar and Choices objects
HotVoice uses these two types of object to build up commands.  
Throughout this documentation, the following syntax will be used to denote a phrase with optional components:  
`Launch [Notepad, Word]`  
In this instance it can mean "Launch Notepad" or "Launch Word".  
##### Choices Objects
Choices objects represent a series of optional words. As in the above example, `[Notepad, Word]` is a series of Choices.  
##### Grammar Objects
Grammar objects are the primary building blocks of HotVoice. They can hold either single words, or choices objects, or even other Grammar objects.
#### Initializing HotVoice
A HotVoice script must do the following:  

1. Load the HotVoice Library  
`#include Lib\HotVoice.ahk`  

2. Create a new HotVoice class  

```
hv := new HotVoice()
```

3. Add at least one Grammar  

```
; Create a new Grammar
testGrammar := hv.NewGrammar()

; Add the word "Test" to it
testGrammar.AppendString("Test")

; Load the Grammar
hv.LoadGrammar(testGrammar, "Test", Func("MyFunc"))
```  

4. Start the Recognizer  

```
hv.StartRecognizer()
```

#### Function Reference
##### NewChoices
Creates a new Choices object from a comma-separated string
`Choices NewChoices(string choiceListStr)`  
eg `choices := hv.NewChoices("Up, Down, Left, Right")`  

##### NewGrammar
Creates a new, empty Grammar Object  
`GrammarObj NewGrammar()`  
eg `grammarObj := hv.NewGrammar()`  

#### GetChoices(name)
Gets a Choices object from HotVoice's store of choices objects.  
By default, this is empty execpt for the `Percent` Choices object, which contains the numbers `0-100`  
`Choices GetChoices(string name)`  
eg `percentChoices := hv.GetChoices("Percent")`

##### SetChoices(name)
Adds a Choices object to HotVoice's store of choices objects.  
`void SetChoices(string name, Choices choices)`  
eg `percentChoices := hv.SetChoices("Directions", hv.NewChoices("Up, Down, Left, Right"))`  

##### LoadGrammar
Loads a GrammarObject into the Recognizer and specifies which function to call when it is triggered.  
`void LoadGrammar(GrammarObject g, string name, BoundFunc callback)`  
eg `hv.LoadGrammar(testGrammar, "Test", Func("MyFunc"))`  

##### Initialize
Loads a Recognizer  
`void Initialize(int recognizerId = 0)`  
eg `hv.Initialize()`  

##### StartRecognizer  
Starts the Recognizer  
`void StartRecognizer()`  
eg `hv.StartRecognizer()`  

#### Object Reference  
##### GrammarObject
###### GetPhrases
Gets a human-readable string that describes the phrasology that this Grammar supports  
`string GetPhrases()`  
eg `phrases := grammarObj.GetPhrases()`  

###### AppendString
Adds a word or words to a GrammarObject  
`void AppendString(string text)`  
eg `grammarObj.AppendString("Hello")`  

###### AppendChoices
Adds a ChoicesObject to this GrammarObject  
`void AppendChoices(Choices choices)`  
eg `grammarObj.AppendChoices(choicesObj)`  

###### AppendGrammars
Adds up to 10 GrammarObjects to this GrammarObject  
`void AppendGrammars(GrammarObject g1, ... , GrammarObject g10)`  
eg `grammarObj1.AppendGrammars(grammarObj2, grammarObj3)`  

# Developers
This **ONLY APPLIES** if you want to work with the C# code that powers HotVoice.  
If you are writing AHK scripts using HotVoice, this does not apply to you.  
### Initial Setup
1. Install the [Microsoft Speech Platform SDK 11](https://msdn.microsoft.com/en-us/library/hh362873(v=office.14).aspx#Anchor_2).  
2. When you open the SLN, you may need to fix the reference to `Microsoft.Speech`  
It can be found in `C:\Program Files\Microsoft SDKs\Speech\v11.0\Assembly` 

[Speech API Reference on MSDN](https://msdn.microsoft.com/en-us/library/hh378380(v=office.14).aspx)
