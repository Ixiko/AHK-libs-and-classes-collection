# Constant classes
This folder holds classes representing enumerations ("enumeration classes") or other constants used by one or several COM classes.

## Requirements
* The member names must exactly match those in the enumeration definition, except that a leading prefix, if present, is omitted.
* Use static fields.

## Usage
The enumeration members can be used in methods or for struct fields. Ensure the corresponding enumeration is documented.
This should also replace cases where you could pass "string flags".