# C++ Constants Scanner/Database

## Highlights
* Flexible and searchable database for referencing API constants.
* Select source C++ header and optionally define additioinal #INCLUDES, or entire directories to scan for more headers/constants.
* Setup this script with a compiler of your choice for checking constants (recommended MSVC BuildTools or GCC variant, like MinGW32/64 or TDGCC).
* Easily compile constants into a small test program to check constant value from the compiler of your choice.
* After scanning, a searchable Includes List is generated, showing child includes for each listed include.

## Details

This script is for making the process of exploring API functions easier.  You can generate and search lists that contain constants for a selected API.  Each constant is logged with lots of data, like src file and line number, so you can easily track down where that constant is in the source code.  You can also optionally do a quick check of the constant value through a compiler.

Currently this script attempts to resolve constant values without the compiler, but only does so for simple math expressions.  Since it is possible to check the constant value through the compiler, I will be updating this script over time as I learn the various ways numbers are expressed in C++ (ie. type casting).

Constant values that can be resolved, or types that can be determined, are categorized to assist with searching.  The rest are left as "Unknown".  The "Other" type usually describes constants that are structs, enums, arrays, or an alias for a macro or function.

It is important to note that the "scanner" portion of this script is not "hyper intelligent".  A single constant can have multiple values depending on how related constant values are defined.  Some of these values must be user defined.  So programatically resolving all constants isn't completely feasible.  Because of this, it is also not feasible to be able to test/compile all constants unless the proper user-defined constants are entered into the source code before compiling (you must check the source code and documentation for the API you are exploring to find out what these special constants are).  Providing the ability to define constants prior to compiling/testing is planned, but is currently not supported.


Constant values with multiple definitions are referred to as "Dupes".  "Critical" constants are defined as those whose value depends on one or more "Dupes".  You can filter out critical and dupe constants if desired.  You can also see all the dupe and critical info for each constant that has this type of info.

## Currently included API databases:

* Windows 10 API - as of 2020 Aug\
123,088 constants / 78,964 Integers / Dupes: 5,695 / Critical: 3,435

* Win32 headers from mingw64 (msys2 repo) as of 2020 Dec\
106,414 constants / 68,708 Integers / Dupes: 2,408 / Critical: 3,436

* scintilla API v4.4.3\
3,071 constants / 3,066 Integers / Dupes and Critical: 0

## Planned changes:

* Add a framework to allow user-defined values for constants before testing/compiling.
* Add catalogging of ENUMs, STRUCTs, and a few other types for searching.

Please use the latest AutoHotkey v2 alpha (currently a122).

https://www.autohotkey.com/download/2.0/
