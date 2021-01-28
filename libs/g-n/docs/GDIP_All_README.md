# AHK GDI+ LIBRARY EXTENDED COMPILATION

This is a compilation of user contributed functions for the GDI+ library wrapper made by Tariq Porter [tic] that never made it into.

This repository is a fork of https://github.com/mmikeww/AHKv2-Gdip/ . Some of the newly added functions are possibly not AHK v2 compatible.

This Gdip_all.ahk file should be compatible with projects already relying on the original edition. In other words, it is backwards compatible. If you this is not the case, please report the issue[s].

I re-added the original examples From Tic in Examples-ahk-v1-1 folder and several new examples that showcase the newly supported GDI+ APIs. These are example scripts initially provided by those that coded the new functions.

# History
- @tic created the original [Gdip.ahk](https://github.com/tariqporter/Gdip/) library
- @Rseding91 updated it to make it compatible with unicode and x64 AHK versions and renamed the file `Gdip_All.ahk`
- @mmikeww's repository updates @Rseding91's `Gdip_All.ahk` to make it compatible with AHK v2 and also fixes some bugs
- this repository attempts to gather all the GDI+ functions contributed by various people that were missing, and further extend the coverage/support of GDI+ API functions

# FUNCTIONS LIST

- 35 GraphicsPath object functions
- 43 Pen object functions
- 28 PathGradient brush functions
- 21 LinearGradient brush functions
- 11 Texture brush functions
- 10 SolidFill and hatch brush functions
- 48 pBitmap functions
- 16 ImageAttributes and Effects functions
- 40 Fonts and StringFormat functions
- 40 pGraphics functions
- 21 Region functions
- 10 Clip functions
- 14 Transformation Matrix functions
- 35 Draw/Fill on pGraphics functions
- 18 GDI functions [selection]
- 22 Other functions [selection]

Please see functions-list.txt for the actual list of functions.

# COMPARISIONS

The following list is comparing Gdip_All.ahk by Tariq Porter and Rseding91 modifications with this new version.

## ~23 MODIFIED FUNCTIONS

## ~300 NEW FUNCTIONS

See functions-list.txt for more details and credits.

## NOTES:
  - GetProperty() functions yield incorrect results for some meta-data/properties.
  - Gdip_PixelateBitmap() seems to not work for me [in any GDI+ library edition].
  - the newly added examples are not AHK v2 compatible
  - awaiting pull requests for bug fixes

## Derniere mise à jour: mercredi 11 mars 2020, v1.82
