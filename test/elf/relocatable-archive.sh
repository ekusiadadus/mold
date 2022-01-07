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
void bar();
void foo() {
  bar();
}
EOF

cat <<EOF | $CC -c -o "$t"/b.o -xc -
void bar() {}
EOF

cat <<EOF | $CC -c -o "$t"/c.o -xc -
void baz() {}
EOF

cat <<EOF | $CC -c -o "$t"/d.o -xc -
void foo();
int main() {
  foo();
}
EOF

ar crs "$t"/e.a "$t"/a.o "$t"/b.o "$t"/c.o
"$mold" -r -o "$t"/f.o "$t"/d.o "$t"/e.a

readelf --symbols "$t"/f.o > "$t"/log
grep -q 'foo$' "$t"/log
grep -q 'bar$' "$t"/log
! grep -q 'baz$' "$t"/log || false

echo OK
