#!/bin/bash -e
#脚本的运行目录
script_dir=$(
    cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd
)

lib_version="master"
lib_name=libsigrok

cd ${BUILD_DIR}
src_dir=${BUILD_DIR}/${lib_name}
# build_dir=${BUILD_DIR}/${lib_name}_build

rm -rf ${src_dir}
git clone  https://github.com/sigrokproject/${lib_name}.git

cd ${src_dir}
git checkout ${lib_version}


./autogen.sh
# Override LD to use the wrapper that handles -r (relocatable) flag
# since LLD for PE/COFF targets does not support -r
# export LD=${script_dir}/x86_64-w64-mingw32-ld

./configure  --verbose ${BUILD_CONFIG} LD="${script_dir}/x86_64-w64-mingw32-ld"
# Fix libtool: replace MSVC-style 'lib -OUT:' with POSIX 'ar cr' for static archiving
# LLVM-mingw uses ar, not lib.exe
sed -i '/old_archive_cmds="lib -OUT/c old_archive_cmds="\$AR \$AR_FLAGS \\\$oldlib\\\$oldobjs\\\$old_deplibs"' libtool
# Fix libtool: change libext from .lib (MSVC) to .a (mingw) for static libraries
sed -i 's/^libext=lib$/libext=a/' libtool
# Fix libtool: replace MSVC-style shared library command (-link) with POSIX-style (-shared)
# LLD does not understand the MSVC -link flag and treats it as a library name
# Also generate .def file for DLL exports since LLD --export-all-symbols is broken for COFF
# After linking, copy the output to the versioned DLL name that libtool expects
bash tools/fix_libtool_archives.sh
# Fix libtool: set export_dynamic_flag_spec for the default (C) tag
# (kept for consistency, though the real export handling is in archive_cmds above)
sed -i '/^export_dynamic_flag_spec="\"$/s/""/"\\\$wl--export-all-symbols"/' libtool
make -j
# Workaround: libtool tries to install old_library (.a) even with --disable-static
# Clear old_library references in .la files to prevent install failures
sed -i "s/^old_library=.*/old_library=''/" libsigrok.la bindings/cxx/libsigrokcxx.la 2>/dev/null || true
make install