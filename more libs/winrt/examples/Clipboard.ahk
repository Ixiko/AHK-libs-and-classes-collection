/*
  This script demonstrates retrieving Clipboard content.
  Only HTML for now, but any format could be retrieved.
  Querying the Clipboard History is shown toward the end.
*/
#include ..\winrt.ahk

Clipboard := WinRT('Windows.ApplicationModel.DataTransfer.Clipboard')

; Show the available clipboard formats.
content := Clipboard.GetContent() ; is DataPackageView
formats := content.AvailableFormats ; is IVectorView<string>
message := "Current clipboard formats:`n"
Loop formats.Size
    message .= formats.GetAt(A_Index - 1) "`n"
MsgBox message

; If there's HTML on the clipboard, show its text and source URL.
if content.Contains('HTML Format') {
    fragment := content.GetHtmlFormatAsync().await()
    if RegExMatch(fragment, 'm)^SourceURL:(.*)\R\K(?s:.*)', &match) {
        ; Exercise for the reader: convert it to bbcode for pasting on the forum. :)
        MsgBox WinRT('Windows.Data.Html.HtmlUtilities').ConvertToText(match.0)
            . '`n`nSource: ' match.1
    }
    else MsgBox "Error parsing HTML fragment."
}
else MsgBox "Try copying text from a website and re-running this script."

; Demonstrate Clipboard History, if enabled.
if !Clipboard.IsHistoryEnabled() {
    MsgBox "Clipboard history is not enabled."
    ExitApp
}

result := Clipboard.GetHistoryItemsAsync().await()
if result.Status.n {
    MsgBox "GetHistoryItemsAsync failed: " String(items.Status)
    ExitApp
}

items := result.Items ; is IVectorView<ClipboardHistoryItem>
MsgBox "There are " items.Size " items in the Clipboard History."
; items.Item(0) returns the first item, which is a DataPackageView,
; like `content` above.  That's enough for this demonstration...
