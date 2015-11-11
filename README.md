CREATING SHARED LIBRARY:

* library sources in `src`, headers in `include`,
* all compiled elements are placed in `build`, created if not present,
* sources compiled into .o files with `-fPIC`, library ingredients
* the .o files gethered to build a final library of a REAL_NAME, but identified
  by loader with SONAME, which is specified as a compilation flag,
  `-Wl,-soname,<SONAME> -o <REAL_NAME> <files> <ext_libs>`
* final library moved to `release` and links created:
  * COMPILATION_NAME link has to be created manually,
  * SONAME link is created by `ldconfig`,

$ make library
$ make release

example:
    REAL_NAME: libfoo.so.1.0 (real binary)
    ^
    SONAME: libfoo.so.1 (soft link)
    ^
    COMPILATION_NAME: libfoo.so (soft link)

* normally, installing shared library means coping it to standard location:
  /usr/local/lib and run ldconfig (as a root), this is faked by the `release`
  directory in the example,

* client program remembers which version it was compiled with (SONAME pointed
  by COMPILATON_NAME), later, on loading, only SONAME is looked for. It can
  even point to other library version, if API remained unchanged.

- EXAMPLE: -
* along with the source code, the VERNB and RELNB in the script have to be
  changed properly, and `client_test.c`.

1) First version, VERNB=1, RELNB=0
* client program in `dev` compiled and linked against the library (identified
  by SONAME), but the library is not in standard location, so it cannot be
  found. Solutions:
  * Specifying additional path to the loader (client_v1):
    $ run_v1
    $ /lib64/ld-linux-x86-64.so.2 --library-path ./release ./dev/client_v1
    equivalently:
    $ LD_LIBRARY_PATH=release ./dev/client_v1
    then, the binary does not have to be recompiled, flag should not be used as
    a permanent solution,

2) Small change, same API, VERNB=1, RELNB=1
* patching the library code and testing before releasing and without breaking
  already compiled programs,
  * modify library code and build it:
        $ make library
  * create the links in test location:
        $ make test_build
  * build the client with hardwired new library: $ make client_test
    (added -Wl,-rpath,<LOCATION>)

* if the change is OK (patch) it can be released with only release number
  changed, version number stays the same since API did not changed (backward
  compatibility):
        $ make release
  * SONAME update: from `libX.so.1`->`libX.so.1.0` to `libX.so.1`->`libX.so.1.1`
    so the program compiled before will use the patched version of a library,
  * COMPILATION_NAME not changed: `libX.so`->`libX.so.1`,
  
3) API change, VERNB=2, RELNB=0
* change in the API, version number has to be changed because totally new
  SONAME has to be created and both versions of the library can exist together
  * old programs will use old version of a library,
  * newly compiled programs will use new version (new SONAME pointed by new
    COMPILATION_TIME),
  * testing client implementation updated
        $ make library
        $ make test_build
        $ make clean_test && make client_test
        $ make run_test
  * release the new version
  * building the client of a new version:
        $ make client_v2 && make run_v2
    it runs with the version 2.0, whereas `client_v1` still uses version 1.1
    

