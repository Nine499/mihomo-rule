#!/usr/bin/env bash
# 下载模块：按配置文件中的规则，下载并拼接源文件到临时目录

# 下载单个 URL 到指定路径
fetch_url() {
  local url="$1" dest="$2"
  curl -fsSL -o "$dest" "$url"
}

# 处理配置文件的一行（"目标文件|源1,源2,..."）：
# 依次下载每个源，按顺序拼接写入临时目录下的同名文件
build_target() {
  local line="$1" tmp_dir="$2"
  local target="${line%%|*}"
  local sources="${line#*|}"

  : > "$tmp_dir/$target"
  local url part_file
  local -a urls
  IFS=',' read -ra urls <<< "$sources"
  for url in "${urls[@]}"; do
    part_file="$(mktemp -p "$tmp_dir")"
    fetch_url "$url" "$part_file"
    cat "$part_file" >> "$tmp_dir/$target"
  done
}

# 逐行读取配置文件，并发下载构建各目标文件；任一下载失败则整体失败
download_all() {
  local config_file="$1" tmp_dir="$2"
  local -a pids=()

  local line
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    build_target "$line" "$tmp_dir" &
    pids+=("$!")
  done < "$config_file"

  local pid
  for pid in "${pids[@]}"; do
    wait "$pid"
  done
}

# 将临时目录中已下载完成的目标文件原子移动到仓库根目录
apply_targets() {
  local config_file="$1" tmp_dir="$2"
  local line target
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    target="${line%%|*}"
    mv "$tmp_dir/$target" "$target"
  done < "$config_file"
}
