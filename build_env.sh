#!/bin/bash -e
#脚本的运行目录
script_dir=$(
    cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd
)

mingw_path="${script_dir}/llvm-mingw" 
build_dir="${script_dir}/.build"
prefix="${script_dir}/out"
target="x86_64"
toolchain_triplet="${target}-w64-mingw32"

export TOOLCHAIN_PATH=${mingw_path}
export BUILD_DIR=${build_dir}
export PREFIX=${prefix}
export TOOLCHAIN_PREFIX=${toolchain_triplet}
export TARGET="${target}"
export PROJECT_DIR="${script_dir}"
export PATH=${PROJECT_DIR}/tools:${mingw_path}/bin:${PATH}
export PYTHON=python3.13  # 指定python版本

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

apt clean
apt update
# apt dist-upgrade -y
apt install git ninja-build curl p7zip-full graphviz libxml-parser-perl docbook-xsl doxygen xsltproc -y

python3 -m pip install meson
# python3 -m pip install PyGObject

# 设置 LLVM MinGW 版本和下载 URL
tool_version="20260421"
tool_file="llvm-mingw-${tool_version}-ucrt-ubuntu-22.04-x86_64.tar.xz"
tool_url="https://github.com/mstorsjo/llvm-mingw/releases/download/${tool_version}/${tool_file}"

# 创建安装目录
rm -rf "${mingw_path}"
mkdir -p "${mingw_path}"
cd "${mingw_path}"

# 下载 llvm-mingw
echo "Downloading LLVM MinGW..."
curl -L -o "${tool_file}" "${tool_url}"

# 解压文件
echo "Extracting LLVM MinGW..."
tar -xf "${tool_file}" -C "${mingw_path}" --strip-components=1

# 验证安装
echo "Verifying installation..."
ls -la "${mingw_path}/bin/"

fi