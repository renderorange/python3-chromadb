#!/bin/bash
set -e

DEBUG=0
while [ $# -gt 0 ]; do
    case "$1" in
        -d|--debug) DEBUG=1; shift ;;
        -h|--help) echo "Usage: $0 [--debug]"; exit 0 ;;
        *) shift ;;
    esac
done

debug() {
    if [ "$DEBUG" = "1" ]; then
        echo "[DEBUG] $*"
    fi
}

echo "Running build and package validation..."

debug "Checking for pip3"
if ! command -v pip3 >/dev/null 2>&1; then
    echo "SKIP: pip3 not available (required for build)"
    exit 0
fi

debug "Checking for protoc"
if ! command -v protoc >/dev/null 2>&1; then
    echo "SKIP: protoc not available (required for build)"
    exit 0
fi

debug "Creating temp build directory"
BUILD_DIR=$(mktemp -d)
debug "BUILD_DIR: $BUILD_DIR"
trap "rm -rf $BUILD_DIR" EXIT

ARCH=$(dpkg --print-architecture)

export MAINTAINER_EMAIL="test@example.com"
export VERSION="0.4.24"
debug "MAINTAINER_EMAIL=$MAINTAINER_EMAIL VERSION=$VERSION ARCH=$ARCH"

debug "Running build-deb"
bash bin/build-deb 0.4.24 >/dev/null 2>&1

if [ ! -f "python3-chromadb_0.4.24-1_${ARCH}.deb" ]; then
    echo "FAIL: .deb file not created"
    exit 1
fi

DEB_FILE="python3-chromadb_0.4.24-1_${ARCH}.deb"

echo "PASS: .deb file created"

dpkg-deb --info "$DEB_FILE" > "$BUILD_DIR/info.txt"

if ! grep -q "Package: python3-chromadb" "$BUILD_DIR/info.txt"; then
    echo "FAIL: Missing Package field"
    exit 1
fi

if ! grep -q "Version: 0.4.24-1" "$BUILD_DIR/info.txt"; then
    echo "FAIL: Missing or wrong Version field"
    exit 1
fi

if ! grep -q "Architecture: any" "$BUILD_DIR/info.txt"; then
    echo "FAIL: Missing Architecture field"
    exit 1
fi

if ! grep -q "Maintainer: test@example.com" "$BUILD_DIR/info.txt"; then
    echo "FAIL: Missing Maintainer field"
    exit 1
fi

if ! grep -q "Depends: python3, python3-pydantic, python3-hnswlib" "$BUILD_DIR/info.txt"; then
    echo "FAIL: Missing Depends field"
    exit 1
fi

echo "PASS: Package info fields valid"

dpkg-deb --info "$DEB_FILE" > "$BUILD_DIR/info.txt"

if ! grep -q "copyright" "$BUILD_DIR/info.txt"; then
    echo "FAIL: Missing copyright file in package"
    exit 1
fi

if ! grep -q "postinst" "$BUILD_DIR/info.txt"; then
    echo "FAIL: Missing postinst script in package"
    exit 1
fi

if ! grep -q "md5sums" "$BUILD_DIR/info.txt"; then
    echo "FAIL: Missing md5sums file in package"
    exit 1
fi

echo "PASS: Package metadata files present"
echo "ALL TESTS PASSED"