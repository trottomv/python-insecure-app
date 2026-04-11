#!/usr/bin/env sh

set -eu

DOCKERFILE="Dockerfile.distroless"

IMAGE=$(grep -E '^FROM .* AS distroless' "$DOCKERFILE" | awk '{print $2}')

if [[ -z "$IMAGE" ]]; then
	echo "❌ Error: could not find any base image in $DOCKERFILE"
	exit 1
fi

OIDC_ISSUER="https://accounts.google.com"
IDENTITY="keyless@distroless.iam.gserviceaccount.com"

echo "🔍 Verifying signature of base image..."
cosign verify \
	"$IMAGE" \
	--certificate-oidc-issuer "$OIDC_ISSUER" \
	--certificate-identity "$IDENTITY"

echo "📄 Verifying SLSA provenance..."
cosign verify-attestation \
	"$IMAGE" \
	--certificate-oidc-issuer "$OIDC_ISSUER" \
	--certificate-identity "$IDENTITY" --type="spdx"

echo "✅ Base image provenance verified!"
