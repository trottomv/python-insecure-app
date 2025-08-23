"""The main file for a Python Insecure App."""

import requests
from fastapi import FastAPI
from fastapi.responses import HTMLResponse
from jinja2 import Template

from app import config

app = FastAPI(
    title="Try Hack Me",
    description="A sample project that will be hacked soon.",
    version="0.0.1337",
    debug=config.DEBUG,
)


@app.get("/", response_class=HTMLResponse)
async def try_hack_me(name: str = config.SUPER_SECRET_NAME):
    """
    Root endpoint that greets the user and provides a random text.

    Args:
        name (str, optional): Name of the user. Defaults to SUPER_SECRET_NAME.

    Returns:
        str: HTML content with a greeting and a random text.
    """
    try:
        # Get the public IP address from an external service
        public_ip_response = requests.get(config.PUBLIC_IP_SERVICE_URL)
        public_ip_response.raise_for_status()
    except (requests.HTTPError, requests.exceptions.InvalidSchema):
        public_ip = "Unknown"
    else:
        public_ip = public_ip_response.text
    content = f"<h1>Hello, {name}!</h1><h2>Public IP: <code>{public_ip}</code></h2>"
    # FIXME: https://fastapi.tiangolo.com/advanced/custom-response/#return-a-response
    return Template(content).render()
