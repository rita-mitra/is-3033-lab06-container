#!/usr/bin/env bash
# IS 3033 Lab 06: the gate.
#
# Runs the same checks a CI pipeline would run, on your own server, and refuses
# to pass until the container is built safely. Exit status 0 means green,
# anything else means red.
#
#   ./check.sh          full run: lint, misconfiguration scan, build, smoke test,
#                       vulnerability count (report only)
#   ./check.sh --fast   lint and misconfiguration scan only (seconds); this is
#                       what the git pre-commit hook runs
#
# Gates (all must pass):
#   1. hadolint: Dockerfile best practices
#   2. Trivy misconfiguration scan of the Dockerfile (root user, latest tag, secrets in ENV, ...)
#   3. Build the image
#   4. Smoke test: start the container, request the page, stop it
# Report only (never fails):
#   5. Trivy vulnerability count for the built image (CRITICAL and HIGH, fixed ones only)

set -u
cd "$(dirname "$0")"

FAST=0
[ "${1:-}" = "--fast" ] && FAST=1

IMAGE="lab06:check"
CONTAINER="lab06-check"
PORT=18080
FAILED=()

line() { printf '\n==== %s ====\n' "$1"; }
result() {  # name, status
  if [ "$2" -eq 0 ]; then printf '  -> %s: PASS\n' "$1"; else printf '  -> %s: FAIL\n' "$1"; FAILED+=("$1"); fi
}

for tool in hadolint trivy docker; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "check.sh: '$tool' is not installed. See Step 1 of the lab." >&2
    exit 2
  fi
done

line "1. hadolint (Dockerfile lint)"
hadolint --failure-threshold warning Dockerfile
result "hadolint" $?

line "2. Trivy misconfiguration scan (Dockerfile)"
trivy config --quiet --severity CRITICAL,HIGH,MEDIUM --exit-code 1 .
result "misconfiguration scan" $?

if [ "$FAST" -eq 1 ]; then
  line "Result (fast mode: gates 1 and 2 only)"
else
  line "3. Build the image"
  docker build -q -t "$IMAGE" . >/dev/null
  BUILD=$?
  result "build" $BUILD

  if [ "$BUILD" -eq 0 ]; then
    line "4. Smoke test (start, request the page, stop)"
    docker rm -f "$CONTAINER" >/dev/null 2>&1
    docker run -d --rm --name "$CONTAINER" -p "$PORT:8080" "$IMAGE" >/dev/null
    sleep 3
    PAGE=$(curl --silent --fail "http://127.0.0.1:$PORT/" 2>/dev/null)
    SMOKE=$?
    docker stop "$CONTAINER" >/dev/null 2>&1
    if [ "$SMOKE" -eq 0 ] && printf '%s' "$PAGE" | grep -q "IS 3033 Lab 06 status service"; then
      printf '%s\n' "$PAGE" | sed 's/^/  /'
      result "smoke test" 0
    else
      echo "  The container did not answer on port $PORT."
      result "smoke test" 1
    fi

    line "5. Vulnerability count (report only, never fails)"
    COUNTS=$(trivy image --quiet --timeout 20m --format json --severity CRITICAL,HIGH --ignore-unfixed --scanners vuln "$IMAGE" 2>/dev/null | python3 -c '
import json, sys
found = [v["Severity"] for r in json.load(sys.stdin).get("Results") or [] for v in r.get("Vulnerabilities") or []]
print("CRITICAL: %d   HIGH: %d" % (found.count("CRITICAL"), found.count("HIGH")))
' 2>/dev/null)
    if [ -n "$COUNTS" ]; then
      echo "  $COUNTS"
    else
      echo "  The vulnerability scan did not finish. To see the error, run:"
      echo "    trivy image --timeout 20m --severity CRITICAL,HIGH --ignore-unfixed --scanners vuln $IMAGE"
    fi
    echo "  Image size: $(docker images "$IMAGE" --format '{{.Size}}')"
  fi
  line "Result"
fi

if [ "${#FAILED[@]}" -eq 0 ]; then
  echo "  GREEN: all gates passed."
  exit 0
else
  echo "  RED: ${#FAILED[@]} gate(s) failed: ${FAILED[*]}"
  echo "  Read the output above, fix the Dockerfile, and run ./check.sh again."
  exit 1
fi
