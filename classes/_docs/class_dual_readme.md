Overview
========

Dual is an [AutoHotkey] script that lets you define [dual-role modifier keys][wikipedia-dual-role]
easily. For example, combine the space bar and shift keys. It is heavily inspired by [BigCtrl].

Dual is not just another script you download, auto-run and forget. It is a tool you include and use,
perhaps in an already existing remapping script.

It is currently quite stable and feature complete, but needs more testing. However, until version
1.0.0 is released, the API might change in backwards incompatible ways without warning.

The biggest thing blocking 1.0.0 are the unit tests.

**I'm looking for a maintainer.** I have moved away from Windows to Linux, and therefore do not use
AutoHotkey anymore. If you like dual and would like to maintain it, please contact me.



Usage
=====

The best thing is to put a copy of the files in the library folder of the AutoHotkey file you wish
to use it with (a folder called "Lib" next to your file). Either download it manually, clone with
git (`git clone https://github.com/lydell/dual.git Lib/dual`) or, preferably, add it as a submodule
(`git submodule add https://github.com/lydell/dual.git Lib/dual`).

Then include the script into the AutoHotkey file you chose. That exposes the `Dual` class, which is
used for configuration and setting up your dual-role keys. Example:

    ; Recommended, but not required:
    SendMode Input
    #NoEnv
    #SingleInstance force

    #Include <dual/dual>
    dual := new Dual

    #Include <dual/defaults>

    #If true ; Override defaults.ahk. There will be "duplicate hotkey" errors otherwise.

    ; Steve Losh shift buttons.
    *LShift::
    *LShift UP::dual.combine(A_ThisHotkey, "(")
    *RShift::
    *RShift UP::dual.combine(A_ThisHotkey, ")")

    ; BigCtrl-like.
    *Space::
    *Space UP::dual.combine("RCtrl", A_ThisHotkey)

    ; Colemak rebinding and Windows key combination.
    *j::
    *j UP::dual.combine("RWin", "n")

    #If

    *ScrollLock::dual.reset()



Pros & Cons
===========

Why use this? Well, to get more characters onto your keyboard. Why can you press for example shift
by itself, and it produces nothing? Let it do something instead!

You can also use Dual to put modifier keys in more convenient places, like on the home row (which I
do).

Normally, all keys send their characters when pressed down. Dual-role keys, on the other hand, sends
their characters when the key is _released_, since they act as modifiers when pressed down. This
might feel a bit laggy. If you make the shift buttons also produce parenthesis, you probably won't
notice it, because you are not used to that the shift keys actually do something when pressed on
their own. But if you put modifiers on the home row you probably will, since this time you _are_
used to seeing the characters pop up immediately on the screen. Moreover, the characters of the
other rows still do, so you will constantly _see_ the difference too, not just remember it.

As I said, I put the modifiers on the home row. My first reaction was: "Ugh, that looks terrible!",
since the home row characters appeared on the screen slower than before. It felt like typing in the
terminal with a somewhat bad ssh connection. Initially that slowed me down. After a while, though, I
learned to ignore the lag, just typing on like before. After yet a while, I didn't think much about
it any longer. So, for me, having the modifiers in really convenient spots is definitely worth the
lag.

Everyone might not stand the lag, though. If so, simply don't make any character keys into dual-role
keys. I can still recommend making the modifier keys and space bar into dual-role keys to anyone.

Also see [Limitations].



API
===

Note that all methods that accepts keys expect keys from the [key list].

The `Dual` class takes an optional settings object as parameter. See [Configuration] for the
available settings.

    dual := new Dual ; Use default settings.
    dual := new Dual({settingName: value}) ; Override some default setting.

Throughout the rest of the documentation, `dual` is assumed to be an instance of the `Dual` class.

`dual.combine(downKey, upKey, settings=false, combinators=false)`
-----------------------------------------------------------------

In a nutshell, a dual-role key sends one key when held down—called the "downKey"—and one when
released—called the "upKey."

The method is supposed to be called as such:

    *KeyName
    *KeyName UP::dual.combine(…)

The upKey and downKey may also be combinations of keys, by passing arrays. For example, you could
make right alt put quotation marks around the cursor when pressed by itself, and a ctrl+shift key
when pressed in combination with some other key:

    *RAlt::
    *RAlt UP::dual.combine(["RCtrl", "RShift"], ["'", "'", "Left"])

For convenience, and to keep your setup DRY, you may pass `A_ThisHotkey`.

You may optionally pass a settings object, just like when instantiating the class (see above), but
at key-level:

    *r::
    *r UP::dual.combine("LWin", A_ThisHotkey, {delay: 100})

Key-level settings have been invaluable for me when experimenting with modifiers on the home row.

See [Limitations] for documentation on the `combinators` parameter.

An older version of Dual provided a method called `set()` instead of `combine()`, which set up the
keys for you, using the `Hotkey` command. That was perhaps a bit more convenient (you didn't have to
write the key name twice for instance), but caused problems with other hotkeys.

`dual.comboKey(remappingKey=false, combinators=false)` or `dual.comboKey(combinators)`
--------------------------------------------------------------------------------------

The method is supposed to be called as such:

    *KeyName::dual.comboKey()

That turns the key into a _[comboKey]_. It basically means that the key sends information to the
dual-role keys when pressed, and then sends itself—so you won't even notice that a comboKey is
comboKey.

If you want a key to be a comboKey _and_ remap it, pass the key you want to remap it to as a
parameter. For example, if you previously swapped the following keys like so …

    a::b
    b::c
    c::a

… you could change it like so:

    *a::dual.comboKey("b")
    *b::dual.comboKey("c")
    *c::dual.comboKey("a")

Just like the `combine()` method, you may also pass an array of keys to be sent together:

    *9::dual.comboKey(["(", ")", "Left"])

See [Limitations] for documentation on the `combinators` parameter.

An older version of Dual provided a setting called `Dual.comboKeys` instead of this method, which
set up the comboKeys for you, using the `Hotkey` command. That is not possible anymore, because it
depended on the `set()` method which also doesn't exist anymore (see the `combine()` method above).
This way is also more reliable.

`dual.combo()`
--------------

Lets you make a key into a comboKey without sending the key itself, in contrast to the `comboKey()`
method.

    *a::
        dual.combo()
        MsgBox Hello, World!
        return

In fact, the `comboKey()` method (called without parameters) is roughly equivalent to:

    dual.combo()
    SendInput {Blind}%A_ThisHotkey%

`dual.modifier(remappingKey=false)`
-----------------------------------

The method is supposed to be called as such:

    *ModifierName
    *ModifierName UP::dual.modifier()

Let's say you want to press control+shift+a. You press down shift and then control, but then change
your mind: You only want to press control+a. So you release shift and then press a. No problems.

Now, let's say you had combined d and shift, and used that for the above. When you release d
(shift), and you do that before its timeout has passed, d will be sent, causing control+d!

You can solve this edge case by using the following:

    *LCtrl::
    *LCtrl UP::
    *RCtrl::
    *RCtrl UP::dual.modifier()

The `remappingKey` parameter works just like it does in the `comboKey()` method.

Note that if _only_ normal modifiers or _only_ dual-role keys are involved, this issue can never
occur.

This method also fixes another edge case. I don't think it's very useful, but it's there for
consistency. If you hold down for example d and then press a modifier, d will be sent, and it won't
start/continue to repeat. However, if d is a dual-role key, d would be modified. For example, if the
modifier in question is shift, D would be sent. That's like doing it backwards, d+shift, and it
still works! `dual.modifier()` takes care of this too.

Implementation note: This method actually turns things into dual-role keys with the same downKey and
upKey! The above example is actually equivalent to:

    *LCtrl::
    *LCtrl UP::
    *RCtrl::
    *RCtrl UP::dual.combine(A_ThisHotkey, A_ThisHotkey, {delay: 0, timeout: 0, doublePress: -1, specificDelays: false})

`dual.Send(string)`
-------------------

`dual.Send()` works exactly like the `Send` command, except that it temporarily releases any dual-
role keys that are down for the moment first. There are also `dual.SendInput()`, `dual.SendEvent()`,
`dual.SendPlay()` and `dual.SendRaw()`. See [Limitations] for usage of this method.

`dual.reset()`
--------------

I strongly recommend that you create a non modifier shortcut that calls this function. Why? Because
in some programs, such as [KeePass] when entering a password in its secure screen, or an elevated
command prompt, AutoHotkey does not work at all. I guess it's a security thing. This can cause your
dual-role keys to be stuck down, which, in the worst case, requires a reboot.

For example: KeePass has a global shortcut to open its window: ctrl-alt-k. If you type that shortcut
using dual-role keys, and your currently open KeePass password database happens to be locked, that
will bring up the KeePass dialog to enter your password for the database, as expected. However, that
will also block AutoHotkey—before you have had time to release your dual-role keys! They will now be
stuck down, which will make it next to impossible to type anything, or actually use your keyboard at
all. Usually, it is enough to turn off the AutoHotkey script, and then press each modifier once. But
in this case, the only solution I've found is to reboot the computer.

That's where `dual.reset()` comes into the picture. It resets all dual-role keys, and sends
{modifier up} for each modifier (shift, ctrl, alt and win—left and right). I recommend binding that
to some key—regardless of which modifiers are down—so that you can press that key if some modifier
is stuck, saving a reboot. Example:

    ; Note the `*`! It allows you to press ScrollLock even if a modifier is stuck.
    *ScrollLock::dual.reset()

I wish that this method wasn't necessary, but unfortunately it sometimes is. If a key gets stuck
down, it's a bug. But in the case where AutoHotkey (or any other program) isn't run for security
reasons, I don't think there is anything I can do.

### KeePass work-around ###

If your database is locked, don't use the ctrl-alt-k shortcut. Instead, use win-b to focus the tray
(by the clock), then navigate to the KeePass icon using the arrow keys and finally hit enter.
Perhaps you could automate that with AutoHotkey ;)


Configuration
=============

While dual-role keys might sound trivial to implement, there are some pretty complicated
**[details]** to work with. Only _using_ dual-role keys is really easy. Here is a summary and the
defaults of the configuration.

    settings := {delay: 70, timeout: 300, doublePress: 200}

`delay` is the number of milliseconds that you must hold a dual-role key in order for it to count as
a combination with another key (comboKeys only, though). Set it to `0` to turn off the feature (of
course). You can really fine-tune things by setting different delays for different comboKeys, via
the `specificDelays` option. More on that [below](#tips).

`timeout` is the number of milliseconds after which the downKey starts to be sent, and the
upKey won't be sent. Set it to `-1` to turn the feature off—to never timeout.

`doublePress` is the maximum number of milliseconds that can elapse between a release of a dual-role
key and its next press and still be called a doublePress. Set it to `-1` to disable doublePress-ing,
and thus repetition.

_comboKeys_ are keys that enhance the accuracy of the dual-role keys. They can be set as such:

    *a::
    *a UP::dual.comboKey()

Also note that the settings can be set per dual-role key. See the `combine()` method. This let's you
fine-tune specific keys. After all, our fingers and the possible key combinations of the keyboard
are all different.

Tips
----

To test the timeout and delay, I recommend setting both of them to long times, for example 3 seconds
and 1 second, respectively. Play with it and you'll quickly get the hang of it. Then tweak the
values so that you never ever have to think about them again.

Here's a method to find a good delay:

Find a pair of characters on your keyboard that you type really quickly in succession. Combine the
first of those two characters with a modifier M. Make sure that the other character is a comboKey,
and that an action A is triggered when modified by M. Then type words that contain the two
characters in succession. If action B is triggered when typing those words, you need more delay.
Then also try to activate other hotkeys that you actually would like to be triggered. If they don't,
you have too much delay. If you're really unlucky, you can't satisfy both at the same time.

Example: I type "er" very quickly in QWERTY. So I made "e" a dual-role key, combining it with the
Windows key. (I also made sure that "r" is a comboKey.) I then typed words like
"h<strong>er</strong>e" and "th<strong>er</strong>e". When I had too little delay, the Run prompt
popped up while typing (win-r is the default shortcut for opening it). When I had too much delay, I
wasn't able to activate other Windows shortcuts, such as win-m (which minimizes all windows),
because I typed the shortcut too quickly: dual thought that I accidentally made a combination. After
I while I found a balance.

You might find that a delay works really well with most or some keys, and worse with others.

For example, I've combined d with control. Using a delay of 70ms works great for me in most cases,
but not with o for some reason. I know that since often when I want to type "don't", an "Open
file..." dialog is opened instead, since I've accidentally triggered a control-o shortcut, which is
commonly used to open files. So for o, I need a longer delay.

I've also combined f with shift. Here I use a delay of 70ms too, but the problem is the other way
around. When I want to type a colon (shift-;), I sometimes end up with f;. When I want to type a
left parenthesis, I sometimes end up with f9. So for ; and 9 I need a shorter delay.

Actually, I've noticed that I can benefit from a shorter delay when using all my dual-role keys with
numbers. I achieve that by setting the `specificDelays` option globally:

    dual := new Dual({specificDelays: {"1 2 3 4 5 6 7 8 9 0": 20}})

Then I extend that in some of my dual-role keys:

    *d::
    *d UP::dual.combine("LControl", A_ThisHotkey, {specificDelays: {extend: true, "o": 150}})

    *f::
    *f UP::dual.combine("LShift", A_ThisHotkey, {specificDelays: {extend: true, ";": 20}})

`extend: true` makes the key-level option extend the global option, instead of overriding it as
usual. It is possible to set `specificDelays` to `false` to turn it off:

    *s::
    *s UP::dual.combine("LAlt", A_ThisHotkey, {specificDelays: false})

In short, the `specificDelays` option is a map of space separated lists of keys and delays.



defaults.ahk
============

To make it easier for you, most keys of the en-US QWERTY layout are turned into comboKeys in the
file [defaults.ahk]. And `dual.modifier()` is run on all modifiers. Before including it, there are a
few things to notice.

- It assumes your `Dual` instance to be called `dual`.
- It sets up hotkeys, so including it will end the auto-execute section.
- You must wrap your hotkeys in `#If conditions`:s to override the defaults. You will get "duplicate
  hotkey" errors otherwise.
- You can probably use it even if you don't use en-US QWERTY. For example, Dvorak and Colemak should
  make no difference. sv-SE QWERTY users should be fine, but might want to add å, ä and ö as
  comboKeys. And so on.

An example:

    #Include <dual/dual>
    dual := new Dual ; The instance is assumed to be called `dual`, so we'd better use that.

    ; This must be included after the above, since it ends the auto-execute section.
    #Include <dual/defaults>

    ; Add sv-SE extra comboKeys.
    *å::
    *ä::
    *ö::
        dual.comboKey()
        return

    #If true ; Override defaults.ahk. There will be "duplicate hotkey" errors otherwise.
    *Space::
    *Space UP::dual.combine("RCtrl", A_ThisHotkey)
    #If

    #If settings.shift ; Using a "real" `#If` works, too, of course.
    *f::
    *f UP::dual.combine("LShift", A_ThisHotkey)
    *j::
    *j UP::dual.combine("RShift", A_ThisHotkey)
    #If



Limitations
===========

The `&` combiner
----------------

Consider the following example:

    *j::
    *j UP::dual.combine("F12", A_ThisHotkey)

    F12 & d::SendInput e

Pressing d while holding down j should produce e, right? I wish it did. In reality, the hotkey
isn't triggered at all. Any already existing hotkeys using the `&` combiner could be rewritten like
the following, to be able to be activated by a dual-role key:

    #If GetKeyState("F12")
    d::SendInput e
    #If

However, you might find such shortcuts more laggy than native shortcuts. It seems like you have to
hold your dual-role key for more that the timeout for the shortcuts to actually trigger, comboKeys
or not. So dual provides a different way of achieving this, using the `combinators` parameter of the
`combine()` and `comboKey()` methods.

    *d::dual.comboKey({F12: "e"})

The above does two things. It turns d into a comboKey, without remapping it. It also checks if F12
is down before sending itself. If it is, e is sent instead. If you also want to remap d to f, you
can:

    *d::dual.comboKey("f", {F12: "e"})

The keys in the `combinators` parameter can also be arrays (as always):

    *d::dual.comboKey("f", {F12: ["(", ")", "Left"]})

But what if you wanted something more complex?

    F12 & d::MsgBox Hello, World!

Then you'll have to resort to something more manual:

    d::
        dual.combo()
        if (GetKeyState("F12")) {
            MsgBox Hello, World!
        } else {
            SendInput d
        }
        return

The biggest use case for this, is to be able to make "homemade" modifiers, to create a new layer on
the keyboard.

    *Space::
    *Space UP::dual.combine("F22", A_ThisHotkey)

    *i::dual.comboKey({F22: "Up"})
    *j::dual.comboKey({F22: "Left"})
    *k::dual.comboKey({F22: "Down"})
    *l::dual.comboKey({F22: "Right"})

The above example turns space into a homemade modifier that puts the navigation keys on ijkl. This
is done by using a key not present on most keyboards (F22).

The `combinators` parameter of the `combine()` method works the same way.

Modifier hotkeys that send
--------------------------

Consider the following example:

    *j::
    *j UP::dual.combine("RShift", A_ThisHotkey)

    +d::Send 1337

Pressing d while holding down j should produce 1337, right? I wish it did. In reality, !##& is sent,
just as if `{Blind}` was used. Any already existing hotkeys that involves modifiers and that **send
input** could be rewritten like the following, to send the input as expected:

    +d::dual.Send("1337")

`dual.Send()` works exactly like the `Send` command, except that it temporarily releases any dual-
role keys that are down for the moment first. There is also `dual.SendInput()`, `dual.SendEvent()`,
`dual.SendPlay()` and `dual.SendRaw()`.



Tests
=====

[YUnit] is used for unit testing. To run the tests, simply run [test/dual.ahk]. (However, there are
no meaningful tests yet.)



License
=======

[MIT Licensed]



[AutoHotkey]:          http://www.autohotkey.com/
[BigCtrl]:             https://github.com/benhansenslc/BigCtrl
[comboKey]:            details.md#combokeys
[Configuration]:       #configuration
[defaults.ahk]:        defaults.ahk
[details]:             details.md
[KeePass]:             http://keepass.info/
[key list]:            http://www.autohotkey.com/docs/KeyList.htm
[Limitations]:         #limitations
[MIT Licensed]:        LICENSE
[test/dual.ahk]:       test/dual.ahk
[wikipedia-dual-role]: http://en.wikipedia.org/wiki/Modifier_key#Dual-role_keys
[YUnit]:               https://github.com/Uberi/Yunit
