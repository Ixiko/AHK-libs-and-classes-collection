/**
 * Class:
 *     Mustache.ahk - AutoHotkey based mustache template system.
 *
 * Version: 
 *     v0.1.0-alpha
 *
 * Lisence:
 *     MIT [https://opensource.org/licenses/MIT]
 *
 * Requirements:
 *     AutoHotkey v1.1.21.00+
 *
 * Installation:
 *     Save this file as Mustache.ahk in your library folder and
 *     include it using #Include <Mustache>.
 *
 * Links:
 *     Github - https://github.com/sidola/Mustache.ahk
 *
 * Usage:
 *     template := "Here's a value: {{myKey}}"
 *     compiledTemplate := Mustache.Compile(template)
 * 
 *     dataObject := {myKey: "myValue"}
 *     renderedTemplate := Mustache.render(compiledTemplate, dataObject)
 */
class Mustache {

    ; ----------------------------------
    ; Public API
    ; ----------------------------------
    
    /**
     * Compiles the given template into a compiled template
     * that can be used to render information.
     *
     * The compiled template can be stored and re-used for
     * better performance.
     * 
     * @param {string} template
     *        A string-based template to compile.
     *
     * @returns {object} A compiled template that can be used
     * by the Mustache.Render() method.
     */
    Compile(template) {
        startMarker := ["{", "{"]
        endMarker := ["}", "}"]

        reader := new Mustache.Reader(template)
        compiler := new Mustache.Compiler()

        return compiler.Compile(reader, startMarker, endMarker, "", false, true)
    }

    /**
     * Renders a compiled template, replacing mustache tags
     * with data provided by the data object.
     * 
     * @param {object} compiledTemplate
     *        A compiled template.
     * @param {object} dataObject
     *        The data to use with the template.
     *
     * @returns A rendered mustache template.
     */
    Render(compiledTemplate, dataObject) {
        writer := new Mustache.Writer()
        parser := new Mustache.Parser()

        parser.Parse(writer, compiledTemplate, dataObject)

        return RTrim(writer.Flush(), "`n")
    }

    ; ----------------------------------
    ; Private API
    ; ----------------------------------

    class Compiler {

        static linebreakChar := "`n"

        Compile(reader, startMarker, endMarker, tagName := ""
            , iterable := false, whitespace := true) {

            tokens := []
            textBuffer := ""

            currentLine := 1
            startOfLine := true
            onlyWhitespace := whitespace
            skipNextLinebreak := false

            while((char := reader.Read()) || char == 0) {

                if (char == this.linebreakChar) {

                    if (skipNextLinebreak == false) {
                        textBuffer .= char
                    } else {
                        skipNextLinebreak := false
                    }

                    textBuffer := this.WriteTextBuffer(tokens, textBuffer)

                    currentLine++
                    startOfLine := true
                    onlyWhitespace := true

                    continue
                }
                ; Encountered a non-whitespace, non-linebreak char, wipe
                ; the previous request to skip a linebreak
                else if (!Mustache.Util.IsWhitespaceChar(char) && skipNextLinebreak) {
                    skipNextLinebreak := false
                }

                ; Look for tags
                if (char == startMarker[1]) {
                    reader.Mark()
                    
                    if (reader.Read() != startMarker[2]) {
                        ; Roll back and continue reading
                        reader.Reset()
                    } else {
                        
                        ; Start command capture
                        command := ""
                        trippleEscaped := false

                        while ((char := reader.Read()) || char == 0) {
                            reader.Mark()

                            if (char == "{")
                                trippleEscaped := true

                            if (char == "}" && trippleEscaped) {
                                command .= char
                                trippleEscaped := false
                                continue
                            }

                            if (char == endMarker[1]) {
                                if (reader.Read() == endMarker[2]) {
                                    ; End command capture
                                    break
                                } else {
                                    ; Roll back and continue reading
                                    reader.Reset()
                                }
                            }

                            command .= char
                        }

                        ; Process captured command
                        if (!command)
                            msgBox % "Error, no command"

                        command := Trim(command)
                        commandTagType := SubStr(command, 1, 1)
                        commandTagName := Trim(SubStr(command, 2))

                        if (!this.isCommand(commandTagType)) {

                            textBuffer := this.WriteTextBuffer(tokens, textBuffer)
                            tokens.Push(Mustache.Token.VariableToken(command))

                        } else {

                            ; Comment
                            if (commandTagType == "!") {
                                if (this.IsStandaloneTag(onlyWhitespace, reader)) {
                                    skipNextLinebreak := true
                                    textBuffer := ""
                                }
                            }

                            ; Section element
                            if (commandTagType == ".") {
                                ; If we're not in a section right now
                                ; this is generally not allowed...
                                if (!iterable)
                                    msgBox % "Error, element outside iterable"

                                textBuffer := this.WriteTextBuffer(tokens, textBuffer)
                                tokens.Push(Mustache.Token.ElementToken())
                            }

                            ; Escaped variable
                            if (commandTagType == "&" || commandTagType == "{") {

                                if (commandTagType == "{") {
                                    commandTagName := SubStr(commandTagName, 1, StrLen(commandTagName) - 1)
                                    commandTagName := Trim(commandTagName)
                                }

                                textBuffer := this.WriteTextBuffer(tokens, textBuffer)
                                tokens.Push(Mustache.Token.EscapedVariableToken(commandTagName))
                            }

                            ; Section
                            if (commandTagType == "#") {

                                childTokens := this.Compile(reader, startMarker, endMarker
                                    , commandTagName, true, onlyWhitespace)

                                ; This is our last chance to flush the
                                ; text buffer of whitespace... But we have
                                ; no idea what's ahead of us?
                                ;
                                ; So we could peek at the first child token?
                                ; If that's a linebreak, we know that nothing
                                ; followed the opening-tag.
                                ;
                                ; Ah, but that linebreak is never added! So
                                ; that's not possible...
                                ;
                                ; We could leave it in and pop it out here
                                ; instead...

                                firstChild := childTokens[1]
                                if (Mustache.Util.IsEmptyLine(firstChild.value) && onlyWhitespace) {

                                    ; Drop the first child
                                    childTokens := Mustache.Util.SliceArray(childTokens, 2)
                                    ; Empty the buffer
                                    textBuffer := ""

                                }

                                textBuffer := this.WriteTextBuffer(tokens, textBuffer)
                                tokens.Push(Mustache.Token.SectionToken(commandTagName, childTokens))

                                ; Now we need to figure out if the next
                                ; linebreak should be swallowed or kept.
                                ; This depends on if the section ends on
                                ; a linebreak or not. So let's peek at the
                                ; last child.

                                lastChildIndex := childTokens.Length()
                                lastChild := childTokens[lastChildIndex]

                                if (Mustache.Util.ContainsLinebreak(lastChild.value) 
                                    || childTokens.Length() == 0) {

                                    ; This isn't a trustworthy flag if
                                    ; we're chaining sections.
                                    ;
                                    ; A trim for section A will
                                    ; trim the linebreak for section B.
                                    ; You need a way to wipe it if
                                    ; there's chars before the next linebreak.
                                    ;
                                    ; I feel like this is a hack for a proper
                                    ; look-ahead, but the fucking whitespace
                                    ; makes looking-ahead seem more difficult
                                    ; than time travel.
                                    skipNextLinebreak := true
                                }
                            }
                            
                            ; Inverted
                            if (commandTagType == "^") {
                                childTokens := this.Compile(reader, startMarker, endMarker
                                    , commandTagName, true, onlyWhitespace)

                                ; TODO: Similar to Section logic, can we refactor out?
                                firstChild := childTokens[1]
                                if (Mustache.Util.IsEmptyLine(firstChild.value) && onlyWhitespace) {
                                    childTokens := Mustache.Util.SliceArray(childTokens, 2)
                                    textBuffer := ""
                                }

                                textBuffer := this.WriteTextBuffer(tokens, textBuffer)
                                tokens.Push(Mustache.Token.InvertedToken(commandTagName, childTokens))

                                lastChildIndex := childTokens.Length()
                                lastChild := childTokens[lastChildIndex]

                                if (Mustache.Util.ContainsLinebreak(lastChild.value)
                                    || childTokens.Length() == 0) {
                                    skipNextLinebreak := true
                                }
                            }

                            ; Closing
                            if (commandTagType == "/") {
                                if (commandTagName != tagName) {
                                    throw Mustache.CompilerException("Different closing tag", command)
                                }

                                if (this.IsStandaloneTag(onlyWhitespace, reader)) {
                                    textBuffer := ""
                                }

                                textBuffer := this.WriteTextBuffer(tokens, textBuffer)
                                return tokens
                            }

                        } ; Specific command capture ends

                        continue
                    } ; Tag capture ends
                } ; Tag search ends

                onlyWhitespace := (onlyWhitespace 
                    && Mustache.Util.IsWhitespaceChar(char))

                textBuffer .= char
            }

            textBuffer := this.WriteTextBuffer(tokens, textBuffer)

            if (iterable) {
                msgBox % "Error, unclosed tag"
            }

            return tokens
        }

        WriteTextBuffer(ByRef tokens, textBuffer) {
            if (textBuffer) {
                tokens.Push(Mustache.Token.TextToken(textBuffer))
            }

            return ""
        }

        IsCommand(commandType) {
            ; Study-option is on for extra speed.
            ; This is a fast solution, believe it or not.
            return RegExMatch(commandType, "S)(#|\/|&|\^|\.|\{|!|\>)")
        }

        /**
         * Returns true if there's only whitespace until the next linebreak.
         *
         * This method will return the reader-pointer to the point
         * it was at when this method was called.
         *
         * @param {boolean} whitespaceBefore
         *        The current whitespace state.
         * @param {Reader} reader
         *        The reader at its current pointer.
         */
        IsStandaloneTag(whitespaceBefore, reader) {
            if (!whitespaceBefore)
                return false

            isStandaloneTag := true
            reader.Mark()

            while ((char := reader.Read()) || char == 0) {
                if (!Mustache.Util.IsWhitespaceChar(char) && char != this.linebreakChar) {
                    isStandaloneTag := false
                    break
                }

                ; New line, we're done here
                if (char == this.linebreakChar) {
                    break
                }
            }

            reader.Reset()
            return isStandaloneTag
        }
    }    

    class Parser {

        Parse(writer, tokens, globalHash, scopedHash := "") {
            for _, thisToken in tokens {

                tokenType := thisToken.type
                tokenValue := thisToken.value

                if (!tokenType)
                    throw Mustache.ParserException("No token type", thisToken)
                if (!tokenValue)
                    throw Mustache.ParserException("No token value", thisToken)

                ; Text token
                if (tokenType == "T") {
                    writer.Write(tokenValue)
                    continue
                }
                
                ; Variable token / Un-escaped variable token
                if (tokenType == "V" || tokenType == "&") {
                    hashValue := this.FindHashValue(globalHash, scopedHash, tokenValue)

                    if (tokenType != "&") {
                        hashValue := this.HtmlEscape(hashValue)
                    }

                    if (Mustache.Util.IsFloat(hashValue)) {
                        hashValue := Mustache.Util.TrimFloat(hashValue)
                    }

                    writer.Write(hashValue)
                    continue
                }

                ; Inverted
                if (tokenType == "I") {
                    hashValue := this.FindHashValue(globalHash, scopedHash, tokenValue)

                    if (hashValue) {
                        if (!IsObject(hashValue)) {
                            continue
                        }

                        ; There is still something in here check object size
                        if (hashValue.NewEnum().Next()) {
                            continue
                        }
                    }

                    this.Parse(writer, thisToken.tokens, globalHash, hashValue)
                }

                ; Section token
                if (tokenType == "S") {
                    hashValue := this.FindHashValue(globalHash, scopedHash, tokenValue)

                    isObjectValue := IsObject(hashValue)
                    if (isObjectValue) {
                        isArrayValue := Mustache.Util.IsArray(hashValue)
                    }

                    ; Basic value
                    if (!isObjectValue) {
                        if (hashValue) {
                            this.Parse(writer, thisToken.tokens, globalHash)
                        }

                        continue
                    }

                    ; Basic array
                    if (isArrayValue) {
                        ; Empty arrays are falsey
                        if (hashValue.Length() == 0) {
                            continue
                        }

                        for _, hashEntry in hashValue {
                            this.Parse(writer, thisToken.tokens
                                , globalHash, hashEntry)
                        }

                        continue
                    }

                    ; Object list
                    if (isObjectValue) {

                        ; Empty list is falsey
                        if (!hashValue.NewEnum().Next()) {
                            continue
                        }

                        extendedScope := hashValue

                        if (scopedHash) {
                            for hashKey, hashValue in hashValue {
                                scopedHash[hashKey] := hashValue
                            }

                            extendedScope := scopedHash
                        }

                        this.Parse(writer, thisToken.tokens
                            , globalHash, extendedScope)

                        continue
                    }
                } ; Section ends

                ; Element (section) token
                if (tokenType == "E") {

                    isObjectHash := IsObject(scopedHash)
                    if (isObjectHash)
                        isArrayHash := Mustache.Util.IsArray(scopedHash)

                    if (isObjectHash && !isArrayHash) {
                        throw Mustache.ParserException("Scoped hash was an object", thisToken)
                    } else if (!scopedHash) {
                        throw Mustache.ParserException("No scoped hash found", thisToken)
                    }

                    if (Mustache.Util.IsFloat(scopedHash)) {
                        scopedHash := Mustache.Util.TrimFloat(scopedHash)
                    }

                    if (isArrayHash) {

                        msgBox % "Running that weird flatArray element logic!"

                        ; TODO: I don't understand this
                        ; What are we actually doing here?
                        flatArray := ""
                        for _, hashValue in scopedHash {
                            flatArray .= hashValue
                        }
                        writer.Write(flatArray)

                    } else {
                        writer.Write(scopedHash)
                    }

                    continue
                }

                if (tokenType == "P") {
                    this.Parse(writer, thisToken.tokens, globalHash, hashValue)
                }

            }
        }

        ResolveScopedKey(globalHash, scopedHash, key) {
            ; Split the token value on dots
            ; Read the parts left to right
            ; Climb the hash until all parts
            ; have been consumed - If we fail
            ; along the way, return an empty value

            keyParts := StrSplit(key, ".")

            rootKey := keyParts[1]
            targetHash := scopedHash[rootKey]
            keyMiss := false

            for _, keyPart in keyParts {
                if (A_Index == 1) ; RootKey, skip
                    continue

                if (!targetHash.HasKey(keyPart)) {
                    keyMiss := true
                    break
                }

                targetHash := targetHash[keyPart]
            }

            if (!keyMiss) {
                if (IsObject(targetHash))
                        return ""
                    else
                        return targetHash
            }

            targetHash := globalHash[rootKey]
            keyMiss := false

            for _, keyPart in keyParts {
                if (A_Index == 1) ; RootKey, skip
                    continue

                if (!targetHash.HasKey(keyPart)) {
                    keyMiss := true
                    break
                }

                targetHash := targetHash[keyPart]
            }

            if (keyMiss) {
                return ""
            } else {
                if (IsObject(targetHash))
                        return ""
                    else
                        return targetHash
            }
        }

        FindHashValue(globalHash, scopedHash, key) {
            if (key == ".") {
                if (!Mustache.Util.IsArray(scopedHash)) {
                    throw Mustache.ParserException("Expected scoped hash to be an array")
                }

                return scopedHash
            } 
            
            if (InStr(key, ".")) {
                return this.ResolveScopedKey(globalHash, scopedHash, key)
            }

            if (!value)
                value := scopedHash[key]
            if (!value)
                value := globalHash[key]

            return value
        }

        HtmlEscape(value) {
            escapeChars := {}
            ; " is replaced with &quot;
            escapeChars[""""] := "&quot`;"
            ; & is replaced with &amp;
            escapeChars["&"] := "&amp`;"
            ;< is replaced with &lt;
            escapeChars["<"] := "&lt`;"
            ;> is replaced with &gt;
            escapeChars[">"] := "&gt`;"

            escapedValue := ""
            for k, v in StrSplit(value) {
                escapeSeq := escapeChars[v]

                if (escapeSeq)
                    escapedValue .= escapeSeq
                else
                    escapedValue .= v
            }

            return escapedValue
        }
    }

    ; ----------------------------------
    ; Private API - Util
    ; ----------------------------------

    CompilerException(string, command) {
        title := "`n{{ mustache exception }}"
        message := title . "`nMessage: " . string

        if (command) {
            message .= "`n`nCommand:`n"
            message .= command
        }

        return Exception(message, -1)
    }

    ParserException(string, token := "") {
        /*
            Error: {{ mustache exception }}
            Message: <string>
            
            Token: ...?
        */

        title := "`n`n{{ mustache exception }}"
        message := title . "`nMessage: " . string

        if (token) {
            message .= "`n`nToken:`n"
            message .= "Type: " token.type
            message .= "`nValue: " token.value
        }

        return Exception(message, -1)
    }

    class Util {

        IsWhitespaceChar(char) {
            if (StrLen(char) > 1) {
                length := StrLen(char)

                msg := Format("Invalid param: {1:}, expected 1 char, received {2:} chars"
                    , char, length)

                throw Exception(msg, -1)
            }

            return (char == A_Space || char == A_Tab || char == "`r")
        }

        IsEmptyLine(value) {
            for _, char in StrSplit(value) {
                if (!this.IsWhitespaceChar(char) && char != "`n") {
                    return false
                }
            }

            return true
        }

        ContainsLinebreak(value) {
            ; Works on both \n and `n
            return RegExMatch(value, "\n")
        }

        SliceArray(array, fromInclusive, toExclusive := false) {
            newArray := []
            toExclusive := (toExclusive) ? toExclusive : array.Length()

            i := fromInclusive
            while (i <= array.Length()) {
                if (toExclusive < i)
                    break

                newArray.Push(array[i])
                i++
            }

            return newArray
        }

        /**
         * Stolen from the JSON lib created by Coco
         * https://github.com/cocobelgica/AutoHotkey-JSON
         */
        IsArray(value) {
            isArray := 0

            ; Check indexes until they stop
            ; being numbers. Pretty clever.
            for k in value {
                isArray := (k == A_Index)
            }
            until (!isArray)

            return isArray
        }

        IsEmptyObject(value) {
            return IsObject(value) && !value.NewEnum().Next()
        }

        TrimFloat(floatValue) {
            ; We do what we must to pass
            ; the damn tests!
            floatValue := RTRim(floatValue, 0)
            decimalCount := StrLen(StrSplit(floatValue, ".")[2])
            floatValue := Round(floatValue, decimalCount)

            return floatValue
        }

        IsFloat(value) {
            if value is float
                return true

            return false
        }
    }

    ; ----------------------------------
    ; Private API - Components
    ; ----------------------------------

    class Token {
        __New(type, value) {
            this.type := type
            this.value := value
        }

        TextToken(textBuffer) {
            return new this("T", textBuffer)
        }

        VariableToken(variable) {
            return new this("V", variable)
        }

        EscapedVariableToken(variable) {
            return new this("&", variable)
        }

        SectionToken(variable, childTokens) {
            t := new this("S", variable)
            t.tokens := childTokens

            return t
        }

        InvertedToken(variable, childTokens) {
            t := new this("I", variable)
            t.tokens := childTokens

            return t
        }

        ElementToken() {
            return new this("E", ".")
        }

        StringifyTokens(tokens, indentLevel := 0) {
            output := ""
            
            for _, t in tokens {
                v := RegExReplace(t.value, "`n", "\n")
                v := RegExReplace(v, " ", ".")
                
                Loop % indentLevel
                    output .= " "

                output .= Format("[{1:} : {2:}]", t.type, v) . "`n"

                if (t.tokens)
                    output .= this.StringifyTokens(t.tokens, (indentLevel+2))
            }

            return output
        }
    }

    class Reader {
        __New(string) {
            this.buffer := StrSplit(string)
            this.pointer := 0
        }

        Mark() {
            this.markedPoint := this.pointer
        }

        Read() {
            if (this.pointer == this.buffer.Length()) {
                return ""
            }

            this.pointer++
            return this.buffer[this.pointer]
        }

        Reset() {
            newPointer := 0
            if (this.markedPoint)
                newPointer := this.markedPoint

            this.pointer := newPointer
        }
    }

    class Writer {
        Write(string) {
            this.string .= string
        }

        Flush() {
            returnString := this.string
            this.string := ""

            return returnString
        }
    }
}