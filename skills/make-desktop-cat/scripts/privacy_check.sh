#!/bin/bash
set -euo pipefail

TARGET="${1:-.}"
if [[ ! -d "${TARGET}" ]]; then
  echo "Usage: $0 <repository-or-project-directory>" >&2
  exit 2
fi

failed=0

if git -C "${TARGET}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  tracked_private_assets="$(
    git -C "${TARGET}" ls-files \
      | grep -E '(^|/)(Photos?|cat_refs|Assets)/.*\.(HEIC|heic|JPG|jpg|JPEG|jpeg|PNG|png|WEBP|webp|MOV|mov|MP4|mp4)$' \
      || true
  )"
  if [[ -n "${tracked_private_assets}" ]]; then
    echo "Potential private photos or sprites are tracked:" >&2
    printf '%s\n' "${tracked_private_assets}" >&2
    failed=1
  fi

  tracked_builds="$(git -C "${TARGET}" ls-files | grep -E '\.(app|zip)$' || true)"
  if [[ -n "${tracked_builds}" ]]; then
    echo "Built app or ZIP is tracked:" >&2
    printf '%s\n' "${tracked_builds}" >&2
    failed=1
  fi
fi

matches="$(
  find "${TARGET}" -type f \
    \( -name '*.md' -o -name '*.txt' -o -name '*.swift' -o -name '*.sh' -o -name '*.yml' -o -name '*.yaml' -o -name '*.plist' \) \
    -not -path '*/.git/*' \
    -not -path '*/scripts/privacy_check.sh' -print0 \
    | xargs -0 grep -nE '/Users/[A-Za-z0-9._-]+/|C:\\Users\\|gho_[A-Za-z0-9]+|github_pat_[A-Za-z0-9_]+|sk-[A-Za-z0-9]{16,}|BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|Developer ID Application:' \
    || true
)"

if [[ -n "${matches}" ]]; then
  echo "Potential personal path, credential, private key, or signing identity found:" >&2
  printf '%s\n' "${matches}" >&2
  failed=1
fi

if [[ "${failed}" -ne 0 ]]; then
  exit 1
fi

echo "Privacy check passed: no tracked pet assets, builds, personal paths, or credential patterns found."
