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

cat <<EOF | $CC -c -xc -o "$t"/a.o -
#include <stdio.h>

int main() {
  printf("Hello world\n");
}
EOF

$CC -B. -Wl,--verbose -o "$t"/exe "$t"/a.o > /dev/null

echo OK
