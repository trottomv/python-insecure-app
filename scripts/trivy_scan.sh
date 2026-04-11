#!/usr/bin/env sh

set -eu

IMAGE="${1:?Missing IMAGE}"
TAG="${2:?Missing TAG}"

GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RESET="\033[0m"

section() {
  echo
  echo "========================================"
  echo "$1"
  echo "========================================"
}

run() {
  local description="$1"
  local cmd="$2"

  echo
  echo -e "${GREEN}${description}${RESET}"
  echo -e "${YELLOW}${cmd}${RESET}"
  echo "========================================"

  eval "$cmd"
}

section "Run Trivy vulnerability assessment"

run "Clean scan cache" \
"trivy clean --scan-cache"

run "Generate SBOM (CycloneDX format)" \
"trivy image \
--skip-db-update \
--exit-code 0 \
--format cyclonedx \
--output /tmp/.trivy/sbom-${TAG}.json \
${IMAGE}:${TAG}"

run "Scan Dockerfile misconfigurations" \
"trivy config \
--misconfig-scanners dockerfile \
--format template \
--template @contrib/html.tpl \
--output /tmp/.trivy/report-config-${TAG}.html \
/tmp/app"

run "Generate vulnerability report (JSON)" \
"trivy image \
--skip-db-update \
--exit-code 0 \
--format json \
--output /tmp/.trivy/report-${TAG}.json \
--scanners vuln \
${IMAGE}:${TAG}"

run "Generate vulnerability report (HTML)" \
"trivy image \
--skip-db-update \
--exit-code 0 \
--format template \
--template @contrib/html.tpl \
--output /tmp/.trivy/report-${TAG}.html \
--scanners vuln \
${IMAGE}:${TAG}"

run "Fail pipeline if fixed vulnerabilities are found" \
"trivy image \
--skip-db-update \
--exit-code 1 \
--ignore-unfixed \
--scanners vuln \
${IMAGE}:${TAG}"
