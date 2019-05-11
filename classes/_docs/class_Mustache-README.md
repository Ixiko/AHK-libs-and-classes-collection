# Mustache.ahk #

[![AHK](https://img.shields.io/badge/AHK-v1.1.21.00-lightgrey.svg?style=flat-square)](https://autohotkey.com/download/)

[Mustache](https://mustache.github.io/) implementation written in AutoHotkey. Very much a work in progress.

Currently handles:
- Variables
- Sections
- Inverted sections
- Comments

Work in progress:
- Partials

## Usage ##

Save `Mustache.ahk` to your `lib` folder and include it using `#Include <Mustache>`. Make sure to use `SetBatchLines -1` if you're going to be compiling big templates. If you'll be working with JSON data, I suggest checking out [Coco's JSON lib](https://github.com/cocobelgica/AutoHotkey-JSON).

See the [mustache manual](https://mustache.github.io/mustache.5.html) for details on how to create templates. Note however that not all features are implemented yet.

```autohotkey
; This really speeds up compiling big files
SetBatchLines -1

; Import the lib
#Include <Mustache>

template := "Hello {{data}}!"
dataObject := {data: "world"}

; This template can be stored and re-used for better performance
compiledTemplate := Mustache.Compile(template)

; Render in the data
renderedTemplate := Mustache.Render(compiledTemplate, dataObject)
msgBox % renderedTemplate

; Let's change the data
dataObject.data := "user"

renderedTemplate := Mustache.Render(compiledTemplate, dataObject)
msgBox % renderedTemplate
```