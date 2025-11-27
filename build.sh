#!/bin/bash
set -e

# 默认参数
OPENCV_VERSION="${OPENCV_VERSION:-4.9.0}"
INSTALL_DIR="${INSTALL_DIR:-/workspace/opencv_static_install}"
OPENCV_SOURCE_DIR="${OPENCV_SOURCE_DIR:-/workspace/opencv}"

# 检测平台和架构
OS_TYPE=$(uname -s)
ARCH_TYPE=$(uname -m)

# 设置平台特定的参数
if [ "$OS_TYPE" = "Darwin" ]; then
    if [ "$ARCH_TYPE" = "arm64" ]; then
        PLATFORM="macos-arm64"
        CPU_BASELINE="NEON"
        CPU_DISPATCH=""
        PARALLEL_JOBS=$(sysctl -n hw.ncpu)
    else
        PLATFORM="macos-x64"
        CPU_BASELINE="SSE4_2"
        CPU_DISPATCH="AVX,AVX2"
        PARALLEL_JOBS=$(sysctl -n hw.ncpu)
    fi
elif [ "$OS_TYPE" = "Linux" ]; then
    PLATFORM="linux-x64"
    CPU_BASELINE="SSE4_2"
    CPU_DISPATCH="AVX,AVX2,AVX512_SKX"
    PARALLEL_JOBS=$(nproc)
else
    echo "Unsupported OS: $OS_TYPE"
    exit 1
fi

echo "=========================================="
echo "Static OpenCV Build Script"
echo "=========================================="
echo "OpenCV Version: $OPENCV_VERSION"
echo "Platform: $PLATFORM"
echo "Architecture: $ARCH_TYPE"
echo "Install Directory: $INSTALL_DIR"
echo "Source Directory: $OPENCV_SOURCE_DIR"
echo "CPU Baseline: $CPU_BASELINE"
echo "CPU Dispatch: $CPU_DISPATCH"
echo "=========================================="

# 克隆 OpenCV 源代码（如果尚未存在）
if [ ! -d "$OPENCV_SOURCE_DIR" ]; then
    echo "Cloning OpenCV source code..."
    git clone --depth 1 --branch $OPENCV_VERSION https://github.com/opencv/opencv.git $OPENCV_SOURCE_DIR
else
    echo "OpenCV source directory already exists, skipping clone"
fi

cd $OPENCV_SOURCE_DIR

# 配置 CMake
echo "Configuring CMake for static build..."
mkdir -p build
cd build

# 构建 CMake 配置参数
CMAKE_ARGS=(
    -DBUILD_SHARED_LIBS=OFF
    -DBUILD_TESTS=OFF
    -DBUILD_PERF_TESTS=OFF
    -DBUILD_EXAMPLES=OFF
    -DBUILD_DOCS=OFF
    -DBUILD_opencv_python2=OFF
    -DBUILD_opencv_python3=OFF
    -DBUILD_opencv_java=OFF
    -DBUILD_opencv_js=OFF
    -DWITH_QT=OFF
    -DWITH_GTK=OFF
    -DWITH_V4L=OFF
    -DWITH_IPP=ON
    -DWITH_ITT=OFF
    -DBUILD_IPP_IW=ON
    -DWITH_OPENEXR=ON
    -DBUILD_OPENEXR=ON
    -DWITH_JPEG=ON
    -DBUILD_JPEG=ON
    -DWITH_PNG=ON
    -DBUILD_PNG=ON
    -DWITH_TIFF=ON
    -DBUILD_TIFF=ON
    -DWITH_WEBP=ON
    -DBUILD_WEBP=ON
    -DWITH_OPENJPEG=ON
    -DBUILD_OPENJPEG=ON
    -DWITH_PROTOBUF=ON
    -DBUILD_PROTOBUF=ON
    -DBUILD_ZLIB=ON
    -DBUILD_opencv_world=OFF
    -DOPENCV_FORCE_3RDPARTY_BUILD=ON
    -DOPENCV_GENERATE_PKGCONFIG=ON
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR
    -DENABLE_FAST_MATH=ON
    -DCPU_BASELINE=$CPU_BASELINE
)

# 添加 CPU_DISPATCH 如果非空
if [ -n "$CPU_DISPATCH" ]; then
    CMAKE_ARGS+=(-DCPU_DISPATCH=$CPU_DISPATCH)
fi

cmake .. "${CMAKE_ARGS[@]}"

# 编译和安装
echo "Building OpenCV..."
cmake --build . -j $PARALLEL_JOBS

echo "Installing OpenCV to $INSTALL_DIR..."
cmake --install .

# 打包
echo "Packaging static libraries..."
cd $INSTALL_DIR
ZIP_FILE="opencv-static-${OPENCV_VERSION}-${PLATFORM}.zip"
zip -r $ZIP_FILE *

echo "=========================================="
echo "Build completed successfully!"
echo "Package: $INSTALL_DIR/$ZIP_FILE"
echo "=========================================="
