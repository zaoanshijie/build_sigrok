#!/bin/bash -e
#脚本的运行目录
script_dir=$(
    cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd
)

lib_version="master"
lib_name=libsigrokdecode

cd ${BUILD_DIR}
src_dir=${BUILD_DIR}/${lib_name}
# build_dir=${BUILD_DIR}/${lib_name}_build

rm -rf ${src_dir}
git clone  https://github.com/sigrokproject/${lib_name}.git

cd ${src_dir}
git checkout ${lib_version}

./autogen.sh
./configure --disable-shared --enable-static ${BUILD_CONFIG}
make -j
make install