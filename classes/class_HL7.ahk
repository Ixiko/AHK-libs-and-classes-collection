/*
 * 	HL7.ahk
 *
 * 	An AutoHotkey library/class to parse HL7 files into structured Autohotkey Objects.
 *
 * 	Originally written by "MA53": Timothy McNamara
 * 	Dedicated to the wonderful folks at http://www.ahkscript.org/ -- never stop doing what you do!
 *
 * 	Hosted on github at https://github.com/ma53/AutoHotkey-HL7
 *
 *  If you get some use out of this, find an issue with it, or see some room for improvement in it,
 *  let me know!  My code is always evolving.
 */
/*
# AutoHotkey-HL7

#### An [AutoHotkey](http://ahkscript.org/) library/class to parse [HL7](http://en.wikipedia.org/wiki/Health_Level_7) files into structured Autohotkey objects.

Tested in AutoHotkey v1.1.16.05

License: [GPLv3](http://www.gnu.org/copyleft/gpl.html)

- - -

## Usage

Simply include HL7.ahk somewhere in your script and invoke the HL7 class's parse() method:

````
; in most cases you will be working from an HL7 text file.
FileRead, HL7_Text, Sample_HL7.txt
Parsed_HL7 := HL7.parse(HL7_Text)
````
The parser is smart enough to detect and honor any specified encoding characters, even though most HL7 implementations do not deviate from the "suggested" values.

The HL7 class will parse your input and return an object of the following structure:

````
{
	"MSH" ; header
	[
		[ ; segment
			[ ; field
				[ ; "repeat"
					[ ; component
						[ ; subcomponent
							"Value"
						]
					]
				]
			]
		]
	]
	...
}
````

The input in the case above would have been:

````
MSH|Value
````

A simple sample script and HL7 message are included in the samples subdirectory.

- - -

## Implementation

Your message is returned as an object with each unique segment header as keys.  The values located at those keys are arrays of all segments which had that header.
Because HL7 messages can have any number of segments, with any number of fields, each of which may or may not have multiple repetitions, components, and subcomponents, the parser implies all levels no matter how many of each level are present.
This means that the actual "values" encoded in your HL7 message will be found in the most specific level possible: the subcomponent.
Fields that have no defined repeats, components, or subcomponents will therefore nontheless be returned as though they had one of each.
This structure is purposeful.  It is the only way to maintain a consistent and useful shape across the myriad of message structures made possibly by HL7's lax definition.

## Acknowledgements

The structure of the class is based largely on that of [cocobelgica's amazing JSON module](https://github.com/cocobelgica/AutoHotkey-JSON), of which I have made extensive use in my own personal projects for the last couple of years.

Everything I know about AutoHotkey has been absorbed from either the included help file or the amazing community at [ahkscript.org](http://ahkscript.org).  I've read hundreds of topics and replies by all of the all-star users over there...too numerous to recall.  Thanks to everyone who contributes to that awesome community!

*/

Class HL7 {

	parse(p_HL7_Text) {

		; This will match the message header and the field separator character, which is required for our
		; matches going forward.
		MSH_Needle := "O)^(?P<header>MSH)(?P<FieldSeparator>.)"
		RegExMatch(p_HL7_Text, MSH_Needle, MSH_Match)
		if !Field_Separator := MSH_Match["FieldSeparator"]
			Throw Exception("The HL7 library was unable to identify a field separator for the supplied input.")

		; If any of the encoding characters collide with reserved Regex symbols (which they do by default), we'll
		; need them to be escaped before putting them in any regex needles.
		Reserved_Characters     := "\.*?+[{|()^$"
		Escaped_Field_Separator := InStr(Reserved_Characters, Field_Separator) ? "\" . Field_Separator : Field_Separator

		; This will match each of the four specified encoding characters within the message header.  Due to the
		; structure of the needle, the match should fail if too few encoding characters were specified.  This will
		; lead to an exception being thrown shortly, which should safely end execution.
		MSH_Separators_Needle := "O)^MSH" . Escaped_Field_Separator . "(?P<ComponentSeparator>[^" . Escaped_Field_Separator "])(?P<FieldRepeatSeparator>[^" . Escaped_Field_Separator "])(?P<EscapeCharacter>[^" . Escaped_Field_Separator "])(?P<SubComponentSeparator>[^" . Escaped_Field_Separator "])"
		foundPos := RegexMatch(p_HL7_Text, MSH_Separators_Needle, Separators_Match)
		Component_Separator     := Separators_Match["ComponentSeparator"]
		Sub_Component_Separator := Separators_Match["SubComponentSeparator"]
		Field_Repeat_Separator  := Separators_Match["FieldRepeatSeparator"]
		Escape_Character        := Separators_Match["EscapeCharacter"]

		; We can't really parse the file without all of the encoding characters.  This will toss an exception if
		; for any reason one of these values is blank.
		if !Component_Separator
		|| !Sub_Component_Separator
		|| !Field_Repeat_Separator
		|| !Escape_Character
			Throw Exception("The HL7 library was unable to identify a separator character for the supplied input."
				, 0 ; this
				, !Component_Separator     ? "Component separator"
				: !Sub_Component_Separator ? "Sub-component separator"
				: !Field_Repeat_Separator  ? "Field repeat separator"
				: !Escape_Character        ? "Escape character"
				: "Unknown")

		; More character escaping.
		Escaped_Escape_Character        := InStr(Reserved_Characters, Escape_Character)        ? "\" . Escape_Character        : Escape_Character
		Escaped_Component_Separator     := InStr(Reserved_Characters, Component_Separator)     ? "\" . Component_Separator     : Component_Separator
		Escaped_Sub_Component_Separator := InStr(Reserved_Characters, Sub_Component_Separator) ? "\" . Sub_Component_Separator : Sub_Component_Separator
		Escaped_Field_Repeat_Separator  := InStr(Reserved_Characters, Field_Repeat_Separator)  ? "\" . Field_Repeat_Separator  : Field_Repeat_Separator

		; Going forward, we will want to match these separator characters, but only if they aren't escaped.
		; I've explicitly specified non-capturing groups here so that it won't throw off the structure of
		; our match objects in future matches .
		Field_Separator_Needle         := "(?:(?<!" . Escaped_Escape_Character . ")" . Escaped_Field_Separator         . ")"
		Component_Separator_Needle     := "(?:(?<!" . Escaped_Escape_Character . ")" . Escaped_Component_Separator     . ")"
		Sub_Component_Separator_Needle := "(?:(?<!" . Escaped_Escape_Character . ")" . Escaped_Sub_Component_Separator . ")"
		Field_Repeat_Separator_Needle  := "(?:(?<!" . Escaped_Escape_Character . ")" . Escaped_Field_Repeat_Separator  . ")"

		; Technically speaking, the segment separator character is "non-negotiable", unlike the other encoding
		; characters.  It's supposed to be a carriage return (Char 13)...however I have personally encountered
		; HL7 files improperly encoded using line feeds (Char 10) QUITE commonly.  Therefore, I match either.
		Segment_Separator_Needle := "(?:(?<!" . Escaped_Escape_Character . ")[\r\n])"

		; The MSH segment is the only segment that's really required.  Since it exists at the very beginning
		; of the file (and does not follow after a segment separator character), I match it here individually
		; and then shove it in with the rest of the segments to be parsed later.
		MSH_Segment_Needle   := "O)^(?P<Header>MSH)(?P<Segment>" . Field_Separator_Needle . ".*?)" . Segment_Separator_Needle
		MSH_Segment_Position := RegExMatch(p_HL7_Text, MSH_Segment_Needle, MSH_Segment_Match)
		MSH_Header  := MSH_Segment_Match["Header"]
		MSH_Segment := MSH_Segment_Match["Segment"]
		if !MSH_Header
			Throw Exception("The HL7 library was unable to identify an MSH header for the supplied input.")
		if !MSH_Segment
			Throw Exception("The HL7 library was unable to identify an MSH segment for the supplied input.")

		; This is the object into which we will dump all segments we find in the HL7 file, to be later
		; enumerated and parsed.  Since we've already matched the MSH segment, we'll go ahead and
		; drop that in.
		Segments := []
		Segments.Insert([MSH_Header, MSH_Segment])

		; Now to go and match all of the segments in the file!
		; We'll begin the search just after the MSH segment we found.
		Segment_Match_Start_Position := MSH_Segment_Position + StrLen(MSH_Header . MSH_Segment)
		Segment_Needle := "O)(?<Separator>" . Segment_Separator_Needle . ")(?P<Header>\w{3})(?P<Segment>" . Field_Separator_Needle ".*?)(" . Segment_Separator_Needle . "|$)"
		Loop
		{
			Segment_Match_Found_Position := RegExMatch(p_HL7_Text, Segment_Needle, Segment_Match, Segment_Match_Start_Position)

			; if RegExMatch returns 0, it means there are no matches to be found to the right of the
			; specified starting position.  To us, it means we've found all of the segments and can
			; exit this loop.
			if !Segment_Match_Found_Position
				break

			; Since there can be more than one instance of a header in an HL7 file, we unfortunately
			; cannot use the header as a unique key.  Structurally speaking, however, the header is
			; not actually a field within the segment, so we'll keep it separate.
			Segments.Insert([Segment_Match["Header"], Segment_Match["Segment"]])
			; This means that the array of segments will look something like this:
			;
			/**
			 *  Segments
			 * 	[
			 * 		[ "Header1", "PlaintextSegment1" ]
			 * 		[ "Header2", "PlaintextSegment2" ]
			 * 		[ "Header1", "PlaintextSegment3" ]
			 *  ]
			 */

			; We'll start the next match attempt just after the match we just made.
			Segment_Match_Start_Position := Segment_Match_Found_Position + StrLen(Segment_Match["Header"] . Segment_Match["Segment"])
		}

		; Having acquired matches for all of the segments contained in the file, we can now recurse
		; into them and extract their guts!
		;
		; The recursion will follow a set progression through; the delimiters we've identified. We
		; construct an array of delimiters using the values we identified from the MSH segment
		; earlier and pass that to the recursing function which will progress through them as it
		; iterates.
		Array_Of_Delimiter_Neeldes := [ Field_Separator_Needle, Field_Repeat_Separator_Needle, Component_Separator_Needle, Sub_Component_Separator_Needle ]

		; this is the actual array we'll be returning at the end of the method.
		Parsed_Structure := []

		; Here's where the magic finally happens.  We're going to iterate through all of the
		; segments and recursively parse their content.
		For Index, Segment in Segments
		{
			; Segment[2] is the actual text of the segment, which you'll recall from the earlier
			; description of the Segments array's structure.  Segment_Separator_Needle is required
			; for the parser to perform its matches accurately, as is the Array_Of_Delimiter_Neeldes
			; we discussed above.  The Escaped_Escape_Character is needed for the parser to clean
			; up any escaped characters within the fields so that they come out as un-escaped plain
			; text.
			HL7_Structure := this.Recurse_HL7(Segment[2], Segment_Separator_Needle, Array_Of_Delimiter_Neeldes, Escaped_Escape_Character)

			; The parser method works perfectly for every single segment and field except one.  The
			; first field within the MSH segment is the one that includes all of the encoding
			; characters in all their naked, un-escaped glory.  This kills the parser.  Rather than
			; trying to design some incredibly arcane needle to account for that in all segments, I
			; simply replace the first field of any segment whose header is "MSH" with a
			; contstruction of all of the encoding characters we identified at the beginning of the
			; method.  In theory and in my practice, the results are identical.
			if ( Segment[1] = "MSH" )
				HL7_Structure[1] := [[[Component_Separator . Field_Repeat_Separator . Escape_Character . Sub_Component_Separator]]]

			; Segment[1] is the header of the segment, if you recall.
			; Parsed_Structure.Insert([Segment[1], HL7_Structure])
			if !IsObject(Parsed_Structure[Segment[1]])
				Parsed_Structure[Segment[1]] := []
			Parsed_Structure[Segment[1]].Insert(HL7_Structure)

			; So at the end of the day, what I'm gonna return to you will look something like this:
			;
			/**
			 *  {
			 *  	"MSH"
			 *  	[
			 *  		[[[[["Field1"]]]], [[[["Field2"]]]], ... ]
			 *  	]
			 *  	"PID"
			 *  	[
			 *  		[[[[["Schmidt"], ["John"], ["Jacobjingleheimer"]]]], [[[["Field2"]]]], ... ]
			 *  		[[[[["Murphy"], ["Dade"]]]], [[[["Zero Cool"], ["Crash Override"]]]], ... ]
			 *  		...
			 *  	]
			 *   	...
			 *  }
			 */
			;
			; It's important to note that if you have more than one segment with the same header
			; (which is possible if not common), they will all end up in an array located at the
			; key equal to their header.  This deviates slightly from HL7's inherent structure,
			; but it buys a lot of utility later on (such as being able to locate segments based
			; on their header, or being able to know how many segments share a header).
		}

		; And, finally, the deed is done.
		return Parsed_Structure

	}

	Recurse_HL7(p_HL7_Text, p_Segment_Separator_Needle, p_Array_Of_Delimiter_Needles, p_Escaped_Escape_Character, p_Delimiter_To_Start_At := 1) {
		; Of the array of delimiters we were passed, pull out the one at the position we were told
		; to look at.
		Current_Delimiter_Needle := p_Array_Of_Delimiter_Needles[p_Delimiter_To_Start_At]

		; If there isn't one there, that means we've recursed down to the most specific field, and
		; we can start returning up the stack.  Before we return the values from the fields,
		; however, we need to clean them up.
		if !Current_Delimiter_Needle
			return this.Clean_HL7(p_HL7_Text, p_Array_Of_Delimiter_Needles, p_Escaped_Escape_Character)

		; If we haven't returned before this point, it means we've got more work to do!  We'll
		; assemble our Regex needle using the delimiter we were instructed to use on this level
		; and grab everything we can find.
		Current_Needle := "O)" . "(" . Current_Delimiter_Needle . ")?.*?(?=(" . Current_Delimiter_Needle . "|" . p_Segment_Separator_Needle . "|" . "$" . "))"
		r_Structure := []
		Match_Start_Position := 1
		Loop {
			; This loop should look pretty familiar if you've been reading from start to finish.
			Match_Found_Position := RegExMatch(p_HL7_Text, Current_Needle, Match, Match_Start_Position)

			; If RegExMatch returns 0, that means we've found everything we're going to find and
			; we can stop iterating.  Same is true if we found a blank value, which only happens
			; when a section is left blank.
			if !Match_Found_Position
			|| !Match.value()
				break

			; WE HAVE TO GO DEEPER.  We pass the text we've found on this loop iteration into
			; the next level of the recurser, and tell it to look for the delimiter after the
			; one we're using now.
			r_Structure.Insert(this.Recurse_HL7(Match.value(), p_Segment_Separator_Needle, p_Array_Of_Delimiter_Needles, p_Escaped_Escape_Character, p_Delimiter_To_Start_At + 1))

			; Once we've recursed that level, it's time to iterate again on our own level.
			Match_Start_Position := Match_Found_Position + ( StrLen(Match.value()) = 0 ? 1 : StrLen(Match.value()) )
		}

		; And voila!  Ready to return.
		return r_Structure
	}

	Clean_HL7(p_HL7_Text, p_Array_Of_Delimiter_Needles, p_Escaped_Escape_Character) {
		; We'll iterate throuh each delimiter that is to be expected and replace them
		; with nothing.
		For index, Delimiter_Needle in p_Array_Of_Delimiter_Needles
			p_HL7_Text := RegExReplace(p_HL7_Text, Delimiter_Needle)

		; All that's left to clean up after that is any encoding character that has been
		; escaped.  In these instances, we replace the escaped character with an
		; un-escaped version of itself.
		p_HL7_Text := RegExReplace(p_HL7_Text, p_Escaped_Escape_Character . "(.)" , "$1")

		; Tadaa!  Ready to go back up the stack.
		return p_HL7_Text
	}
}