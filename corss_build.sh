#!/bin/bash -e
#脚本的运行目录
script_dir=$(
    cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd
)


if [[ "$GITHUB_ACTIONS" != "true" ]]; then
  mingw_path="/mnt/data/env/llvm-mingw"
  build_dir="${script_dir}/.build"
  prefix="${script_dir}/out"
  target="x86_64"
  toolchain_triplet="${target}-w64-mingw32"

  export TOOLCHAIN_PATH=${mingw_path}
  export BUILD_DIR=${build_dir}
  export PREFIX=${prefix}
  export TOOLCHAIN_PREFIX=${toolchain_triplet}
  export TARGET="${target}"
  export PATH=${script_dir}/tools:${mingw_path}/bin:${PATH}
fi

echo "TOOLCHAIN_PATH=${TOOLCHAIN_PATH}"
echo "BUILD_DIR=${BUILD_DIR}"
echo "PREFIX=${PREFIX}"
echo "TOOLCHAIN_PREFIX=${TOOLCHAIN_PREFIX}"
echo "TARGET=${TARGET}"
echo "PATH=${PATH}"

# 预处理参数
build_config="--host=${TOOLCHAIN_PREFIX} --prefix=${PREFIX} --disable-shared --enable-static CPPFLAGS=-D__printf__=__gnu_printf__"
export BUILD_CONFIG=${build_config}
# 这个是pkgconfig查找路径
export PKG_CONFIG_LIBDIR=${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig # 替换默认搜索路径
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig"
export PKG_CONFIG_PATH_x86_64_w64_mingw32="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig"

rm -rf ${BUILD_DIR}
mkdir ${BUILD_DIR}
rm -rf ${PREFIX}
mkdir -p ${PREFIX}/include
mkdir -p ${PREFIX}/lib

# export HTTP_PROXY=http://192.168.15.103:10809
bash ${script_dir}/download_libusb.sh
bash ${script_dir}/convert_python.sh
bash ${script_dir}/build_glib.sh
bash ${script_dir}/build_glibmm.sh
bash ${script_dir}/build_libzip.sh
bash ${script_dir}/build_libserialport.sh
bash ${script_dir}/build_libsigrok.sh
bash ${script_dir}/build_libsigrokdecode.sh

# 复制依赖
cp ${TOOLCHAIN_PATH}/${TOOLCHAIN_PREFIX}/bin/libunwind.dll ${PREFIX}/bin/
cp ${TOOLCHAIN_PATH}/${TOOLCHAIN_PREFIX}/bin/libc++.dll ${PREFIX}/bin/