#!/bin/bash

set -ue

BIN=${BIN:-$PWD/.bin}
SRC=$(dirname $0)
VERSION=0.2.0

log() {
  echo "$@" >&2
}

test -d $BIN || mkdir $BIN

(
  cd $SRC

  test -e grok-test-$VERSION.gem || gem build grok-test.gemspec
  test -e $BIN/.grok-test_$VERSION || gem install --user --bindir=$BIN grok-test-$VERSION.gem && touch $BIN/.grok-test_$VERSION
  if [ \! -e $BIN/grok-test.sh ] || [ grok-test.sh -nt $BIN/grok-test.sh ]; then
    install -m 0755 -t $BIN bin/grok-test.sh
  fi
)
