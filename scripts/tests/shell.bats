#!/usr/bin/env bats

load helpers

setup() {
  BASH_BIN="$(type -P bash)"
  FISH_BIN="$(type -P fish)"
  TEST_CONFIG_HOME="${BATS_TEST_TMPDIR}/config"
  mkdir -p "${TEST_CONFIG_HOME}/fish"
  ln -s "${REPO_ROOT}/home/config/fish/config.fish" "${TEST_CONFIG_HOME}/fish/config.fish"
  ln -s "${REPO_ROOT}/home/config/fish/conf.d" "${TEST_CONFIG_HOME}/fish/conf.d"
  ln -s "${REPO_ROOT}/home/config/fish/functions" "${TEST_CONFIG_HOME}/fish/functions"
  mkdir -p "${BATS_TEST_TMPDIR}/home/.config/toolchain"
  ln -s "${REPO_ROOT}/home/config/toolchain/tools.json" \
    "${BATS_TEST_TMPDIR}/home/.config/toolchain/tools.json"
  mkdir -p "${BATS_TEST_TMPDIR}/home/.local/bin"
  printf '#!%s\nprintf "fake-mcb %%s\\n" "$*"\n' "${BASH_BIN}" \
    > "${BATS_TEST_TMPDIR}/home/.local/bin/mcb-toolchain"
  chmod +x "${BATS_TEST_TMPDIR}/home/.local/bin/mcb-toolchain"
  mkdir -p "${BATS_TEST_TMPDIR}/minimal-bin"
  ln -s "$(command -v env)" "${BATS_TEST_TMPDIR}/minimal-bin/env"
}

@test "fish_noninteractive_startup_has_no_prompt_output" {
  run env \
    HOME="${BATS_TEST_TMPDIR}/home" \
    XDG_CONFIG_HOME="${TEST_CONFIG_HOME}" \
    XDG_DATA_HOME="${BATS_TEST_TMPDIR}/data" \
    TERM=dumb \
    fish -c 'printf marker'

  [ "${status}" -eq 0 ]
  [ "${output}" = "marker" ]
}

@test "fish_bang_bang_bindings_load_in_interactive_shell" {
  run env \
    HOME="${BATS_TEST_TMPDIR}/home" \
    XDG_CONFIG_HOME="${TEST_CONFIG_HOME}" \
    XDG_DATA_HOME="${BATS_TEST_TMPDIR}/data" \
    TERM=dumb \
    fish -i -c 'bind --user | string match -q "bind ! __history_previous_command"'

  [ "${status}" -eq 0 ]
}

@test "fish_history_wrapper_preserves_builtin_subcommands" {
  run fish --no-config -c \
    'source home/config/fish/functions/history.fish; history --help >/dev/null'

  [ "${status}" -eq 0 ]
}

@test "nushell_config_registers_portable_helpers" {
  run env HOME="${BATS_TEST_TMPDIR}/home" nu --no-history \
    --env-config home/config/nushell/env.nu \
    --config home/config/nushell/config.nu \
    -c 'let native = (which ls | get type); let helper = (which bootstrap-toolchain | get type); print $"($native)/($helper)"'

  [ "${status}" -eq 0 ]
  [[ "${output}" == *"[built-in]/[custom]"* ]]
}

@test "mcb_toolchain_dry_run_emits_command_plan_without_network" {
  run env HOME="${BATS_TEST_TMPDIR}/home" \
    bash "${REPO_ROOT}/home/scripts/mcb-toolchain" bootstrap --dry-run

  [ "${status}" -eq 0 ]
  [[ "${output}" == *"RUN "* ]]
  [[ "${output}" != *"curl"* ]]
  [[ "${output}" != *"wget"* ]]
}

@test "tools_inventory_uses_packages_without_versions" {
  run jq -e '
    .rust.channel == "stable"
    and .lean.channel == "stable"
    and ([.opam[], .cargo[], .go[], .uv[], .bun[]]
      | all((keys | sort) == ["binary", "package"]))
  ' "${REPO_ROOT}/home/config/toolchain/tools.json"

  [ "${status}" -eq 0 ]
}

@test "fish_upgrade_toolchain_wraps_mcb_toolchain" {
  run env \
    HOME="${BATS_TEST_TMPDIR}/home" \
    XDG_CONFIG_HOME="${TEST_CONFIG_HOME}" \
    XDG_DATA_HOME="${BATS_TEST_TMPDIR}/data" \
    TERM=dumb \
    fish -i -c 'upgrade-toolchain --dry-run'

  [ "${status}" -eq 0 ]
  [[ "${output}" == *"fake-mcb upgrade --dry-run"* ]]
}

@test "fish_missing_fzf_does_not_break_noninteractive_startup" {
  run env \
    HOME="${BATS_TEST_TMPDIR}/home" \
    XDG_CONFIG_HOME="${TEST_CONFIG_HOME}" \
    XDG_DATA_HOME="${BATS_TEST_TMPDIR}/data" \
    PATH="${BATS_TEST_TMPDIR}/minimal-bin" \
    TERM=dumb \
    "${FISH_BIN}" -c 'printf marker'

  [ "${status}" -eq 0 ]
  [ "${output}" = "marker" ]
}

@test "mcb_toolchain_upgrade_dry_run_uses_rolling_managers" {
  run env HOME="${BATS_TEST_TMPDIR}/home" \
    bash "${REPO_ROOT}/home/scripts/mcb-toolchain" upgrade --dry-run

  [ "${status}" -eq 0 ]
  [[ "${output}" == *"RUN rustup update stable"* ]]
  [[ "${output}" == *"RUN uv tool upgrade --all"* ]]
  [[ "${output}" == *"RUN bun update --global"* ]]
  [[ "${output}" == *"RUN opam upgrade --switch=default -y"* ]]
  [[ "${output}" == *"RUN rustup run stable cargo install --force cargo-audit"* ]]
}

@test "mcb_toolchain_check_dry_run_lists_inventory" {
  run env HOME="${BATS_TEST_TMPDIR}/home" \
    bash "${REPO_ROOT}/home/scripts/mcb-toolchain" check --dry-run

  [ "${status}" -eq 0 ]
  [[ "${output}" == *"CHECK manager rustup"* ]]
  [[ "${output}" == *"CHECK gopls (go)"* ]]
  [[ "${output}" == *"CHECK ruff (uv)"* ]]
}

@test "mcb_toolchain_invalid_manifest_returns_usage_error" {
  bad_home="${BATS_TEST_TMPDIR}/bad-home"
  mkdir -p "${bad_home}/.config/toolchain"
  printf '%s\n' \
    '{"rust":{"channel":"stable","components":["rust-analyzer"]},"lean":{"channel":"stable"},"opam":[],"cargo":[],"go":[],"uv":[],"bun":[{"package":"https://evil.invalid/payload","binary":"evil"}]}' \
    > "${bad_home}/.config/toolchain/tools.json"

  run env HOME="${bad_home}" \
    bash "${REPO_ROOT}/home/scripts/mcb-toolchain" bootstrap --dry-run

  [ "${status}" -eq 2 ]
  [[ "${output}" == *"invalid manifest"* ]]
}

@test "nushell_toolchain_wrapper_forwards_rolling_operation" {
  run env HOME="${BATS_TEST_TMPDIR}/home" \
    nu --no-history \
    --env-config home/config/nushell/env.nu \
    --config home/config/nushell/config.nu \
    -c 'bootstrap-toolchain --dry-run'

  [ "${status}" -eq 0 ]
  [[ "${output}" == *"fake-mcb bootstrap --dry-run"* ]]
}
