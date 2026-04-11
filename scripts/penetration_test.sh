#!/usr/bin/env sh

set -eu

TIMESTAMP=$(date +%Y%m%d%H%M%S)

zap-api-scan.py \
	-t http://localhost:1337/openapi.json \
	-f openapi \
	-r /zap/wrk/reports/${TIMESTAMP}.html \
	-J /zap/wrk/reports/${TIMESTAMP}.json
