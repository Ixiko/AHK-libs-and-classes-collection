import os
import subprocess
from textwrap import dedent


AHK = "C:\\Program Files\\AutoHotkey\\AutoHotkey.exe"
EMBED_PYTHON = os.path.abspath("EmbedPython.ahk")


def run_embed_python(args, **kwargs):
    args = [AHK, EMBED_PYTHON, *args]
    return subprocess.run(args, text=True, capture_output=True, **kwargs)


def run_from_input(code, *, quiet=False):
    # TODO: Share the function with test_embed
    args = ["-"]
    if quiet:
        args.insert(0, "-q")
    return run_embed_python(args, input=dedent(code))
