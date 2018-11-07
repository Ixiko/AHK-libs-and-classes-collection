
Creates a GUI with a searchable listview.

Searches are done via regex, each word in the search is matched separately against the column(s) being searched (case insensitive).

You can change the listview selection without activating it (Up/Down/PgUp/PgDn, pressing ctrl/shift plus one of those, ctrl/shift space, etc.)

This was written for an older version of Autohotkey, so it doesn't use some of the newer features of the language (which would make things a lot prettier - using arrays instead of `n-separated strings, variadic functions, etc.)

See demo for example usage

![demo](https://github.com/diogo0258/lvs/raw/master/demo.png)


Some more involved examples:
- <https://github.com/diogo0258/lvs-explorer>
- <https://github.com/diogo0258/lvs-active-explorer-search>
- <https://github.com/diogo0258/lvs-manage-open-windows>


Note: there are probably better ways to do this. See [SoLong&Thx4AllTheFish's CSV Quick Filter](https://autohotkey.com/board/topic/68279-csv-quick-filter-gui-show-results-in-listview-as-you-type/), or [Rajat's nDroid / 320mph](https://autohotkey.com/board/topic/2845-ndroid-formerly-320mph-ultra-fast-anything-launcher/)

