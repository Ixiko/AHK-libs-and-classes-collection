Changelog
=========

0.6.0 (2013-12-01)
------------------

- Improved: The `comboKey()` method now accepts arrays of keys to be sent together in its
  parameters, just like the `combine()` and `modifier()` methods.
- Improved: The `modifier()` method is now documented to accept an array of keys as its
  `remappingKey` parameter. It has worked by accident; no it's "official".
- Added: The `specificDelays` option.
- Added: The `combinators` parameter of the `combine()` method, just like the `comboKey()` method.
- Fixed: Any of the characters #!^+<>*~$ may now be used as downKeys, upKeys, remappingKeys and in
  combinators. They were accidentally stripped out before.

0.5.0 (2013-11-17)
------------------

- Removed: The `force` option. It never really worked. (Backwards incompatible change.)
- Added: The `combinators` parameter of the `comboKey()` method, replacing the `force` option and
  the old advice on combinator shortcuts.
- Added: defaults.ahk.

0.4.3 (2013-11-13)
------------------

- Fixed: The `force` option should cause the downKey to be sent when the delay has passed, not
  immediately, to make the delay useful at all.

0.4.2 (2013-11-12)
------------------

- Added: The `force` option.

0.4.1 (2013-09-17)
------------------

- Added: The `reset()` method, to deal with modifiers being stuck down.

0.4.0 (2013-09-04)
------------------

- Added: Initial unit testing.
- Changed: The `Dual` constructor now takes an optional settings object as parameter, just like the
  `combine()` method, instead of setting properties on the instance. This is more consistent, nicer
  and encourages changing the settings before setting up dual-role keys. (Backwards incompatible
  change.)
- Improved: Re-factored some code.
- Added: The `modifier()` method.
- Improved: The `timeout` and `doublePress` can be turned off, by setting them to `-1`.

0.3.2 (2013-09-01)
------------------

- Fixed: Dual-role keys typed rapidly in succession were output backwards. For example, you wanted
  to type fd but got df.
- Improved: If you press down a dual-role key, then another, and then release the first, the full
  press of the first dual-role key is always a no-op.
- Both of the above are explained in detail in the source code.

0.3.1 (2013-08-29)
------------------

- Fixed: The comboKeys sometimes failed to force down downKeys. They now force them down much more
  forcefully.

0.3.0 (2013-08-14)
------------------

- Fixed: The dual-role keys now trigger other hotkeys out of the box (except hotkeys using the `&`
  combiner), with no changes to the other hotkeys required. They also work more reliably.
- Improved: Re-implemented the functionality of `Dual.send()` way more robustly.
- Changed: Replaced `Dual.send()` with the `SendInput()`, `SendEvent()`, `SendPlay()`, `SendRaw()`
  and `Send()` methods. (Backwards incompatible change.)
- Replaced the `Dual.set()` with the `combine()` method, in order to fix the above. (Backwards
  incompatible change.)
- Replaced the `comboKeys` setting with the `comboKey()` (and `combo()`) method, because of the
  above. (Backwards incompatible change.)
- Added: Per-key settings.
- Changed: The script now exports the class `Dual` itself, not an instance of the class. (Backwards
  incompatible change.)

0.2.0 (Unreleased)
------------------

- Comments are no longer allowed in the comboKeys setting. It prevented `;` from being used as a
  comboKey, and it is not worth introducing escape rules. (Backwards incompatible change.)

0.1.1 (2013-07-05)
------------------

- Fixed #3: Now {downKey down} won't be sent until the timeout has passed, in order to support the
  alt and Windows modifiers.

0.1.0 (2013-07-04)
------------------

Initial release.
