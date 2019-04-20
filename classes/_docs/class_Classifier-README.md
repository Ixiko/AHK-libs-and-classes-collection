Classifier
==========
A document filtering class implementing a Fisher classifier.

A Fisher classifier is similar to a naive Bayesian classifier, but it is known to give significantly more accurate results in many cases.

Example
-------

A simple example of classifying documents with training data:

    c := new Classifier
    
    c.Train("Nobody owns the water.","good")
    c.Train("the quick rabbit jumps fences","good")
    c.Train("buy pharmaceuticals now","bad")
    c.Train("make quick money at the online casino","bad")
    c.Train("the quick brown fox jumps","good")
    
    Item := "quick rabbit"
    
    Result := "Category`tProbability`n"
    For Index, Entry In c.Classify(Item)
        Result .= Entry.Category . "`t" . Entry.Probability . "`n"
    MsgBox, %Result%

The classifier considers "quick rabbit" to belong in the category "good", taking into account past training data.

Usage
-----

Suppose we wanted to detect whether a forum posting for a script was written for AutoHotkey Basic or AutoHotkey_L. How would we go about doing this?

First, we need to create a classifier:

    c := new Classifier

Now, the classifier needs to be trained to recognize the types of posts we are looking for. Specifically, we'll give it posts that are written for AutoHotkey Basic, and posts that are written for AutoHotkey_L, as well as the categories they belong to.

We'll use "AutoHotkey Basic" and "AutoHotkey_L" as our categories, and a few posts selected randomly from the AutoHotkey forums as our training data:

    Data = 
    (
    Native Zip and Unzip XP/Vista/7 [AHK_L]
    
    This version for Autohotkey_L was inspired by the script at Zip/Unzip using native ZipFolder Feature in XP by Sean. 
    
    Features: 
    1. Zip/Unzip natively on any Windows > XP 
    2. Zip file(s)/folder(s)/wildcard pattern files 
    3. Unzip destination folder created if !Exists [Thanks Sean] 
    
    Credits: 
    Sean - for original idea 

    ;...snip
    )
    c.Train(Data,"AutoHotkey_L") ;train the classifier with the fact that the above post was written for AutoHotkey_L
    
    Data = 
    (
    Minecraft Utilities : Fishing Bot, Chest Xfer, Auto Furnace
    
    This is a lil' tool I made to both learn AHK (first script besides messing around with autofire stuff that other people made) and to make minecraft less of a chore. i.e. Loading 9 furnaces at once. 
    
    
    Minecraft Utilities Package X-treme Edition Advanced Gold Medal 
    Get it here 
    Requirements: GDIP, bobber.png (for autofisher and default bobber skin only) 
    Also run Minecraft either maximized or full screen. Sometimes title bar transparency coupled with a specific background might confuse some parts of the script. 
    
    ;...snip
    )
    c.Train(Data,"AutoHotkey Basic") ;train the classifier with the fact that the above post was written for AutoHotkey Basic

In a real world application it would be best to do far more training; the classifier becomes more accurate with each item it is trained with. It is recommended to train the classifier with at least a few dozen items before expecting really accurate results.

Now that we've given it some basic training, it is now capable of classifying documents. Let's try classifying a post written for AHK_L, and see if it recognizes it:

    Data = 
    (
    [AHK_L] ListMFTfiles: NTFS Instant File Search
    
    Searches whole drive in just a few seconds or faster even if you have 100000 files or more, and lists file names, optionally matching given regex criteria.
    
    Features:
    AHKL Unicode
    Only NTFS drives
    Currently no junctions support
    Searches all files on a drive specified in the first parameter, for example "c:"
    Optional regex parameter to filter filenames
    No error reporting, just an empty string is returned
    Tested on XPsp3, Win7x64
    
    ;...snip
    )
    Categories := c.Classify(Data)
    
    MsgBox, % "The data belongs to the category """ . Categories[1].Category . """ with a probability of " . Categories[1].Probability . "."

Success! The post was correctly recognized as being written for AHK_L, even though the classifier has never seen it before.

Interface
---------

A quick overview of what the class contains.

### Classifier.Train(Item,Category)

Trains the classifier with the fact that the item "Item" belongs to the category "Category".

### Classifier.Classify(Item)

Classifies the item "Item" into known categories, according to the data it was trained with.

Extending
---------

Maybe you'd like a different way to convert items into a list of features. Maybe you'd like to use a different probability weighting scheme. No problem! The class can easily be extended. This section contains an overview of the internal functions and data structures used by the class.

### Classifier.Features

A map of the number of times a given feature has been seen in an item belonging to a given category, organized by feature and then by category: Classifier.Features[Feature][Category]

### Classifier.Items

A map of the number of items that belong to a given category, organized by category: Classifier.Items[Category]

### Classifier.Sanitize(Data)

Accepts raw data given as input, and returns an array of features. For example, the input "quick rabbit" would result in the array ["quick","rabbit"].

### Classifier.WeightedProbability(Feature,Category)

Accepts a feature and a category, and returns a weighted probability that the feature belongs in the category. A weighted probability should consider features that have not been previously encountered, and consider it to have a certain assumed probability.

### Classifier.Probability(Feature,Category)

Accepts a feature and a category, and returns a basic probability that the feature belongs in the category. A basic probability is simply the ratio of the occurrences of the feature in the category to the occurrences of the feature in total.