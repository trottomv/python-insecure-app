.DEFAULT_GOAL := help

.PHONY: audit
audit: sca sast ## Audit dependencies and common security issues

.PHONY: build
build:  ## Build docker image
	docker build --pull --tag python-insecure-app .

.PHONY: build_alpine
build_alpine:  ## Build docker alpine image
	docker build --file Dockerfile.alpine --pull --tag python-insecure-app:alpine .

.PHONY: build_wolfi
build_wolfi:  ## Build docker wolfi image
	docker build --file Dockerfile.wolfi --pull --target wolfi-distroless --tag python-insecure-app:wolfi .

.PHONY: build_distroless
build_distroless:  ## Build docker distroless image
	docker build --file Dockerfile.distroless --pull --tag python-insecure-app:distroless .

.PHONY: check
check:  ## Check linting and vulnerabilities
	python3 -m ruff format --check .
	python3 -m ruff check .

.PHONY: fix
fix:  ## Fix Python code formatting, linting and sorting imports
	python3 -m ruff format .
	python3 -m ruff check --fix .

.PHONY: fuzzytest
fuzzytest: install_dev  ## Run fuzzy tests
	schemathesis run --checks all http://localhost:1337/openapi.json

.PHONY: install_base
install_base:  ## Install base requirements and dependencies
	uv pip install -r requirements/base.txt

.PHONY: install_common
install_common: requirements install_base  ## Install common requirements and dependencies
	uv pip sync requirements/common.txt

.PHONY: install_dev
install_dev: requirements install_base  ## Install dev requirements and dependencies
	uv pip sync requirements/dev.txt

.PHONY: outdated
outdated:  ## Check outdated requirements and dependencies
	python3 -m pip list --outdated

.PHONY: pentest
pentest:  ## Run pentest
	docker run --rm -t \
		--network host \
		--volume ${PWD}/.zap/reports:/zap/wrk/reports:rw \
		ghcr.io/zaproxy/zaproxy:stable \
		zap-api-scan.py \
		-t http://localhost:8000/openapi.json \
		-f openapi \
		-r reports/$(shell date +%Y%m%d%H%M%S).html \
		-J reports/$(shell date +%Y%m%d%H%M%S).json

.PHONY: precommit
precommit:  ## Run pre_commit
	python3 -m pre_commit run --all

.PHONY: precommit_update
precommit_update:  ## Update pre_commit
	python3 -m pre_commit autoupdate

.PHONY: quicktest
quicktest: install_dev  ## Run quick tests
	python3 -m coverage run --omit=./tests/* --m pytest --disable-warnings
	python3 -m coverage report

.PHONY: requirements
requirements: install_base  ## Compile requirements
	uv pip compile --generate-hashes --no-header --quiet --resolver=backtracking --strip-extras --upgrade --output-file requirements/base.txt requirements/base.in
	uv pip compile --generate-hashes --no-header --quiet --resolver=backtracking --strip-extras --upgrade --output-file requirements/common.txt requirements/common.in
	uv pip compile --generate-hashes --no-header --quiet --resolver=backtracking --strip-extras --upgrade --output-file requirements/dev.txt requirements/dev.in

.PHONY: run
run: install_common  ## Run production server
	fastapi run app/main.py

.PHONY: run_dev
run_dev: install_dev  ## Run dev mode server
	fastapi dev app/main.py --port 1337

tag ?= latest
.PHONY: run_docker
run_docker: ## Run docker distroless server with optional `tag=latest` or `tag=alpine` or `tag=distroless`
	docker run --rm \
		--env-file .env \
		--publish 8000:8000 \
		--name python_insecure_app \
		python-insecure-app:$(tag)

.PHONY: sast
sast:  ## Audit common security issues
	python3 -m bandit --exclude "./.venv,./tests" --quiet --recursive .

.PHONY: sca
sca:  ## Audit the Software Composition Analysis
	python3 -m pip_audit --require-hashes --disable-pip --requirement requirements/common.txt

.PHONY: test
test: install_dev check audit quicktest  ## Run tests

.PHONY: update
update: requirements precommit_update ## Run update

.PHONY: venv
venv: ## Create virtual environment
	uv venv --python 3.13 .venv --allow-existing

tag ?= latest
.PHONY: vuln_assessment
vuln_assessment:  ## Run vulnerability assessment with optional `tag=latest` or `tag=alpine` or `tag=distroless`
	docker run --rm \
      --entrypoint="" \
      --env GIT_STRATEGY=none \
      --env TRIVY_CACHE_DIR=/tmp/.trivycache/ \
      --env TRIVY_NO_PROGRESS=true \
      --volume /var/run/docker.sock:/var/run/docker.sock \
      --volume ${PWD}:/tmp/app \
      --volume ${PWD}/.trivy:/tmp/.trivy \
      --volume ${PWD}/.trivy/cache:/tmp/.trivycache \
      aquasec/trivy sh -c "trivy clean --scan-cache && trivy image \
		--exit-code 0 \
		--format cyclonedx \
		--output /tmp/.trivy/sbom.json \
		python-insecure-app:$(tag) && \
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
		python-insecure-app:$(tag) && \
	  trivy image \
		--exit-code 1 \
		--ignore-unfixed \
		--scanners vuln \
		python-insecure-app:$(tag)"

.PHONY: help
help:
	@echo "[Help] Makefile list commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
