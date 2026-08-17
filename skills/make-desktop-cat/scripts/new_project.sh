#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TEMPLATE_DIR="${SKILL_DIR}/assets/macos-template"
OUTPUT_DIR=""

usage() {
  echo "Usage: $0 --output <project-directory>" >&2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output)
      OUTPUT_DIR="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 2
      ;;
  esac
done

if [[ -z "${OUTPUT_DIR}" ]]; then
  usage
  exit 2
fi

if [[ -e "${OUTPUT_DIR}" ]]; then
  echo "Refusing to overwrite existing path: ${OUTPUT_DIR}" >&2
  exit 1
fi

mkdir -p "$(dirname "${OUTPUT_DIR}")" "${OUTPUT_DIR}"
cp -R "${TEMPLATE_DIR}/." "${OUTPUT_DIR}/"
mkdir -p "${OUTPUT_DIR}/Assets" "${OUTPUT_DIR}/output"

echo "Created private Cat Companion project: ${OUTPUT_DIR}"
echo "Add seven transparent PNG sprites to: ${OUTPUT_DIR}/Assets"
