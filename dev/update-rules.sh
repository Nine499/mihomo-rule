#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG="$SCRIPT_DIR/config/sources.conf"

source "$SCRIPT_DIR/lib/download.sh"

main() {
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf -- "${tmp_dir:-}"' EXIT

  download_all "$CONFIG" "$tmp_dir"
  apply_targets "$CONFIG" "$tmp_dir"
}

main "$@"
