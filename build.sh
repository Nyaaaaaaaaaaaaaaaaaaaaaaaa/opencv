#!/bin/bash
set -e

# 默认参数
OPENCV_VERSION="${OPENCV_VERSION:-4.9.0}"
INSTALL_DIR="${INSTALL_DIR:-/workspace/opencv_static_install}"
OPENCV_SOURCE_DIR="${OPENCV_SOURCE_DIR:-/workspace/opencv}"

echo "=========================================="
echo "Static OpenCV Build Script"
echo "=========================================="
echo "OpenCV Version: $OPENCV_VERSION"
echo "Install Directory: $INSTALL_DIR"
echo "Source Directory: $OPENCV_SOURCE_DIR"
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

cmake .. \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_TESTS=OFF \
    -DBUILD_PERF_TESTS=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_DOCS=OFF \
    -DBUILD_opencv_python2=OFF \
    -DBUILD_opencv_python3=OFF \
    -DBUILD_opencv_java=OFF \
    -DBUILD_opencv_js=OFF \
    -DWITH_QT=OFF \
    -DWITH_GTK=OFF \
    -DWITH_V4L=OFF \
    -DWITH_IPP=ON \
    -DWITH_ITT=OFF \
    -DBUILD_IPP_IW=ON \
    -DWITH_OPENEXR=ON \
    -DBUILD_OPENEXR=ON \
    -DOPENCV_GENERATE_PKGCONFIG=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
    -DENABLE_FAST_MATH=ON \
    -DCPU_BASELINE=SSE4_2 \
    -DCPU_DISPATCH=AVX,AVX2,AVX512_SKX \
    # -DCMAKE_CXX_FLAGS="-O3 -march=native -mtune=native -ffast-math" \
    # -DCMAKE_C_FLAGS="-O3 -march=native -mtune=native -ffast-math"

# 编译和安装
echo "Building OpenCV..."
cmake --build . -j $(nproc)

echo "Installing OpenCV to $INSTALL_DIR..."
cmake --install .

# 打包
echo "Packaging static libraries..."
cd $INSTALL_DIR
ZIP_FILE="opencv-static-${OPENCV_VERSION}-linux-x64.zip"
zip -r $ZIP_FILE *

echo "=========================================="
echo "Build completed successfully!"
echo "Package: $INSTALL_DIR/$ZIP_FILE"
echo "=========================================="
