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

BUILD_DIR=$(mktemp -d)
trap "rm -rf $BUILD_DIR" EXIT

ARCH=$(dpkg --print-architecture)

export MAINTAINER_EMAIL="test@example.com"
export VERSION="1.0.0"
debug "MAINTAINER_EMAIL=$MAINTAINER_EMAIL VERSION=$VERSION ARCH=$ARCH"

debug "Running build-deb"
MAINTAINER_EMAIL="$MAINTAINER_EMAIL" bash bin/build-deb "$VERSION" >/dev/null 2>&1

if [ ! -f "python3-chromadb_${VERSION}-1_${ARCH}.deb" ]; then
    echo "FAIL: .deb file not created"
    exit 1
fi

DEB_FILE="python3-chromadb_${VERSION}-1_${ARCH}.deb"

echo "PASS: .deb file created"

dpkg-deb --info "$DEB_FILE" > "$BUILD_DIR/info.txt"

if ! grep -q "Package: python3-chromadb" "$BUILD_DIR/info.txt"; then
    echo "FAIL: Missing Package field"
    exit 1
fi

if ! grep -q "Version: ${VERSION}-1" "$BUILD_DIR/info.txt"; then
    echo "FAIL: Missing or wrong Version field"
    exit 1
fi

if ! grep -q "Architecture: $ARCH" "$BUILD_DIR/info.txt"; then
    echo "FAIL: Missing Architecture field (expected: $ARCH)"
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

rm -f "$DEB_FILE"
echo "ALL TESTS PASSED"
