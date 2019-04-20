Configuration details
=====================

Here is a detailed explanation of the configuration, and how the dual-role keys actually work.

_comboKeys_
-----------

What happens, in essence, when you press a dual-role key, is the following:

You press the dual-role key down. That causes {downKey down} to be sent. You hold the dual-role key
for a while. During that time you might press other keys, which then might be modified, if your
downKey is a modifier. You release the dual-role key. That causes {downKey up} to be sent, as well
as {upKey}.

That achieves what we're after, right? The dual-role key is a modifier (the downKey) when held, and
a character (the upKey) when released! Well, yes but also no. It isn't perfect.

The biggest problem is that if you combine the downKey with another key, you don't want the upKey to
be sent when releasing the dual-role key. For example, if you have combined space and shift, and you
have pressed space+f, you'd expect an F, but in reality you get an F followed by a space. So the
script needs a way of knowing if you have combined a dual-role key with some other key.

That is solved by what I call **"comboKeys."** A comboKey is a key that you have assigned a hotkey
to that runs the `comboKey()` method, which checks if any of the dual-role keys are down. If so, it
tells the dual-role keys in question that they have been combined. The comboKey then sends itself,
so you won't even notice that it is a hotkey. Perfect, problem solved—the dual-role keys now know if
they have been combined, and can therefore skip sending the upKey when released. Note that the dual-
role keys are automatically combo keys. You should not add extra hotkeys to them to run the
`comboKey()` method fact that results in a "duplicate hotkey" error in AutoHotkey.

_timeout_
---------

But, wait! Does the above mean that the downKey only can be combined with a specific set of keys—the
comboKeys? That kinda sucks! Well, yes it does. Fortunately, there is a way to deal with this, so
that the downKey can be combined with _any_ key (however a little bit more limited than with the
comboKeys—why bother with comboKeys at all otherwise?). Phew!

Let me introduce the **"timeout"**. When the dual-role key has been held longer than the timeout,
the upKey won't be sent. When you think about, don't you always hold modifier keys longer than you
press character keys? So if you want to combine a downKey with a non-comboKey, just make sure that
you hold down the dual-role key longer than the timeout (which you probably do anyway).

According to the above paragraph, if you combine a dual-role key with some other, non-comboKey
within the timeout, that would result in both the combination _and_ the upKey. Right, I've already
said that. However, that is not true. In reality, _only_ the upKey will be sent.

The timeout actually takes care of one more thing.

In the beginning of this section, I said that the first thing that happens when you press down a
dual-role key is that {downKey down} is sent. That is actually not true. {downKey down} is not sent
until the timeout has passed. That's why only the upKey is sent, and the combination does not occur,
as described above. But why?

What makes it possible to combine a modifier key with another key is that the modifier only does
something when held down. However, that is not true for _all_ modifiers. Take the Windows key for
example. When released it opens the start menu (in fact, it is already a dual-role modifier key; a
combination of a special modifier and an "open the start menu" key). Or the alt keys, which might
show a hidden menu bar when released.

Alright, what about those modifiers? Well, if you try to use them in dual-role keys, you will get
trouble. For example, if you have combined the "w" and Windows keys, and you tap "w", you'd expect a
"w", but instead the start menu is opened, and a "w" is typed in its search box. Ouch.

That's why the downKey isn't sent down during the timeout. By doing so, {downKey up} is not sent if
the dual-role key is released before the timeout has passed, and therefore does not interfere. Now
you can type "w" again. If you wish to open the start menu, you have to hold the "w" key for longer
than the timeout.

But, wait again! So the dual-role key is not a modifier when held down until the timeout has passed?
What about combinations with the comboKeys? The whole point of them was not having to hold the dual-
role keys for longer than the timeout, right? Don't worry, the comboKeys force {downKey down} if the
timeout hasn't passed. Yet a reason for comboKeys!

The timeout also has yet another positive effect: If you ever change your mind half-way through a
keyboard shortcut—that is, when holding a modifier down—you can just release it without worrying
about having to clean up the upKey that was just sent.

_delay_
-------

Now, let's leave the timeout and move on. When typing quickly, sometimes you might press down
several keys simultaneously for a short period of time. If one of them is a dual-role key, you're in
trouble. For example, let's say you've combined the space and shift keys, and you want to type
"Hello world!". If you type this really quickly, so that the space bar happens to be down when you
type "w", the result would be "HelloWorld!".

The solution to this problem lies in its description. "Sometimes you might press down several keys
simultaneously for a _short period of time._" Thus, let me introduce the **"delay."** It is in
relationship with the comboKeys. Now, the comboKeys have one more check to do. As before, they check
if any dual-role keys are down. If so, they check how long time have elapsed since they were pressed
down. If that time is shorter than the delay, the downKey of the dual-role key in question is
released and its upKey sent instead. Otherwise the dual-role key is told that it has been combined
with another key, just as before. Again, the dual-role keys _work_ with any key combination. But
common keys better be set as comboKeys to reduce mistakes.

_doublePress_
-------------

Lastly, we've got the **"doublePress."** Usually, keys repeat when being held down (if your OS does
so). However, a dual-role key repeats its downKey when held, not the upKey. For example, if you've
combined the space and shift keys, holding down the space bar won't produce a serious of spaces,
perhaps used as indentation. What now?

For this issue, a doublePress is used. Press the dual-role key, release it and press it again,
within the doublePress time. If you continue to hold the dual-role key, the upKey will be repeated.

Now, the comboKeys come in handy yet a time. If you type "bob" really quickly, and "b" is a dual-
role key, and you keep holding "b" the last time, "b" will actually start to repeat, even though
another key was pressed in-between the two "b" presses. That's not really a double press, right?
However, if "o" is a comboKey, that won't happen.

Timeline
--------

`t` is time. Remember that dual-role keys also are comboKeys.

1. `t=0`. The dual-role key is physically pressed down. Nothing is sent (*).

   **If released:** The upKey is sent (**).

   **If combined with a comboKey:** The upKey is sent, followed by the comboKey. The dual-role key
   is now considered to be released, even though it is still physically down. Nothing more will be
   sent.

   **If combined with some other key:** That other key is sent as it normally would. It is not
   affected by the dual-role key in any way, and the dual-role key is not affected by it.

2. `t=delay`. Nothing is sent.

   **If released:** The upKey is sent (**).

   **If combined with a comboKey:** {downKey down} is sent, followed by the comboKey. The dual-role
   key now acts as a held down modifier, which affects the comboKey.

   **If combined with some other key:** That other key is sent as it normally would. It is not
   affected by the dual-role key in any way, and the dual-role key is not affected by it.

3. `t=timeout`. {downKey down} is sent. The dual-role key now acts as a held down modifier.

   **If released:** {downKey up} is sent. (Note that the upKey is _not_ sent.)

   **If combined with a comboKey or some other key:** The key in question is sent as it normally
   would. It is however affected by the dual-role key, since the dual-role key acts as a held down
   modifier.

(*) Unless the time elapsed since the dual-role key last was released is less than or equal to the
doublePress time, and the last pressed comboKey is the dual-role key itself. If so, the dual-role
key will enter repeat mode and leave the timeline; nothing more in the timeline will happen. In
repeat mode, upKey is sent, until the dual-role key is released. The repetition is controlled by
your operating system: The initial delay, repetition speed and if repetition should occur at all.

(**) Unless another dual-role key has been pressed down after `t=0`. Then one of two things happen:

   - If the delay of that other dual-role key has not elapsed: The upKey is sent, followed by the
     upKey of that other dual-role key. Both dual-role keys are now considered to be released, even
     though they are still physically down. Nothing more will be sent.
   - If the delay of that other dual-role key _has_ elapsed: {downKey up} is sent, if the dual-role
     key was down, and upKey is _not_ sent. That other dual-role key is not affected in any way.
