#!/bin/bash -e
#脚本的运行目录
script_dir=$(
    cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd
)

PATH=${script_dir}/miniconda3/bin:${PATH}

# 下载miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ${script_dir}/miniconda.sh
bash ${script_dir}/miniconda.sh -b -u -p ${script_dir}/miniconda3
source ${script_dir}/miniconda3/bin/activate
conda init --all

conda create -n myenv python=${python_version}
conda activate myenv

python3 -m pip install meson
# python3 -m pip install PyGObject