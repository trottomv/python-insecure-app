"""Configuration settings for the Python Insecure App."""

import os

from dotenv import find_dotenv, load_dotenv

load_dotenv(find_dotenv())

DEBUG = os.getenv("DEBUG", "False").lower() in ("true", "1", "yes", "y")

PUBLIC_IP_SERVICE_URL = os.getenv("PUBLIC_IP_SERVICE_URL")

SUPER_SECRET_NAME = os.getenv("SUPER_SECRET_NAME")

SUPER_SECRET_TOKEN = os.getenv("SUPER_SECRET_TOKEN")
