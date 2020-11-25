import sys
import traceback
from contextlib import contextmanager
from functools import partial

import _ahk  # noqa


# TODO: Write an __all__.
Error = _ahk.Error


def message_box(text=None, title="", options=0, timeout=None):
    if text is None:
        # Show "Press OK to continue."
        return _ahk.call("MsgBox")

    return _ahk.call("MsgBox", options, title, str(text), timeout)
    # TODO: Return result of IfMsgBox?


def hotkey(key_name, func=None, buffer=None, priority=0, max_threads=None,
           input_level=None):
    if key_name == "":
        raise Error("invalid key name")

    if func is None:
        # Return the decorator.
        return partial(hotkey, key_name, buffer=buffer, priority=priority,
                       max_threads=max_threads, input_level=input_level)

    # TODO: Handle case when func == "AltTab" or other substitutes.
    # TODO: Set the options.
    # TODO: Change options of the existing hotkeys.
    # TODO: Return a Hotkey object.
    _ahk.call("Hotkey", key_name, func)


def remap_key(origin_key, destination_key):
    # TODO: Implement key remapping, e.g. Esc::CapsLock.
    raise NotImplementedError()


@contextmanager
def hotkey_context():
    # TODO: Implement `Hotkey, If` commands.
    raise NotImplementedError()


def send(keys):
    # TODO: Consider adding `mode` keyword?
    _ahk.call("Send", keys)


def send_mode(mode):
    _ahk.call("SendMode", mode)


def set_batch_lines(interval=None, lines=None):
    if interval is not None:
        _ahk.call("SetBatchLines", f"{interval}ms")
        return
    if lines is not None:
        _ahk.call("SetBatchLines", f"{lines}")
        return
    raise ValueError("either 'interval' or 'lines' are required")


def detect_hidden_windows(value):
    value = "On" if value else "Off"
    _ahk.call("DetectHiddenWindows", value)


def set_title_match_mode(mode=None, speed=None):
    if mode is not None:
        match_modes = {
            "startswith": "1",
            "contains": "2",
            "exact": "3",
            "1": "1",
            "2": "2",
            "3": "3",
            "regex": "regex",
        }
        ahk_mode = match_modes.get(str(mode).lower())
        if ahk_mode is None:
            raise ValueError(f"unknown match mode {mode!r}")
        _ahk.call("SetTitleMatchMode", ahk_mode)

    if speed is not None:
        speeds = ["fast", "slow"]
        if speed.lower() not in speeds:
            raise ValueError(f"unknown speed {speed!r}")
        _ahk.call("SetTitleMatchMode", speed)


def win_exist(win_title, win_text="", exclude_title="", exclude_text=""):
    # TODO: Check that empty strings work in this case.
    return _ahk.call(win_title, win_text, exclude_title, exclude_text)


def set_timer(func=None, period=0.25, countdown=None, priority=0):
    if func is None:
        # Return the decorator.
        return partial(set_timer, period=period, countdown=countdown, priority=priority)

    if countdown is not None:
        if countdown < 0:
            raise ValueError("countdown must be positive")
        period = -countdown
    period = int(period*1000)

    _ahk.call("SetTimer", func, period, priority)

    return Timer(func)


class Timer:
    def __init__(self, func):
        self._func = func

    def enable(self):
        _ahk.call("SetTimer", self._func, "On")

    def disable(self):
        _ahk.call("SetTimer", self._func, "Off")

    def delete(self):
        _ahk.call("SetTimer", self._func, "Delete")

    def set_priority(self, priority):
        _ahk.call("SetTimer", self._func, "", priority)


def get_key_state(key_name, mode=None):
    return _ahk.call("GetKeyState", key_name, mode)


_quiet = False


def _main():
    sys.excepthook = _excepthook
    try:
        _run_from_args()
    except SystemExit as exc:
        _ahk.call("ExitApp", _handle_system_exit(exc))


def _run_from_args():
    import argparse
    import os
    import runpy

    parser = argparse.ArgumentParser()
    parser.add_argument("-q", "--quiet", action="store_true",
                        help="supress message boxes with errors")
    program = parser.add_mutually_exclusive_group()
    program.add_argument("-m", "--module",
                        help="run library module as a script")
    program.add_argument("FILE", nargs="?",
                         help="program read from script file")
    parser.add_argument("ARGS", nargs="*",
                        help="arguments passed to program in sys.argv[1:]")

    args = _parse_args()
    if args is None:
        parser.print_usage(sys.stderr)
        sys.exit(2)

    global _quiet
    help, _quiet, module, file, rest = args

    if help:
        parser.print_help()
        sys.exit()

    if module:
        # TODO: Handle exception in the module.
        sys.argv = [module, *rest]
        cwd = os.path.abspath(os.getcwd())
        if cwd not in sys.path:
            sys.path.insert(0, cwd)
        runpy.run_module(module, run_name="__main__", alter_sys=True)
    elif file == "-":
        file = "<string>"
        code = sys.stdin.read()
        del sys.argv[0]
        globs = {"__name__": "__main__"}
        with _handle_exception(file):
            exec(code, globs)
    elif file:
        sys.argv = [file, *rest]
        script_dir = os.path.abspath(os.path.dirname(file))
        if script_dir not in sys.path:
            sys.path.insert(0, script_dir)
        with _handle_exception(file):
            runpy.run_path(file, run_name="__main__")
    else:
        # TODO: Implement interactive mode.
        # TODO: Show usage in a message box.
        parser.print_usage()
        sys.exit()


def _parse_args():
    # Parse arguments manually instead of using ArgumentParser.parse_args,
    # because I want to keep the strict order of arguments.
    if len(sys.argv) < 2:
        return

    args = sys.argv[1:]

    help = False
    quiet = False
    module = None
    file = None
    rest = []

    if args[0] in ("-h", "--help"):
        help = True
        return help, quiet, module, file, rest

    if args[0] in ("-q", "--quiet"):
        quiet = True
        del args[0]

    if len(args) < 1:
        return

    if args[0] == "-m":
        if len(args) < 2:
            return
        module, *rest = args[1:]
    else:
        file, *rest = args

    return help, quiet, module, file, rest


@contextmanager
def _handle_exception(entry_filename):
    """Drop auxiliary traceback frames and show the exception."""
    try:
        yield
    except (SyntaxError, Exception) as err:
        tbe = traceback.TracebackException.from_exception(err)
        skip_frames = 0
        for i, frame in enumerate(tbe.stack):
            if frame.filename == entry_filename:
                skip_frames = i
                break
        if (isinstance(err, SyntaxError) and err.filename == entry_filename and
                skip_frames == 0):
            skip_frames = len(tbe.stack)
        tbe.stack = traceback.StackSummary.from_list(tbe.stack[skip_frames:])
        _print_exception("".join(tbe.format()))
        sys.exit(1)


def _excepthook(type, value, tb):
    _print_exception("".join(traceback.format_exception(type, value, tb)))


def _print_exception(text):
    if sys.stderr is not None:
        print(text, end="", file=sys.stderr, flush=True)
    if not _quiet:
        # TODO: Add more MB_* constants to the module?
        MB_ICONERROR = 0x10
        message_box(text, options=MB_ICONERROR)


def _handle_system_exit(value):
    # Reference implementation: pythonrun.c/_Py_HandleSystemExit
    if value is None:
        return 0

    if isinstance(value, BaseException):
        try:
            code = value.code
        except AttributeError:
            pass
        else:
            value = code
            if value is None:
                return 0

    if isinstance(value, int):
        return value

    if sys.stderr is not None:
        print(value, file=sys.stderr, flush=True)
    return 1
