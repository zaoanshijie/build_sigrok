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
# export LD=${TOOLS}/x86_64-w64-mingw32-ld
./configure ${BUILD_CONFIG} LD="${TOOLS}/x86_64-w64-mingw32-ld"
# Fix libtool: replace MSVC-style 'lib -OUT:' with POSIX 'ar cr' for static archiving
# LLVM-mingw uses ar, not lib.exe
sed -i '/old_archive_cmds="lib -OUT/c old_archive_cmds="\$AR \$AR_FLAGS \\\$oldlib\\\$oldobjs\\\$old_deplibs"' libtool
# Fix libtool: change libext from .lib (MSVC) to .a (mingw) for static libraries
sed -i 's/^libext=lib$/libext=a/' libtool
make -j
make install