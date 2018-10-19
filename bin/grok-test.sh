#!/bin/bash

set -ue

log() {
  echo "$@" >&2
}

grok_test() {
  local test=$1

  ${GROK_TEST:-grok-test} "${@:2}" $test.log > $test.new

  if test -e $test.out; then
    if diff -u $test.out $test.new > $test.diff; then
      log "[OK] $test"
    else
      log "[DIFF] $test"
      cat $test.diff | sed 's/^/    /'
    fi

    rm $test.diff
  else
    log "[NEW] $test"
  fi

  mv $test.new $test.out
}

grok_test "$@"
