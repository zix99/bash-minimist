#!/bin/bash
# https://github.com/zix99/bash-minimist
# Usage:
#
# Minimist is modeled after a similar script by the same name written for nodejs/javascript
# Its goal is to provide a minimal command-line parser for input into scripts
# Unlike classical approaches, no help-doc or pre-defined variable sets are defined
#
# Quickstart
# In your script call
#   source minimist.sh
#
# Or to not override $@ call
#   source minimist.sh $@
#
# To read values once parse
#   -a         ARG_a=y
#   -ab        ARG_a=y ARG_b=y
#   --abc      ARG_ABC=y
#   --abc 123  ARG_ABC=123
#   --abc=234  ARG_ABC=234
#   -a a b     ARG_a=y ARGV="a b"
#   --a-b#c    ARG_A_B_C=y
#
# ARG_0 preserves $0
# ARG_V is the positionals before a ending marker --
# $1...n are only positional arguments, exclusive of flags
# Everything following -- marker are treated as positional arguments
# $@ includes all positional arguments, excluding flags
#
# Functional changes
# To change basic functional requirements, please see configuration below
# Either change it inline, or declare it before calling `source minimist.sh`


# Configuration
# If y, a flag that looks like "--abc 123", 123 will be positional rather than a value of 'abc'
AOPT_POSITIONAL_OVER_FLAG=${AOPT_POSITIONAL_OVER_FLAG:-y}

# Arguments for `declare`. Defaults to -r for readonly. eg adding `-x` will export values
AOPT_DECLARE_FLAGS=${AOPT_DECLARE_FLAGS:--r}

# If y, will override -- ($@) to be the full positional argument set, rather than remaining unparsed variables
AOPT_SET_ARGS=${AOPT_SET_ARGS:-y}

# Value to set for truthy flags
AOPT_TRUTHY=${AOPT_TRUTHY:-y}

# If y, exit on error
AOPT_EXIT_ON_ERROR=${AOPT_EXIT_ON_ERROR:-y}

# Prefix of exported arguments
AOPT_PREFIX=${AOPT_PREFIX:-ARG_}

# Array of valid flags (If empty, assume all flags are valid)
[[ -z $AOPT_VALID_ARGS ]] && AOPT_VALID_ARGS=()

################
function __handleError() {
  echo "$1"
  if [[ ${AOPT_EXIT_ON_ERROR^^} == 'Y' ]]; then
    exit 2
  fi
}

function handleInvalidKey() {
  __handleError "Invalid key: '$1', as part of '${2:-$1}'"
}

function __validateArgument() {
  if [[ ${#AOPT_VALID_ARGS[@]} -gt 0 && ! " ${AOPT_VALID_ARGS[*]^^} " =~ " ${1^^} " ]]; then
    __handleError "Invalid argument: --${1}"
  fi
}

function sanitize() {
  local CLEAN=$@
  CLEAN=${CLEAN//[^a-zA-Z0-9_]/_}
  echo -n $CLEAN
}

ARG_0=$0
ARGV=
while (( "$#" )); do
  case "$1" in
    --) # Stop parsing args (the rest is positional)
      shift
      break
    ;;
    --*=*) # --abc=123
      KEY=${1%=*}
      KEY=${KEY:2}
      KEY=$(sanitize $KEY)
      __validateArgument ${KEY}
      declare ${AOPT_DECLARE_FLAGS} "${AOPT_PREFIX}${KEY^^}=${1#*=}" 2>/dev/null || handleInvalidKey $KEY
      shift
    ;;
    --*) # --abc OR --abc 123
      KEY=$(sanitize $1)
      __validateArgument ${KEY:2}
      KEY=${KEY^^}
      shift
      if [[ ! -z $1 && ${1:0:1} != '-' && ${AOPT_POSITIONAL_OVER_FLAG^^} != 'Y' ]]; then
        declare ${AOPT_DECLARE_FLAGS} "${AOPT_PREFIX}${KEY:2}=$1" 2>/dev/null || handleInvalidKey $KEY
        shift
      else
        declare ${AOPT_DECLARE_FLAGS} "${AOPT_PREFIX}${KEY:2}=$AOPT_TRUTHY" 2>/dev/null || handleInvalidKey $KEY
      fi
    ;;
    -*) # Multi-flag single-char args; -abc -a -b -C
      KEY=$1
      for (( i=1; i<${#KEY}; i++ )); do
        [[ ${#AOPT_VALID_ARGS[@]} -gt 0 && ! " ${AOPT_VALID_ARGS[*]} " =~ " ${1:$i:1} " ]] \
          && __handleError "Invalid flag: -${1:$i:1}"
        declare ${AOPT_DECLARE_FLAGS} "${AOPT_PREFIX}${KEY:$i:1}=$AOPT_TRUTHY" 2>/dev/null || handleInvalidKey ${KEY:$i:1} $KEY
      done
      shift
    ;;
    *) # positional args
      ARGV="${ARGV:+$ARGV }$1"
      shift
    ;;
  esac
done

# Reset positional arguments
declare ${AOPT_DECLARE_FLAGS} "${AOPT_PREFIX}V=${ARGV}"
declare ${AOPT_DECLARE_FLAGS} "${AOPT_PREFIX}0=${ARG_0}"

if [[ ${AOPT_SET_ARGS^^} == 'Y' ]]; then
  set -- ${ARGV} "$@"
fi

# Cleanup non-exported things (since this will be sourced)
unset ARGV
unset KEY
unset sanitize
unset handleInvalidKey
unset __handleError
unset __validateArgument
