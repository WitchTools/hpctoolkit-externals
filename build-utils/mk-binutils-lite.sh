#!/bin/sh
#
# Make a binutils-lite tar file for externals's distfiles and exclude
# the following subdirs.  We don't use them for hpctoolkit, so this
# saves space in the git repo.
#
#   binutils
#   cpu
#   gas
#   gdb
#   gold
#   gprof
#   ld
#   md5.sum
#   .git
#
# Usage: unpack binutils tar file (or git clone) and run:
#
#   mk-binutils-lite.sh  directory  [version]
#

exclude_list='binutils cpu gas gdb gold gprof ld md5.sum .git'

die() {
    echo "error: $@"
    exit 1
}

dir="$1"
version="$2"

test -d "$dir" || die "not a directory: $dir"

if test "x$version" = x ; then
    base=`basename "$dir"`
    version=`expr "$base" : 'binutils-\(.*\)'`
fi
tar_file="binutils-lite-${version}.tar"

set --

for f in $exclude_list ; do
    set -- "$@" --exclude "$f"
done

set -- "$@" "$dir"

echo "making tar file: $tar_file ..."

rm -f "$tar_file" "${tar_file}.bz2"

echo
echo tar cf "$tar_file" "$@"

tar cf "$tar_file" "$@"
test $? -eq 0 || die "tar failed"

bzip2 "$tar_file"
test $? -eq 0 || die "bzip2 failed"

echo
ls -lh "${tar_file}.bz2"
