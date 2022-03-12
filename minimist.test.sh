#!/bin/bash
set -e

VERBOSE=${VERBOSE:-n}

ERROR_COUNT=0
function assert() {
  if [[ $VERBOSE == 'y' ]]; then
    echo "$(caller): ${FUNCNAME[1]} asserted '$1' == '$2'"
  fi
  if [[ "$1" != "$2" ]]; then
    echo "$(caller) Assertion failed: '$1' != '$2'" >&2
    ERROR_COUNT=$((ERROR_COUNT+1))
  fi
}

function test_basic() {
  source minimist.sh -a --long -Abc abc 123
  assert $ARG_a y
  assert $ARG_LONG y
  assert $ARG_A y
  assert $ARG_b y
  assert $ARG_c y
  assert "$ARG_V" "abc 123"
  assert "$ARG_0" "./minimist.test.sh"
}

function test_positional() {
  AOPT_POSITIONAL_OVER_FLAG=n
  source minimist.sh abc -a bq --key val -- -ab --cd 123
  assert $ARG_KEY val
  assert "$ARG_V" "abc bq"
}

function test_positional_override() {
  AOPT_POSITIONAL_OVER_FLAG=y
  source minimist.sh --abc 123
  assert $ARG_ABC y
  assert $ARG_V 123
}

function test_duplicate_definitions() {
  source minimist.sh -aa 2>/dev/null || true
  assert $ARG_a y
}

function test_empty_equals() {
  source minimist.sh --abc=
  assert $ARG_ABC ""
}

function test_full_equals() {
  source minimist.sh --abc=qef "--def=this is long" --double=a=b
  assert $ARG_ABC qef
  assert "$ARG_DEF" "this is long"
  assert "$ARG_DOUBLE_A" "a=b"
}

function test_no_export() {
  source minimist.sh "--abc=123"
  assert $ARG_ABC 123
  FOUND=$(env | grep ARG_ || echo)
  assert $FOUND ""
}

function test_export() {
  AOPT_DECLARE_FLAGS=-rx
  source minimist.sh "--abc=456"
  assert $ARG_ABC 456
  FOUND=$(env | grep ARG_ABC || echo)
  assert $FOUND "ARG_ABC=456"
}

function test_truthy_override() {
  AOPT_TRUTHY=1
  source minimist.sh -ab --charlie
  assert $ARG_a 1
  assert $ARG_b 1
  assert $ARG_CHARLIE 1
  AOPT_TRUTHY=y
}

function test_invalid_key() {
  source minimist.sh '-wz -f'
  assert $ARG_w "y"
  assert $ARG_z "y"
  assert $ARG_f "y"
}

function test_spaces_in_key() {
  source minimist.sh "--test thing=bla"
  assert "$ARG_TEST_THING" "bla"
}

function test_spaces_in_value() {
  source minimist.sh "--test=bla bla"
  assert "$ARG_TEST" "bla bla"
}

function test_sanitizing_key() {
  source minimist.sh "--test-bla=bla"
  assert "$ARG_TEST_BLA" "bla"
}

function test_sanitizing_non_alphanum() {
  source minimist.sh "--test#123-*=abc @@23"
  assert "$ARG_TEST_123__" "abc @@23"
}

export AOPT_EXIT_ON_ERROR=n

if [[ -z $1 ]]; then
  test_basic
  test_positional
  test_positional_override
  test_duplicate_definitions
  test_empty_equals
  test_full_equals
  test_no_export
  test_export
  test_truthy_override
  test_invalid_key
  test_spaces_in_key
  test_spaces_in_value
  test_sanitizing_key
  test_sanitizing_non_alphanum
else
  eval "$1"
fi

if [[ $ERROR_COUNT -gt 0 ]]; then
  echo "There were $ERROR_COUNT errors"
  exit 1
else
  echo "Tests finished successfully"
fi
