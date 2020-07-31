import os
import sys

import pytest

import _ahk  # noqa
import ahk
from conftest import run_from_input


# TODO: sys.stdout is not in utf-8.


def test_call():
    with pytest.raises(ahk.Error):
        # Calling _ahk.call() without arguments must raise an error.
        _ahk.call()

    with pytest.raises(ahk.Error):
        # _ahk.call() to a non-existent function must raise an error.
        _ahk.call("NoSuchFunction")

    os.environ["HELLO"] = "Привет"
    hello = _ahk.call("EnvGet", "HELLO")
    assert hello == os.environ["HELLO"]

    temp = _ahk.call("EnvGet", "TEMP")
    assert isinstance(temp, str), "EnvGet result must be a string"

    rnd = _ahk.call("Random", 42, "42")
    assert isinstance(rnd, int), "Random result must be an integer"
    assert rnd == 42, f"Result must be 42, got {rnd}"

    assert _ahk.call("Random", 1, True) == 1, "Result must be 1"

    val = _ahk.call("Max", 9223372036854775807)
    assert val == 9223372036854775807, f"Result must be 9223372036854775807, got {val}"

    val = _ahk.call("Min", -9223372036854775806)
    assert val == -9223372036854775806, f"Result must be -9223372036854775806, got {val}"

    with pytest.raises(OverflowError):
        val = _ahk.call("Max", 9223372036854775808)

    val = _ahk.call("Min", 0.5)
    assert val == 0.5, f"Result must be 0.5, got {val}"

    with pytest.raises(ahk.Error, match="cannot convert '<object object"):
        _ahk.call("Min", object())


def test_message_box():
    result = ahk.message_box()
    assert result == "", "MsgBox result must be an empty string"
    ahk.message_box("Hello, мир!")
    ahk.message_box("Do you want to continue? (Press YES or NO)", options=4)


def test_hotkey():
    with pytest.raises(ahk.Error):
        ahk.hotkey("")

    with pytest.raises(ahk.Error):
        # Passing a non-callable to ahk.hotkey must raise an error.
        ahk.hotkey("^t", func="not callable")

    @ahk.hotkey("AppsKey & t")
    def show_msgbox():
        ahk.message_box("Hello from hotkey.")

    ahk.message_box("Press AppsKey & t now.")

    @ahk.hotkey("AppsKey & y")
    def show_bang():
        1 / 0

    ahk.message_box("Press AppsKey & y to see an exception.")


def test_get_key_state():
    ahk.message_box("Press LShift.")
    if ahk.get_key_state("LShift"):
        ahk.message_box("LShift is pressed")
    else:
        ahk.message_box("LShift is not pressed")


def test_timer():
    res = run_from_input("""\
        import sys, ahk
        ahk.hotkey("F12", lambda: None)  # Make the script persistent
        @ahk.set_timer(countdown=0.1)
        def dong():
            print("Dong!")
            ahk._ahk.call("ExitApp")
        print("Ding!")
        """)
    assert res.stdout == "Ding!\nDong!\n"
    assert res.returncode == 0

    res = run_from_input("""\
        import sys, ahk
        ahk.hotkey("F12", lambda: None)  # Make the script persistent
        @ahk.set_timer(period=0.1)
        def ding():
            print("Ding!")
            ding.disable()

        @ahk.set_timer(countdown=0.5)
        def exit():
            ahk._ahk.call("ExitApp")
        """)
    assert res.stdout == "Ding!\n"
    assert res.returncode == 0
