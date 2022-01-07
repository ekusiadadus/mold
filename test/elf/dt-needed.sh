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

cat <<EOF | $CC -c -o "$t"/a.o -xc -
void foo() {}
EOF

$CC -B. -shared -o "$t"/libfoo.so "$t"/a.o -Wl,--soname,libfoo
$CC -B. -shared -o "$t"/libbar.so "$t"/a.o

cat <<EOF | $CC -c -o "$t"/b.o -xc -
void foo();
int main() { foo(); }
EOF

$CC -B. -o "$t"/exe "$t"/b.o "$t"/libfoo.so
readelf --dynamic "$t"/exe | fgrep -q 'Shared library: [libfoo]'

$CC -B. -o "$t"/exe "$t"/b.o -L "$t" -lfoo
readelf --dynamic "$t"/exe | fgrep -q 'Shared library: [libfoo]'

$CC -B. -o "$t"/exe "$t"/b.o "$t"/libbar.so
readelf --dynamic "$t"/exe | grep -Pq 'Shared library: \[.*dt-needed/libbar\.so\]'

$CC -B. -o "$t"/exe "$t"/b.o -L"$t" -lbar
readelf --dynamic "$t"/exe | fgrep -q 'Shared library: [libbar.so]'

echo OK
