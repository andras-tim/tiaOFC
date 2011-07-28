#!/bin/bash

#Example: ./test.sh /etc init.d
[ $# -lt 2 ] && exit 1

PRGPATH="`pwd`"
TESTPATH="$PRGPATH/tia-ofc_test"

function get_md5sum()
{
    cd "$1" || exit $?
    find . -type f | sort | while read a
    do
       md5sum "$a" | awk '{print $2"\t"$1}'
    done
}

echo ' * Preparing environment'
[ -e  "$TESTPATH" ] && rm -r "$TESTPATH"
mkdir "$TESTPATH" || exit $?
cp 'tia-ofc' "$TESTPATH/tia-ofc" || exit $?

echo ' * Starting compress'
cd "$1" || exit $?
"$TESTPATH/tia-ofc" --import "$2" || exit $?

echo ' * Starting extract'
cd "$TESTPATH" || exit $?
./tia-ofc --export || exit $?

echo ' * Checking result'
get_md5sum "$1/$2" > "$TESTPATH/chksum-orig.md5"
get_md5sum "$TESTPATH/$2" > "$TESTPATH/chksum-uncomp.md5"

diff -u "$TESTPATH/chksum-orig.md5" "$TESTPATH/chksum-uncomp.md5" || exit $?

echo 'OK'
rm -r "$TESTPATH"
exit 0

