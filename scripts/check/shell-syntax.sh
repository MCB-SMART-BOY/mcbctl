#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="${1:-.}"
cd "${PROJECT_ROOT}"

check_file() {
  local file="$1"
  if [[ ! -f "${file}" ]]; then
    return 0
  fi

  if LC_ALL=C grep -q $'\r' "${file}"; then
    echo "CRLF line endings are not allowed: ${file}" >&2
    exit 1
  fi

  local first_line=""
  first_line="$(head -n 1 "${file}" || true)"
  if [[ "${first_line}" == '#!'* ]]; then
    case "${first_line}" in
      *"/bash"*|*"env bash"*|*"/sh"*|*"env sh"*) ;;
      *)
        echo "Unsupported shebang in ${file}: ${first_line}" >&2
        exit 1
        ;;
    esac
    if [[ ! -x "${file}" ]]; then
      echo "Script with shebang must be executable: ${file}" >&2
      exit 1
    fi
    bash -n "${file}"
  fi
}

shellcheck_file() {
  local file="$1"
  if [[ ! -f "${file}" ]]; then
    return 0
  fi
  shellcheck -x -s bash -e SC1090,SC1091,SC2034,SC2154,SC2329 "${file}"
}

fish_syntax_file() {
  local file="$1"
  if [[ -f "${file}" ]]; then
    fish --no-config -n "${file}"
  fi
}

zsh_syntax_file() {
  local file="$1"
  if [[ -f "${file}" ]]; then
    zsh -n "${file}"
  fi
}

nushell_syntax_file() {
  local file="$1"
  if [[ -f "${file}" ]]; then
    if [[ "$(basename "${file}")" == "env.nu" ]]; then
      nu --no-history --env-config "${file}" --config /dev/null -c exit
    else
      nu --no-history --env-config /dev/null --config "${file}" -c exit
    fi
  fi
}

toml_syntax_file() {
  local file="$1"
  if [[ -f "${file}" ]]; then
    check_file "${file}"
    taplo lint --no-auto-config --no-schema "${file}"
  fi
}

lua_syntax_file() {
  local file="$1"
  if [[ -f "${file}" ]]; then
    check_file "${file}"
    luac -p "${file}" >/dev/null
  fi
}

# 检查用户配置与脚本；单用户 Home Manager 内容位于 home/**。
while IFS= read -r -d "" file; do
  check_file "${file}"
  shellcheck_file "${file}"
done < <(find "${PROJECT_ROOT}/scripts" -type f -name "*.sh" -print0)

while IFS= read -r -d "" file; do
  fish_syntax_file "${file}"
done < <(find "${PROJECT_ROOT}/home" -type f \( -name "*.fish" -o -path "*/config/fish/functions/*" \) -print0)

while IFS= read -r -d "" file; do
  zsh_syntax_file "${file}"
done < <(find "${PROJECT_ROOT}/home" -type f \( -name "*.zsh" -o -name ".zshrc" \) -print0)

while IFS= read -r -d "" file; do
  nushell_syntax_file "${file}"
done < <(find "${PROJECT_ROOT}/home" -type f -name "*.nu" -print0)

while IFS= read -r -d "" file; do
  toml_syntax_file "${file}"
done < <(find "${PROJECT_ROOT}/home" -type f -name "*.toml" -print0)

while IFS= read -r -d "" file; do
  lua_syntax_file "${file}"
done < <(find "${PROJECT_ROOT}/home" -type f -name "*.lua" -print0)

# Niri KDL 配置验证
if command -v niri &>/dev/null; then
  while IFS= read -r -d "" file; do
    if ! niri validate --config "${file}" 2>&1; then
      echo "niri 配置无效: ${file}" >&2
      exit 1
    fi
  done < <(find "${PROJECT_ROOT}/home" -type f -name "config.kdl" -path "*/niri/*" -print0)
fi

if [[ -d "${PROJECT_ROOT}/scripts/run" ]]; then
  while IFS= read -r -d "" file; do
    shellcheck_file "${file}"
  done < <(find "${PROJECT_ROOT}/scripts/run" -type f -name "*.sh" -print0)
fi

while IFS= read -r -d "" file; do
  shellcheck_file "${file}"
done < <(find "${PROJECT_ROOT}/home" -type f -path "*/scripts/*" -print0)

if [[ -d "${PROJECT_ROOT}/pkgs" ]]; then
  while IFS= read -r -d "" file; do
    shellcheck_file "${file}"
  done < <(find "${PROJECT_ROOT}/pkgs" -type f -name "*.sh" -print0)
fi

