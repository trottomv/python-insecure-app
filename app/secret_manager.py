"""OpenBao secret manager client."""

from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path

import hvac


class SecretError(RuntimeError):
    """Raised when authentication or secret retrieval fails."""


@dataclass
class OpenBaoClient:
    client: hvac.Client

    @classmethod
    def get_client(cls) -> OpenBaoClient:
        client = hvac.Client(url=os.getenv("BAO_ADDR"))
        token_path = Path("/openbao/token")
        if token_path.exists():
            return cls.from_agent(client, token_path)
        return cls.from_env(client)

    @classmethod
    def from_agent(cls, client, token_path: Path) -> OpenBaoClient:
        if token_path.exists():
            client.token = token_path.read_text().strip()
        return cls(client)

    @classmethod
    def from_env(cls, client) -> OpenBaoClient:
        client.token = os.getenv("BAO_TOKEN") or ""
        return cls(client)

    def get_secret(
        self,
        path: str,
        mount_point: str = "app",
        key: str = "value",
    ) -> str | None:
        """Reads a KV v2 secret."""
        try:
            resp = self.client.secrets.kv.v2.read_secret_version(
                mount_point=mount_point,
                path=path,
            )
            data = resp.get("data", {}).get("data", {})
            if key in data:
                return data[key]
            return next(iter(data.values()), None)
        except Exception:
            return None
