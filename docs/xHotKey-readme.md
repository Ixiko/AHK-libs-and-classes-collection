# xHotkey

xHotkey is a function library for AutoHotkey v1.1 and v2.0. It serves as an alternative to the [Hotkey command](http://ahkscript.org/docs/commands/Hotkey.htm), more suited to dynamic scripts.

## Installation

Copy the contents of the `Lib` folder into a [function library](http://ahkscript.org/docs/Functions.htm#lib).  This folder should include xHotkey.ahk, HotkeyNormalize.ahk and a number of scripts intended for AutoHotkey v1.1 compatibility.

## Usage

    xHotkey(KeyName [, Callback, Enable])

Creates, modifies, enables, or disables a hotkey.

*KeyName:* The hotkey, such as `"#c"` for Win+C.

*Callback:* A function to call when the hotkey fires.  This can be a function name or reference, or an object. The sample script *xHotkey_test.ahk* shows how to use an object to bind parameters to a function.

*Enable:* Whether to enable the hotkey. Can be `"On"`, `"Off"`, `0` (false) or `1` (true). If this parameter is omitted and the hotkey variant exists but is disabled, it is left disabled. New hotkey variants default to enabled.


    xHotkey(IfWin [, WinTitle, WinText])

*IfWin* can be the name of any of the IfWin commands supported by the Hotkey command, but cannot be `"If"`. 

    xHotkey.IfWinActive(WinTitle, WinText)
    xHotkey.IfWinExist(WinTitle, WinText)
    xHotkey.IfWinNotActive(WinTitle, WinText)
    xHotkey.IfWinNotExist(WinTitle, WinText)

Equivalent to `xHotkey("IfWin...", WinTitle, WinText)`.

### Examples

```AutoHotkey
xHotkey("#z", "AHK")

AHK() {
    Run http://ahkscript.org
}
```

See *xHotkey_test.ahk* for more.

## HotkeyNormalize

    NHotkey := HotkeyNormalize(Hotkey [, ByRef UseHook, ByRef HasTilde])

Normalizes a hotkey name.

It is not necessary to call this function when using xHotkey, since xHotkey calls it automatically.

Modifiers are sorted into the following order:

    * <^ <! <+ <# >^ >! >+ ># ^ ! + #

Because the use-hook `$` and pass-through `~` modifiers do not form part of the identity of the hotkey, they are not included in the return value. Instead, the *UseHook* and *HasTilde* parameters are set according to whether those modifiers are present.

Key names are converted to their long form and proper casing, so for instance, `bs` becomes `Backspace` and `return` becomes `Enter`. Consequently, while using inconsistent names causes problems with normal hotkeys, it does not bother xHotkey at all.

`vkNN` and `scNNN` codes are converted to lower-case. AutoHotkey is designed to treat these as distinct from their corresponding key names, so they are not converted to names.

**Note:** VK and SC codes are not validated by HotkeyNormalize or AutoHotkey. `vk12abc34` is treated like `vk12`, but only one of the two will work at a time.

**Note:** Unlike Send and GetKeyName, hotkeys do not recognize the scan code in `vkXXscYYY`. Instead, the leading digits of `XXscYYY` are used and the rest is ignored.

### What's it for?

xHotkey supports IfWin hotkey variants by registering a single hotkey under a context similar to `#If ShouldFire(A_ThisHotkey)`. Each hotkey name is mapped to an array of hotkey variants. 

AutoHotkey treats two hotkeys as the same if they have the same combination of modifier keys and the same key name. For example, `^!x` and `!^x` are the same hotkey, but `esc` and `Escape` are not. When a hotkey is created, its name becomes the permanent name of all variants of that hotkey. Without normalization, this would pose problems for xHotkey:

- The string returned by `A_ThisHotkey` might not match the expected hotkey name. Only hotkey variants which use the original modifier symbol ordering would work.
- Disabling all variants of `^!x` turns off the hotkey, which would prevent all variants of `!^x` from working even if they're supposed to be enabled.

To solve these problems, xHotkey normalizes all hotkey names.

## Known Issues

Custom combinations do not support the tilde prefix, as in `~a & b` or `a & ~b`.

Defining a hotkey outside of xHotkey with the wrong symbol order can prevent that hotkey from working with xHotkey. For example, `!^n::` would prevent `^!n` from working with xHotkey, because `A_ThisHotkey` will always return symbols in the original order: `!^n`. It would also prevent `!^n` from working, because xHotkey normalizes this to `^!n`. To work around this issue, either use xHotkey for all hotkeys, or write your hotkeys in "normal" form. See *HotkeyNormalize* above for the proper symbol order. 

Each hotkey can only run one thread at a time. Normally, while a hotkey subroutine is running, other variants of the same hotkey can still run. This isn't the case with xHotkey since all variants of a hotkey are actually seen as one variant by AutoHotkey. 

Hotkey options such as `B` (thread buffering), `Pn` (thread priority) and `Tn` (max threads) are not supported. This is mainly for simplicity, but also because the options would apply to all variants of the hotkey due to the way xHotkey dispatches hotkey events.  For example:

```AutoHotkey
xHotkey("^1", "AAA", "T5")
xHotkey.IfWinActive("Untitled")
xHotkey("^1", "BBB", "T2")  ; This would apply to AAA as well.
```

There is no equivalent of `Hotkey If, Expression`.

Calling any of the `Hotkey If` sub-commands does not affect xHotkey. This is intentional. However, calling xHotkey does revert the Hotkey command to global context. This is unavoidable.