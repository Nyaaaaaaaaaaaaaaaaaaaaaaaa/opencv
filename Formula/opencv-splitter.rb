# typed: false
# frozen_string_literal: true

class OpencvSplitter < Formula
  desc "OpenCV minimal build for splitter"
  homepage "https://opencv.org/"
  license "Apache-2.0"

  url "https://github.com/opencv/opencv.git",
      tag:      "4.12.0",
      revision: "49486f61fb25722cbcf586b7f4320921d46fb38e"
  head "https://github.com/opencv/opencv.git", branch: "master"

  depends_on "cmake" => :build
  depends_on "pkg-config" => [:build, :test]
  depends_on "ninja" => :build
  depends_on "ccache" => :build

  depends_on "jpeg-turbo"
  depends_on "libpng"
  depends_on "libtiff"
  uses_from_macos "zlib"

  def install
    args = std_cmake_args + %W[
      -G Ninja
      -DCMAKE_BUILD_TYPE=Release
      -DCMAKE_OSX_ARCHITECTURES=arm64
      -DOPENCV_GENERATE_PKGCONFIG=ON

      -DBUILD_LIST=core,imgproc,imgcodecs,videoio

      -DBUILD_opencv_highgui=OFF
      -DBUILD_opencv_viz=OFF
      -DBUILD_EXAMPLES=OFF
      -DBUILD_TESTS=OFF
      -DBUILD_PERF_TESTS=OFF
      -DBUILD_opencv_apps=OFF
      -DBUILD_JAVA=OFF
      -DBUILD_opencv_python3=OFF
      -DBUILD_opencv_js=OFF

      -DBUILD_JPEG=OFF
      -DBUILD_PNG=OFF
      -DBUILD_TIFF=OFF
      -DBUILD_ZLIB=OFF
      -DBUILD_OPENEXR=OFF

      -DWITH_QT=OFF
      -DWITH_OPENGL=OFF
      -DWITH_VTK=OFF
      -DWITH_OPENCL=OFF
      -DWITH_OPENMP=OFF
      -DWITH_IPP=OFF
      -DWITH_TBB=OFF
      -DWITH_EIGEN=OFF
      -DWITH_AVFOUNDATION=ON
      -DWITH_V4L=OFF
      -DWITH_FFMPEG=OFF

      -DENABLE_PRECOMPILED_HEADERS=ON

      -DOPENCV_DOWNLOAD_PATH=#{HOMEBREW_CACHE}/opencv

      -DCPU_DISPATCH=
    ]

    args += %W[
      -DCMAKE_C_COMPILER_LAUNCHER=ccache
      -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
    ]

    ENV.runtime_cpu_detection

    system "cmake", "-S", ".", "-B", "build", *args
    system "cmake", "--build", "build", "-j"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <opencv2/core.hpp>
      #include <opencv2/imgproc.hpp>
      #include <iostream>
      int main() {
        std::cout << CV_VERSION << std::endl;
        cv::Mat m = cv::Mat::zeros(10, 10, CV_8UC1);
        cv::Mat n; cv::Canny(m, n, 10, 30);
        return 0;
      }
    EOS
    cflags = `pkg-config --cflags opencv4`.split
    libs   = `pkg-config --libs opencv4`.split
    system ENV.cxx, "test.cpp", "-std=c++17", *cflags, *libs, "-o", "test"
    assert_match version.to_s, shell_output("./test")
  end
end

