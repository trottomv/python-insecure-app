"""Configuration settings for the Python Insecure App."""

import os

from dotenv import find_dotenv, load_dotenv

from app.secret_manager import OpenBaoClient

load_dotenv(find_dotenv())

DEBUG = os.getenv("DEBUG", "False").lower() in ("true", "1", "yes", "y")

bao_client = OpenBaoClient.get_client()

PUBLIC_IP_SERVICE_URL = bao_client.get_secret("public_ip_service_url") or ""

SUPER_SECRET_NAME = bao_client.get_secret("super_secret_name") or "John Ripper"

SUPER_SECRET_TOKEN = bao_client.get_secret("super_secret_token")
