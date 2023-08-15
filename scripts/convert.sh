#!/usr/bin/env bash

set -o nounset -o pipefail -o errexit

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)" 
ROOT="$DIR/.."
BUILDDIR="$ROOT/build"
SCRIPTS="$ROOT/scripts"
HTML="$BUILDDIR/jq.html"
ORG="$BUILDDIR/jq.org"
SECTIONS="$ROOT/sections.json"
DOCS="$ROOT/jq.org"

build() {
    mkdir -p "$BUILDDIR"

    ."$SCRIPTS/jq-docs.py" "$HTML" "$SECTIONS"

    pandoc --shift-heading-level=-1         \
           --indented-code-classes=jq       \
           --columns=80                     \
           -f html-native_divs-native_spans \
           -t org                           \
           -o "$ORG"                        \
           "$HTML"

    emacs --batch -Q -l org --eval \
          "(with-temp-buffer
                (insert-file-contents \"$ORG\")
                (org-table-map-tables #'org-table-align)
                (write-file \"$DOCS\" nil))"
}

build
