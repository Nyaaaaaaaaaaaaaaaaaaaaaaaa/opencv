FROM ubuntu:22.04

# 设置非交互式安装
ENV DEBIAN_FRONTEND=noninteractive

# 安装构建依赖
RUN apt-get update && apt-get install -y \
    cmake \
    build-essential \
    libssl-dev \
    libtbb-dev \
    libopenexr-dev \
    git \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /workspace

# 复制构建脚本
COPY build.sh /workspace/build.sh
RUN chmod +x /workspace/build.sh

# 设置默认环境变量
ENV OPENCV_VERSION=4.9.0
ENV INSTALL_DIR=/workspace/opencv_static_install
ENV OPENCV_SOURCE_DIR=/workspace/opencv

# 默认命令
CMD ["/bin/bash"]
