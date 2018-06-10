# Mini-Framework,  version 0.4.0.5

Library of Mini-Framework
Copyright (c) 2013, -  2017 Paul Moss
Licensed under the [GNU General Public License GPL-2.0](License.htm)

Requires [AutoHotkey](http://ahkscript.org/)  [v1.1.21+]

## Introduction

Mini-Framework is as  collection of classes built for [AutoHotkey](http://ahkscript.org/) that  help give functionality similar to a strongly typed language. The [MfType](MfType.htm) class can be used to  get information from an object. All objects have a GetType() method that returns  an instance of the [MfType](MfType.htm) class. All object inherit from [MfObject](MfObject.htm) and therefore inherit all the  [methods](MfObjectMethods.htm)  of [MfObject](MfObject.htm).

Mini-Framework  attempts to bridge the gap between the powerful scripting language of [AutoHotkey](http://ahkscript.org/) and a more strongly typed language. The classes are built in a  Mono/.Net style.

The Mini-Framework classes are built with the  power of strongly type object while maintaining flexibility with [AutoHotkey](http://ahkscript.org/) variables. Many of the classes accept variables in their methods,  constructors and overloads methods to make using this framework  flexible.

All the Classes in System root Namespace are  prefixed with Mf to help  avoid any conflicts with naming conventions and variables in existing  projects.

There is also a package available for [Sublime  Text](http://www.sublimetext.com/) to give [intellisense](https://en.wikipedia.org/wiki/Intelligent_code_completion) and syntax highlighting to  Mini-Framework.

All objects derived from [MfObject](MfObject.htm) use a  Zero-Based index.

### On the  Web

GitHub Home page can be found at <https://github.com/Amourspirit/Mini-Framework>

The On-line version of this document can be  found at <https://amourspirit.github.io/Mini-Framework/> 

### Namespaces

This framework loosely uses name-spaces.  AutoHotkey does on support Namespace at this time and this framework mimics  name-spaces by using includes organizes in specific groups. See [Namespace](NameSapce.htm) for more  information.

### Primitives

Mini-Framework has  what might be considered primitives in other languages. These are objects that  are used to represent string and numbers in a more object oriented  way.
See core numeric related classes [here](NS_System.htm#Numeric).

- [MfChar](MfChar.htm)  represents a Unicode character.  
- [MfString](MfString.htm) represents a string.([StringBuilder](StringBuilder.htm) represents a  mutable string of characters)  
- [MfBool](MfBool.htm)  represents a boolean.  
- [MfByte](MfByte.htm)  represents a Byte with a [MinValue](MfByteMinValue.htm) and a [MaxValue](MfByteMaxValue.htm).  
- [MfInt16](MfInt16.htm)  represents a signed 16 bit integer with a [MinValue](MfInt16MinValue.htm) and a [MaxValue](MfInt16MaxValue.htm)  (short).  
- [MfInteger](MfInteger.htm) represents a signed 32 bit integer with a [MinValue](MfIntegerMinValue.htm) and a [MaxValue](MfIntegerMaxValue.htm)  (Int32).  
- [MfInt64](MfInt64.htm)  represents a signed 64 bit integer with a [MinValue](MfInt64MinValue.htm) and a [MaxValue](MfInt64MaxValue.htm)  (long).  
- [MfFloat](MfFloat.htm)  represents a signed float. (double)  
- [MfSByte](MfSByte.htm)  represents a signed Byte with a [MinValue](MfSByteMinValue.htm) and a [MaxValue](MfSByteMaxValue.htm).  
- [MfUInt16](MfUInt16.htm) represents a unsigned 16 bit integer with a [MinValue](MfUInt16MinValue.htm) and a [MaxValue](MfUInt16MaxValue.htm)  (ushort).  
- [MfUInt32](MfUInt32.htm) represents a unsigned 32 bit integer with a [MinValue](MfUInt32MinValue.htm) and a [MaxValue](MfUInt32MaxValue.htm)  (uint32).  
- [MfUInt64](MfUInt64.htm) represents a unsigned 64 bit integer with a [MinValue](MfUInt64MinValue.htm) and a [MaxValue](MfUInt64MinValue.htm)  (ulong). (For bigger numbers  use [MfBigInt](MfBigInt.htm)) 

### List/Array/Dictionary/HashTable

Mini-Framework has  several classes to help with List, Arrays and  Dictionaries such as  [MfCollection](MfCollection.htm), [MfDictionary](MfDictionary.htm), [MfGenericList](MfGenericList.htm),  [MfList](MfList.htm), [MfQueue](MfQueue.htm), [MfHashTable](MfHashTable.htm) and  [MfStack](MfStack.htm).

Classes such as [MfCollectionBase](MfCB16.htm), [MfDictionaryBase](MfDB16.htm) and [MfListBase](MfListBase.htm) can be used  in your project to create custom list and dictionary classes. See core list  related classes [here](NS_System.htm#List).

### Exceptions

Exceptions are used  extensively throughout Mini-Framework to gather and display error information. All exceptions are derived  from the [MfException](MfException.htm) class. Exceptions  are used in place of AutoHotkey [Exception](http://ahkscript.org/docs/commands/Throw.htm#Exception) and [ErrorLevel](https://autohotkey.com/docs/misc/ErrorLevel.htm) unless otherwise noted. See core  exceptions classes [here](NS_System.htm#Exceptions).

### Method  Overloads

Mini-Framework uses  method overloading extensively. Overloading allows a method to have different  variations of parameters based upon the type that is passed in. For an example  of Overloads see the [MfTimeSpan](MfTimeSpan.htm) [Constructor](MfTimeSpanConstructor.htm)  method.

The [MfParams](MfParams.htm) is a class designed for  working with method overloads.

### Enumerations

Mini-Framework uses  enumerations such as [MfDigitShapes](MfDigitShapes.htm), [MfEqualsOptions](MfEqualsOptions.htm),  [MfNumberFormatInfo](MfNFI18.htm), [MfNumberStyles](MfNS14.htm), [MfSetFormatNumberType](MfSFNT.htm), [MfStringSplitOptions](MfSSO20.htm),  [MfStringComparison](MfSC18.htm). All enumerations inherit from the [MfEnum](MfEnum.htm) class. All Enumeration classes  enumeration values are instances of [MfEnum.EnumItem](MfEnumEnumItem.htm). See Core  Enumeration classes [here](NS_System.htm#Enumerations).

To create custom enumerations for you project  inherit your class from the [MfEnum](MfEnum.htm) class.

### Null  Values

Mini-Framework has  several different options for working with nulls. The Primary way is the  [MfNull](MfNull.htm) class  using the [MfNull.IsNull()](MfNullIsNull.htm) method.

There is also a global variable named [Null](Globals.htm#Null) with a value of  "" for convenience. For another option you can use global variable [Undefined](Globals.htm#undefined).  

Also see [MfString.IsNullOrEmpty()](MfStringIsNullOrEmpty.htm)  method.

### Environment

Mini-Framework uses  The [MfEnvironment](MfEnvironment.htm) class to access various environment variables. See [MfEnvironment  Properties](MfEnvironment.htm#Properties) for a list of Environment variables.

### Command  Wrappers

Mini-Framework uses  the [Mfunc](Mfunc.htm) create a  wrapper for many of the built in AutoHotkey command functions and adds a few  other functions for common use. See the [Mfunc](Mfunc.htm) [Methods](MfuncMethods.htm).

#### How to Include in my  project?

See [Distribution](Distribution.htm)

#### Will adding  Mini-Framework  cause cause performance issues due to the number of objects?

[AutoHotkey](http://ahkscript.org/) Documentation [states](https://autohotkey.com/docs/Variables.htm#cap) "There is  no limit to how many variables a script may create. The program is designed to  support at least several million variables without a significant drop in  performance.".

Copyright © 2013-2017 by Paul Moss. All Rights  Reserved.

76 libs

