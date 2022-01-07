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

echo 'int main() { return 0; }' > "$t"/a.c

$CC -B. -o "$t"/exe "$t"/a.c -Wl,-build-id
readelf -n "$t"/exe | grep -qv 'GNU.*0x00000010.*NT_GNU_BUILD_ID'

$CC -B. -o "$t"/exe "$t"/a.c -Wl,-build-id=uuid
readelf -nW "$t"/exe |
  grep -Pq 'GNU.*0x00000010.*NT_GNU_BUILD_ID.*Build ID: ............4...[89abcdef]'

$CC -B. -o "$t"/exe "$t"/a.c -Wl,-build-id=md5
readelf -n "$t"/exe | grep -q 'GNU.*0x00000010.*NT_GNU_BUILD_ID'

$CC -B. -o "$t"/exe "$t"/a.c -Wl,-build-id=sha1
readelf -n "$t"/exe | grep -q 'GNU.*0x00000014.*NT_GNU_BUILD_ID'

$CC -B. -o "$t"/exe "$t"/a.c -Wl,-build-id=sha256
readelf -n "$t"/exe | grep -q 'GNU.*0x00000020.*NT_GNU_BUILD_ID'

$CC -B. -o "$t"/exe "$t"/a.c -Wl,-build-id=0xdeadbeef
readelf -n "$t"/exe | grep -q 'Build ID: deadbeef'

echo OK
