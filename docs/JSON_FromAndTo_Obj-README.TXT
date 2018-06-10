AutoHotkey Object conversion to/from JSON. Copyright © 2013 VxE. All rights reserved.

This library is compatible with AutoHotkey 1.1.08.00 and later versions.

JSON_FromObj: serializes an object as JSON-like text OR formats a string for inclusion in such text.
  NOTE: scientific notation is treated as a string and hexadecimal as a number.
  NOTE: UTF-8 sequences are encoded as-is, NOT as their intended codepoint.

JSON_ToObj: deserializes JSON-like text and returns an object representation of its structure and data.
  NOTE: does not use REGEX
  NOTE: does not use recursion.
