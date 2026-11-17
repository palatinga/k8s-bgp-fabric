#!/usr/bin/env bash
# Stage 0: is this host ready to run the lab?
# Checks pinned tool versions, kernel limits kind needs, and IP overlaps.
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../versions.env
source "$ROOT/versions.env"
# shellcheck source=lib.sh
source "$ROOT/tests/lib.sh"

# version_of <command...>: run the command, print the first x.y.z it outputs.
# Keeps pre-release tags ("0.34.0-alpha") so they never match a stable pin,
# drops build metadata ("4.3.1+g1a2b3c" -> "4.3.1").
version_of() {
  "$@" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?' | head -n 1
}

# check_tool <name> <expected version> <version command...>
check_tool() {
  local name="$1" expected="$2"
  shift 2
  if ! command -v "$1" >/dev/null 2>&1; then
    fail "$name is installed (command '$1' not found)"
    return
  fi
  assert_eq "$name version" "$expected" "$(version_of "$@")"
}

echo "== Docker"
if docker info >/dev/null 2>&1; then
  pass "docker works without sudo"
else
  fail "docker works without sudo (is the daemon running? is $USER in the docker group?)"
fi

echo "== Pinned tool versions (versions.env)"
check_tool containerlab "$CONTAINERLAB_VERSION" containerlab version
check_tool kind         "$KIND_VERSION"         kind version
check_tool kubectl      "$KUBECTL_VERSION"      kubectl version --client
check_tool helm         "$HELM_VERSION"         helm version --short
check_tool cilium-cli   "$CILIUM_CLI_VERSION"   cilium version --client

echo "== Other tools"
for tool in jq make; do
  if command -v "$tool" >/dev/null 2>&1; then
    pass "$tool is installed"
  else
    fail "$tool is installed"
  fi
done

echo "== Kernel limits for kind (multi-node clusters need more inotify)"
assert_ge "fs.inotify.max_user_watches"   524288 "$(sysctl -n fs.inotify.max_user_watches)"
assert_ge "fs.inotify.max_user_instances" 512    "$(sysctl -n fs.inotify.max_user_instances)"

echo "== Host routes must not overlap the lab's 10.0.0.0/8 plan"
overlaps="$(ip -j route show | jq -r '.[] | select(.dst | startswith("10.")) | .dst' | paste -sd ' ')"
assert_eq "no host route inside 10.0.0.0/8" "" "$overlaps"

finish
