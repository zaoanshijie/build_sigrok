#!/bin/bash -e
#脚本的运行目录
script_dir=$(
    cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd
)

bash ${script_dir}/script/download_libusb.sh
bash ${script_dir}/script/convert_python.sh
bash ${script_dir}/script/build_glib.sh
bash ${script_dir}/script/build_glibmm.sh
bash ${script_dir}/script/build_libzip.sh
bash ${script_dir}/script/build_libserialport.sh
bash ${script_dir}/script/build_libsigrok.sh
bash ${script_dir}/script/build_libsigrokdecode.sh

# 复制依赖
cp ${TOOLCHAIN_PATH}/${TOOLCHAIN_PREFIX}/bin/libunwind.dll ${PREFIX}/bin/
cp ${TOOLCHAIN_PATH}/${TOOLCHAIN_PREFIX}/bin/libc++.dll ${PREFIX}/bin/