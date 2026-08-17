#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ARG=""
APP_NAME="Cat Companion"
BUNDLE_ID="org.opensource.catcompanion"
OUTPUT_ARG=""
FORCE=0

usage() {
  cat >&2 <<'USAGE'
Usage: build_app.sh --project <directory> [options]

Options:
  --app-name <name>       App and ZIP display name (default: Cat Companion)
  --bundle-id <id>        Reverse-DNS bundle identifier
  --output <directory>    ZIP output directory (default: <project>/output)
  --force                 Replace an existing ZIP with the same name
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)
      PROJECT_ARG="${2:-}"
      shift 2
      ;;
    --app-name)
      APP_NAME="${2:-}"
      shift 2
      ;;
    --bundle-id)
      BUNDLE_ID="${2:-}"
      shift 2
      ;;
    --output)
      OUTPUT_ARG="${2:-}"
      shift 2
      ;;
    --force)
      FORCE=1
      shift
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

if [[ -z "${PROJECT_ARG}" || ! -d "${PROJECT_ARG}" ]]; then
  usage
  exit 2
fi

if [[ "${APP_NAME}" == *"/"* || "${APP_NAME}" == *":"* || -z "${APP_NAME}" ]]; then
  echo "App name must be non-empty and cannot contain / or :." >&2
  exit 1
fi

if ! printf '%s' "${BUNDLE_ID}" | grep -Eq '^[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$'; then
  echo "Invalid reverse-DNS bundle identifier: ${BUNDLE_ID}" >&2
  exit 1
fi

PROJECT_DIR="$(cd "${PROJECT_ARG}" && pwd)"
ASSET_DIR="${PROJECT_DIR}/Assets"
SOURCE_PATH="${PROJECT_DIR}/Sources/CatCompanion/main.swift"
INFO_PATH="${PROJECT_DIR}/Resources/Info.plist"

if [[ ! -f "${SOURCE_PATH}" || ! -f "${INFO_PATH}" ]]; then
  echo "Project template is incomplete: ${PROJECT_DIR}" >&2
  exit 1
fi

"${SCRIPT_DIR}/validate_assets.sh" "${ASSET_DIR}"

if [[ -z "${OUTPUT_ARG}" ]]; then
  OUTPUT_ARG="${PROJECT_DIR}/output"
fi
mkdir -p "${OUTPUT_ARG}"
OUTPUT_DIR="$(cd "${OUTPUT_ARG}" && pwd)"
ZIP_NAME="$(printf '%s' "${APP_NAME}" | tr ' ' '-')-macOS.zip"
ZIP_PATH="${OUTPUT_DIR}/${ZIP_NAME}"

if [[ -e "${ZIP_PATH}" && "${FORCE}" -ne 1 ]]; then
  echo "Output already exists; pass --force to replace it: ${ZIP_PATH}" >&2
  exit 1
fi

STAGE_ROOT="$(mktemp -d /tmp/cat-companion-build.XXXXXX)"
trap 'rm -rf "${STAGE_ROOT}"' EXIT

APP_PATH="${STAGE_ROOT}/${APP_NAME}.app"
CONTENTS_PATH="${APP_PATH}/Contents"
MACOS_PATH="${CONTENTS_PATH}/MacOS"
RESOURCES_PATH="${CONTENTS_PATH}/Resources"
MODULE_CACHE="${STAGE_ROOT}/module-cache"

mkdir -p "${MACOS_PATH}" "${RESOURCES_PATH}" "${MODULE_CACHE}"
cp "${INFO_PATH}" "${CONTENTS_PATH}/Info.plist"
plutil -replace CFBundleDisplayName -string "${APP_NAME}" "${CONTENTS_PATH}/Info.plist"
plutil -replace CFBundleIdentifier -string "${BUNDLE_ID}" "${CONTENTS_PATH}/Info.plist"

for name in sit.png sleep.png jump.png walk-1.png walk-2.png walk-3.png walk-4.png; do
  cp "${ASSET_DIR}/${name}" "${RESOURCES_PATH}/${name}"
done

SDK_PATH="$(xcrun --sdk macosx --show-sdk-path)"
ARCH="${ARCHS:-$(uname -m)}"
env CLANG_MODULE_CACHE_PATH="${MODULE_CACHE}" \
    SWIFT_MODULE_CACHE_PATH="${MODULE_CACHE}" \
    xcrun swiftc -O \
    -sdk "${SDK_PATH}" \
    -target "${ARCH}-apple-macosx13.0" \
    -framework AppKit \
    "${SOURCE_PATH}" \
    -o "${MACOS_PATH}/CatCompanion"

chmod +x "${MACOS_PATH}/CatCompanion"
plutil -lint "${CONTENTS_PATH}/Info.plist"
xattr -cr "${APP_PATH}" 2>/dev/null || true

SIGN_IDENTITY_VALUE="${SIGN_IDENTITY:--}"
if [[ "${SIGN_IDENTITY_VALUE}" == "-" ]]; then
  codesign --force --deep --sign - "${APP_PATH}"
else
  codesign --force --deep --options runtime --timestamp --sign "${SIGN_IDENTITY_VALUE}" "${APP_PATH}"
fi

codesign --verify --deep --strict --verbose=2 "${APP_PATH}"

if [[ -e "${ZIP_PATH}" ]]; then
  rm "${ZIP_PATH}"
fi
(
  cd "${STAGE_ROOT}"
  zip -qry "${ZIP_PATH}" "${APP_NAME}.app"
)
unzip -t "${ZIP_PATH}" >/dev/null

echo "Built and verified: ${ZIP_PATH}"
echo "This ZIP contains private sprites. Keep it local unless the owner explicitly approves sharing."
