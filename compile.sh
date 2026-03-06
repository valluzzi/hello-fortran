#!/bin/bash
set -e

# CMake build script for fortran-lzw project

# Configuration
BUILD_DIR="build"
BUILD_TYPE="${1:-Release}"  # Default to Release, can pass Debug as argument
TARGET="hello-fortran"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Check CMake availability
if ! command -v cmake &> /dev/null; then
    print_warn "CMake not found. Installing via Homebrew..."
    brew install cmake
fi

print_info "Using CMake: $(cmake --version | head -n1)"
print_info "Build type: ${BUILD_TYPE}"

# Clean build option
if [ "$2" == "clean" ]; then
    print_step "Cleaning build directory"
    rm -rf "${BUILD_DIR}"
fi

# Configure
print_step "Configuring project with CMake"
cmake -B "${BUILD_DIR}" -DCMAKE_BUILD_TYPE="${BUILD_TYPE}"

# Build
print_step "Building project"
cmake --build "${BUILD_DIR}" --parallel $(sysctl -n hw.ncpu)

# Success message
if [ -f "${BUILD_DIR}/${TARGET}" ]; then
    SIZE=$(du -h "${BUILD_DIR}/${TARGET}" | cut -f1)
    print_info "Build successful!"
    print_info "Executable: ${BUILD_DIR}/${TARGET} (${SIZE})"
    echo ""
    echo "Run with: ./${BUILD_DIR}/${TARGET}"
    echo "*****************************************************"
    ./${BUILD_DIR}/${TARGET}
else
    print_warn "Build completed but executable not found"
    exit 1
fi
