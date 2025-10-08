# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This repository contains a GitHub Actions workflow for building static OpenCV libraries. It does not contain source code itself, but rather automation to build OpenCV from the official opencv/opencv repository.

## Build Process

The repository uses GitHub Actions workflow dispatch to trigger builds:

**Trigger a build:**
```bash
# Via GitHub UI: Actions → Manual Static OpenCV Build & Release → Run workflow
# Specify the OpenCV version (e.g., 4.9.0)
```

The workflow (`.github/workflows/static_opencv_build.yml`) performs the following:
1. Checks out the specified OpenCV version from opencv/opencv
2. Configures CMake for static-only builds with minimal dependencies
3. Builds OpenCV with `-DBUILD_SHARED_LIBS=OFF`
4. Creates a release package named `opencv-static-{VERSION}-linux-x64.zip`
5. Publishes as a GitHub Release with tag `opencv-static-{VERSION}`

**Local development build:**
```bash
# Using Docker (recommended):
docker build -t opencv-builder .
docker run -v $(pwd)/output:/workspace/opencv_static_install opencv-builder /workspace/build.sh

# Direct execution:
OPENCV_VERSION=4.9.0 INSTALL_DIR=./output OPENCV_SOURCE_DIR=./opencv ./build.sh
```

## Key Configuration

The CMake configuration (in `build.sh`) disables:
- Shared libraries (static only)
- Tests, performance tests, examples, documentation
- Python, Java, JavaScript bindings
- Qt, GTK, V4L support

Enabled optimizations:
- IPP (Intel Performance Primitives)
- OpenEXR support
- CPU baseline: SSE4.2
- CPU dispatch: AVX, AVX2, AVX512_SKX

This produces minimal static libraries suitable for embedding in C++ projects.

## Important Details

- The workflow requires `contents: write` permission to create releases (fixed in commit cee6fb7)
- Build artifacts are installed to `$GITHUB_WORKSPACE/opencv_static_install`
- Builds run on `ubuntu-latest` with dependencies: cmake, build-essential, libssl-dev, libtbb-dev, libopenexr-dev
- The repository itself is minimal - the workflow fetches OpenCV source dynamically
- `.gitignore` excludes the `output/` directory where local builds are stored
