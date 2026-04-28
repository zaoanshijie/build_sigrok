
#!/bin/bash -e
#脚本的运行目录
script_dir=$(
    cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd
)

lib_version="v1.11.4"
lib_name=libzip

cd ${BUILD_DIR}
src_dir=${BUILD_DIR}/${lib_name}
build_dir=${BUILD_DIR}/${lib_name}_build

rm -rf ${src_dir}
git clone https://github.com/nih-at/${lib_name}.git

cd ${src_dir}
git checkout ${lib_version}

rm -rf ${build_dir}
mkdir -p ${build_dir}

cd ${build_dir}
cat >${build_dir}/toolchain.cmake <<EOF 
set(TOOL_CHAIN_PATH "${TOOLCHAIN_PATH}")
set(TOOL_CHAIN_PREFIX "${TOOLCHAIN_PREFIX}")
set(CMAKE_C_COMPILER "\${TOOL_CHAIN_PATH}/bin/\${TOOL_CHAIN_PREFIX}-gcc")
set(CMAKE_CXX_COMPILER "\${TOOL_CHAIN_PATH}/bin/\${TOOL_CHAIN_PREFIX}-g++")
set(CMAKE_AR "\${TOOL_CHAIN_PATH}/bin/\${TOOL_CHAIN_PREFIX}-ar")
set(CMAKE_LINKER "\${TOOL_CHAIN_PATH}/bin/\${TOOL_CHAIN_PREFIX}-ld")
set(CMAKE_NM "\${TOOL_CHAIN_PATH}/bin/\${TOOL_CHAIN_PREFIX}-nm")
set(CMAKE_OBJDUMP "\${TOOL_CHAIN_PATH}/bin/\${TOOL_CHAIN_PREFIX}-objdump")
set(CMAKE_RANLIB "\${TOOL_CHAIN_PATH}/bin/\${TOOL_CHAIN_PREFIX}-ranlib")
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
SET(CMAKE_SYSTEM_PROCESSOR ${TARGET})
SET(CMAKE_SYSTEM_NAME Windows)
SET(CMAKE_FIND_ROOT_PATH \${CMAKE_FIND_ROOT_PATH} ${PREFIX})
EOF

cmake -S ${src_dir} -B ${build_dir} \
      -DCMAKE_TOOLCHAIN_FILE=${build_dir}/toolchain.cmake \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -G "Unix Makefiles"
cmake --build ${build_dir} --config Release -j
cmake --install ${build_dir} 
