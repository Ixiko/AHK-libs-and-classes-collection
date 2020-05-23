StringCaseSense, On
group := tester.newGroup("array_sort(callback)")


; test subgroup 1: basic arrays
string_array := ["Delta","alpha","delta","Beta","Charlie","beta","Alpha","charlie"]
number_array := [11,9,5,10,1,6,3,4,7,8,2]
assert_strings := ["Alpha","Beta","Charlie","Delta","alpha","beta","charlie","delta"]

group.newTest("String array"
    , Assert.arrayEqual(assert_strings, array_sort(string_array)))

group.newTest("Number array"
    , Assert.arrayEqual([1,2,3,4,5,6,7,8,9,10,11], array_sort(number_array)))


; test subgroup 2: complex arrays (objects)
complex_array := [{"symbol": "Delta", "morse": "-***"}
    , {"symbol": "alpha", "morse": "*-"}
    , {"symbol": "delta", "morse": "-**"}
    , {"symbol": "Beta", "morse": "-***"}
    , {"symbol": "Charlie", "morse": "-*-*"}
    , {"symbol": "beta", "morse": "-***"}
    , {"symbol": "Alpha", "morse": "*-"}
    , {"symbol": "charlie", "morse": "-*-*"}]

accessor_fn := func("objProp_get").bind("symbol")
sorting_fn := func("complex_sort").bind(accessor_fn)
array_sort(complex_array, sorting_fn)

group.newTest("Using accessor function with complex arrays: key='symbol'"
    , Assert.arrayEqual(assert_strings, array_map(complex_array, accessor_fn)))

accessor_fn := func("objProp_get").bind("morse")
assert_morse := ["*-","-***","-*-*","-***","*-","-***","-*-*","-**"]

group.newTest("Using accessor function with complex arrays: key='morse'"
    , Assert.arrayEqual(assert_morse, array_map(complex_array, accessor_fn)))
