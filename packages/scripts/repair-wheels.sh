#!/bin/bash
# Conditionally repair wheels using auditwheel.
# Platform wheels get repaired (shared libs bundled); pure-Python wheels are copied as-is.
#
# Usage: repair-wheels.sh <input_dir> <output_dir>
#   input_dir:  directory containing .whl files to process
#   output_dir: directory to write repaired/copied wheels

set -euo pipefail

INPUT_DIR="${1:?Usage: repair-wheels.sh <input_dir> <output_dir>}"
OUTPUT_DIR="${2:?Usage: repair-wheels.sh <input_dir> <output_dir>}"

mkdir -p "$OUTPUT_DIR"

for whl in "$INPUT_DIR"/*.whl; do
    echo "Checking wheel $whl"
    if ! auditwheel show "$whl" 2>&1 | grep -q "platform wheel"; then
        echo "Repairing wheel $whl"
        auditwheel repair "$whl" -w "$OUTPUT_DIR"
        auditwheel show "$OUTPUT_DIR"/*.whl
    else
        echo "Copying wheel without repair since not a platform wheel: $whl"
        cp "$whl" "$OUTPUT_DIR"/
    fi
done

echo "Wheels in $OUTPUT_DIR:"
ls -l "$OUTPUT_DIR"
