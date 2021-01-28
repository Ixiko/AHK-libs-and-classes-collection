# AHK GDI+ LIBRARY EXTENDED COMPILATION

This is a compilation of user contributed functions for the GDI+ library wrapper made by Tariq Porter [tic] that never made it into.

This repository is a fork of https://github.com/mmikeww/AHKv2-Gdip/ . Some of the newly added functions are possibly not AHK v2 compatible.

This Gdip_all.ahk file should be compatible with projects already relying on the original edition.

I re-added the original examples From Tic in Examples-ahk-v1-1 folder and several new examples that showcase the newly supported GDI+ APIs. These are example scripts initially provided by those that coded the new functions.

# History
- @tic created the original [Gdip.ahk](https://github.com/tariqporter/Gdip/) library
- @Rseding91 updated it to make it compatible with unicode and x64 AHK versions and renamed the file `Gdip_All.ahk`
- @mmikeww's repository updates @Rseding91's `Gdip_All.ahk` to make it compatible with AHK v2 and also fixes some bugs
- this repository attempts to gather all the GDI+ functions contributed by various people that were missing, and further extend the coverage/support of GDI+ API functions

# FUNCTIONS LIST

- 34 GraphicsPath object functions
- 42 Pen object functions
- 27 PathGradient brush functions
- 19 LinearGradient brush functions
- 10 Texture brush functions
- 10 SolidFill and hatch brush functions
- 39 pBitmap functions
- 16 ImageAttributes and Effects functions
- 37 Fonts and StringFormat functions
- 39 pGraphics functions
- 21 Region functions
- 10 Clip functions
- 14 Transformation Matrix functions
- 35 Draw/Fill on pGraphics functions
- 29 Other functions [selection]

Please see functions-list.txt for the actual list of functions.

# COMPARISIONS

The following list is comparing Gdip_All.ahk by Tariq Porter and Rseding91 modifications with this new version.

## 20 MODIFIED FUNCTIONS

## 276 NEW FUNCTIONS

See functions-list.txt for more details.

## NOTES:
  - GetProperty() functions yield incorrect results for some meta-data/properties.
  - Gdip_PixelateBitmap() seems to not work for me [in any GDI+ library edition].
  - the newly added examples are not AHK v2 compatible
  - all other tutorials / examples throw an error on script exit on AHK v2 a104; the same applies to @mmikeww's edition
  - awaiting pull requests for bug fixes

## Last updated on: jeudi 19 septembre 2019, v1.74


