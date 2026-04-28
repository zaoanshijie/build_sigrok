#!/bin/bash -e
#脚本的运行目录
script_dir=$(
    cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd
)

lib_version="v1.0.29"
lib_name=libusb

cd ${BUILD_DIR}
src_dir=${BUILD_DIR}/${lib_name}
rm -rf ${src_dir}
mkdir -p ${src_dir}

cd ${src_dir}
install_file=$(curl -fsSL "https://api.github.com/repos/libusb/${lib_name}/releases/latest" |
            grep "browser_download_url" |
            cut -d '"' -f 4 |
            grep -E "libusb.*7z$")
file_name=$(echo ${install_file} | awk -F "/" '{print $NF}')

curl_proxy=
if [ ! -z  "${HTTP_PROXY}" ]; then
  curl_proxy="-x ${HTTP_PROXY}"
fi
curl ${curl_proxy} -OL "${install_file}"

7z x ${file_name} include/  MinGW64/

cp -r include/* ${PREFIX}/include
cp -r MinGW64/static/libusb-1.0.a ${PREFIX}/lib/
# 这里创建一个libusb的搜索
if [ ! -d  "${PREFIX}/lib/pkgconfig" ]; then
  mkdir -p ${PREFIX}/lib/pkgconfig
fi

cat >${PREFIX}/lib/pkgconfig/libusb-1.0.pc <<EOF 
prefix=${PREFIX}
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include
Name: libusb-1.0
Description: libusb-1.0 library
Version: 1.0.29
Libs: \${libdir}/libusb-1.0.a
Cflags: -I\${includedir}
EOF