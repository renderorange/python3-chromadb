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

echo "Testing script syntax..."

debug "Running bash -n on bin/build-deb"
if ! bash -n bin/build-deb; then
    echo "FAIL: Script has syntax errors"
    exit 1
fi

echo "PASS: Script syntax valid"