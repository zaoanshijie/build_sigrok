#!/bin/bash -e
#脚本的运行目录
script_dir=$(
    cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd
)

build_script=""
if [ -n "$1" ]; then
  build_script="$1"
else
  echo "错误：输入脚本不存在"
  exit 1
fi

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
build_config="--host=${TOOLCHAIN_PREFIX} --prefix=${PREFIX} --enable-shared --disable-static CPPFLAGS=-D__printf__=__gnu_printf__ CC=${TOOLCHAIN_PREFIX}-gcc CXX=${TOOLCHAIN_PREFIX}-g++  AR=${TOOLCHAIN_PREFIX}-ar  WINDRES=${TOOLCHAIN_PREFIX}-windres"
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
mkdir -p ${PREFIX}/bin

bash "${script_dir}/${build_script}"