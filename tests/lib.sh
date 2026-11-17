# shellcheck shell=bash
# Test helpers. Source this file from a test script; do not execute it.
#
# Tests do not stop at the first failure: every check runs, failures are
# counted, and finish() sets the exit code. Seeing all failures at once
# shows the pattern (one node? one link?) that points to the cause.

FAILS=0
LAB="${LAB:-bgplab}"

pass() {
  echo "PASS: $1"
}

fail() {
  echo "FAIL: $1"
  FAILS=$((FAILS + 1))
}

# assert_eq <description> <expected> <actual>
assert_eq() {
  local desc="$1" expected="$2" actual="$3"
  if [[ "$actual" == "$expected" ]]; then
    pass "$desc"
  else
    fail "$desc (expected '$expected', got '$actual')"
  fi
}

# assert_ge <description> <minimum> <actual>
# Fails (instead of crashing) when actual is not a number, e.g. jq's "null".
assert_ge() {
  local desc="$1" min="$2" actual="$3"
  if [[ ! "$actual" =~ ^[0-9]+$ ]]; then
    fail "$desc (expected a number >= $min, got '$actual')"
  elif (( actual >= min )); then
    pass "$desc"
  else
    fail "$desc (expected >= $min, got $actual)"
  fi
}

# frr_json <node> <vtysh command>
# Runs "<command> json" in the lab router and prints the JSON.
# Example: frr_json leaf1 "show bgp ipv4 unicast summary" | jq ...
frr_json() {
  local node="$1" cmd="$2"
  docker exec "clab-${LAB}-${node}" vtysh -c "${cmd} json"
}

# finish: print a summary and exit 1 if any check failed.
finish() {
  if (( FAILS > 0 )); then
    echo "$FAILS check(s) failed"
    exit 1
  fi
  echo "All checks passed"
}
