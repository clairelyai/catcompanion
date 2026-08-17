#!/bin/bash
set -euo pipefail

ASSET_DIR="${1:-}"
if [[ -z "${ASSET_DIR}" || ! -d "${ASSET_DIR}" ]]; then
  echo "Usage: $0 <Assets-directory>" >&2
  exit 2
fi

required=(
  sit.png
  sleep.png
  jump.png
  walk-1.png
  walk-2.png
  walk-3.png
  walk-4.png
)

expected_width=""
expected_height=""
mixed_canvas_sizes=0

for name in "${required[@]}"; do
  path="${ASSET_DIR}/${name}"
  if [[ ! -f "${path}" ]]; then
    echo "Missing required sprite: ${path}" >&2
    exit 1
  fi

  if ! file "${path}" | grep -q "PNG image data"; then
    echo "Not a valid PNG: ${path}" >&2
    exit 1
  fi

  metadata="$(sips -g pixelWidth -g pixelHeight -g hasAlpha "${path}" 2>/dev/null)"
  width="$(printf '%s\n' "${metadata}" | awk '/pixelWidth:/ {print $2}')"
  height="$(printf '%s\n' "${metadata}" | awk '/pixelHeight:/ {print $2}')"
  alpha="$(printf '%s\n' "${metadata}" | awk '/hasAlpha:/ {print $2}')"

  if [[ "${alpha}" != "yes" ]]; then
    echo "Sprite must contain an alpha channel: ${path}" >&2
    exit 1
  fi

  if [[ "${width}" -lt 512 || "${height}" -lt 512 ]]; then
    echo "Sprite is too small (${width}x${height}): ${path}" >&2
    exit 1
  fi

  if [[ -z "${expected_width}" ]]; then
    expected_width="${width}"
    expected_height="${height}"
  elif [[ "${width}" != "${expected_width}" || "${height}" != "${expected_height}" ]]; then
    mixed_canvas_sizes=1
  fi
done

unique_walk_frames="$(
  shasum -a 256 \
    "${ASSET_DIR}/walk-1.png" \
    "${ASSET_DIR}/walk-2.png" \
    "${ASSET_DIR}/walk-3.png" \
    "${ASSET_DIR}/walk-4.png" \
    | awk '{print $1}' | sort -u | wc -l | tr -d ' '
)"

if [[ "${unique_walk_frames}" != "4" ]]; then
  echo "All four walking files must be different images." >&2
  exit 1
fi

echo "Validated seven transparent sprites."
if [[ "${mixed_canvas_sizes}" -eq 1 ]]; then
  echo "Note: canvas sizes differ; the app will scale them, but visual alignment needs manual review."
fi
echo "Visual review is still required for identity consistency and anatomical four-leg motion."
