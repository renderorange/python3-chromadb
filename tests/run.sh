#!/bin/bash
set -e

echo "=== Running test suite ==="

for test in tests/0*.sh; do
    echo ""
    echo "--- $test ---"
    bash "$test" "$@"
done

echo ""
echo "=== All tests passed ==="