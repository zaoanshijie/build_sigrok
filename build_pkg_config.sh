#!/bin/bash -e
#脚本的运行目录
script_dir=$(
    cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd
)

lib_version="pkgconf-2.5.1"
lib_name=pkgconf

cd ${BUILD_DIR}
src_dir=${BUILD_DIR}/${lib_name}
build_dir=${BUILD_DIR}/${lib_name}_build

rm -rf ${src_dir}
git clone https://github.com/pkgconf/${lib_name}.git

cd ${src_dir}
git checkout ${lib_version}

rm -rf ${build_dir}
mkdir -p ${build_dir}

cd ${build_dir}
cat >${build_dir}/cross_file.txt <<EOF 
[host_machine]
system = 'windows'
cpu_family = '${TARGET}'
cpu = '${TARGET}'
endian = 'little'

[built-in options]
c_args = []
c_link_args = []

[binaries]
c = '${TOOLCHAIN_PREFIX}-gcc'
cpp = '${TOOLCHAIN_PREFIX}-g++'
ar = '${TOOLCHAIN_PREFIX}-ar'
ld = '${TOOLCHAIN_PREFIX}-ld'
objcopy = '${TOOLCHAIN_PREFIX}-objcopy'
strip = '${TOOLCHAIN_PREFIX}-strip'
pkg-config = 'pkg-config'
windres = '${TOOLCHAIN_PREFIX}-windres'
EOF

meson setup --prefix ${PREFIX} --buildtype release -Dtests=disabled --cross-file ${build_dir}/cross_file.txt  ${build_dir} ${src_dir}
meson compile -C ${build_dir}
meson install -C ${build_dir} 
