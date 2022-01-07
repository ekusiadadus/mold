#!/bin/bash
export LANG=
set -e
CC="${CC:-cc}"
CXX="${CXX:-c++}"
testname=$(basename -s .sh "$0")
echo -n "Testing $testname ... "
cd "$(dirname "$0")"/../..
mold="$(pwd)/mold"
t="$(pwd)/out/test/elf/$testname"
mkdir -p "$t"

cat <<EOF | $CC -fcommon -c -xc -o "$t"/a.o -
int foo;
EOF

cat <<EOF | $CC -fcommon -c -xc -o "$t"/b.o -
int foo;

int main() {
  return 0;
}
EOF

$CC -B. -o "$t"/exe "$t"/a.o "$t"/b.o > "$t"/log
! fgrep -q 'multiple common symbols' "$t"/log || false

$CC -B. -o "$t"/exe "$t"/a.o "$t"/b.o -Wl,-warn-common 2> "$t"/log
fgrep -q 'multiple common symbols' "$t"/log

echo OK
