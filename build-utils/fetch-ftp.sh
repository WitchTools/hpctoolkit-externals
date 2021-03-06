#!/bin/sh
#
#  Download and unpack one tarfile using wget.  The tarfile can be
#  already downloaded in DISTDIR or externals/distfiles, or else this
#  script will first download it and put it there.
#
#  This script is called from Makefile.inc from within the package
#  directory, it is not used interactively.  The package Makefile
#  should set FETCH_TARFILE, FETCH_URL_1, FETCH_URL_2, etc, and these
#  are passed as follows.
#
#  Usage: fetch-ftp.sh FETCH_TARFILE FETCH_URL_1 ...
#
#  Note: this script fetches a single file.
#
#  $Id$
#

default_distdir=../distfiles
tarfile="$1"
url_1="$2"
shift

die()
{
    echo "$0: $*"
    exit 1
}

#------------------------------------------------------------
# Step 1 -- Search for the file in DISTDIR (if set) or else in
# externals/distfiles.
#------------------------------------------------------------

the_file=
if test -d "$DISTDIR" && test -f "${DISTDIR}/${tarfile}" ; then
    the_file="${DISTDIR}/${tarfile}"
elif test -f "${default_distdir}/${tarfile}" ; then
    the_file="${default_distdir}/${tarfile}"
fi
if test "x$the_file" != x ; then
    echo "found tarfile: $the_file"
fi

#------------------------------------------------------------
# Step 2 -- If not found in step 1, then try the command-line
# arguments (FETCH_URL_1. FETCH_URL_2, ...)  and save in DISTDIR or
# externals/distfiles.
#------------------------------------------------------------

if test "x$the_file" = x ; then
    if type wget >/dev/null 2>&1 ; then :
    else
	die "unable to find wget"
    fi

    write_dir="$default_distdir"
    if test -d "$DISTDIR" ; then
	write_dir="$DISTDIR"
    fi

    for url in "$@"
    do
	if test "x$url" = x ; then
	    continue
	fi
	echo "wget $url"
	wget -t 4 -O "${write_dir}/${tarfile}" "$url"
	if test $? -eq 0 && test -s "${write_dir}/${tarfile}" ; then
	    the_file="${write_dir}/${tarfile}"
	    break
	else
	    echo "wget failed: $url"
	fi
    done
fi

#
# If unable to fetch the file, then tell the user what to try
# manually.
#
if test "x$the_file" = x ; then
    cat <<EOF

Unable to find or download the file: $tarfile
Try downloading this file manually and putting it in the
externals/distfiles directory and rerunning make fetch.

See the package README for notes on where to find this file.

EOF
    die "make fetch failed"
fi

#------------------------------------------------------------
# Step 3 -- Unpack the tarfile.
#------------------------------------------------------------

case "$the_file" in
    *.tar )
	echo tar xf "$the_file"
	tar -x -f "$the_file"
	test $? -eq 0 || die "unable to untar: $the_file"
	;;

    *.tar.gz | *.tgz )
	echo tar xzf "$the_file"
	tar -x -z -f "$the_file"
	test $? -eq 0 || die "unable to untar: $the_file"
	;;

    *.tar.bz | *.tar.bz2 | *.tbz )
	echo tar xjf "$the_file"
	tar -x -j -f "$the_file"
	test $? -eq 0 || die "unable to untar: $the_file"
	;;

    *.zip | *.ZIP )
	echo unzip -q "$the_file"
	unzip -q "$the_file"
	test $? -eq 0 || die "unable to unzip: $the_file"
	;;

    * )
	die "unknown file format: $tarfile"
	;;
esac
