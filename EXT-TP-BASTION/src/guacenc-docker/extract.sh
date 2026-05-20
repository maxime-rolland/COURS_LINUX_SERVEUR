#!/bin/bash
# Convert a Guacamole protocol recording to .m4v and dump PNG frames
# at a regular interval. Auto-detects display size from the recording.
#
# Usage: extract <recording-path> [interval-seconds]
#   recording-path  : path to the Guacamole recording (relative to /work)
#   interval-seconds: seconds between extracted frames (default: 2)
#
# Outputs (next to the input):
#   <recording>.m4v          — encoded video
#   <recording>.frames/      — PNG frames at the requested cadence

set -euo pipefail

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ] || [ $# -eq 0 ]; then
    sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
fi

RECORDING="$1"
INTERVAL="${2:-2}"

if [ ! -f "$RECORDING" ]; then
    echo "extract: recording not found: $RECORDING" >&2
    exit 1
fi

# The whole recording is on one line: split on ';' and find the first
# 'size' instruction targeting layer 0 (the display).
# Instruction format: LEN.size,1.0,LEN.WIDTH,LEN.HEIGHT
SIZE_LINE=$(head -c 65536 "$RECORDING" | tr ';' '\n' \
            | grep -m1 -E '^[0-9]+\.size,1\.0,' || true)

SIZE_ARG=()
if [ -n "$SIZE_LINE" ]; then
    W=$(printf '%s' "$SIZE_LINE" | awk -F',' '{print $3}' | sed 's/^[0-9]*\.//')
    H=$(printf '%s' "$SIZE_LINE" | awk -F',' '{print $4}' | sed 's/^[0-9]*\.//')
    if [[ "$W" =~ ^[0-9]+$ && "$H" =~ ^[0-9]+$ ]]; then
        SIZE_ARG=(-s "${W}x${H}")
        echo "[extract] detected display size: ${W}x${H}"
    fi
fi
if [ ${#SIZE_ARG[@]} -eq 0 ]; then
    echo "[extract] display size not detected, using guacenc default"
fi

OUT_VIDEO="${RECORDING}.m4v"
OUT_FRAMES_DIR="${RECORDING}.frames"

echo "[extract] encoding video with guacenc..."
guacenc -f "${SIZE_ARG[@]}" "$RECORDING"

if [ ! -f "$OUT_VIDEO" ]; then
    echo "extract: guacenc did not produce $OUT_VIDEO" >&2
    exit 1
fi

rm -rf "$OUT_FRAMES_DIR"
mkdir -p "$OUT_FRAMES_DIR"
echo "[extract] dumping frames every ${INTERVAL}s into ${OUT_FRAMES_DIR}/"
ffmpeg -y -loglevel error -i "$OUT_VIDEO" \
    -vf "fps=1/${INTERVAL}" \
    "${OUT_FRAMES_DIR}/frame_%04d.png"

COUNT=$(find "$OUT_FRAMES_DIR" -maxdepth 1 -name 'frame_*.png' | wc -l)
echo "[extract] done."
echo "  video : ${OUT_VIDEO}"
echo "  frames: ${OUT_FRAMES_DIR}/ (${COUNT} frames)"
