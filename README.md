This is a collection of various annotated disassemblies I've done while trying to learn the inner workings of certain programs and routines.

Links:
- [Compiler Explorer](https://godbolt.org) (also known as "godbolt")

Disassemblies:
- `string_view_contains` - the `contains()` method on a C++ `std::basic_string_view<char>`
  - disassembly taken from simply running the code `my_string_view.contains(needle)` in godbolt with compiler flags `-std=c++23 -O3 -mabi=ms`
- `memcmp` - the C standard library's `memcmp()` method, specifically MSVC's version of it taken from `vcruntime.lib`
  - disassembly found by writing a simple MASM x86 program that links to `vcruntime.lib` and calls `memcmp`, and stepping thru it in WinDbg, just to get access to the memcmp machine code
