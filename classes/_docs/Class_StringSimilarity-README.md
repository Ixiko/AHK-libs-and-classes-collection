string-similarity.ahk
=================

Finds degree of similarity between two strings, based on [Dice's Coefficient](http:;;en.wikipedia.org/wiki/S%C3%B8rensen%E2%80%93Dice_coefficient), which is mostly better than [Levenshtein distance](http:;;en.wikipedia.org/wiki/Levenshtein_distance).


## Usage
Install by defining the package in package.json:


```javascript
"dependencies": {
        "string-similarity.ahk": "chunjee/string-similarity.ahk"
     }
```

then install with yarn:

```shell
yarn newinstall
```

In your code:

```autohotkey
#Include %A_ScriptDir%\lib\stringsimilarity.ahk\export.ahk
stringSimilarity := new stringsimilarity()

similarityrating := stringSimilarity.compareTwoStrings("healed", "sealed")

matches := stringSimilarity.findBestMatch("healed", ["edward", "sealed", "theatre"])

bestmatchstring := stringSimilarity.simpleBestMatch("Hard to", [" hard to    ", "hard to", "Hard 2"])
```

## API

Requiring the module gives an object with three methods: .compareTwoStrings, .findBestMatch, and .simpleBestMatch


### compareTwoStrings(string1, string2)

Returns a fraction between 0 and 1, which indicates the degree of similarity between the two strings. 0 indicates completely different strings, 1 indicates identical strings. The comparison is case-insensitive.

##### Arguments
  
1. string1 (string): The first string
2. string2 (string): The second string
  
Order does not make a difference.
  
##### Returns
  
(Number): A fraction from 0 to 1, both inclusive. Higher number indicates more similarity.

##### Examples
  
```autohotkey
stringSimilarity.compareTwoStrings("healed", "sealed")
;; → 0.80

stringSimilarity.compareTwoStrings("Olive-green table for sale, in extremely good condition."
  , "For sale: table in very good  condition, olive green in colour.")
;; → 0.71

stringSimilarity.compareTwoStrings("Olive-green table for sale, in extremely good condition."
  , "For sale: green Subaru Impreza, 210,000 miles")
;; → 0.30

stringSimilarity.compareTwoStrings("Olive-green table for sale, in extremely good condition."
  , "Wanted: mountain bike with at least 21 gears.")
;; → 0.11
```

### findBestMatch(mainString, targetStrings)

Compares `mainString` against each string in `targetStrings`.

##### Arguments

1. mainString (string): The string to match each target string against.
2. targetStrings (Array): Each string in this array will be matched against the main string.

##### Returns
(Object): An object with a `ratings` property, which gives a similarity rating for each target string, and a `bestMatch` property, which specifies which target string was most similar to the main string.

##### Examples
```autohotkey
stringSimilarity.findBestMatch("Olive-green table for sale, in extremely good condition."
  , ["For sale: green Subaru Impreza, 210,000 miles"
  , "For sale: table in very good condition, olive green in colour."
  , "Wanted: mountain bike with at least 21 gears."])
;; → 
{ ratings:
   [ { target: "For sale: green Subaru Impreza, 210,000 miles",
       rating: 0.30 },
     { target: "For sale: table in very good condition, olive green in colour.",
       rating: 0.71 },
     { target: "Wanted: mountain bike with at least 21 gears.",
       rating: 0.11 } ],
  bestMatch:
   { target: "For sale: table in very good condition, olive green in colour.",
     rating: 0.71 } }
```


### simpleBestMatch(mainString, targetStrings)

Compares `mainString` against each string in `targetStrings`.

##### Arguments

1. mainString (string): The string to match each target string against.
2. targetStrings (Array): Each string in this array will be matched against the main string.

##### Returns
(String): The string that was most similar to the first argument string.

##### Examples
```autohotkey
stringSimilarity.findBestMatch("Hard to"
  , [" hard to    "
  , "hard to"
  , "Hard 2"])
;; → "hard to"
```
