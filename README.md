# bash-minimist

[![Build Status](https://travis-ci.org/zix99/bash-minimist.svg?branch=master)](https://travis-ci.org/zix99/bash-minimist)

*bash-minimist* is a lightweight bash script inspired by the NodeJS module [minimist](https://github.com/substack/minimist).

It is meant to be a very simple and non-invasive argument parser.  It will convert any flags or positional arguments into appropriate variables and expose them to your script.

This will fit into your application well 90% of the time for simple things, and once you outgrow it, it should be easy to convert.

## Usage

Download [minimist.sh](minimist.sh) and place in your script path.

Add `source minimist.sh` to your script after your shebang.

See [minimist.example.sh](minimist.example.sh) for a complete example, and the header of *minimist.sh* for details.

```sh
#!/bin/bash
source minimist.sh

# Now my variables are exposed via ARG_
# Positional args have been rewritten, and all flags are excluded. So $1, $2, $3, etc will only be positional
if [[ $ARG_HELP == 'y' ]]; then
	echo "Someone passed --help"
fi
```

## Configuration

At the top of *minimist.sh* there are a few configurable items, which you can change inline or set before calling minimist.

For instance, to export any parsed args (rather than just setting locally-scoped variables), you could do:

```sh
#!/bin/bash
AOPT_DECLARE_FLAGS="-rx" # Readonly, export on 'declare'
source minimist.sh

echo "Now other scripts can access $ARG_"
```

## Error checking

The script by itself provides minimal input sanitation.  Any non-alphanumeric character will be replaced by a `_`

If there is still an error after sanitation, an error will be thrown by default (configurable).

All other validation is expected to be done by the script (required variables, etc).

# License

The MIT License (MIT)
Copyright (c) 2019 Chris LaPointe

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
