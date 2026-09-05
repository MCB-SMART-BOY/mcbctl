# Bats 测试共享辅助函数。

REPO_ROOT="$(cd -- "${BATS_TEST_DIRNAME}/../.." && pwd -P)"
export REPO_ROOT
export TMPDIR="${TMPDIR:-${BATS_TEST_TMPDIR:-/tmp}}"

