# Logd [![Build Status](https://travis-ci.org/ernestrc/logd.svg)](https://travis-ci.org/ernestrc/logd)
Logd is a log processor daemon that exposes a lua API to run arbitrary logic on structured logs.

## Logd module API
| Builtin | Description |
| --- | --- |
| `function logd.log_get (logptr, key) value` | Get a property from the log |
| `function logd.log_set (logptr, key, value)` | Set a property to the log |
| `function logd.log_remove (logptr, key)` | Remove a property from a log |
| `function logd.log_reset (logptr)` | Reset all log properties |
| `function logd.log_clone (logptr) logptr` | Make a safe clone of logptr which will be managed by lua's GC. |
| `function logd.to_str (logptr) str` | Serialize a log into a string |
| `function logd.to_logptr (table) logptr` | Convert a table into a logptr |
| `function logd.to_table (logptr) table` | Convert a logptr into a table |
| `function logd.print (string\|table\|logptr)` | Serialize message or table into a log string and print it to the standard output |

| Hook | Description |
| --- | --- |
| `function logd.on_log (logptr)` | Logs are parsed and supplied to this handler. Use `logd.log_*` set of functions to manipulate them. |
| `function logd.on_eof ()` | Called when collector has reached EOF reading the input file. |
| `function logd.on_error (error, logptr, at)` | Called when collector failed to parse a log line. Parsing will resume after this function returns. |

## Preloaded Lua modules
- [logd](#logd-module-api)
- [uv](https://github.com/luvit/luv)
- [miniz](https://github.com/luvit/luvi/blob/master/src/lminiz.c) 

## Optionally Preloaded Lua modules 
Depending on the build, the following modules are preloaded:
- [lpeg](http://www.inf.puc-rio.br/~roberto/lpeg/)
- [openssl](https://github.com/zhaozg/lua-openssl)
- [zlib](https://github.com/brimworks/lua-zlib)

## Build instructions
Run configure script and then make:
```sh
$ ./configure
$ make
$ make install
```
If you have problems linking with a system dependency, you can configure the project to build the dependency from source:
```sh
$ ./configure --enable-build-luajit --enable-build-openssl
$ make
```
Alternatively, you can provide your own CFLAGS or LDFLAGS:
```sh
$ ./configure CFLAGS='-DOPENSSL_NO_STDIO -DOPENSSL_NO_SM2'
$ make
```
Finally, you can also disable some of the modules:
```sh
$ ./configure --without-openssl --without-lpeg
$ make
```
For a full list of options run `./configure --help`.

Please refer to the Docker images in [utils](utils) to see some of the common options and CFLAGS used by the different Linux distros.

## MacOS Build instructions
Assuming you have Homebrew installed:
```
$ brew update && brew bundle --file=utils/Brewfile
$ export LIBTOOL=glibtool
$ export LIBTOOLIZE=glibtoolize
$ ./configure --enable-build-all
$ make && make install
```

Please refer to MacOS section in [.travis.yml](.travis.yml) to see the latest build options.

## Parsing
The builtin parser expects logs to be in the following format:
```
YYYY-MM-dd hh:mm:ss	LEVEL	[Thread]	Class	key: value...
```
If you need to parse logs in a different format, you can load a dynamic shared object that implements [src/parser.h](src/parser.h) via the `--parser` flag. For static builds (if dlopen is disabled) or if you simply want to build the project with a different builtin parser, you can configure so with:
```
$ ./configure --with-builtin-parser=my_parser.c
```

For a list of available parsers look for the source files in [src](src) that end in \_parser.c.

## Running tests
Configure and enable the development build:
```sh
$ ./configure --enable-develop
$ make
$ make test
```

## Luvit
Logd uses Libuv under the hood and is compatible with [Luvit](https://luvit.io) modules. The Luvit runtime and standard modules are not preloaded by default but you can do so by running `lit install luvit/luvit` in your script's directory and then supplying your script to the logd executable.
