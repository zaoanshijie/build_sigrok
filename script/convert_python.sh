#!/bin/bash -e
#脚本的运行目录
script_dir=$(
    cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd
)

python_version="310"
python_point_version="3.10"

if [[ "${PYTHON}" == "python3.13" ]]; then
  python_version="313"
  python_point_version="3.13"
fi

if [[ "${PYTHON}" == "python3.12" ]]; then
  python_version="312"
  python_point_version="3.12"
fi
echo "使用${PYTHON}"

# 处理python环境
if [ ! -d  "${PREFIX}/include" ]; then
  mkdir -p ${PREFIX}/include
fi
if [ ! -d  "${PREFIX}/lib/pkgconfig" ]; then
  mkdir -p ${PREFIX}/lib/pkgconfig
fi
if [ ! -d  "${PREFIX}/bin" ]; then
  mkdir -p ${PREFIX}/bin
fi
python_dir="${PROJECT_DIR}/python/python${python_version}"
cp -r ${python_dir}/include/* ${PREFIX}/include
patch -p1 ${PREFIX}/include/pyconfig.h < ${PROJECT_DIR}/python/pyconfig.patch
# patch -p1 ${PROJECT_DIR}/python/python312/include/pyconfig.h < ${PROJECT_DIR}/python/pyconfig.patch


cat >${PREFIX}/lib/pkgconfig/python3.pc <<EOF 
prefix=${PREFIX}
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include
Name: Python
Description: Python library
Version: ${python_point_version}
Libs: \${libdir}/libpython${python_version}.a
Cflags: -I\${includedir}
EOF

cp ${python_dir}/bin/*.dll ${PREFIX}/bin
cd ${PREFIX}/bin
gendef python${python_version}.dll
llvm-dlltool -D python${python_version}.dll -d python${python_version}.def -l libpython${python_version}.a
mv -f libpython${python_version}.a ${PREFIX}/lib/
mv -f python${python_version}.def ${PREFIX}/lib/