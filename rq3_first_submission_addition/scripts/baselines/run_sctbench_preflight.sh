#!/usr/bin/env bash
set -u

SCT_ROOT="${SCT_ROOT:-/home/sct/sctbench}"
STAGING_ROOT="${STAGING_ROOT:-/home/sct/rq3-staging/rq3-preparation/rq3-period-matched}"

check() {
  local label="$1"
  local target="$2"
  if [ -e "$target" ]; then
    printf 'PASS %-24s %s\n' "$label" "$target"
  else
    printf 'FAIL %-24s %s\n' "$label" "$target"
  fi
}

echo '=== SCTBench baseline preflight ==='
printf 'kernel=%s\n' "$(uname -r)"
printf 'os=%s\n' "$(awk -F= '/^PRETTY_NAME=/{gsub(/\"/,"",$2); print $2}' /etc/os-release 2>/dev/null)"
printf 'python=%s\n' "$(python --version 2>&1 || true)"
printf 'python3=%s\n' "$(python3 --version 2>&1 || true)"

check sctbench_root "$SCT_ROOT"
check run_many "$SCT_ROOT/scripts/run_many.py"
check maple_runner "$SCT_ROOT/maple/script/maple/runner.py"
check pin_binary "$SCT_ROOT/pin/pin"
check staging_root "$STAGING_ROOT"

if [ -d "$STAGING_ROOT" ]; then
  count=$(find "$STAGING_ROOT" -mindepth 2 -maxdepth 2 -type d -name run 2>/dev/null | wc -l)
  printf 'staged_subjects=%s\n' "$count"
fi

case "$(uname -r)" in
  0.*|1.*|2.*|3.*) echo 'kernel_compatibility=PASS_PIN_LEGACY' ;;
  *) echo 'kernel_compatibility=FAIL_PIN_REQUIRES_KERNEL_3_X_OR_OLDER' ;;
esac

echo '=== container inventory must be collected on the host with: docker ps -a ==='
