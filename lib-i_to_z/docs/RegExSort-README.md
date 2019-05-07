# RegExSort [![](https://img.shields.io/badge/License-AGPL_v3-blue.svg)](https://tldrlegal.com/license/gnu-affero-general-public-license-v3-(agpl-3.0)) <img src="https://img.shields.io/badge/AHK-1.0.*-brightgreen.svg" title="Ok" alt="AHK 1.0.* : Ok"/> <img src="https://img.shields.io/badge/AHK-1.1.*-brightgreen.svg" title="Ok" alt="AHK 1.1.* : Ok"/> <img src="https://img.shields.io/badge/AHK-2.0--a*-lightgray.svg" title="Untested" alt="AHK 2.0-a* : Untested"/>

## Usage
```p_InputList, p_RegExNeedle [, p_Order, p_OptString, p_Din, p_Dout]```

#### Required Parameters
| Name | Description |
| :--- | :--- |
| p_InputList | Input variable (see input remarks below) |
| p_RegExNeedle | RegEx to match for each item delimited by *p_Din* |

#### Optional Parameters
| Name | Description | Default |
| :--- | :--- | :--- |
| p_Order | CSV string (see remarks below) | blank |
| p_OptString | See remarks below | blank |
| p_Din | Input delimiter | `r`n |
| p_ReturnColor | Output delimiter (single character) | `n |

**Returns:** a sorted list delimited by p_*Dout*.

*p_Order* defines the order of precedence for the matching subpatterns  
to be sorted. Specifying "R" instead will use all matching subpatterns  
in reverse. When blank (default), will sort the entire RegEx match.

*p_OptString* specifies additional options for the Sort command.  
Use *p_Dout* instead of the "D" option. Do not use the "\" option  
(see *p_InputList* remarks below).

*p_InputList* should **not** containg the "\" character, since the presence  
of such character would cause the Sort command to misbehave.  
As a workaround, replace any occurrences of it with a dummy uncommon  
character before calling this function and replace it back afterwards.

Although passing a blank string to *p_RegExNeedle* is not be intended,  
doing so will cause the first item of the input list to become the last one.

-----------------------

## Changelog

##### 2012-07-05
* Fixed variables *l_PrivChar1* and *l_PrivChar2* (thanks *berban*)

##### 2010-04-27
* Fixed a logical mistake

##### 2009-12-06
* Initial release
