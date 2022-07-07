# [![ngram.ahk A really simple ngram generator for AutoHotkey](https://raw.githubusercontent.com/Chunjee/ngram.ahk/master/header.svg)](https://www.github.com/chunjee/ngram.ahk)

[![npm](https://img.shields.io/npm/dm/ngram.ahk?style=for-the-badge&logo=npm)](https://www.npmjs.com/package/ngram.ahk) [![source-code](https://img.shields.io/badge/source-code-red?style=for-the-badge&logo=github)](https://www.github.com/chunjee/ngram.ahk) ![license](https://img.shields.io/npm/l/ngram.ahk?color=tan&style=for-the-badge)


## Installation

In a terminal or command line navigated to your project folder:

```bash
npm install ngram.ahk
```

In your code only export.ahk needs to be included:

```autohotkey
#Include %A_ScriptDir%\node_modules
#Include ngram.ahk\export.ahk

ngram := new ngram()

ngram.generate(["hello", "world", "foo", "bar"], 2)
; => [["hello", "world"], ["world", "foo"], ["foo", "bar"]]
```


## API

### .generate(value, length)

generates ngrams.

##### Arguments
1. value (String|Array): The value to generate ngrams from
2. size (Number|Array): Optional (default `1`); the length of the ngrams to generate

##### Returns
(Array): returns all n-grams in an array

##### Example
```autohotkey
ngram.generate("string")
; => [["s"], ["t"], ["r"], ["i"], ["n"], ["g"]]

ngram.generate("string", 2)
; => [["s", "t"], ["t", "r"], ["r", "i"], ["i", "n"], ["n", "g"]]

array := strSplit("Time is an illusion. Lunchtime doubly so", " ")
ngram.generate(array, [1, 3])
; => [["Time"], ["is"], ["an"], ["illusion."], ["Lunchtime"], ["doubly"], ["so"]], [["Time", "is", "an"], ["is", "an", "illusion."], ["an", "illusion.", "Lunchtime"], ["illusion.", "Lunchtime", "doubly"], ["Lunchtime", "doubly", "so"]]
```
