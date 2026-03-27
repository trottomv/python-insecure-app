# --------------------
# justfile
# --------------------
set shell := ["bash", "-eu", "-o", "pipefail", "-c"]
set dotenv-load := false

help:
    @just --list

# --------------------
# Variables
# --------------------
image := "python-insecure-app"
tag := "latest"

# --------------------
# Audit & Security
# --------------------
# Audit the SCA and SAST
audit: sca sast
    @echo "Audit completed"

# Audit the Software Composition Analysis
sca:
    python3 -m pip_audit --require-hashes --disable-pip --requirement requirements/common.txt

# Audit common security issues
sast:
    python3 -m bandit --exclude "./.venv,./tests" --quiet --recursive .

# --------------------
# Build
# --------------------
# Build docker image
build: requirements
    docker build --pull --tag {{image}} .

# Build docker alpine image
build_alpine: requirements alpine

# Build docker distroless image
build_distroless: requirements distroless

# Build docker wolfi image
build_wolfi: requirements wolfi

# Build docker wolfi-distroless image
build_wolfi_distroless:
    echo "Building wolfi_distroless image..."
    docker build --file Dockerfile.wolfi_distroless --tag {{image}}:wolfi-distroless .

# Build alpine image
alpine:
    echo "Building alpine image..."
    docker build --file Dockerfile.alpine --pull --tag {{image}}:alpine .

# Build distroless image
distroless:
    echo "Building distroless image..."
    docker build --file Dockerfile.distroless --pull --tag {{image}}:distroless .

# Build wolfi image
wolfi:
    echo "Building wolfi image..."
    docker build --file Dockerfile.wolfi --pull --tag {{image}}:wolfi .

# --------------------
# Code quality
# --------------------
# Check linting and vulnerabilities
check:
    python3 -m ruff format --check .
    python3 -m ruff check .

# Fix Python code formatting, linting and sorting imports
fix:
    python3 -m ruff format .
    python3 -m ruff check --fix .

# --------------------
# Fuzzy tests
# --------------------
# Run fuzzy tests
fuzzytest: install_dev
    schemathesis run --checks all http://localhost:1337/openapi.json

# --------------------
# Tests
# --------------------
# Run quick tests
quicktest: install_dev
    python3 -m coverage run --omit=./tests/* --m pytest --disable-warnings
    python3 -m coverage report

# Run tests
test: install_dev check audit quicktest

# --------------------
# Dependencies
# --------------------
# Compile requirements
requirements:
    uv pip compile --generate-hashes --no-header --quiet --resolver=backtracking --strip-extras --upgrade --output-file requirements/base.txt requirements/base.in
    uv pip compile --generate-hashes --no-header --quiet --resolver=backtracking --strip-extras --upgrade --output-file requirements/common.txt requirements/common.in
    uv pip compile --generate-hashes --no-header --quiet --resolver=backtracking --strip-extras --upgrade --output-file requirements/dev.txt requirements/dev.in

# Install base requirements and dependencies
install_base:
    uv pip install -r requirements/base.txt

# Install common requirements and dependencies
install_common: requirements install_base
    uv pip sync requirements/common.txt

# Install dev requirements and dependencies
install_dev: requirements install_base
    uv pip sync requirements/dev.txt

# --------------------
# Tooling
# --------------------
# Check outdated requirements and dependencies
outdated:
    python3 -m pip list --outdated

# Run pre_commit
precommit:
    python3 -m pre_commit run --all

# Update pre_commit
precommit_update:
    python3 -m pre_commit autoupdate

# Run update
update: requirements precommit_update

# Create virtual environment
venv:
    uv venv --python 3.13 .venv --allow-existing

# --------------------
# Run
# --------------------
# Run production server
run: install_common
    fastapi run app/main.py

# Run dev mode server
run_dev: install_dev
    fastapi dev app/main.py --port 1337

# Run docker server with optional tag
run_docker tag=tag:
    docker run --rm \
        --env-file .env \
        --publish 1337:1337 \
        --name python_insecure_app \
        {{image}}:{{tag}}

# --------------------
# Verify provenance
# --------------------
# Verify distroless base image provenance
verify_distroless_provenance:
    ./scripts/verify_distroless_provenance.sh

# --------------------
# Vulnerability assessment
# --------------------
# Run vulnerability assessment
vuln_assessment image=image tag=tag:
    docker run --rm \
        --entrypoint="" \
        --env GIT_STRATEGY=none \
        --env TRIVY_CACHE_DIR=/tmp/.trivycache/ \
        --env TRIVY_NO_PROGRESS=true \
        --volume /var/run/docker.sock:/var/run/docker.sock \
        --volume $(pwd):/tmp/app \
        --volume $(pwd)/.trivy:/tmp/.trivy \
        --volume $(pwd)/.trivy/cache:/tmp/.trivycache \
        aquasec/trivy sh -c "trivy clean --scan-cache && trivy image \
            --exit-code 0 \
            --format cyclonedx \
            --output /tmp/.trivy/sbom.json \
            {{image}}:{{tag}} && \
        trivy config \
            --misconfig-scanners dockerfile \
            --format template \
            --template @contrib/html.tpl \
            --output /tmp/.trivy/report-config.html \
            /tmp/app && \
        trivy image \
            --exit-code 0 \
            --format template \
            --output /tmp/.trivy/report.html \
            --scanners vuln \
            --template @contrib/html.tpl \
            {{image}}:{{tag}} && \
        trivy image \
            --exit-code 1 \
            --ignore-unfixed \
            --scanners vuln \
            {{image}}:{{tag}}"
