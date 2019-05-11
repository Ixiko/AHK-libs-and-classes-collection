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