#!/usr/bin/env bash
set -euo pipefail

readonly YQ_URL='https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64'

main() {
  local yq_path="${1:?用法: $0 <yq-path>}"

  curl -fsSL "$YQ_URL" -o "$yq_path"
  chmod +x "$yq_path"
}

main "$@"
