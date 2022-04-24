#!/bin/bash
set -e

function abortHelp() {
  echo "Usage:"
  echo "  $0 <positional1> [flags]"
  echo "  -h --help   Show this help"
  echo "  -t --tun    Create tunnel"
  exit 1
}

AOPT_VALID_ARGS=("help" "h" "tun" "t") # Optional
source minimist.sh

if [[ $ARG_h == 'y' || $ARG_HELP == 'y' ]]; then
	abortHelp
fi

if [[ -z $1 ]]; then
  echo "Required pos arg 1"
  abortHelp
fi

if [[ $ARG_t == 'y' || $ARG_TUN == 'y' ]]; then
  echo "You want a tunnel"
fi

echo "Tunneling to $1"
echo
echo "ARG_V: $ARG_V"
echo "\$@: $@"
