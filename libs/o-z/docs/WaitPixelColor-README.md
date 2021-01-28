# WaitPixelColor [![](https://img.shields.io/badge/License-AGPL_v3-blue.svg)](https://tldrlegal.com/license/gnu-affero-general-public-license-v3-(agpl-3.0)) <img src="https://img.shields.io/badge/AHK-1.0.*-brightgreen.svg" title="Ok" alt="AHK 1.0.* : Ok"/> <img src="https://img.shields.io/badge/AHK-1.1.*-brightgreen.svg" title="Ok" alt="AHK 1.1.* : Ok"/> <img src="https://img.shields.io/badge/AHK-2.0--a*-lightgray.svg" title="Untested" alt="AHK 2.0-a* : Untested"/>

## Usage
```p_DesiredColor, p_PosX, p_PosY [, p_TimeOut, p_GetMode, p_ReturnColor]```

#### Required Parameters
| Name | Description |
| :--- | :--- |
| p_DesiredColor | The color you are waiting for |
| p_PosX, p_PosY | Pixel coordinates |

#### Optional Parameters
| Name | Description | Default |
| :--- | :--- | :--- |
| p_TimeOut | Timeout in milliseconds | 0 (no timeout) |
| p_GetMode | PixelGetColor mode(s) | blank |
| p_ReturnColor | Boolean, see returned values below | 0 (false) |

##### Returned values when *p_ReturnColor* is 0 (false):
| Value | Description |
| :--- | :--- |
| 0 | The desired color was found |
| 1 | There was a problem during PixelGetColor |
| 2 | The function timed out |

##### Returned values when *p_ReturnColor* is 1 (true):
| Value | Description |
| :--- | :--- |
| Blank | There was a problem during PixelGetColor |
| Non-blank | Will be the latest found color, even if not the desired one |

-----------------------

## Changelog

##### 2012-09-06
* Reduced code size

##### 2009-07-19
* Fixed a logical mistake

##### 2009-04-30
* Initial release
